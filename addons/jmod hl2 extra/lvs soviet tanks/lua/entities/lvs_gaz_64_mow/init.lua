AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(-38,15,25), Angle(0,-95,-8) )
	local PassengerSeat = self:AddPassengerSeat( Vector(-20,-12,30), Angle(0,-95,0) )
	local PassengerSeat1 = self:AddPassengerSeat( Vector(-60,-10,35), Angle(0,-95,0) )
	local PassengerSeat2 = self:AddPassengerSeat( Vector(-60,10,35), Angle(0,-95,0) )

	
	

	self:AddEngine( Vector(46,0,34.5) )

	local FuelTank = self:AddFuelTank( Vector(47.06,0,17.92), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )
	FuelTank:SetDoorHandler( FuelCap )

	
	local WheelModel = "models/simer/prop/ba64_wh.mdl"


	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 30,
			TorqueFactor = 0,
			BrakeFactor = 1,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(53,-32,25),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),

			self:AddWheel( {
				pos = Vector(53,32,25),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),

			} ),
		},
		Suspension = {
			Height = 35,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 20000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )


	local RearAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_NONE,
			TorqueFactor = 1,
			BrakeFactor = 1,
			UseHandbrake = true,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(-44,-32,22),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),

			self:AddWheel( {
				pos = Vector(-44,32,22),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
			} ),
		},
		Suspension = {
			Height = 20,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 40000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

	self:AddTrailerHitch( Vector(-90,0,19), LVS.HITCHTYPE_MALE )
end
