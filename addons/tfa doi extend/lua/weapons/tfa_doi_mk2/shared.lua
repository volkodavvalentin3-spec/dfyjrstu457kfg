// MISC
SWEP.Base					= "tfa_ins2_nade_base"
SWEP.Category				= "TFA DOI"
SWEP.Author					= "Commando"
SWEP.Contact				= ""
SWEP.PrintName				= "Mk2 Grenade"
SWEP.Purpose				= "Successor to the Mk.2 grenade with a 3 second fuse before detonation will devestate foes."
SWEP.Type				    = "America Fragmentation Hand Grenade"
SWEP.Slot					= 4
SWEP.SlotPos				= 99
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.Weight					= 2
SWEP.AutoSwitchTo				= true
SWEP.AutoSwitchFrom			= true
SWEP.HoldType 				= "grenade"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.Sprint_Mode 				= TFA.Enum.LOCOMOTION_ANI
SWEP.SelectiveFire = false

// VIEWMODEL
SWEP.ViewModelFOV				= 65
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/tfa_doi/v_mk2.mdl"

// WORLDMODEL
SWEP.WorldModel				= "models/weapons/doi/w_mk2.mdl"
SWEP.ShowWorldModel			= true

// NADE STUFF
SWEP.Primary.RPM				= 30
SWEP.Primary.ClipSize			= 1
SWEP.Primary.DefaultClip		= 3
SWEP.Primary.Automatic			= false
SWEP.Primary.Ammo				= "grenade"
SWEP.Primary.Round 			= ("tfa_doi_thrownmk2")
SWEP.Velocity = 1200
SWEP.Velocity_Underhand = 650
SWEP.Delay = 0.23
SWEP.DelayCooked = 0.24
SWEP.Delay_Underhand = 0.245
SWEP.CookStartDelay = 1
SWEP.UnderhandEnabled = true
SWEP.CookingEnabled = true
SWEP.CookTimer = 3

SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ,
		["value"] = "sprint",
		["is_idle"] = true
	}
}

SWEP.InspectPos 				= Vector(4, -3.619, -0.787)
SWEP.InspectAng 				= Vector(22.386, 34.417, 5)
