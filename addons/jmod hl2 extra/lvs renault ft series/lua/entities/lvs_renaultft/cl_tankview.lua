
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

function ENT:TankViewOverride( ply, pos, angles, fov, pod )
	if pod == self:GetWeaponSeat() and not pod:GetThirdPersonMode() then
		local ID = self:LookupAttachment( "gunview" ) -- muzzle_turret
		local Muzzle = self:GetAttachment( ID )
		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Up() * -5 - Muzzle.Ang:Forward() * 3 - Muzzle.Ang:Right() * 5
		end
	end

	return pos, angles, fov
end

function ENT:CalcViewDriver( ply, pos, angles, fov, pod )
	if pod ~= self:GetWeaponSeat() and not pod:GetThirdPersonMode() then
		pos = pos + pod:GetRight() * -44
	end

	if ply:lvsMouseAim() then
		angles = ply:EyeAngles()
		return self:CalcViewMouseAim( ply, pos, angles,  fov, pod )
	else
		return self:CalcViewDirectInput( ply, pos, angles,  fov, pod )
	end
end

function ENT:CalcViewPassenger(ply, pos, angles, fov, pod)
	if pod == self:GetGunnerSeat() and pod ~= self:GetWeaponSeat() then
		local ID = self:LookupAttachment( "gunview" )

		local Muzzle = self:GetAttachment( ID )

		if Muzzle then
			pos =  Muzzle.Pos - Muzzle.Ang:Up() * -5 - Muzzle.Ang:Forward() * 3 - Muzzle.Ang:Right() * 5
		end
	elseif not pod:GetThirdPersonMode() then
		angles = pod:LocalToWorldAngles( ply:EyeAngles() )
	end

	return self:CalcTankView( ply, pos, angles, fov, pod )
end