AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(20,15,35), Angle(0,-95,-8) )
	local PassengerSeat = self:AddPassengerSeat( Vector(35,-12,40), Angle(0,-95,0) )
	local PassengerSeat1 = self:AddPassengerSeat( Vector(0,-35,45), Angle(0,0,0) )
	local PassengerSeat2 = self:AddPassengerSeat( Vector(-30,-33,45), Angle(0,0,0) )
	local PassengerSeat3 = self:AddPassengerSeat( Vector(-60,-33,45), Angle(0,0,0) )
    local PassengerSeat4 = self:AddPassengerSeat( Vector(-90,-33,45), Angle(0,0,0) )
	local PassengerSeat5 = self:AddPassengerSeat( Vector(0,33,45), Angle(0,180,0) )
	local PassengerSeat6 = self:AddPassengerSeat( Vector(-30,33,45), Angle(0,180,0) )
	local PassengerSeat7 = self:AddPassengerSeat( Vector(-60,33,45), Angle(0,180,0) )
    local PassengerSeat8 = self:AddPassengerSeat( Vector(-90,33,45), Angle(0,180,0) )
	
	

    self:AddEngine( Vector(86,0,34.5) )

	local FuelTank = self:AddFuelTank( Vector(87.06,0,13.92), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )
	FuelTank:SetDoorHandler( FuelCap )

	
	local WheelModel = "models/simer/opel/vorosh_wheels.mdl"


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
				pos = Vector(79,-35,25),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
			} ),

			self:AddWheel( {
				pos = Vector(79,35,25),
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

    local WheelModel = "models/simer/opel/vorosh_wheels_2.mdl"

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
				pos = Vector(-60.5,-36,32),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
			} ),

			self:AddWheel( {
				pos = Vector(-60.5,39,32),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),
		},
		Suspension = {
			Height = 27,
			MaxTravel = 7,
			ControlArmLength = 125,
			SpringConstant = 40000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

	self:AddTrailerHitch( Vector(-114,1,25), LVS.HITCHTYPE_MALE )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/halftrack/engine_start.wav" )
	end
end