SWEP.Category				= "TFA DOI"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.PrintName				= "Marine Bayonet"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 0				-- Slot in the weapon selection menu
SWEP.SlotPos				= 27			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "knife"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/tfa_doi/v_marinebayonet.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/khrcw2/doipack/w_kabar.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= true
SWEP.Base				= "tfa_knife_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false

SWEP.Offset = {
	Pos = {
		Up = -2.2,
		Right = 1.5,
		Forward = 3
	},
	Ang = {
		Up = 0,
		Right = 90,
		Forward = 0
	},
	Scale = 1.0
}

SWEP.ViewModelFOV			= 75		-- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip			= false		-- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = true --Use gmod c_arms system.

--SWEP.SlashTable = {"hitcenter1", "hitcenter2"} --Table of possible hull sequences
SWEP.SlashTable = {"hitcenter1","hitcenter1"} --Table of possible hull sequences
SWEP.StabTable = {"hitcenter2"} --Table of possible hull sequences
SWEP.StabMissTable = {"hitcenter2"} --Table of possible hull sequences

SWEP.Primary.RPM = 120 --Primary Slashs per minute
SWEP.Secondary.RPM = 80 --Secondary stabs per minute
SWEP.Primary.Delay = 0.2 --Delay for hull (primary)
SWEP.Secondary.Delay = 0.25 --Delay for hull (secondary)
SWEP.Primary.Damage = 70
SWEP.Secondary.Damage = 90

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1

SWEP.Primary.Sound = ""-- Sound("Weapon_Knife.Slash") --Sounds
SWEP.KnifeShink = "tfa_doi_knife.Hitwall"--"Weapon_Knife.HitWall" --Sounds
SWEP.KnifeSlash = "tfa_doi_knife.Hit"--"Weapon_Knife.Hit" --Sounds
SWEP.KnifeStab = ""--"Weapon_Knife.Slash" --Sounds

SWEP.Primary.Length = 70
SWEP.Secondary.Length = 70

function SWEP:ThrowKnife()
	return
end

--
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only

SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "sprint", --Number for act, String/Number for sequence
		["is_idle"] = true
	}
}

SWEP.InspectPos 				= Vector(4, -3.619, -0.787)
SWEP.InspectAng 				= Vector(22.386, 34.417, 5)
