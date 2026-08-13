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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/76mm_l11.wav", "weapons/76mm_l11.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(80,-24,31), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	
    local Seat1 = self:AddPassengerSeat( Vector(-45,25,60), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-25,60), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-75,25,60), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-75,-25,60), Angle(0,180,0) )
	Seat4.HidePlayer = false

	self:AddEngine( Vector(-50,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,0,15), Angle(0,0,0), 2200, LVS.FUELTYPE_PETROL, Vector(-10,-30,0),Vector(10,30,35) )

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
	local TurretArmor = self:AddArmor( Vector(25,0,60), Angle(0,0,0), Vector(-40,-38,0), Vector(34,38,30), 1200, self.TurretArmor )
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
