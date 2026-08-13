-- Variables that are used on both client and server
SWEP.Gun = ("tfa_verdun_tankgewehr") -- must be the name of your swep but NO CAPITALS!
SWEP.Category				= "TFA Verdun" --Category where you will find your weapons
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Manufacturer = "Mauser" --Gun Manufactrer (e.g. Hoeckler and Koch )
SWEP.Author				= "The Master MLG"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.PrintName				= "Tankgewehr 1918"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 2				-- Slot in the weapon selection menu
SWEP.SlotPos				= 2		-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox		= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   	= false		-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= true		-- set false if you want no crosshair
SWEP.Weight					= 35		-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "ar2"		-- how others view you carrying the weapon
-- normal melee melee2 fist knife smg ar2 pistol rpg physgun grenade shotgun crossbow slam passive 
-- you're mostly going to use ar2, smg, shotgun or pistol. rpg makes for good sniper rifles

SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_verdun_tankgewehr1918_t6.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_verdun_tankgewehr.mdl"	-- Weapon world model
SWEP.Base				= "tfa_gun_base" --the Base this weapon will work on. PLEASE RENAME THE BASE! 
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater = false
SWEP.ShowWorldModel			= true
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("TFA_WW1_Tankgewehr_1918.Fire") -- This is the sound of the weapon, when you shoot.
SWEP.Primary.RPM			= 100		-- This is in Rounds Per Minute
SWEP.Primary.StaticRecoilFactor = 3.55
SWEP.Primary.HullSize = 2
SWEP.Primary.ClipSize			= 1		-- Size of a clip
SWEP.Primary.DefaultClip		= 5		-- Bullets you start with
SWEP.Primary.KickUp			= 3.22		-- Maximum up recoil (rise)
SWEP.Primary.KickDown			= 2.05		-- Maximum down recoil (skeet)
SWEP.Primary.KickHorizontal		= 1.86		-- Maximum up recoil (stock)
SWEP.Primary.Automatic			= false	-- Automatic = true; Semi Auto = false
SWEP.Primary.Ammo			= "SniperPenetratedRound"			-- pistol, 357, smg1, ar2, buckshot, slam, SniperPenetratedRound, AirboatGun
SWEP.Primary.Knockback = 555
SWEP.Primary.Force     = 9 -- Force value, leave nil to autocalc
-- Pistol, buckshot, and slam always ricochet. 
--Use AirboatGun for a light metal peircing shotgun pellets
SWEP.SelectiveFire		= false
SWEP.CanBeSilenced		= false
SWEP.DisableChambering = true

SWEP.ProjectileEntity = "ent_panzerschreck_shell_v2" --Entity to shoot
SWEP.ProjectileVelocity = 1 --Entity to shoot's velocity

SWEP.Secondary.IronFOV			= 70		-- How much you 'zoom' in. Less is more! 	

SWEP.data 				= {}				--The starting firemode

SWEP.Primary.Damage		= 250  -- Base damage per bullet
SWEP.Primary.Spread		= .095	-- Define from-the-hip accuracy 1 is terrible, .0001 is exact)
SWEP.Primary.IronAccuracy = .008 -- Ironsight accuracy, should be the same for shotguns

SWEP.Type = "Anti-Tank Rifle"
SWEP.FireModeName = "Bolt-Action"

SWEP.Primary.DamageTypeHandled = true       -- true will handle damagetype in base
SWEP.Primary.DamageType        = DMG_BULLET -- See DMG enum. This might be DMG_SHOCK, DMG_BURN, DMG_BULLET, etc.  Leave nil to autodetect.  DMG_AIRBOAT opens doors.

SWEP.ViewModelBoneMods = {
	["L Hand"] = { scale = Vector(0.78, 0.78, 0.78), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
        ["R Hand"] = { scale = Vector(0.79, 0.79, 0.79), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
}

-- Enter iron sight info and bone mod info below
SWEP.IronSightsPos = Vector(-2.819, 0, 0.995)
SWEP.IronSightsAng = Vector(0.244, 0, 0)
SWEP.InspectPos = Vector(7.76, -5.178, 0.016)
SWEP.InspectAng = Vector(1, 37.277, 3.2)
SWEP.IronSightTime			= 0.4
SWEP.MoveSpeed = 0.8 --Multiply the player's movespeed by this.
SWEP.DisableChambering = true
SWEP.IronSightsMoveSpeed = SWEP.MoveSpeed  * 0.6 --Multiply the player's movespeed by this when sighting.

SWEP.Offset = {
	Pos = {
		Up = 0.5,
		Right = 0.964,
		Forward = -2.2
	},
	Ang = {
		Up = 0,
		Right = -5.844,
		Forward = 180
	},
	Scale = 1.1
} --Procedural world model animation, defaulted for CS:S purposes.


SWEP.WElements = {
	["ref"] = { type = "Model", model = SWEP.WorldModel, bone = "oof", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}, bonemerge = true, active = false },
}

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_HYBRID -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_ANI -- ANI = mdl, HYBRID = ani + lua, Lua = lua only

SWEP.SprintAnimation = {
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "base_sprint", --Number for act, String/Number for sequence
		["is_idle"] = true
	}
}

--Shell

SWEP.LuaShellEject               = false                      -- Enable shell ejection through lua?
SWEP.LuaShellEjectDelay          = 0                          -- The delay to actually eject things
SWEP.LuaShellEffect              = "RifleShellEject"          -- The effect used for shell ejection; Defaults to that used for blowback


SWEP.EventTable = {
	[ACT_VM_RELOAD] = {
		{ ["time"] = 20 / 30, ["type"] = "lua", ["value"] = function(wep,vm)
			if wep and wep.EventShell then
				wep:EventShell()
			end
		end, ["client"] = true, ["server"] = true }
	},
}


SWEP.IronSightsReloadEnabled = true
SWEP.IronSightsReloadLock    = false

--[[ATTACHMENTS]]--NEW

SWEP.Attachments = {
	[1] = { atts = { "doipage_mg_bipods"} },

}

SWEP.AttachmentDependencies = {}

SWEP.AttachmentExclusions   = {}
