ENT.Base = "lvs_renaultft"

ENT.PrintName = "FT (37mm Canon)"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's WW1 Vehicles"
ENT.Category = "[LVS] - Tanks"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Light"

ENT.Spawnable			= true

ENT.MDL = "models/tank_ft_male.mdl"

ENT.TrackLeftSubMaterialID = 2
ENT.TrackLeftSubMaterialMul = Vector(0,-0.001,0)
ENT.TrackRightSubMaterialID = 3
ENT.TrackRightSubMaterialMul = Vector(0,-0.001,0)

// used in cl_optics.lua
ENT.WeaponName = "PUTEAUX 37mm"

ENT.TurretSeatIndex = 1

local ShootSound = {
	"LANRP/realism/weapon/shot/gun/50to76_cal/50mm_kwk38/57ALL.wav",
	"LANRP/realism/weapon/shot/gun/50to76_cal/50mm_kwk38/57ALL2.wav",
	"LANRP/realism/weapon/shot/gun/50to76_cal/50mm_kwk38/57ALL3.wav",
	"LANRP/realism/weapon/shot/gun/50to76_cal/50mm_kwk38/57ALL4.wav"
}

function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	//CANNON
	local weapon = {}
	weapon.Icon = Material("weapons/cannon.png")
	weapon.Ammo = 15
	weapon.Delay = 4.5
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.25
	weapon.OnThink = function( ent )
		if ent:GetSelectedWeapon() ~= 2 then return end

		local ply = ent:GetDriver()

		if not IsValid( ply ) then return end

		local SwitchType = ply:lvsKeyDown( "CAR_SWAP_AMMO" )

		if ent._oldSwitchType ~= SwitchType then
			ent._oldSwitchType = SwitchType

			if SwitchType then
				ent:SetUseHighExplosive( not ent:GetUseHighExplosive() )
				ent:EmitSound("lvs/vehicles/sherman/cannon_unload.wav", 75, 100, 1, CHAN_WEAPON )
				--[[if self:GetUseHighExplosive() then
				ent:EmitSound("weapons/123.wav",  75, 100, 1, CHAN_WEAPON )
				else
				ent:EmitSound("weapons/122.wav",  75, 100, 1, CHAN_WEAPON )
				end]]
				ent:SetHeat( 1 )
				ent:SetOverheated( true )
			end
		end
	end
	weapon.Attack = function( ent )
		local veh = ent:GetVehicle()
		local ID = veh:LookupAttachment( "gun_muzzle" )
		local Muzzle = veh:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread = Vector(0,0,0)
		bullet.EnableBallistics = true

		if ent:GetUseHighExplosive() then
			bullet.Force	= 450
			bullet.HullSize 	= 8
			bullet.Damage	= 150
			bullet.SplashDamage = 450
			bullet.SplashDamageRadius = 150
			bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
			bullet.SplashDamageType = DMG_BLAST
			bullet.Velocity = ent.ProjectileVelocityHighExplosive
		else
			bullet.Force	= ent.CannonArmorPenetration
			bullet.HullSize 	= 0
			bullet.Damage	= 100
			bullet.Velocity = ent.ProjectileVelocityArmorPiercing
		end

		bullet.TracerName = "lvs_tracer_cannon"
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( veh )
		util.Effect( "lvs_muzzle", effectdata )

		local PhysObj = veh:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 250000, bullet.Src )
		end

		ent:TakeAmmo( 1 )
		veh:PlayAnimation("gun_recoil")
		---veh.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + ent:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

		veh:EmitSound(table.Random(ShootSound), 140, 100, 1)

		EmitFarSound(self:GetPos(), "LANRP/realism/weapon/dist/tank/tank_shot_0" .. math.random(1,4) .. ".ogg", 3000, 100000)

		veh:EmitSound("lvs/vehicles/sherman/cannon_reload.wav", 75, 100, 1, CHAN_WEAPON )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local veh = ent:GetVehicle()
		local ID = veh:LookupAttachment( "gun_muzzle" )

		local Muzzle = veh:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos + -Muzzle.Ang:Forward() * 50000,
				filter = veh:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen()

			veh:PaintCrosshairOuter( MuzzlePos2D, COLOR_WHITE )
			veh:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	self:AddWeapon( weapon, self.TurretSeatIndex )

	//NOTHING
	local weapon = {}
	weapon.Icon = Material("weapons/cross.png")
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.OnSelect = function( ent )
		local veh = ent:GetVehicle()
		if veh.SetTurretEnabled then
			veh:SetTurretEnabled( false )
		end
	end
	weapon.OnDeselect = function( ent )
		local veh = ent:GetVehicle()
		if veh.SetTurretEnabled then
			veh:SetTurretEnabled( true )
		end
	end
	self:AddWeapon( weapon, self.TurretSeatIndex )
end