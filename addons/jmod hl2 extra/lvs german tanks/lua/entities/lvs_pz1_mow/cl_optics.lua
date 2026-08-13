
ENT.OpticsFov = 30
ENT.OpticsEnable = true
ENT.OpticsZoomOnly = true
ENT.OpticsFirstPerson = true
ENT.OpticsThirdPerson = false
ENT.OpticsPodIndex = {
	[1] = true,
}

local OldTargetOffset = 0
local RotationOffset = 0

local tri1 = Material( "lvs/triangle1.png" )
local tri2 = Material( "lvs/triangle2.png" )
local pointer = Material( "gui/point.png" )


function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	surface.SetDrawColor( 255, 255, 255, 5 )
	surface.SetMaterial( tri1 )
	surface.DrawTexturedRect( Pos2D.x - 17, Pos2D.y - 1, 32, 32 )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( Pos2D.x - 16, Pos2D.y, 32, 32 )

	if Type == 1 then
		self:DrawRotatedText( "MG", Pos2D.x + 30, Pos2D.y + 30, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	else
		self:DrawRotatedText( Type == 3 and "HE" or "AP", Pos2D.x + 30, Pos2D.y + 30, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	end

	local ScrW = ScrW()
	local ScrH = ScrH()

	for i = -3, 3, 1 do
		if i == 0 then continue end

		surface.SetMaterial( tri2 )
		surface.SetDrawColor( 255, 255, 255, 5 )
		surface.DrawTexturedRect( Pos2D.x - 11 + i * 32, Pos2D.y - 1, 20, 20 )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawTexturedRect( Pos2D.x - 10 + i * 32, Pos2D.y, 20, 20 )
	end

	surface.SetDrawColor( 0, 0, 0, 200 )

	local TargetOffset = self:GetSelectedWeapon() == 1 and 150 or 0

	if OldTargetOffset ~= TargetOffset then
		OldTargetOffset = TargetOffset
		surface.PlaySound( "lvs/optics.wav" )
	end



	

	

	

	
end

