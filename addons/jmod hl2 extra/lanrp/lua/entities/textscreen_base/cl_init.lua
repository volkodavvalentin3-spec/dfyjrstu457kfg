include("shared.lua")
surface.CreateFont("TextscreenFont", {
	font = "Arial",
	extended = true,
	size = 35,
	weight = 900,
	blursize = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local function utf8Trim(text, max_length)
    local utf8_chars = {}
    for char in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(utf8_chars, char)
    end

    if #utf8_chars > max_length then
        return table.concat(utf8_chars, "", 1, max_length)
    end
    return text
end

local function unicodeLen(str)
    local _, count = string.gsub(str, "[^\128-\191]", "")
    return count
end

net.Receive("textscreen_menu_open", function()
    local ent = net.ReadEntity()
    
    local TextMenu = vgui.Create("DFrame")
        TextMenu:MakePopup()
        TextMenu:SetTitle("Textscreen")
        TextMenu:SetDraggable(false)
        TextMenu:SetSize(500, 373)
        TextMenu:Center()
        TextMenu:SetDeleteOnClose( false )

    local TextColorLabel = vgui.Create( "DLabel", TextMenu )
        TextColorLabel:SetText("Цвет")
        TextColorLabel:Dock(TOP)

    local TextColor = vgui.Create( "DColorCombo", TextMenu )
        TextColor:Dock(TOP)

    local TextEntryLabel = vgui.Create( "DLabel", TextMenu )
        TextEntryLabel:SetText("Текст")
        TextEntryLabel:Dock(TOP)

    local TextEntry = vgui.Create("DTextEntry", TextMenu)
        TextEntry:Dock(TOP)
        TextEntry:SetPlaceholderText( "Начните вводить текст" )

    local TextSend = vgui.Create("DButton", TextMenu)
        TextSend:Dock(TOP)
        TextSend:SetText("Применить")
        TextSend.DoClick = function()
            net.Start("textscreen_menu_open")
                net.WriteEntity(ent)
                net.WriteString(TextEntry:GetValue())
                net.WriteVector(Vector(TextColor:GetColor().r, TextColor:GetColor().g, TextColor:GetColor().b))
            net.SendToServer()

            TextMenu:Remove()
        end
        
    TextMenu:SizeToContents()

    if IsValid(ent) then
        TextColor:SetColor(Color(ent:GetTextColor().x, ent:GetTextColor().y, ent:GetTextColor().z))
        TextEntry:SetValue(ent:GetTextValue())
    end
end)

function ENT:Initialize()
    self:DrawShadow(false)
    self.OldText = nil
    self.OldCol = nil
    self.Col = self:GetTextColor()
    self.BlackText = nil
    self.TextStr = ""
end

function ENT:Think()
    if self.GetTextValue() ~= self.OldText or self:GetTextColor() ~= self.OldCol then
        surface.SetFont(self.Font)
        local w, h = surface.GetTextSize("S")
        self.TextStr = utf8Trim(self.GetTextValue(), 241+math.Remap(unicodeLen(self.GetTextValue()), 40, 260, 0, 4))
        self.Text = markup.Parse("<font=TextscreenFont>" .. "<color="..markup.Color(Color(self:GetTextColor():Unpack())).. ">" .. markup.Escape(self.TextStr), 444+math.Remap(unicodeLen(self.TextStr), 110, 320, 0, w*24))
        self.BlackText = markup.Parse("<font=TextscreenFont>" .. "<color="..markup.Color(color_black).. ">" .. markup.Escape(self.TextStr), 444+math.Remap(unicodeLen(self.TextStr), 110, 320, 0, w*24))
        self.OldText = self.GetTextValue()
        self.OldCol = self:GetTextColor()
    end
    self:NextThink( CurTime() + 1 )
    return true
end

function ENT:Draw()
    self:DrawModel()

    if EyePos():Distance2DSqr(self:GetPos()) > 1024^2 then return end

    cam.Start3D2D(
        self:LocalToWorld(self.DrawPos), 
        self:LocalToWorldAngles(self.DrawAngles),  
        math.Remap( 24-math.Remap(unicodeLen(self.TextStr), 20, 240, 0, 13), 10, 32, 0.10, 0.32 )
    )

        self.BlackText:Draw( self.OutlineWidht, self.OutlineWidht, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_CENTER )

        self.Text:Draw( 0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end
