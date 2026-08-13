
ENT.Base = "lvs_base_wheeldrive_trailer"

ENT.PrintName = "Fortification - PTRD-1941 "
ENT.Author = "SIMER"
ENT.Information = ""
ENT.Category = "[LVS]"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Artillery"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/maxim_ucrep_ptrd.mdl"

ENT.AITEAM = 2

ENT.MaxHealth = 500
ENT.FrontArmor = 1000
ENT.DSArmorIgnoreForce = 2000

ENT.WheelPhysicsMass = 350
ENT.WheelPhysicsInertia = Vector(10,8,10)

ENT.CannonArmorPenetration = 6200

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
	ply.CalcSeqOverride = ply:LookupSequence( "idle_ar2" )

	return ply.CalcIdeal, ply.CalcSeqOverride
end



function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	local weapon = {}
	weapon.Icon = true
	weapon.Ammo = 60
	weapon.Delay = 1
	weapon.HeatRateUp = 3
	weapon.HeatRateDown = 0.5
	weapon.OnThink = function( ent )
		local ply = ent:GetDriver()

		if not IsValid( ply ) then return end

		

		if ent._oldSwitchType ~= SwitchType then
			ent._oldSwitchType = SwitchType

			if SwitchType then			
				if (ent:GetOverheated() == false) and (ent:GetHeat() < 1) then
					ent:SetUseHighExplosive( not ent:GetUseHighExplosive() )
					ent:SpawnShell()
					ent:SetHeat( 1 )
					ent:SetOverheated( true )
				end
			end
		end
	end
    weapon.Attack = function( ent )
		local ID = ent:LookupAttachment( "muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread = Vector(0,0,0)

		if ent:GetUseHighExplosive() then
			bullet.Force	= 200
			bullet.HullSize 	= 1
			bullet.Damage	= 250
			bullet.SplashDamage = 450
			bullet.SplashDamageRadius = 150
			bullet.SplashDamageEffect = "lvs_defence_explosion"
			bullet.SplashDamageType = DMG_BLAST
			bullet.Velocity = 13000
		else
			bullet.Force	= ent.CannonArmorPenetration
			bullet.HullSize 	= 0
			bullet.Damage	= 250
			bullet.Velocity = 13000
		end

		bullet.TracerName = "lvs_tracer_autocannon"
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

        ent:TakeAmmo( 1 )

		if not IsValid( ent.SNDTurret ) then return end
		ent:ResetSequence("fire")
		ent.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
		
		ent:EmitSound("lvs/vehicles/222/cannon_overheat.wav", 75, 100, 1, CHAN_WEAPON )

		local PhysObj = ent:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 15000, bullet.Src )
		end
	end
	weapon.StartAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		ent.SNDTurretMG:Play()
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		ent.SNDTurretMG:Stop()
	end
	weapon.OnOverheat = function( ent ) ent:EmitSound("weapons/pull.wav") end
		weapon.HudPaint = function( ent, X, Y, ply )
		local ID = ent:LookupAttachment(  "muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
				filter = ent:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen() 

			if ent:GetUseHighExplosive() then
				ent:PaintCrosshairSquare( MuzzlePos2D, COLOR_WHITE )
			else
				ent:PaintCrosshairOuter( MuzzlePos2D, COLOR_WHITE )
			end

			ent:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	
	self:AddWeapon( weapon )

	
end