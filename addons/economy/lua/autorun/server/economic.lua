local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

if SERVER then
    util.AddNetworkString("econ_sync")
    util.AddNetworkString("econ_init")
end

ECONOMIC = {}
ECONOMIC_QUEUE_SYNC = {}
ECONOMIC_CL_REQUESTED_SYNC = false

local ECON_NET_INDEX = {}
local ECON_NET_INDEX_INVERT = {}

local pregen_start  = 30
//local SAVE_PRICES   = 20
local base_spikes   = 0.2

B_DOWN      = -1
B_BASE      = 0
B_UP        = 1

local genrand = {  
    B_DOWN,
    B_BASE,
    B_UP
}

local MAX_PRICE = 100000
local MAX_ITEM_CAP = 20000


local function FloatRand(min, max)
    return Lerp(math.random(), min, max)
end

local trends = {
    [B_DOWN] = function(item)
        // nothing
        //if !item.price_opt.supply_amount then return end
        //item.amount = item.amount - math.floor(math.random(, 1) * item.price_opt.supply_amount)

        if !item.price_opt.supply_amount then return end
        item.amount = item.amount - math.floor(FloatRand(0.1, 0.5) * item.price_opt.supply_amount / item.price_opt.supply_time)
    end,
    
    [B_BASE] = function(item)
        if !item.price_opt.supply_amount then return end
        item.amount = item.amount - math.floor(FloatRand(0.1, 1.5) * item.price_opt.supply_amount / item.price_opt.supply_time)
    end,
    [B_UP] = function(item)
        if !item.price_opt.supply_amount then return end

        item.amount = item.amount - math.floor(FloatRand(1, 2.5) * item.price_opt.supply_amount / item.price_opt.supply_time)
    end,
    
}


local function push_to_end(t, a, max)
    if #t < max then
        t[#t+1] = a
        return
    end
    for i = 1, #t-1 do
        t[i] = t[i+1]
    end
    t[#t] = a
end

function ECONOMIC:Setup()
    self.Items      = {}
    self.Prices     = {}
    self.Started    = false
    self.EconTime   = 0

    self.fast_alias = {}
    self.BufferAdd = {}
    self.BufferSub = {}

end

function ECONOMIC:Start()
    --print("ECONOMIC START")
    self:GeneratePrice(20, true)

    for k, item in pairs(self.Items) do
        item.status = B_BASE

        item.last_change = self.EconTime
        item.next_change = self.EconTime + math.ceil(util.SharedRandom(k, 4, 10))
    end

    timer.Create("ECON_TIME", ECON_DAY, 0, function()
        self:GeneratePrice()
    end)
end


function ECONOMIC:CheckPrices(ind)
    // if prices is very big, force down syt
    local item = self.Items[ind]
    if item.med_price / item.price_opt.base_price >= ECON_CATEG_LIMITS[item.item.categ] or item.price >= MAX_PRICE then
        //print("ITEM", item.item.name, " IS VERY EXPENSIVE, FORCE DOWN TREND")
        item.status = B_DOWN
        item.last_change = self.EconTime
        item.next_change = self.EconTime + 50 //this should be enough for the price to fall
        return true
    elseif item.med_price <= item.price_opt.min_price or item.price == 0.01 then
        // dont know need it to add?
        item.status = B_UP
        item.last_change = self.EconTime
        item.next_change = self.EconTime + math.ceil(util.SharedRandom("next"..ind..tostring(self.EconTime), 4, 40))
        return true
    end
end


function ECONOMIC:ItemSupplyAdd(item)
    if item.price_opt.cant_produce then return end
    if self.BufferAdd[item.item.index] > 0 then return end

    item.time_to_supply = item.time_to_supply - 1
    if item.time_to_supply > 0 then return end

    //local amount = item.amount
    local supply = item.price_opt.supply_amount

    //if item.crisis_time != nil and item.crisis_time > 0  then
    //    supply = supply + math.random(300, 500)
    //end

    //if amount => MAX_ITEM_CAP then return end

    item.amount = math.Clamp(item.amount + supply, 0, MAX_ITEM_CAP) 

    item.time_to_supply = item.price_opt.supply_time
end

local BUFFER_RELEASE_ADD = 400
local BUFFER_RELEASE_SUB  = 400

function ECONOMIC:ItemBufferAdd(item)
    local index = item.item.index
    //print("ITEM BUFFER ADD", self.BufferAdd[index])
    if self.BufferAdd[index] == 0 then return end

    local buffer_amount = self.BufferAdd[index]
    local amount_add = math.Clamp(buffer_amount, 0, BUFFER_RELEASE_ADD)

    item.amount = math.Clamp(item.amount + amount_add, 0, MAX_ITEM_CAP)

    self.BufferAdd[index] = math.Clamp(self.BufferAdd[index] - amount_add, 0, MAX_ITEM_CAP)
end

function ECONOMIC:ItemBufferSub(item)
    local index = item.item.index
   // print("ITEM BUFFER SUB", self.BufferSub[index])

    if self.BufferSub[index] == 0 then return end

    local buffer_amount = self.BufferSub[index]
    local amount_sub = math.Clamp(buffer_amount, 0, BUFFER_RELEASE_SUB)

    item.amount = math.Clamp(item.amount - amount_sub, 0, MAX_ITEM_CAP)

    self.BufferSub[index] = math.Clamp(self.BufferSub[index] - amount_sub, 0, MAX_ITEM_CAP)
end

function ECONOMIC:ItemSupplyTrendCalc(item)
    if item.next_change <= self.EconTime then
        item.last_change = self.EconTime
        item.next_change = item.last_change + math.random(4,10)

        local new_trend = table.Copy(genrand)

        table.RemoveByValue(new_trend, item.status)

        item.status = table.Random(new_trend)
        
    end

    trends[item.status](item)

    item.amount = math.Clamp(item.amount,0, MAX_ITEM_CAP)


    if item.amount > MAX_ITEM_CAP - 1000 then
        item.last_change = self.EconTime
        item.next_change = item.last_change + 30

        item.status = B_UP
    end
end

local function LerpPrice(fraction, from, to)
	return Lerp(math.ease.InSine(fraction), from, to)
end

function ECONOMIC:ItemCalcPrice(item)
    local amount = item.amount
    local categ_amnt_border = ECON_AMOUNT_BORDER[item.item.categ]
    local price;
    
    local fract = amount / MAX_ITEM_CAP 

    local max_price = item.price_opt.base_price * ECON_MAX_PRICE[item.item.categ]
    local min_price = item.price_opt.base_price
    
    price = LerpPrice(1-fract, min_price, max_price )
    
    /*
    if amount / MAX_ITEM_CAP < ECON_AMOUNT_BORDER[item.item.categ] then
        // with function
        local fract = amount / (ECON_AMOUNT_BORDER[item.item.categ] * MAX_ITEM_CAP) 

        local max_price = item.price_opt.base_price * ECON_MAX_PRICE[item.item.categ]
        local min_price = item.price_opt.base_price
        
        price = LerpPrice(1-fract, min_price, max_price )
    else
        // linear
        //local fract = (amount - ECON_AMOUNT_BORDER[item.item.categ] * MAX_ITEM_CAP) / (MAX_ITEM_CAP - ECON_AMOUNT_BORDER[item.item.categ] * MAX_ITEM_CAP)

        //local offset = ECON_AMOUNT_BORDER[item.item.categ] * MAX_ITEM_CAP
        //print(amount )
        local fract = amount / (ECON_AMOUNT_BORDER[item.item.categ] * MAX_ITEM_CAP) - (1 - ECON_AMOUNT_BORDER[item.item.categ])

        local max_price = item.price_opt.base_price
        local min_price = item.price_opt.min_price

        //print(1-fract, min_price, max_price)

        price = Lerp(1-fract, min_price, max_price )
    end
    */
    
    // add some random

    local max = item.price_opt.spikes * item.price_opt.base_price
    local seed = item.item.name..tostring(ECONOMIC.EconTime).."BASE"

    item.price = math.max(math.Truncate( util.SharedRandom(seed, price - max, price + max), 2), 0.01)
    //item.price = math.Truncate(price, 2)


    //return price
end

function ECONOMIC:GeneratePrice(time, prestart)
    time = time or 1
    self.EconTime = self.EconTime + 1


    for i = 1, time do
        for index, item in pairs(self.Items) do
            //print(index, item.price, item.amount)
            
            if SERVER then
                local old_amount = item.amount
                self:ItemSupplyAdd(item)
                self:ItemBufferAdd(item)
                self:ItemBufferSub(item)
                // otskok
                local amount = item.amount
                
                --[[if amount < 500 and item.price_opt.cant_produce == nil and !prestart then
                    local time_to_crisis = item.time_to_crisis
                    local crisis_time    = item.crisis_time

                    // debilnaya logika
                    if crisis_time != nil then   // crisis time
                        if crisis_time == 0 then
                            crisis_time = nil // 
                        else
                            crisis_time = crisis_time - 1
                        end
                    else
                        if time_to_crisis == nil then // not setted
                            time_to_crisis = math.random(10,20)
                        elseif time_to_crisis == 0 then // end, start load economics with resources
                            time_to_crisis = nil
                            crisis_time = math.random(10,25)
                        else
                            time_to_crisis = time_to_crisis - 1
                        end
                    end

                    item.crisis_time = crisis_time
                    item.time_to_crisis = time_to_crisis
                elseif item.time_to_crisis != nil then
                    item.time_to_crisis = nil 
                end]]
                //print(index, item.price)
                if !prestart then
                    self:ItemSupplyTrendCalc(item)
                end

                item.amount = math.Clamp(math.floor(item.amount), 0, MAX_ITEM_CAP)
            end
            
            self:ItemCalcPrice(item)

            push_to_end(self.Prices[index], item.price, ECON_SAVE_PRICES)

        end
    end


    if SERVER then
        self:Syncing()
    end
    
    hook.Run("EconomicUpdatePrices")
end

function ECONOMIC:GetIndex(a)
    // check for aliases
    if self.Items[a] != nil then // is already inde 
        return a
    end

    return self.fast_alias[a]
end

function ECONOMIC:AddNewItem(item_struct, price_opt)
    if self.Started then return end
    
    price_opt.spikes = price_opt.spikes or base_spikes

    local item = {
        item        = item_struct,
        //categ       = item_struct.categ,
        med_price   = price_opt.base_price,
        price       = price_opt.base_price,
        price_opt   = price_opt,
        status      = B_BASE,
        last_change = 0,
        next_change = 0,

        time_to_supply = 0,
        amount = 0,

        crisis_time = nil,
        time_to_crisis = nil,
    }

    //item.price_opt.def_price = default_price

    // add fast aliases
    local index = item_struct.index

    self.Items[index] = item
    self.Prices[index] = {}
    self.BufferAdd[index] = 0
    self.BufferSub[index] = 0


    local ent = item_struct.ent_name or JMod.EZ_RESOURCE_ENTITIES[item_struct.name]
    if ent then
        self.fast_alias[ent] = index
    end
    self.fast_alias[item_struct.name] = index

    ECON_NET_INDEX[index] = table.Count(ECON_NET_INDEX)
    ECON_NET_INDEX_INVERT[ECON_NET_INDEX[index]] = index
end

function ECONOMIC:GetPrice(name, amount)

    local amount = amount or 1
    if CLIENT then
    //print(name, amount, "CALC PRICE", self.Items[index].price * amount)
    end
    // name can be item class,
    local index = self:GetIndex(name)
    
    if !index then 
        print("ECONOMIC: unknown item "..tostring(name))
        //debug.Trace()

        return
    end

    return self.Items[index].price * amount
end

function ECONOMIC:GetHistory(name)
    local index = self:GetIndex(name)
    
    if !index then 
        print("ECONOMIC: unknown item "..tostring(name))
        //debug.Trace()

        return
    end

    return self.Prices[name]
end

function ECONOMIC:GetLastChangeProc(name)
    local index = self:GetIndex(name)
    
    if !index then 
        print("ECONOMIC: unknown item "..tostring(name)) 
        //debug.Trace()

        return
    end

    local sz = #self.Prices[name]

    if sz < 2 then
        return 0
    end

    local p1, p2 = self.Prices[index][sz], self.Prices[index][sz-1]
    local proc = math.Truncate(100 - (p2*100)/p1, 2)

    return proc
end

function ECONOMIC:ItemBuy(name, amount)
    local index = self:GetIndex(name)
    
    amount = math.floor(amount)

    if !index then 
        print("ECONOMIC: unknown item "..tostring(name)) 
        return
    end

    // calc ratio
    local item = self.Items[index]
    
    if item.amount - (amount + self.BufferSub[index]) < 0 then
        return false
    end

    print("ECONOMIC: item buy", amount, item.amount)

    //item.amount = math.Clamp(math.floor(item.amount - amount), 0, MAX_ITEM_CAP)
    //print("AFTER BUYING", item.amount)
    
    
    //if self.Buffer[index] else
        self.BufferSub[index] = math.Clamp(self.BufferSub[index] + amount, 0, MAX_ITEM_CAP)
    //else
    //    self.Buffer[index] = math.Clamp(amount, 0, MAX_ITEM_CAP)
    //end
    return true
end

function ECONOMIC:ItemSell(name, amount)
    local index = self:GetIndex(name)
    
    if !index then 
        print("ECONOMIC: unknown item "..tostring(name)) 
        return false
    end

    local item = self.Items[index]

    if item.amount + amount + self.BufferAdd[index] > MAX_ITEM_CAP then 
        return false
    end
    //print("ECONOMIC: item sell", amount, item.amount)
    
    //item.amount = math.Clamp(math.floor(item.amount + amount), 0, MAX_ITEM_CAP)
    //print("AFTER selling", item.amount)
    self.BufferAdd[index] = math.Clamp(self.BufferAdd[index] + amount, 0, MAX_ITEM_CAP)

    
    return true
end

function ECONOMIC:ForceSyncPly(ply)
    if CLIENT then return end
    ECONOMIC_QUEUE_SYNC[ply] = true
end


hook.Add("EconItemBuy", "main", function(item, amount)
    return ECONOMIC:ItemBuy(item, amount)
end)

hook.Add("EconItemSell", "main", function(item, amount)
    return ECONOMIC:ItemSell(item, amount)
end)



function ECONOMIC:CLForceSync(day, tbl)
    --print("FORCE SYNC")
    //print("SERVER", day , "CLIENT", self.EconTime)
    self.EconTime = day
    for ind, val in pairs(tbl) do
        //print(ind, val)
        self.Items[ind].status      = val.status
        self.Items[ind].next_change = val.next_change
        //self.Items[ind].med_price   = val.med_price
        self.Items[ind].amount       = val.amount
        timer.Adjust("ECON_TIME", ECON_DAY, 0, function()
            self:GeneratePrice()
        end)
    end
    ECONOMIC_CL_REQUESTED_SYNC = false
end

function ECONOMIC:ClRequestSync()
    net.Start("econ_init")
    net.SendToServer()
end 

function ECONOMIC:Syncing(day, amount_tbl)
    //print("SYNCING", day, self.EconTime)
    if SERVER then
        for ply, v in pairs(ECONOMIC_QUEUE_SYNC) do
            if v == true then
            // send
            // econ_day
            // item.index, items.status, next_change, med_price, ratio
                net.Start("econ_init")
                net.WriteUInt(self.EconTime, 16)
                for index, item in pairs(self.Items) do
                    //net.WriteString(index)
                    net.WriteUInt(ECON_NET_INDEX[index], 5)
                    net.WriteInt(item.status, 3)
                    net.WriteUInt(item.next_change, 16)
                    //net.WriteFloat(item.med_price)
                    net.WriteUInt(item.amount, 15)
                    //net.WriteFloat(item.ratio)
                end
                net.Send(ply)
            end
            ECONOMIC_QUEUE_SYNC[ply] = nil
        end
        //need send ratio for items
        net.Start("econ_sync")
        net.WriteUInt(self.EconTime, 16)
        for index, item in pairs(self.Items) do
            //net.WriteString(index)
            net.WriteUInt(ECON_NET_INDEX[index], 5)
            
            net.WriteUInt(math.floor(item.amount), 15)
        end
        net.Broadcast()
    else
        //print("sync amount, ", table.Count(amount_tbl))
        for k, v in pairs(amount_tbl) do
            //print(k, v)
            self.Items[k].amount = v
        end
        local tleft = timer.TimeLeft( "ECON_TIME" )

        if !tleft then
            timer.Create("ECON_TIME", ECON_DAY, 0, function()
                self:GeneratePrice()
            end)
            print("Error syncing, request sync")
            self:ClRequestSync()
            return
        end
        if day != self.EconTime then
            if (day-1 == self.EconTime and (math.abs(timer.TimeLeft( "ECON_TIME" )) < 1 )) then
                //print("v predelah pogreshnosti")
                return
            end

            // request force sync
            if ECONOMIC_CL_REQUESTED_SYNC == true then return end
            //print("Error syncing, request sync")
            self:ClRequestSync()
            ECONOMIC_CL_REQUESTED_SYNC = true

        elseif ECON_DAY - math.abs(timer.TimeLeft( "ECON_TIME" )) > 1 then
            //print("adjust timer", ECON_DAY - timer.TimeLeft( "ECON_TIME" ))
            timer.Adjust("ECON_TIME", ECON_DAY, 0, function()
                self:GeneratePrice() 
            end)
        end
    end
end

function ECONOMIC:ForceSyncPly(ply)
    if CLIENT then return end
    ECONOMIC_QUEUE_SYNC[ply] = true
end

if CLIENT then 
    net.Receive("econ_sync", function()
        local day = net.ReadUInt(16)
        //print("econ_sync", day)
        local amount_tbl = {}    
        for i = 1,  table.Count(ECONOMIC.Items) do
            //local ind = net.ReadString()
            local ind = ECON_NET_INDEX_INVERT[net.ReadUInt(5)]
            local amnt = net.ReadUInt(15)
            //local rto = net.ReadFloat()
            amount_tbl[ind] = amnt
        end
        
        if ECONOMIC then
            ECONOMIC:Syncing(day, amount_tbl)
        end
    end)

    net.Receive("econ_init", function()
        local sync_tbl = {}
        local day = net.ReadUInt(16)
        --print(day, table.Count(ECONOMIC.Items) )
        for i = 1,  table.Count(ECONOMIC.Items) do
            //local ind = net.ReadString()
            local ind = ECON_NET_INDEX_INVERT[net.ReadUInt(5)]

            local sts = net.ReadInt(3)
            local nxt = net.ReadUInt(16)
            //local prc = net.ReadFloat()
            local amn = net.ReadUInt(15)
            //local rto = net.ReadFloat()
            sync_tbl[ind] = {status = sts, next_change = nxt, amount = amn}
        end
        
        --PrintTable(sync_tbl)

        ECONOMIC:CLForceSync(day, sync_tbl)
    end)
else
    net.Receive("econ_init", function(_, ply)
        if ECONOMIC then
            ECONOMIC:ForceSyncPly(ply)
        end
    end)
end

ECONOMIC:Setup()
