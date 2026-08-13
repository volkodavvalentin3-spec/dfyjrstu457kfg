
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "GAZ-MM 61-K"
ENT.Author = "SIMER"
ENT.Information = "ЗенитОчка"
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Cars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/lvs_gaz_mm_61k.mdl"

ENT.AITEAM = 2

ENT.MaxHealth = 500

--damage system
ENT.CannonArmorPenetration = 2700

ENT.MaxVelocity = 700
ENT.MaxVelocityReverse = 250

ENT.EngineCurve = 0
ENT.EngineTorque = 175

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.lvsShowInSpawner = true

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/kuebelwagen/eng_idle_loop.wav",
		Volume = 0.5,
		Pitch = 85,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/vehicles/kuebelwagen/eng_loop.wav",
		Volume = 1,
		Pitch = 100,
		PitchMul = 100,
		SoundLevel = 75,
		UseDoppler = true,
	},
}

ENT.Lights = {
	{
		Trigger = "main",
		Sprites = {
			{ pos = Vector(-109,32,30), colorG = 0, colorB = 0, colorA = 150 },
			
		},
		ProjectedTextures = {
			{ pos = Vector(92,18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			
		},
	},
	{
		Trigger = "high",
		ProjectedTextures = {
			{ pos = Vector(92,18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		
		},
	},
	{
		Trigger = "main+high",
		SubMaterialID = 1,
		Sprites = {
			{ pos = Vector(92,18,45), colorB = 200, colorA = 150 },
		
		},
	},
	{
		Trigger = "brake",
		SubMaterialID = 2,
		Sprites = {
			{ pos = Vector(-109,32,30), colorG = 0, colorB = 0, colorA = 150 },
			
		}
	},
	{
		Trigger = "fog",
		SubMaterialID = 3,
		Sprites = {
			{ pos = Vector(33.15,-25.63,48.61), colorB = 200, colorA = 150 },
		},
	},
}

ENT.ExhaustPositions = {
	{
		pos = Vector(32,-15,-7),
		ang = Angle(0,210,0),
	},
}


function ENT:InitWeapons()
    local weapon = {}
	weapon.Icon = Material("lvs/weapons/bullet_ap.png")
	weapon.Ammo = 1500
	weapon.Delay = 0.25
	weapon.HeatRateUp = 1
	weapon.HeatRateDown = 0.5
	weapon.Attack = function( ent )
		if not ent:TurretInRange() then
			if IsValid( ent.SNDTurretMG ) then
				ent.SNDTurretMG:Stop()
			end

			return true
		end

		ent._MuzzleID = ent._MuzzleID and ent._MuzzleID + 1 or 1

		if ent._MuzzleID > 4 then
			ent._MuzzleID = 1
		end

		local ID = ent:LookupAttachment( "muzzle_"..ent._MuzzleID )

		local Muzzle = ent:GetAttachment( ID )

		if not Muzzle then return end

		local Pos = Muzzle.Pos
		local Dir =  Muzzle.Ang:Forward()

		local bullet = {}
		bullet.Src 	= Pos
		bullet.Dir 	= (ent:GetEyeTrace().HitPos - Pos):GetNormalized()
		bullet.Spread 	= Vector(0,0,0)
		bullet.TracerName = "lvs_tracer_autocannon"
		bullet.Force	= 1500
		bullet.HullSize 	= math.Round( math.min( 200 * math.abs( Dir.z ), 50 ), 0 )
		bullet.Damage	= 5
		bullet.SplashDamage = 75
		bullet.SplashDamageRadius = 180
		bullet.SplashDamageEffect = "lvs_defence_explosion"
		bullet.SplashDamageType = DMG_BLAST
		bullet.Velocity = 30000
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo( 1 )

		if not IsValid( ent.SNDTurretMG ) then return end

		ent.SNDTurretMG:Play()
	end
	weapon.StartAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		ent.SNDTurretMG:Play()
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent.SNDTurretMG ) then return end
		if not ent.SNDTurretMG:GetActive() then return end

		ent.SNDTurretMG:Stop()
		ent.SNDTurretMG:EmitSound( "lvs/vehicles/halftrack/mc_lastshot.wav" )
	end
	weapon.OnOverheat = function( ent )
		ent:EmitSound("lvs/vehicles/222/cannon_overheat.wav")
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()

		local Col =  ent:TurretInRange() and Color(255,255,255,255) or Color(255,0,0,255)

		ent:PaintCrosshairCenter( Pos2D, Col )
		ent:PaintCrosshairOuter( Pos2D, Col )
		ent:LVSPaintHitMarker( Pos2D )
	end
	self:AddWeapon( weapon )

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/horn.png")
	weapon.Ammo = -1
	weapon.Delay = 0.5
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.UseableByAI = false
	weapon.Attack = function( ent ) end
	weapon.StartAttack = function( ent )
		if not IsValid( ent.HornSND ) then return end
		ent.HornSND:Play()
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent.HornSND ) then return end
		ent.HornSND:Stop()
	end
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
	weapon.OnThink = function( ent, active )
		ent:SetHeat( self.WEAPONS[1][ 1 ]._CurHeat or 0 )
	end
	self:AddWeapon( weapon )
end

