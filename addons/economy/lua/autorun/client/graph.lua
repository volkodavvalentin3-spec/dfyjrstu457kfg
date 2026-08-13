local PANEL = {}

local MAX_XP    = 20

local icn = Material("materials/icon16/hourglass.png")

local function getAmpl(t)
    if #t <= 1 then return 1 end
 
    local min = math.min(unpack(t))
    local max = math.max(unpack(t))

    return math.abs(max - min)
end

local function getMed(t)
    if #t <= 1 then return 1 end

    local sred = 0
    for i=1, #t do
        sred = sred + t[i]
    end

    return sred / #t
end

function PANEL:Init()
    self.GraphData  = {}
    //self.XPoints    = 30
    self.PDraw      = {}
    self.GScale     = 1
    self.NameHead   = "..."
    self.Waiting    = false
end

function PANEL:Clear()
    self.GraphData = {}
    self.PDraw     = {}
    self.NameHead  = "..."
end

function PANEL:Wait()
    self.Waiting = true
end

function PANEL:SetData(data)
    self.GraphData  = data
    self.Waiting    = false
    self:GraphReload()
end

function PANEL:GraphReload()
    //print("upodate graph")
    //PrintTable(self.GraphData)
    if !self.GraphData then return end 
    if table.Count(self.GraphData) == 0 then return end
    local w,h = self:GetSize() 

    local graph_h = h - 30
    local med  = getMed(self.GraphData)
    local aplt = getAmpl(self.GraphData)

    local min = math.min(unpack(self.GraphData))
    local max = math.min(unpack(self.GraphData))
    local scale = 1
    

    scale = (graph_h/2) / aplt

    if scale > 200 then
        scale = 200
    end
    //self.GScale = scale

    for i = 1, #self.GraphData do
        local y = 15 + ((graph_h / 2)) - (med - self.GraphData[i]) *-scale
        self.PDraw[i] = {y = y, price = self.GraphData[i]}
    end
end

function PANEL:SetGraphName(text)
    self.NameHead = text
end
local wait_t = "Waiting"
function PANEL:Paint(w,h)
    /*if self.Waiting then
        // waiting anim, but unused
        surface.SetMaterial(icn)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(w/2-8, h/2 + math.sin(CurTime()*2)*5, 16, 16)

        surface.SetFont("DermaDefault")
        surface.SetTextColor(255,255,255)

        local ww,hh = surface.GetTextSize(wait_t)
        
        surface.SetTextPos(w/2 - ww/2, 20 + h/2)
        surface.DrawText(wait_t)
        return
    end
    */
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)

    
    //сетка is broken
    /*
    surface.SetDrawColor(128,128,128)
    for x = 1, #self.PDraw - 1 do
        local ay1, ax1 = (w / MAX_XP) * (x), h
        local ay2, ax2 = (w / MAX_XP) * (x), 0
        surface.DrawLine( ay1, ax1, ay2, ax2 )
    end

    for y = 10/self.GScale, w, 10/self.GScale do
        local ay1, ax1 = w, y
        local ay2, ax2 = 0, y
        surface.DrawLine( ay1, ax1, ay2, ax2 )
    end 
    */

    if !self.PDraw then return end
    if #self.PDraw < 2 then return end
    for i = 2, #self.PDraw do
        local a = self.PDraw[i-1]
        local b = self.PDraw[i]

        if b.y < a.y then
            surface.SetDrawColor(0,255,0)
        else
            surface.SetDrawColor(255,0,0)
        end

        local x1 = (w / MAX_XP) * (i-2)
        local x2 = (w / MAX_XP) * (i-1)
        local axp, ayp, bxp, byp = x1, a.y, x2 ,b.y
        surface.DrawLine( axp, ayp, bxp, byp )
        
        local xt,yt = surface.GetTextSize(tostring(b.price))

        surface.SetTextColor(255,255,255)
        surface.SetFont("DermaDefault")

        surface.SetTextPos((bxp) - (xt/2), (byp-yt))
        surface.DrawText(tostring(b.price))
    end

    surface.SetFont("DermaLarge")
    local sx, sy = surface.GetTextSize(self.NameHead)

    surface.SetTextPos(2, 2)
    surface.SetTextColor(Color(255,255,255))
    surface.DrawText(self.NameHead .. " " .. tostring(self.PDraw[#self.PDraw]["price"].."$"))
end

vgui.Register( "Graph", PANEL, "DPanel")

