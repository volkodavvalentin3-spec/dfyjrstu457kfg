
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
local axis = Material( "lvs/axis.png" )
local tri1 = Material( "lvs/triangle1.png" )
local tri2 = Material( "lvs/triangle2.png" )
local scope = Material( "scops/t34.png" )

function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )




	if Type == 1 then
		self:DrawRotatedText( "ДТ", Pos2D.x + 400, Pos2D.y + 30, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	else
		self:DrawRotatedText( Type == 3 and "ОФ" or "БР", Pos2D.x + 400, Pos2D.y + 10, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	end

	local H05 = ScrH() * 0.5

	local diameter = ScrH()
	local radius = H05

	surface.SetMaterial( scope )
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )





	

	
end