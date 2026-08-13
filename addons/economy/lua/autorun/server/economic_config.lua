ECON_DAY           = 3
ECON_SAVE_PRICES   = 20

WH_SEND = 0
WH_BUY  = 1
WH_SELL = 2
WH_UPD  = 3
 
WH_RESTRICTED_TO_BUY = {
    //["fissile material"] = true,
    //["uranium"] = true,
    //["fuel"] = true,
}

ECON_CANT_OVERLOAD = {
    // uran or smth
}

ECON_MAX_PRICE = {
    ["Metals"]      = 10,
    ["Resources"]  = 8,
    ["Other"]       = 10,
}

ECON_AMOUNT_BORDER = {
    ["Metals"]      = 0.2,
    ["Resources"]   = 0.4,
    ["Other"]       = 0.5,
}


ECONOMIC_CONFIG = {
    {
        {       // item_struct
            index       = "STEL",
            name        = "steel",
            categ       = "Metals",
        },
        {
            base_price  = 3,
            min_price   = 0.5,
            spikes      = 0.4,

            supply_time = 1,
            supply_amount = 150,

        }
    },
    {
        {       // item_struct
            index       = "APRT",
            name        = "advanced parts",
            categ       = "Resources",
        },
        {
            base_price  = 10,
            min_price   = 1,
            spikes      = 0.2,

            supply_time = 2,
            supply_amount = 100,
            // cant_produce = true
        }
    },
    /*
    {
        {
            index       = "APRT",
            name        = "advanced parts",
            categ       = "Resources",
        },
        {
            min_price   = 5,
            spikes      = 0.1
        }
    },
*/
    
    {
        {
            index       = "ATXT",
            name        = "advanced textiles",
            categ       = "Resources",
        },
        {
            base_price  = 5,
            min_price   = 1,
            spikes      = 0.2,

            supply_time = 2,
            supply_amount = 75,
        }
    },
    {
        {
            index       = "BPRT",
            name        = "basic parts",
            categ       = "Resources",
        },
        {
            base_price  = 5,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 100,
        }
    },
    {
        {
            index       = "CHEM",
            name        = "chemicals",
            categ       = "Resources",
        },
        {
            base_price  = 8,
            min_price   = 1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 40,
        }
    },
    
    {
        {
            index       = "COPR",
            name        = "copper",
            categ       = "Metals",
        },
        {
            base_price  = 4,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 70,
        }
    },
    { 
        {
            index       = "FISL",
            name        = "fissile material",
            categ       = "Other",
        },
        {
            base_price  = 100,
            min_price   = 500,
            spikes      = 0.1,
            cant_produce = true
        }
    },
    
    {
        {
            index       = "FUEL",
            name        = "fuel",
            categ       = "Resources",
        },
        {
            base_price  = 5,
            min_price   = 0.2,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    
    {
        {
            index       = "GAS",
            name        = "gas",
            categ       = "Resources",
        },
        {

            base_price  = 3,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    {
        {
            index       = "GOLD",
            name        = "gold",
            categ       = "Metals",
        },
        {
            base_price  = 15,
            min_price   = 5,
            spikes      = 0.2,
            supply_time = 2,
            supply_amount = 50,

        }
    },
    {
        {
            index       = "MED",
            name        = "medical supplies",
            categ       = "Resources",
        },
        {
            base_price  = 6,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    
    {
        {
            index       = "AMMO",
            name        = "ammo",
            categ       = "Other",
            ent_name    = "ent_jack_gmod_ezammo",
        },

        {
            base_price  = 8,
            min_price   = 1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    {
        {
            index       = "MUNI",
            name        = "munitions",
            categ       = "Other",
            ent_name    = "ent_jack_gmod_ezmunitions",
        },
        {
            base_price  = 10,
            min_price   = 2,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 25,
        }
    },
    {
        {
            index       = "EXPL",
            name        = "explosives",
            categ       = "Resources",
            ent_name    = "ent_jack_gmod_ezexplosives",
        },
        {
            base_price  = 3,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    
    {
        {
            index       = "CLTH",
            name        = "cloth",
            categ       = "Resources",
            ent_name    = "ent_jack_gmod_ezcloth",
        },
        {
            base_price  = 4,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 100,
        }
    },
    {
        {
            index       = "OIL",
            name        = "oil",
            categ       = "Resources",
        },
        {
            base_price  = 8,
            min_price   = 1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 75,
        }
    },
    {
        {
            index       = "ORGN",
            name        = "organics",
            categ       = "Resources",
        },
        {
            base_price  = 1,
            min_price   = 0.1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 120,
        }
    },
    {
        {
            index       = "PAPR",
            name        = "paper",
            categ       = "Resources",
        },
        {
            base_price  = 1,
            min_price   = 0.1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 150,

        }
    },
    {
        {
            index       = "PLST",
            name        = "plastic",
            categ       = "Resources",
        },
        {
            base_price  = 1,
            min_price   = 0.1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 150,
        }
    },
    
    {
        {
            index       = "PPRT",
            name        = "precision parts",
            categ       = "Resources",
        },
        {
            base_price  = 15,
            min_price   = 5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 75,
        }
    },
    {
        {
            index       = "PRLT",
            name        = "propellant",
            categ       = "Resources",
        },
        {
            base_price  = 5,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 80,
        }
    },
    
    {
        {
            index       = "RUBR",
            name        = "rubber",
            categ       = "Resources",
        },
        {
            base_price  = 4,
            min_price   = 0.5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 90,
        }
    },
    {
        {
            index       = "SILV",
            name        = "silver",
            categ       = "Metals",
        },
        {
            base_price  = 12,
            min_price   = 5,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 30,
        }
    },
    {
        {
            index       = "TUNG",
            name        = "tungsten",
            categ       = "Metals",
        },
        {
            base_price  = 7,
            min_price   = 2,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 50,
        }
    },
    {
        {
            index       = "WOOD",
            name        = "wood",
            categ       = "Resources",
        },
        {
            base_price  = 1.5,
            min_price   = 0.1,
            spikes      = 0.2,
            supply_time = 1,
            supply_amount = 100,
        }
    },
    {
        {
            index       = "URAN",
            name        = "uranium",
            categ       = "Metals",
        },
        {
            base_price  = 5,
            min_price   = 10,
            spikes      = 0.1,
            cant_produce = true,
        }
            
    },
    
}
