
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local WheelModel = "models/simer/prop/zis_wheel.mdl"

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_NONE,
			SteerAngle = 0,
			BrakeFactor = 1,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(-10,28,0),
				mdl = WheelModel,
				mdl_ang = Angle(0,0,0),
			} ),

			self:AddWheel( {
				pos = Vector(-10,-28,0),
				mdl = WheelModel,
				mdl_ang = Angle(0,180,0),

			} ),
		},
			Suspension = {
			Height = 10,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 70000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )


	self:AddTrailerHitch( Vector(75.7,0,7.4), LVS.HITCHTYPE_FEMALE )
	
	

end
