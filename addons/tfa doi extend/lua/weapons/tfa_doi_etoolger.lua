SWEP.Category				= "TFA DOI"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.PrintName				= "Entrenching Tool"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 0				-- Slot in the weapon selection menu
SWEP.SlotPos				= 27			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 30			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "melee2"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg and crossbow make for good sniper rifles

SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/tfa_doi/v_etool_ger.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/doi/w_etool_ger.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= true
SWEP.Base				= "tfa_knife_base"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false

SWEP.Offset = {
	Pos = {
		Up = 0.25,
		Right = 0.5,
		Forward = 4
	},
	Ang = {
		Up = -1,
		Right = -15,
		Forward = 178
	},
	Scale = 1.0
}

SWEP.ViewModelFOV			= 75		-- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip			= false		-- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = true --Use gmod c_arms system.

SWEP.SlashTable = {"base_attack_1", "base_attack_2"} --Table of possible hull sequences
SWEP.StabTable = {"base_attack_3"} --Table of possible hull sequences
SWEP.StabMissTable = {"base_attack_3"} --Table of possible hull sequences

SWEP.Primary.RPM = 100 --Primary Slashs per minute
SWEP.Secondary.RPM = 60 --Secondary stabs per minute
SWEP.Primary.Delay = 0.3 --Delay for hull (primary)
SWEP.Secondary.Delay = 0.4 --Delay for hull (secondary)
SWEP.Primary.Damage = 80
SWEP.Secondary.Damage = 95

SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = -1

SWEP.Primary.Sound = ""-- Sound("Weapon_Knife.Slash") --Sounds
SWEP.KnifeShink = "tfa_doi_tool.Hitwall"--"Weapon_Knife.HitWall" --Sounds
SWEP.KnifeSlash = "tfa_doi_tool.Hit"--"Weapon_Knife.Hit" --Sounds
SWEP.KnifeStab = ""--"Weapon_Knife.Slash" --Sounds

SWEP.Primary.Length = 80
SWEP.Secondary.Length = 80

SWEP.VMPos = Vector(0,0,-2)
SWEP.VMAng = Vector(5,0,0)

function SWEP:ThrowKnife()
	return
end

--
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only

SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "base_sprint", --Number for act, String/Number for sequence
		["is_idle"] = true
	}
}

SWEP.InspectPos 				= Vector(4, -3.619, -0.787)
SWEP.InspectAng 				= Vector(22.386, 34.417, 5)
