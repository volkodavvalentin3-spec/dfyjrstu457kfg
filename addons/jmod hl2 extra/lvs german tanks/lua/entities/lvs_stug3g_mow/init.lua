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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/75mm_kwk42.wav", "weapons/75mm_kwk42.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	
	
	local Seat1 = self:AddPassengerSeat( Vector(-45,40,60), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-45,-40,60), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-75,40,60), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-75,-40,50), Angle(0,180,0) )
	Seat4.HidePlayer = false

	self:AddEngine( Vector(-50,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-70,0,15), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-10,-30,0),Vector(10,30,35) )

	self:AddArmor( Vector(45,0,44), Angle(5,0,0), Vector(0,-39,0), Vector(44,39,10), 800, self.SideArmor )
	self:AddArmor( Vector(85,0,43), Angle(30,0,0), Vector(0,-39,0), Vector(15,39,10), 1300, self.FrontArmor )
	self:AddArmor( Vector(97,0,39), Angle(112,0,0), Vector(-5,-39,0), Vector(22,39,10), 1300, self.FrontArmor )

	-- side armor left
	self:AddArmor( Vector(10,24,51), Angle(0,0,0), Vector(-82,5,-20), Vector(50,15,13), 800, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(10,-24,51), Angle(0,0,0), Vector(-82,-15,-20), Vector(50,-5,13), 800, self.SideArmor )

	-- top armor
	self:AddArmor( Vector(10,0,51), Angle(0,0,0), Vector(-82,-30,-20), Vector(50,30,13), 600, self.RearArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(15,0,50), Angle(0,0,0), Vector(-50,-50,0), Vector(54,50,34), 1200, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-90,0,44), Angle(-15,0,0), Vector(-10,-40,0), Vector(23,40,15), 300, self.SideArmor )

	-- rear mid
	self:AddArmor( Vector(-105,0,43), Angle(-60,0,0), Vector(-10,-40,-5), Vector(10,40,6), 800, self.SideArmor )

	-- rear down
	self:AddArmor( Vector(-90,0,23), Angle(-10,0,0), Vector(-5,-40,0), Vector(5,40,20), 1200, self.FrontArmor )

	-- rear very down
	self:AddArmor( Vector(-90,0,26), Angle(-66,0,0), Vector(-5,-40,-25), Vector(5,40,3), 1200, self.FrontArmor )
	
	self:AddTrailerHitch( Vector(-90,0,22), LVS.HITCHTYPE_MALE )
	
	-- fuel tank
	self:AddFuelTank( Vector(-70,0,20), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-5,-30,0),Vector(5,30,35) )

	-- ammo rack weakspot
	self:AddAmmoRack( Vector(23.38,-29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	self:AddAmmoRack( Vector(23.38,29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	self:AddAmmoRack( Vector(-5.38,-29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	self:AddAmmoRack( Vector(-5.38,29.13,30.32), Vector(10,0,62.5), Angle(90,90,0), Vector(-9.25,-12.25,-6.25), Vector(9.25,12.25,6.25) )
	
end



