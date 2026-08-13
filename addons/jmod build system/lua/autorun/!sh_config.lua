AddCSLuaFile()

CreateConVar( "build_jmod", 0, FCVAR_NONE)
CreateConVar( "build_jmod_effects", 1, FCVAR_NONE )
CreateConVar( "build_break", 1, FCVAR_NONE )
CreateConVar( "build_expl_only", 1, FCVAR_NONE )
CreateConVar( "build_use_normal_props",  0, FCVAR_NONE )
CreateConVar( "build_gibs",  3, FCVAR_NONE, "", 0, 6 )

BuildConf = {}
BuildConf.Version = '1.01'

BUILD_NIL   = 0
BUILD_FENCE = 1
BUILD_FOUND = 2
BUILD_WALLS = 3
BUILD_STAIR = 4
BUILD_CEIL  = 5
BUILD_OTHER = 6
BUILD_PLATE = 7
BUILD_DOOR  = 8

BUILD_GATE  = 9

BuildConf.Models = {
    [BUILD_FENCE]   = { 
       "models/jmod_construction/fence01.mdl",
       "models/jmod_construction/fence02.mdl",
    },
    [BUILD_FOUND]   = {
        "models/jmod_construction/foundament01.mdl",
        "models/jmod_construction/foundament02.mdl",
        "models/jmod_construction/foundament03.mdl",
        "models/jmod_construction/foundament04.mdl",
        "models/jmod_construction/foundament05.mdl",

        "models/jmod_construction/ramp01.mdl",
        "models/jmod_construction/ramp02.mdl",
        "models/jmod_construction/ramp03.mdl",

        "models/jmod_construction/halframp01.mdl",
        "models/jmod_construction/halframp02.mdl",
        "models/jmod_construction/halframp03.mdl",

    },
    [BUILD_PLATE] = {
        "models/jmod_construction/floor01.mdl",
        "models/jmod_construction/floor02.mdl",
        "models/jmod_construction/floor03.mdl",
        "models/jmod_construction/floor04.mdl",
        "models/jmod_construction/floor05.mdl",
        "models/jmod_construction/floor06.mdl",
        "models/jmod_construction/floor07.mdl",
    },
    [BUILD_WALLS] = {
        "models/jmod_construction/doorframe01.mdl",
        "models/jmod_construction/doorframe02.mdl",
        "models/jmod_construction/doorframe03.mdl",
        "models/jmod_construction/doorframe04.mdl",
        "models/jmod_construction/wall01.mdl",
        "models/jmod_construction/wall02.mdl",
        "models/jmod_construction/wall03.mdl",
        "models/jmod_construction/wall04.mdl",
        "models/jmod_construction/wall05.mdl",
        "models/jmod_construction/windowbig01.mdl",
        "models/jmod_construction/windowbig02.mdl",
        "models/jmod_construction/windowbig03.mdl",
        "models/jmod_construction/windowsmall01.mdl",
        "models/jmod_construction/windowsmall02.mdl",
        "models/jmod_construction/windowsmall03.mdl",
        "models/jmod_construction/windowthin01.mdl",
        "models/jmod_construction/windowthin02.mdl",
        "models/jmod_construction/windowthin03.mdl",
        "models/jmod_construction/windowthin04.mdl",

        // offsets!!!
        "models/jmod_construction/halfwall01.mdl",
        "models/jmod_construction/halfwall02.mdl",
        "models/jmod_construction/halfwall03.mdl",

    },
    [BUILD_CEIL] = {
        "models/jmod_construction/roof01.mdl",
        "models/jmod_construction/roof02.mdl",
        "models/jmod_construction/roof03.mdl",
    },
    [BUILD_OTHER] = {
        "models/jmod_construction/barricade01.mdl",
        "models/jmod_construction/barricade02.mdl",
        "models/jmod_construction/barricade03.mdl",
        "models/jmod_construction/pillar01.mdl",
        "models/jmod_construction/pillar02.mdl",
        "models/jmod_construction/pillar03.mdl",
        "models/jmod_construction/vasily_bust.mdl",
    },
    [BUILD_STAIR]  = {
        "models/jmod_construction/lstair01.mdl",
        "models/jmod_construction/lstair02.mdl",
        "models/jmod_construction/lstair03.mdl",
        "models/jmod_construction/lstair04.mdl",
        "models/jmod_construction/stair01.mdl",
        "models/jmod_construction/stair02.mdl",
        "models/jmod_construction/ustair01.mdl",
        "models/jmod_construction/ustair02.mdl",
        "models/jmod_construction/ustair03.mdl",
        "models/jmod_construction/ustair04.mdl",
    },
    [BUILD_GATE] = {
        "models/jmod_construction/garagedoor01.mdl",
    }
}

BUILD_USE_ENTS = {
    ["models/jmod_construction/garagedoor01.mdl"] = "prop_ww_door",
}


-- if util.IsValidModel( "models/components/stairs_l2.mdl" ) then
--     // prikoli
--     print("Simple Build System: we have addon 'Building components' - add to config")

--     table.Add( BuildConf.Models[BUILD_STAIR], {
--         "models/components/stairs_u2.mdl",
--         "models/components/stairs_u.mdl",
--         "models/components/stairs_l2.mdl",
--         "models/components/stairs_l.mdl"
--     } )

--     table.Add( BuildConf.Models[BUILD_FOUND], {
--         "models/components/stilted_foundation01.mdl",
--         "models/components/stilted_foundation02.mdl"
--     } )

--     table.Add( BuildConf.Models[BUILD_OTHER], {
--         "models/components/wall_sheet_short01.mdl",
--     } ) 
-- end
 

BUILD_DOOR_OFFSET = Vector(-2.5,-23,-10)//Vector(23,-2.5,-10)
BUILD_DOOR_OFFSET_ANG = Angle()
BUILD_DOORHOLE_OFFSET = {
    ["models/military/doorframe.mdl"] = Vector(19,-2.5,-10),
}

BuildConf.Models[BUILD_DOOR] = {
    {mdl_id = 1, mdl = "models/props_c17/door01_left.mdl", skin = 1},
    {mdl_id = 2, mdl = "models/props_c17/door01_left.mdl", skin = 3},
    {mdl_id = 3, mdl = "models/props_c17/door01_left.mdl", skin = 7},
    {mdl_id = 4, mdl = "models/props_c17/door01_left.mdl", skin = 9},
    {mdl_id = 5, mdl = "models/props_c17/door01_left.mdl", skin = 10},
    {mdl_id = 6, mdl = "models/props_c17/door01_left.mdl", skin = 12},
}

BuildConf.Gibs = {
    [MAT_CONCRETE] = {
        "models/props_debris/tile_wall001a_chunk06.mdl",
        "models/props_debris/tile_wall001a_chunk07.mdl",
        "models/props_debris/prison_wallchunk001a.mdl",
        "models/props_debris/prison_wallchunk001c.mdl",
        "models/props_debris/concrete_spawnchunk001a.mdl",
        "models/props_debris/concrete_spawnchunk001b.mdl",
        "models/props_debris/concrete_spawnchunk001c.mdl",
        "models/props_debris/concrete_spawnchunk001d.mdl",
        "models/props_debris/concrete_spawnchunk001e.mdl",
        "models/props_debris/concrete_spawnchunk001f.mdl",
        "models/props_debris/concrete_spawnchunk001g.mdl",
    },
    [MAT_METAL] = {
        "models/props_c17/oildrumchunk01a.mdl",
        "models/props_c17/oildrumchunk01b.mdl",
        "models/props_c17/oildrumchunk01c.mdl",
        "models/props_c17/oildrumchunk01d.mdl",
        "models/props_c17/oildrumchunk01e.mdl",
    },
    [MAT_GLASS] = {
        "models/gibs/glass_shard01.mdl",
        "models/gibs/glass_shard02.mdl",
        "models/gibs/glass_shard03.mdl",
        "models/gibs/glass_shard04.mdl",
        "models/gibs/glass_shard05.mdl",
        "models/gibs/glass_shard06.mdl",
    },
    [MAT_WOOD] = {
        "models/props_debris/wood_board04a.mdl",
        "models/props_debris/wood_board05a.mdl",
        "models/props_debris/wood_board07a.mdl",
        "models/props_debris/wood_chunk06a.mdl",
        "models/props_debris/wood_chunk05f.mdl",
        "models/props_debris/wood_chunk06c.mdl",
        "models/props_debris/wood_chunk07b.mdl",
        "models/props_debris/wood_chunk08b.mdl",
        "models/props_wasteland/dockplank_chunk01a.mdl",
        "models/props_wasteland/dockplank_chunk01b.mdl",
        "models/props_wasteland/dockplank_chunk01c.mdl",
        "models/props_wasteland/dockplank_chunk01d.mdl",
        "models/props_wasteland/dockplank_chunk01e.mdl",
        "models/props_wasteland/dockplank_chunk01f.mdl",
    }
}

BuildConf.DoorAllowed = {
    -- ["models/props/door5.mdl"] = true, 
    -- ["models/props/door1.mdl"] = true,
    -- ["models/props/door2.mdl"] = true,
    -- ["models/props/door4.mdl"] = true,
    -- ["models/military/doorframe.mdl"] = true,

        ["models/jmod_construction/doorframe01.mdl"] = true,
        ["models/jmod_construction/doorframe02.mdl"] = true,
        ["models/jmod_construction/doorframe03.mdl"] = true,
        ["models/jmod_construction/doorframe04.mdl"] = true,
        ["models/jmod_construction/fence02.mdl"] = true,
}

BuildConf.ModelWithOffset = {
    ["models/components/wall_window_slit.mdl"] = {
        vec = Vector(),
        ang = Angle(0,90,0),
    },

    ["models/military/railing128.mdl"] = {
        vec = Vector(0,-2,-48),
        ang = Angle(0,0,0), 
    },

    ["models/jmod_construction/halfwall01.mdl"] = {
        vec = Vector(0, 0,-40),
        ang = Angle(0,0,0), 
    },

    ["models/jmod_construction/halfwall02.mdl"] = {
        vec = Vector(0,0,-40),
        ang = Angle(0,0,0), 
    },
    ["models/jmod_construction/halfwall03.mdl"] = {
        vec = Vector(0,0,-40),
        ang = Angle(0,0,0), 
    },

    ["models/jmod_construction/halframp01.mdl"] = {
        vec = Vector(0,0,-32),
        ang = Angle(0,0,0), 
    },
    ["models/jmod_construction/halframp02.mdl"] = {
        vec = Vector(0,0,-32),
        ang = Angle(0,0,0), 
    },
    ["models/jmod_construction/halframp03.mdl"] = {
        vec = Vector(0,0,-32),
        ang = Angle(0,0,0), 
    },

    ["models/jmod_construction/garagedoor01.mdl"] = {
        vec = Vector(0,0, -4),
        ang = Angle(0,0,0), 
        
    }
}

if JMod then
    
    BuildConf.RecourceReq = {
        [BUILD_FOUND] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 15,
        },
        [BUILD_STAIR] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
        },
        [BUILD_FENCE] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
        },
        [BUILD_WALLS] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 10,
        },
        [BUILD_PLATE] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 10,
        },
        [BUILD_OTHER] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
        },
        [BUILD_CEIL] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
        },
        [BUILD_DOOR] = {
            [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5
        },
        [BUILD_GATE] = {
            //[JMod.EZ_RESOURCE_TYPES.STEEL] = 20,
            [JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 25,
        }
    }
end
BuildConf.ModelsHullType = {
    [BUILD_FOUND] = { Vector( 63.95, 63.95, 63.95 )	, 	Vector( -63.95, -63.95, -63.95 ) },
    [BUILD_STAIR] = { Vector( 64, 64, 64 )	, 	Vector( -64, -64, -64 ) },
    [BUILD_FENCE] = { Vector( 56.980003356934, 72.251564025879, 88.107238769531 ), Vector( -56.969532012939, -72.251373291016, -50.110000610352 )},
    [BUILD_WALLS] = { Vector( 64, 4, 64 )	, 	Vector( -64, -4, -64 )},
    [BUILD_PLATE] = { Vector( 64, 64, 4 ) , Vector( -64, -64, -4 )	 },
}

BuildConf.ModelsHull = {
    -- ['models/props/stairhalf.mdl']	 = { 	Vector( 32.25, 32.25, 8.2500648498535 )	, 	Vector( -32.25, -32.25, -64.25 )	 },
    -- ['models/props/wall2.mdl']	 = { 	Vector( 64.25, 64.25, 64.25 )	, 	Vector( -64.25, -64.25, -64.25 )	 },
    -- ['models/props/roof1.mdl']	 = { 	Vector( 64.25, 64.25, 12 )	, 	Vector( -64.25, -64.25, -12)	 },
    -- ['models/props/roof2.mdl']	 = { 	Vector( 64.25, 64.25, 24 )	, 	Vector( -64.25, -64.25, -24 )	 },
    -- ['models/props/roof3.mdl']	 = { 	Vector( 64.25, 64.25, 4 )	, 	Vector( -64.25, -64.25, -4 )	 },
    -- ['models/props/roof4.mdl']	 = { 	Vector( 64.25, 64.25, 24)	, 	Vector( -64.25, -64.25, -24)	 },
    -- ['models/props/roof_grate1.mdl']	 = { 	Vector( 64.25, 64.25, 12.249641418457 )	, 	Vector( -64.25, -64.25, -12.25 )	 },
    -- ['models/military/barricade128.mdl']	 = { 	Vector( 64.25, 8.2500019073486, 20.25 )	, 	Vector( -64.25, -8.2500019073486, -20.25 )	 },
    -- ['models/military/barricade64.mdl']	 = { 	Vector( 32.25, 8.2500009536743, 20.25 )	, 	Vector( -32.25, -8.2500009536743, -20.25 )	 },
    -- ['models/props/conc_support1.mdl']	 = { 	Vector( 16.25, 16.25, 64.25 )	, 	Vector( -16.25, -16.25, -64.25 )	 },
    -- ['models/props/conc_support2.mdl']	 = { 	Vector( 32.25, 32.25, 64.25 )	, 	Vector( -32.25, -32.25, -64.25 )	 },
    -- ['models/military/platform3.mdl']	 = { 	Vector( 32.250003814697, 64.25, 4.25 )	, 	Vector( -32.250003814697, -64.25, -4.25 )	 },
    -- ['models/barn/barnwall_half1.mdl']	 = { 	Vector( 64.25, 4.2500028610229, 32.25 )	, 	Vector( -64.25, -4.2500028610229, -32.25 )	 },
    -- ['models/barn/barnwall_half2.mdl']	 = { 	Vector( 64.25, 4.2500028610229, 32.25 )	, 	Vector( -64.25, -4.2500028610229, -32.25 )	 },
    -- ['models/military/railing64.mdl']	 = { 	Vector( 32.25, 2.2500014305115, 16.25 )	, 	Vector( -32.25, -2.2500014305115, -16.25 )	 },
    -- ['models/components/wall_sheet_short01.mdl']	 = { 	Vector( 64, 63.999996185303, 64 )	, 	Vector( -64, -63.999996185303, -64.000007629395 )	 },


    ['models/jmod_construction/barricade01.mdl']	 = { 	Vector( 8.2500019073486, 64.25, 20.25 )	, 	Vector( -8.2500019073486, -64.25, -20.25 )	 },
    ['models/jmod_construction/barricade02.mdl']	 = { 	Vector( 8.2500009536743, 32.25, 20.25 )	, 	Vector( -8.2500009536743, -32.25, -20.25 )	 },
    ['models/jmod_construction/barricade03.mdl']	 = { 	Vector( 4.2500033378601, 64.25, 32.25 )	, 	Vector( -4.2500028610229, -64.25, -32.25 )	 },
    ['models/jmod_construction/pillar01.mdl']	 = { 	Vector( 32.25, 32.25, 64.25 )	, 	Vector( -32.25, -32.25, -64.25 )	 },
    ['models/jmod_construction/pillar02.mdl']	 = { 	Vector( 16.25, 16.25, 64.25 )	, 	Vector( -16.25, -16.25, -64.25 )	 },
    ['models/jmod_construction/pillar03.mdl']	 = { 	Vector( 8.2500009536743, 8.2500009536743, 64.249984741211 )	, 	Vector( -8.2500009536743, -8.2500009536743, -64.249984741211 )	 },
    //['models/jmod_construction/vasily_bust.mdl']	 = { 	Vector( 7.7499995231628, 12.749999046326, 34.250003814697 )	, 	Vector( -8.7496061325073, -12.74676990509, -1.2500001192093 )	 },
    ['models/jmod_construction/vasily_bust.mdl']	 = { 	Vector( 7.7499995231628, 12.749999046326, 0 )	, 	Vector( -8.7496061325073, -12.74676990509, -2 )	 },

    ['models/jmod_construction/roof01.mdl']	 = { 	Vector( 64.25, 64.25, 4.25 )	, 	Vector( -64.25, -64.25, -4.25 )	 },
    ['models/jmod_construction/roof02.mdl']	 = { 	Vector( 64.25, 64.25, 36.249996185303 )	, 	Vector( -64.25, -64.25, -4.25 )	 },
    ['models/jmod_construction/roof03.mdl']	 = { 	Vector( 64.250007629395, 64.25, 36.25 )	, 	Vector( -64.250007629395, -64.25, -4.2500042915344 )	 },
    ['models/jmod_construction/garagedoor01.mdl']    = {    Vector( 4.0000457763672, 128, 128 )     ,       Vector( -248, -128, -4 )         },

}

BuildConf.HP = {
    [BUILD_FENCE] = 500,
    [BUILD_FOUND]= 800,
    [BUILD_WALLS]= 500,
    [BUILD_STAIR]= 400,
    [BUILD_CEIL] = 500,
    [BUILD_OTHER]= 400,
    [BUILD_PLATE] = 400,
}

CreateConVar( "build_hp_found", BuildConf.HP[BUILD_FOUND], FCVAR_NONE,"", 100, 5000 )
CreateConVar( "build_hp_fence", BuildConf.HP[BUILD_FENCE], FCVAR_NONE, "",100, 5000 )
CreateConVar( "build_hp_wall", BuildConf.HP[BUILD_WALLS], FCVAR_NONE, "",100, 5000 )
CreateConVar( "build_hp_stair", BuildConf.HP[BUILD_STAIR], FCVAR_NONE, "",100, 5000 )
CreateConVar( "build_hp_roof", BuildConf.HP[BUILD_CEIL], FCVAR_NONE, "",100, 5000 )
CreateConVar( "build_hp_other", BuildConf.HP[BUILD_OTHER], FCVAR_NONE,"", 100, 5000 )
CreateConVar( "build_hp_plate", BuildConf.HP[BUILD_PLATE], FCVAR_NONE, "",100, 5000 )

WALL_T =  4.2
PLATE_T = 4

BuildConf.CategModels = {}

for k, v in pairs(BuildConf.Models) do
    for kk, vv in pairs(v) do
        BuildConf.CategModels[vv] = k 
    end
end

function BuildGetCateg(str)
    return BuildConf.CategModels[str]
end

function BuildGetModelID(mod, skn)
    local categ = BuildGetCateg(mod)
    if !categ then return 0, 0 end
    for k, v in pairs(BuildConf.Models[categ]) do
        if istable(v) then
            if v.m == mod and v.s == skn then
                return categ, k
            end
        else
            if v == mod then 
                return categ, k
            end
        end
    end

    return 0, 0
end

print("Simple build system version: "..BuildConf.Version)

if CLIENT then return end

-- for k, v in pairs(BuildConf.Models) do
--     for kk, vv in pairs(v) do
--         if k != BUILD_GATE  then continue end
--         local a = ents.Create("prop_physics")
--         a:SetModel(vv)
--         a:Spawn()

--         local max, min = a:OBBMaxs(), a:OBBMins()

--         local s1 = "Vector( "..max.x..", "..max.y..", "..max.z.." )"
--         local s2 = "Vector( "..min.x..", "..min.y..", "..min.z.." )"
 
--         print("['"..vv.."']"," = { ", s1, ", ",s2, " },") 
--         a:Remove() 

--     end
-- end

 
hook.Add("PhysgunPickup", "BuildDoor", function(ply, ent)
    if ent:GetClass() == "build_prop" then return false end
end)

if CLIENT then
    print("BuildMode Populate tool menu 1")

    hook.Add( "AddToolMenuTabs", "build_tooltab", function()
        spawnmenu.AddToolTab( "Options", "Options", "icon16/wrench.png" )
    end )

    
    hook.Add("PopulateToolMenu", "Simple Build System", function()
        spawnmenu.AddToolMenuOption("Options", "Simple Build System", "SBS", "Server settings", "", "", function(panel)
            panel:ClearControls()
            panel:NumSlider("Gibs amount", "build_gibs", 0, 6, 0)
            panel:CheckBox("Destroyable?", "build_break")
            panel:ControlHelp("If on you can damage props, break, and they can fall")

            panel:CheckBox("Damaged by only explosion", "build_expl_only")
            panel:ControlHelp("If OFF you can kill a house with fists(why?)")

            panel:CheckBox("Use normal props for building", "build_use_normal_props")
            panel:ControlHelp("If ON then builder will be creating normal prop")

            if JMod != nil then
                panel:CheckBox("Use JMod effects", "build_jmod_effects")
                panel:ControlHelp("If you have JMod, you can add some additional effects")
                panel:CheckBox("Need JMod resources for creating a prop", "build_jmod")
                panel:ControlHelp("Resources(ceramica) are now needed to create a prop (Recipe editor coming soon...)")
            end

            panel:NumSlider("HP Foundation", "build_hp_found", 100, 5000, 0)
            panel:NumSlider("HP Wall", "build_hp_wall", 100, 5000, 0)
            panel:NumSlider("HP Stairs", "build_hp_stair", 100, 5000, 0)
            panel:NumSlider("HP Roof", "build_hp_roof", 100, 5000, 0)
            panel:NumSlider("HP Fence", "build_hp_fence", 100, 5000, 0)
            panel:NumSlider("HP Other", "build_hp_other", 100, 5000, 0)
            panel:NumSlider("HP Plate", "build_hp_plate", 100, 5000, 0)
        end)
    end)

end