ENT.OpticsFov = 50
ENT.OpticsEnable = true
ENT.OpticsZoomOnly = true
ENT.OpticsFirstPerson = true
ENT.OpticsThirdPerson = false
ENT.OpticsPodIndex = nil -- do not put a table here, lua inheritance will FUCK it up

local axis = Material( "lvs/circle_hollow.png" )
local sight = Material( "lvs/shermansights.png" )
local scope = Material( "weapons/scope_filled.png" )

function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	surface.SetMaterial( axis )
	surface.SetDrawColor( 255, 255, 255, 1 )
	surface.DrawTexturedRect( Pos2D.x, Pos2D.y, 16, 16 )
	surface.SetDrawColor( 0, 0, 0, 255, 1 )
	surface.DrawTexturedRect( Pos2D.x - 8, Pos2D.y, 16, 16 )

	surface.SetMaterial( sight )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( Pos2D.x - 210, Pos2D.y - 23, 420, 420 )

	self:DrawRotatedText( self.WeaponName, Pos2D.x + 55, Pos2D.y + 10, "LVS_FONT_PANEL", Color(0,0,0,220), 0)

	local diameter = ScrH()
	local radius = diameter * 0.5

	surface.SetMaterial( scope )
	surface.SetDrawColor( 0, 0, 0, 50 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )
end