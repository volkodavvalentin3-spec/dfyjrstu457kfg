AddCSLuaFile()

local ProjectileInfo = {}
ProjectileInfo.__index = ProjectileInfo
_G.ProjectileInfo = ProjectileInfo

-- Create the damage struct and effect data
local ImpactDamage = DamageInfo()
local ImpactEffect = EffectData()
local BounceEffect = EffectData()
local SplashEffect = EffectData()

local BounceOn = {
    [MAT_CONCRETE]    = true,
    [MAT_TILE]        = true,
    [MAT_PLASTIC]     = true,
    [MAT_SAND]        = false,
    [MAT_SNOW]        = false,
    [MAT_DIRT]        = true,
    [MAT_GRASS]       = true,
    [MAT_GLASS]       = false,
    [MAT_WOOD]        = false,
    [MAT_FLESH]       = false,
    [MAT_BLOODYFLESH] = false,
    [MAT_ALIENFLESH]  = false,
    [MAT_ANTLION]     = false,
    [MAT_METAL]       = true,
    [MAT_COMPUTER]    = true,
    [MAT_VENT]        = true
}

// Functions

local ConvarCache = {}
local function GetConVarCached(ConvarName)
    if ConvarCache[ConvarName] == nil then
        local ConVar = GetConVar(ConvarName)
        ConvarCache[ConvarName] = ConVar
    end

    return ConvarCache[ConvarName]
end

function util.DistanceToLineFrac(Start, End, Point)
    local Dist = Start:Distance(End)

    local DistToLine, Nearest, Fraction = util.DistanceToLine(Start, End, Point)
    Fraction = math.Clamp(Fraction / Dist, 0, 1)

    return DistToLine, Nearest, Fraction
end

local function Spread(Normal, Degrees, Seed, Extra)
    Extra = Extra-1 or 0
    local correctDegrees = 1 - math.cos(math.rad(Degrees))
    local u = util.SharedRandom(Seed, 0, correctDegrees, Extra)
    local v = util.SharedRandom(Seed, 0, 1, Extra + 1)

    local phi = v * 2 * math.pi 
    local cosTheta = math.sqrt(1 - u)
    local sinTheta = math.sqrt(1 - cosTheta * cosTheta)
    local Final = Vector(cosTheta, math.cos(math.deg(phi)) * sinTheta, math.sin(math.deg(phi)) * sinTheta)
    Final:Rotate(Normal:Angle())
    return Final
end

local function Reflect(incident, normal)
    return incident - 2 * (incident:Dot(normal)) * normal
end

local function Squash(vec, planeNormal, scalar)
    return vec - (planeNormal * planeNormal:Dot(vec) * scalar)
end

local function Fallback(tbl, index, fallback)
    if not tbl then return end
    if not index then return end

    if tbl[index] == nil then
        tbl[index] = fallback
    end
end


local function ToBinary(Number)
    local theString = ""

    local n = 32
    for i=1, n do
        local toCheck = 2 ^ (n - i)

        if bit.band(Number, toCheck) == toCheck then
            theString = theString .. "1"
        else
            theString = theString .. "0"
        end
    end
    return theString
end

local function IsEntityVisible(Entity)
    if not Entity or not Entity:IsValid() then return end
    local flags = Entity:GetEFlags()
    return bit.band(flags, EF_NODRAW) == EF_NODRAW
end

local function GetMuzzlePosition(self)
    local MuzzlePosition
    -- Get the muzzle position
    if self:IsPlayer() then
        local ActiveWeapon = self:GetActiveWeapon()
        local ViewModel = self:GetViewModel()

        -- Get the viewmodel from the weapon itself if its possible
        if ActiveWeapon and ActiveWeapon:IsValid() and ActiveWeapon.GetViewModel then
            ViewModel = ActiveWeapon:GetViewModel() or ViewModel
        end

        -- If the world model is visible, use the world model
        if IsEntityVisible(ActiveWeapon) then
            ViewModel = ActiveWeapon
        end

        -- If "muzzle" doesnt exist use the first attachment which is usually the muzzle
        --[[local MuzzleID = ViewModel:LookupAttachment("muzzle")
        if MuzzleID == 0 and ViewModel:GetAttachment(1) then 
            MuzzleID = 1
        end

        -- Get the muzzle attachment
        if MuzzleID > 0 then
            local Muzzle = ViewModel:GetAttachment(MuzzleID)
            if Muzzle then
                MuzzlePosition = Muzzle.Pos
            end
        end]]
    end
    if MuzzlePosition then
        debugoverlay.Sphere(MuzzlePosition, 3, 5, Color(255, 255, 255, 0), false)
    end

    return MuzzlePosition
end


-- Gets the player metatable
PlayerMeta = FindMetaTable("Player")

local VectorZERO = Vector(0, 0, 0)

local DefaultBulletInfo = {
    Attacker = NULL,
    Callback = nil,
    Damage = 1,
    Force = 1,
    Distance = 56756,
    HullSize = 0,
    Num = 1,
    Tracer = 1,
    AmmoType = "",
    Dir = VectorZERO,
    Spread = VectorZERO,
    Src = VectorZERO,
    IgnoreEntity = NULL
}

-- Creates a basic projectile structure
function ProjectileInfo:New()
    local self = {}

    local Default = DefaultBulletInfo
    self.BulletInfo = Default

    -- Projectile specific variables
    self.Position = VectorZERO
    self.LastPosition = VectorZERO
    self.InterpolatedPosition = VectorZERO
    self.Velocity = VectorZERO
    self.Forward = VectorZERO
    self.MoveTrace = {}
    self.TickCount = 0
    self.Attacker = NULL 
    self.First = true
    self.TimeSinceLastSimulation = 0
    self.TickLifetime = 0
    self.TicksSinceLastBounce = 0
    self.Cracked = false
    self.AwaitingNextHit = false

    -- Variables for the managers
    self.Manager = nil
    self.Index = 0

    return setmetatable(self, ProjectileInfo)
end

local CustomBulletSpeed = {
    ["tfa_doik98"] = true and 1.8,
    ["tfa_doik98_scop"] = true and 1.8,
    ["tfa_doienfield"] = true and 1.8,
    ["tfa_doim1garand"] = true and 1.8,
    ["tfa_doim1carbine"] = true and 1.8,
    ["tfa_doispringfield"] = true and 1.8,
    ["tfa_doienfield_scop"] = true and 1.8,
    ["tfa_doispringfield_scop"] = true and 1.8,
}

-- Setups the projectile structure
function ProjectileInfo:Setup(BulletInfo)
    for k,v in pairs(BulletInfo) do
        self.BulletInfo[k] = v
    end
    
    --PrintTable(BulletInfo)

    local Damage, AmmoType = self.BulletInfo.Damage, self.BulletInfo.AmmoType
    if Damage == 0 and (AmmoType ~= "" and AmmoType ~= nil) then
        self.AmmoID = game.GetAmmoID(AmmoType)
    elseif Damage == 0 and (AmmoType == nil or AmmoType == "") then

        self.BulletInfo.Damage = self.BulletInfo.Weapon.Damage * 0.7

    end

    self.Settings = self.BulletInfo.Settings or {}
    self.BulletInfo.Settings = nil

    Fallback(self.Settings, "Speed", 20000)
    Fallback(self.Settings, "Gravity", 1000)
    Fallback(self.Settings, "MaxBounceAngle", 0.07)
    Fallback(self.Settings, "ShouldBounce", true)
    Fallback(self.Settings, "EnableSounds", true)


    self.BulletInfo.Spread = nil
    self.Position = BulletInfo.Src
    self.LastPosition = self.Position
    self.InterpolatedPosition = self.Position
    self.VirtualPosition = GetMuzzlePosition(BulletInfo.Attacker)
    self.TimeAtLastSimulation = UnPredictedCurTime()

    self.Velocity = BulletInfo.Dir * self.Settings.Speed

    if self.BulletInfo.Damage >= 100 then
        self.Velocity = BulletInfo.Dir * (self.Settings.Speed * 1.8)
    end

    if IsValid(BulletInfo.Attacker) and BulletInfo.Attacker:IsPlayer() then
        if IsValid(BulletInfo.Attacker:GetActiveWeapon()) then
            if CustomBulletSpeed[BulletInfo.Attacker:GetActiveWeapon():GetClass()] then
                self.Velocity = BulletInfo.Dir * (self.Settings.Speed * CustomBulletSpeed[BulletInfo.Attacker:GetActiveWeapon():GetClass()])
            end
        end
    end

    --self.Velocity = BulletInfo.Dir * self.Settings.Speed
    self.Forward = self.Velocity:GetNormalized()
    self.Attacker = BulletInfo.Attacker

    self.InitialPos = self.Attacker:GetPos()
end

function ProjectileInfo:CalculateSpread(BulletInfo, Seed, Extra)
    if not BulletInfo.Spread then return end
    BulletInfo.Dir = Spread(BulletInfo.Dir, BulletInfo.Spread[1] * 90, Seed, Extra)
end

function ProjectileInfo:SetTickCount(TickCount)
    self.TickCount = TickCount
end

function ProjectileInfo:GetTickCount()
    return self.TickCount
end

function ProjectileInfo:GetSimulationTick()
    return self.TickLifetime
end

function ProjectileInfo:SetManager(Manager, Index)
    self.Manager = Manager
    self.Index = Index
end

function ProjectileInfo:GetManager()
    return self.Manager
end

function ProjectileInfo:Delete()
    self.Manager:RemoveProjectile(self)
    table.Empty(self)
end

function ProjectileInfo:InterpolatePositions()
    if self == nil then return end

    if self.AwaitingNextHit then
        self.InterpolatedPosition = self.Position
        return
    end
    local CurrentTime = UnPredictedCurTime()
    local TimePassed = math.Clamp((CurrentTime - self.TimeAtLastSimulation) / engine.TickInterval(), 0, 1)
    self.InterpolatedPosition = LerpVector(TimePassed, self.LastPosition, self.Position)
end

local _AmmoTypeCache = {}
function GetAmmoTypeDamage(AmmoID)
    -- Attempt to return a cached value first.
    if _AmmoTypeCache[AmmoID] then return _AmmoTypeCache[AmmoID] end
    -- Set the cached variable for appropriate ammo type.
    _AmmoTypeCache[AmmoID] = game.GetAmmoPlayerDamage(AmmoID)

    return _AmmoTypeCache[AmmoID]
end

function ProjectileInfo:CalculateDamage(Entity)
    if not self.AmmoID or self.AmmoID == "" then return self.BulletInfo.Damage end

    local Damage = GetAmmoTypeDamage(self.AmmoID)

    return Damage
end

function ProjectileInfo:FireBullet()
    if not self.MoveTrace.Hit then return end

    local HitEntity = self.MoveTrace.Entity
    if HitEntity and HitEntity:IsValid() and HitEntity ~= self.Attacker then
        local CalculatedDamage = self:CalculateDamage(HitEntity)

        local Attacker = self.Attacker
        local Inflictor = self.Attacker
        if self.Attacker:GetOwner():IsValid() then
            Attacker = self.Attacker:GetOwner()
        end
        if self.Attacker:IsPlayer() and self.Attacker:GetActiveWeapon():IsValid() then
            Inflictor = self.Attacker:GetActiveWeapon()
        end

        --PrintTable(self.BulletInfo)
        -- Setup damage
        local ImpactDamage = DamageInfo()
        ImpactDamage:SetDamageType(DMG_BULLET)
        ImpactDamage:SetDamage(CalculatedDamage)
        ImpactDamage:SetDamageForce(self.Forward * self.BulletInfo.Force * 300)
        ImpactDamage:SetAttacker(Attacker)
        ImpactDamage:SetInflictor(Inflictor)
        ImpactDamage:SetDamagePosition(self.MoveTrace.HitPos)
        ImpactDamage:SetReportedPosition(self.MoveTrace.HitPos)

        -- Apply Force
        --[[if SERVER then
            local Phys = HitEntity:GetPhysicsObjectNum(self.MoveTrace.PhysicsBone)

            if not Phys or not Phys:IsValid() then
                ImpactDamage:SetDamageForce((self.Forward * self.BulletInfo.Weapon.Force * 1500) + Vector(0, 0, 500))
            else
                ImpactDamage:SetDamageForce(Vector(0, 0, 0))
                Phys:ApplyForceOffset(self.Forward * self.BulletInfo.Weapon.Force * 300, self.MoveTrace.HitPos)
            end
        end]]

        -- Apply damage to entity
        HitEntity:DispatchTraceAttack(ImpactDamage, self.MoveTrace, self.Forward)
    end

    if not self.Manager:GetPrediction() or CLIENT then
        -- Setup impact effect
        ImpactEffect:SetDamageType(DMG_BULLET)
        ImpactEffect:SetEntity(HitEntity)
        ImpactEffect:SetOrigin(self.MoveTrace.HitPos + self.MoveTrace.Normal)
        ImpactEffect:SetStart(self.Position - self.MoveTrace.Normal * 4)
        ImpactEffect:SetSurfaceProp(self.MoveTrace.SurfaceProps)
        ImpactEffect:SetHitBox(self.MoveTrace.HitBox)
        ImpactEffect:SetNormal(self.MoveTrace.HitNormal)

        -- Apply effect
        util.Effect("Impact", ImpactEffect)
        
        if HitEntity:IsWorld() or not HitEntity:IsPlayer() then
            local Eff = EffectData()
	        Eff:SetOrigin(self.MoveTrace.HitPos)
	        Eff:SetScale(.25)
	        Eff:SetNormal(self.MoveTrace.HitNormal)
	        util.Effect("eff_jack_gmod_efpburst", Eff, true, true)

            local Eff = EffectData()
	        Eff:SetOrigin(self.MoveTrace.HitPos)
	        util.Effect("battlefieldsmoke", Eff)
        end
    end

    //-- Call callback
    if self.BulletInfo.Callback then
        self.BulletInfo.Callback(self.Attacker, self.MoveTrace, ImpactDamage)
    end
end

local EntBounce = {
    "prop_physics",
    "worldspawn",
    "lvs",
    "build_prop"
}

function ProjectileInfo:ShouldBounce()
    -- Self explanatory
    if not BounceOn[self.MoveTrace.MatType] then
        return false
    end

    -- Dont bounce if the speed is not high enough
    if self.Velocity:LengthSqr() < (1000 ^ 2) then
        return false
    end

    -- Dont bounce on anything other than props and world
    if self.MoveTrace.Entity and self.MoveTrace.Entity:IsValid() then
        local EntityClass = self.MoveTrace.Entity:GetClass()
        
        local DoBounce = false

        for k,v in pairs(EntBounce) do 
            if string.find(EntityClass, v) then DoBounce = true end
        end

        if not DoBounce then
            return false 
        end
    
    end

    local Dot = self.MoveTrace.HitNormal:Dot(-self.Forward:GetNormalized())

    if math.random(0,5) == 5 then
        Dot = 0 
    end

    return (Dot < self.Settings.MaxBounceAngle) and (self.MoveTrace.Fraction ~= 0)
end

function ProjectileInfo:Simulate()
    local Settings = self.Settings
    --local UpdateRate = engine.TickInterval()
    local UpdateRate
    if SERVER then
        UpdateRate = engine.TickInterval() * GetConVarCached("host_timescale"):GetFloat()
    else
        UpdateRate = engine.ServerFrameTime()
    end
    
    local Velocity = self.Velocity - (self.Velocity * 0.1)

    util.TraceLine({
        start = self.Position,
        endpos = self.Position + Velocity * UpdateRate,
        filter = self.Attacker,
        mask = MASK_SHOT,
        output = self.MoveTrace
    })


    self.LastPosition = self.Position
    self.Position = self.MoveTrace.HitPos
    self.Forward = Velocity:GetNormalized()

    -- Bounce, wtf is this honestly
    self.TicksSinceLastBounce = self.TicksSinceLastBounce + 1
    if self.MoveTrace.Hit and Settings.ShouldBounce then
        local Fraction = (1 - self.MoveTrace.Fraction)
        local Hit = false
        local LastVelocity = Velocity
        for i=1, 16 do
            if not self:ShouldBounce() then break end

            self:OnBounce()
            LastVelocity = self.Velocity

            if not self.MoveTrace.Hit then break end

            util.TraceLine({
                start = self.Position,
                endpos = self.Position + self.Velocity * UpdateRate * Fraction,
                filter = self.Attacker,
                mask = MASK_SHOT,
                output = self.MoveTrace
            })
            self.Position = self.MoveTrace.HitPos
            self.LastPosition = self.Position

            Fraction = Fraction - self.MoveTrace.Fraction

            if --[[Fraction <= 0]] math.random(0,2) < 2 then break end
            self.MoveTrace.Hit = false
        end
        self.Forward = LastVelocity:GetNormalized()
    end
    
    if self.MoveTrace.Hit and not self.AwaitingNextHit then
        self.AwaitingNextHit = true
        self.MoveTrace.Hit = false
    end

    -- Apply gravity
    local Gravity = Vector(0, 0, -Settings.Gravity) * UpdateRate
    self.Velocity = self.Velocity + Gravity

    self.TimeAtLastSimulation = UnPredictedCurTime()
    self.First = self.TickLifetime < 1
    self.TickLifetime = self.TickLifetime + 1

    self:OnSimulate()
end

local function PointContents(Pos, Content)
    return bit.band(util.PointContents(Pos), Content) == Content
end

// BUG!!!
// The bubbles are books on gm_novenka (wtf?)
local function BubbleTrail(Start, End, Count)
    for i=0, Count-1 do
        local Delta = (Count == 1) and 0.5 or i / (Count-1)
        local InterpolatedPosition = LerpVector(Delta, Start, End)

        effects.Bubbles(InterpolatedPosition + Vector(-6, -6, -6), InterpolatedPosition + Vector(6, 6, 6), 2, math.random() * 32, 64, 0)
    end
end

// TODO make this better 
function ProjectileInfo:SimulateWaterDrag()
    local SpeedLoss = 0.5

    local MoveTrace = self.MoveTrace
    local InWater = PointContents(MoveTrace.StartPos, CONTENTS_WATER) or PointContents(MoveTrace.StartPos, CONTENTS_TRANSLUCENT)

    if InWater then
        local VelocityLength = self.Velocity:Length()
        self.Velocity = self.Velocity - (self.Velocity * SpeedLoss)
        if VelocityLength < 100 then
            self:Delete()
        end

        if VelocityLength > 2000 then
            BubbleTrail(MoveTrace.StartPos, MoveTrace.HitPos, 8)
        end
    end
end

function ProjectileInfo:OnSimulate()
    if SERVER then
        --[[for k, v in ipairs(ents.FindInSphere( self.Position, 300 )) do
            if v:IsPlayer() and self.Attacker ~= v then
                local dist = 300
                local distdist = dist * dist

                if self.InitialPos:DistToSqr(v:GetPos()) < distdist then return end

                v:SetCrazy(v:GetCrazy() + 0.03)
            end
        end]]
    end

    -- Do splash effects
    local MoveTrace = self.MoveTrace

    local IsSlime = PointContents(MoveTrace.HitPos, CONTENTS_SLIME)
    local InWater = PointContents(MoveTrace.HitPos, CONTENTS_WATER) or IsSlime // CONTENTS_TRANSLUCENT
    if InWater and CLIENT then
        local WaterTrace = {}
        util.TraceLine({
            start = self.LastPosition,
            endpos = MoveTrace.HitPos,
            filter = self.Attacker,
            mask = MASK_WATER,
            output = WaterTrace
        })

        if WaterTrace.Hit and not WaterTrace.StartSolid then

            local Flags = IsSlime and 1 or 2

            -- Setup splash effect
            SplashEffect:SetOrigin(WaterTrace.HitPos)
            SplashEffect:SetSurfaceProp(WaterTrace.SurfaceProps)
            SplashEffect:SetFlags(Flags)
            SplashEffect:SetScale(6)

            -- Apply effect
            util.Effect("gunshotsplash", SplashEffect)
        end
    end

    self:SimulateWaterDrag()
end

function ProjectileInfo:OnHit()
    -- Dont do anything if the bullet hit the sky
    if self.MoveTrace.HitSky then 
        self:Delete()
        return
    end

    -- Dont do anything if the attacker is no longer valid 
    if not self.Attacker or not self.Attacker:IsValid() then
        self:Delete()
        return
    end

    -- Impact sounds
    if CLIENT and self.Settings.EnableSounds and BounceOn[self.MoveTrace.MatType] then
        EmitSound("sonic_Crack.Distant", self.MoveTrace.HitPos, 0, CHAN_STATIC, 5, 160, 0, 150, 0)
    end

    -- Fire the bullet
    self:FireBullet()

    -- Delete the projectile
    self:Delete()
end

function ProjectileInfo:OnBounce()
    local SpeedLoss = math.Rand(0.4, 0.6)--1 - (self.MoveTrace.HitNormal:Dot(-self.Forward))

    

    self.Velocity = Reflect(self.Velocity, self.MoveTrace.HitNormal) * SpeedLoss
    self.Cracked = false
    self.TicksSinceLastBounce = 0

    local HalfNormal = (self.Forward + self.MoveTrace.HitNormal):GetNormalized()
    BounceEffect:SetOrigin(self.Position)
    BounceEffect:SetNormal(HalfNormal)
    BounceEffect:SetMagnitude(1)
    BounceEffect:SetScale(0.05)
    util.Effect( "ElectricSpark", BounceEffect)

    -- Play bounce sound
    if CLIENT and self.Settings.EnableSounds then
        EmitSound("sonic_Crack.Distant", self.MoveTrace.HitPos, 0, CHAN_STATIC, 5, 160, 0, 255, 0)
    end
end

if CLIENT then
    // Rendering

    local GlowEffect = Material("sprites/orangecore2")
    local Tracer = Material("effects/tracer_middle")
    local NewGlowEffect = Material( "sprites/light_glow02_add" )

    local r = 3
    local Quad = {Vector(0, r, r), Vector(0, r, -r), Vector(0, -r, -r), Vector(0, -r, r)}
    local bullet_color = Color( 255, 200, 0, 255 )
    function ProjectileInfo:Render()
        if self == nil then return end

        local BulletSpeed = self.Velocity:Length() * engine.TickInterval()
        local IsAttackerPlayer = self.Attacker == LocalPlayer()

        local InterpolatedPosition = self.InterpolatedPosition
        local TicksSinceLastBounce = self.TicksSinceLastBounce
        local LastPosition = self.LastPosition
        local sForward = self.Forward
        local TickLifetime = self.TickLifetime

        local BaseWidth = math.Clamp(LocalPlayer():GetPos():DistToSqr(InterpolatedPosition) / (100^2), 50, 150)
        local BaseHight = BaseWidth * 0.6

        local DirectionToBullet = (InterpolatedPosition - EyePos()):GetNormalized()

        local dot = EyeAngles():Forward():Dot(DirectionToBullet)
        local angle = math.deg(math.acos(math.Clamp(dot, -1, 1)))
        local normalizedAngle = math.min(angle, 180 - angle)
        local WidthFactor = normalizedAngle / 90
        --local HightFactor = normalizedAngle * WidthFactor

        local width = math.Min(Lerp(WidthFactor, BaseWidth, 2500), 250)
        --local hight = Lerp(HightFactor, BaseHight, 700)

        -- Render the tracer
        local RenderTick = 2.5 -- Amount of ticks/frame to skip before rendering the tracer
        if TicksSinceLastBounce > RenderTick then
            if TicksSinceLastBounce < (RenderTick - 1) then 
                render.SetMaterial(Tracer)
                render.DrawBeam(InterpolatedPosition, LastPosition, 8.5, 0, 1)

                render.SetMaterial( NewGlowEffect )
	            render.DrawSprite( InterpolatedPosition, width, width * 0.5 --[[hight]], bullet_color )
            else
                render.SetMaterial(Tracer)
                render.DrawBeam(InterpolatedPosition, InterpolatedPosition - sForward * BulletSpeed * 1, 12, 0, 1)

                render.SetMaterial( NewGlowEffect )
	            render.DrawSprite( InterpolatedPosition, width, width * 0.5 --[[hight]], bullet_color )
            end
        end

        -- Render the tracer for a couple frames so it looks like the bullet came out the gun
        local Bounced = (TicksSinceLastBounce ~= TickLifetime)
        local ShouldRender = (TickLifetime >= 2 and TickLifetime <= 2) -- Amount of frames here
        local MuzzlePosition = self.VirtualPosition

        if not Bounced and ShouldRender and MuzzlePosition then
            render.SetMaterial(Tracer)
            render.DrawBeam(InterpolatedPosition, MuzzlePosition, 8.5, 0, 1)

            render.SetMaterial(GlowEffect)
            render.DrawBeam(InterpolatedPosition, MuzzlePosition, 15, 1, 0.3)

            render.SetMaterial( NewGlowEffect )
	        render.DrawSprite( InterpolatedPosition, width, width * 0.5 --[[hight]], bullet_color )
        end

        -- Skip 2 frames before rendering
        if TicksSinceLastBounce > 2 then
            local EyePosition = EyePos()
            local BulletPosition = InterpolatedPosition
            local BulletForward = sForward
            
            local NewQuad = {}
    
            for k, Vert in pairs(Quad) do
                local Vert = Vector(Vert[1], Vert[2], Vert[3])
                
                local DirectionToBullet = (BulletPosition - EyePosition):GetNormalized()
                local DirectionToVert = ((Vert + BulletPosition) - EyePosition):GetNormalized()
            
                Vert:Rotate((-DirectionToBullet):Angle())
                
                local DotToBullet = math.ease.OutCubic(1 - (math.abs(DirectionToVert:Dot(BulletForward)) * 0.9))

                Vert = Squash(Vert, BulletForward, -BulletSpeed * 0.05 / DotToBullet)
                --Vert = Squash(Vert, DirectionToBullet, 1)
            
                NewQuad[k] = Vert + BulletPosition
            end
            render.SetMaterial(GlowEffect)
            render.DrawQuad(NewQuad[1], NewQuad[2], NewQuad[3], NewQuad[4])
        end
    end

    // Sounds
    function ProjectileInfo:Crack()
        if not self.Settings.EnableSounds then return end

        if self == nil then return end

        local LocalVelocity = self.Velocity - LocalPlayer():GetVelocity()
        local LocalSpeed = LocalVelocity:Length()

        local Eyepos = EyePos()

        if self.Position:DistToSqr(Eyepos) > 1500^2 then return end
        if self.Cracked then return end


        local Start, End = self.LastPosition, self.Position
        local DistanceToLine, Point, Fraction = util.DistanceToLineFrac(Start, End, Eyepos)

        local Distances = {
            {100, "sonic_Crack.Light", 1},
            {400, "sonic_Crack.Heavy", 1 - ((DistanceToLine / 400) * 0.5)},
            {1200, "sonic_Crack.Medium", 1 - (DistanceToLine / 1200)}
        }
        if not self.First and Fraction < 1 and LocalSpeed > 10000 then
            for i=1, #Distances do
                local TheFuck = Distances[i]
                if DistanceToLine < TheFuck[1] then
                    self.Cracked = true
                    local Volume = TheFuck[3]
                    local SoundPath = TheFuck[2]
                    EmitSound(SoundPath, Point, 0, CHAN_AUTO, Volume, 150, 0, 100, 0)
                    break
                end
            end
        end
    end

    local effect_amount = 0
    local supr_delay = 0

    function ProjectileInfo:Suppression()
        if self == nil then return end

        local Eyepos = EyePos()

        if self.Attacker == LocalPlayer() or LocalPlayer():InVehicle() then return end
        if IsValid(self.BulletInfo.Attacker) then
            if self.BulletInfo.Attacker:GetPos():DistToSqr(Eyepos) < 128^2 then return end
        end

        --PrintTable(self)

        local dist = 300
        local distdist = dist * dist

        if self.InitialPos:DistToSqr(Eyepos) < distdist then return end

        if LocalPlayer():Alive() and (self.Position:DistToSqr(Eyepos) < distdist) and CurTime() > supr_delay then
            effect_amount = math.Clamp(effect_amount + 0.1, 0, 1)
            sound.Play("bul_snap/supersonic_snap_" .. math.random(1,18) .. ".wav", self.Position, 75, 100, 1)
            sound.Play("bul_flyby/subsonic_" .. math.random(1,27) .. ".wav", self.Position, 75, 100, 1)

            local angle = Angle(math.Rand(-3.5, 3.5) * (effect_amount * 3)), 
                                math.Rand(-3.5, 3.5) * (effect_amount * 3), 
                                math.Rand(-3.5, 3.5) * (effect_amount * 3)
            Viewpunch(angle)
            supr_delay = CurTime() + 0.08

            LocalCrazy = LocalCrazy + 0.05
            
            --print(self.Attacker)
        end
    end

    --Другой мусор подавления
    local started_effect = false
    hook.Add("Think", "suppression_loop", function() 
    	if effect_amount == 0 then
    		if started_effect then

    			started_effect = false
    		end
    	 	return 
    	end

    	effect_amount = math.Clamp(effect_amount - 0.2 * FrameTime(), 0, 1)
    	started_effect = true
    end)

    local sharpen_lerp = 0
    local bloom_lerp = 0
    local effect_lerp = 0
    -- hook.Add("RenderScreenspaceEffects", "suppression_ApplySuppression", function()
    -- 	if effect_amount == 0 then return end

    -- 	--[[sharpen_lerp = Lerp(6 * FrameTime(), sharpen_lerp, effect_amount * 2.5)
    -- 	DrawSharpen(sharpen_lerp , 0.4)

    -- 	bloom_lerp = Lerp(6 * FrameTime(), bloom_lerp, effect_amount * 2.5)
    -- 	DrawBloom(0.30, bloom_lerp , 0.33, 4.5, 1, 0, 1, 1, 1)]]

    -- 	--[[if suppression_blur:GetBool() then
    -- 		effect_lerp = Lerp(6 * FrameTime(), effect_lerp, effect_amount)
    -- 		if (supression_blur_style:GetFloat()) == 0 then
    -- 			DrawBokehDOF(effect_lerp * supression_blur_intensity:GetFloat(), 0, 0 )
    -- 		else
    -- 			DrawBokehDOF(effect_lerp * supression_blur_intensity:GetFloat(), 0.05, 0.25 )
    -- 		end
    -- 	end]]
    -- end)

    local m = Material("vignette/vignette")
    local alphanew = 0
    hook.Add("RenderScreenspaceEffects", "suppression_vignette", function()
    	if effect_amount == 0 then return end

    	alphanew = Lerp(6 * FrameTime(), alphanew, effect_amount)

    	render.SetMaterial(m)
    	m:SetFloat("$alpha", alphanew)

    	for i = 1, 4 do render.DrawScreenQuad() end
    end)

    hook.Add("PlayerInitialSpawn", "suppression_Initialize", function(ply)
    	effect_amount = 0
    end)

    hook.Add("PlayerDeath", "suppression_ClearDeath", function(ply, i, a)
    	effect_amount = 0
    end)
end

/////////////////////////////////////////////////////////////////////////////////////////////////////

local C_ProjectileManager = {}
C_ProjectileManager.__index = C_ProjectileManager
_G.C_ProjectileManager = C_ProjectileManager


-- Create a projectile manager
function C_ProjectileManager:New()
    local self = {}

    self.Projectiles = {}
    self.AttachedEntity = NULL 
    self.ShouldPredict = true
    self.Index = 0

    return setmetatable(self, C_ProjectileManager)
end

function C_ProjectileManager:EnablePrediction()
    self.ShouldPredict = true
end

function C_ProjectileManager:DisablePrediction()
    self.ShouldPredict = false
end

function C_ProjectileManager:GetPrediction()
    return self.ShouldPredict
end

function C_ProjectileManager:AttachToPlayer(Player)
    -- Sets the manager for the player, returns false if failed to assign manager
    local WasAssigned = Player:SetProjectileManager(self)

    -- Failed to assign manager
    if not WasAssigned then return end

    self.AttachedEntity = Player
end

-- Gets the entity the manager is attached to
function C_ProjectileManager:GetAttachedEntity()
    return self.AttachedEntity
end

-- Checks if the manager is attached to an entity
function C_ProjectileManager:IsAttachedToEntity()
    return self.AttachedEntity ~= nil and self.AttachedEntity ~= NULL
end

-- Gets projectiles from the list
function C_ProjectileManager:GetProjectiles()
    return self.Projectiles
end

-- Add projectile to the list
function C_ProjectileManager:AddProjectile(_ProjectileInfo)
    local Index = table.insert(self.Projectiles, _ProjectileInfo)
    _ProjectileInfo:SetManager(self, Index)
end

-- Removes projectile from the list
function C_ProjectileManager:RemoveProjectile(_ProjectileInfo)
    self.Projectiles[_ProjectileInfo.Index] = nil
end

function C_ProjectileManager:CreateProjectile(BulletInfo)
    -- Prevent prediction from the engine
    if self:GetPrediction() and not IsFirstTimePredicted() then return end

    -- Create a new projectile structure
    local Projectile = ProjectileInfo:New()

    -- Setup the projectile structure
    Projectile:Setup(BulletInfo)

    -- Get the entity which the manager is attached to
    local AttachedEntity = self:GetAttachedEntity()
    if AttachedEntity:IsPlayer() then
        -- Set attacker of the projectile in case it is not set
        --Projectile.BulletInfo.Attacker = AttachedEntity

        if self:GetPrediction() and GetPredictionPlayer() == AttachedEntity then
            -- Get the current command
            local CUserCmd = AttachedEntity:GetCurrentCommand()

            -- Set the tick at which the bullet was fired (allows for mostly accurate lag compensation)
            if CUserCmd then
                Projectile:SetTickCount(CUserCmd:TickCount())
            else
                Projectile:SetTickCount(engine.TickCount())
            end
        else
            -- Cannot use current command when not in a prediction so we use the server tick count
            Projectile:SetTickCount(engine.TickCount())
        end
    else 
        Projectile:SetTickCount(engine.TickCount())
    end

    -- Call the internal hook function
    self:OnCreateProjectile(Projectile.BulletInfo)

    -- Add projectile to the manager's projectile list
    self:AddProjectile(Projectile)
    return Projectile
end

function C_ProjectileManager:OnCreateProjectile(BulletInfo)
    -- Hi
end

if SERVER then
    function C_ProjectileManager:OnSetupMove(Player, CMoveData, CUserCmd)
        if not self:GetPrediction() then return end
        if not IsFirstTimePredicted() then return end

        C_LagCompensationManager:StartLagCompensation(Player)
        for _, Projectile in next, self:GetProjectiles() do
            
            local TargetTick = Projectile:GetTickCount() + Projectile:GetSimulationTick() - 1
            C_LagCompensationManager:BacktrackTo(TargetTick)
            Projectile:Simulate()

            if table.IsEmpty(Projectile) then continue end
            
            C_HitboxSystem:QueryRaycast(Projectile.MoveTrace, function()
                Projectile:OnHit()
            end)
        end
        C_LagCompensationManager:EndLagCompensation()
    end
else
    function C_ProjectileManager:OnSetupMove(Player, CMoveData, CUserCmd)
        if not self:GetPrediction() then return end
        if not IsFirstTimePredicted() then return end
    
        for _, Projectile in next, self:GetProjectiles() do

            if table.IsEmpty(Projectile) then continue end

            if Projectile == nil then continue end

            Projectile:Simulate()
            
            if Projectile.MoveTrace.Hit then
                Projectile:OnHit()
            end
        end

    end
end

function C_ProjectileManager:OnSetupMoveUnpredicted()
    if self:GetPrediction() then return end
    for _, Projectile in next, self:GetProjectiles() do

        if table.IsEmpty(Projectile) then continue end

        if Projectile == nil then continue end

        Projectile:Simulate()

        if Projectile.MoveTrace.Hit then
            Projectile:OnHit()
        end
    end
end


if CLIENT then
    function C_ProjectileManager:InterpolateProjectilePositions()
        for _, Projectile in next, self:GetProjectiles() do

            if table.IsEmpty(Projectile) then continue end

            if Projectile == nil then continue end

            Projectile:InterpolatePositions()
        end
    end

    function C_ProjectileManager:RenderProjectiles()
        for _, Projectile in next, self:GetProjectiles() do

            if table.IsEmpty(Projectile) then continue end

            if Projectile == nil then continue end

            Projectile:Render()
        end
    end

    function C_ProjectileManager:CrackProjectiles()
        for _, Projectile in next, self:GetProjectiles() do

            if table.IsEmpty(Projectile) then continue end

            if Projectile == nil then continue end

            Projectile:Crack()
        end
    end

    function C_ProjectileManager:SupressProjectiles()
        for _, Projectile in next, self:GetProjectiles() do

            if table.IsEmpty(Projectile) then continue end

            if Projectile == nil then continue end

            Projectile:Suppression()
        end
    end
end

/////////////////////////////////////////////////////////////////////////////////////////////////////

function PlayerMeta:GetProjectileManager()
    return self.ProjectileManager
end

function PlayerMeta:SetProjectileManager(Manager)
    -- Only allow one manager per player
    -- The manager was not assigned
    if self:GetProjectileManager() ~= nil then return false end
    
    self.ProjectileManager = Manager

    -- The manager was assigned
    return true 
end

function PlayerMeta:RemoveProjectileManager()
    self.ProjectileManager = nil
end
