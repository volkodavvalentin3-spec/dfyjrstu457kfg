AddCSLuaFile( "shared.lua" )
--AddCSLuaFile( "sh_turret.lua" )
AddCSLuaFile( "cl_init.lua" )
--AddCSLuaFile( "cl_optics.lua" )
include("shared.lua")
--include("sh_turret.lua")

util.AddNetworkString( "set_schneider_range" )

ENT.AISearchCone = 30

ENT.AmmoWhiteList = {
	["ent_jack_gmod_ezhebomb"] = true,
	["ent_jack_gmod_ezclusterbomb"] = true,
	["ent_jack_gmod_ezchlorinebomb"] = true,
	["ent_jack_gmod_ezincendiarybomb"] = true,
}

ENT.AmmoAngle = {
	["ent_jack_gmod_ezhebomb"] = Angle(85, 0, 0),
	["ent_jack_gmod_ezclusterbomb"] = Angle(-85, 0, 0),
	["ent_jack_gmod_ezchlorinebomb"] = Angle(-85, 0, 0),
	["ent_jack_gmod_ezincendiarybomb"] = Angle(-85, 0, 0),
}

ENT.Range = 50
ENT.Turn = 0

ENT.AmmoTable = {}

net.Receive( "set_schneider_range", function(len, ply)
	local ent = net.ReadEntity()
	local fire = net.ReadBool()

    local range = net.ReadFloat()
    local turn = net.ReadFloat()

	ent.Range = range
	ent.Turn = turn

	if fire then
		if ent.AmmoTable[1] then
			ent:FireJmodProjectile(ply)
		end
	end

end)


function ENT:OnSpawn( PObj )
	--self:AddDriverSeat( Vector(-50,20,-46), Angle(0,-90,0) )

	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurret = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/vehicles/cannons/105to130mm.mp3" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )

	local WheelModel = "models/diggerCars/cannons/schneider_wheel.mdl"

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_NONE,
			SteerAngle = 0,
			BrakeFactor = 1,
		},
		Wheels = {
			self:AddWheel( {
				pos = Vector(-1.05,30.02,-17),
				mdl = WheelModel,
				mdl_ang = Angle(0,-90,0),
			} ),

			self:AddWheel( {
				pos = Vector(-1.05,-30.02,-17),
				mdl = WheelModel,
				mdl_ang = Angle(0,90,0),

			} ),
		},
		Suspension = {
			Height = 0,
			MaxTravel = 0,
			ControlArmLength = 0,
		},
	} )

	self:AddTrailerHitch( Vector(-151.64,0,-36.45), LVS.HITCHTYPE_FEMALE )

	self:TakeAmmo()

	self:SetPoseParameter("cannon_pitch", 10 )
	self:SetPoseParameter("cannon_yaw", 0 )
end

function ENT:OnCollision( data, physobj )
	if self:WorldToLocal( data.HitPos ).z < 19 then return true end -- dont detect collision  when the lower part of the model touches the ground

	return false
end

function ENT:OnCoupled( targetVehicle, targetHitch )
	self:SetProngs( true )
end

function ENT:OnDecoupled( targetVehicle, targetHitch )
	self:SetProngs( false )
end

function ENT:OnStartDrag( caller, activator )
	self:SetProngs( true )
end

function ENT:OnStopDrag( caller, activator )
	self:SetProngs( false )
end

function ENT:SpawnShell()
	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle then return end

	local Shell = ents.Create( "lvs_item_shell" )

	if not IsValid( Shell ) then return end

	Shell:SetPos( Muzzle.Pos - Muzzle.Ang:Forward() * 100 )
	Shell:SetAngles( Muzzle.Ang + Angle(0,90,90) )
	Shell:Spawn()
	Shell:Activate()
	Shell:SetOwner( self )

	local PhysObj = Shell:GetPhysicsObject()

	if not IsValid( PhysObj ) then return end

	PhysObj:SetVelocityInstantaneous( Shell:GetRight() * 250 - Shell:GetUp() * 20 )
	PhysObj:SetAngleVelocityInstantaneous( Vector(-80,0,0) )
end

function ENT:DoReloadSequence( delay )
	if self._ReloadActive then return end

	self._ReloadActive = true

	self:SetBodygroup(1, 1)

	timer.Simple(delay, function()
		if not IsValid( self ) then return end

		self:PlayAnimation("breach")

		self:EmitSound("lvs/vehicles/pak40/cannon_unload.wav", 75, 100, 0.5, CHAN_WEAPON )

		timer.Simple(0.3, function()
			if not IsValid( self ) then return end
			self:SpawnShell()
		end)
	end)

	timer.Simple(2, function()
		if not IsValid( self ) then return end

		self:PlayAnimation("reload")

		self:EmitSound("lvs/vehicles/pak40/cannon_reload.wav", 75, 100, 1, CHAN_WEAPON )

		timer.Simple(0.1, function()
			if not IsValid( self ) then return end
			self:SetBodygroup(1, 0)
			self._ReloadActive = nil
		end )
	end )
end

function ENT:DoAttackSequence()
	if not IsValid( self.SNDTurret ) then return end

	self.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

	self:PlayAnimation("fire")

	self:DoReloadSequence( 1 )
end

function ENT:Think()
	local SelfAngles = self:GetAngles()
	SelfAngles.p = 0 
	SelfAngles.r = 0

	debugoverlay.Axis( self:GetPos() + (SelfAngles:Forward() * self.Range * 45) + SelfAngles:Right() * self.Turn * 45, SelfAngles, 500, 0.2, true )
end

function ENT:Use(ply)
	net.Start("set_schneider_range")
		net.WriteEntity(self)
		net.WriteFloat(self.Range)
		net.WriteFloat(self.Turn)
	net.Send(ply)
end

function ENT:FireJmodProjectile(ply)
	local ID = self:LookupAttachment( "muzzle" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle then return end

	local CanFire = util.TraceLine( {
        start = Muzzle.Pos,
        endpos = Muzzle.Pos + Muzzle.Ang:Forward() * 700,
		filter = self
    } )

	debugoverlay.Line(Muzzle.Pos, Muzzle.Pos + Muzzle.Ang:Forward() * 700, 3, Color(0,255,0), true)

	if CanFire.Hit then
		ply:LanRPChatPrint(Color(230,0,0), "Ты не можешь стрелять, пока перед тобой преграда.")
		return
	end

	local SelfAngles = self:GetAngles()
	SelfAngles.p = 0 
	SelfAngles.r = 0

	local LieVector = self:GetPos() + (SelfAngles:Forward() * self.Range * 45) + SelfAngles:Right() * self.Turn * 45

	local RangeDistance = math.Clamp(self:GetPos():Distance( LieVector ) / 2100, 0, 2)

	local TrueVector = util.TraceLine( {
        start = LieVector + Vector(0,0,2048),
        endpos = LieVector + Vector(0,0,5000 * RangeDistance),
        mask = MASK_SOLID_BRUSHONLY
    } )

	local projectile = ents.Create(self.AmmoTable[1])
	projectile:SetPos( TrueVector.HitPos + Vector(math.random( -500 * RangeDistance, 500 * RangeDistance), math.random( -500 * RangeDistance, 500 * RangeDistance), 0))
	projectile:SetAngles( Angle(90,0,0) + self.AmmoAngle[self.AmmoTable[1]])
	projectile:Spawn()
	projectile:Activate()
	projectile:SetState(1)

	projectile:SetCollisionGroup( COLLISION_GROUP_WORLD)

	debugoverlay.Line(LieVector, projectile:GetPos(), 10, Color(255,255,255), true)

	--[[timer.Simple(0.1, function()
		if IsValid(projectile) then
			projectile:SetCollisionGroup( COLLISION_GROUP_NONE)
		end
	end)]]

	local effectdata = EffectData()
	effectdata:SetOrigin( Muzzle.Pos )
	effectdata:SetNormal( Muzzle.Ang:Forward() )
	effectdata:SetEntity( self )
	util.Effect( "lvs_haubitze_muzzle", effectdata )

	local PhysObj = projectile:GetPhysicsObject()
	if IsValid( PhysObj ) then
		PhysObj:ApplyForceCenter( Vector(0,0,-1000) )
	end

	local PhysObj = self:GetPhysicsObject()
	if IsValid( PhysObj ) then
		PhysObj:ApplyForceOffset( -Muzzle.Ang:Forward() * 200000, Muzzle.Pos )
	end

	self:TakeAmmo()
	self:SetHeat( 1 )
	self:SetOverheated( true )

	if not IsValid( self.SNDTurret ) then return end

	self:DoAttackSequence()

	self.SNDTurret:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )

	self:EmitSound("lvs/vehicles/wespe/cannon_reload.wav", 75, 100, 1, CHAN_WEAPON )

	EmitFarSound(self:GetPos(), math.random(16,19), 5000, 10000, 1000, 0)

	table.remove( self.AmmoTable, 1 )
end

function ENT:PhysicsCollide( data, phys )
	local ent = data.HitEntity
	local Ammo = self:GetAmmo()
	local MaxAmmo = self:GetMaxAmmo() 

	if ( data.Speed > 50 ) 
	and self.AmmoWhiteList[ent:GetClass()] and Ammo < MaxAmmo then  

		for PodID, data in pairs( self.WEAPONS ) do
			for id, weapon in pairs( data ) do
				local MaxAmmo = weapon.Ammo or -1
				local CurAmmo = weapon._CurAmmo or MaxAmmo
	
				if CurAmmo == MaxAmmo then continue end
	
				self.WEAPONS[PodID][ id ]._CurAmmo = math.min( CurAmmo + 1, MaxAmmo )
	
				AmmoIsSet = true
			end
		end
	
		if AmmoIsSet then
			self:SetNWAmmo( self:GetAmmo() )
	
			for _, pod in pairs( self:GetPassengerSeats() ) do
				local weapon = pod:lvsGetWeapon()
	
				if not IsValid( weapon ) then continue end
	
				weapon:SetNWAmmo( weapon:GetAmmo() )
			end
		end

		self:EmitSound("items/ammo_pickup.wav")

		table.insert(self.AmmoTable, ent:GetClass())

		--PrintTable(self.AmmoTable)

		ent:Remove()
	end
end
