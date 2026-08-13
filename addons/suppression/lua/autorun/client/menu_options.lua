local function PopulateSBXToolMenu(pnl)
    pnl:CheckBox("Suppression Enabled", "suppression_enabled")
    pnl:ControlHelp("Enable or disable the suppression entierly.")

    pnl:CheckBox("Suppression Enabled", "suppression_self_suppress")
    pnl:ControlHelp("Suppress yourself, because you're the greatest enemy to yourself.")

    pnl:CheckBox("Viewpunch Enabled", "suppression_viewpunch")
    pnl:ControlHelp("Enable or disable the viewpunch.")

    pnl:CheckBox("Sharpen Enabled", "suppression_sharpen")
    pnl:ControlHelp("Enable or disable the sharpen.")

    pnl:CheckBox("Blur Enabled", "suppression_blur")
    pnl:ControlHelp("Enable or disable the blur.")

    pnl:CheckBox("Bloom Enabled", "suppression_bloom")
    pnl:ControlHelp("Enable or disable the bloom. Very performance heavy!")

    pnl:CheckBox("Gasp Enabled", "suppression_gasp_enabled")
    pnl:ControlHelp("Enable or disable the gasp.")

    pnl:CheckBox("Work in Vehicles Enabled", "suppression_enable_vehicle")
    pnl:ControlHelp("Enable or disable suppression in vehicles.")

    pnl:NumSlider("Blur Style", "supression_blur_style", 0, 1, 0)
    pnl:ControlHelp("0 - General blur, 1 - Broken DOF blur")

    pnl:NumSlider("Suppression Buildup", "suppression_buildupspeed", 0, 3, 1)
    pnl:ControlHelp("Suppression effect buildup speed intensity value")
    
    pnl:NumSlider("Blur Intensity", "supression_blur_intensity", 0, 3, 1)
    pnl:ControlHelp("Suppression blur intensity value")
    
    pnl:NumSlider("Viewpunch Intensity", "suppression_viewpunch_intensity", 0, 3, 1)
    pnl:ControlHelp("Suppression viewpunch effect intensity value")

    pnl:NumSlider("Sharpen Intensity", "suppression_sharpen_intensity", 0, 3, 1)
    pnl:ControlHelp("Suppression sharpen effect intensity value")

    pnl:NumSlider("Bloom Intensity", "suppression_bloom_intensity", 0, 3, 1)
    pnl:ControlHelp("Suppression bloom effect intensity value")
end

if engine.ActiveGamemode() == "sandbox" or engine.ActiveGamemode() == "darkrp" then
    hook.Add("AddToolMenuCategories", "SupressionMenuAdd", function() 
        spawnmenu.AddToolCategory("Options", "Suppression", "Suppression")
    end)

    hook.Add("PopulateToolMenu", "SupressionMenu", function() 
        spawnmenu.AddToolMenuOption("Options", "Suppression", "SuppressionSettings", "Settings", "", "", function(pnl)
            pnl:ClearControls()
            PopulateSBXToolMenu(pnl)
        end)
    end)
end