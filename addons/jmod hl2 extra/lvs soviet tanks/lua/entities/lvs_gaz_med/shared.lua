
ENT.Base = "lvs_base_wheeldrive"

ENT.PrintName = "GAZ-MM Medical"
ENT.Author = "SIMER"
ENT.Information = "ДурОчка"
ENT.Category = "[LVS] - Cars"

ENT.VehicleCategory = "Tanks WW2"
ENT.VehicleSubCategory = "Cars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/simer/lvs_gaz_mm_med.mdl"

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

ENT.HornSound = "weapons/zonk.wav"
ENT.HornPos = Vector(40,0,35)

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
			{ pos = Vector(-123,31,23), colorG = 0, colorB = 0, colorA = 150 },
			
			
		},
		ProjectedTextures = {
			{ pos = Vector(92,18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(92,-18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			
		},
	},
	{
		Trigger = "high",
		ProjectedTextures = {
			{ pos = Vector(92,18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
			{ pos = Vector(92,-18,45), ang = Angle(0,0,0), colorB = 200, colorA = 150, shadows = true },
		
		
		},
	},
	{
		Trigger = "main+high",
		SubMaterialID = 1,
		Sprites = {
			{ pos = Vector(92,18,45), colorB = 200, colorA = 150 },
			{ pos = Vector(92,-18,45), colorB = 200, colorA = 150 },
		
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

end

