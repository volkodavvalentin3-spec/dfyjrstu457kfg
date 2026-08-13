-- FumoFumo 2025
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "#ent_fumo_gmod_ezthunderstick"
ENT.PhysicsSounds = true
ENT.Category = "WWars"
ENT.Spawnable = true
ENT.PhysicsSounds = true
---
ENT.JModPreferredCarryAngles = Angle( 90, 0, 0 )
---

if SERVER then

	function ENT:Initialize()
		self:SetModel( "models/props_ww_weapons/thunderstick01a.mdl" )
		self:SetSkin( math.random( 0, 4 ) )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PrecacheGibs()

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:Wake()
		end

		self.IsExploded = false

	end
	
	function ENT:Use( ply )
		local phys = self:GetPhysicsObject()
		local grndEnt = ply:GetGroundEntity()

		if grndEnt ~= self and phys:IsMotionEnabled() then
			ply:PickupObject( self )
		end

	end

	function ENT:PhysicsCollide( data, physobj )
		local hitDot = ( self:GetUp() * -1 ):Dot( data.HitSpeed:GetNormalized() )

		if data.DeltaTime > 0.2 and data.HitSpeed:LengthSqr() > 65536 then
			if hitDot > 0.5 then
				self:Explode( data.OurOldVelocity )
			end
		end

	end
	
	function ENT:Think()

		JMod.AeroDrag( self, self:GetUp(), 5 )

		self:NextThink( CurTime() + 0.25 )

		return true
	end

	function ENT:OnTakeDamage( dmgInfo )
		if dmgInfo:GetInflictor() == self or self.isExploded then return end

		self:TakePhysicsDamage( dmgInfo )

		local dmgVal = dmgInfo:GetDamage()
		if dmgVal < 4 then return end

		local vel = self:GetVelocity()
		local dmgPos = dmgInfo:GetDamagePosition()
		local canPos = self:GetPos() + self:GetUp() * 40

		if dmgVal >= 4 and canPos:DistToSqr( dmgPos ) <= 49 then -- 49 is 7 unit from can
			self:Explode( vel * 2 )
		end

		if dmgVal >= 15 and dmgInfo:IsDamageType( DMG_BLAST ) then
			self:Explode( ( vel + dmgInfo:GetDamageForce() ) * 0.02 ) -- magic number yay
		end

	end

	function ENT:Explode( gibVel )
		if self.IsExploded then return end
		self.IsExploded = true
		local canPos = self:GetPos() + self:GetUp() * 40
		util.BlastDamage( self, self, canPos, 64, 128  )
		self:GibBreakClient( gibVel + ( self:GetUp() * math.random( 2, 5 ) * -1 ) )
		
		local effectData = EffectData()
		effectData:SetOrigin( canPos )
		effectData:SetMagnitude( 1 )
		effectData:SetScale( 1 )
		effectData:SetRadius( 50 )
--		effectData:Flags(  )
		util.Effect( "Explosion", effectData )

		self:Remove()

	end

	function ENT:Throw( ply, force )
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			local throwForce = force or 1
			phys:AddVelocity( ply:GetAimVector() * force )
		end
	end

elseif CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

end

hook.Add( "OnPlayerPhysicsDrop", "ThunderStickThrow", function( ply, ent, thrown )
	if ent:IsValid() and ent:GetClass() == "ent_fumo_gmod_ezthunderstick" then
		if thrown then
			ent:Throw( ply, 512 )
		end
	end
 end )