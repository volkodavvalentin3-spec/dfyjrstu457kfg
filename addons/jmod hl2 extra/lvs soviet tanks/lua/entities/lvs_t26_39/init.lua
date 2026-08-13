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
	  
	
	local Seat1 = self:AddPassengerSeat( Vector(-45,28,35), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-28,35), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-75,-28,35), Angle(0,180,0) )
	Seat3.HidePlayer = false


	self:AddEngine( Vector(-40,20,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(-60,-20,30), Angle(0,0,0), 2600, LVS.FUELTYPE_PETROL, Vector(-12,-10,-12),Vector(30,10,0) )

		-- front upper wedge center
	self:AddArmor( Vector(14,-35,30), Angle(10,0,0), Vector(0,0,0), Vector(65,70,20), 600, self.FrontArmor )
	self:AddArmor( Vector(-23,-37,40), Angle(0,0,0), Vector(0,0,0), Vector(60,75,20), 600, self.FrontArmor )
	

	-- side armor left front
	self:AddArmor( Vector(20,40,30), Angle(0,0,0), Vector(-90,-5,-15), Vector(30,15,13), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(20,-40,30), Angle(0,0,0), Vector(-90,-5,-15), Vector(30,15,13), 600, self.SideArmor )

	
	-- top armor
	
	self:AddArmor( Vector(-27,-5,40), Angle(-10,0,0), Vector(-50,-30,0), Vector(5,40,10), 300, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(-5,-5,60), Angle(0,0,0), Vector(-35,-17,0), Vector(34,38,22), 600, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-85,-10,5), Angle(-10,0,0), Vector(10,-25,7),Vector(20,45,34), 300, self.SideArmor )

    self:AddAmmoRack( Vector(5,0,30), Vector(5,0,65), Angle(0,0,0), Vector(-30,-25,-12.15), Vector(20,25,5.15) )

	self:AddTrailerHitch( Vector(-80,0,22), LVS.HITCHTYPE_MALE )
end



