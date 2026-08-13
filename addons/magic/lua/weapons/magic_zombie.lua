SWEP.PrintName			= "magic zombie" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "(your name)" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
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

local snd = Sound("physics/concrete/concrete_block_scrape_rough_loop1.wav")

local offset_vec = 0

local function new_zombie()
    local npc = ents.Create("npc_fastzombie")
    return npc
end

function SWEP:Initialize()
    self.Snd = CreateSound(self, snd)
    self:SetHoldType("magic")
    self.NextReload = 0
end

local function thumper_dust(pos)
    local eff = EffectData()

    eff:SetOrigin(pos)
    eff:SetScale(100)
    util.Effect("ThumperDust", eff)
end

function SWEP:SpawnZombie(pos)
    local zombs = {}
    self.Snd:Play()

    thumper_dust(pos)
    for i= 1, math.random(3, 6) do
        local zomb = new_zombie()
        local addpos = Vector(math.random(-150, 150), math.random(-150, 150),-70)
        local finpos = pos + addpos //- Vector(0,0, -100) 
        zomb:SetPos(finpos)
        zomb:Spawn()
        //table.insert(zombs, zomb)

        zombs[zomb] = finpos
    end
    
    local ind = "ZombieGrob:"..math.random(1000,10000)

    timer.Create(ind, 0.1, 20, function()
        debugoverlay.Cross(pos, 5,1)
        
        for zomb, pos in pairs(zombs) do
            pos = pos + Vector(0,0,5)
        
            zombs[zomb] = pos
            zomb:SetPos(pos)
        end

        if timer.RepsLeft( ind ) == 0 then
            self.Snd:Stop()
        end
    end)
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    
    local trace = owner:GetEyeTrace()

    if !trace.HitPos then return end

    self:SpawnZombie(trace.HitPos)
    self:SetNextPrimaryFire(CurTime() + 0.2)
end
 

local offset = Vector(50, 0, -100)
function SWEP:Necromancy(grob)

    local pos = grob:LocalToWorld(offset)

    debugoverlay.Cross(pos, 5,1)

    local zomb = new_zombie()
    zomb:SetPos(pos)
    zomb:Spawn()
    
    self.Snd:Play()

    local ind = "ZombieGrob:"..zomb:EntIndex()
    timer.Create(ind, 0.1, 20, function()
        debugoverlay.Cross(pos, 5,1)

        pos = pos + Vector(0,0,5)
        zomb:SetPos(pos)

        if timer.RepsLeft( ind ) == 0 then
            self.Snd:Stop()
        end
    end)
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    
    local trace = owner:GetEyeTrace()

    if !trace.HitPos then return end

    if trace.Entity:GetModel() == "models/props_c17/gravestone002a.mdl" then
        self:Necromancy(trace.Entity)
    end

   self:SetNextSecondaryFire(CurTime() + 1)
end


function SWEP:Reload()
    if self.NextReload > CurTime() then return end
    --[[local owner = self:GetOwner()

    local zomb = new_zombie()
    zomb:SetPos(owner:GetPos())
    zomb:Spawn()
	owner:Spectate( OBS_MODE_CHASE )
    owner:SpectateEntity( zomb )


	timer.Simple( 5, function()
		if IsValid( owner ) then
			owner:UnSpectate()
			owner:Spawn()
		end
	end )]]

    if SERVER then
        for k,v in ipairs(ents.GetAll()) do 
            if v:GetClass() == "npc_fastzombie" then
                v:Remove()
            end
        end
    end

    self.NextReload = CurTime() + 1
end