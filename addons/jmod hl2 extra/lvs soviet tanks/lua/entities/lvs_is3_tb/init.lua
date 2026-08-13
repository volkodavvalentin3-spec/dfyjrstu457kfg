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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "weapons/t90ms_cannon.wav", "weapons/t90ms_cannon.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos - Muzzle.Ang:Up() * 140 - Muzzle.Ang:Forward() * 15 ), "lvs/vehicles/sherman/mg_loop.wav", "lvs/vehicles/sherman/mg_loop_interior.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

    local DriverSeat = self:AddDriverSeat( Vector(0,0,60), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	
	
	local Seat1 = self:AddPassengerSeat( Vector(-55,45,56), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-55,-50,56), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-85,50,56), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-85,-50,56), Angle(0,180,0) )
	Seat4.HidePlayer = false

	
	self:AddEngine( Vector(-110,0,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(-40,0,50), Angle(0,0,0), 2200, LVS.FUELTYPE_PETROL, Vector(-22,-37,-32),Vector(12,37,0) )

	-- front plate
	self:AddArmor( Vector(125,0,25), Angle(50,0,0), Vector(-5,-40,-20), Vector(5,40,20), 4000, self.FrontArmor )

	-- "windscreen"
	self:AddArmor( Vector(105,40,45), Angle(-60,20,-20), Vector(-5,-43,-30), Vector(5,15,30), 4000, self.FrontArmor )
	self:AddArmor( Vector(105,-15,50), Angle(-60,-20,20), Vector(-5,-40,-30), Vector(5,17,30), 4000, self.FrontArmor )

	-- side armor
	self:AddArmor( Vector(5,39,42), Angle(0,0,-30), Vector(-130,-5,0), Vector(80,5,25), 3000, self.SideArmor )
	self:AddArmor( Vector(5,39,20), Angle(0,0,0), Vector(-130,-15,-20), Vector(100,5,25), 3000, self.SideArmor )
	self:AddArmor( Vector(-23,0,43), Angle(0,0,0), Vector(-90,-45,0), Vector(100,45,25), 3000, self.SideArmor )

	self:AddArmor( Vector(5,-39,42), Angle(0,0,30), Vector(-130,-5,0), Vector(80,5,25), 3000, self.SideArmor )
	self:AddArmor( Vector(5,-39,20), Angle(0,0,0), Vector(-130,-15,-20), Vector(100,5,25), 3000, self.SideArmor )
	

	-- turret
	local TurretArmor = self:AddArmor( Vector(30,0,55), Angle(0,0,0), Vector(-70,-62,0), Vector(70,62,40), 3000, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-136,0,30), Angle(50,0,0), Vector(-10,-55,0),Vector(20,55,45), 3000, self.RearArmor )

	-- driver viewport weakspot
	self:AddDriverViewPort( Vector(105,21,55), Angle(0,0,0), Vector(-1,-7,-1), Vector(1,7,1) )

	-- ammo rack weakspot
	
	self:AddAmmoRack( Vector(30,20,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
	self:AddAmmoRack( Vector(30,-20,30), Vector(0,0,65), Angle(0,0,0), Vector(-30,-6,-12), Vector(30,6,12) )
end
