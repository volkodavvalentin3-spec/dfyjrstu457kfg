
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "Willys MB"
ENT.Author = "SIMER"
ENT.Information = ""
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Cars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/wil_mow.mdl"

ENT.AITEAM = 2

ENT.MaxVelocity = 750

ENT.EngineTorque = 150
ENT.EngineCurve = 0.25

ENT.TransGears = 4
ENT.TransGearsReverse = 2

ENT.HornSound = "weapons/zonk.wav"
ENT.HornPos = Vector(40,0,35)

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/willy/eng_idle_loop.wav",
		Volume = 0.5,
		Pitch = 85,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/vehicles/willy/eng_loop.wav",
		Volume = 1,
		Pitch = 50,
		PitchMul = 100,
		SoundLevel = 75,
		UseDoppler = true,
	},
}

ENT.Lights = {
{
		Trigger = "main",
		Sprites = {
			{ pos = Vector(-79,30,23), colorG = 0, colorB = 0, colorA = 150 },
			{ pos = Vector(-79,-28,23), colorG = 0, colorB = 0, colorA = 150 },
			
		},
		ProjectedTextures = {
			{ pos = Vector(70,21,42), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(70,-19,42), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		},
	},
	{
		Trigger = "high",
		ProjectedTextures = {
			{ pos = Vector(70,21,42), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(70,-19,42), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		},
	},
	{
		Trigger = "main+high",
		SubMaterialID = 1,
		Sprites = {
			{ pos = Vector(70,21,42), colorB = 200, colorA = 150 },
			{ pos = Vector(70,-19,42), colorB = 200, colorA = 150 },
		},
	},
	{
		Trigger = "brake",
		SubMaterialID = 2,
		Sprites = {
			{ pos = Vector(-79,30,23), colorG = 0, colorB = 0, colorA = 150 },
			
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
		pos = Vector(-59.32,13.07,12.77),
		ang = Angle(0,180,0),
	},
}

