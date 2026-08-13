AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "sh_tracks.lua" )
AddCSLuaFile( "cl_optics.lua" )
AddCSLuaFile( "cl_tankview.lua" )
AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "cl_attached_playermodels.lua" )
include("shared.lua")
include("sh_turret.lua")
include("sh_tracks.lua")

-- since this is based on a tank we need to reset these to default var values:
ENT.DSArmorDamageReductionType = DMG_BULLET + DMG_CLUB
ENT.DSArmorIgnoreDamageType = DMG_SONIC


function ENT:OnSpawn( PObj )

	local ID = self:LookupAttachment( "muzzle_mg" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/t34/dt28_loop.wav", "lvs/vehicles/t34/dt28_loop.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/t26/t26_shot_outside.wav", "lvs/vehicles/t26/t26_shot_inside.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )


	local DriverSeat = self:AddDriverSeat( Vector(0,0,30), Angle(0,-90,0) )

	DriverSeat.HidePlayer = true

	local DoorHandler = self:AddDoorHandler( "hatch1", Vector(45.52,10.12,49.37), Angle(0,0,0), Vector(-10,-10,-10), Vector(10,10,10), Vector(-10,-10,-10), Vector(10,10,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( DriverSeat )

	local DoorHandler = self:AddDoorHandler( "hatch2", Vector(-13.86,11.35,77.72), Angle(0,0,0), Vector(-12,-12,-2), Vector(8,12,2), Vector(-12,-12,-2), Vector(12,12,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )

	self:AddEngine( Vector(-74,-18,42) )
	self:AddFuelTank( Vector(-60,18,37), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL )

	-- front plate
	self:AddArmor( Vector(54.7,0,39.6), Angle(-62,0,0), Vector(-2,-36,-29), Vector(2,36,29), 800, self.FrontArmor )
	-- front plate cover
	self:AddArmor( Vector(69.4,-16.3,33), Angle(-62,0,0), Vector(-3,-16,-12), Vector(3,16,12), 800, self.FrontArmor )
	-- driver hatch
	self:AddArmor( Vector(44,10.8,47.5), Angle(0,0,0), Vector(-14.5,-14,-8.5), Vector(14.5,14,8.5), 1200, self.HatchArmor )
	-- front plate cover
	self:AddArmor( Vector(75.7,0,21.1), Angle(48.5,0,0), Vector(-1,-37,-9), Vector(1,37,9), 900, self.FrontLowArmor )

	-- front top plate
	self:AddArmor( Vector(58.5,0,15.3), Angle(78.8,0,0), Vector(-2,-35,-10.5), Vector(2,35,10.5), 400, self.SideArmor )

	-- top plate
	self:AddArmor( Vector(-15.1,0,52.5), Angle(90,0,0), Vector(-2,-35,-45), Vector(2,35,45), 200, self.TopArmor )
	-- rear top plate
	self:AddArmor( Vector(-75.6,0,45.5), Angle(67.7,0,0), Vector(-2,-35,-17.8), Vector(2,35,17.8), 400, self.SideArmor )
	-- rear bottom plate
	self:AddArmor( Vector(-76.3,0,26.6), Angle(-45,0,0), Vector(-2,-35,-18.8), Vector(2,35,18.8), 600, self.RearArmor )

	-- spare wheel
	self:AddArmor( Vector(-76.5,18.8,50.5), Angle(-22.65,0,0), Vector(-11,-11,-3.5), Vector(11,11,3.5), 1200, self.HatchArmor )

	-- right rear plate
	self:AddArmor( Vector(-52.4,-35,42.4), Angle(0,0,0), Vector(-40,-1,-12), Vector(40,1,12), 400, self.SideArmor )
	-- right front plate
	self:AddArmor( Vector(37,-35,42.4), Angle(0,0,0), Vector(-50,-1,-12), Vector(50,1,12), 400, self.SideArmor )

	-- right left plate
	self:AddArmor( Vector(-52.4,35,42.4), Angle(0,0,0), Vector(-40,-1,-12), Vector(40,1,12), 400, self.SideArmor )
	-- right left plate
	self:AddArmor( Vector(37,35,42.4), Angle(0,0,0), Vector(-50,-1,-12), Vector(50,1,12), 400, self.SideArmor )

	-- turret
	self:AddArmor( Vector(-7.4,10.7,66), Angle(0,0,0), Vector(-28.3,-28.3,-12.4), Vector(28.3,28.3,12.4), 1000, self.TurretArmor )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-2.7,0,29.7), Vector(-7,10,54), Angle(0,0,0), Vector(-7,-8,-5), Vector(7,8,5) )

	self:AddTrailerHitch( Vector(-79.04,0,20.98), LVS.HITCHTYPE_MALE )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/halftrack/engine_start.wav" )
	end
end
