if CLIENT then return end
JMOD_PowerNet = JMOD_PowerNet or {}
--[[
local dev = GetConVar("developer")
-]]
local function devprint(...)
    //if !dev:GetBool() then return end
    print(...)
end
local MACHINE_POWER_TO_CHARGE = 95

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

function JMOD_PowerNet:Init()
    self.Net = {}
    self.Iter = 0
    self.Inited = true
    devprint("POWERNET INIT")
end

function JMOD_PowerNet:CreateNew(ent)
    
    local line = {
        all = {},
        line = {},
        power_producer = {},
        machine = {},
        powerbank = {},
    }


    line.line[ent] = true
    
    line.all[ent] = true
    self.Net[self.Iter] = line

    ent.PowerNetID = self.Iter

    self.Iter = self.Iter + 1

    devprint("powernet: Created new net - ", ent.PowerNetID)

    self:CreateTimer(ent.PowerNetID)

    return ent.PowerNetID
end

function JMOD_PowerNet:AddTo(netid, ent)
    if self.Net[netid].all[ent] then return end
    devprint("powernet: adding to net ent", netid, ent)

    //print(ent)

    if ent.EZNewPowerLine then
        if ent.PowerNetID then
            if ent.PowerNetID != netid and ent.EZNewPowerLine then
                self:Merge(netid, ent.PowerNetID)
                return
            else
                devprint("powernet: replace net for machine", ent)
            end
        else
            self.Net[netid].line[ent] = true
            ent.PowerNetID = netid
        end
    elseif ent.EZpowerProducer then
        self.Net[netid].power_producer[ent] = true
    elseif ent.EZpowerBank then
        self.Net[netid].powerbank[ent] = true
    else
        self.Net[netid].machine[ent] = true
    end
    self.Net[netid].all[ent]  = true
end

function JMOD_PowerNet:RemoveFrom(netid, line, ent)
    //print(netid, line, ent)
    if !self.Net[netid] or !IsValid(ent) then return end
    if !ent.EZNewPowerLine then
        if ent.EZpowerProducer then
            self.Net[netid].power_producer[ent] = nil
        elseif ent.EZpowerBank then
            self.Net[netid].powerbank[ent] = nil
        else
            self.Net[netid].machine[ent] = nil
        end
        self.Net[netid].all[ent]  = nil
        devprint("powernet: disconnect machine from net, ",ent, netid)
    else        
        local connected = constraint.FindConstraints(ent, "JModResourceCable")
        //print(connected)
        if #connected > 0 then
            devprint("powernet: line "..tostring(line).." need to reconfigure net")
            ent.NetReconfigure = true
            self:ReconfigureNet(line, ent.PowerNetID)
        else
            if ent.NetReconfigure then
                devprint("powernet: line "..tostring(line).." need to reconfigure net")
                self:ReconfigureNet(line, ent.PowerNetID)
                
            else
                if !line then
                    self:ReconfigureNet(nil, ent.PowerNetID)
                end
                self.Net[netid].line[ent]  = nil
                self.Net[netid].all[ent]  = nil
                
                ent.PowerNetID = nil
                //print("poeli")
            end
        end
    end
end

function JMOD_PowerNet:RemoveNet(netid)
    if table.Count(self.Net[netid].line) != 0 then
        for line, _ in pairs(self.Net[netid].line) do
            if line:IsValid() then line.PowerNetID = nil end
        end
    end

    self.Net[netid] = nil
    timer.Remove("powernet:"..netid)
end

local function getAllConnectedEnts(parent)
    if !IsValid(parent) then return {} end
    local arr = {}
    local child
    for _, cable in pairs(constraint.FindConstraints(parent, "JModResourceCable")) do
        child = Either(cable.Ent1 == parent, cable.Ent2, cable.Ent1)
        arr[child] = true
    end
    return arr
end

function POWERgetAllConnectedEnts(parent)
    if !IsValid(parent) then return {} end
    local arr = {}
    local child
    for _, cable in pairs(constraint.FindConstraints(parent, "JModResourceCable")) do
        child = Either(cable.Ent1 == parent, cable.Ent2, cable.Ent1)
        arr[child] = true
    end
    return arr
end

function JMOD_PowerNet:ReconfigureNet(parent, oldnet)
    // recursive get all ents in connection, add in one
    local function getline()
        //local line
        for ent, v in pairs(self.Net[oldnet].line) do
            if ent:IsValid() then return ent end
        end
        return nil
    end

    if !parent then
        // some shit happens
        // simple reload all net
        parent = getline()
        if !parent then return end 
    end
    if parent.PowerNetID != oldnet then 
        devprint("powernet: "..tostring(parent).." now have another id, seems to already in other net")
        return
    end

    local newnet = self:CreateNew(parent)
    local function addto(ent)
        if ent.EZNewPowerLine then
            self.Net[newnet].line[ent] = true
            ent.PowerNetID = newnet
        elseif ent.EZpowerProducer then
            self.Net[newnet].power_producer[ent] = true
        elseif ent.EZpowerBank then
            self.Net[newnet].powerbank[ent] = true
        else
            self.Net[newnet].machine[ent] = true
        end
        self.Net[newnet].all[ent]  = true
        devprint("powernet: adding ", ent, " to net ", newnet)
        
    end

    local function remfrom(ent)
        if ent.EZNewPowerLine then
            self.Net[oldnet].line[ent] = nil
        elseif ent.EZpowerProducer then
            self.Net[oldnet].power_producer[ent] = nil
        elseif ent.EZpowerBank then
            self.Net[oldnet].powerbank[ent] = nil
        else
            self.Net[oldnet].machine[ent] = nil
        end
        self.Net[oldnet].all[ent]  = nil
    end

    local function getrecurs(prnt)
        addto(prnt)
        
        if !parent.EZNewPowerLine then return end
        local arr = getAllConnectedEnts(prnt)
       
        for ent, _ in pairs(arr) do
            if ent:IsValid() and !self.Net[newnet].all[ent] then
                getrecurs(ent)
            end
        end
        remfrom(prnt)
    end

    getrecurs(parent)

    devprint("powernet: reconfigure the net, created new id - ", newnet, table.Count(self.Net[newnet].all) )
end

function JMOD_PowerNet:Merge(net1, net2)
    devprint("powernet: attempt to merge nets - ", net1, net2 )
    if net1 == nil or net2 == nil then return end
    local parent = Either(net1 < net2, net1, net2)
    local child  =  Either(net1 < net2, net2, net1)

    local parentnet, childnet = self.Net[parent], self.Net[child]

    if parentnet == nil or childnet == nil then return end

    for ent, _ in pairs(self.Net[child].all) do
        if ent.EZNewPowerLine then
            self.Net[parent].line[ent] = true
            ent.PowerNetID = parent
        elseif ent.EZpowerProducer then
            self.Net[parent].power_producer[ent] = true
        elseif ent.EZpowerBank then
            self.Net[parent].powerbank[ent] = true
        else 
            self.Net[parent].machine[ent] = true
        end
        self.Net[parent].all[ent]  = true
    end

    self.Net[child] = nil
    timer.Remove("powernet:"..child)
end

function JMOD_PowerNet:Get(netid)
    return self.Net[netid]
end

local function getvalid(tbl)
    for ent, _ in pairs(tbl) do
        if ent:IsValid() then return true end
    end
    return false
end

function JMOD_PowerNet:CreateTimer(netid)
    devprint("powernet: timer ", netid)

    timer.Create("powernet:"..netid, 1,0, function()
        local Net = self.Net[netid]
        if self.Net[netid] == nil then timer.Remove("powernet:"..netid) return end

        local valid_count = 0
        for ent, _ in pairs(Net.all) do
            if ent:IsValid() then valid_count = valid_count + 1 end
        end
        
        if !(valid_count > 1) then
            print(valid_count, netid, "DELETE")
            self:RemoveNet(netid)
            return
        end

        //print(netid, table.Count(Net.all))

        local powerbanks = {}
        local machines = Net.machine

        //PrintTable(Net)

        if table.Count(Net.powerbank) == 0 then return end

        for k, v in pairs(Net.powerbank) do
            table.insert(powerbanks, k)
        end

        local id = 1

        local function nextbank() // need to put it out from timer
            id = id + 1
            if id > #powerbanks then
                return true
            else
                if !powerbanks[id]:IsValid() then return nextbank() end
                if powerbanks[id]:GetElectricity() == 0 then return nextbank() end
                return false
            end
        end
    

        for ent, v in pairs(machines) do
            if !IsValid(ent) then continue end
            if powerbanks[id]:GetElectricity() == 0 then
                local needend = nextbank()
                if needend then
                    break
                end
            end            

            if ent:GetElectricity() > MACHINE_POWER_TO_CHARGE then continue end // charge machine if under this limit

            local bank_power = powerbanks[id]:GetElectricity()

            local taken = math.min(ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, bank_power), bank_power)
            //print(taken)
			ent.NextRefillTime = 0
			powerbanks[id]:SetElectricity(bank_power - taken)
        end

    end)
end

function JMOD_PowerNet:DistributePower(net_id, machine, amount)
    local gived = amount

    local powernet = self.Net[net_id]
    // first machines
    local pgive = amount / table.Count(powernet.machine)
    for machine, v in pairs(powernet.machine) do
        if amount <= 0 then return gived end
        amount = amount - machine:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, pgive)
    end

    // then powerbanks
    for machine, v in pairs(powernet.powerbank) do
        if amount <= 0 then return gived end
        amount = amount - machine:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, amount)
    end

    return gived - amount
end

function JMOD_PowerNet:Reload()
    for netid, _ in pairs(self.Net) do
        self:RemoveNet(netid)
    end
    
    JMOD_PowerNet:Init()
end

JMOD_PowerNet:Init()

--============================================================================================

hook.Add("JMOD_CreatedResourceConnection", "powerline_addconnection", function(ent1, ent2, typ)

    if !(ent1.EZNewPowerLine or ent2.EZNewPowerLine) then return end 
    
    local connect = {
        {
            ent = ent1,
            isPowerLine = ent1.EZNewPowerLine == true,
            pnet = ent1.PowerNetID or false
        },
        {
            ent = ent2,
            isPowerLine = ent2.EZNewPowerLine == true,
            pnet = ent2.PowerNetID or false
        }
    }
    //PrintTable(connect)
    if connect[1].pnet == connect[2].pnet and connect[1].pnet == false then
        local netline = Either( connect[1].isPowerLine, ent1, ent2 )
        local entadd = Either( connect[1].ent == netline, ent2, ent1 )

        local newNet = JMOD_PowerNet:CreateNew(netline)
        JMOD_PowerNet:AddTo(newNet, entadd)
    elseif connect[1].pnet != connect[2].pnet then 
        local addnet = Either( connect[1].pnet != false, connect[1].pnet, connect[2].pnet )
        local entadd = Either( connect[1].pnet != false, ent2, ent1 )

        JMOD_PowerNet:AddTo(addnet, entadd)
    end
end)

hook.Add("JMOD_RemoveResourceConnection","powerline_removeconnection", function(ent1, ent2, cable)
    if !ent1 or !ent2 then return end
    if !(ent1.EZNewPowerLine or ent2.EZNewPowerLine) then return end 

    local connect = {
        {
            ent = ent1,
            isPowerLine = ent1.EZNewPowerLine == true,
            pnet = ent1.PowerNetID or false
        },
        {
            ent = ent2,
            isPowerLine = ent2.EZNewPowerLine == true,
            pnet = ent2.PowerNetID or false
        }
    }
    
    //PrintTable(connect)
    if connect[1].pnet == connect[1].pnet and connect[1].pnet != false then

        if connect[1].isPowerLine == connect[2].isPowerLine and connect[1].isPowerLine == true then
            JMOD_PowerNet:RemoveFrom(connect[1].pnet, connect[1].ent, connect[2].ent)
        else
            local remline = Either( connect[1].isPowerLine, 1, 2 )
            local entrem  = Either( connect[1].isPowerLine, 2, 1 )

            JMOD_PowerNet:RemoveFrom(connect[remline].pnet, connect[remline].ent, connect[entrem].ent)

        end
    end 

end)

/////////////////
//  after reload lua
//  auto create nets

local powerLineCheck = {}
local function getrecurs(prnt, netid)
    //print("check:", prnt, netid)
    JMOD_PowerNet:AddTo(netid, prnt)
    powerLineCheck[prnt] = true

    if !prnt.EZNewPowerLine then return end
    local arr = getAllConnectedEnts(prnt)

    for ent, _ in pairs(arr) do
        if ent:IsValid() and !powerLineCheck[ent] then
            getrecurs(ent, netid)
        end
    end
end

local function powerlinecheck(ent)
    if powerLineCheck[ent] then return end
    if table.Count(getAllConnectedEnts(ent)) == 0 then return end
    //ent.PowerNetID = nil
    local netid = JMOD_PowerNet:CreateNew(ent)
    getrecurs(ent, netid)
end

function PowerNetReload()
    for _, ent in pairs(ents.FindByClass("ent_new_powerline")) do
        if powerLineCheck[ent] then continue end
        ent.PowerNetID = nil
        powerlinecheck(ent)
    end
    powerLineCheck = {}
end

PowerNetReload()

concommand.Add("powernet_reload", function()
    devprint("powernet: reload all systems")
    JMOD_PowerNet:Reload()
    PowerNetReload()
end)
