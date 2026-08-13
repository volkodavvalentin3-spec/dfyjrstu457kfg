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
	  


	
	local Seat1 = self:AddPassengerSeat( Vector(-35,30,54), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-35,-30,54), Angle(0,180,0) )
	Seat2.HidePlayer = false
	

	self:AddEngine( Vector(-40,0,40), Angle(0,180,0) )
	self:AddFuelTank( Vector(-60,0,30), Angle(0,0,0), 2200, LVS.FUELTYPE_PETROL, Vector(-12,-30,-12),Vector(12,30,20) )

			-- front upper wedge center
	self:AddArmor( Vector(55,-35,30), Angle(20,0,0), Vector(0,0,0), Vector(45,70,20), 600, self.FrontArmor )
	self:AddArmor( Vector(45,-35,35), Angle(0,0,0), Vector(0,0,0), Vector(33,70,20), 600, self.FrontArmor )
	

	-- side armor left front
	self:AddArmor( Vector(0,21,44), Angle(0,0,0), Vector(-50,-15,-20), Vector(55,25,13), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(0,-31,44), Angle(0,0,0), Vector(-50,-15,-20), Vector(55,25,13), 600, self.SideArmor )

	
	-- top armor
	
	self:AddArmor( Vector(-61,0,44), Angle(-15,0,0), Vector(-41,-50,-20), Vector(16,50,10), 300, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(0,0,50), Angle(0,0,0), Vector(-20,-35,0), Vector(70,35,35), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-105,-10,5), Angle(0,0,0), Vector(10,-25,7),Vector(30,45,34), 600, self.SideArmor )
	
	
	self:AddAmmoRack( Vector(25,0,25), Vector(21,0,65), Angle(0,0,0), Vector(-30,-25,-12.15), Vector(20,27,5.15) )

	self:AddTrailerHitch( Vector(-90,0,25), LVS.HITCHTYPE_MALE )
end
