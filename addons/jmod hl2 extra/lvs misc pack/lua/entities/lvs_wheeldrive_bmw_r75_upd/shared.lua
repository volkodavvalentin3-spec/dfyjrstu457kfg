
ENT.Base = "lvs_bike_wheeldrive"

ENT.PrintName = "BMW R75 (Sidecar)"
ENT.Author = "Digger"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Military"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/diggercars/bmw_r75/r75_upd.mdl"
ENT.MDL_DESTROYED = "models/diggercars/bmw_r75/r75_dead_upd.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 500

ENT.MaxVelocity = 1250
ENT.MaxVelocityReverse = 100

ENT.EngineCurve = 0.4
ENT.EngineTorque = 250

ENT.TransGears = 4
ENT.TransGearsReverse = 1

ENT.lvsShowInSpawner = true

ENT.HornSound = "lvs/horn1.wav"
ENT.HornPos = Vector(40,0,35)

ENT.KickStarter = true
ENT.KickStarterSound = "lvs/vehicles/bmw_r75/moped_crank.wav"
ENT.KickStarterMinAttempts = 2
ENT.KickStarterMaxAttempts = 4
ENT.KickStarterAttemptsInSeconds = 5

ENT.DriverBoneManipulateIdle = {
	["ValveBiped.Bip01_L_Thigh"] = Angle(-25,45,0),
	["ValveBiped.Bip01_L_Calf"] = Angle(0,-30,0),
	["ValveBiped.Bip01_L_Foot"] = Angle(0,0,0),
}

ENT.DriverBoneManipulateParked = {
	["ValveBiped.Bip01_R_Thigh"] = Angle(25,45,0),
	["ValveBiped.Bip01_R_Calf"] = Angle(0,-30,0),
	["ValveBiped.Bip01_R_Foot"] = Angle(0,0,0),
}

ENT.DriverBoneManipulateKickStart = {
	Start = {
		["ValveBiped.Bip01_L_Thigh"] = Angle(-20,60,25),
		["ValveBiped.Bip01_L_Calf"] = Angle(0,0,0),
		["ValveBiped.Bip01_L_Foot"] = Angle(0,-10,0),
	},
	End = {
		["ValveBiped.Bip01_L_Thigh"] = Angle(-20,-10,25),
		["ValveBiped.Bip01_L_Calf"] = Angle(0,70,0),
		["ValveBiped.Bip01_L_Foot"] = Angle(0,-10,0),
	},
}

ENT.PlayerBoneManipulate = {
	[1] = {
		["ValveBiped.Bip01_Pelvis"] = Angle(0,0,23),
		
		["ValveBiped.Bip01_R_Thigh"] = Angle(14,10,-5),
		["ValveBiped.Bip01_L_Thigh"] = Angle(-14,10,5),

		["ValveBiped.Bip01_R_Calf"] = Angle(0,40,0),
		["ValveBiped.Bip01_L_Calf"] = Angle(0,40,0),
		
		["ValveBiped.Bip01_R_Foot"] = Angle(0,-20,0),
		["ValveBiped.Bip01_L_Foot"] = Angle(0,-20,0),

		["ValveBiped.Bip01_R_UpperArm"] = Angle(10,25,0),
		["ValveBiped.Bip01_L_UpperArm"] = Angle(-5,25,0),

		["ValveBiped.Bip01_R_Forearm"] = Angle(0,-10,0),
		["ValveBiped.Bip01_L_Forearm"] = Angle(0,-10,0),
	},
	[3] = {
		["ValveBiped.Bip01_R_Thigh"] = Angle(14,10,0),
		["ValveBiped.Bip01_L_Thigh"] = Angle(-14,10,0),
	},
}


ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/bmw_r75/r12_idle.wav",
		Volume = 0.7,
		Pitch = 85,
		PitchMul = 50,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/vehicles/bmw_r75/vtwin_small.wav",
		Volume = 1,
		Pitch = 50,
		PitchMul = 50,
		SoundLevel = 75,
		UseDoppler = true,
	},
}

function ENT:OnSetupDataTables()
	self:AddDT( "Entity", "GunnerSeat" )
end

ENT.Lights = {
	{
		Trigger = "main",
		SubMaterialID = 0,
		Sprites = {
			{ pos = "lamp", colorB = 200, colorA = 150 },
			{ pos = "back1", colorG = 0, colorB = 0, colorA = 150, width = 10, height = 10 },
			{ pos = "back2", colorG = 0, colorB = 0, colorA = 150, width = 6, height = 6 },
		},
		ProjectedTextures = {
			{ pos = "lamp", ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		},
	},
	{
		Trigger = "main",
		SubMaterialID = 6,
	},
	{
		Trigger = "brake",
		SubMaterialBrightness = 1,
		Sprites = {
			{ pos = "back1", colorG = 0, colorB = 0, colorA = 150, width = 20, height = 20 },
			{ pos = "back2", colorG = 0, colorB = 0, colorA = 150, width = 10, height = 10 },
		},
	},
}

ENT.ExhaustPositions = {
	{
		pos = Vector(-38.43,11.44,23.42),
		ang = Angle(0,180,0),
	},
}

function ENT:InitWeapons()
	self:AddGunnerWeapons()
end

function ENT:GunnerInRange( Dir )
	local pod = self:GetGunnerSeat()

	if IsValid( pod ) and not pod:GetThirdPersonMode() then
		local ply = pod:GetDriver()

		if IsValid( ply ) and ply:lvsKeyDown( "ZOOM" ) then
			return true
		end
	end

	return self:AngleBetweenNormal( self:GetForward(), Dir ) < 30
end

function ENT:AddGunnerWeapons()
	local COLOR_RED = Color(255,0,0,255)
	local COLOR_WHITE = Color(255,255,255,255)

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 1000
	weapon.Delay = 0.12
	weapon.HeatRateUp = 0.2
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if not base:GunnerInRange( ent:GetAimVector() ) then

			if not IsValid( base.SNDTurretMGf ) then return true end

			base.SNDTurretMGf:Stop()
	
			return true
		end

		local Muzzle = base:GetAttachment( base:LookupAttachment( "muzzle" ) )

		if not Muzzle then return end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos

		local ply = ent:GetDriver()

		if IsValid( ply ) and ply:lvsKeyDown( "ZOOM" ) then
			local pod = ply:GetVehicle()

			if IsValid( pod ) and not pod:GetThirdPersonMode() then
				bullet.Dir = Muzzle.Ang:Forward()
			else
				bullet.Dir = (ent:GetEyeTrace().HitPos - bullet.Src):GetNormalized()
			end
		else
			bullet.Dir 	= (ent:GetEyeTrace().HitPos - bullet.Src):GetNormalized()
		end

		bullet.Spread 	= Vector(0.015,0.015,0.015)
		bullet.TracerName = "lvs_tracer_yellow_small"
		bullet.EnableBallistics = true
		bullet.Force	= 10
		bullet.HullSize 	= 0
		bullet.Damage	= 25
		bullet.Velocity = 30000
		bullet.Attacker 	= ply
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo( 1 )

		base:PlayAnimation( "shot" )

		if not IsValid( base.SNDTurretMGf ) then return end

		base.SNDTurretMGf:Play()
	end
	weapon.StartAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMGf ) then return end

		base.SNDTurretMGf:Play()
	end
	weapon.FinishAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMGf ) then return end

		base.SNDTurretMGf:Stop()
	end
	weapon.OnThink = function( ent, active )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		if not ent:GetAI() and not IsValid( ent:GetDriver() ) then
			base:SetPoseParameter("turret_pitch",  15 )
			base:SetPoseParameter("turret_yaw", 0 )

			return
		end

		local Angles = base:WorldToLocalAngles( ent:GetAimVector():Angle() )
		Angles:Normalize()

		base:SetPoseParameter("turret_yaw", -Angles.y )
		base:SetPoseParameter("turret_pitch",  -Angles.p )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()

		local Col = base:GunnerInRange( ent:GetAimVector() ) and COLOR_WHITE or COLOR_RED

		local pod = ply:GetVehicle()

		if not IsValid( pod ) then return end

		if not ply:lvsKeyDown( "ZOOM" ) or pod:GetThirdPersonMode() then
			base:PaintCrosshairCenter( Pos2D, Col )
		end

		base:LVSPaintHitMarker( Pos2D )
	end
	weapon.OnOverheat = function( ent )
		ent:EmitSound("lvs/overheat.wav")
	end
	self:AddWeapon( weapon, 2 )
end


function ENT:CalcMainActivityPassenger( ply )
	local GunnerSeat = self:GetGunnerSeat()

	if not IsValid( GunnerSeat ) then return end

	if GunnerSeat:GetDriver() ~= ply then return end

	if ply.m_bWasNoclipping then 
		ply.m_bWasNoclipping = nil 
		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM ) 
		
		if CLIENT then 
			ply:SetIK( true )
		end 
	end 

	ply.CalcIdeal = ACT_STAND
	ply.CalcSeqOverride = ply:LookupSequence( "sit_pistol" )

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function ENT:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	ply:SetPlaybackRate( 1 )

	if CLIENT then
		local GunnerSeat = self:GetGunnerSeat()

		if ply == self:GetDriver() then
			ply:SetPoseParameter( "vehicle_steer", self:GetSteer() /  self:GetMaxSteerAngle() )
			ply:InvalidateBoneCache()
		end

		if IsValid( GunnerSeat ) and GunnerSeat:GetDriver() == ply then
			local Pitch = math.Remap( self:GetPoseParameter( "turret_pitch" ),0,1,-15,-5)
			local Yaw = math.Remap( self:GetPoseParameter( "turret_yaw" ),0,1,-20,20) 

			ply:SetPoseParameter( "aim_pitch", Pitch * 1.5 )
			ply:SetPoseParameter( "aim_yaw", Yaw * 1.5 )

			ply:SetPoseParameter( "head_pitch", -Pitch * 2 )
			ply:SetPoseParameter( "head_yaw", -Yaw * 3 )

			ply:SetPoseParameter( "move_x", 0 )
			ply:SetPoseParameter( "move_y", 0 )

			ply:InvalidateBoneCache()
		end

		GAMEMODE:GrabEarAnimation( ply )
		GAMEMODE:MouthMoveAnimation( ply )
	end

	return false
end
