--player_manager.AddValidModel("JMod_HazMat", "models/bloocobalt/splinter cell/chemsuit_cod.mdl")
--player_manager.AddValidHands("JMod_HazMat", "models/bloocobalt/splinter cell/chemsuit_v.mdl", 0, "00000000")
--[[ ArmorSlots

	-- if damage is locational (bullets):

	HITGROUP_HEAD
		eyes (1/2 of hit if hit is from front)
		mouthnose (1/2 of hit if hit is from front)
		ears (nonprotective: receives damage but doesn't protect, 1/4)
		head (if hit angle isn't from front)
	HITGROUP_CHEST
		chest (all of HITGROUP_CHEST)
		back (all of HITGROUP_CHEST if hit is from back)
	HITGROUP_STOMACH
		abdomen (all of HITGROUP_STOMACH)
	HITGROUP_LEFTLEG
		leftthigh (1/2)
		leftcalf (1/2)
	HITGROUP_RIGHTLEG
		rightthigh (1/2)
		rightcalf (1/2)
	HITGROUP_RIGHTARM
		rightbicep (1/2)
		rightforearm (1/2)
	HITGROUP_LEFTARM
		leftbicep (1/2)
		leftforearm (1/2)
	
--]]
-- support third-party backup armor repair recipes
JMod.BackupArmorRepairRecipes = JMod.BackupArmorRepairRecipes or {}

JMod.LocationalDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER}

--JMod.FullBodyScalingDamageTypes={DMG_ACID, DMG_POISON}
JMod.FullBodyDmgTypes = {DMG_CRUSH, DMG_SLASH, DMG_BURN, DMG_VEHICLE, DMG_BLAST, DMG_CLUB, DMG_PLASMA, DMG_ACID, DMG_POISON}

JMod.BiologicalDmgTypes = {DMG_NERVEGAS, DMG_RADIATION}

JMod.PiercingDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER, DMG_SLASH}

JMod.BodyPartHealthMults = {
	--skintight -- HITGROUP_HEAD
	eyes = .05,
	mouthnose = .05,
	ears = 0,
	head = .18,
	-- HITGROUP_CHEST
	chest = .25,
	back = 0,
	-- HITGROUP_STOMACH
	abdomen = .1,
	pelvis = .05,
	waist = 0,
	-- HITGROUP_LEFTLEG
	leftthigh = .04,
	leftcalf = .04,
	-- HITGROUP_RIGHTLEG
	rightthigh = .04,
	rightcalf = .04,
	-- HITGROUP_RIGHTARM
	rightshoulder = .04,
	rightforearm = .04,
	-- HITGROUP_LEFTARM
	leftshoulder = .04,
	leftforearm = .04
}

JMod.ArmorSlotNiceNames = {
	eyes = "Eyes",
	mouthnose = "Mouth & Nose",
	ears = "Ears",
	head = "Head",
	chest = "Chest",
	back = "Back",
	abdomen = "Abdomen",
	pelvis = "Pelvis",
	waist = "Waist",
	leftthigh = "Left Thigh",
	leftcalf = "Left Calf",
	rightthigh = "Right Thigh",
	rightcalf = "Right Calf",
	rightshoulder = "Right Shoulder",
	rightforearm = "Right Forearm",
	leftshoulder = "Left Shoulder",
	leftforearm = "Left Forearm"
}

-- only used if JMod.Config.QoL.RealisticLocationalDamage is true
JMod.BodyPartDamageMults = {
	[HITGROUP_HEAD] = 2,
	[HITGROUP_CHEST] = 1,
	[HITGROUP_GENERIC] = 1,
	[HITGROUP_STOMACH] = 1.1,
	[HITGROUP_GEAR] = .8,
	[HITGROUP_LEFTARM] = .9,
	[HITGROUP_RIGHTARM] = .9,
	[HITGROUP_LEFTLEG] = .9,
	[HITGROUP_RIGHTLEG] = .9
}

local BasicArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .999,
	[DMG_CLUB] = .99,
	[DMG_SLASH] = .99,
	[DMG_BULLET] = .98,
	[DMG_BLAST] = .95,
	[DMG_SNIPER] = .9,
	[DMG_AIRBOAT] = .85,
	[DMG_CRUSH] = .75,
	[DMG_VEHICLE] = .65,
	[DMG_BURN] = .65,
	[DMG_PLASMA] = .65,
	[DMG_ACID] = .55
}

local PoorArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .6,
	[DMG_CLUB] = .6,
	[DMG_SLASH] = .6,
	[DMG_BULLET] = .2,
	[DMG_BLAST] = .2,
	[DMG_SNIPER] = .1,
	[DMG_AIRBOAT] = .2,
	[DMG_CRUSH] = .3,
	[DMG_VEHICLE] = .2,
	[DMG_BURN] = .2,
	[DMG_PLASMA] = .1,
	[DMG_ACID] = .1
}

local NonArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .05,
	[DMG_BLAST] = .05,
	[DMG_BULLET] = .05,
	[DMG_SNIPER] = .05,
	[DMG_AIRBOAT] = .05,
	[DMG_CLUB] = .05,
	[DMG_SLASH] = .05,
	[DMG_CRUSH] = .05,
	[DMG_VEHICLE] = .05,
	[DMG_BURN] = .05,
	[DMG_PLASMA] = .05,
	[DMG_ACID] = .05
}

-- keep in mind that all armor model names must be all lower-case
JMod.ArmorTable = {
	["GasMask"] = {
		PrintName = "Gas Mask",
		mdl = "models/splinks/kf2/cosmetics/gas_mask.mdl", -- kf2
		slots = {
			eyes = 1,
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = 1,
			[DMG_RADIATION] = .75
		}, NonArmorProtectionProfile),
		dur = 2,
		chrg = {
			chemicals = 25
		},
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(0.8, 0.8, 0.8),
		pos = Vector(1.35, .1, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		mskmat = "mats_jack_gmod_sprites/vignette_gray.png",
		sndlop = "snds_jack_gmod/mask_breathe.ogg",
		ent = "ent_jack_gmod_ezarmor_gasmask",
		--[[tgl = {
			pos = Vector(3, 3, 0),
			ang = Angle(190, 180, 90),
			eff = {},
			mskmat = "",
			sndlop = "",
			def = NonArmorProtectionProfile,
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}]]
	},
	["BallisticMask"] = {
		PrintName = "Ballistic Mask",
		mdl = "models/jmod/ballistic_mask.mdl", -- csgo misc
		slots = {
			eyes = .8,
			mouthnose = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		dur = 200,
		mskmat = "mats_jack_gmod_sprites/hard_vignette.png",
		ent = "ent_jack_gmod_ezarmor_balmask",
		tgl = {
			pos = Vector(-2, 4, 0),
			ang = Angle(170, 180, 90),
			mskmat = "",
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}
	},
	["NightVisionGoggles"] = {
		PrintName = "Goggles-Night Vision",
		mdl = "models/nvg.mdl", -- scp something
		clr = {
			r = 15,
			g = 50,
			b = 10
		},
		slots = {
			eyes = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		entsiz = 1.5,
		pos = Vector(6.5, 2, 0),
		ang = Angle(-100, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 20
		},
		mskmat = "mats_jack_gmod_sprites/vignette.png",
		eqsnd = "snds_jack_gmod/tinycapcharge.ogg",
		ent = "ent_jack_gmod_ezarmor_nvgs",
		eff = {
			nightVision = true
		},
		blackvisionwhendead = true,
		tgl = {
			blackvisionwhendead = false,
			pos = Vector(6, 6, 0),
			ang = Angle(-130, 0, 90),
			mskmat = "",
			eff = {},
			slots = {
				eyes = 0
			}
		}
	},
	["ThermalGoggles"] = {
		PrintName = "Goggles-Thermal",
		mdl = "models/nvg.mdl", -- scp something
		slots = {
			eyes = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		entsiz = 1.5,
		pos = Vector(6.5, 2, 0),
		ang = Angle(-100, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 20
		},
		mskmat = "mats_jack_gmod_sprites/vignette.png",
		eqsnd = "snds_jack_gmod/tinycapcharge.ogg",
		ent = "ent_jack_gmod_ezarmor_thermals",
		eff = {
			thermalVision = true
		},
		blackvisionwhendead = true,
		tgl = {
			blackvisionwhendead = false,
			pos = Vector(6, 6, 0),
			ang = Angle(-130, 0, 90),
			mskmat = "",
			eff = {},
			slots = {
				eyes = 0
			}
		}
	},
	["Respirator"] = {
		PrintName = "Respirator",
		mdl = "models/jmod/respirator.mdl", -- MGSV
		slots = {
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = .25,
			[DMG_RADIATION] = .75
		}, NonArmorProtectionProfile),
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(3.25, 1, 0),
		ang = Angle(100, 180, 90),
		chrg = {
			chemicals = 10
		},
		wgt = 5,
		dur = 2,
		sndlop = "snds_jack_gmod/mask_breathe.ogg",
		ent = "ent_jack_gmod_ezarmor_respirator",
		tgl = {
			def = NonArmorProtectionProfile,
			eff = {},
			slots = {
				mouthnose = 0
			},
			pos = Vector(3.25, -4, 0),
			ang = Angle(110, 180, 90),
			sndlop = ""
		}
	},
	["Headset"] = {
		PrintName = "Headset",
		mdl = "models/jmod/props/items/sci_fi_headset.mdl", -- sci fi lt
		slots = {
			ears = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.2, 1.05, 1.1),
		pos = Vector(.5, 3, .1),
		ang = Angle(130, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 10
		},
		ent = "ent_jack_gmod_ezarmor_headset",
		eff = {
			teamComms = true,
			earPro = true
		},
		tgl = {
			eff = {},
			slots = {
				ears = 0
			},
			pos = Vector(1.5, -2.5, .1),
			ang = Angle(100, 0, 90)
		}
	},
	["Nazi-helmet"] = {
		PrintName = "Nazi-helmet",
		mdl = "models/parts/german_helmet.mdl", -- tarkov
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1, 1.07),
		pos = Vector(1.4, -3, 1.1),
		ang = Angle(-80, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_nazihead"
	},
	["Soviet-helmet"] = {
		PrintName = "Soviet-helmet",
		mdl = "models/half-dead/red orchestra 2/headgear/sov_helmet.mdl",
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.1, 0.95, 1),
		pos = Vector(0, -0.9, 0),
		ang = Angle(-80, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_sovhead"
	},
	["Adrian-helmet"] = {
		PrintName = "Adrian-helmet",
		mdl = "models/ironeurope/adrian helmet.mdl", -- tarkov
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(0.95, 1, 1.05),
		pos = Vector(-0.1, 6, 0.15),
		ang = Angle(90, 95, 0),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_adrianhead"
	},
	["Western-helmet"] = {
		PrintName = "Western-helmet",
		mdl = "models/parts/us_helmet.mdl", -- tarkov
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.1, 0.95, 1),
		pos = Vector(1, -2, 0.4),
		ang = Angle(-80, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_ushead"
	},
	["schirmmuetze"] = {
		PrintName = "schirmmuetze",
		mdl = "models/codww2/german/schirmmuetze.mdl",
		slots = {
			head = 0
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1.1, 1),
		pos = Vector(1, 1.4, 0.1),
		ang = Angle(-90, -25, 180),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_schirmmuetze"
	},
	["Glasses"] = {
		PrintName = "Glasses",
		mdl = "models/jmod/glasses_classic.mdl", -- csgo misc?
		slots = {
			eyes = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(2, 2.4, 0.1),
		ang = Angle(-80, 0, -90),
		mskmat = "mats_jack_gmod_sprites/glasses",
		wgt = 1,
		dur = 2,
		ent = "ent_jack_gmod_ezarmor_glasses",
		eff = {
			glasses = true
		},
		--[[tgl = {
			eff = {},
			slots = {
				eyes = 0
			},
			pos = Vector(1.5, -2.5, .1),
			ang = Angle(100, 0, 90)
		}--]]
	},
	["Light-Helmet"] = {
		PrintName = "Helmet-Light",
		mdl = "models/player/helmet_achhc_black/achhc_black.mdl", 
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.07, 1, 1.1),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_lhead"
	},
	["Medium-Helmet"] = {
		PrintName = "Helmet-Medium",
		mdl = "models/player/helmet_ulach_black/ulach.mdl", -- tarkov
		slots = {
			head = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1, 1.05),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 15,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_mhead"
	},
	["Heavy-Helmet"] = {
		PrintName = "Helmet-Heavy",
		mdl = "models/player/helmet_psh97_jeta/jeta.mdl", -- tarkov
		slots = {
			head = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(1, -3, 0),
		ang = Angle(-90, 0, -90),
		wgt = 20,
		dur = 350,
		ent = "ent_jack_gmod_ezarmor_hhead"
	},
	["Riot-Helmet"] = {
		PrintName = "Helmet-Riot",
		mdl = "models/jmod/helmet_riot_heavy.mdl", -- csgo
		slots = {
			head = 0.6,
			eyes = .4,
			mouthnose = .4
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1.1),
		pos = Vector(1, 3.5, 0),
		ang = Angle(-70, 0, -90),
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		wgt = 15,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_riot",
		bdg = {
			[0] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.6,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[0] = 1
			}
		}
	},
	["Heavy-Riot-Helmet"] = {
		PrintName = "Helmet-Heavy Riot",
		mdl = "models/jmod/helmet_riot.mdl",
		slots = {
			head = 0.8,
			eyes = .6,
			mouthnose = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(0, 1, 0),
		ang = Angle(-90, 0, -90),
		wgt = 25,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_rioth",
		bdg = {
			[1] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.8,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[1] = 1
			}
		}
	},
	["Ultra-Heavy-Helmet"] = {
		PrintName = "Helmet-UltraHeavy",
		mdl = "models/jmod/helmet_maska.mdl", -- tarkov
		slots = {
			head = 1,
			eyes = 1,
			mouthnose = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		pos = Vector(1.5, -2, 0),
		ang = Angle(-80, 0, -90),
		wgt = 35,
		dur = 500,
		mskmat = "mats_jack_gmod_sprites/slit_vignette.png",
		ent = "ent_jack_gmod_ezarmor_maska",
		bdg = {
			[1] = 0
		},
		tgl = {
			slots = {
				head = 1,
				eyes = 0,
				mouthnose = 0
			},
			bdg = {
				[1] = 1
			},
			mskmat = ""
		}
	},
	["Metal Bucket"] = {
		PrintName = "BUCKET",
		mdl = "models/props_junk/metalbucket01a.mdl", -- hl2
		slots = {
			head = 1,
			eyes = .75
		},
		eff = {scuba = true},
		def = PoorArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.75, .75, .75),
		pos = Vector(1, 5, 0),
		ang = Angle(90, 10, 0),
		wgt = 10,
		dur = 100,
		mskmat = "mats_jack_gmod_sprites/three-quarter-from-top-blocked.png",
		ent = "ent_jack_gmod_ezarmor_metalbucket"
	},
	["Metal Pot"] = {
		PrintName = "COOKIN POT",
		mdl = "models/props_interiors/pot02a.mdl", -- hl2
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		clrForced = true,
		slots = {
			head = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.15, 1.15, 1.15),
		pos = Vector(5.2, 7.2, -3),
		ang = Angle(80, 20, 30),
		wgt = 20,
		dur = 150,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_jack_gmod_ezarmor_metalpot"
	},
	["Ceramic Pot"] = {
		PrintName = "CERAMIC POT",
		mdl = "models/props_junk/terracotta01.mdl", -- hl2
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		clrForced = true,
		slots = {
			head = .9,
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.61, .61, .61),
		pos = Vector(-2, 11, .5),
		ang = Angle(90, 20, 0),
		wgt = 15,
		dur = 10,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_jack_gmod_ezarmor_ceramicpot"
	},
	["Traffic Cone"] = {
		PrintName = "CONE",
		mdl = "models/props_junk/trafficcone001a.mdl", -- hl2
		mat = "models/mat_jack_gmod_trafficcone",
		clr = {
			r = 240,
			g = 120,
			b = 0
		},
		slots = {
			head = .7,
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(.85, .85, .85),
		pos = Vector(-3.5, 15.5, 0),
		ang = Angle(-90, 18, 0),
		wgt = 4,
		dur = 10,
		mskmat = "mats_jack_gmod_sprites/one-quarter-from-top-blocked.png",
		ent = "ent_jack_gmod_ezarmor_trafficcone"
	},
	["Light-Vest"] = {
		PrintName = "Vest-Light",
		mdl = "models/player/armor_paca/paca.mdl", -- tarkov
		slots = {
			chest = .45,
			abdomen = .35
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1.05, .9),
		pos = Vector(-2.5, -4.5, 0),
		ang = Angle(-90, 0, 90),
		wgt = 5,
		dur = 250,
		storage = 5,
		ent = "ent_jack_gmod_ezarmor_ltorso",
		gayPhysics = true
	},
	["Medium-Light-Vest"] = {
		PrintName = "Vest-Medium-Light",
		mdl = "models/player/armor_trooper/trooper.mdl", -- tarkov
		slots = {
			chest = .6,
			abdomen = .4
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, .95),
		pos = Vector(-3, -6, 0),
		ang = Angle(-90, 0, 90),
		wgt = 10,
		dur = 450,
		storage = 5,
		ent = "ent_jack_gmod_ezarmor_mltorso",
		gayPhysics = true
	},
	["Medium-Vest"] = {
		PrintName = "Vest-Medium",
		mdl = "models/player/armor_gjel/gjel.mdl", -- tarkov
		slots = {
			chest = .7,
			abdomen = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-2.5, -7, 0),
		ang = Angle(-90, 0, 90),
		wgt = 20,
		dur = 625,
		storage = 5,
		ent = "ent_jack_gmod_ezarmor_mtorso",
		gayPhysics = true
	},
	["Medium-Heavy-Vest"] = {
		PrintName = "Vest-Medium-Heavy",
		mdl = "models/player/armor_6b13_killa/6b13_killa.mdl", -- tarkov
		slots = {
			chest = .8,
			abdomen = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-4.5, -12, 0),
		ang = Angle(-85, 0, 90),
		wgt = 40,
		dur = 725,
		ent = "ent_jack_gmod_ezarmor_mhtorso",
		gayPhysics = true
	},
	["Heavy-Vest"] = {
		PrintName = "Vest-Heavy",
		mdl = "models/jmod/heavy_armor.mdl", -- csgo hydra
		slots = {
			chest = 1,
			abdomen = .9
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(.9, .9, 1),
		pos = Vector(-3, 2.5, 0),
		ang = Angle(-85, 0, 90),
		wgt = 80,
		dur = 900,
		ent = "ent_jack_gmod_ezarmor_htorso"
	},
	["Pelvis-Panel"] = {
		PrintName = "Pelvis Panel",
		mdl = "models/jmod/pelviscover.mdl", -- csgo misc
		slots = {
			pelvis = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Pelvis",
		siz = Vector(1.5, 1.4, 1.8),
		pos = Vector(6, 0, 5),
		ang = Angle(90, -90, 0),
		wgt = 10,
		dur = 350,
		ent = "ent_jack_gmod_ezarmor_spelvis"
	},
	["Light-Left-Shoulder"] = {
		PrintName = "Shoulder-Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlbicep.mdl", -- aegis
		slots = {
			leftshoulder = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_llshoulder"
	},
	["Heavy-Left-Shoulder"] = {
		PrintName = "Shoulder-Heavy (L)",
		mdl = "models/jmod/heavy_left_armor_pad.mdl", -- csgo hydra
		slots = {
			leftshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, -20, 90),
		wgt = 15,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_hlshoulder"
	},
	["Light-Right-Shoulder"] = {
		PrintName = "Shoulder-Light (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrbicep.mdl", -- aegis
		slots = {
			rightshoulder = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, .5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_lrshoulder"
	},
	["Heavy-Right-Shoulder"] = {
		PrintName = "Shoulder-Heavy (R)",
		mdl = "models/jmod/heavy_right_armor_pad.mdl", -- csgo hydra
		slots = {
			rightshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, 20, 90),
		wgt = 15,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_hrshoulder"
	},
	["Left-Forearm"] = {
		PrintName = "Forearm (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlforearm.mdl", -- aegis
		slots = {
			leftforearm = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(0, -90, -50),
		wgt = 10,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_slforearm",
		gayPhysics = true
	},
	["Right-Forearm"] = {
		PrintName = "Forearm (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrforearm.mdl", -- aegis
		slots = {
			rightforearm = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(-.5, 0, .5),
		ang = Angle(0, -90, 50),
		wgt = 10,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_srforearm",
		gayPhysics = true
	},
	["Light-Left-Thigh"] = {
		PrintName = "Thigh-Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlthigh.mdl", -- aegis
		slots = {
			leftthigh = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(-.5, 0, -1.5),
		ang = Angle(90, -85, 110),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_llthigh",
		gayPhysics = true
	},
	["Heavy-Left-Thigh"] = {
		PrintName = "Thigh-Heavy (L)",
		mdl = "models/jmod/heavy_left_thigh_armor.mdl", -- csgo hydra
		slots = {
			leftthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_hlthigh"
	},
	["Light-Right-Thigh"] = {
		PrintName = "Thigh-Light (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrthigh.mdl", -- aegis
		slots = {
			rightthigh = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(.5, 0, 1),
		ang = Angle(90, -95, 80),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_lrthigh",
		gayPhysics = true
	},
	["Heavy-Right-Thigh"] = {
		PrintName = "Thigh-Heavy (R)",
		mdl = "models/jmod/heavy_right_thigh_armor.mdl", -- csgo hydra
		slots = {
			rightthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_hrthigh"
	},
	["Left-Calf"] = {
		PrintName = "Calf (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlcalf.mdl", -- aegis
		slots = {
			leftcalf = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, -.5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_slcalf"
	},
	["Right-Calf"] = {
		PrintName = "Calf (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrcalf.mdl", -- aegis
		slots = {
			rightcalf = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, .5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_srcalf"
	},
	["Hazmat Suit"] = {
		PrintName = "Hazmat Suit",
		mdl = "models/props_junk/cardboard_box003a.mdl",
		mat = "models/bloocobalt/splinter cell/chemsuit/chemsuit_bm",
		lbl = "EZ HAZMAT SUIT",
		clr = {
			r = 200,
			g = 175,
			b = 0
		},
		clrForced = false,
		slots = {
			eyes = 1,
			mouthnose = 1,
			head = 1,
			chest = 1,
			abdomen = 1,
			pelvis = 1,
			leftthigh = 1,
			leftcalf = 1,
			rightthigh = 1,
			rightcalf = 1,
			rightshoulder = 1,
			rightforearm = 1,
			leftshoulder = 1,
			leftforearm = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = 1,
			[DMG_RADIATION] = 1,
			[DMG_ACID] = 1,
			[DMG_POISON] = 1,
			[DMG_SLASH] = .25
		}, NonArmorProtectionProfile),
		resist = {
			[DMG_ACID] = .995,
			[DMG_POISON] = .99999
		},
		chrg = {
			chemicals = 50
		},
		bdg = {
			[1] = 2,
			[2] = 1
		},
		snds = {
			eq = "snd_jack_clothequip.ogg",
			uneq = "snd_jack_clothunequip.ogg"
		},
		plymdl = "models/player_hl2_combine_hazmat.mdl", -- https://steamcommunity.com/sharedfiles/filedetails/?id=243665786&searchtext=splinter+cell+blacklist
		mskmat = "mats_jack_gmod_sprites/vignette_gray.png",
		sndlop = "snds_jack_gmod/mask_breathe.ogg",
		wgt = 15,
		dur = 8,
		ent = "ent_jack_gmod_ezarmor_hazmat"
	},
	["Parachute"] = {
		PrintName = "Parachute",
		mdl = "models/jessev92/resliber/weapons/parachute_backpack_closed_w.mdl",
		clr = {
			r = 83,
			g = 83,
			b = 55
		},
		slots = {
			back = .8
		},
		eff = {
			parachute = {mdl = "models/jessev92/bf2/parachute.mdl", offset = 50, drag = 3}
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1, 1),
		pos = Vector(-3, -50, 0),
		ang = Angle(-90, 0, 90),
		wgt = 30,
		dur = 100,
		ent = "ent_jack_gmod_ezarmor_parachute"
	},
	["Backpack"] = {
		PrintName = "Backpack",
		mdl = "models/jmod/props/backpack_3.mdl",
		clr = {
			r = 50,
			g = 50,
			b = 50
		},
		slots = {
			back = .9
		},
		storage = 30,
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1, 1),
		pos = Vector(-2, 0, 0),
		ang = Angle(-90, 0, 90),
		wgt = 5,
		dur = 100,
		ent = "ent_jack_gmod_ezarmor_backpack"
	},
	["Munition Backpack"] = {
		PrintName = "Munition Backpack",
		mdl = "models/weapons/jautocannonbackpack.mdl",
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		clrForced = true,
		slots = {
			back = .9
		},
		ammoCarryMult = 5,
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(.9, .9, .9),
		pos = Vector(3, 2, 0),
		ang = Angle(-90, 0, 90),
		wgt = 5,
		dur = 100,
		ent = "ent_jack_gmod_ezarmor_munitionbackpack"
	},
	["Pouches"] = {
		PrintName = "Pouches",
		mdl = "models/weapons/w_defuser.mdl",
		slots = {
			waist = .5
		},
		storage = 10,
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine",
		siz = Vector(1, 1, 1),
		pos = Vector(4, -3, 0),
		ang = Angle(-80, 0, 90),
		wgt = 5,
		dur = 50,
		ent = "ent_jack_gmod_ezarmor_pouch"
	},
	["Flamethrower-Tank"] = {
		PrintName = "Flamethrower Tank",
		mdl = "models/weapons/sanic/w_m2_static.mdl",
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		clrForced = true,
		slots = {
			back = 1
		},
		chrg = {
			fuel = 200,
			--gas = 200,
		},
		eff = {
			weapon = "wep_jack_gmod_ezflamethrower",
			explosive = true
		},
		bdg = {
			[1] = 0
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1, 1),
		pos = Vector(0.1, -10.1, -0.5),
		ang = Angle(90, 180, -90),
		wgt = 30,
		dur = 50,
		ent = "ent_jack_gmod_ezarmor_flametank"
	},
	["Radio-Backpack"] = {
		PrintName = "Radio Backpack",
		mdl = "models/jmod/ez_radiopack.mdl",
		clr = {
			r = 255,
			g = 255,
			b = 255
		},
		merge = false,
		clrForced = true,
		slots = {
			back = 1
		},
		--[[chrg = {
			power = 50
		},]]
		eff = {
			--weapon = "radiophone",
			radio = true,
		},
		--[[tgl = {
			eff = {radio = false},
			slots = {
				back = 1
			}
		},]]
		bdg = {
			[1] = 0
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine1",
		siz = Vector(1, 1, 1),
		pos = Vector(7, 7, 0),
		ang = Angle(80, 180, -90),
		wgt = 30,
		dur = 100,
		ent = "ent_jack_gmod_ezarmor_radiobackpack"
	}
}

-- Dynamically generate armor ents
function JMod.GenerateArmorEntities(tbl)
	for class, info in pairs(tbl) do
		if info.noent then continue end
		local armorent = {}
		armorent.Base = "ent_jack_gmod_ezarmor"
		armorent.PrintName = info.PrintName or class
		if info.Spawnable == nil then
			armorent.Spawnable = true
		else
			armorent.Spawnable = info.Spawnable
		end
		armorent.AdminOnly = info.AdminOnly or false
		armorent.Category = info.Category or "JMod - EZ Armor"
		armorent.ArmorName = class
		armorent.ModelScale = info.gayPhysics and nil or info.entsiz -- or math.max(info.siz.x, info.siz.y, info.siz.z)
		scripted_ents.Register(armorent, info.ent)
	end
end

JMod.GenerateArmorEntities(JMod.ArmorTable)

-- support third-party additions to the jmod armor table
local function LoadAdditionalArmor()
	if JMod.AdditionalArmorTable then
		table.Merge(JMod.ArmorTable, JMod.AdditionalArmorTable)
		JMod.GenerateArmorEntities(JMod.AdditionalArmorTable)
	end
end

hook.Add("Initialize", "JMod_LoadAdditionalArmor", LoadAdditionalArmor)

-- support third-party integration of gas-based weapons
function JMod.GetArmorBiologicalResistance(ply, typ)
	local faceResist, skinResist = 0, 0

	if ply.EZarmor then
		for k, armorData in pairs(ply.EZarmor.items) do
			if not armorData.tgl then
				local ArmorInfo = JMod.ArmorTable[armorData.name]

				if ArmorInfo.def and (ArmorInfo.chrg and ArmorInfo.chrg.chemicals and armorData.chrg.chemicals > 0) then
					skinResist = skinResist + (ArmorInfo.def[typ] or 0) * ((ArmorInfo.slots.chest or 0) + (ArmorInfo.slots.abdomen or 0)) / 2
					faceResist = faceResist + (ArmorInfo.def[typ] or 0) * ((ArmorInfo.slots.eyes or 0) + (ArmorInfo.slots.mouthnose or 0)) / 2
				end
			end
		end
	end

	return faceResist, skinResist
end

function JMod.DepleteArmorChemicalCharge(ply, amt)
	local SubtractAmt = amt * JMod.Config.Armor.DegradationMult * math.Rand(.05, .15)

	if ply.EZarmor then
		for k, armorData in pairs(ply.EZarmor.items) do
			local ArmorInfo = JMod.ArmorTable[armorData.name]

			if armorData.chrg and armorData.chrg.chemicals then
				armorData.chrg.chemicals = math.max(armorData.chrg.chemicals - SubtractAmt, 0)

				if armorData.chrg.chemicals <= ArmorInfo.chrg.chemicals * .25 then
					JMod.EZarmorWarning(ply, (ArmorInfo.PrintName or armorData.name).."'s chemical charge is almost depleted!")
				end

				break
			end
		end
	end
end
/*

hook.Add("SetupMove", "JMOD_SLEEP", function(ply, mvd, cmd)
	if not(ply:Alive()) then ply.JMod_IsSleeping = false return end
	local Time = CurTime()
	local Veh = ply:GetVehicle()
	if not((cmd:GetMouseX() < 10) and (cmd:GetMouseY() < 10) and (cmd:GetButtons() == 0) and IsValid(Veh) and IsValid(Veh:GetParent()) and Veh:GetParent().EZrespawnPoint) then
		ply.JModLastLookMoveTime = Time
	end
	if (Time - ply.JModLastLookMoveTime) > 15 then
		ply.JMod_IsSleeping = true
	else
		ply.JMod_IsSleeping = false
	end
end)
*/

--hook.Remove("SetupMove", "JMOD_SLEEP")

--[[hook.Add("SetupMove", "JMOD_DISABLE_JUMP", function(ply, mvd, cmd)
	if mvd:KeyDown(IN_JUMP) and (ply.EZImmobilizationTime and (ply.EZImmobilizationTime > CurTime())) then
		local NewButtons = bit.band(mvd:GetButtons(), bit.bnot(IN_JUMP))
		mvd:SetButtons(NewButtons)
	end
end)]]

hook.Add("Move", "JMOD_ARMOR_MOVE", function(ply, mv)
	local origSpeed = mv:GetMaxSpeed()
	local origClientSpeed = mv:GetMaxClientSpeed()

	if not(ply.IsProne and ply:IsProne()) and ply.EZarmor then
		if ply.EZarmor.speedfrac and ply.EZarmor.speedfrac ~= 1 then
			mv:SetMaxSpeed(origSpeed * ply.EZarmor.speedfrac)
			mv:SetMaxClientSpeed(origClientSpeed * ply.EZarmor.speedfrac)
		end
		if SERVER and IsFirstTimePredicted() then
			if ply:GetNW2Bool("EZparachuting", false) and IsValid(ply.EZparachute) and ply:GetMoveType() ~= MOVETYPE_WALK then
				ply:SetNW2Bool("EZparachuting", false)
			end
		end
	end

	--[[if ply.EZImmobilizationTime and (ply.EZImmobilizationTime > CurTime()) then
		mv:SetMaxSpeed(origSpeed * .01)
		mv:SetMaxClientSpeed(origClientSpeed * .01)
	end]]
end)

if CLIENT then
	function JMod.GetItemInSlot(armorTable, slot)
		if not (armorTable and armorTable.items) then return nil end

		for id, armorData in pairs(armorTable.items) do
			local ArmorInfo = JMod.ArmorTable[armorData.name]
			if ArmorInfo.slots[slot] then return id, armorData, ArmorInfo end
		end

		return nil
	end

	concommand.Add("jmod_ez_toggleeyes", function()
		local ply = LocalPlayer()
		if not (IsValid(ply) and ply:Alive()) then return end
		-- 2 eyes
		ply:ConCommand("jmod_ez_armoraction toggle eyes")
	end)

	local ArmorCommands = {"drop", "toggle", "repair", "recharge"}
	local ArmorNames = {"head", "eyes", "mouthnose", "ears", "leftshoulder", "leftforearm", "leftthigh", "leftcalf", "chest", "back", "waist", "pelvis", "rightshoulder", "rightforearm", "rightthigh", "rightcalf"}

	concommand.Add("jmod_ez_armoraction", function(ply, cmd, args)
		if not(IsValid(ply)) or not(ply:Alive()) then return end
		local action = args[1]
		local slot = args[2]

		if not(action) or not(slot) then return end

		if not isnumber(tonumber(action)) then
			action = table.KeyFromValue(ArmorCommands, action)
		end
		if isnumber(tonumber(slot)) then
			slot = ArmorNames[tonumber(slot)]
		end

		if not(action) then return end
		
		if not(slot) then
			for number, slot in ipairs(ArmorNames) do
				local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(ply.EZarmor, slot)
				if ItemID then
					net.Start("JMod_Inventory")
					net.WriteInt(action, 8)
					net.WriteString(ItemID)
					net.SendToServer()
				end
			end
		else
			local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(ply.EZarmor, slot)
			if not ItemID then
				ply:PrintMessage(HUD_PRINTCENTER, "There's nothing in slot " .. slot)
			else
				net.Start("JMod_Inventory")
				net.WriteInt(action, 8)
				net.WriteString(ItemID)
				net.SendToServer()
			end
		end
	end, function(cmd, params)
		-- Normalizes the string
		params = params:Trim():lower()
		-- Splits the string into an array
		params = string.Explode('%s+',params,true)
		
		local Suggestions = {}

		if #params < 2 then
			for _, action in ipairs(ArmorCommands) do
				if string.find(action, params[1]) then
					table.insert(Suggestions, cmd .. " " .. action)
				end
			end
		else
			for _, slot in ipairs(ArmorNames) do
				if string.find(slot, params[2]) then
					table.insert(Suggestions, cmd .. " " .. params[1] .. " " .. slot)
				end
			end
		end

		return Suggestions

	end, "First argument is action, second arg is slot to apply the action to")
end

-- Debug
--[[
for _, ply in player.Iterator() do
	ply.NextEZarmorTableCopy=0
end
--]]
LoadAdditionalArmor()

-- Sounds
sound.Add({	name = "JMod_ZipLine_Clip",
	channel = CHAN_BODY,
	volume	= 1.0,
	level	= 50,
	pitch	= { 90, 110 },
	sound	= { "npc/combine_soldier/zipline_clip1.ogg", "npc/combine_soldier/zipline_clip2.ogg"}
} )

sound.Add({	name = "JMod_ParaWep_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 100,
	pitch	= { 105, 110 },
	--sound	= {"jessev92/parachute/deploy1.ogg","jessev92/parachute/deploy2.ogg","jessev92/parachute/deploy3.ogg","jessev92/parachute/deploy4.ogg","jessev92/parachute/deploy5.ogg"}
	sound	= {"common/null.ogg"}
})

sound.Add({	name = "JMod_BF2142_Para_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2142/vehicles/parachute_open.ogg"}
})

sound.Add({	name = "JMod_BF2_Para_Deploy",
	channel	= CHAN_BODY,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2/vehicles/parachute_deploy.ogg"}
})

sound.Add({	name = "JMod_BF2_Para_Idle",
	channel	= CHAN_STATIC,
	volume	= 1.0,
	level	= 75,
	pitch	= { 105, 110 },
	sound	= {"jessev92/bf2/vehicles/parachute_ride_loop.wav"}
})

 
local Armor_Index = {}
local Armor_Index_Invert = {}

for k, v in pairs(JMod.ArmorTable) do
	local data = {}
	data.name = k

	if v.chrg then
		data.chrg = {}
		for k, v in pairs(v.chrg) do
			table.insert(data.chrg, k)
		end
	end

	local key = table.insert(Armor_Index, data)
	Armor_Index_Invert[k] = key 
end


function JMod.OptimizeArmorSyncWrite(ply) 
	local armor = ply.EZarmor
	
	// items_amount = uint(5)
	// weight = uint(8) -- we need to send total weight because we cant reach another ply weight
	//					   BUT on client we need weight another ply
	// 		structure
	// id_item = string
	// armor_id = uint
	// col = color without alpha
	// dur = uint
	// tgl = bool
	//

	local items_amount = table.Count(armor.items)
	//print(items_amount)
	net.WriteUInt(items_amount, 5)
	
	for id, item in pairs(armor.items) do
		local ind = Armor_Index_Invert[item.name]
		
		net.WriteString(id)
		net.WriteUInt(ind, 6)
		net.WriteColor(Color(item.col.r, item.col.g, item.col.b), true)
		net.WriteUInt(item.dur, 10)
		net.WriteBool(item.tgl)
		// now send charge values
		if Armor_Index[ind].chrg then
			for k, v in pairs(Armor_Index[ind].chrg) do
				//print(k, v)
				net.WriteUInt(item.chrg[v], 8)
			end
		end

	end
end

function JMod.OptimizeArmorSyncRead(ply)
	local ply_armor = {
		["effects"] 	= {},
		["items"] 		= {},
		["mskmats"] 	= {},
		["speedfrac"] 	=	1,
		["suited"]		=	false,
		["totalWeight"]	=	0,
	}

	local item_amount = net.ReadUInt(5)
	for i = 1, item_amount do
		local id = net.ReadString()
		local item_ind = net.ReadUInt(6)
		local col = net.ReadColor(true)
		local dur = net.ReadUInt(10)
		local tgl = net.ReadBool()

		local ind_data = Armor_Index[item_ind]
		local name = ind_data.name

		local item = {
			id = id,
			col = col,
			dur = dur,
			name = name,
			tgl = tgl,
		}

		if ind_data.chrg then
			item.chrg = {}
			for _, typ in pairs(ind_data.chrg) do
				item.chrg[typ] = net.ReadUInt(8)
			end
		end
		
		// weight
		ply_armor.totalWeight = ply_armor.totalWeight + JMod.ArmorTable[name].wgt

		// effect
		if JMod.ArmorTable[name].eff and !tgl then
			table.Merge(ply_armor.effects, JMod.ArmorTable[name].eff)
		end
		// mask
		if JMod.ArmorTable[name].mskmat and !tgl then
			ply_armor.mskmats[id] = JMod.ArmorTable[name].mskmat
		end

		ply_armor.items[id] = item

	end

	// calc total weight
	if ply.JModInv then
		if ply.JModInv.weight then
			ply_armor.totalWeight = ply_armor.totalWeight + ply.JModInv.weight
		end
	end

	
	//if JMod.Config then
	//	if JMod.Config.Armor then 
			local WeighedFrac = ply_armor.totalWeight / 250
			ply_armor.speedfrac = math.Clamp(1 - (.8 * WeighedFrac * 1), .05, 1)
	//	end
	//end
	return ply_armor
end


function JMod.EZEquipUpdateSend(ply)
	if not ply.EZarmor then return end

	local data = {}

	for id, item in pairs(ply.EZarmor.items) do
		local ind = Armor_Index_Invert[item.name]
		if item.chrg then
			data[id] = {chrg = item.chrg, ind = ind}
		end
	end

	net.Start("JMod_EZEquipUpdate")
	net.WriteUInt(table.Count(data), 5)
	for id, item in pairs(data) do
		net.WriteString(id)
		net.WriteUInt(item.ind, 6)
		for k, v in pairs(Armor_Index[item.ind].chrg) do
			net.WriteUInt(item.chrg[v], 8)
		end
	end
	net.Send(ply)
end

function JMod.EZEquipUpdateRead()
	local count = net.ReadUInt(5)
	local equip = {}
	for i = 1, count do
		local id = net.ReadString()
		local ind = net.ReadUInt(6)
		local chrg = {}

		for _, typ in pairs(Armor_Index[ind].chrg) do
			chrg[typ] = net.ReadUInt(8)
		end

		equip[id] = {chrg = chrg, ind = ind}
	end


	local ply = LocalPlayer()
	if ply.EZarmor then
		for id, data in pairs(equip) do
			if ply.EZarmor["items"][id] then
				ply.EZarmor["items"][id]["chrg"] = data.chrg
			end
		end
	end
end

net.Receive("JMod_EZEquipUpdate", JMod.EZEquipUpdateRead)

/*

function TableToHash(tbl)
    if type(tbl) ~= "table" then
        error("TableToHash ожидает таблицу в качестве аргумента", 2)
    end
    
    local sortedKeys = {}

    for k in pairs(tbl) do
        table.insert(sortedKeys, k)
    end
    
    table.sort(sortedKeys, function(a, b)
        local typeA, typeB = type(a), type(b)

        if typeA ~= typeB then
            return tostring(typeA) < tostring(typeB)
        end
        
        if typeA == "number" then
            return a < b
        elseif typeA == "string" then
            return a < b
        elseif typeA == "boolean" then
            return tostring(a) < tostring(b)
        else
            return tostring(a) < tostring(b)
        end
    end)
    
    local hash = ""

    for _, key in ipairs(sortedKeys) do
        local value = tbl[key]
        local keyType = type(key)
        local valueType = type(value)
        
        hash = hash .. "[" .. keyType .. ":" .. tostring(key) .. "]"
        
        if valueType == "table" then
            hash = hash .. "=" .. TableToHash(value)
        else
            hash = hash .. "=" .. valueType .. ":" .. tostring(value)
        end
        
        hash = hash .. ";"
    end
    
    return util.CRC(hash)
end

*/
// JMod.ArmorCalcHash(playa.EZarmor)
local plyf = player.GetAll()[1]


local function sortTableAlphabetically(t)
    -- Создаем копию таблицы, чтобы не изменять оригинальную
    local sorted = {}
    for i, v in ipairs(t) do
        sorted[i] = v
    end
    
    -- Сортируем копию таблицы
    table.sort(sorted, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    
    return sorted
end

function JMod.ArmorCalcHash(armor_table, ply)
	// need more optimizing armor
	// send hashsum to ply, for sync (checking if have rassinhron)
	// if hashsumm not equal -> request update
	// its passiv check in Think func


	local hash = ""
	if !armor_table then return "0" end

	//local armor_calc = table.Copy(armor_table)

	//armro

	//print(ply)
	//PrintTable(plyf.EZarmor)


	local item_ind = {}

	for k, v in pairs(armor_table.items) do
		table.insert(item_ind, k)
		//print(k)
		//hash = hash .. k
	end
	
	local sorted_tbl = sortTableAlphabetically(item_ind)

	for k, v in pairs(sorted_tbl) do
		//table.insert(item_ind, k)
		//print(k)
		hash = hash .. v
	end

	local fhash  = util.CRC(hash)

	//print(hash, fhash)
	return fhash
end
function JMod.ArmorHashSync(ply)
	local armor = ply.EZarmor
	if !armor then return end
	

	//print(plyf)
	//PrintTable(plyf.EZarmor)

	local hash = string.Left(JMod.ArmorCalcHash(armor, ply),6)
	//print(ply, hash)



	net.Start("JMod_ArmorCheckHash")
	net.WritePlayer(ply)
	net.WriteString(hash)
	net.SendPVS(ply:GetPos())
end

EZ_RequestedSync = false
function JMod.ArmorClientCheckHash()
	local ply = net.ReadPlayer()
	local hash = net.ReadString()

	local need_update = false
	
	//print(plyf)
	//PrintTable(plyf.EZarmor)


	if !ply.EZarmor then need_update = true end
	local cl_hash = string.Left(JMod.ArmorCalcHash(ply.EZarmor, ply), 6)
	
	//print("JMOD ARMOR CHECK HASH", ply, cl_hash, hash, hash != cl_hash , EZ_RequestedSync)

//Pz04J8WwFHi0iZ9fITnJZFH8IUD10OPZ        960480400
//Pz04J8WwFHi0iZ9fITnJZFH8IUD10OPZ        960480400

	if hash != cl_hash then need_update = true end

	if need_update and !EZ_RequestedSync then
		net.Start("JMod_ArmorCheckHash")
		net.SendToServer()
	end

	EZ_RequestedSync = true
end


if CLIENT then
	net.Receive("JMod_ArmorCheckHash", JMod.ArmorClientCheckHash)
else
	net.Receive("JMod_ArmorCheckHash", function(_, ply)
		AddToArmorUpdateQueue(ply)
	end)
end