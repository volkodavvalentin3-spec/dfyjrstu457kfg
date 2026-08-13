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
	self.SNDTurretMGH = self:AddSoundEmitter( self:WorldToLocal( MuzzleMGH.Pos ),"lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGH:SetSoundLevel( 95 )
	self.SNDTurretMGH:SetParent( self, ID )
	
	local ID = self:LookupAttachment( "cannon_muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/t90ms_cannon.wav", "weapons/t90ms_cannon.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "cannon_mg_muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )


	local DriverSeat = self:AddDriverSeat( Vector(-3.01478,0,45), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	
	local DoorHandlerDriver = self:AddDoorHandler( "!hatch_d", Vector(80,0,69), Angle(0,0,0), Vector(-25,-75,-15), Vector(25,75,15), Vector(-25,-75,-15), Vector(25,55,15) )
	DoorHandlerDriver:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandlerDriver:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandlerDriver:LinkToSeat( DriverSeat )
	
	self:MakeWeakSpots()
	self:MakeFrontGunnerSeat()
	self:MakeTurretGunnerSeat()
	self:MakeArmor()
end

function ENT:MakeArmor()
	self:AddEngine( Vector(-125.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-120,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )

	-- front plate
	self:AddArmor( Vector(125,0,38), Angle(35,0,0), Vector(-10,-70,-20), Vector(20,70,20), 4000, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(115,0,55), Angle(-50,0,0), Vector(-15,-70,-20), Vector(10,70,30), 3000, self.FrontArmor )
	self:AddArmor( Vector(95,0,55), Angle(0,0,0), Vector(-80,-50,-14), Vector(10,50,30), 3000, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(17,65,35), Angle(0,0,20), Vector(-180,-15,0), Vector(80,10,45), 1500, self.SideArmor )
	self:AddArmor( Vector(17,-65,35), Angle(0,0,-30), Vector(-180,-15,0), Vector(80,10,45), 1500, self.SideArmor )
	
	-- top armor
	self:AddArmor( Vector(-95,0,75), Angle(0,0,0), Vector(-80,-50,-14), Vector(50,50,10), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(4,0,70), Angle(0,0,0), Vector(-90,-57,-30), Vector(60,57,50), 4000, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-130,0,20), Angle(-35,0,0), Vector(-10,-70,0),Vector(10,70,74), 500, self.RearArmor )

	 

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-40,30,79), Vector(0,0,65), Angle(0,0,0), Vector(-24,-12,-6), Vector(34,12,26) )
	self:AddAmmoRack( Vector(-40,-30,79), Vector(0,0,65), Angle(0,0,0), Vector(-24,-12,-6), Vector(34,12,26) )
	

	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end

function ENT:MakeFrontGunnerSeat()
	local FrontGunnerSeat = self:AddPassengerSeat( Vector(64.746,-34.3197,45), Angle(0,-90,0) )
	FrontGunnerSeat.HidePlayer = true
	self:SetFrontGunnerSeat( FrontGunnerSeat )

end

function ENT:MakeTurretGunnerSeat()
	local TopGunnerSeat = self:AddPassengerSeat( Vector(-3.01478,0,65), Angle(0,-90,0) )
	TopGunnerSeat.HidePlayer = true
	self:SetTopGunnerSeat( TopGunnerSeat )

	local DoorHandler = self:AddDoorHandler( "!hatch_g", Vector(-18.2394,-20.9427,116), Angle(0,0,0), Vector(-25,-25,-15), Vector(25,25,15), Vector(-25,-25,-15), Vector(25,25,15) )
	local DoorHandler2 = self:AddDoorHandler( "!hatch_c_part", Vector(-18.2394,-20.9427,116), Angle(0,0,0), Vector(-25,-25,-15), Vector(25,25,15), Vector(-25,-15,-15), Vector(25,25,15) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( TopGunnerSeat )
	DoorHandler2:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler2:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler2:LinkToSeat( TopGunnerSeat )
	self.TopGunnerDoorHandler = DoorHandler
	self.TopGunnerDoorHandler2 = DoorHandler2
end 

function ENT:OnTick()
	self:AimTurret()
	
	local TopGunnerSeat = self:GetTopGunnerSeat()
	local DoorHandler = self.TopGunnerDoorHandler
	local DoorHandler2 = self.TopGunnerDoorHandler2

	if not IsValid( DoorHandler ) or not IsValid( TopGunnerSeat ) then return end
	if not IsValid( DoorHandler2 ) or not IsValid( TopGunnerSeat ) then return end
	
	if IsValid(DoorHandler) and IsValid(TopGunnerSeat) then
        local ply = TopGunnerSeat:GetDriver()
        -- Open hatch
        local PoseValue = (IsValid(ply) and TopGunnerSeat:GetThirdPersonMode()) and 1 or 0
        if PoseValue ~= DoorHandler:GetPoseMin() then
            DoorHandler:SetPoseMin(PoseValue)
        end
		local PoseValue2 = (IsValid(ply) and TopGunnerSeat:GetThirdPersonMode()) and 1 or 0
        if PoseValue ~= DoorHandler2:GetPoseMin() then
            DoorHandler2:SetPoseMin(PoseValue)
        end
    end
end

function ENT:MakeWeakSpots()
	-- driver viewport weakstop
	self:AddDriverViewPort( Vector(89.9445,20.8554,61.4489), Angle(0,0,0), Vector(-5,-5,-5), Vector(5,5,5) )

end
