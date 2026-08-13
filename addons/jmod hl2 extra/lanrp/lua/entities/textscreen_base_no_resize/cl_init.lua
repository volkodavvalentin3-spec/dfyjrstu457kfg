include("shared.lua")

function ENT:Initialize()
    self:DrawShadow(false)
	self.DrawAngles = Angle(90, 0, 0)
	self.DrawPos = Vector(-6, 0, 1.55)
	self.FontSize = 13
	self.MaxLines = 3
    self.Font = "TextscreenFont"
    self.OutlineWidht = 3
end

function ENT:Draw()
    self:DrawModel()
    local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
    local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
    local DisplayAng = SelfAng

    surface.SetFont(self.Font)
    local w, h = surface.GetTextSize("S")
    local DrawPosMod = self.DrawPos.x*Forward + self.DrawPos.y*Right + self.DrawPos.z*Up
    local Col = self:GetTextColor()
    local TextStr = utf8Trim(self.GetTextValue(), 168)
    local Text = markup.Parse("<font=TextscreenFont>" .. "<color="..markup.Color(Color(Col.x, Col.y, Col.z)).. ">" .. markup.Escape(TextStr), 536)
    local BlackText = markup.Parse("<font=TextscreenFont>" .. "<color="..markup.Color(Color(0, 0, 0)).. ">" .. markup.Escape(TextStr), 536)

    DisplayAng:RotateAroundAxis(DisplayAng:Up(), self.DrawAngles.x)
    DisplayAng:RotateAroundAxis(DisplayAng:Right(), self.DrawAngles.y)
    DisplayAng:RotateAroundAxis(DisplayAng:Forward(), self.DrawAngles.z)

    cam.Start3D2D(
    	self:LocalToWorld(self.DrawPos), 
    	DisplayAng,  
    	math.Remap( 13, 10, 32, 0.10, 0.32 )
    )

        for x = -1*self.OutlineWidht, 1*self.OutlineWidht do
            for y = -1*self.OutlineWidht, 1*self.OutlineWidht do
                if y == x != 0 then
                    BlackText:Draw( x, y, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_CENTER )
                end
            end
        end

        Text:Draw( 0, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end
