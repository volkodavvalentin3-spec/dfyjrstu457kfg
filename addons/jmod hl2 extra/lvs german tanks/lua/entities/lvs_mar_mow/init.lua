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

	local DriverSeat = self:AddDriverSeat( Vector(-20,20,60), Angle(0,-110,0) )
	DriverSeat.HidePlayer = false
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(55,17,15), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	local Seat1 = self:AddPassengerSeat( Vector(-20,-20,60), Angle(0,-80,0) )
	Seat1.HidePlayer = false


	self:AddEngine( Vector(-30,-15,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(-40,15,15), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-15,-10,0),Vector(20,10,35) )

	-- front upper wedge center
	self:AddArmor( Vector(44,0,82), Angle(80,0,0), Vector(17,-30,-10), Vector(50,30,5), 1300, self.FrontArmor )

	self:AddArmor( Vector(54,0,30), Angle(5,0,0), Vector(0,-30,0), Vector(30,30,10), 800, self.SideArmor )

	self:AddArmor( Vector(82,0,32), Angle(112,0,0), Vector(-5,-30,0), Vector(15,30,5), 1300, self.FrontArmor )

	-- side armor left
	self:AddArmor( Vector(10,25,46), Angle(0,0,0), Vector(-82,5,-22), Vector(40,15,23), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(10,-25,46), Angle(0,0,0), Vector(-82,-15,-22), Vector(40,-5,23), 800, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(10,0,58), Angle(0,0,0), Vector(-35,-30,-20), Vector(40,30,13), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(14,0,65), Angle(0,0,0), Vector(-37,-30,0), Vector(16,30,30), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-40,0,40), Angle(-10,0,0), Vector(-15,-30,0), Vector(23,30,15), 300, self.SideArmor )
	self:AddArmor( Vector(-70,0,30), Angle(-25,0,0), Vector(-15,-30,0), Vector(23,30,15), 300, self.SideArmor )


	-- rear down
	self:AddArmor( Vector(-83,0,15), Angle(-10,0,0), Vector(-5,-30,0), Vector(5,30,20), 1200, self.FrontArmor )

	
	self:AddTrailerHitch( Vector(-90,0,22), LVS.HITCHTYPE_MALE )
	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(-8,-16,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,5,6.25) )
	self:AddAmmoRack( Vector(-8,16,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,5,6.25) )
	self:AddAmmoRack( Vector(33.38,16,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	
end



