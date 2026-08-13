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
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/222/cannon_fire_interior.wav", "lvs/vehicles/222/cannon_fire_interior.wav")
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


	self:AddEngine( Vector(-45.66,-10,50), Angle(0,180,0) )
	self:AddFuelTank( Vector(8,-14,35), Angle(0,0,0), 600, LVS.FUELTYPE_PETROL, Vector(-21,-6,-12),Vector(21,6,12) )

	-- front upper wedge center
	self:AddArmor( Vector(67,0,50), Angle(80,0,0), Vector(-10,-10,-15), Vector(5,30,5), 600, self.FrontArmor )

	-- front upper wedge right
	self:AddArmor( Vector(55,-20,50), Angle(80,-45,0), Vector(-10,-15,-15), Vector(5,22,5), 600, self.FrontArmor )

	-- front upper wedge left
	self:AddArmor( Vector(45,35,50), Angle(80,80,0), Vector(-10,-25,-15), Vector(5,22,5), 300, self.SideArmor )

	-- front lower wedge
	self:AddArmor( Vector(88,0,33), Angle(17,0,0), Vector(-40,-32,-15), Vector(15,32,10), 600, self.FrontArmor )

	-- side armor left
	self:AddArmor( Vector(30,28,50), Angle(0,0,0), Vector(-50,-30,-14), Vector(0,15,10), 300, self.SideArmor )

	-- side armor right
	self:AddArmor( Vector(30,-16,50), Angle(0,0,0), Vector(-50,-15,-14), Vector(20,15,10), 300, self.SideArmor )

	-- side armor right rear
	self:AddArmor( Vector(-30,-16,47), Angle(-10,0,0), Vector(-50,-15,-14), Vector(20,20,10), 200, self.RearArmor )

	-- side armor left rear
	self:AddArmor( Vector(-30,22,40), Angle(0,0,0), Vector(-50,-19,-14), Vector(20,15,10), 300, self.SideArmor )

	-- turret
	local TurretArmor = self:AddArmor( Vector(25,5,60), Angle(0,0,0), Vector(-40,-30,0), Vector(34,34,20), 500, self.TurretArmor )
	TurretArmor.OnDestroyed = function( ent, dmginfo ) if not IsValid( self ) then return end self:SetTurretDestroyed( true ) end
	TurretArmor.OnRepaired = function( ent ) if not IsValid( self ) then return end self:SetTurretDestroyed( false ) end
	TurretArmor:SetLabel( "Turret" )
	self:SetTurretArmor( TurretArmor )

	-- rear
	self:AddArmor( Vector(-63,0,20), Angle(-15,0,0), Vector(-10,-30,-5),Vector(10,30,30), 200, self.RearArmor )


	-- ammo rack weakspot
	self:AddAmmoRack( Vector(8.5,-15,52), Vector(12,0,60), Angle(0,0,0), Vector(-21,-6,-3), Vector(21,6,3) )
	

	-- trailer hitch
	self:AddTrailerHitch( Vector(-75.49,0,24.98), LVS.HITCHTYPE_MALE )

end



