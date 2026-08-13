-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Incendiary Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 90, 0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, 0, 0)
ENT.EZbombBaySize = 5
---
ENT.EZguidable = false
ENT.Model = "models/hunter/blocks/cube025x125x025.mdl"
--ENT.Model = "models/props_phx/ww2bomb.mdl"
ENT.Mass = 100
ENT.DetSpeed = 1000
ENT.DetType = "airburst"

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1000)
		---
		local Dir = self:GetPhysicsObject():GetVelocity():GetNormalized()
		local Speed = math.Clamp(self:GetPhysicsObject():GetVelocity():Length(), 0, self.DetSpeed * .5)
		---
		local Sploom = EffectData()
		Sploom:SetOrigin(SelfPos)
		Sploom:SetScale(.6)
		Sploom:SetNormal(Dir)
		util.Effect("eff_jack_firebomb", Sploom, true, true)

		JMod.FireSplosion(SelfPos, Dir * Speed, 50, 5, 1, false, self, nil, 15)

		---
		timer.Simple(0, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end

	function ENT:AeroDragThink()

		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 5 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 1200, self)

				if Tr.Hit then
					self:Detonate()
				end
			end
		else
			self.FreefallTicks = 0
		end

		JMod.AeroDrag(self, self:GetRight(), 2)
		self:NextThink(CurTime() + .1)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/props_phx/ww2bomb.mdl")
		self.Mdl:SetSubMaterial(0, "models/entities/mat_jack_firebomb")
		self.Mdl:SetModelScale(1, 0)
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
		self.Mdl:SetRenderOrigin(Pos + Ang:Right() * 6 + Ang:Forward() * 17)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end

	--
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

	language.Add("ent_jack_gmod_ezincendiarybomb", "EZ Incendiary Bomb")
end
