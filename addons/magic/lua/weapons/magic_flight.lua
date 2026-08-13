SWEP.PrintName			= "magic fly" -- This will be shown in the spawn menu, and in the weapon selection menu
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

if SERVER then
    util.AddNetworkString("magic_fly")
end

function SWEP:Deploy()
    self:SetHoldType("fist")

end

local snd = Sound("vehicles/airboat/fan_motor_fullthrottle_loop1.wav")
local snd1 = Sound("ambient/levels/labs/machine_stop1.wav")
function SWEP:Initialize()
    if CLIENT then 
        //self.Part =  CreateParticleSystem( self:GetOwner(), "generic_smoke_infinite", PATTACH_POINT_FOLLOW )
        //self.Part:StopEmission( false, true, false )
        self.Snd = CreateSound(self, snd)
    end
        self.Snd1 = CreateSound(self, snd1)

end

function SWEP:OnRemove()
    if CLIENT then
        if IsValid(self.Part) then
            self.Part:Remove()
        end
    end

    self.Snd:Stop()
end

function SWEP:Fly()
    local owner = self:GetOwner()
    local vel = owner:GetForward() * 25 + owner:GetUp() * 40

    owner:SetVelocity( vel )
end

function SWEP:FlyUp()
    local owner = self:GetOwner()
    local vel = owner:EyeAngles():Forward() * 400 + Vector(0,0,1) * 700

    owner:SetVelocity( vel )
end


function SWEP:PrimaryAttack()
    self:Fly()
    self:SetNextPrimaryFire(CurTime() + 0.05)
end


function SWEP:SecondaryAttack()
    self:FlyUp()
    self:EmitSound(snd1)
    //self:GetOwner():Say("ПРЫЖОК")

    self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:FlySmoke(stop)
    if SERVER then
        net.Start("magic_fly")
        net.WriteEntity(self)
        net.WriteBool(stop)
        net.Broadcast()
    else

        if stop then
            self.Part:StopEmission(true)
            self.Snd:Stop()
        else

            if IsValid(self.Part) then
                self.Part:StartEmission( true )
            else
                self.Part =  CreateParticleSystem( self:GetOwner(), "generic_smoke_infinite", PATTACH_POINT_FOLLOW )
            end
            self.Snd:Play()
        end
    end
end

function SWEP:Think()
    local owner = self:GetOwner()
    if SERVER then
        if owner:KeyPressed(IN_ATTACK) then
            self:FlySmoke(false)
        elseif owner:KeyReleased(IN_ATTACK) then
            self:FlySmoke(true)
        end
    end
    if owner:KeyPressed(IN_ATTACK2) then 
        local eff = EffectData()
        eff:SetOrigin(owner:GetPos())
        eff:SetScale(1)
        util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
    end
end

net.Receive("magic_fly", function()
    local wep = net.ReadEntity()

    wep:FlySmoke(net.ReadBool())
end)

hook.Add("EntityTakeDamage", "MagicFly", function(ent, dmg)
    if !ent:IsPlayer() then return end
    if !dmg:GetDamageType(DMG_FALL) then return end
    if !IsValid(ent:GetActiveWeapon()) then return end
    if ent:GetActiveWeapon():GetClass() == "magic_flight" then return true end
end)