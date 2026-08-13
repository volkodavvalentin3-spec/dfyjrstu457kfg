include("shared.lua")
include("sh_tracks.lua")
include("sh_turret.lua")
include("cl_optics.lua")
include("cl_tankview.lua")

local switch = Material("lvs/weapons/change_ammo.png")
local AP = Material("lvs/weapons/bullet_ap.png")
local HE = Material("lvs/weapons/tank_cannon.png")
function ENT:DrawWeaponIcon( PodID, ID, x, y, width, height, IsSelected, IconColor )
	local Icon = self:GetUseHighExplosive() and HE or AP

	surface.SetMaterial( Icon )
	surface.DrawTexturedRect( x, y, width, height )

	local ply = LocalPlayer()

	if not IsValid( ply ) or self:GetSelectedWeapon() ~= 2 then return end

	surface.SetMaterial( switch )
	surface.DrawTexturedRect( x + width + 5, y + 7, 24, 24 )

	local buttonCode = ply:lvsGetControls()[ "CAR_SWAP_AMMO" ]

	if not buttonCode then return end

	local KeyName = input.GetKeyName( buttonCode )

	if not KeyName then return end

	draw.DrawText( KeyName, "DermaDefault", x + width + 17, y + height * 0.5 + 7, Color(0,0,0,IconColor.a), TEXT_ALIGN_CENTER )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/sherman/engine_start.wav", 75, 100,  LVS.EngineVolume )
	end
end
 
 
function ENT:DrawGunner()
	local pod = self:GetGunnerSeat()

	if not IsValid( pod ) then self:RemovePlayerModel( "driver" ) return end

	local plyL = LocalPlayer()
	local ply = pod:GetDriver()

	if not IsValid( ply ) or (ply == plyL and not pod:GetThirdPersonMode()) then self:RemovePlayerModel( "driver" ) return end

	local model = self:CreatePlayerModel( ply, "driver" )
	
	local ID = self:LookupAttachment( "mg_yaw" )
	local Muzzle = self:GetAttachment( ID )

	local Pos,Ang = LocalToWorld( Vector(-45,0,-3), Angle(-90,0,-90), Muzzle.Pos, Muzzle.Ang )
	
	local LAng = self:WorldToLocalAngles( Ang )
	local LPos = self:WorldToLocal( Pos )
	LAng.p = 0
	LAng.r = 0

	model:SetSequence( "idle_all_01" )
	model:SetRenderOrigin( self:LocalToWorld( LPos ) )
	model:SetRenderAngles( self:LocalToWorldAngles( LAng ) )
	model:DrawModel()
end