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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/222/cannon_fire_interior.wav", "weapons/20mm.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(0,0,20), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	
	
	local Seat1 = self:AddPassengerSeat( Vector(-35,25,40), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-35,-27,40), Angle(0,180,0) )
	Seat2.HidePlayer = false


	self:AddEngine( Vector(-40.66,10,35), Angle(0,180,0) )
	self:AddFuelTank( Vector(-30,-14,35), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-21,-6,-12),Vector(11,6,12) )

	-- front upper wedge center
	self:AddArmor( Vector(25,0,70), Angle(70,0,0), Vector(17,-30,-10), Vector(50,30,5), 1300, self.FrontArmor )

	self:AddArmor( Vector(54,0,30), Angle(20,0,0), Vector(-20,-30,0), Vector(30,30,10), 800, self.SideArmor )

	self:AddArmor( Vector(82,0,22), Angle(112,0,0), Vector(-5,-30,0), Vector(15,30,5), 1300, self.FrontArmor )

	-- side armor left
	self:AddArmor( Vector(10,20,40), Angle(0,0,0), Vector(-32,5,-20), Vector(20,15,13), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(10,-20,40), Angle(0,0,0), Vector(-32,-15,-20), Vector(20,-5,13), 800, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(0,0,41), Angle(0,0,0), Vector(-20,-30,0), Vector(30,30,13), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(14,-5,55), Angle(0,0,0), Vector(-30,-25,0), Vector(20,20,15), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-40,0,35), Angle(0,0,0), Vector(-15,-30,0), Vector(23,30,15), 300, self.SideArmor )
	


	-- rear down
	self:AddArmor( Vector(-55,0,15), Angle(0,0,0), Vector(-5,-30,0), Vector(5,30,20), 1200, self.FrontArmor )

	
	self:AddTrailerHitch( Vector(-90,0,22), LVS.HITCHTYPE_MALE )
	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	

	-- trailer hitch
	self:AddTrailerHitch( Vector(-75.49,0,24.98), LVS.HITCHTYPE_MALE )

end



