-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZ Smoke Grenade"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(-90, 90, 0)
ENT.Model = "models/props_ww_items/grenade_smoke.mdl"
--ENT.Material = "models/mats_jack_nades/smokescreen"
ENT.SpoonScale = 1
ENT.SpoonModel = "models/props_ww_items/pin_smoke.mdl"
ENT.PinBodygroup = {1, 1}
ENT.DetDelay = 2
ENT.Mass = 10

if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		self.FuelLeft = 100
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 70, 150)
	end

	function ENT:CustomThink(State, Time)
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
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezsmokenade", "EZ Smokescreen Grenade")
end
