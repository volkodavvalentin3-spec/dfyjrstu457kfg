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

    local DriverSeat = self:AddDriverSeat( Vector(0,0,20), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  
	
	local Seat1 = self:AddPassengerSeat( Vector(-45,25,57), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-75,25,57), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-45,-25,57), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-75,-25,57), Angle(0,180,0) )
	Seat3.HidePlayer = false

	self:AddEngine( Vector(-50,0,40), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,30), Angle(0,0,0), 2200, LVS.FUELTYPE_PETROL, Vector(-12,-30,-12),Vector(12,30,20) )

			-- front upper wedge center
	self:AddArmor( Vector(53,-35,37), Angle(28,0,0), Vector(-20,0,0), Vector(47,70,20), 600, self.FrontArmor )
	self:AddArmor( Vector(40,-13,42), Angle(0,0,0), Vector(0,0,0), Vector(33,25,20), 600, self.FrontArmor )
	

	-- side armor left front
	self:AddArmor( Vector(0,11,49), Angle(0,0,0), Vector(-90,-15,-20), Vector(50,25,13), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(0,-21,49), Angle(0,0,0), Vector(-90,-15,-20), Vector(50,25,13), 600, self.SideArmor )


	-- turret
	local TurretArmor = self:AddArmor( Vector(-5,-7,55), Angle(0,0,0), Vector(-10,-20,0), Vector(60,35,35), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-123,-10,13), Angle(0,0,0), Vector(10,-25,7),Vector(30,45,34), 600, self.SideArmor )
	
	
	self:AddAmmoRack( Vector(25,0,40), Vector(21,0,65), Angle(0,0,0), Vector(-30,-25,-12.15), Vector(20,27,5.15) )

	self:AddTrailerHitch( Vector(-110,0,25), LVS.HITCHTYPE_MALE )
end
