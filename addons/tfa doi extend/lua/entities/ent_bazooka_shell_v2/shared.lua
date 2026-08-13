ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "New Doi Projectile"
ENT.Category		= "None"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false


ENT.MyModel = "models/weapons/tfa_doi/w_bazooka_projectile.mdl"
ENT.MyModelScale = 1
ENT.Damage = 100
ENT.Radius = 100
if SERVER then

	AddCSLuaFile()

	function ENT:Initialize()

		local model = self.MyModel and self.MyModel 
		
		self.Class = self:GetClass()
		
		self:SetModel(model)
		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetHealth(1)
		self:SetModelScale(self.MyModelScale,0)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:Wake()
		end
		
		local ply = self.Owner

		local bullet = {}
		bullet.Src 	= ply:GetShootPos() + ply:EyeAngles():Right() * 2
		bullet.Dir 	= ply:EyeAngles():Forward()
		bullet.Spread 	= Vector(0.015,0.015,0.015)
		bullet.EnableBallistics = true
		bullet.TracerName = "lvs_tracer_cannon"
		bullet.Force	= 14000
		bullet.HullSize 	= 0
		bullet.Damage	= 250

		bullet.SplashDamage = 100
		bullet.SplashDamageRadius = 128
		bullet.SplashDamageEffect = "lvs_bullet_impact_explosive"
		bullet.SplashDamageType = DMG_BLAST

		bullet.Velocity = 8000
		bullet.Entity = ply
		bullet.Attacker 	= ply

		--bullet.Velocity = bullet.Velocity + self:GetVelocity():Length()
		bullet.SrcEntity = self:WorldToLocal( bullet.Src )
		LVS:FireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( bullet.Dir )
		effectdata:SetEntity( self )
		util.Effect( "lvs_muzzle", effectdata )

		self:Remove()
	end

	function ENT:PhysicsCollide(data, physobj)
		--[[local owent = self.Owner and self.Owner or self
		util.BlastDamage(self,owent,self:GetPos(),self.Radius,self.Damage)
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		fx:SetNormal(data.HitNormal)
		util.Effect("Explosion",fx)

		ParticleEffect("50lb_air", self:GetPos() - -self:GetRight() * 20, self:GetAngles())
		--ParticleEffect("50lb_air", self:GetPos() - -self:GetRight() * 50, self:GetAngles())
		--ParticleEffect("50lb_air", self:GetPos() - -self:GetRight() * 80, self:GetAngles())

		self:Remove()]]
	end
end

function ENT:Think()

	--[[--self:SetAngles(self:GetVelocity())

	local Eff = EffectData()
	Eff:SetOrigin(self:GetPos())
	Eff:SetScale(1)
	util.Effect( "effect_rocket_smoke", Eff )]]

end

if CLIENT then
	
	function ENT:Draw()
		self:DrawModel()
	end

end