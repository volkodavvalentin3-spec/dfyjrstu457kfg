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

	local DriverSeat = self:AddDriverSeat( Vector(-50,30,10), Angle(0,-90,0) )
	DriverSeat.HidePlayer = false
	  

	
	
	local Seat1 = self:AddPassengerSeat( Vector(15,25,50), Angle(0,0,0) )
	Seat1.HidePlayer = false
	
	local Seat2 = self:AddPassengerSeat( Vector(15,-27,50), Angle(0,180,0) )
	Seat2.HidePlayer = false


	self:AddEngine( Vector(10,-20,30), Angle(0,180,0) )
	self:AddFuelTank( Vector(10,18,30), Angle(0,0,0), 2600, LVS.FUELTYPE_PETROL, Vector(-12,-5,-12),Vector(32,20,20) )

		-- front upper wedge center
	self:AddArmor( Vector(34,-40,40), Angle(28,0,0), Vector(0,0,0), Vector(55,80,20), 600, self.FrontArmor )
	
	

	-- side armor left front
	self:AddArmor( Vector(13,29,32), Angle(0,0,0), Vector(-100,-15,-10), Vector(30,15,23), 600, self.SideArmor )

	-- side armor right front
	self:AddArmor( Vector(13,-29,32), Angle(0,0,0), Vector(-100,-15,-10), Vector(30,15,23), 600, self.SideArmor )

	
	-- top armor
	self:AddArmor( Vector(27,-6,45), Angle(0,0,0), Vector(-40,-33,0), Vector(15,45,10), 300, self.RearArmor )
	

	-- turret
	local TurretArmor = self:AddArmor( Vector(-50,5,50), Angle(0,0,0), Vector(-35,-45,0), Vector(44,45,35), 800, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear up
	self:AddArmor( Vector(-95,0,10), Angle(0,0,0), Vector(10,-35,7),Vector(20,45,45), 600, self.SideArmor )
	
	
	self:AddAmmoRack( Vector(-40,30,30), Vector(-40,0,35), Angle(0,0,0), Vector(-30,-5,-16), Vector(20,7,25) )
	self:AddAmmoRack( Vector(-40,-30,30), Vector(-40,0,35), Angle(0,0,0), Vector(-30,-5,-16), Vector(20,7,25) )

	self:AddTrailerHitch( Vector(-85,0,25), LVS.HITCHTYPE_MALE )

end



