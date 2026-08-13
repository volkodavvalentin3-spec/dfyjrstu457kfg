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

	local DriverSeat = self:AddDriverSeat( Vector(0,0,20), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  
    local GunnerSeat = self:AddPassengerSeat( Vector(30,-18,25), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	
	local Seat1 = self:AddPassengerSeat( Vector(-45,28,60), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-28,60), Angle(0,180,0) )
	Seat2.HidePlayer = false


	self:AddEngine( Vector(-60,-0,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(-40,12,30), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-12,-15,-12),Vector(12,20,20) )

		-- front upper wedge center
	self:AddArmor( Vector(10,-35,35), Angle(20,0,0), Vector(0,0,0), Vector(65,70,20), self.FrontArmorHP, self.FrontArmor )
	self:AddArmor( Vector(10,-35,65), Angle(90,0,0), Vector(0,0,0), Vector(35,70,20), self.FrontArmorHP, self.FrontArmor )
	
	

	-- side armor left front
	self:AddArmor( Vector(-20,30,50), Angle(0,0,0), Vector(-80,-15,-20), Vector(32,15,13), self.SideArmorHP, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(-20,-30,50), Angle(0,0,0), Vector(-80,-15,-20), Vector(32,15,13), self.SideArmorHP, self.SideArmor )

	
	-- top armor
	self:AddArmor( Vector(-20,0,55), Angle(0,0,0), Vector(-80,-30,-20), Vector(32,30,10), self.RearArmorHP, self.RearArmor )
	

	-- turret
	local TurretArmor = self:AddArmor( Vector(-20,0,65), Angle(0,0,0), Vector(-20,-30,0), Vector(48,30,25), self.TurretArmorHP, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-85,-15,3), Angle(-30,0,0), Vector(10,-25,7),Vector(20,45,37), self.SideArmorHP, self.SideArmor )
	
	
	
	self:AddAmmoRack( Vector(5,25,30), Vector(5,0,55), Angle(0,0,0), Vector(-30,-5,-12.15), Vector(20,7,5.15) )
	self:AddAmmoRack( Vector(5,-25,30), Vector(5,0,55), Angle(0,0,0), Vector(-30,-5,-12.15), Vector(20,7,5.15) )

	self:AddTrailerHitch( Vector(-73,0,25), LVS.HITCHTYPE_MALE )
end
