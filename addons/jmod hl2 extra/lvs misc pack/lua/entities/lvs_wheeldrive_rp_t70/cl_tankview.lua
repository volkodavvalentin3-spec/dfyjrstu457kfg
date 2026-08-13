include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( ply, pos, angles, fov, pod )




	if ply == self:GetDriver() and not pod:GetThirdPersonMode() then

		local ID = self:LookupAttachment( "eye_driver" )
		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Up() * -1 - Muzzle.Ang:Forward() * 0 - Muzzle.Ang:Right() * 0
		end
	end

	if pod == self:GetGunnerSeat() then

		angles = ply:EyeAngles() -- this will unlock the camera from tank rotation. See init.lua line 39 for server

		if not pod:GetThirdPersonMode() then
			if ply:lvsKeyDown( "ZOOM" ) then

				local ID = self:LookupAttachment( "eye" )

				local Muzzle = self:GetAttachment( ID )

				if Muzzle then
					pos =  Muzzle.Pos
				end

			else

				local ID = self:LookupAttachment( "gunner" )

				local Muzzle = self:GetAttachment( ID )

				if Muzzle then
					pos =  Muzzle.Pos - Muzzle.Ang:Up() * -0.6 - Muzzle.Ang:Forward() * -2 - Muzzle.Ang:Right() * 36.5
				end

			end
		end
	end

	return pos, angles, fov
end

function ENT:CalcViewPassenger( ply, pos, angles, fov, pod )
	return self:CalcTankView( ply, pos, angles, fov, pod )
end
