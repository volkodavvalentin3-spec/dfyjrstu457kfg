-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Mortar Shell Smoke"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.ImpactSound = "Grenade.ImpactHard"
ENT.JModEZstorable = true
ENT.Arm = false
---
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/surgeon/mortarshell.mdl")
		--self:SetColor(Color(50, 50, 50))
    	self:SetSolid(SOLID_VPHYSICS)
    	self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType( SIMPLE_USE )
		self:SetKeyValue("fademindist", "2048") 
		self:SetKeyValue("fademaxdist", "2304") 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		self.IgnoreBlastTime = CurTime() + 2

		self:SetSkin( 1 )

		if IsValid(self) then
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then 
				phys:SetMass(20)
				phys:Wake()
			end
		end
	end

	function ENT:Use(ply)
		if self:IsPlayerHolding() then return end

		ply:PickupObject( self )
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		--if data.HitEntity.NoEZbombletDet then return end

		if self.Arm then
			if data.DeltaTime > 0.2 then
				self:Detonate()
			end
		end

		if data.DeltaTime > 0.2 and data.Speed > 30 then
			self:EmitSound(self.ImpactSound)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.IgnoreBlastTime < CurTime() then
			self:TakePhysicsDamage(dmginfo)
		end

		if dmginfo:GetDamage() >= 80 then
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Remove()
			--self:Detonate()
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		JMod.Sploom(self.EZowner, self:GetPos(), math.random(10, 20), 254)
		self:EmitSound("explosions/artillery_strike_gas_close_0" .. math.random(1,4) .. ".wav", 90, 100)
		EmitFarSound(self:GetPos(), math.random(919,922), 1000, 2000, 2000, 0)
		
		util.ScreenShake(SelfPos, 20, 20, 1, 1000)

		local d = DamageInfo()
		d:SetDamage( 100 )
		d:SetAttacker( self )
		d:SetDamageType( DMG_BURN ) 

		util.BlastDamageInfo( d, SelfPos, 512 )

		for i = 1, 10 do
			local Eff = EffectData()
			Eff:SetOrigin(SelfPos)
			util.Effect("phosphorus", Eff)
		end

		self:Remove()
	end

elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	--language.Add("ent_jack_gmod_ezbomblet", "EZ Bomblet")
end
