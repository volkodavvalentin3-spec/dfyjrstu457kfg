
ENT.OpticsFov = 30
ENT.OpticsEnable = true
ENT.OpticsZoomOnly = true
ENT.OpticsFirstPerson = true
ENT.OpticsThirdPerson = false
ENT.OpticsPodIndex = {
	[1] = true,
}

ENT.OpticsCrosshairMaterial = Material( "lvs/circle_filled.png" )
ENT.OpticsCrosshairColor = Color(0,0,0,150)
ENT.OpticsCrosshairSize = 4

ENT.OpticsProjectileSize = 7.5

local OldTargetOffset = 0
local RotationOffset = 0
local circle = Material( "lvs/circle_hollow.png" )
local tri1 = Material( "lvs/triangle1.png" )
local tri2 = Material( "lvs/triangle2.png" )
local pointer = Material( "gui/point.png" )
local scope = Material( "scops/is2.png" )


function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	if Type == 1 then
		self:DrawRotatedText( "ДТ", Pos2D.x + 30, Pos2D.y + 30, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	else
		self:DrawRotatedText( Type == 3 and "ОФ" or "БР", Pos2D.x + 30, Pos2D.y + 30, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	end

	local size = self.OpticsCrosshairSize

	

	local H05 = ScrH() * 0.5

	local ScrW = ScrW()
	local ScrH = ScrH()

	local diameter = ScrH + 64
	local radius = diameter * 0.5

	local Ro = math.min(self:WorldToLocal( self:GetEyeTrace().HitPos ):Length() / 50000,1) * 90

	local R1 = math.rad( 100 + Ro )
	local R2 = math.rad( 260 - Ro )

	local X1 = math.sin( R1 ) * H05
	local Y1 = math.cos( R1 ) * H05
	local X2 = math.sin( R2 ) * H05



	local Cstart = Pos2D.x - H05 * 0.4
	local Ystart = Pos2D.y - H05 * 0.15
	local xSwap = true

	

	



	surface.SetMaterial( scope )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )

	-- black bar left + right
	surface.DrawRect( 0, 0, Pos2D.x - radius, ScrH )
	surface.DrawRect( Pos2D.x + radius, 0, Pos2D.x - radius, ScrH )
end