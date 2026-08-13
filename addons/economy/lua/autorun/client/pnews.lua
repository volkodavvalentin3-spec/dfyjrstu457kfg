local PANEL = {}
surface.CreateFont( "EconHeader", {
	font = "Arial",
	extended = true,
	size = 28,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "EconText", {
	font = "Arial",
	extended = true,
	size = 18,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
 
surface.CreateFont( "AfricaHead", {
	font = "CloseCaption_BoldItalic",
	extended = true,
	size = 28,
	weight = 800,
	blursize = 0,
	scanlines = 0,
    italic = true,
    underline = true,
} )


local NEWS_AGENCY_STYLE = {
    ["econtoday"] = {
        paint = function(self, w, h)
            local header = "Экономика сегодня"
            surface.SetDrawColor(255,255,255)
            surface.DrawRect(0, 0, w, h)

            surface.SetTextColor(10,10,10)
            surface.SetTextPos(3,0)
            surface.SetFont("EconHeader")
            surface.DrawText(header)

            surface.SetTextColor(128,128,128)
            surface.SetFont("EconText")
            local ww,hh = surface.GetTextSize(self.Time or "")
            surface.SetTextPos((w-ww)-10,8)
            surface.DrawText(self.Time or "")
        end,
        label = function(self)
            // setup label text news
            if IsValid(self.Label) then
                self.Label:Remove()
            end
            local text = vgui.Create( "RichText", self)
            text:Dock(FILL)
            text:DockMargin(10,30,10,5)
            text:SetPos(5,50)
            text:SetFontInternal( "DermaDefault" )
            text:SetText(self.News)

            function text:PerformLayout()
                if ( self:GetFont() != "DermaDefault" ) then self:SetFontInternal( "DermaDefault" ) end
                self:SetFGColor( color_black )
            end

            self.Label = text
        end
    },
    ["afrika"] = {
        paint = function(self, w, h)
            local header ="АФРИКАНИСТАНИН"
            surface.SetDrawColor(252, 216, 169)
            surface.DrawRect(0, 0, w, h)

            surface.SetTextColor(138, 59, 23)
            surface.SetFont("AfricaHead")

            local x,y = surface.GetTextSize(header)
            surface.SetTextPos(w/2 - x/2,0)
            
            surface.DrawText(header)

            surface.SetTextColor(205, 133, 63)
            surface.SetFont("EconText")
            
            local ww,hh = surface.GetTextSize(self.Time or "")
            surface.SetTextPos((w-ww)-10,8)
            surface.DrawText(self.Time or "")
        end,
        label = function(self)
            if IsValid(self.Label) then
                self.Label:Remove()
            end
            local text = vgui.Create( "RichText", self)
            text:Dock(FILL)
            text:DockMargin(10,30,10,5)
            text:SetPos(5,50)
            text:SetFontInternal( "DermaDefault" )
            text:SetText(self.News)

            function text:PerformLayout()
                if ( self:GetFont() != "DermaDefault" ) then self:SetFontInternal( "DermaDefault" ) end
                self:SetFGColor( Color(173,111,63) )
            end
            
            self.Label = text
        end
    },
    ["plivtown"] ={
        paint = function(self, w, h)
            surface.SetDrawColor(155, 196, 226) // 176, 196, 222
            surface.DrawRect(0, 0, w, h)

            surface.SetTextColor(0,43,89)
            surface.SetTextPos(15,0)
            surface.SetFont("EconHeader")
            surface.DrawText("Новости Плывтауна")

            surface.SetTextColor(128,128,128)
            surface.SetFont("EconText")
            local ww,hh = surface.GetTextSize(self.Time or "")
            surface.SetTextPos((w-ww)-10,8)
            surface.DrawText(self.Time or "")
        end,
        label = function(self)
            // setup label text news
            if IsValid(self.Label) then
                self.Label:Remove()
            end
            local text = vgui.Create( "RichText", self)
            text:Dock(FILL)
            text:DockMargin(10,30,10,5)
            text:SetPos(5,50)
            text:SetFontInternal( "DermaDefault" )
            text:SetText(self.News)

            function text:PerformLayout()
                if ( self:GetFont() != "DermaDefault" ) then self:SetFontInternal( "DermaDefault" ) end
                self:SetFGColor( Color(0,43,89) )
            end
            text:SizeToContentsY()
            self.Label = text
        end
    }
}

function PANEL:Init()
    self.Agency = "econtoday"
    self.Time   = "2034.04.15"
    self.News   = "Have a nice day!"
    self.Paint  = NEWS_AGENCY_STYLE[self.Agency]["paint"]
    self.SetupText = NEWS_AGENCY_STYLE[self.Agency]["label"]
    
    self:SetupText()
end

function PANEL:SetAgency(a)
    self.Agency = (NEWS_AGENCY_STYLE[a] != nil and a or "econtoday")
    self.Paint = NEWS_AGENCY_STYLE[self.Agency]["paint"]
    self.SetupText = NEWS_AGENCY_STYLE[self.Agency]["label"]

    self:SetupText()
end

function PANEL:SetText(text, time)
    self.News   = text
    self.Time   = time or self.Time
    self:SetupText()

end

function PANEL:SetTime(text)

end
--[[
function PANEL:Paint(w,h)
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
end
--]] 
vgui.Register( "DNews", PANEL, "DPanel")

