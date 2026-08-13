ENT.Base = "lvs_renaultft"

ENT.PrintName = "FT (8mm Mitrailleuse)"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's WW1 Vehicles"
ENT.Category = "[LVS] - Tanks"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Light"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/tank_ft_female.mdl"

// used in cl_optics.lua
ENT.WeaponName = "HOTCHKISS 8mm"

ENT.TurretSeatIndex = 1

function ENT:InitWeapons()
	local COLOR_WHITE = Color(255,255,255,255)

	//MACHINEGUN
	local weapon = {}
	weapon.Icon = Material("weapons/mg.png")
	weapon.Ammo = 1500
	weapon.Delay = 0.1
	weapon.HeatRateUp = 0.2
	weapon.HeatRateDown = 0.2
	weapon.Attack = function( ent )

		local veh = ent:GetVehicle()
		local ID = veh:LookupAttachment( "gun_muzzle" )
		local Muzzle = veh:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= -Muzzle.Ang:Forward()
		bullet.Spread 	= Vector(0.01,0.01,0.01)
		bullet.TracerName = "lvs_tracer_yellow"
		bullet.Force	= 100
		bullet.HullSize = 0
		bullet.Damage	= 20
		bullet.Velocity = 30000
		bullet.Attacker = veh:GetDriver()
		veh:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( veh )
		util.Effect( "lvs_muzzle", effectdata )

		local PhysObj = veh:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 2000, bullet.Src )
		end

		veh:PlayAnimation("gun_recoil")
		ent:TakeAmmo( 1 )
	end
	weapon.StartAttack = function( ent )
		local veh = ent:GetVehicle()
		if not IsValid( veh.SNDTurretMG ) then return end
		veh.SNDTurretMG:Play()
	end
	weapon.FinishAttack = function( ent )
		local veh = ent:GetVehicle()
		if not IsValid( veh.SNDTurretMG ) then return end
		veh.SNDTurretMG:Stop()
	end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	weapon.HudPaint = function( ent, X, Y, ply )
		local veh = ent:GetVehicle()
		local ID = veh:LookupAttachment( "gun_muzzle" )

		local Muzzle = veh:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos - Muzzle.Ang:Forward() * 50000,
				filter = veh:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen()

			veh:PaintCrosshairCenter( MuzzlePos2D, COLOR_WHITE )
			veh:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	weapon.OnOverheat = function( ent )
		local veh = ent:GetVehicle()
		veh:EmitSound("lvs/overheat.wav")
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