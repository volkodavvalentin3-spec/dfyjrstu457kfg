
include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")

ENT.TurretAimRate = 12

ENT.TurretRotationSound = "vehicles/tank_turret_loop1.wav"

ENT.TurretPitchPoseParameterName = "can_aim_pitch"
ENT.TurretPitchMin = -8
ENT.TurretPitchMax = 16
ENT.TurretPitchMul = -1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "can_aim_yaw"
ENT.TurretYawMul = 1
ENT.TurretYawOffset = 0
ENT.TurretYawMin = -10
ENT.TurretYawMax = 10


if CLIENT then
    function ENT:CalcTurret()
        local pod = self:GetWeaponSeat()
        if not IsValid( pod ) then return end

        local plyL = LocalPlayer()
        local ply = pod:GetDriver()

        if ply ~= plyL then return end

        self:AimTurret()
    end
end