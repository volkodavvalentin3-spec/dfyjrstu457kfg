// reformat config
local BUTTONS_CONF = {}
//bruh
for k, v in pairs(ECONOMIC_CONFIG) do
    BUTTONS_CONF[v[1]["categ"]] = {}
end

for k, v in pairs(ECONOMIC_CONFIG) do
    table.insert(BUTTONS_CONF[v[1]["categ"]], v[1])
end


local function format_p(a)
    local str = ""
    if a > 0 then
        str = str.."+"
    end
    return str .. tostring(a).."%" 
end

local procpos = 100

local function DRAWBUTTON(self, w, h)
    local Hovr = self:IsHovered()

    if Hovr then
        if not self.hovered then
            self.hovered = true

            --if self.enabled then
                surface.PlaySound("snds_jack_gmod/ez_gui/hover_ready.ogg")
            --end
        end
    else
        self.hovered = false
    end

    if self.ItemIcon then
        surface.SetMaterial(self.ItemIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(5, 5, 32, 32)
    end

    surface.SetDrawColor(0, 0, 0, (Hovr and 50) or 20)
 
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText(self.itemName, "DermaDefault", (self.ItemIcon and 47) or 5, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)


    //draw proc
    local X = w - 15
    local Txt = tostring(resourceAmt)

    if self.WarehouseID then
        
        if Warehouse.Items[self.WarehouseID] then
            //print(self.WarehouseID)
            if Warehouse.Items[self.WarehouseID] > 0 then
                local amnt = Warehouse.Items[self.WarehouseID]
                draw.SimpleText(amnt, "DermaDefault", 100, 15, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end
    end
    
    if ECONOMIC.Items[self.itemName] then 
        local amnt = ECONOMIC.Items[self.itemName].amount or 0
        draw.SimpleText(amnt, "DermaDefault", 170, 15, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    

    if ECONOMIC.Prices[self.itemName] then
        local prc = ECONOMIC:GetPrice(self.itemName).."$"
        surface.SetFont("DermaDefault")
        local prcSize = surface.GetTextSize(prc)
        local color = Color(255,255,255)
        
        draw.SimpleText(prc, "DermaDefault", X - prcSize, 15, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local proc      = ECONOMIC:GetLastChangeProc(self.itemName)
        local proctxt   = format_p(proc)
        local procSize  = surface.GetTextSize(prc)

        if proc > 0 then
            color = Color(0,255,0)    
        elseif proc == 0 then
            color = Color(255,255,255)
        else
            color = Color(255,0,0)  
        end
        draw.SimpleText(proctxt, "DermaDefault", X - (procpos) , 15, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

local function getlast(tbl)
    return tbl[#tbl]
end

function TradeButton(itemind, itemid, buy, radio)
    local selected = itemind
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "Trade" )
    frame:SetSize( 200, 150)
    frame:Center()
    frame:MakePopup()
    //print(itemid)
    local haveit = Warehouse.Items[itemid] or 0

    local itemprice = 0
    
    local lbl = vgui.Create("DLabel", frame)
    lbl:SetFont("DermaDefault")
    lbl:SetColor(color_white)
    lbl:SetPos(15,25)
    if buy then
        lbl:SetText("Buy: "..itemind)
    else
        lbl:SetText("Sell: "..itemind)
    end

    /*
    local TEAmount = vgui.Create( "DTextEntry", frame )
    TEAmount:SetPos(10,50)
    TEAmount:SetNumeric(true)
    TEAmount:SetSize(180,18)
    */

    
    local NSAmount = vgui.Create( "DNumSlider", frame )
    NSAmount:SetPos( 20, 50 )
    NSAmount:SetSize( 180, 18 )
    NSAmount:SetText( "Amount" )
    NSAmount:SetMin( 0 )
    if buy then
        NSAmount:SetMax( 1000 )
    else
        NSAmount:SetMax( Warehouse.Items[itemid] or 0 )
    end 
    NSAmount:SetDecimals( 0 )
   

    local lbl2 = vgui.Create("DLabel", frame)
    lbl2:SetPos(15,70)
    lbl2:SetText("")
    lbl2:SetSize(165,20)


    function lbl2:Paint(w,h)
        local price = getlast(ECONOMIC.Prices[selected])
        local amnt = NSAmount:GetValue() or 0
        if buy then
            draw.SimpleText("Price: "..tostring(format_num(math.Round(price*amnt * (1 + ((SquadMenu.mySquad.Loan.Debt or 0) / 100)), 0), 0)).."$", "DermaDefault", 0, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleText("Sell for: "..tostring(format_num(math.Round(price*amnt, 0), 0)).."$", "DermaDefault", 0, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText("You have: "..tostring(haveit), "DermaDefault", 90, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
    

    local bconf = vgui.Create( "DButton", frame )
    bconf:SetText("CONFIRM")
    bconf:SetPos( 10, 90 )
    bconf:SetSize( 180, 50  )
    
    function bconf:DoClick()
        local amnt = NSAmount:GetValue() or 0
        if amnt <= 0 then return end
        
        if buy then
            Warehouse.SendAction(radio, WH_BUY, itemid, amnt)    
            surface.PlaySound("snds_jack_gmod/ez_gui/click_big.ogg")
        else
            Warehouse.SendAction(radio, WH_SELL,itemid, amnt)
            surface.PlaySound("snds_jack_gmod/ez_gui/click_big.ogg")
            frame:Remove()
        end
    end

end



function RadioEconPanel(parent, radio)
    fromRadio = IsValid(radio)

    local function getwhid(ind)
        //print(ind, ECONOMIC.Items[ind].item.name)
        return JMod.ResourceToIndex[ECONOMIC.Items[ind].item.name] or 0
    end
    
    function Select(key)
        if ECONOMIC.Prices[key] then
            print(key)
            if selected == key then return end
            parent.graph:SetGraphName(key)
            parent.graph:SetData(ECONOMIC:GetHistory(key))
            parent.graph:GraphReload()
            selected = key
        end
    end

    function parent:UpdatePrice()
        if selected == "" then return end
        if !IsValid(parent.graph) then return end 
        parent.graph:SetData(ECONOMIC:GetHistory(selected))
        parent.graph:GraphReload()
    end

    function parent:Paint(w,h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    local plist = vgui.Create("DPanel", parent)
    plist.Paint = parent.Paint

    //print(Either( fromRadio == true, 400, 275))
    //print(fromRadio)
    plist:SetSize(Either( fromRadio == true, 350, 275),389)
    --plist:Dock(LEFT)
    
    local pplist = vgui.Create( "DScrollPanel", plist )
    pplist:Dock( FILL )

    local pgraph = vgui.Create("DPanel", parent)
    pgraph:SetSize(510,0)
    pgraph:Dock(RIGHT)

    --[[local ppglist = vgui.Create( "DScrollPanel", pgraph )
    ppglist:Dock( FILL )]]

    local graph = vgui.Create("Graph", pgraph)
    graph:SetSize(0,490)
    graph:Dock(TOP)
    
    parent.graph = graph
    --[[if noTrade != true then
        local ptrade = vgui.Create("DPanel", ppglist)
        ptrade:SetSize(0, 100)
        ptrade:Dock(BOTTOM)
        ptrade.Paint = parent.Paint
        
        function ptrade:Paint(w,h)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)
        end
    

        // dev: disable buttons
        /*
        if false then
            local btbuy = vgui.Create( "DButton", ptrade )
            btbuy:SetText("")
            btbuy:SetPos( 40, 10 )
            btbuy:SetSize( 60, 60 )
            btbuy.lbl = "Buy"

            local btsell = vgui.Create( "DButton", ptrade )
            btsell:SetText("")
            btsell:SetPos( 510-60-40, 10 )
            btsell:SetSize( 60, 60 )
            btsell.lbl = "Sell"

            function btbuy:DoClick() TradeButton(selected, getwhid(selected), true) end
            function btsell:DoClick() TradeButton(selected, getwhid(selected)) end

            function btbuy:Paint(w,h)
                surface.SetDrawColor(0, 0, 0, 100)
                surface.DrawRect(0, 0, w, h)

                draw.SimpleText(self.lbl, "DermaLarge", w/2 , h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end


            btsell.Paint = btbuy.Paint
        end
        */
    end]]
    
    

    pgraph.Paint = parent.Paint

    for categ, items in pairs(BUTTONS_CONF) do
        local l = vgui.Create( "DLabel", pplist )
        l:SetSize(200,40)
        l:Dock(TOP)
        l:DockMargin( 10, 5, 0, 0 )
        l:SetFont("DermaDefault")
        l:SetColor(Color(255,255,255))
        l:SetText( categ )

        for _, item in pairs(items) do
            local bsel = vgui.Create( "DButton", pplist )
            bsel:SetText("")
            bsel:Dock(TOP)
            bsel:SetSize( 0, 42 )
            
            bsel.itemName = item["index"]
            bsel.ItemIcon = JMod.EZ_RESOURCE_TYPE_ICONS[item["name"]]
            bsel.WarehouseID = JMod.ResourceToIndex[item["name"]] or nil
            bsel.Paint = DRAWBUTTON
            
            

            function bsel:DoClick()
                Select(self.itemName)
                surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")
            end

            function bsel:DoRightClick()
                local btn = self
                local opt = DermaMenu()
                
                opt:AddSpacer()
                //local bbuy = opt:AddOption( "Buy" )
                
                surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")

                if !WH_RESTRICTED_TO_BUY[JMod.IndexToResource[btn.WarehouseID]] then 
                    local bbuy = opt:AddOption( "Buy" )
 
                    function bbuy:DoClick()
                        //    print(btn.itemName, btn.WarehouseID)
                        TradeButton(btn.itemName, btn.WarehouseID, true, radio)
                    end
                end
                local bsell = opt:AddOption( "Sell" ) 
    
                //function bbuy:DoClick()
                //    print(btn.itemName, btn.WarehouseID)
                //    TradeButton(btn.itemName, btn.WarehouseID, true, radio)
                //end
    
                function bsell:DoClick() 
                    TradeButton(btn.itemName, btn.WarehouseID, false, radio)
                end
                
                opt:Open()
            end
        end

    end


    ECON_DERMA = parent
end

function DrawDerma(radio)
    local selected = ""

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "Stock listing" )
    frame:SetSize( 800,600 )
    frame:Center()
    frame:MakePopup()

    RadioEconPanel(frame, radio)
end


hook.Add("EconomicUpdatePrices", "derma_update", function() 
    if IsValid(ECON_DERMA) then
        ECON_DERMA:UpdatePrice()
    end
end)