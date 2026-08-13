//
//  Squad.Warehouse = {}
//  Squad.Warehouse = {
//      [JMOD_GOLD] = 50,
//
// }

//                MAX RESOURCE CAP = ~100000 on one item


local WAREHOUSE_MAX_CAP = 5000
local WAREHOUSE_MAX_BUY = 500
local WAREHOUSE_CD = 5

if CLIENT then return end

util.AddNetworkString("warehouse_update")
util.AddNetworkString("warehouse_actions")
util.AddNetworkString("warehouse_act_notify")



hook.Add("SquadMenu_SquadCreated", "SetSquadWarehouse", function(id, squad)
    squad.Warehouse = {}
    squad.WarehouseCD = 0

    
    squad.LastTrade = 0

    // time, item_id, amount, fin price, fee if have
    squad.HistoryTrade = {}

    print("WAREHOUSE: Setup warehouse for squad ", id)
end)

hook.Add("SquadMenu_OnJoinedSquad", "UpdateWarehouse", function(id, ply)
    local squad = SquadMenu:GetSquad(id)
    local ware = squad.Warehouse or {}

    net.Start("warehouse_update")
    net.WriteUInt(table.Count(ware), 8)
    for id, amnt in pairs(ware) do
        net.WriteUInt(id, 8)
        net.WriteUInt(amnt, 20)
    end
    net.Send(ply)
end)

hook.Add("SquadMenu_OnLeftSquad", "UpdateWarehouse", function(id, ply)
    // simply send clean list
    net.Start("warehouse_update")
    net.WriteUInt(0, 8)
    net.Send(ply)
end)

hook.Add("WarehouseUpdated", "UpdateWarehouse", function(id)
    local squad = SquadMenu:GetSquad(id)
    local plys = squad:GetActiveMembers()

    local ware = squad.Warehouse or {}

    //print("WAREHOUSE: some cargo has been updated!")
    //PrintTable(ware)

    for _, ply in ipairs(plys) do
        net.Start("warehouse_update")
        net.WriteUInt(table.Count(ware), 8)
        for id, amnt in pairs(ware) do
            net.WriteUInt(id, 8)
            net.WriteUInt(amnt, 20)
        end
        net.Send(ply)
    end
end)

local function convert_keyitems(items)
    local arr = {}
    for item, amnt in pairs(items) do
        //local id = item
        if JMod.IndexToResource[item] then
            arr[item] = amnt
        elseif JMod.ResourceToIndex[item] then
            arr[JMod.ResourceToIndex[item]] = amnt 
        end
    end

    return arr
end

local function fastsale(ply, item, amnt)
    local money = GAMEMODE:CalcJBuxWorth({[JMod.IndexToResource[item]] = amnt})
    GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + money)
end

// trade_data {itemid, amount, price, typ}
// главная цель - определить спекулянта и забрать у него деньги
// игроки также смогут в долгосрочные сделки
-- function CalcFee(squadid, trade_data)
--     // before making trade
--     local squad = SquadMenu:GetSquad()
--     local history = squad.HistoryTrade

--     // забрать прибыль у спекулянтов
--     // определить сделку как спекулятивная
--     if trade_data.typ == "sell" then
--         // поиск в истории покупок такого же материала по дешевлее
--         // если такое есть режэм прибыль
--         local amount_h      = 0
--         local med_price_h   = 0

--         for k, old_trade in pairs(history) do
--             if old_trade.itemid == trade_data.itemid and old_trade.typ == "buy" then
--                 amount_h = 
--             end
--         end
--     end
-- end


function CalcFee(squadid, trade_data)
    local squad = SquadMenu:GetSquad(squadid)
    local history = squad.HistoryTrade

    local relevant_trades = {}
    for _, t in ipairs(history) do
        if t.itemid == trade_data.itemid then
            local k = table.insert(relevant_trades, t)
            //relevant_trades[k].price_u = t.price / t. 
        end
    end
    
    local trades_prices = {
        buy = {
            t_amnt    = 0,
            t_price     = 0,
            t_price_u     = 0,
            trades      = {}
        }, 
        sell = {
            t_amnt    = 0,
            t_price     = 0,
            t_price_u     = 0,

            trades      = {}
        }
    }


    //PrintTable()
    

    for _, trade in pairs(relevant_trades) do
        -- local tp = trade[trade.typ]
        -- tp.t_ammt = tp.t_amnt + trade.amnt
        -- tp.t_price  = tp.t_price  + trade.price
        -- tp.t_price_u = tp.t_price_u + trade.price_u

        local tp = table.Copy(trade)
        trades_prices[trade.type].t_amnt = (trades_prices[trade.type].t_amnt or 0) + trade.amnt
        trades_prices[trade.type].t_price  = (trades_prices[trade.type].t_price or 0) + trade.price
        trades_prices[trade.type].t_price_u =  (trades_prices[trade.type].t_price_u or 0) + trade.amnt *  trade.price_u //(trades_prices[trade.type].t_price_u or 0) + trade.price_u


        //PrintTable(trade)
        table.insert(trades_prices[trade.type]["trades"], tp)     
    end

    for k, v in pairs(trades_prices) do
        //v.avg_price = #v.trades > 0 and( v.t_price / #v.trades) or 0
        //v.avg_price_u = #v.trades > 0 and(v.t_price_u / #v.trades) or 0
        
        v.avg_price = 0
        v.avg_price_u = 0

        if #v.trades > 0 then
            v.avg_price = v.t_price  / #v.trades
        end

        if #v.trades > 0 then
            //print(v.t_price_u  , v.t_amnt)
            v.avg_price_u = v.t_price_u  / v.t_amnt
        end
        
    end

    //PrintTable(trades_prices)
    //PrintTable(trades_prices)
    //PrintTable(trade_data)
    local speculative = false
    local profit = 0
    if trade_data.type == "buy" then
        // dont know
    elseif trade_data.type == "sell" then
        local buy_t = trades_prices.buy 
        if buy_t.avg_price_u > 0 then
            // if more than 1.2 than specul
            //print( )
            //print(buy_t.avg_price_u, trade_data.price_u, trade_data.price_u / buy_t.avg_price_u )
            if buy_t.avg_price_u < trade_data.price_u and buy_t.avg_price_u * 1.3 < trade_data.price_u then
                profit = (trade_data.price_u  - buy_t.avg_price_u) * trade_data.amnt
                speculative = true  
            end
        end
    end

    if speculative then
        //print("SPECULATIVE TRADE", profit)
        return profit * 0.5
    end
    return 0
end


local SAVE_TIME_TRADE = 1 * 30
function SanitizeHistoryTrade(squadid)
    // clear history if they old
    local squad = SquadMenu:GetSquad(squadid)
    local history = squad.HistoryTrade

    for k, t in pairs(history) do
        if t.time + SAVE_TIME_TRADE < CurTime() then
            table.remove(history, k)
        end 
    end
end

function WarehouseAdd(squadid, item, amnt, ply)
    local squad = SquadMenu:GetSquad(squadid)

    // check is real
    if type(item) == "table" then
        local items = convert_keyitems(item)
        for k, v in pairs(items) do
            WarehouseAdd(squadid, k, v, ply)
        end
    else
        amnt = math.floor(amnt)
        if JMod.ResourceToIndex[item] then
            item = JMod.ResourceToIndex[item]
        elseif !JMod.IndexToResource[item] then
            print("WAREHOUSE: trying add ", tostring(item), tostring(JMod.IndexToResource[item]) )
            return 
        end
 
        local wh_size = WarehouseGetSize(squadid)

        local ost = WAREHOUSE_MAX_CAP - (wh_size + amnt)
        local tosell = 0 // if we dont have space in wh, sell amnt

        if ost < 0 then
            tosell = math.Clamp(math.abs(ost), 0, amnt)
            amnt = amnt + ost
        end

        if amnt > 0 then 
            if squad.Warehouse[item] then
                squad.Warehouse[item] = squad.Warehouse[item] + amnt
            else
                squad.Warehouse[item] = amnt
            end
        end

        squad.Warehouse[item] = math.floor(squad.Warehouse[item])

        if tosell > 0 then
            print(item, tosell, "TOSELL")
            fastsale(ply, item, tosell)
        end

    end
    hook.Run("WarehouseUpdated", squadid )
end

function WarehouseGet(squadid, item)
    local squad = SquadMenu:GetSquad(squadid)
    if type(item) == "string" and JMod.ResourceToIndex[item] then
        item = JMod.ResourceToIndex[item]
    end
    return squad.Warehouse[item] or 0
end

local function CalcCD(amnt) // if buy more, you need more()
    if amnt < 100 then return 3
    elseif amnt < 300 then return 4
    elseif amnt < 500 then return 6
    else return 8 end 
end

function WarehouseGetSize(squadid)
    local squad = SquadMenu:GetSquad(squadid)
    
    local size = 0
    for k, v in pairs(squad.Warehouse) do
        size = size + v
    end

    return size
end

function WarehouseSub(squadid, item, amnt)
    local squad = SquadMenu:GetSquad(squadid)

    if type(item) == "string" and JMod.ResourceToIndex[item] then
        item = JMod.ResourceToIndex[item]
    end

    if squad.Warehouse[item] then
        if squad.Warehouse[item] - amnt >= 0 then
            squad.Warehouse[item] = squad.Warehouse[item] - amnt
        else
            print("WAREHOUSE - tried to sub big amount resurce from wh")
            print(item)
            print("wh = ",squad.Warehouse[item], "sub = ", amnt )
            debug.Trace()
            return false
        end
    else
        return false
    end
    
    squad.Warehouse[item] = math.floor(squad.Warehouse[item])

    if squad.Warehouse[item] == 0 then
        squad.Warehouse[item] = nil
    end
    hook.Run("WarehouseUpdated", squadid )
end


function WarehouseBuy(ply, squadid, itemid, amnt, radio)
    if WH_RESTRICTED_TO_BUY[JMod.IndexToResource[itemid]] then 
        // cant buy shit
        return
    end

    local squad = SquadMenu:GetSquad(squadid)

    local wh_size = WarehouseGetSize(squadid)

    if wh_size >= WAREHOUSE_MAX_CAP then return false, "На складе кончилось место." end
    if WAREHOUSE_MAX_CAP - (wh_size + amnt) < 0 then
        amnt = amnt - (WAREHOUSE_MAX_CAP - (wh_size + amnt))
    end

    if amnt == 0 then return false, "На складе кончилось место." end
  
            
    local for_calc = {[JMod.IndexToResource[itemid]] = amnt}
    //PrintTable(for_calc)

    local price = GAMEMODE:CalcJBuxWorth({[JMod.IndexToResource[itemid]] = amnt}) * (1 + ((squad.Loan.Debt or 0) / 100))

    local money = GAMEMODE:GetJBux(ply) 

    if !(money - price >= 0) then return false, "Не хватает денег." end
    local success = hook.Run("EconItemBuy", JMod.IndexToResource[itemid], amnt)
    
    if !success then return false , "Ресурса в таком количестве нет на рынке" end

    GAMEMODE:SetJBux(ply, money - price)
    WarehouseAdd(squadid, itemid, amnt, ply)

    squad.LastTrade = CurTime()
    
    //add to history
    SanitizeHistoryTrade(squadid)
    
    
    
    local key = table.insert(squad.HistoryTrade, {
        itemid  = itemid,
        amnt    = amnt,
        price   = price,
        price_u = price / amnt,
        time    = CurTime(),
        type    = "buy",
    })



    return true,  "Покупка "..tonumber(amnt).." "..JMod.IndexToResource[itemid].. "." 
end

// old
-- function WarehouseSell(ply, squadid, itemid, amnt, radio)
--     //
--     // daem dengi
--     //
--     //if WarehouseSub(squadid, itemid, amnt) != false then

--     local squad = SquadMenu:GetSquad(squadid)
    
--     //    print(itemid, amnt)
--     //PrintTable(squad.Warehouse)

--     amnt = math.floor(amnt)
--     if amnt == 0 then return false, "Неправильное количество" end
    
--     if squad.Warehouse[itemid] then
--         if squad.Warehouse[itemid] >= amnt then
--             local success = hook.Run("EconItemSell", JMod.IndexToResource[itemid], amnt)

--             if !success then
--                 return false, "Не удалось продать ресурс - предложений слишком много!"
--             end

--             local money = GAMEMODE:CalcJBuxWorth({[JMod.IndexToResource[itemid]] = amnt})

--             GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + money)

--             WarehouseSub(squadid, itemid, amnt)

--             return true, "Продажа "..tonumber(amnt).." "..JMod.IndexToResource[itemid].. "." 
--         end
--     end
--     return false, "Не хватает ресурсов!"
--     //WarehouseSub(squadid, itemid, amnt)
-- end


function WarehouseSell(ply, squadid, itemid, amnt, radio)
    local squad = SquadMenu:GetSquad(squadid)

    if squad.Warehouse[itemid] then
        if squad.Warehouse[itemid] >= amnt then
            local success = hook.Run("EconItemSell", JMod.IndexToResource[itemid], amnt)

            if !success then
                return false, "Не удалось продать ресурс - предложений слишком много!"
            end
            
            WarehouseSub(squadid, itemid, amnt)
            local money = GAMEMODE:CalcJBuxWorth({[JMod.IndexToResource[itemid]] = amnt})
            GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + money)

            squad.LastTrade = CurTime()
            
            //add to history
            
            SanitizeHistoryTrade(squadid)
            local key = table.insert(squad.HistoryTrade, {
                itemid  = itemid,
                amnt    = amnt,
                price   = money,
                price_u = money / amnt,
                time    = CurTime(),
                type    = "sell",
            })


            local fee = CalcFee(squadid, squad.HistoryTrade[key] )
            print(fee)
            if fee > 0 then
                local money = GAMEMODE:GetJBux(ply) 
                GAMEMODE:SetJBux(ply, money - fee)

            end

            print("WAREHOUSE: selling ", JMod.IndexToResource[itemid], amnt, "FOR ", money)
            return true, "Продажа "..tonumber(amnt).." "..JMod.IndexToResource[itemid].. "." 
        end
    end

    return false, "Не хватает ресурсов!"
end

function WarehouseSend(ply, squadid, itemid, amnt, radio)
    if !IsValid(radio) or !ply then return end

    local squad = SquadMenu:GetSquad(squadid)

    if GetGlobalVar("NuclearWar") then 
        radio:Speak("Поставки временно прекращены из-за применения ядерного оружия.") 
        return false 
    end 

    if squad.Warehouse[itemid] >= amnt then
        if JMod.EZ_RADIO_STATIONS[radio:GetOutpostID()].state ==  JMod.EZ_STATION_STATE_READY then
            radio:Speak(JMod.EZradioRequest(radio, radio:GetOutpostID(), ply, "custom", false, {[itemid]= amnt})) 
            WarehouseSub(squadid, itemid, amnt)
        end
    end
end

--[[
function WarehouseSendMult(ply, squadid, zakaz, radio)
    if !IsValid(radio) or !ply then return end

    local squad = SquadMenu:GetSquad(squadid)

    JMod.EZradioRequest(Entity(79), 1, ply, "custom", false, skib) 
end
--]]

local function WHSendNotify(ply, radio, txt)
    // poka cherez radio
    if IsValid(radio) then
        radio:Speak(txt)
    end
end

net.Receive("warehouse_actions",function(_, ply)
    local radio     = net.ReadEntity()
    local act       = net.ReadUInt(3)
    local itemid    = net.ReadUInt(8)
    local amnt      = net.ReadUInt(20)

    local squadid = ply:GetSquadID()
    local squad = SquadMenu:GetSquad(squadid)

    //print("WAREHOUSE: new action", act, itemid,amnt, WH_SEND)

    if squad.WarehouseCD == nil then
        squad.WarehouseCD = 0
        // notify: "otdohni on komputera
    end

    //if squad.WarehouseCD > CurTime() then
    //    WHSendNotify(ply, radio, "Склад занят, попытайтесь в другой раз.")
    //    return
    //end

    local succes, msg
    if act == WH_BUY then
        succes, msg = WarehouseBuy(ply, squadid, itemid, amnt, radio)
    elseif act == WH_SELL then
        succes, msg = WarehouseSell(ply, squadid, itemid, amnt, radio)
    elseif act == WH_SEND then
        // send fulton to ply
        succes, msg = WarehouseSend(ply, squadid, itemid, amnt, radio)
    elseif act == WH_UPD then
    end

    if msg then
        WHSendNotify(ply, radio, msg)
    end
    if succes then
        SquadMenu:GetSquad(squadid).WarehouseCD = CurTime() + CalcCD(amnt)
    end
end)

--[[local radio = Entity(79)
local zakaz = {
    [JMod.ResourceToIndex["gold"]] --= 50,
--}
--[[
concommand.Add("getposilka", function(ply)
    local skib = {
        [JMod.ResourceToIndex["gold"]]-- = 50,
    --[[]}
    JMod.EZradioRequest(Entity(79), 1, ply, "custom", false, skib) 
end)
--]]