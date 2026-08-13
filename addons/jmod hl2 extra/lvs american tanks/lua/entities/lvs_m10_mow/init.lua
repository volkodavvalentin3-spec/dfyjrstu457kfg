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

	local DriverSeat = self:AddDriverSeat( Vector(0,5,50), Angle(0,-90,0)--[[, "muzzle_smoke_left"]] )
	DriverSeat.HidePlayer = true
	  

	--[[local GunnerSeat = self:AddPassengerSeat( Vector(80,-24,31), Angle(0,-90,0) )
	GunnerSeat.HidePlayer = true
	self:SetGunnerSeat( GunnerSeat )]]
	
	
    local Seat1 = self:AddPassengerSeat( Vector(-55,35,70), Angle(0,0,0) )
	Seat1.HidePlayer = false
	local Seat2 = self:AddPassengerSeat( Vector(-55,-35,70), Angle(0,180,0) )
	Seat2.HidePlayer = false
	local Seat3 = self:AddPassengerSeat( Vector(-75,25,60), Angle(0,0,0) )
	Seat3.HidePlayer = false
	local Seat4 = self:AddPassengerSeat( Vector(-75,-25,60), Angle(0,180,0) )
	Seat4.HidePlayer = false

	self:AddEngine( Vector(-79.66,0,70), Angle(0,180,0) )
	self:AddFuelTank( Vector(-75,0,40), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(0,-20,-18),Vector(18,20,18) )

		-- front upper wedge center
	
	self:AddArmor( Vector(62,0,51), Angle(40,0,0), Vector(-8,-60,-20), Vector(55,60,20), self.FrontArmorHP, self.FrontArmor )
	

	-- side armor left front
	self:AddArmor( Vector(-10,33,52), Angle(0,0,0), Vector(-115,-40,-40), Vector(75,15,17), self.SideArmorHP, self.SideArmor )
	self:AddArmor( Vector(-10,41,35), Angle(0,0,45), Vector(-115,-5,-10), Vector(75,25,17), self.SideArmorHP, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(-10,-41,52), Angle(0,0,0), Vector(-115,-5,-40), Vector(75,40,17), self.SideArmorHP, self.SideArmor )
	self:AddArmor( Vector(-10,-55,52), Angle(0,0,-45), Vector(-115,-5,-10), Vector(75,25,17), self.SideArmorHP, self.SideArmor )
	

	
	-- top armor
	


	-- turret
	local TurretArmor = self:AddArmor( Vector(-5,0,70), Angle(0,0,0), Vector(-55,-50,0), Vector(65,50,30), self.TurretArmorHP, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	
	
	-- ammo rack weakspot
	self:AddAmmoRack( Vector(0,40,55), Vector(-5,0,70), Angle(0,0,0), Vector(-18,-6,-9), Vector(18,6,9) )
	self:AddAmmoRack( Vector(0,-40,55), Vector(-5,0,70), Angle(0,0,0), Vector(-18,-6,-9), Vector(18,6,9) )

	-- trailer hitch
	self:AddTrailerHitch( Vector(-100,0,24), LVS.HITCHTYPE_MALE )
end