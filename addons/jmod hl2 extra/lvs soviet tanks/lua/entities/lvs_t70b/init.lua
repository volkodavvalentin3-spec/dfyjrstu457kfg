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
	  

	
	
	local Seat1 = self:AddPassengerSeat( Vector(-45,25,50), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-27,50), Angle(0,180,0) )
	Seat2.HidePlayer = false


	self:AddEngine( Vector(0,-20,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(-40,12,30), Angle(0,0,0), 2200, LVS.FUELTYPE_PETROL, Vector(-12,-15,-12),Vector(12,20,20) )

		-- front upper wedge center
	self:AddArmor( Vector(13,-35,41), Angle(28,0,0), Vector(0,0,0), Vector(65,70,20), 600, self.FrontArmor )
	
	

	-- side armor left front
	self:AddArmor( Vector(0,21,30), Angle(0,0,0), Vector(-70,-15,-20), Vector(30,15,13), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(0,-21,30), Angle(0,0,0), Vector(-70,-15,-20), Vector(30,15,13), 600, self.SideArmor )

	
	-- top armor
	self:AddArmor( Vector(5,-5,45), Angle(0,0,0), Vector(-50,-33,0), Vector(15,40,10), 300, self.RearArmor )
	self:AddArmor( Vector(-51,-5,43), Angle(-20,0,0), Vector(-30,-33,0), Vector(12,40,10), 300, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(-20,0,50), Angle(0,0,0), Vector(-20,-12,0), Vector(48,38,25), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-76,-10,3), Angle(-30,0,0), Vector(10,-25,7),Vector(20,45,37), 600, self.SideArmor )
	
	
	self:AddAmmoRack( Vector(5,25,40), Vector(5,0,55), Angle(0,0,0), Vector(-30,-5,-12.15), Vector(20,7,5.15) )

	self:AddTrailerHitch( Vector(-73,0,25), LVS.HITCHTYPE_MALE )
end
