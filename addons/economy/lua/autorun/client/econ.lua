ECON_DERMA = nil

ECON_DATA = {
    prices_t = 0,
    prices = {},
    graphs      = {},
    requested   = {},
}

/*
    last_prices_t 
    last_prices = {
        IND1 = 120,
        IND2 = 51,
        ...
    }

    graphs = {
        "INDX" = {
            last_check = [time]
            data = {...}
        }
    }

    if CurTime + ECON_DAY > last_check:
        request_price
*/
/*
function PricesIsOutdated(ind)
    if !ECON_DATA.graphs[ind] then
        return true
    end
    return ECON_DATA.graphs[ind]["time"] + ECON_DAY > CurTime()
end
*/
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
/*
function RequestGraph(ind)
    if true then return end
    if ECON_DATA.requested[ind] then return end
    net.Start("econ_graph")
    net.WriteString(ind)
    net.SendToServer()

    ECON_DATA.requested[ind] = true
    if IsValid(ECON_DERMA) then

    end
end
*/
net.Receive("econ_prices", function()
    local all = net.ReadUInt(8)
    for i = 1, all do
        local ind = net.ReadString()
        local prc = math.Truncate( net.ReadFloat(), 2)
        
        if !ECON_DATA.prices[ind] then
            ECON_DATA.prices[ind] = {}
        end
        //ECON_DATA.prices[ind] = 
        push_to_end(ECON_DATA.prices[ind], prc, ECON_SAVE_PRICES)
    end

    if IsValid(ECON_DERMA) then
        ECON_DERMA:UpdatePrice()
    end
    ECON_DATA.prices_t = CurTime()
    --print("PRICESGET", #ECON_DATA.prices["STEL"])
end)