if SERVER then AddCSLuaFile() end

if CLIENT then
	SWEP.PrintName			= "Trench Whistle"
	SWEP.Author				= "Micro"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 1
end

SWEP.Category				= "Other"
SWEP.ViewModelFlip			= false
SWEP.ViewModelFOV			= 65

SWEP.Spawnable				= true
SWEP.AdminOnly				= false
SWEP.UseHands				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/ufn/ww1/weapons/trenchwhistle/c_trenchwhistle.mdl"
SWEP.WorldModel				= "models/ufn/ww1/weapons/trenchwhistle/w_trenchwhistle.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetHoldType("slam")
end

local sound = "/ufn/ww1/weapons/trenchwhistle.wav"

function SWEP:Deploy()
	--[[self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	timer.Simple(1, function()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	end)]]
end

local AttackText = {
	"УМРИ В БОЮ",
	"В АТАКУ",
	"ВПЕРЕД",
	"МАРШ МАРШ МАРШ",
	"МАРШ",
	"ВПЕРЕД ВПЕРЕД ВПЕРЕД",
}

function SWEP:PrimaryAttack()
	if ( self.lastUsed or CurTime() ) <= CurTime() then
		self.lastUsed = CurTime() + 3.16
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		timer.Simple(.25, function()
			if IsValid(self and self:GetOwner()) then
				self:EmitSound(sound)

				if SERVER then
					EmitFarSound(self:GetPos(), math.random(925,931), 3000, 10000)

					timer.Simple(0.5, function()
						if IsValid(self:GetOwner()) and self:GetOwner():GetSquadID() ~= -1 then
							local squad = SquadMenu:GetSquad( self:GetOwner():GetSquadID() )

							if squad:IsLeader(self:GetOwner()) and not table.IsEmpty(squad.SquadsInWar) then

								for k,v in pairs(squad.membersById) do
									local ply = player.GetBySteamID(k)

									if self:GetOwner():GetPos():Distance2DSqr( ply:GetPos() ) <= 2048^2 then
										ply:SendMessageOnTop(table.Random(AttackText), Color(130,0, 0), true)
									end
								end

							end
 						end
					end)
				end
			end
		end)
		timer.Simple(3.16, function()
			if IsValid(self and self:GetOwner()) then
				self:SendWeaponAnim( ACT_VM_IDLE )
			end
		end)
		--[[timer.Simple(3.16, function()
			if IsValid(self) then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end)]]
	end
end

function SWEP:SecondaryAttack()
	--[[if self:GetOwner():IsPlayer() and ( self.lastUsed or CurTime() ) <= CurTime() then
		self.lastUsed = CurTime() + 3.16
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		timer.Simple(.25, function()
			if IsValid(self) then
				self:EmitSound(sound)
			end
		end)
		timer.Simple(3.16, function()
			if IsValid(self) then
				self:SendWeaponAnim(ACT_VM_IDLE)
			end
		end)
	end]]
end

function SWEP:Reload()
	return
end
