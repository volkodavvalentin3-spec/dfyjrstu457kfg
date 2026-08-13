-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Thin-Skinned Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZRackOffset = Vector(0, 0, 20)
ENT.EZRackAngles = Angle(0, -90, 0)
ENT.EZbombBaySize = 5
ENT.EZguidable = false
---
ENT.Model = "models/hunter/blocks/cube025x075x025.mdl"
ENT.Mass = 100
ENT.DetSpeed = 500

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)
		--JMod.Sploom(Att, SelfPos, 300)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 4000)
		local Eff = "500lb_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "500lb_air"
		else
			for i = 1, 100 do
				local Eff = EffectData()
	       		Eff:SetOrigin(SelfPos)
	       		util.Effect("battlefieldsmoke", Eff)
			end
		end

		for i = 1, 3 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---

		if math.random(1,2) == 1 then
			EmitFarSound(self:GetPos(), math.random(179,181), 1000, 1500, 2000, 0)
		else
			EmitFarSound(self:GetPos(), math.random(183,186), 1000, 1500, 2000, 0)
		end
		

		--[[for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 250) and (Dist < 4000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.ogg", 55, 110)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 3, 1, 100)
				end)
			end
		end]]

		for _, ent in pairs( ents.FindInSphere( self:GetPos(), 2500 ) ) do
			if ent:IsPlayer() and ply ~= ent then
				ent:SetCrazy(ent:GetCrazy() + math.Rand(0.1,0.2))

				if math.random(1,3) == 1 then
					ent:CrazyEffect()
				end

			end
		end

		---
		util.BlastDamage(self, Att, SelfPos + Vector(0, 0, 300), 600, 600)

		--[[timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 1600, 100)
		end)]]

		for k, ent in pairs(ents.FindInSphere(SelfPos, 500)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 7)
		JMod.BlastDoors(self, SelfPos, 7)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:AeroDragThink()
		JMod.AeroDrag(self, -self:GetRight(), 2)
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jailure/wwii/wwii.mdl")
		self.Mdl:SetSubMaterial(0, "models/jmod/explosives/bombs/he_bomb")
		self.Mdl:SetModelScale(.8, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		
		self.Mdl:SetNoDraw(true)
		self.snd = CreateSound(self, self.WhistleSound)
		self.snd:SetSoundLevel( 110 )
		self.snd:PlayEx(0,150)
	end

	function ENT:CalcDoppler()
		local Ent = LocalPlayer()
		local ViewEnt = Ent:GetViewEntity()

		local sVel = self:GetVelocity()
		local oVel = Ent:GetVelocity()
		local SubVel = oVel - sVel
		local SubPos = self:GetPos() - Ent:GetPos()
	
		local DirPos = SubPos:GetNormalized()
		local DirVel = SubVel:GetNormalized()
		local A = math.acos( math.Clamp( DirVel:Dot( DirPos ) ,-1,1) )
		return 1 + math.cos( A ) * SubVel:Length() / 13503.9
	end
	--
	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(), -90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos + Ang:Right() * 6 + Ang:Forward() * 15)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end

	function ENT:Think()
		if self.snd then
			self.snd:ChangePitch( 100 * self:CalcDoppler(), 1 )
			self.snd:ChangeVolume(math.Clamp((self:GetVelocity():LengthSqr() - 150000) / 5000,0,1), 2)
		end

		if self:GetState() == STATE_ARMED and not self.snd then
			self.snd = CreateSound(self, self.WhistleSound)
			self.snd:SetSoundLevel( 110 )
			self.snd:PlayEx(0,150)
		elseif self:GetState() == STATE_OFF and self.snd then
			self.snd = nil
		end
	end

	function ENT:OnRemove()
		if self.snd then
			self.snd:Stop()
		end
	end

	language.Add("ent_jack_gmod_ezhebomb", "EZ Thin-Skinned Bomb")
end
