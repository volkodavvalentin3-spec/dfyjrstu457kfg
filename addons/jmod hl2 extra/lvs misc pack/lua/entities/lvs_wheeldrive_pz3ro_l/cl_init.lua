include("shared.lua")

ENT.TrackLeftSubMaterialID = 2
ENT.TrackRightSubMaterialID = 3

ENT.OpticsProjectileSize = 3.7

function ENT:OnSpawn()
	self:CreateBonePoseParameter( "hatch_driver", 26, Angle(0,0,0), Angle(120,0,0), Vector(0,0,0), Vector(0,0,0) )
	self:CreateBonePoseParameter( "hatch_radio", 25, Angle(0,0,0), Angle(120,0,0), Vector(0,0,0), Vector(0,0,0) )
end

function ENT:TankGunnerViewOverride( ply, pos, angles, fov, pod )
	if pod == self:GetTopGunnerSeat() and not pod:GetThirdPersonMode() then
		pod:SetThirdPersonMode( true )
	end

	return pos, angles, fov
end
