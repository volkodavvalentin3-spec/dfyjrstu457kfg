AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_tracks.lua" )
AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_optics.lua" )
AddCSLuaFile( "cl_tankview.lua" )
include("shared.lua")
include("sh_tracks.lua")
include("sh_turret.lua")

function ENT:OnSpawn( PObj )
	local ID = self:LookupAttachment( "muzzle_machinegun" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMGf = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGf:SetSoundLevel( 95 )
	self.SNDTurretMGf:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/76mm_l11.wav", "weapons/76mm_l11.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(10,15,20), Angle(0,-90,0) )
	DriverSeat.HidePlayer = false
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(-15,0,60), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = false
	self:SetGunnerSeat( GunnerSeat )
	
	
    local Seat1 = self:AddPassengerSeat( Vector(15,-15,30), Angle(0,-90,0) )

	local Seat2 = self:AddPassengerSeat( Vector(-21,-17,35), Angle(0,0,0) )
	
	local Seat3 = self:AddPassengerSeat( Vector(-43,-17,35), Angle(0,0,0) )
	
	local Seat4 = self:AddPassengerSeat( Vector(-63,-17,35), Angle(0,0,0) )

	local Seat5 = self:AddPassengerSeat( Vector(-83,-17,35), Angle(0,0,0) )

	local Seat6 = self:AddPassengerSeat( Vector(-21,17,35), Angle(0,180,0) )
	
	local Seat7 = self:AddPassengerSeat( Vector(-43,17,35), Angle(0,180,0) )
	
	local Seat8 = self:AddPassengerSeat( Vector(-63,17,35), Angle(0,180,0) )

	local Seat9 = self:AddPassengerSeat( Vector(-83,17,35), Angle(0,180,0) )
	
	
	
	local WheelModel = "models/simer/prop/Whhanomag.mdl"

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 30,
			TorqueFactor = 0.5,
			BrakeFactor = 1,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(97,-35,17),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),

			self:AddWheel( {
				pos = Vector(97,35,17),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),
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

	self:AddEngine( Vector(79.66,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(55,0,50), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(0,-20,-18),Vector(18,20,18) )

	self:AddArmor( Vector(-10,0,60), Angle(0,0,0), Vector(-120,-50,-40), Vector(56,50,35), 800, self.SideArmor )
	self:AddArmor( Vector(110,0,55), Angle(5,0,0), Vector(-70,-35,-30), Vector(20,35,15), 800, self.FrontArmor )

	-- trailer hitch
	self:AddTrailerHitch( Vector(-130,0,34), LVS.HITCHTYPE_MALE )
end
