if true then return end

BuildConf = {}

BUILD_NIL   = 0
BUILD_FENCE = 1
BUILD_FOUND = 2
BUILD_WALLS = 3
BUILD_STAIR = 4
BUILD_CEIL  = 5
BUILD_OTHER = 6
BUILD_PLATE = 7
BUILD_DOOR  = 8

BuildConf.Models = {
    --[[
    [BUILD_FENCE]   = { 
        --"models/props/fence1.mdl",
        "models/props/fence2.mdl",
        "models/props/fence3.mdl",
        "models/props/fence4.mdl",
        --"models/props/fence5.mdl",
    },
    [BUILD_FOUND]   = {
        "models/barn/barn_foundation1.mdl",
        "models/barn/barn_foundation2.mdl",
        "models/barn/barn_foundation3.mdl",
        "models/barn/barn_foundation4.mdl",
        --"models/props/foundation01.mdl",
        --"models/props/foundation02.mdl",
        --"models/props/foundation9.mdl",
        "models/military/platform1.mdl",
        "models/components/stilted_foundation02.mdl"
    },
    [BUILD_PLATE] = {
        "models/barn/barn_floor.mdl",
        "models/military/platform5.mdl",
    },
    [BUILD_WALLS] = {
        --"models/props/wall1.mdl",
        --"models/props/wall3.mdl",
        --"models/props/wall4.mdl",
        "models/props/wall5.mdl",
        "models/props/window1.mdl",
        "models/components/wall_window_slit.mdl",
        --"models/props/window2.mdl",
        --"models/props/window3.mdl",
        --"models/props/window4.mdl",
        --"models/props/window5.mdl",
        --"models/military/metalwalling.mdl",
        --"models/military/windowbig.mdl", 
        --"models/props/door1.mdl",
        --"models/props/door2.mdl",
        --"models/props/door4.mdl",
        "models/props/door5.mdl",
        "models/military/glasspane.mdl",

    },
    --]]
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
        "models/jmod_construction/ramp04.mdl",
        "models/jmod_construction/halframp01.mdl",
        "models/jmod_construction/halframp02.mdl",
        "models/jmod_construction/halframp03.mdl",
        "models/jmod_construction/halframp04.mdl",

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
    },
    [BUILD_CEIL] = {
        "models/jmod_construction/roof01.mdl",
        "models/jmod_construction/roof02.mdl",
        "models/jmod_construction/roof03.mdl",
    },
    [BUILD_OTHER] = {
        "models/fortification collection/hedgehog_big.mdl",
        "models/props_c17/FurnitureTable002a.mdl",
        "models/props_c17/shelfunit01a.mdl",
        "models/jmod_construction/pillar01.mdl",
        "models/jmod_construction/pillar02.mdl",
        "models/jmod_construction/pillar03.mdl",
        "models/jmod_construction/barricade01.mdl",
        "models/jmod_construction/barricade02.mdl",
        "models/jmod_construction/barricade03.mdl",
        "models/jmod_construction/halfwall01.mdl",
        "models/jmod_construction/halfwall02.mdl",
        "models/jmod_construction/halfwall03.mdl",
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
    }
}

--[[
[BUILD_FENCE]   = { 
        "models/props/fence1.mdl",
        "models/props/fence2.mdl",
        "models/props/fence3.mdl",
        "models/props/fence4.mdl",
        "models/props/fence5.mdl",
    },
    [BUILD_FOUND]   = {
        "models/barn/barn_foundation1.mdl",
        "models/barn/barn_foundation2.mdl",
        "models/barn/barn_foundation3.mdl",
        "models/barn/barn_foundation4.mdl",
        "models/props/foundation01.mdl",
        "models/props/foundation02.mdl",
        "models/props/foundation9.mdl",
        "models/military/platform1.mdl",
    },
    [BUILD_PLATE] = {
        "models/barn/barn_floor.mdl",
        "models/military/platform5.mdl",
        "models/military/platform2.mdl",
        "models/props/floor1.mdl",
        "models/props/floor2.mdl"
    },
    [BUILD_WALLS] = {
        "models/props/wall1.mdl",
        "models/props/wall3.mdl",
        "models/props/wall4.mdl",
        "models/props/wall5.mdl",
        "models/props/window1.mdl",
        "models/props/window2.mdl",
        "models/props/window3.mdl",
        "models/props/window4.mdl",
        "models/props/window5.mdl",
        "models/military/metalwalling.mdl",
        "models/military/windowbig.mdl", 
        "models/props/door1.mdl",
        "models/props/door2.mdl",
        "models/props/door4.mdl",
        "models/props/door5.mdl",
        "models/military/doorframe.mdl",
        "models/military/glasspane.mdl",

    },
--]]

BUILD_DOOR_OFFSET = Vector(23,-2.5,-10)
BUILD_DOORHOLE_OFFSET = {
    ["models/military/doorframe.mdl"] = Vector(19,-2.5,-10),
}

BuildConf.Models[BUILD_DOOR] = {
    {m = "models/props_c17/door01_left.mdl", s = 1},
    {m = "models/props_c17/door01_left.mdl", s = 3},
    {m = "models/props_c17/door01_left.mdl", s = 7},
    {m = "models/props_c17/door01_left.mdl", s = 9},
    {m = "models/props_c17/door01_left.mdl", s = 10},
    {m = "models/props_c17/door01_left.mdl", s = 12},
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
--[[
BuildConf.DoorAllowed = {
    ["models/props/door5.mdl"] = true 
}
    --]]
BuildConf.DoorAllowed = {
    ["models/props/door5.mdl"] = true, 
    ["models/props/door1.mdl"] = true,
    ["models/props/door2.mdl"] = true,
    ["models/props/door4.mdl"] = true,
    ["models/military/doorframe.mdl"] = true,
}

BuildConf.ModelWithOffset = {
    ["models/components/wall_window_slit.mdl"] = {
        vec = Vector(),
        ang = Angle(0,90,0),
    }
}

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
        [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
    },
    [BUILD_OTHER] = {
        [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
    },
    [BUILD_CEIL] = {
        [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5,
    },
    [BUILD_DOOR] = {
        [JMod.EZ_RESOURCE_TYPES.CERAMIC] = 5
    }
}

BuildConf.ModelsHullType = {
    [BUILD_FOUND] = { Vector( 64, 64, 64 )	, 	Vector( -64, -64, -64 ) },
    [BUILD_STAIR] = { Vector( 64, 64, 64 )	, 	Vector( -64, -64, -64 ) },
    [BUILD_FENCE] = { Vector( 56.980003356934, 72.251564025879, 81.107238769531 ), Vector( -56.969532012939, -72.251373291016, -81.110000610352 )},
    [BUILD_WALLS] = { Vector( 64, 4.2500028610229, 64 )	, 	Vector( -64, -4.2500028610229, -64 )},
    [BUILD_PLATE] = { Vector( 64, 64, 4 ) , Vector( -64, -64, -4 )	 },
}

BuildConf.ModelsHull = {
    ['models/jmod_construction/foundament01.mdl']    = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/foundament02.mdl']    = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/foundament03.mdl']    = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/foundament04.mdl']    = {    Vector( 64.250007629395, 64.250007629395, 64.25 )       ,       Vector( -64.25, -64.25, -64.25 )        },
    ['models/jmod_construction/foundament05.mdl']    = {    Vector( 64.250007629395, 64.250007629395, 64.25 )       ,       Vector( -64.250007629395, -64.250007629395, -64.25 )    },
    ['models/jmod_construction/ramp01.mdl']  = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/ramp02.mdl']  = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/ramp03.mdl']  = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -64.25, -64.25, -64.25 )         },
    ['models/jmod_construction/ramp04.mdl']  = {    Vector( 64.250007629395, 64.250007629395, 64.25 )       ,       Vector( -64.25, -64.250007629395, -64.25 )      },
    ['models/jmod_construction/halframp01.mdl']      = {    Vector( 64.249977111816, 64.25, 32.25 ) ,       Vector( -64.25, -64.25, -32.25 )         },
    ['models/jmod_construction/halframp02.mdl']      = {    Vector( 64.249977111816, 64.25, 32.25 ) ,       Vector( -64.25, -64.25, -32.25 )         },
    ['models/jmod_construction/halframp03.mdl']      = {    Vector( 64.249977111816, 64.25, 32.25 ) ,       Vector( -64.25, -64.25, -32.25 )         },
    ['models/jmod_construction/halframp04.mdl']      = {    Vector( 64.249977111816, 64.250007629395, 32.25 )       ,       Vector( -64.250007629395, -64.250007629395, -32.250003814697 )  },
    ['models/jmod_construction/roof01.mdl']  = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/roof02.mdl']  = {    Vector( 64.25, 64.25, 36.249996185303 ) ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/roof03.mdl']  = {    Vector( 64.250007629395, 64.25, 36.25 ) ,       Vector( -64.250007629395, -64.25, -4.2500042915344 )   },
    ['models/jmod_construction/wall01.mdl']  = {    Vector( 4.2500033378601, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.25, -64.25 )       },
    ['models/jmod_construction/wall02.mdl']  = {    Vector( 4.2500033378601, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.25, -64.25 )       },
    ['models/jmod_construction/wall03.mdl']  = {    Vector( 4.2500028610229, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.25, -64.25 )       },
    ['models/jmod_construction/wall04.mdl']  = {    Vector( 4.2500033378601, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.25, -64.25 )       },
    ['models/jmod_construction/wall05.mdl']  = {    Vector( 4.2500033378601, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.25, -64.25 )       },
    ['models/jmod_construction/windowbig01.mdl']     = {    Vector( 6.0000019073486, 64.250007629395, 64.250007629395 )     ,       Vector( -4.2500028610229, -64.250007629395, -64.250007629395 )  },
    ['models/jmod_construction/windowbig02.mdl']     = {    Vector( 6.0000019073486, 64.250007629395, 64.250007629395 )     ,       Vector( -4.2500028610229, -64.250007629395, -64.250007629395 )  },
    ['models/jmod_construction/windowbig03.mdl']     = {    Vector( 4.2500033378601, 64.25, 64.250007629395 )       ,       Vector( -4.2500023841858, -64.25, -64.25 )      },
    ['models/jmod_construction/windowsmall01.mdl']   = {    Vector( 6.0000019073486, 64.250007629395, 64.250007629395 )     ,       Vector( -4.2500028610229, -64.250007629395, -64.250007629395 )  },
    ['models/jmod_construction/windowsmall02.mdl']   = {    Vector( 6.0000019073486, 64.250007629395, 64.250007629395 )     ,       Vector( -4.2500028610229, -64.250007629395, -64.250007629395 )  },
    ['models/jmod_construction/windowsmall03.mdl']   = {    Vector( 4.2500033378601, 64.25, 64.250007629395 )       ,       Vector( -4.2500023841858, -64.25, -64.25 )      },
    ['models/jmod_construction/windowthin01.mdl']    = {    Vector( 6.0000019073486, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.250007629395, -64.25 )    },
    ['models/jmod_construction/windowthin02.mdl']    = {    Vector( 6.0000019073486, 64.25, 64.25 ) ,       Vector( -4.2500028610229, -64.250007629395, -64.25 )    },
    ['models/jmod_construction/windowthin03.mdl']    = {    Vector( 4.2500038146973, 64.250007629395, 64.250015258789 )     ,       Vector( -4.2500038146973, -64.250007629395, -64.25 )    },
    ['models/jmod_construction/windowthin04.mdl']    = {    Vector( 4.2500038146973, 64.250007629395, 64.25 )       ,       Vector( -4.2500042915344, -64.25, -64.25 )      },
    ['models/jmod_construction/floor01.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor02.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor03.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor04.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor05.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor06.mdl']         = {    Vector( 64.25, 64.25, 4.25 )    ,       Vector( -64.25, -64.25, -4.25 )  },
    ['models/jmod_construction/floor07.mdl']         = {    Vector( 64.25, 64.25, 4.2500042915344 ) ,       Vector( -64.25, -64.25, -4.2500042915344 )     },
    ['models/jmod_construction/fence01.mdl']         = {    Vector( 32.250003814697, 72.249992370605, 88.25 )       ,       Vector( -8.2500028610229, -72.249992370605, -72.25 )    },
    ['models/jmod_construction/fence02.mdl']         = {    Vector( 32.250003814697, 72.249992370605, 88.25 )       ,       Vector( -8.2500028610229, -72.249992370605, -72.25 )    },
    ['models/jmod_construction/lstair01.mdl']        = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -56.250003814697, -56.250003814697, -64.25 )   },
    ['models/jmod_construction/lstair02.mdl']        = {    Vector( 64.25, 64.25, 64.25 )   ,       Vector( -56.250003814697, -56.250003814697, -64.25 )   },
    ['models/jmod_construction/lstair03.mdl']        = {    Vector( 64.25, 56.25, 64.25 )   ,       Vector( -56.250003814697, -64.25, -64.25 )       },
    ['models/jmod_construction/lstair04.mdl']        = {    Vector( 64.25, 56.25, 64.25 )   ,       Vector( -56.250003814697, -64.25, -64.25 )       },
    ['models/jmod_construction/stair01.mdl']         = {    Vector( 64.25, 32.25, 64.25 )   ,       Vector( -64.25, -32.25, -64.25 )         },
    ['models/jmod_construction/stair02.mdl']         = {    Vector( 64.25, 32.25, 64.25 )   ,       Vector( -64.25, -32.25, -64.25 )         },
    ['models/jmod_construction/ustair01.mdl']        = {    Vector( 64.25, 56.250011444092, 64.25 ) ,       Vector( -64.250007629395, -56.250003814697, -64.25 )    },
    ['models/jmod_construction/ustair02.mdl']        = {    Vector( 64.25, 56.250011444092, 64.25 ) ,       Vector( -64.250007629395, -56.250003814697, -64.25 )    },
    ['models/jmod_construction/ustair03.mdl']        = {    Vector( 64.25, 56.25, 64.25 )   ,       Vector( -64.250007629395, -56.250003814697, -64.25 )   },
    ['models/jmod_construction/ustair04.mdl']        = {    Vector( 64.25, 56.25, 64.25 )   ,       Vector( -64.250007629395, -56.250003814697, -64.25 )   },
    ['models/fortification collection/hedgehog_big.mdl']     = {    Vector( 36.543258666992, 39.847927093506, 39.850982666016 )     ,       Vector( -36.543258666992, -39.84782409668, -39.849945068359 )   },
    ['models/props_c17/FurnitureTable002a.mdl']      = {    Vector( 20.070127487183, 33.9914894104, 18.926160812378 )       ,       Vector( -20.005672454834, -34.180370330811, -18.443807601929 )  },
    ['models/props_c17/shelfunit01a.mdl']    = {    Vector( 39.486999511719, 10.500003814697, 93.125244140625 )     ,       Vector( -39.486988067627, -10.500001907349, 93 )         },
    ['models/jmod_construction/pillar01.mdl']        = {    Vector( 32.25, 32.25, 64.25 )   ,       Vector( -32.25, -32.25, -64.25 )         },
    ['models/jmod_construction/pillar02.mdl']        = {    Vector( 16.25, 16.25, 64.25 )   ,       Vector( -16.25, -16.25, -64.25 )         },
    ['models/jmod_construction/pillar03.mdl']        = {    Vector( 8.2500009536743, 8.2500009536743, 64.249984741211 )     ,       Vector( -8.2500009536743, -8.2500009536743, -64.249984741211 )  },
    ['models/jmod_construction/barricade01.mdl']     = {    Vector( 8.2500019073486, 64.25, 20.25 ) ,       Vector( -8.2500019073486, -64.25, -20.25 )     },
    ['models/jmod_construction/barricade02.mdl']     = {    Vector( 8.2500009536743, 32.25, 20.25 ) ,       Vector( -8.2500009536743, -32.25, -20.25 )     },
    ['models/jmod_construction/barricade03.mdl']     = {    Vector( 4.2500033378601, 64.25, 32.25 ) ,       Vector( -4.2500028610229, -64.25, -32.25 )     },
    ['models/jmod_construction/halfwall01.mdl']      = {    Vector( 4.2500028610229, 64.25, 24.25 ) ,       Vector( -4.2500023841858, -64.25, -24.25 )     },
    ['models/jmod_construction/halfwall02.mdl']      = {    Vector( 4.2500028610229, 64.25, 24.25 ) ,       Vector( -4.2500023841858, -64.25, -24.25 )     },
    ['models/jmod_construction/halfwall03.mdl']      = {    Vector( 4.2500028610229, 64.25, 24.25 ) ,       Vector( -4.2500028610229, -64.25, -24.25 )     },
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

if CLIENT then return end


--[[for k, v in pairs(BuildConf.Models) do
    for kk, vv in pairs(v) do
        --if k != BUILD_FENCE then continue end
        if not isstring(vv) then continue end
        local a = ents.Create("prop_physics")
        a:SetModel(vv)
        a:Spawn()

        local max, min = a:OBBMaxs(), a:OBBMins()

        local s1 = "Vector( "..max.x..", "..max.y..", "..max.z.." )"
        local s2 = "Vector( "..min.x..", "..min.y..", "..min.z.." )"
 
        print("['"..vv.."']"," = { ", s1, ", ",s2, " },") 
        a:Remove()

    end
end]]


