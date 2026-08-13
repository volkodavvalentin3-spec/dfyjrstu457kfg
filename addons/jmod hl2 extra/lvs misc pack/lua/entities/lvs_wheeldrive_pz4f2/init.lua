AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "sh_tracks.lua" )
AddCSLuaFile( "cl_optics.lua" )
AddCSLuaFile( "cl_tankview.lua" )
AddCSLuaFile( "sh_turret.lua" )
include("shared.lua")
include("sh_turret.lua")
include("sh_tracks.lua")

-- since this is based on a tank we need to reset these to default var values:
ENT.DSArmorDamageReductionType = DMG_BULLET + DMG_CLUB
ENT.DSArmorIgnoreDamageType = DMG_SONIC


function ENT:OnSpawn( PObj )

	local ID = self:LookupAttachment( "muzzle_mg2" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMGf = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMGf:SetSoundLevel( 95 )
	self.SNDTurretMGf:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle_mg" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle_ausfg" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/sherman/cannon_fire.wav", "lvs/vehicles/sherman/cannon_fire.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )


	local DriverSeat = self:AddDriverSeat( Vector(0,0,70), Angle(0,-90,0) )

	DriverSeat.HidePlayer = true


	self.HornSND = self:AddSoundEmitter( Vector(40,0,35), "lvs/horn3.wav" )
	self.HornSND:SetSoundLevel( 75 )
	self.HornSND:SetDoppler( true )

	local DoorHandler = self:AddDoorHandler( "hatch2", Vector(59.62,21.91,66.29), Angle(0,0,0), Vector(-10,-10,-10), Vector(10,10,10), Vector(-10,-10,-10), Vector(10,10,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( DriverSeat )





	local GunnerSeat = self:AddPassengerSeat( Vector(83,-24,32), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true

	local DoorHandler = self:AddDoorHandler( "hatch3", Vector(59.62,-28,66.29), Angle(0,0,0), Vector(-10,-10,-10), Vector(10,10,10), Vector(-10,-10,-10), Vector(10,10,10) )
	DoorHandler:SetSoundOpen( "lvs/vehicles/generic/car_hood_open.wav" )
	DoorHandler:SetSoundClose( "lvs/vehicles/generic/car_hood_close.wav" )
	DoorHandler:LinkToSeat( GunnerSeat )


	self:AddEngine( Vector(-54.09,13.33,32) )
	self:AddFuelTank( Vector(-54.09,-13.33,32), Angle(0,0,0), 600, LVS.FUELTYPE_DIESEL )

	-- front mid
	self:AddArmor( Vector(107,0,32), Angle(10,0,0), Vector(-5,-40,-10), Vector(5,40,9), 1000, self.TurretArmor )
	-- front bottom
	self:AddArmor( Vector(97,0,20), Angle(68,0,0), Vector(-2,-40,-12), Vector(2,40,11), 800, self.SideArmor )
	-- front upper
	self:AddArmor( Vector(97,0,43), Angle(-72,0,0), Vector(-2,-40,-15), Vector(2,40,17), 700, self.FrontArmor )
	-- front
	self:AddArmor( Vector(75,0,57.27), Angle(-8,0,0), Vector(-5,-40,-10), Vector(5,40,9), 1000, self.TurretArmor )

	-- turret
	self:AddArmor( Vector(-2,3.5,65), Angle(0,0,0), Vector(-45,-45,0), Vector(45,45,30), 1500, self.RearArmor )

	-- midblock fronttop
	self:AddArmor( Vector(60,0,65), Angle(5,0,0), Vector(-30,-40,-2), Vector(10,40,2), 700, self.FrontArmor )
	-- midblock frontleft
	self:AddArmor( Vector(60,41,60), Angle(90,75,0), Vector(-10,-12,-10), Vector(10,30,2), 800, self.SideArmor )
	-- midblock left
	self:AddArmor( Vector(8,48,60), Angle(90,90,0), Vector(-10,-28,-10), Vector(10,45,2), 800, self.SideArmor )
	-- midblock rearleft
	self:AddArmor( Vector(-66,48,57), Angle(-4,0,0), Vector(-30,-10,-10), Vector(30,2,10), 700, self.SideArmor )

	-- midblock left wheels
	self:AddArmor( Vector(-0.85,52.86,59.87), Angle(90,90,0), Vector(-10,-25,-5), Vector(10,25,5), 3000, self.TurretArmor )

	-- midblock frontright
	self:AddArmor( Vector(60,-41,60), Angle(90,105,0), Vector(-10,-12,-2), Vector(10,30,10), 800, self.SideArmor )
	-- midblock right
	self:AddArmor( Vector(8,-48,60), Angle(90,90,0), Vector(-10,-28,-2), Vector(10,45,10), 800, self.SideArmor )
	-- midblock rearright
	self:AddArmor( Vector(-66,-48,57), Angle(-4,0,0), Vector(-30,-2,-10), Vector(30,10,10), 700, self.SideArmor )

	-- rear top
	self:AddArmor( Vector(-66,0,57), Angle(-4,0,0), Vector(-30,-40,-10), Vector(30,40,10), 700, self.FrontArmor )

	-- rear
	self:AddArmor( Vector(-92,0,38), Angle(-10,0,0), Vector(-3,-40,-23), Vector(3,40,20), 700, self.FrontArmor )

	self:AddDriverViewPort( Vector(82.05,14.9,53.91), Angle(0,0,0), Vector(-1,-5,-1), Vector(1,5,1) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(0,40.67,59.85), Vector(0,0,68), Angle(0,0,0), Vector(-30,-6,-6), Vector(30,6,6) )

	self:AddTrailerHitch( Vector(-94.07,0,21.55), LVS.HITCHTYPE_MALE )
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/vehicles/halftrack/engine_start.wav" )
	end
end
