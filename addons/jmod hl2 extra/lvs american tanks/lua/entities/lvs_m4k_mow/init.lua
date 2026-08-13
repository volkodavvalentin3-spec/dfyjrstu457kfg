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
	local ID = self:LookupAttachment( "machinegun" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMGf = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGf:SetSoundLevel( 95 )
	self.SNDTurretMGf:SetParent( self, ID )

	local ID = self:LookupAttachment( "turret_machinegun" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local ID = self:LookupAttachment( "turret_cannon" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/cannon_fire.wav", "lvs/vehicles/sherman/cannon_fire.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(23,-25,65), Angle(0,-90,0) )
	

	local GunnerSeat = self:AddPassengerSeat( Vector(38,15,65), Angle(0,-90,0) )
	
	 local Seat1 = self:AddPassengerSeat( Vector(-18,26,55), Angle(0,-90,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-18,-26,55), Angle(0,-90,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(18,0,50), Angle(0,-90,0) )
	Seat3.HidePlayer = false
	
	
	self:SetGunnerSeat( GunnerSeat )

		self:AddEngine( Vector(-79.66,0,70), Angle(0,180,0) )
	self:AddFuelTank( Vector(-75,0,40), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(0,-20,-18),Vector(18,20,18) )

		-- front upper wedge center
	self:AddArmor( Vector(100,0,0), Angle(-40,0,0), Vector(0,-55,0), Vector(45,55,20), 600, self.FrontArmor )
	self:AddArmor( Vector(70,0,55), Angle(40,0,0), Vector(-20,-55,-20), Vector(55,55,20), 600, self.FrontArmor )
	

	-- side armor left front
	self:AddArmor( Vector(0,33,62), Angle(0,0,0), Vector(-95,-40,-40), Vector(75,25,17), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(0,-41,62), Angle(0,0,0), Vector(-95,-15,-40), Vector(75,40,17), 600, self.SideArmor )

	
	-- top armor
	
	self:AddArmor( Vector(-100,-6,47), Angle(-25,0,0), Vector(-11,-28,0), Vector(16,40,10), 300, self.RearArmor )

	

	-- rear up
	self:AddArmor( Vector(-123,0,13), Angle(0,0,0), Vector(10,-55,7),Vector(30,55,60), 600, self.SideArmor )
	


	-- trailer hitch
	self:AddTrailerHitch( Vector(-100,0,24), LVS.HITCHTYPE_MALE )
end
