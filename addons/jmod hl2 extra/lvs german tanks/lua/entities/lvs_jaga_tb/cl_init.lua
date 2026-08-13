include("shared.lua")
include("sh_tracks.lua")
include("sh_turret.lua")
include("cl_optics.lua")
include("cl_tankview.lua")
include("cl_attached_playermodels.lua")

local switch = Material("lvs/weapons/change_ammo.png")
local APFSDS = Material("lvs/weapons/bullet_ap.png")
local HE = Material("lvs/weapons/tank_cannon.png")
local HEATFS = Material("lvs/weapons/tank_heat.png")
function ENT:DrawWeaponIcon( PodID, ID, x, y, width, height, IsSelected, IconColor )
	if self:GetUseHighExplosive() == 0 then
		local Icon = self:GetUseHighExplosive() and APFSDS 
		surface.SetMaterial( Icon )
	elseif self:GetUseHighExplosive() == 1 then
		local Icon = self:GetUseHighExplosive() and HE
		surface.SetMaterial( Icon )
	end
	surface.DrawTexturedRect( x, y, width, height )
	
	if self:GetUseHighExplosive() == 3 then self:SetUseHighExplosive(0) end
	
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
		self:EmitSound( "lvs/vehicles/tiger/engine_start.wav", 75, 100,  LVS.EngineVolume )
	else
		self:EmitSound( "lvs/vehicles/tiger/engine_stop.wav", 75, 100,  LVS.EngineVolume )
	end
end

function ENT:OnSpawn()
	self:CreateBonePoseParameter( "hatch_d", 39, Angle(0,0,0), Angle(180,0,0), Vector(0,0,0), Vector(0,0,0) )
	self:CreateBonePoseParameter( "hatch_g", 40, Angle(0,0,0), Angle(0,-90,0), Vector(0,0,0), Vector(0,0,0) )
	self:CreateBonePoseParameter( "hatch_c", 123, Angle(0,0,0), Angle(110,0,0), Vector(0,0,0), Vector(0,0,0) )
	self:CreateBonePoseParameter( "hatch_c_part", 124, Angle(0,0,0), Angle(105,0,0), Vector(0,0,0), Vector(0,0,0) )
end
