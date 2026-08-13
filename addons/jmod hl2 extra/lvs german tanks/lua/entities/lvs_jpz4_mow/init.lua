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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/tiger/cannon_fire.wav", "lvs/vehicles/tiger/cannon_fire.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(20,10,40), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(60,-40,35), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	local Seat1 = self:AddPassengerSeat( Vector(-55,35,60), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-55,-35,60), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-85,35,60), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-85,-35,60), Angle(0,180,0) )
	Seat4.HidePlayer = false

	self:AddEngine( Vector(-70,20,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,-20,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-10,-10,0),Vector(30,10,35) )

	-- front upper wedge center
	self:AddArmor( Vector(35,0,79), Angle(40,0,0), Vector(8,-60,-10), Vector(50,60,10), self.FrontArmorHP, self.FrontArmor )

	
	self:AddArmor( Vector(93,0,38), Angle(10,0,0), Vector(-24,-60,0), Vector(15,60,10), self.FrontArmorHP, self.FrontArmor )
	self:AddArmor( Vector(105,0,30), Angle(40,0,0), Vector(-10,-60,-15), Vector(15,60,15), self.FrontArmorHP, self.FrontArmor )
	

	-- side armor left
	self:AddArmor( Vector(10,40,60), Angle(0,0,30), Vector(-99,5,-20), Vector(50,15,13), self.SideArmorHP, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(10,-40,60), Angle(0,0,-30), Vector(-99,-15,-20), Vector(50,-5,13), self.SideArmorHP, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(-9,0,63), Angle(0,0,0), Vector(-82,-38,-20), Vector(68,38,13), self.RearArmorHP, self.RearArmor )

	-- rear very down
	self:AddArmor( Vector(-90,0,40), Angle(-5,0,0), Vector(-5,-55,-25), Vector(5,55,23), self.FrontArmorHP, self.FrontArmor )

	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-10,-30.13,55), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(-10,30.13,55), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	
	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end
