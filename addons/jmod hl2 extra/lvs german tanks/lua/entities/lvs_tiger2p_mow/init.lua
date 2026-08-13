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

	local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	local GunnerSeat = self:AddPassengerSeat( Vector(113,-24,45), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )

	self:AddEngine( Vector(-79.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )

	-- front plate
	self:AddArmor( Vector(125,0,38), Angle(30,0,0), Vector(-10,-70,-20), Vector(10,70,20), 4000, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(115,0,55), Angle(-50,0,0), Vector(-15,-70,-20), Vector(10,70,30), 3000, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(17,65,35), Angle(0,0,20), Vector(-160,-15,0), Vector(80,10,45), 1500, self.SideArmor )
	self:AddArmor( Vector(17,-65,35), Angle(0,0,-30), Vector(-160,-15,0), Vector(80,10,45), 1500, self.SideArmor )
	
	-- top armor
	self:AddArmor( Vector(-84,0,72), Angle(0,0,0), Vector(-50,-50,-14), Vector(180,50,10), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(4,0,80), Angle(0,0,0), Vector(-90,-55,0), Vector(60,55,40), 4000, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-110,0,20), Angle(-30,0,0), Vector(-10,-70,0),Vector(10,70,65), 500, self.RearArmor )

	 

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(0,45,65), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(74,12,6) )
	self:AddAmmoRack( Vector(0,-45,65), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(74,12,6) )
	

	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end
