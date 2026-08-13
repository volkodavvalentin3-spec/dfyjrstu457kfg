AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_tracks.lua" )
AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_optics.lua" )
AddCSLuaFile( "cl_tankview.lua" )
AddCSLuaFile( "cl_attached_playermodels.lua" )
include("shared.lua")
include("sh_tracks.lua")
include("sh_turret.lua")

ENT.DSArmorDamageReductionType = DMG_BULLET + DMG_CLUB
ENT.DSArmorIgnoreDamageType = DMG_SONIC

function ENT:OnSpawn( PObj )
	local ID = self:LookupAttachment( "mgh_muzzle" )
	local MuzzleMGH = self:GetAttachment( ID )
	self.SNDTurretMGH = self:AddSoundEmitter( self:WorldToLocal( MuzzleMGH.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGH:SetSoundLevel( 95 )
	self.SNDTurretMGH:SetParent( self, ID )
	
	local ID = self:LookupAttachment( "cannon_muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/75mm_kwk42.wav", "weapons/75mm_kwk42.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "cannon_mg_muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )
	
	local ID = self:LookupAttachment( "mgc_muzzle" )
	local MuzzleMGT = self:GetAttachment( ID )
	self.SNDTurretMGT = self:AddSoundEmitter( self:WorldToLocal( MuzzleMGT.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGT:SetSoundLevel( 95 )
	self.SNDTurretMGT:SetParent( self, ID )

	self:AddEngine( Vector(-79.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )
	
	local DriverSeat = self:AddDriverSeat( Vector(-3.01478,0,45), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	
	local DoorHandlerDriver = self:AddDoorHandler( "!hatch_d", Vector(75,56,69), Angle(0,0,0), Vector(-35,-40,-15), Vector(15,15,15), Vector(-35,-30,-15), Vector(15,15,15) )
	DoorHandlerDriver:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandlerDriver:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandlerDriver:LinkToSeat( DriverSeat )
	
	self:MakeWeakSpots()
	self:MakeFrontGunnerSeat()
	self:MakeTurretGunnerSeat()
	self:MakeArmor()
end

function ENT:MakeArmor()
	self:AddEngine( Vector(-79.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )

	self:AddArmor( Vector(105,0,50), Angle(35,0,0), Vector(-37,-64,0), Vector(25,64,10), 1300, self.FrontArmor )
	self:AddArmor( Vector(110,0,25), Angle(-36,0,0), Vector(-10,-39,0), Vector(25,39,10), 1300, self.FrontArmor )
	

	-- side armor left
	self:AddArmor( Vector(11,54,62), Angle(0,0,30), Vector(-140,5,-13), Vector(89,15,13), 800, self.SideArmor )
	self:AddArmor( Vector(21,54,32), Angle(0,0,0), Vector(-140,5,-15), Vector(89,15,25), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(11,-54,62), Angle(0,0,140), Vector(-140,5,-13), Vector(89,15,13), 800, self.SideArmor )
    self:AddArmor( Vector(21,-74,32), Angle(0,0,0), Vector(-140,5,-15), Vector(89,15,25), 800, self.SideArmor )
	-- top armor
	self:AddArmor( Vector(-9,0,75), Angle(0,0,0), Vector(-115,-50,-10), Vector(89,50,5), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(0,0,70), Angle(0,0,0), Vector(-57,-45,0), Vector(47,45,40), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )


	-- rear very down
	self:AddArmor( Vector(-110,0,50), Angle(-25,0,0), Vector(-5,-64,-28), Vector(5,64,28), 1200, self.FrontArmor )
	
	self:AddTrailerHitch( Vector(-190,0,22), LVS.HITCHTYPE_MALE )
	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-20,-40.13,65), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(-20,40.13,65), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(20,-40.13,65), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(20,40.13,65), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-15.25,-6.25), Vector(9.25,17.25,5.25) )
	self:AddAmmoRack( Vector(-10,0,30), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-25.25,-16.25), Vector(9.25,25.25,15.25) )

	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )

end

function ENT:MakeFrontGunnerSeat()
	local FrontGunnerSeat = self:AddPassengerSeat( Vector(64.746,-34.3197,45), Angle(0,-90,0) )
	FrontGunnerSeat.HidePlayer = true
	self:SetFrontGunnerSeat( FrontGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_g", Vector(75,-44.3197,69), Angle(0,0,0), Vector(-35,-30,-15), Vector(15,25,15), Vector(-35,-30,-15), Vector(15,15,15) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( FrontGunnerSeat )
	self.FrontGunnerDoorHandler = DoorHandler
end

function ENT:MakeTurretGunnerSeat()
	local TopGunnerSeat = self:AddPassengerSeat( Vector(-3.01478,0,65), Angle(0,-90,0) )
	TopGunnerSeat.HidePlayer = true
	self:SetTopGunnerSeat( TopGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_c", Vector(-10.2394,30.9427,106), Angle(0,0,0), Vector(-25,-40,-15), Vector(15,15,15), Vector(-25,-40,-15), Vector(15,15,15) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( TopGunnerSeat )
	self.TopGunnerDoorHandler = DoorHandler
end 

function ENT:OnTick()
	self:AimTurret()
	
	local TopGunnerSeat = self:GetTopGunnerSeat()
	local DoorHandler = self.TopGunnerDoorHandler

	if not IsValid( DoorHandler ) or not IsValid( TopGunnerSeat ) then return end

	local PoseValue = IsValid( TopGunnerSeat:GetDriver() ) and 1 or 0

	if PoseValue ~= DoorHandler:GetPoseMin() then
		DoorHandler:SetPoseMin( PoseValue )
	end
end

function ENT:MakeWeakSpots()
	-- driver viewport weakstop
	self:AddDriverViewPort( Vector(89.9445,20.8554,61.4489), Angle(0,0,0), Vector(-5,-5,-5), Vector(5,5,5) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(0,50,55), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(0,-50,55), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(0,30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
	self:AddAmmoRack( Vector(0,-30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
end
