AddCSLuaFile("economic.lua")
AddCSLuaFile("economic_config.lua")
AddCSLuaFile("economic_init.lua")
AddCSLuaFile("autorun/client/graph.lua")
AddCSLuaFile("autorun/client/derma.lua")
AddCSLuaFile("autorun/client/cl_init.lua")
AddCSLuaFile("warehouse.lua")
AddCSLuaFile("autorun/client/cl_warehouse.lua")
  
 
if SERVER then
    local trend_t = {  
        [B_DOWN] = "down",
        [B_BASE] = "base",
        [B_UP] =   "up",
    }    

    local autocompl_items    = {}

    for k, v in pairs(ECONOMIC_CONFIG) do
        table.insert(autocompl_items, v[1]["index"])
    end

    local function autocompl_info(cmd, par, part)
        local cmdcom = table.Copy(autocompl_items)
        local findt = {}

        if #part > 0 then
            local st = 0
            for k, v in pairs(cmdcom) do
                st = string.find(v, string.Trim(part[1]))
                if st then table.insert(findt, v) end
            end

            for k, v in pairs(findt) do
                findt[k] = cmd.." "..v
            end
        end

        return findt
    end

    local function autocompl_chstock(cmd, par, part)
        local cmdcom = table.Copy(autocompl_items)
        table.insert(cmdcom, "*")
        local findt = {}

        if #part > 0 then
            local st = 0
            for k, v in pairs(cmdcom) do
                st = string.find(v, string.Trim(part[1]))
                if st then table.insert(findt, v) end
            end

            for k, v in pairs(findt) do
                findt[k] = cmd.." "..v
            end
        end

        if #part > 1 then
            if #findt == 1 then
                return {
                    findt[1].." up",
                    findt[1].." base",
                    findt[1].." down",
                }
            end
        end

        return findt
    end

    local function SyncAllPlys()
        if !ECONOMIC then return end
        for _, plys in pairs(player.GetAll()) do
            ECONOMIC:ForceSyncPly(plys)
        end
    end

    concommand.Add("jmod_ez_econ_force_sync", function(ply)
        //if !ply:IsAdmin() then return end 
        if ECONOMIC then
            print("ECONOMIC: forcing all players to syncing with servers")
            SyncAllPlys()
        end
    end, nil, "Force all player to synchronise economic with server")

    concommand.Add("jmod_ez_econ_info", function(ply, str, arg)
        //if !ply:IsAdmin() then ply:ConCommand("help jmod_ez_econ_info") return end 
        if ECONOMIC then
            if #arg == 0 then ply:ConCommand("help jmod_ez_econ_info") return end
            local index = arg[1]
            if ECONOMIC:GetIndex(index) then
                local item = ECONOMIC.Items[index]
                print("ECONOMIC: info about "..arg[1])
                print("Price: ", item.price, "\tmed price: ", item.med_price,"\tdef price: ",item.price_opt.def_price)
                print("Current trend: ",trend_t[item.status],"\tnext change: ", item.next_change )
                print("Econ day: ", ECONOMIC.EconTime)
            end
        end
    end, autocompl_info, "usable: jmod_ez_econ_info [index]\n Get info, status about item")

    concommand.Add("jmod_ez_econ_buy", function(ply, str, arg)
        //if !ply:IsAdmin() then ply:ConCommand("help jmod_ez_econ_info") return end 
        if ECONOMIC then
            if #arg != 2 then ply:ConCommand("help jmod_ez_econ_info") return end
            local index = arg[1]
            local amnt  = tonumber(arg[2])
            print("buy", index, amnt)
            if ECONOMIC:GetIndex(index) then
                ECONOMIC:ItemBuy(index, amnt)
            end

        end
    end, autocompl_info, "usable: jmod_ez_econ_buy [index] [amnt]\n BUY")

    concommand.Add("jmod_ez_econ_sell", function(ply, str, arg)
        //if !ply:IsAdmin() then ply:ConCommand("help jmod_ez_econ_info") return end 
        if ECONOMIC then
            if #arg != 2 then ply:ConCommand("help jmod_ez_econ_info") return end
            local index = arg[1]
            local amnt  = tonumber(arg[2])
            print("sell", index, amnt)
            if ECONOMIC:GetIndex(index) then
                ECONOMIC:ItemSell(index, amnt)
            end

        end
    end, autocompl_info, "usable: jmod_ez_econ_buy [index] [amnt]\n BUY")


    concommand.Add("jmod_ez_econ_change_trend", function(ply, str, arg)
        if !ply:IsAdmin() then return end 
        if ECONOMIC then
            if #arg >= 2 then
                local index, trend = string.upper(arg[1]), string.lower(arg[2])
                if autocompl_items[index] or index != "*" then return end
                trend = table.Flip(trend_t)[trend]
                if !trend then return end
                local day = math.Clamp(tonumber(arg[3]) or 50, 1, 200)
                print("ECONOMIC: force "..(index == "*" and "ALL" or index).." to "..trend_t[trend].." for "..day.." days")
                if index == "*" then
                    for k, v in pairs(ECONOMIC.Items) do
                        ECONOMIC.Items[k].status = trend
                        ECONOMIC.Items[k].last_change = ECONOMIC.EconTime
                        ECONOMIC.Items[k].next_change = ECONOMIC.EconTime + day
                    end
                else 
                    ECONOMIC.Items[index].status = trend
                    ECONOMIC.Items[index].last_change = ECONOMIC.EconTime
                    ECONOMIC.Items[index].next_change = ECONOMIC.EconTime + day
                end
                
                for _, plys in pairs(player.GetAll()) do
                    ECONOMIC:ForceSyncPly(plys)
                end
            else
                ply:ConCommand("help jmod_ez_econ_change_trend")
            end
        end
    end, autocompl_chstock, "usable: jmod_ez_econ_change_trend [index] [base|up|down] (day)\n Set force trend for item. If 3 arg is nil, days is 50, force sync all plys")

    concommand.Add("jmod_ez_econ_reset", function(ply, str, arg)
        if !ply:IsAdmin() then return end 
        if ECONOMIC then
            print("ECONOMIC: reseting...")
            timer.Remove("ECON_TIME")
            ECONOMIC:Setup()
            AddItemsInEconomic()
            ECONOMIC:Start()
            SyncAllPlys()
        end
    end, autocompl_chstock, "reset economics on server")


    hook.Add("PlayerInitialSpawn", "EconForceSync", function(ply)
        ECONOMIC:ForceSyncPly(ply)
    end)

end
