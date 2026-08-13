
include("entities/lvs_tank_wheeldrive/modules/sh_turret.lua")

ENT.TurretAimRate = 25

ENT.TurretRotationSound = "common/null.wav"

ENT.TurretPitchPoseParameterName = "cannon_pitch"
ENT.TurretPitchMin = -25
ENT.TurretPitchMax = 8
ENT.TurretPitchMul = -1
ENT.TurretPitchOffset = 0

ENT.TurretYawPoseParameterName = "cannon_yaw"
ENT.TurretYawMin = -20
ENT.TurretYawMax = 20
ENT.TurretYawMul = 1
ENT.TurretYawOffset = 0