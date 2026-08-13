AddCSLuaFile()

SWEP.PrintName			= "magic shield"
SWEP.Author			= "(your name)"
SWEP.Instructions		= "Left mouse to fire a chair!"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

local shield_model = "models/props_phx/construct/metal_plate_curve2x2.mdl" 
local mat = "models/props_combine/stasisshield_sheet"
local color = Color(255,255,255,50)

local snd = Sound("ambient/energy/force_field_loop1.wav")

local function CreateShieldProp()
    local prop = ents.Create("prop_physics")
    prop:SetModel(shield_model)
    prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
    prop:SetColor(color)
    prop:SetMaterial(mat)
    prop:SetRenderMode(RENDERMODE_TRANSALPHA)
    prop:SetRenderFX(kRenderFxHologram)

    return prop
end
local vec_offset = Vector(0,0,0)

function SWEP:ShieldPos()
    local shield = self.Shield //or self:GetNWEntity("Shield")
    if CLIENT then
        shield = self:GetNWEntity("Shield")
    end
    local owner = self:GetOwner() 
    local center = shield:OBBCenter()

    //local pos = owner:GetShootPos()
    //pos = pos - vec_offset

    pos  = owner:LocalToWorld(vec_offset) + owner:GetRenderAngles():Forward() * 70
    return pos 
end

function SWEP:Deploy()
    self:SetHoldType("magic")
    self.NextSpark = 0
    if CLIENT then return end
    self.Shield = CreateShieldProp()

    self.Shield:SetPos(self:ShieldPos())
    self.Shield:Spawn()

    local phys = self.Shield:GetPhysicsObject()

    if phys then
        phys:EnableMotion(false)
    end

    self.Snd = CreateSound(self, snd)
    //self.Snd:SetSoundLevel(100)
    self.Snd:PlayEx(1, 100)

    self.NextSpark = 0
    self.DeployTime = CurTime()
    //self:GetOwner():Say("МАГИЧЕСКИЙ ЩИТ") 

    self.Shield:SetModelScale(0)
    self.Shield:SetModelScale(1, 0.3)
    self:SetNWEntity("Shield", self.Shield)
    return true
end

function SWEP:Holster()
    if CLIENT then return end
    self.Shield:Remove()
    self.Shield = nil
    self.Snd:Stop()
    return true
end

local ang_offset = Angle(0,135,0)
local pos_offset = Vector(0,0,0)
local time_to_size = 1
function SWEP:Think()
    //if CLIENT then return end
    self.NextSpark = self.NextSpark or 0
    local owner = self:GetOwner()
    local pos = self:ShieldPos()
    local ang = owner:GetRenderAngles() + ang_offset//owner:LocalToWorldAngles(ang_offset)

    if SERVER then
        local shield = self.Shield
        if !shield then return end


        //local center = shield:OBBCenter()
        shield:SetPos(pos)


        shield:SetAngles(ang)

    end

    //print(self.NextSpark, CurTime())
    if self.NextSpark > CurTime() then return end

        local shield = self:GetNWEntity("Shield")
        if !shield then return end
    
    ///local pos = shield:WorldSpaceCenter()
    local addpos = Vector(0,5,10) * VectorRand(-0.5, 0.5)

    debugoverlay.Cross(shield:LocalToWorld(addpos), 10, 1)

    local pos =  shield:LocalToWorld(addpos) + Vector(0,0,50)

    local spark = EffectData()
    spark:SetOrigin(pos)
    spark:SetMagnitude(5)
    spark:SetScale(0.1)
    spark:SetNormal(ang:Forward())
    spark:SetRadius(5)

    util.Effect("Sparks", spark)

    self.NextSpark = CurTime() + math.random(1,3)

    

    self:EmitSound("weapons/stunstick/spark"..math.random(1,3)..".wav")
end

function SWEP:OnRemove()
    if SERVER then
        if IsValid(self.Shield) then self.Shield:Remove() end
        self.Snd:Stop()
        
    end
end

