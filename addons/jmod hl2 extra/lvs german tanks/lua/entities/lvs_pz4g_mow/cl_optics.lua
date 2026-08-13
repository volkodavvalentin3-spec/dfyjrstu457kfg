
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

local axis = Material( "lvs/axis.png" )
local sight = Material( "lvs/shermansights.png" )
local scope = Material( "lvs/scope_viewblocked.png" )

function ENT:PaintOpticsCrosshair( Pos2D )

end

local OldType = nil

function ENT:PaintOptics( Pos2D, Col, PodIndex, Type )
	local ID = self:LookupAttachment(  "muzzle" )

	local Muzzle = self:GetAttachment( ID )

	if not Muzzle then return end

	local traceTurret = util.TraceLine( {
		start = Muzzle.Pos,
		endpos = Muzzle.Pos + Muzzle.Ang:Up() * 50000,
		filter = self:GetCrosshairFilterEnts()
	} )

	local MuzzlePos2D = traceTurret.HitPos:ToScreen() 

	surface.SetMaterial( sight )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( MuzzlePos2D.x - 210, MuzzlePos2D.y - 23, 420, 420 )

	surface.SetMaterial( axis )
	surface.SetDrawColor( 255, 255, 255, 25 )
	surface.DrawTexturedRect( MuzzlePos2D.x - 7, MuzzlePos2D.y - 7, 16, 16 )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( MuzzlePos2D.x - 8, MuzzlePos2D.y - 8, 16, 16 )
	
	local size = self.OpticsCrosshairSize

	surface.SetMaterial( self.OpticsCrosshairMaterial )
	surface.SetDrawColor( self.OpticsCrosshairColor )
	surface.DrawTexturedRect( Pos2D.x - size * 0.5, Pos2D.y - size * 0.5, size, size )

	if Type == 1 then
		self:DrawRotatedText( "MG", MuzzlePos2D.x + 30, MuzzlePos2D.y + 10, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	else
		self:DrawRotatedText( Type == 3 and "HE" or "AP", MuzzlePos2D.x + 30, MuzzlePos2D.y + 10, "LVS_FONT_PANEL", Color(0,0,0,220), 0)
	end

	if OldType ~= Type then
		OldType = Type
		surface.PlaySound( "lvs/optics.wav" )
	end

	local ScrW = ScrW()
	local ScrH = ScrH()

	local diameter = ScrH + 64
	local radius = diameter * 0.5

	surface.SetMaterial( scope )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( Pos2D.x - radius, Pos2D.y - radius, diameter, diameter )

	-- black bar left + right
	surface.DrawRect( 0, 0, Pos2D.x - radius, ScrH )
	surface.DrawRect( Pos2D.x + radius, 0, Pos2D.x - radius, ScrH )
end
