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

	local GunnerSeat = self:AddPassengerSeat( Vector(103,-24,41), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )

	self:AddEngine( Vector(-79.66,0,72.21), Angle(0,180,0) )
	self:AddFuelTank( Vector(-80,0,60), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-50,-12),Vector(12,50,0) )

	-- front plate
	self:AddArmor( Vector(115,0,38), Angle(10,0,0), Vector(-20,-70,-20), Vector(20,70,20), self.FrontArmorHP, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(95,0,38), Angle(0,0,0), Vector(-15,-70,-30), Vector(10,70,40), self.FrontArmorHP, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(0,54,35), Angle(0,0,0), Vector(-120,-15,0), Vector(80,15,45), self.SideArmorHP, self.SideArmor )
	self:AddArmor( Vector(0,-54,35), Angle(0,0,0), Vector(-120,-15,0), Vector(80,15,45), self.SideArmorHP, self.SideArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(4,0,70), Angle(0,0,0), Vector(-60,-60,0), Vector(60,60,40), self.TurretArmorHP, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-100,0,20), Angle(-15,0,0), Vector(-10,-45,0),Vector(10,45,65), self.RearArmorHP, self.RearArmor )

	 

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(0,50,55), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(0,-50,55), Vector(0,0,65), Angle(0,0,0), Vector(-54,-12,-6), Vector(54,12,6) )
	self:AddAmmoRack( Vector(0,30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
	self:AddAmmoRack( Vector(0,-30,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )

	-- trailer hitch
	self:AddTrailerHitch( Vector(-112,0,22), LVS.HITCHTYPE_MALE )
end
