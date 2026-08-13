
ENT.Base = "lvs_base_wheeldrive_trailer"

ENT.PrintName = "M-30 (1938)"
ENT.Author = "SIMER"
ENT.Information = "Пиздык по ебалу"
ENT.Category = "[LVS]"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Artillery"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/lvs_m30_mow.mdl"

ENT.AITEAM = 2

ENT.MaxHealth = 1000

ENT.WheelPhysicsMass = 350
ENT.WheelPhysicsInertia = Vector(10,8,10)

ENT.CannonArmorPenetration = 15000

ENT.DSArmorIgnoreForce = 1000

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "Prongs" )
	self:AddDT( "Bool", "UseHighExplosive" )
end

function ENT:CalcMainActivity( ply )
	if ply ~= self:GetDriver() then return self:CalcMainActivityPassenger( ply ) end

	if ply.m_bWasNoclipping then 
		ply.m_bWasNoclipping = nil 
		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM ) 
		
		if CLIENT then 
			ply:SetIK( true )
		end 
	end 

	ply.CalcIdeal = ACT_STAND
	ply.CalcSeqOverride = ply:LookupSequence( "cidle_knife" )

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 10
	weapon.Delay = 10
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0.1
	weapon.StartAttack = function( ent )
		if self:GetAI() then return end
		self:MakeProjectile()
	end
	weapon.FinishAttack = function( ent )
		if self:GetAI() then return end
		self:FireProjectile()
	end
	weapon.Attack = function( ent )
		if self:GetAI() then
			self:MakeProjectile()
			self:FireProjectile()
		end
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()
		ent:LVSPaintHitMarker( Pos2D )
	end
	self:AddWeapon( weapon )
end