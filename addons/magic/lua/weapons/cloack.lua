SWEP.PrintName			= "clok" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "vasi" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Instructions		= "lkm for pryatki"

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

SWEP.ViewModel			= "models/weapons/c_arms.mdl"
SWEP.WorldModel			= ""

SWEP.SoundCloack = Sound( "ambient/levels/canals/windchime4.wav")
SWEP.SoundUncloack = Sound( "ambient/levels/canals/windchime5.wav")
SWEP.Cloacked = false
--SWEP.Material = "Models/effects/vol_light001"

function SWEP:Deploy()
	self:SetHoldType( "fist" )
    self:GetOwner():SetRenderMode( RENDERMODE_TRANSCOLOR )
    local vm = self:GetOwner():GetViewModel()

end
function SWEP:Holster()
    if self.Cloacked==true then
        self:uncloack()
        self.Cloacked=false
    end
    return (true)
end

function SWEP:PrimaryAttack()
	if(CLIENT) then return end

    local owner=self:GetOwner()
    
	if self.Cloacked==false then
        self:cloack()
        self.Cloacked=true
    else 
        self:uncloack(owner)
        self.Cloacked=false
    end
	self:SetNextPrimaryFire( CurTime() + 2 )
end
 


function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + 0.1 )
end


function SWEP:cloack()
    local owner = self:GetOwner()
    owner:RemoveAllDecals()
    owner:EmitSound(self.SoundCloack)

    local clocktime  = 1
    owner.TimeToCloack = CurTime() + clocktime
    owner.StartCloack = CurTime()
    local ind = "Cloack:"..tostring(owner)

    local ply_color = owner:GetColor()

    timer.Create(ind, 0, 0, function()
        if !IsValid(owner) then timer.Remove(ind) return end
        if owner.TimeToCloack < CurTime() then
            timer.Remove(ind)
            return
        end

        local fract = 1 - (CurTime()-owner.StartCloack) / clocktime
        
        owner:SetColor(Color(ply_color.r, ply_color.g ,ply_color.b, Lerp(fract, 10, 255)))
    end)
end

function SWEP:uncloack(o)

    local owner = self:GetOwner()
    owner:EmitSound(self.SoundUncloack)

    local clocktime  = 1
    owner.TimeToCloack = CurTime() + clocktime
    owner.StartCloack = CurTime()

    local ply_color = owner:GetColor()

    local ind = "Uncloack:"..tostring(owner)
    timer.Create(ind, 0, 0, function()
        if !IsValid(owner) then timer.Remove(ind) return end

        if owner.TimeToCloack < CurTime() then
            timer.Remove(ind)
            owner:SetColor(Color(ply_color.r, ply_color.g ,ply_color.b,255))
            return
        end

        local fract = (CurTime()-owner.StartCloack) / clocktime
        owner:SetColor(Color(ply_color.r, ply_color.g ,ply_color.b, Lerp(fract, 10, 255)))
    end)
    
end


