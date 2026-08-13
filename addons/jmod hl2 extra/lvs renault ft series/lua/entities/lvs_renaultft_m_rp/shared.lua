ENT.Base = "lvs_renaultft_m"

ENT.PrintName = "FT (37mm Canon)"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's WW1 Vehicles"
ENT.Category = "[LVS] - Tanks"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "RP"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.TurretSeatIndex = 2

function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	//CANNON
	local weapon = {}
	weapon.Icon = Material("weapons/cannon.png")
	weapon.Ammo = 10
	weapon.Delay = 5.5
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		local veh = ent:GetVehicle()
		local ID = veh:LookupAttachment( "gun_muzzle" )
		local Muzzle = veh:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= -Muzzle.Ang:Forward()
		bullet.Spread 	= Vector(0.0025,0.0025,0.0025)
		bullet.TracerName = "lvs_tracer_autocannon"
		bullet.Force	= 1600
		bullet.HullSize = 10
		bullet.Damage	= 200
		bullet.SplashDamage = 100
		bullet.SplashDamageRadius = 365
		bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
		bullet.SplashDamageType = DMG_SONIC
		bullet.Velocity = 8000
		bullet.Attacker = veh:GetGunnerSeat():GetDriver()
		veh:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( veh )
		util.Effect( "lvs_muzzle", effectdata )

		local PhysObj = veh:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 40000, bullet.Src )
		end

		ent:TakeAmmo( 1 )
		veh:PlayAnimation("gun_recoil")
		veh.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + ent:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

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
