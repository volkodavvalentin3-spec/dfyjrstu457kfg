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

	local DriverSeat = self:AddDriverSeat( Vector(0,0,30), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	  

	local GunnerSeat = self:AddPassengerSeat( Vector(20,-10,31), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )
	
	
    local Seat1 = self:AddPassengerSeat( Vector(-7,12,45), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-7,-12,45), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-27,12,45), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-27,-12,45), Angle(0,180,0) )
	Seat4.HidePlayer = false
	local Seat5 = self:AddPassengerSeat( Vector(-44,12,45), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat6 = self:AddPassengerSeat( Vector(-44,-12,45), Angle(0,180,0) )
	Seat4.HidePlayer = false

	self:AddEngine( Vector(-50,0,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(-30,0,15), Angle(0,0,0), 1600, LVS.FUELTYPE_PETROL, Vector(-10,-10,0),Vector(30,10,35) )

    self:AddArmor( Vector(-10,0,50), Angle(0,0,0), Vector(-60,-35,-40), Vector(75,35,10), 800, self.SideArmor )
 
	self:AddTrailerHitch( Vector(-70,0,22), LVS.HITCHTYPE_MALE )
end

