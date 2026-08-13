SWEP.PrintName			= "magic popcorn" -- This will be shown in the spawn menu, and in the weapon selection menu
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

function SWEP:Initialize()
    self.Snd = CreateSound(self, snd)
    self:SetHoldType("magic")
    self.NextReload = 0
end

local function newPop()
    local pop = ents.Create("ent_jack_gmod_ezpopcorn")
    return pop
end

function SWEP:TransformToPopcorn(ply)
    local pop = newPop()
    pop:SetPos(ply:LocalToWorld(Vector(0,0,32)))
    if ply:IsNPC() then
        ply:Remove()
    else
        ply:Spectate( OBS_MODE_CHASE )
        ply:SpectateEntity( pop )
        ply:StripWeapons()
        ply.SpectateMode = true
       // ply:SetParent(pop)
        /*timer.Simple( 5, function()
            if IsValid( ply ) then
                ply:UnSpectate()
                ply:Spawn()
            end
        end )*/

        pop.PopPly = ply
        pop:CallOnRemove("KillSpec", function(pop)

            
            ply:UnSpectate()
            ply:Spawn()
            ply:SetMaterial(ply:GetMaterials()[1])
            --PrintTable(ply:GetMaterials())
            ply:SetPos(pop:GetPos())
            ply:Kill()
        end)
    end
    pop:Spawn()
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    
    local trace = owner:GetEyeTrace()

    //if !trace.HitPos then return end
    local trg = trace.Entity
    if trg:IsPlayer() or trg:IsNPC() then
        self:TransformToPopcorn(trg)
    end
    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    
    local trace = owner:GetEyeTrace()

    //if !trace.HitPos then return end
    if !IsValid(trace.Entity) then return end
    if !IsValid(trace.Entity.PopPly) then return end

    local pop = trace.Entity
    local ply = pop.PopPly

    ply:UnSpectate()
    ply.SpectateMode = false
    ply:Spawn()
    ply:SetPos(pop:GetPos()+ Vector(0,0, 32))

    ply:Give("wep_jack_gmod_hands")
    //ply:SetParent(0)
    pop.PopPly = nil
    pop:RemoveCallOnRemove("KillSpec")
    pop:Remove()
   self:SetNextSecondaryFire(CurTime() + 1)
end
