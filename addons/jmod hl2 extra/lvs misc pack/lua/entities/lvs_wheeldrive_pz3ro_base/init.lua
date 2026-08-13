AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_tankview.lua" )
AddCSLuaFile( "cl_optics.lua" )
AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "sh_tracks.lua" )
include("shared.lua")
include("sh_turret.lua")
include("sh_tracks.lua")

function ENT:OnSpawn( PObj )
	self:MakeDriverSeat()
	self:MakeGunnerSeat()
	self:MakeArmor()
	self:MakeWeakSpots()
	self:MakeSoundEmitters()

	self:AddEngine( Vector(-40,0,53), Angle(0,180,0) )

	self:AddTrailerHitch( Vector(-101,0,30), LVS.HITCHTYPE_MALE )
end

function ENT:MakeDriverSeat()
	local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local DoorHandler = self:AddDoorHandler( "!hatch_driver", Vector(85,14,40), Angle(5,0,0), Vector(-10,-10,-10), Vector(10,15,10), Vector(-10,-10,-10), Vector(10,15,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( DriverSeat )
end

function ENT:MakeTopGunnerSeat()
	local TopGunnerSeat = self:AddPassengerSeat( Vector(8,0,60), Angle(0,-90,0) )
	TopGunnerSeat.HidePlayer = true

	self:SetTopGunnerSeat( TopGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "hatch1", Vector(10,0,96), Angle(0,0,0), Vector(-50,-40,-10), Vector(40,40,10), Vector(-50,-40,-10), Vector(40,40,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( TopGunnerSeat )

	self.TopGunnerDoorHandler = DoorHandler
end

function ENT:MakeGunnerSeat()
	local GunnerSeat = self:AddPassengerSeat( Vector(77,-23,26), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true

	self:SetGunnerSeat( GunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_radio", Vector(85,-14,40), Angle(5,0,0), Vector(-10,-15,-10), Vector(10,10,10), Vector(-10,-15,-10), Vector(10,10,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( GunnerSeat )
end

function ENT:MakeArmor()
	-- armor mask
	self:AddArmor( Vector(69,0,57), Angle(-12,0,0), Vector(-1,-38,-7.5), Vector(1,38,7.5), 1600, self.MaskArmor )
	-- front upper
	self:AddArmor( Vector(64.3,0,55.6), Angle(-11,0,0), Vector(-1,-38,-7.5), Vector(1,38,7.5), 1000, self.FrontArmor )
	-- front mid
	self:AddArmor( Vector(78,0,48.5), Angle(-84.5,0,0), Vector(-1,-38,-12), Vector(1,38,12), 500, self.TurretArmor )
	-- front low
	self:AddArmor( Vector(96.6,0,42), Angle(-52,0,0), Vector(-1,-38,-9), Vector(1,38,9), 1000, self.FrontArmor )
	-- front bottom
	self:AddArmor( Vector(99.6,0,28.7), Angle(24,0,0), Vector(-1,-38,-10), Vector(1,38,10), 1000, self.FrontArmor )
	-- front very bottom
	self:AddArmor( Vector(86.5,0,17.8), Angle(75,0,0), Vector(-1,-38,-10), Vector(1,38,10), 600, self.SideArmor )

	-- top plate front
	self:AddArmor( Vector(19.5,0,62), Angle(90,0,0), Vector(-1,-38,-43), Vector(1,38,43), 320, self.RearArmor )
	-- top plate mid
	self:AddArmor( Vector(-42.2,0,61.5), Angle(88,0,0), Vector(-1,-38,-20), Vector(1,38,20), 320, self.RearArmor )
	-- top plate rear
	self:AddArmor( Vector(-78,0,57.7), Angle(79,0,0), Vector(-1,-38,-18), Vector(1,38,18), 320, self.RearArmor )
	-- rear upper
	self:AddArmor( Vector(-98.4,0,52), Angle(52.6,0,0), Vector(-1,-38,-4), Vector(1,38,4), 600, self.SideArmor )
	-- rear mid
	self:AddArmor( Vector(-101,0,43), Angle(19.3,0,0), Vector(-2,-38,-7), Vector(2,38,7), 1000, self.FrontArmor )
	-- top mid2
	self:AddArmor( Vector(-95,0,37), Angle(91.4,0,0), Vector(-1,-38,-7), Vector(1,38,7), 320, self.RearArmor )
	-- rear mid
	self:AddArmor( Vector(-87,0,29), Angle(-15.6,0,0), Vector(-1,-38,-8), Vector(1,38,8), 1000, self.FrontArmor )
	-- rear mid
	self:AddArmor( Vector(-75,0,19), Angle(-73.6,0,0), Vector(-1,-38,-10), Vector(1,38,10), 1000, self.FrontArmor )

	-- side front right
	self:AddArmor( Vector(52,-39,39), Angle(0,0,0), Vector(-55,-1,-24), Vector(55,1,24), 600, self.SideArmor )
	-- side rear right
	self:AddArmor( Vector(-53,-39,39), Angle(0,0,0), Vector(-55,-1,-24), Vector(55,1,24), 600, self.SideArmor )

	-- side front left
	self:AddArmor( Vector(52,39,39), Angle(0,0,0), Vector(-55,-1,-24), Vector(55,1,24), 600, self.SideArmor )
	-- side rear left
	self:AddArmor( Vector(-53,39,39), Angle(0,0,0), Vector(-55,-1,-24), Vector(55,1,24), 600, self.SideArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(25,0,60), Angle(0,0,0), Vector(-45,-40,0), Vector(32,40,30), 1600, self.MaskArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( FrontArmor )

	-- spare tracks upper
	self:AddArmor( Vector(96.7,0,44.3), Angle(-52,0,0), Vector(-2,-16.55,-9), Vector(2,16.55,9), 1600, self.MaskArmor )
	-- spare tracks lower
	self:AddArmor( Vector(100.7,0,27.8), Angle(30,0,0), Vector(-2,-30.5,-9), Vector(2,30.5,9), 1600, self.MaskArmor )
end

function ENT:MakeWeakSpots()
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(23.38,-29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	self:AddAmmoRack( Vector(-3.78,-17.2,30.4), Vector(10,0,62.5), Angle(90,12.5,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )

	self:AddAmmoRack( Vector(23.38,29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	self:AddAmmoRack( Vector(-3.78,17.2,30.4), Vector(10,0,62.5), Angle(90,-12.5,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
end

function ENT:MakeSoundEmitters()
end
