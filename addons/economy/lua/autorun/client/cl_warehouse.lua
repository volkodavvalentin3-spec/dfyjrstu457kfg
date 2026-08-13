if SERVER then return end
Warehouse = Warehouse or {}
Warehouse.Items = Warehouse.Items or {}

local WAREHOUSE_PANEL
--[[
function Warehouse.SendResource(radio, id, amnt) -- item = { id , amnt}
    print(radio, id, amnt)
    net.Start("warehouse_actions")
    net.WriteEntity(radio)
    net.WriteUInt(WH_SEND, 3)
    net.WriteUInt(id, 8)
    net.WriteUInt(amnt, 14)
    net.SendToServer()
end

function Warehouse.BuyResource(radio, id, amnt)
    net.Start("warehouse_actions")
    net.WriteEntity(radio)
    net.WriteUInt(WH_BUY, 3)
    net.WriteUInt(id, 8)
    net.WriteUInt(amnt, 14)
    net.SendToServer()
end

function Warehouse.SellResource(radio, id, amnt)
    net.Start("warehouse_actions")
    net.WriteEntity(radio)
    net.WriteUInt(WH_SELL, 3)
    net.WriteUInt(id, 8)
    net.WriteUInt(amnt, 14)
    net.SendToServer()
end

// !!!
function Warehouse.RequestUpd(radio, id, amnt)
    net.Start("warehouse_actions")
    net.WriteEntity(radio)
    net.WriteUInt(WH_SELL, 3)
    net.WriteUInt(0, 8)
    net.WriteUInt(0, 14)
    net.SendToServer()
end
--]]

function Warehouse.SendAction(radio, act, id, amnt) -- item = { id , amnt}
    print( "WAREHOUSE: try make action",radio, id, amnt, act)
    net.Start("warehouse_actions")
    net.WriteEntity(radio)
    net.WriteUInt(act, 3)
    net.WriteUInt(id, 8)
    net.WriteUInt(amnt, 20)
    net.SendToServer()
end

local function DRAWBUTTON(self, w, h)
    local Hovr = self:IsHovered()

    if Hovr then
        if not self.hovered then
            self.hovered = true

            if self.enabled then
                surface.PlaySound("snds_jack_gmod/ez_gui/hover_ready.ogg")
            end
        end
    else
        self.hovered = false
    end

    if self.ItemIcon then
        surface.SetMaterial(self.ItemIcon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(10, 5, 55, 55)
    end

    surface.SetDrawColor(0, 0, 0, (Hovr and 50) or 20)
    surface.DrawRect(0, 0, w, h)

    draw.SimpleText(self.itemName, "DermaDefault", w/2, 60, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function WarehousePanel(parent, radio)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(FILL)

    function panel:Paint(w,h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    function panel:Update()
        self:Clear()
        function self:Paint(w,h)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.DrawRect(0, 0, w, h)

            draw.SimpleText("Warehouse is updating", "DermaDefault", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        timer.Simple(1, function()
            if IsValid(self) then
                self:fillPanel()
            end
        end)
    end

    function panel:fillPanel()
        if self:ChildCount() > 0 then
            self:Clear()
        end
        local grid = vgui.Create( "DGrid", self)
        grid:SetCols( 5 )
        grid:SetColWide( 85 )
        grid:SetRowHeight( 85 )
        grid:Dock(FILL)

        if table.Count(Warehouse.Items)  == 0 then
            function self:Paint(w,h)
                --surface.SetDrawColor(0, 0, 0, 100)
                --surface.DrawRect(0, 0, w, h)
    
                draw.SimpleText("Warehouse is empty...", "DermaDefault", w/2, h/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            return
        else
            function self:Paint(w,h)
                --surface.SetDrawColor(0, 0, 0, 100)
                --surface.DrawRect(0, 0, w, h)
            end
        end
    
        for k, amnt in pairs(Warehouse.Items)  do
            local icon = JMod.EZ_RESOURCE_TYPE_ICONS[JMod.IndexToResource[k]]
            local name = JMod.IndexToResource[k]
            
            local but = vgui.Create( "DButton" )
            but:SetText( "" )
            but:SetSize( 75, 75 )
    
            but.Paint = DRAWBUTTON
            but.ItemIcon = icon
            but.itemName = tostring(amnt)
    
            grid:AddItem( but )
    
            function but:DoClick()
                local opt = DermaMenu()
                local bsend = opt:AddOption( "Send" )
                opt:AddSpacer()

                surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")

                if !WH_RESTRICTED_TO_BUY[JMod.IndexToResource[k]] then 
                    local bbuy = opt:AddOption( "Buy" )
 
                    function bbuy:DoClick()
                        TradeButton(ECONOMIC:GetIndex(JMod.IndexToResource[k]), k, true, radio)
                    end
                end
                local bsell = opt:AddOption( "Sell" ) 
    
                function bsend:DoClick()

                    surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")

                    Derma_StringRequest(
                        "Управление складом", 
                        "Укажите количество (Сейчас у вас "..tostring(amnt)..")",
                        "",
                        function(text) 
                            if !tonumber(text) then return end
    
                            local sendamnt = math.Clamp(tonumber(text), 0, amnt)
                            
                            if sendamnt > 0 then
                                --print(radio, k, sendamnt)
                                Warehouse.SendAction(radio, WH_SEND,k, sendamnt)
                            end
                        end
                    )
    
                end
    
    
                function bsell:DoClick() 
                    TradeButton(ECONOMIC:GetIndex(JMod.IndexToResource[k]), k, false, radio)
                end
                
                opt:Open()
            end
        end
    end
    panel:fillPanel()

    WAREHOUSE_PANEL = panel
end
//ResourceToIndex
//IndexToResource
concommand.Add("warehouse_show",function()
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "wh" )
    frame:SetSize( 800,600 )
    frame:Center()
    frame:MakePopup()

    function frame:Paint(w,h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    WarehousePanel(frame)
    
end)


net.Receive("warehouse_update", function()
    local size_wh = net.ReadUInt(8)
    
    local upd_wh = {}

    for i = 1, size_wh do
        local id = net.ReadUInt(8)
        local amnt = net.ReadUInt(20)
        
        upd_wh[id] = amnt
    end

    Warehouse.Items = upd_wh

    if ispanel(WAREHOUSE_PANEL) and IsValid(WAREHOUSE_PANEL) then
        WAREHOUSE_PANEL:Update()
    end
end)

-- Warehouse.Items = {
--     [JMod.ResourceToIndex["gold"]] = 50,
--     [JMod.ResourceToIndex["silver"]] = 25,
-- }
--[[
Warehouse.Items = {
    [JMod.ResourceToIndex["gold"]] --= 50,
    --[JMod.ResourceToIndex["silver"]] = 25,
--}