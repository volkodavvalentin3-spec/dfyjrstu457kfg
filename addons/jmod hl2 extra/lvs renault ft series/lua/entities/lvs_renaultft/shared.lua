ENT.Base = "lvs_tank_wheeldrive"

ENT.PrintName = "FT"
ENT.Author = "Kalamari"
ENT.Information = "Kalamari's WW1 Vehicles"
ENT.Category = "[LVS] - Tanks"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Light"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.MDL = "models/tank_ft_female.mdl"

ENT.TurretSeatIndex = 1

ENT.AITEAM = 2

ENT.MaxHealth = 250

--damage system
ENT.DSArmorIgnoreForce = 1500
ENT.CannonArmorPenetration = 7000
ENT.FrontArmor = 1000
ENT.SideArmor = 200
ENT.TurretArmor = 1000
ENT.RearArmor = 200

ENT.FrontArmorHP = 300
ENT.SideArmorHP = 100
ENT.TurretArmorHP = 300
ENT.RearArmorHP = 300

-- ballistics
ENT.ProjectileVelocityCoaxial = 4000
ENT.ProjectileVelocityHighExplosive = 8000
ENT.ProjectileVelocityArmorPiercing = 16000

ENT.SpawnNormalOffset = 40

//damage system
//ENT.DSArmorDamageReduction = 0.6
ENT.DSArmorBulletPenetrationType = DMG_BULLET + DMG_BLAST + DMG_AIRBOAT
ENT.DSArmorIgnoreDamageType = DMG_SONIC + DMG_SLASH + DMG_MISSILEDEFENSE + DMG_CLUB
ENT.DSArmorDamageReductionType = DMG_BULLET

ENT.MaxVelocity = 300
ENT.MaxVelocityReverse = 250

ENT.EngineCurve = 0.2
ENT.EngineTorque = 300

ENT.TransGears = 5
ENT.TransGearsReverse = 5

ENT.FastSteerAngleClamp = 15
ENT.FastSteerDeactivationDriftAngle = 12

ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = true

ENT.PhysicsWeightScale = 2
ENT.PhysicsDampingSpeed = 1000
ENT.PhysicsInertia = Vector(6000,6000,1500)

ENT.MouseSteerAngle = 20
--ENT.MouseSteerExponent = 2

ENT.lvsShowInSpawner = true

ENT.WheelBrakeAutoLockup = true
ENT.WheelBrakeLockupRPM = 15

ENT.EngineSounds = {
	{
		sound = "engine1.wav",
		Volume = 10,
		Pitch = 50,
		PitchMul = 25,
		SoundLevel = 80,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "engineFT.wav",
		Volume = 10,
		Pitch = 50,
		PitchMul = 25,
		SoundLevel = 80,
		UseDoppler = true,
	},
}

function ENT:OnSetupDataTables()
	self:AddDT( "Entity", "WeaponSeat" )
	self:AddDT( "Entity", "GunnerSeat" )
end

ENT.ExhaustPositions = {
	{
		pos = Vector(-51,-28,48),
		ang = Angle(180,55,0),
	},
}