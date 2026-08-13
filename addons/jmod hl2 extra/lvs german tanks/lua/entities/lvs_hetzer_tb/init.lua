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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/75mm_kwk42.wav", "weapons/75mm_kwk42.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(20,-20,40), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(0,20,55), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	

	self:AddEngine( Vector(-70,20,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,-20,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-10,-10,0),Vector(30,10,35) )

	-- front upper wedge center
	

	
	self:AddArmor( Vector(73,0,50), Angle(33,0,0), Vector(-50,-50,0), Vector(25,50,10), 1300, self.FrontArmor )
	self:AddArmor( Vector(80,0,30), Angle(130,0,0), Vector(-10,-39,0), Vector(15,39,10), 1300, self.FrontArmor )
	

	-- side armor left
	self:AddArmor( Vector(10,32,65), Angle(0,0,35), Vector(-99,5,-20), Vector(50,15,13), 800, self.SideArmor )
	self:AddArmor( Vector(10,38,45), Angle(0,0,0), Vector(-99,5,-20), Vector(80,15,13), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(10,-32,65), Angle(0,0,-35), Vector(-99,-15,-20), Vector(50,-5,13), 800, self.SideArmor )
	self:AddArmor( Vector(10,-38,45), Angle(0,0,0), Vector(-99,-15,-20), Vector(80,-5,13), 800, self.SideArmor )

	-- rear very down
	self:AddArmor( Vector(-90,0,40), Angle(5,0,0), Vector(-5,-45,-25), Vector(5,45,19), 1200, self.FrontArmor )
	
	self:AddArmor( Vector(-50,0,65), Angle(70,0,0), Vector(-5,-45,-31), Vector(5,45,31), 1200, self.FrontArmor )
	
	self:AddTrailerHitch( Vector(-90,0,22), LVS.HITCHTYPE_MALE )
	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-10,-30.13,55), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(-10,30.13,55), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	
	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end
