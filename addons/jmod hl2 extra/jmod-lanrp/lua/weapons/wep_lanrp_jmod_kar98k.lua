SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Kar-98k"
JMod.SetWepSelectIcon(SWEP, "entities/ent_lanrp_jmod_kar98k", false)
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/c_unsk98k.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.WorldModel = "models/weapons/w_k98k.mdl"
SWEP.WorldModelOffset = {
	pos = Vector(-1, .5, 2.5),
	ang = Angle(-15, 0, 180)
}

SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(185, 15, 180)
SWEP.BodyHolsterAngL = Angle(0, 195, 170)
SWEP.BodyHolsterPos = Vector(4, -2, -5)
SWEP.BodyHolsterPosL = Vector(1, -11, 11)
SWEP.BodyHolsterScale = .9
JMod.ApplyAmmoSpecs(SWEP, "Medium Rifle Round", 1.3)
SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.
SWEP.Recoil = 1.5
SWEP.Delay = 60 / 35 -- 60/RPM.
SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "BOLT-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"
SWEP.AccuracyMOA = 3 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
--SWEP.FirstShootSound = "snd_jack_hmcd_snp_close.wav"

SWEP.ShootSound = "weapons/k98k/scout_fire-1.wav"
SWEP.DistantShootSound = "weapons/k98k/huntingrifle.wav"
SWEP.TrueDistantSound = "LANRP/realism/weapon/dist/kar98/kar98_dist.mp3"

SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_m14"
--SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
--SWEP.ShellPitch = 80
--SWEP.ShellScale = 2
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .6
SWEP.SightTime = .55
SWEP.IronSightStruct = {
	Pos = Vector(-4.73, -2, 2.8),
	Ang = Vector(.246, .06, 0),
	Magnification = 1,
	SwitchToSound = "weapons/k98k/foley2.wav",
	SwitchFromSound = "weapons/k98k/foley4.wav"
}

SWEP.ActivePos = Vector(0, 0, .5)
SWEP.ActiveAng = angle_zero
SWEP.HolsterPos = Vector(5.5, 1, 1)
SWEP.HolsterAng = Angle(-15, 40, 0)

SWEP.BarrelLength = 45
SWEP.Animations = {
	["idle"] = {
		Source = "awm_idle",
		Time = 1
	},
	["draw"] = {
		Source = "awm_draw",
		Time = 1.6,
		SoundTable = {
			{
				s = "weapons/k98k/foley5.wav",
				t = 0.1,
				v = 60
			},
			{
				s = "weapons/k98k/boltback.wav",
				t = 0.3,
				v = 60
			},
			{
				s = "weapons/k98k/boltrelease.wav",
				t = 0.5,
				v = 60
			},
			{
				s = "weapons/k98k/boltforward.wav",
				t = 0.6,
				v = 60
			},
			{
				s = "weapons/k98k/boltlatch.wav",
				t = 0.8,
				v = 60
			},
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = .35,
	},
	["fire"] = {
		Source = "awm_fire",
		Time = 2,
		SoundTable = {
			{
				s = "weapons/k98k/boltback.wav",
				t = 0.7,
				v = 60
			},
			{
				s = "weapons/k98k/boltrelease.wav",
				t = 0.85,
				v = 30
			},
			{
				s = "weapons/k98k/boltforward.wav",
				t = 1.1,
				v = 60
			},
			{
				s = "weapons/k98k/boltlatch.wav",
				t = 1.3,
				v = 30
			},
		},
		--ShellEjectAt = 1,
	},
	["reload"] = {
		Source = "awm_reload",
		Time = 4,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		SoundTable = {
			{
				s = "weapons/k98k/magrelease.wav",
				t = 0.3,
				v = 30
			},
			{
				s = "weapons/k98k/magout.wav",
				t = 0.7,
				v = 60
			},
			{
				s = "weapons/k98k/magin.wav",
				t = 2,
				v = 60
			},


			{
				s = "weapons/k98k/boltrelease.wav",
				t = 2.7,
				v = 60
			},
			{
				s = "weapons/k98k/boltback.wav",
				t = 2.8,
				v = 60
			},
			{
				s = "weapons/k98k/boltforward.wav",
				t = 3,
				v = 60
			},
			{
				s = "weapons/k98k/boltlatch.wav",
				t = 3.1,
				v = 60
			},
		}
	}
}