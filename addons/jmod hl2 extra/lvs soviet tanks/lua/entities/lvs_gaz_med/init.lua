AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "sh_turret.lua" )


include("shared.lua")
include("sh_turret.lua")



-- since this is based on a tank we need to reset these to default var values:
ENT.DSArmorDamageReductionType = DMG_BULLET + DMG_CLUB
ENT.DSArmorIgnoreDamageType = DMG_SONIC


function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(0,10,30), Angle(0,-90,0) )
	local PassengerSeat = self:AddPassengerSeat( Vector(15,-10,37), Angle(0,-90,10) )

	self.HornSND = self:AddSoundEmitter( Vector(40,0,35), "weapons/zonk.wav" )
	self.HornSND:SetSoundLevel( 75 )
	self.HornSND:SetDoppler( true )

	local DoorHandler = self:AddDoorHandler( "left_door", Vector(20,30,48), Angle(0,0,0), Vector(-17,-3,-12), Vector(20,6,12), Vector(-17,-15,-12), Vector(20,30,12) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( DriverSeat )

	local DoorHandler = self:AddDoorHandler( "right_door", Vector(20,-30,48), Angle(0,180,0), Vector(-17,-3,-12), Vector(20,6,12), Vector(-17,-15,-12), Vector(20,30,12) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( PassengerSeat )

    local DoorHandler = self:AddDoorHandler( "trunk", Vector(-125,0,60), Angle(0,0,0), Vector(-1,-25,-15), Vector(1,25,25), Vector(-30,-25,-25), Vector(1,15,15) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( PassengerSeat )
	
	local PassengerSeat2 = self:AddPassengerSeat( Vector(-40,-35,52), Angle(0,0,0) )
	local PassengerSeat3 = self:AddPassengerSeat( Vector(-70,-35,52), Angle(0,0,0) )
    local PassengerSeat4 = self:AddPassengerSeat( Vector(-100,-35,52), Angle(0,0,0) )
	


	self:AddEngine( Vector(68,0,50) )
	self:AddFuelTank( Vector(55,0,18), Angle(0,0,0), 600, LVS.FUELTYPE_DIESEL )

	self.SNDTurretMG = self:AddSoundEmitter( Vector(-63,0,85), "weapons/loope.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )

local WheelModel = "models/simer/prop/zis_wheel.mdl"


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
				pos = Vector(85,-30,20),
				mdl = WheelModel,
				mdl_ang = Angle(0,180,0),
			} ),

			self:AddWheel( {
				pos = Vector(85,30,20),
				mdl = WheelModel,
				mdl_ang = Angle(0,0,0),

			} ),
		},
		Suspension = {
			Height = 10,
			MaxTravel = 7,
			ControlArmLength = 25,
			SpringConstant = 20000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )

    local WheelModel = "models/simer/prop/zis_wheel2.mdl"

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
				pos = Vector(-63.5,-28,20),
				mdl = WheelModel,
				mdl_ang = Angle(0,180,0),
			} ),

			self:AddWheel( {
				pos = Vector(-63.5,28,20),
				mdl = WheelModel,
				mdl_ang = Angle(0,0,0),
			} ),
		},
		Suspension = {
			Height = 10,
			MaxTravel = 7,
			ControlArmLength = 125,
			SpringConstant = 40000,
			SpringDamping = 2000,
			SpringRelativeDamping = 2000,
		},
	} )



end

