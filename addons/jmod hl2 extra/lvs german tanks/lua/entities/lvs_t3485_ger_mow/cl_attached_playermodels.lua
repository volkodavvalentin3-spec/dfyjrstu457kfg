
include("entities/lvs_tank_wheeldrive/modules/cl_attachable_playermodels.lua")

function ENT:DrawTopGunner()
	local pod = self:GetTopGunnerSeat()

	if not IsValid( pod ) then self:RemovePlayerModel( "gunner" ) return end

	local plyL = LocalPlayer()
	local ply = pod:GetDriver()

	if not IsValid( ply ) or (ply == plyL and not pod:GetThirdPersonMode()) then self:RemovePlayerModel( "gunner" ) return end

	local ID = self:LookupAttachment( "smoke" )
	local Att = self:GetAttachment( ID )

	if not Att then self:RemovePlayerModel( "gunner" ) return end

	local Pos,Ang = LocalToWorld( Vector(-33,-35,18), Angle(-math.Remap( self:GetPoseParameter( "mgc_aim_yaw" ), 0, 1,5, 5 ),0,-90), Att.Pos, Att.Ang )

	local model = self:CreatePlayerModel( ply, "gunner" )

	model:SetSequence( "idle_all_01" )
	model:SetRenderOrigin( Pos - Ang:Forward() )
	model:SetRenderAngles( Ang )
	model:DrawModel()
end


function ENT:PreDraw()
	self:DrawTopGunner()

	return true
end
