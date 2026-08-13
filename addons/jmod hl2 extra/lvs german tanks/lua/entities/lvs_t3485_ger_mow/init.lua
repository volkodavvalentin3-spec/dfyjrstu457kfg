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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/85mm_zis53.wav", "weapons/85mm_zis53.wav" )
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
	
	local DoorHandlerDriver = self:AddDoorHandler( "!hatch_d", Vector(75,26,49), Angle(0,0,0), Vector(-45,-40,-15), Vector(25,15,15), Vector(-45,-40,-15), Vector(15,15,15) )
	DoorHandlerDriver:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandlerDriver:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandlerDriver:LinkToSeat( DriverSeat )
	
	self:MakeWeakSpots()
	self:MakeFrontGunnerSeat()
	self:MakeTurretGunnerSeat()
	self:MakeArmor()
end

function ENT:MakeArmor()
	self:AddEngine( Vector(-50,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,0,15), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-10,-30,0),Vector(10,30,35) )

		-- front upper wedge center
	self:AddArmor( Vector(67,0,46), Angle(30,0,0), Vector(17,-55,-10), Vector(50,0,10), 1100, self.FrontArmor )
	self:AddArmor( Vector(67,0,46), Angle(30,0,0), Vector(-16,-50,-10), Vector(17,0,10), 1100, self.FrontArmor )

	self:AddArmor( Vector(67,0,46), Angle(30,0,0), Vector(17,0,-10), Vector(50,55,10), 1100, self.FrontArmor )
	self:AddArmor( Vector(67,0,46), Angle(30,0,0), Vector(-16,0,-10), Vector(17,50,10), 1100, self.FrontArmor )

	-- side armor left front
	self:AddArmor( Vector(20,31,50), Angle(0,0,45), Vector(-40,-15,-20), Vector(40,15,13), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(20,-31,50), Angle(0,0,-45), Vector(-40,-15,-20), Vector(40,15,13), 600, self.SideArmor )

	-- side armor left rear
	self:AddArmor( Vector(20,31,50), Angle(0,0,45), Vector(-120,-15,-20), Vector(-40,15,13), 600, self.SideArmor )

	-- side armor right rear
	self:AddArmor( Vector(20,-31,50), Angle(0,0,-45), Vector(-120,-15,-20), Vector(-40,15,13), 600, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(-33,0,58), Angle(0,0,0), Vector(-50,-33,-14), Vector(20,33,10), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(25,0,60), Angle(0,0,0), Vector(-60,-39,0), Vector(37,39,40), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-100,0,40), Angle(50,0,0), Vector(-10,-45,7),Vector(20,45,34), 600, self.SideArmor )

	-- rear down
	self:AddArmor( Vector(-100,0,40), Angle(50,0,0), Vector(-10,-50,-17),Vector(20,50,7), 600, self.SideArmor )
	
	self:AddAmmoRack( Vector(25,0,30), Vector(21,0,65), Angle(0,0,0), Vector(-24.25,-24.25,-12.25), Vector(24.25,24.25,12.25) )
	
	self:AddTrailerHitch( Vector(-100,0,22), LVS.HITCHTYPE_MALE )

end

function ENT:MakeFrontGunnerSeat()
	local FrontGunnerSeat = self:AddPassengerSeat( Vector(64.746,-34.3197,45), Angle(0,-90,0) )
	FrontGunnerSeat.HidePlayer = true
	self:SetFrontGunnerSeat( FrontGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_g", Vector(-50,0,60), Angle(0,0,0), Vector(-15,-15,-15), Vector(15,15,15), Vector(-15,-15,-15), Vector(15,15,15) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )


end

function ENT:MakeTurretGunnerSeat()
	local TopGunnerSeat = self:AddPassengerSeat( Vector(-3.01478,0,65), Angle(0,-90,0) )
	TopGunnerSeat.HidePlayer = true
	self:SetTopGunnerSeat( TopGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_c", Vector(10.2394,30.9427,90), Angle(0,0,0), Vector(-25,-40,-5), Vector(15,15,15), Vector(-25,-40,-15), Vector(15,15,15) )
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

	
end
