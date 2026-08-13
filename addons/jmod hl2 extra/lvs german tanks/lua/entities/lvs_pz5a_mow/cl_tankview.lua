
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( ply, pos, angles, fov, pod )
	if ply == self:GetDriver() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "cannon_view" )

		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Up() * 0 + Muzzle.Ang:Forward() * 0 - Muzzle.Ang:Right() * 0
		end

	end
	
	if pod == self:GetFrontGunnerSeat() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "mgh_view" )

		local EyeAttach = self:GetAttachment( ID )

		if EyeAttach then
			--EyeAttach.Pos + EyeAttach.Ang:Right() * -0.4 + EyeAttach.Ang:Forward() * -5) * Zoom
			pos = EyeAttach.Pos + EyeAttach.Ang:Up() * 0 + EyeAttach.Ang:Forward() * -5 + EyeAttach.Ang:Right() * -5
		end
	end
	
	if pod == self:GetTopGunnerSeat() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "mgc_view" )

		local EyeAttach = self:GetAttachment( ID )

		if EyeAttach then
			--EyeAttach.Pos + EyeAttach.Ang:Right() * -0.4 + EyeAttach.Ang:Forward() * -5) * Zoom
			pos = EyeAttach.Pos + EyeAttach.Ang:Up() * 0.5 + EyeAttach.Ang:Forward() * -20 + EyeAttach.Ang:Right() * 2
		end
	end

	return pos, angles, fov
end
