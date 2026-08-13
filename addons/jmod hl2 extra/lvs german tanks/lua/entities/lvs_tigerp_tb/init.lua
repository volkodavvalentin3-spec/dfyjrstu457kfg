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

	local GunnerSeat = self:AddPassengerSeat( Vector(113,-24,41), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	local Seat1 = self:AddPassengerSeat( Vector(20,15,90), Angle(0,-90,0) )
	Seat1.HidePlayer = true
	local Seat2 = self:AddPassengerSeat( Vector(-55,40,65), Angle(0,0,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-55,-40,65), Angle(0,180,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-85,40,65), Angle(0,0,0) )
	Seat4.HidePlayer = false
	local Seat5 = self:AddPassengerSeat( Vector(-85,-40,65), Angle(0,180,0) )
	Seat5.HidePlayer = false

	self:AddEngine( Vector(-79.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )

	-- front plate
	self:AddArmor( Vector(115,0,38), Angle(10,0,0), Vector(-20,-70,-20), Vector(20,70,20), 4000, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(95,0,38), Angle(0,0,0), Vector(-15,-70,-30), Vector(10,70,40), 3000, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(0,54,33), Angle(0,0,0), Vector(-130,-15,0), Vector(80,15,45), 1500, self.SideArmor )
	self:AddArmor( Vector(0,-54,33), Angle(0,0,0), Vector(-130,-15,0), Vector(80,15,45), 1500, self.SideArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(24,0,70), Angle(0,0,0), Vector(-60,-60,0), Vector(60,60,40), 4000, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-120,0,25), Angle(0,0,0), Vector(-10,-45,0),Vector(10,45,35), 500, self.RearArmor )

	-- top armor
	self:AddArmor( Vector(-9,0,63), Angle(0,0,0), Vector(-82,-38,-20), Vector(68,38,13), 600, self.RearArmor )
	self:AddArmor( Vector(-89,0,66), Angle(-20,0,0), Vector(-32,-38,-10), Vector(18,38,5), 600, self.RearArmor )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(20,50,55), Vector(0,0,65), Angle(0,0,0), Vector(-44,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(20,-50,55), Vector(0,0,65), Angle(0,0,0), Vector(-44,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(20,30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
	self:AddAmmoRack( Vector(20,-30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )

	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end
