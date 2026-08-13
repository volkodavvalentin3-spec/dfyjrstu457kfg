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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/222/cannon_fire_interior.wav", "lvs/vehicles/222/cannon_fire_interior.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local Seat1 = self:AddPassengerSeat( Vector(-45,25,55), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-27,55), Angle(0,180,0) )
	Seat2.HidePlayer = false


	self:AddEngine( Vector(-45.66,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-50,0,35), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-11,-16,-12),Vector(11,16,12) )

	-- front upper wedge center
	self:AddArmor( Vector(40,0,79), Angle(75,0,0), Vector(17,-30,-10), Vector(50,30,5), 1300, self.FrontArmor )

	self:AddArmor( Vector(45,0,39), Angle(15,0,0), Vector(0,-40,0), Vector(30,40,10), 800, self.SideArmor )

	self:AddArmor( Vector(75,0,32), Angle(112,0,0), Vector(-5,-30,0), Vector(15,30,5), 1300, self.FrontArmor )

	-- side armor left
	self:AddArmor( Vector(8,20,48), Angle(0,0,0), Vector(-95,5,-20), Vector(40,15,13), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(8,-20,48), Angle(0,0,0), Vector(-95,-15,-20), Vector(40,-5,13), 800, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(10,0,48), Angle(0,0,0), Vector(-95,-30,-20), Vector(40,30,13), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(10,0,55), Angle(0,0,0), Vector(-40,-33,0), Vector(26,33,27), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	
	


	-- rear down
	self:AddArmor( Vector(-74,0,25), Angle(-20,0,0), Vector(-5,-30,-10), Vector(5,30,38), 1200, self.FrontArmor )


	-- ammo rack weakspot
	self:AddAmmoRack( Vector(8.5,-20,52), Vector(12,0,60), Angle(0,0,0), Vector(-21,-6,-3), Vector(21,6,3) )
	self:AddAmmoRack( Vector(8.5,20,52), Vector(12,0,60), Angle(0,0,0), Vector(-21,-6,-3), Vector(21,6,3) )
	

	-- trailer hitch
	self:AddTrailerHitch( Vector(-75.49,0,24.98), LVS.HITCHTYPE_MALE )

end
