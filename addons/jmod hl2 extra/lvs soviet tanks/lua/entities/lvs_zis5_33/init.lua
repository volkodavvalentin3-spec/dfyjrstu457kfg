AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(30,15,8), Angle(0,-95,-8) )
	local PassengerSeat = self:AddPassengerSeat( Vector(50,-12,15), Angle(0,-95,0) )
	local PassengerSeat1 = self:AddPassengerSeat( Vector(12,-27,31), Angle(0,90,0) )
	local PassengerSeat2 = self:AddPassengerSeat( Vector(12,-1,31), Angle(0,90,0) )
	local PassengerSeat3 = self:AddPassengerSeat( Vector(12,27,31), Angle(0,90,0) )
    local PassengerSeat4 = self:AddPassengerSeat( Vector(-30,-27,31), Angle(0,-90,0) )
	local PassengerSeat5 = self:AddPassengerSeat( Vector(-30,-1,31), Angle(0,-90,0) )
	local PassengerSeat6 = self:AddPassengerSeat( Vector(-30,27,31), Angle(0,-90,0) )
	local PassengerSeat7 = self:AddPassengerSeat( Vector(-65,-27,31), Angle(0,-90,0) )
	local PassengerSeat8 = self:AddPassengerSeat( Vector(-65,-1,31), Angle(0,-90,0) )
	local PassengerSeat9 = self:AddPassengerSeat( Vector(-65,27,31), Angle(0,-90,0) )
	local PassengerSeat10 = self:AddPassengerSeat( Vector(-95,-27,31), Angle(0,-90,0) )
	local PassengerSeat11 = self:AddPassengerSeat( Vector(-95,-1,31), Angle(0,-90,0) )
	local PassengerSeat12 = self:AddPassengerSeat( Vector(-95,27,31), Angle(0,-90,0) )
	
	

	self:AddEngine( Vector(96,0,34.5) )

	local FuelTank = self:AddFuelTank( Vector(97.06,0,13.92), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )
	FuelTank:SetDoorHandler( FuelCap )

	
	local WheelModel = "models/simer/prop/si5wh.mdl"


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
				pos = Vector(120,-30,-2),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
			} ),

			self:AddWheel( {
				pos = Vector(120,30,-2),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),

			} ),
		},
		Suspension = {
			Height = 29,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 20000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

    local WheelModel = "models/simer/prop/si5wh2.mdl"

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
				pos = Vector(-37.5,-38,0),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
			} ),

			self:AddWheel( {
				pos = Vector(-37.5,38,0),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),
		},
		Suspension = {
			Height = 15,
			MaxTravel = 7,
			ControlArmLength = 125,
			SpringConstant = 40000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

	self:AddTrailerHitch( Vector(-84,0,5), LVS.HITCHTYPE_MALE )
end
