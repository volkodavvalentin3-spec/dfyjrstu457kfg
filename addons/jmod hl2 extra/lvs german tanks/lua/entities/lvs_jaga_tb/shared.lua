ENT.Base = "lvs_tank_wheeldrive"

ENT.PrintName = "Panzerjäger Tiger Ausf. B"
ENT.Author = "SIMER"
ENT.Information = ""
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Heavy"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/lvs_jaga_tb.mdl"


ENT.AITEAM = 1

ENT.MaxHealth = 1800

--damage system
ENT.DSArmorIgnoreForce = 7000
ENT.CannonArmorPenetration = 35000
ENT.FrontArmor = 10000
ENT.SideArmor = 1000
ENT.TurretArmor = 19000
ENT.RearArmor = 1000

ENT.SteerSpeed = 1
ENT.SteerReturnSpeed = 2

ENT.PhysicsWeightScale = 2
ENT.PhysicsDampingSpeed = 1000
ENT.PhysicsInertia = Vector(6000,6000,1500)

ENT.MaxVelocity = 400
ENT.MaxVelocityReverse = 90

ENT.EngineCurve = 0.1
ENT.EngineTorque = 110

ENT.TransMinGearHoldTime = 0.1
ENT.TransShiftSpeed = 0

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.MouseSteerAngle = 45

ENT.WheelBrakeAutoLockup = true
ENT.WheelBrakeLockupRPM = 15

ENT.lvsShowInSpawner = true

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/tiger/eng_idle_loop.wav",
		Volume = 1,
		Pitch = 70,
		PitchMul = 30,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/vehicles/tiger/eng_loop.wav",
		Volume = 1,
		Pitch = 30,
		PitchMul = 100,
		SoundLevel = 85,
		SoundType = LVS.SOUNDTYPE_NONE,
		UseDoppler = true,
	},
}

ENT.ExhaustPositions = {
	{
		pos = Vector(-180.7,-15,74),
		ang = Angle(-180,-0,0),
	},
	{
		pos = Vector(-180.7,16,74),
		ang = Angle(-180,-0,0),
	},
	
}

ENT.Lights = {
	{
		Trigger = "main",
		Sprites = {
			{ pos = Vector(129,0,72), colorA = 150 },
			
			
		},
		ProjectedTextures = {
			{ pos = Vector(129,0,72), colorA = 150 },
			
			
		},
	},

}
function ENT:OnSetupDataTables()
	self:AddDT( "Entity", "WeaponSeat" )
	self:AddDT( "Entity", "TopGunnerSeat" )
	self:AddDT( "Entity", "FrontGunnerSeat" )
	self:AddDT( "Int", "UseHighExplosive" )
end

function ENT:InitWeapons()

	local weapon = {}
	weapon.Icon = true
	weapon.Ammo = 40
	weapon.Delay = 8.5
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.14
	weapon.OnThink = function( ent )
		if ent:GetSelectedWeapon() ~= 1 then return end

		local ply = ent:GetDriver()

		if not IsValid( ply ) then return end

		local SwitchType = ply:lvsKeyDown( "CAR_SWAP_AMMO" )
		if ent:GetUseHighExplosive() == 2 then ent:SetUseHighExplosive(0) end
		if ent._oldSwitchType ~= SwitchType then
			ent._oldSwitchType = SwitchType

			if SwitchType then
				ent:SetUseHighExplosive(math.Clamp((ent:GetUseHighExplosive() + 1),1,3 ))
				ent:EmitSound("lvs/vehicles/tiger/cannon_reload.wav")
				ent:SetHeat( 1 )
				ent:SetOverheated( true )
			end
		end
	end
	weapon.Attack = function( ent )
		local ID = ent:LookupAttachment( "cannon_muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread = Vector(0,0,0)

		if ent:GetUseHighExplosive() == 0 then
			bullet.Force	= ent.CannonArmorPenetration
			bullet.HullSize 	= 0
			bullet.Damage	= 1750
			bullet.Velocity = 16000
		elseif ent:GetUseHighExplosive() == 1 then
			bullet.Force	= 750
			bullet.HullSize 	= 15
			bullet.Damage	= 1800
			bullet.SplashDamage = 1000
			bullet.SplashDamageRadius = 250
			bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
			bullet.SplashDamageType = DMG_BLAST
			bullet.Velocity = 13000
		end

		bullet.TracerName = "lvs_tracer_cannon"
		bullet.Attacker 	= ent:GetDriver()
		if ent:GetUseHighExplosive() != 2 then 
			ent:LVSFireBullet( bullet )
		end

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		local PhysObj = ent:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceOffset( -bullet.Dir * 250000, bullet.Src )
		end
		
		ent:PlayAnimation( "fire" )

		ent:TakeAmmo( 1 )

		if not IsValid( ent.SNDTurret ) then return end

		ent.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + ent:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

		ent:EmitSound("lvs/vehicles/tiger/cannon_reload.wav", 75, 85, 1, CHAN_WEAPON )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local ID = ent:LookupAttachment(  "cannon_muzzle" )

		local Muzzle = ent:GetAttachment( ID )

		if Muzzle then
			local traceTurret = util.TraceLine( {
				start = Muzzle.Pos,
				endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 50000,
				filter = ent:GetCrosshairFilterEnts()
			} )

			local MuzzlePos2D = traceTurret.HitPos:ToScreen() 

			if ent:GetUseHighExplosive() == 0 then
				ent:PaintCrosshairOuter( MuzzlePos2D, Col )
			elseif ent:GetUseHighExplosive() == 1 then
				ent:PaintCrosshairOuter( MuzzlePos2D, Col )
				ent:PaintCrosshairOuter( MuzzlePos2D, Col )
		
			end

			ent:LVSPaintHitMarker( MuzzlePos2D )
		end
	end
	self:AddWeapon( weapon )

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/smoke_launcher.png")
	weapon.Ammo = 3
	weapon.Delay = 1
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.05
	weapon.Attack = function( ent )
		ent:TakeAmmo( 1 )

		local ID1 = ent:LookupAttachment( "smoke_r" )
		local Muzzle1 = ent:GetAttachment( ID1 )
		
		local ID2 = ent:LookupAttachment( "smoke_l" )
		local Muzzle2 = ent:GetAttachment( ID2 )
		
		if not Muzzle1 and Muzzle2 then return end

		local Up = self:GetUp()

		ent:EmitSound("lvs/smokegrenade.wav") 

		local Ang1 = Muzzle1.Ang
		Ang1:RotateAroundAxis( Up, 0 )
		local grenade = ents.Create( "lvs_item_smoke" )
		grenade:SetPos( Muzzle1.Pos )
		grenade:SetAngles( Ang1 )
		grenade:Spawn()
		grenade:Activate()
		grenade:GetPhysicsObject():SetVelocity( Ang1:Forward() * 900 )

		local Ang2 = Muzzle2.Ang
		Ang2:RotateAroundAxis( Up, 0 )
		local grenade = ents.Create( "lvs_item_smoke" )
		grenade:SetPos( Muzzle2.Pos )
		grenade:SetAngles( Ang2 )
		grenade:Spawn()
		grenade:Activate()
		grenade:GetPhysicsObject():SetVelocity( Ang2:Forward() * 900 )		
	end
	self:AddWeapon( weapon )

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/tank_noturret.png")
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.OnSelect = function( ent )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( false )
		end
	end
	weapon.OnDeselect = function( ent )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( true )
		end
	end
	self:AddWeapon( weapon )

	self:AddGunnerHull()
	self:AddGunnerTurret()
end

function ENT:AddGunnerHull()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 1000
	weapon.Delay = 0.08
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.3
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local ID = base:LookupAttachment( "mgh_muzzle" )

		local Muzzle = base:GetAttachment( ID )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= Muzzle.Ang:Forward()
		bullet.Spread 	= Vector(0.015,0.015,0.015)
		bullet.TracerName = "lvs_tracer_yellow_small"
		bullet.Force	= 20
		bullet.HullSize 	= 0
		bullet.Damage	= 20
		bullet.Velocity = 15000
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( Muzzle.Pos )
		effectdata:SetNormal( Muzzle.Ang:Forward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo( 1 )

		if not IsValid( base.SNDTurretMGH ) then return end

		base.SNDTurretMGH:Play()
	end
	weapon.StartAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMGH ) then return end

		base.SNDTurretMGH:Play()
	end
	weapon.FinishAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMGH ) or not base.SNDTurretMGH:GetActive() then return end
		self:EmitSound("weapons/mg34/mg34_lastshot_01.wav")
		base.SNDTurretMGH:Stop()
	end
	weapon.OnThink = function( ent, active )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end
		
		local pod = base:GetFrontGunnerSeat()

		if not base:GetAI() and (not IsValid( pod ) or not IsValid( pod:GetDriver() )) then return end

		local Ang = base:WorldToLocalAngles( ent:GetAimVector():Angle() ) - Angle(0,0,0)
		Ang:Normalize()

		base:SetPoseParameter("mgh_aim_yaw", Ang.y )
		base:SetPoseParameter("mgh_aim_pitch",  -Ang.p )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = self:GetVehicle()
		if not IsValid( base ) then return end

		local Pos2D = base:TraceTurretMG().HitPos:ToScreen()
		base:PaintCrosshairCenter( Pos2D, Col)
		base:LVSPaintHitMarker( Pos2D )	
	end
	weapon.OnSelect = function( ent )  end
	weapon.OnDeselect = function( ent )  end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon, 2 )
end

function ENT:AddGunnerTurret()
end

function ENT:TraceTurretMG()
	local ID = self:LookupAttachment( "mgh_muzzle" )
	local MuzzleMG = self:GetAttachment( ID )

	if not MuzzleMG then return end

	local dir = MuzzleMG.Ang:Forward()
	local pos = MuzzleMG.Pos

	local trace = util.TraceLine( {
		start = pos,
		endpos = (pos + dir * 50000),
	} )

	return trace
end

function ENT:TraceTurretMGTurret()
	local ID = self:LookupAttachment( "mgc_muzzle" )
	local MuzzleMG = self:GetAttachment( ID )

	if not MuzzleMG then return end

	local dir = MuzzleMG.Ang:Forward()
	local pos = MuzzleMG.Pos

	local trace = util.TraceLine( {
		start = pos,
		endpos = (pos + dir * 50000),
	} )

	return trace
end

