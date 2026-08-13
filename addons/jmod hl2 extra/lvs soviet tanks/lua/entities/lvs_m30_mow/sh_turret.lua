
include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")

ENT.TurretAimRate = 15

ENT.TurretRotationSound = "common/null.wav"

ENT.TurretPitchPoseParameterName = "cannon_pitch"
ENT.TurretPitchMin = -27
ENT.TurretPitchMax = 2
ENT.TurretPitchMul = -1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "cannon_yaw"
ENT.TurretYawMin = -25
ENT.TurretYawMax = 25
ENT.TurretYawMul = 1
ENT.TurretYawOffset = 0