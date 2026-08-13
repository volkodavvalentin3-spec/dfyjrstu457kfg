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
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(85,15,41), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	local Seat1 = self:AddPassengerSeat( Vector(-10,15,85), Angle(0,-90,0) )
	Seat1.HidePlayer = true
	local Seat2 = self:AddPassengerSeat( Vector(-75,50,65), Angle(0,0,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-75,-50,65), Angle(0,180,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-115,40,65), Angle(0,0,0) )
	Seat4.HidePlayer = false
	local Seat5 = self:AddPassengerSeat( Vector(-115,-40,65), Angle(0,180,0) )
	Seat5.HidePlayer = false

	self:AddEngine( Vector(-110,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,0,60), Angle(0,0,0), 800, LVS.FUELTYPE_PETROL, Vector(-22,-37,-32),Vector(12,37,0) )

	-- front plate
	self:AddArmor( Vector(90,23,30), Angle(15,0,0), Vector(-25,-70,-5), Vector(30,20,20), self.FrontArmorHP, self.FrontArmor )
	self:AddArmor( Vector(125,45,27), Angle(0,0,0), Vector(0,-20,0), Vector(25,15,45), self.FrontArmorHP, self.FrontArmor )
	self:AddArmor( Vector(125,-43,27), Angle(0,0,0), Vector(0,-20,0), Vector(25,15,45), self.FrontArmorHP, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(70,28,40), Angle(0,0,0), Vector(-25,-70,-20), Vector(20,15,30), self.FrontArmorHP, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(5,45,27), Angle(0,0,0), Vector(-170,-20,0), Vector(120,15,45), self.SideArmorHP, self.SideArmor )

	self:AddArmor( Vector(5,-43,27), Angle(0,0,0), Vector(-170,-20,0), Vector(120,15,45), self.SideArmorHP, self.SideArmor )
	

	-- turret
	local TurretArmor = self:AddArmor( Vector(0,20,65), Angle(0,0,0), Vector(-60,-60,0), Vector(60,25,43), self.TurretArmorHP, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-150,0,45), Angle(10,0,0), Vector(-10,-45,0),Vector(10,45,25), self.RearArmorHP, self.RearArmor )
	self:AddArmor( Vector(-130,0,15), Angle(-30,0,0), Vector(-10,-45,0),Vector(10,45,45), self.RearArmorHP, self.RearArmor )

	-- driver viewport weakspot
	self:AddDriverViewPort( Vector(105,21,55), Angle(0,0,0), Vector(-1,-7,-1), Vector(1,7,1) )

	-- ammo rack weakspot
	
	self:AddAmmoRack( Vector(10,40,50), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
	self:AddAmmoRack( Vector(10,-40,50), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
end
