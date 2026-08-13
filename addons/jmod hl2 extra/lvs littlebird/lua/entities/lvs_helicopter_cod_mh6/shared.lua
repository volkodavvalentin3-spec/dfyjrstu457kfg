
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "MH-6 Littlebird"
ENT.Category = "[LVS] - Helicopters"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lfs_merydian/ah6_lbbench.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 325

ENT.MaxVelocity = 2550

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.8

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1.3
ENT.TurnRateRoll = 1

ENT.ForceLinearDampingMultiplier = 1.4

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.GibModels = {
	"models/lvs_custom/mh6/ah6_gib1.mdl",
	"models/lvs_custom/mh6/ah6_gib2.mdl",
	"models/lvs_custom/mh6/ah6_gib3.mdl",
	"models/lvs_custom/mh6/ah6_gib4.mdl",
	"models/lvs_custom/mh6/ah6_gib5.mdl",
	"models/lvs_custom/mh6/ah6_gib6.mdl",
}

ENT.EngineSounds = {
	{
	    sound = "^lvs_custom/ah6/rotor.wav",
		sound_int = "lvs_custom/ah6/ah6_cockpit.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =110,
		UseDoppler = true,
	},
	{
	    sound = "^lvs_custom/ah6/engine.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =105,
		UseDoppler = true,
	},
		{
	    sound = "lvs_custom/ah6/ah6_turbine.wav",
		sound_int = "",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =70,
		UseDoppler = true,
	},
}

ENT.FlyByAdvance = 1 -- how many second the flyby sound is advanced
ENT.FlyBySound = "AH6_FLYBY" -- which sound to play on fly by

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "LightsEnabled" )
	self:AddDT( "Bool", "SignalsEnabled" )
end

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetLightsEnabled then return end

		if ent:GetAI() then return end

		ent:SetLightsEnabled( not ent:GetLightsEnabled() )
		ent:EmitSound( "items/flashlight1.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_light.wav")
	end
	self:AddWeapon( weapon )
	
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/wing_light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetSignalsEnabled then return end

		if ent:GetAI() then return end

		ent:SetSignalsEnabled( not ent:GetSignalsEnabled() )
		ent:EmitSound( "buttons/lightswitch2.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_signal.wav")
	end
	self:AddWeapon( weapon )
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_ah6", "vgui/killicons/iw4_choppergunner")
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_mh6", "vgui/killicons/iw4_choppergunner")
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_mh6alt", "vgui/killicons/iw4_choppergunner")
end

sound.Add( {
	name = "AH6_MGLOOP",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/gunloop.wav"
} )

sound.Add( {
	name = "AH6_MGWHINELOOP",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 70,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/whineloop.wav"
} )

sound.Add( {
	name = "AH6_MGLOOPDistance",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 120,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/gunloopdistant.wav"
} )

sound.Add( {
	name = "AH6_MGSTART",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 70,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstart.wav"
} )

sound.Add( {
	name = "AH6_MGSTARTDistance",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 120,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstartdistant.wav"
} )

sound.Add( {
	name = "AH6_MGSTOP",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstop.wav"
} )

sound.Add( {
	name = "AH6_MGSTOPTDistance",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 120,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstopdistant.wav"
} )

sound.Add( {
	name = "AH6_MGLAST_OVERHEAT",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = {100},
	sound = "lvs_custom/ah6/last.wav"
} )

sound.Add( {
	name = "AH6_FLYBY",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 110,
	pitch = {100},
	sound = {"lvs_custom/ah6/flyby-01.wav","lvs_custom/ah6/flyby-02.wav","lvs_custom/ah6/flyby-03.wav","lvs_custom/ah6/flyby-04.wav"}
} )
