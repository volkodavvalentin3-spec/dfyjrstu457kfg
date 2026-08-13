-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZ Flare"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(-90, 90, 0)
ENT.Model = "models/props_ww_items/grenade_signal.mdl"
--ENT.Material = "models/mats_jack_nades/smokescreen"
ENT.SpoonScale = 1
ENT.SpoonModel = "models/props_ww_items/pin_signal.mdl"
--ENT.PinBodygroup = {1, 1}
ENT.DetDelay = 0.7
ENT.HardThrowStr = 100
ENT.Mass = 10
ENT.PreCol = 0
ENT.ShiftCooldown = CurTime()

local colred = Color(200,0,0)
local colgreen = Color(0,200,0)
local colblue = Color(0,0,200)
if SERVER then

	function ENT:CustomInit()
		self:SetKeyValue("fademindist", "1536") 
		self:SetKeyValue("fademaxdist", "1792") 
		self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetColor(colred)	
	end

	function ENT:ShiftAltUse(ply, onOff)
		if not onOff then return end

		self.PreCol = self.PreCol + 1

		if self.PreCol > 2 then self.PreCol = 0 end

		if self.PreCol == 0 then
			self:SetColor(colred)
		elseif self.PreCol == 1 then
			self:SetColor(colgreen)
		elseif self.PreCol == 2 then
			self:SetColor(colblue)
		end
	end

	function ENT:OnTakeDamage( dmginfo )
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetInflictor():GetClass() == "ent_jack_gmod_ezdetpack" then
			self:Detonate()
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
	
		self:SetBodygroup(1,1)

		local Flare = ents.Create("ent_jack_gmod_ezflareprojectile")
		Flare:SetPos(self:GetPos() + Vector(0, 0, 15))
		Flare:Spawn()
		Flare:Activate()
		Flare:SetColor(self:GetColor())
		Flare.ParticleColor = self.PreCol
		Flare:GetPhysicsObject():SetVelocity(Vector(0, 0, 2700) + VectorRand() * math.random(0, 100))
		self:EmitSound("snds_jack_gmod/flaregun_fire.ogg", 75, math.random(90, 110))

		self:EmitSound("snd_jack_fragsplodeclose.ogg", 70, 150)

		EmitFarSound(self:GetPos(), 32, 2000, 3000, 2000, 0)

		SafeRemoveEntityDelayed(self, 10)
	end

	--[[function ENT:CustomThink(State, Time)
		if self.Exploded then
			local Foof = EffectData()
			Foof:SetOrigin(self:GetPos())
			Foof:SetNormal(-self:GetUp())
			Foof:SetScale(self.FuelLeft / 100)
			Foof:SetStart(self:GetPhysicsObject():GetVelocity())
			util.Effect("eff_jack_gmod_ezsmokescreen", Foof, true, true)
			self:EmitSound("snd_jack_sss.wav", 55, 80)
			self.FuelLeft = self.FuelLeft - .5

			if self.FuelLeft <= 0 then
				SafeRemoveEntityDelayed(self, 1)
			end
		end
	end]]
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezsmokenade", "EZ Smokescreen Grenade")
end
