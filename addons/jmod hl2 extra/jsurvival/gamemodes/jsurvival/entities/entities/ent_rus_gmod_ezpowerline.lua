-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Power Line"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZpowerBank = true
ENT.EZpowerLine = true
ENT.Model = "models/props_c17/utilitypole03a.mdl"
ENT.Mass = 150
ENT.MaxConnectionRange = 1000
ENT.EZpowerSocket = Vector(0,0,200)
--
ENT.StaticPerfSpecs={ 
	MaxElectricity = 1000,
	MaxDurability = 100,
	Armor = 2.5
}

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:CustomInit()
		self.NextUseTime = 0
		self.PowerLineConnections = {}
		self.EZupgradable = false
		self.EZcolorable = false
		self.PowerFlow = 0

		self:SetModelScale(0.5)

		timer.Simple(1, function()
			if IsValid(self) and IsValid(self:GetPhysicsObject()) then
				self:GetPhysicsObject():EnableMotion(false)
			end
		end)
		
	end

	function ENT:Use(activator)
		if self.NextUseTime > CurTime() then return end
		local State = self:GetState()
		local IsPly = (IsValid(activator) and activator:IsPlayer())
		local Alt = IsPly and activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)

		if State == JMod.EZ_STATE_BROKEN then
			JMod.Hint(activator, "destroyed", self)
		end
		
		if Alt then
			self:ModConnections(activator)
		else
			if State == JMod.EZ_STATE_OFF then
				self:TurnOn(activator)
			elseif State == JMod.EZ_STATE_ON then
				self:TurnOff(activator)
			end
		end
	end

	function ENT:TurnOn(dude)
		if self:GetState() ~= JMod.EZ_STATE_OFF then return end
		self:SetState(JMod.EZ_STATE_ON)
		self:EmitSound("snd_jack_displayson.ogg")
		if IsValid(dude) then
			self.EZstayOn = true
		end
	end

	function ENT:TurnOff(dude)
		if self:GetState() ~= JMod.EZ_STATE_ON then return end
		self:SetState(JMod.EZ_STATE_OFF)
		self:EmitSound("snd_jack_displaysoff.ogg")
		if IsValid(dude) then
			self.EZstayOn = nil
		end
	end

	function ENT:DisconnectAll()
		JMod.RemoveResourceConnection(self)
	end

	-- TODO: Figure out some logic inconsitancies with auto-turn on/off
	function ENT:Think()
		local Time, State = CurTime(), self:GetState()
		
		if (State == JMod.EZ_STATE_ON) and table.Count(constraint.FindConstraints(self, "JModResourceCable")) > 0 then
			self:DistributePower()
		end

		self:NextThink(Time + 1)
		return true
	end

	function ENT:DistributePower()
		for entID, cable in pairs(constraint.FindConstraints(self, "JModResourceCable")) do
			local SelfPower = self:GetElectricity()

			local Cable = cable
			local Ent = cable.Ent1 ~= self and cable.Ent1 or cable.Ent2

			if --[[not IsValid(Ent) or not]] IsValid(Cable) then
				JMod.RemoveResourceConnection(self, entID)
				self:SetElectricity(0)
			elseif Ent.EZpowerProducer then
				if SelfPower <= (self.MaxElectricity * .5) then
					Ent:TurnOn(nil, true)
				end
			elseif (SelfPower >= 1) and Ent.EZpowerBank and not Ent.EZpowerLine then
				local EntPower = Ent:GetElectricity()
				local ChargeDiff = SelfPower - EntPower
				if (ChargeDiff >= 1) then
					local PowerTaken = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, ChargeDiff / 2), SelfPower)
					Ent.NextRefillTime = 0
					self:SetElectricity(SelfPower - PowerTaken)
				end
			elseif (SelfPower >= 1) and Ent.EZpowerLine then
				local EntPower = Ent:GetElectricity()
				local ChargeDiff = SelfPower - EntPower
				if (ChargeDiff >= 2) then

					if Ent.Produced then
						self.Produced = true
						self:SetElectricity(EntPower)

						Ent.Produced = false
					else
						local PowerTaken = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, ChargeDiff), SelfPower)
						Ent.NextRefillTime = 0
						self:SetElectricity(EntPower + PowerTaken)
					end
				end
			elseif Ent.IsJackyEZcrate and (Ent.GetResourceType and ((Ent:GetResourceType() == JMod.EZ_RESOURCE_TYPES.POWER) or (Ent:GetResourceType() == "generic"))) then
				local EntPower = Ent:GetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER) or 0
				if SelfPower > (self.MaxElectricity * .9) then
					local PowerGiven = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, SelfPower - (self.MaxElectricity * .9)), SelfPower)
					Ent.NextRefillTime = 0
					self:SetElectricity(SelfPower - PowerGiven)
					self.Produced = true
				elseif SelfPower <= (self.MaxElectricity * .5) and (EntPower >= 1) then
					local PowerTaken = self:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, math.min(EntPower, self.MaxElectricity))
					Ent:SetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER, EntPower - PowerTaken)
					self.Produced = true
				end
			elseif (SelfPower >= 1) and not(Ent.IsJackyEZcrate) and Ent.EZconsumes and table.HasValue(Ent.EZconsumes, JMod.EZ_RESOURCE_TYPES.POWER) then
				local EntPower = (Ent.GetEZsupplies and Ent:GetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER)) or (Ent.GetElectricity and Ent:GetElectricity()) or Ent.Electricity or 0
				local MaxElec = Ent.MaxElectricity or Ent.MaxResource or 100
				if (MaxElec - EntPower) > MaxElec * .1 then
					local PowerTaken = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, SelfPower), SelfPower)
					Ent.NextRefillTime = 0
					self:SetElectricity(SelfPower - PowerTaken)
					self.Produced = true
				end
				if (EntPower >= 1) and Ent.EZstayOn and Ent:GetState() == JMod.EZ_STATE_OFF then
					Ent:TurnOn()
				end
			elseif SelfPower >= 1 then
				JMod.RemoveResourceConnection(self, entID)
			end
		end
		self.PowerFlow = self:GetElectricity()
	end

	function ENT:ProduceResource(activator)

	end

	function ENT:OnRemove()
		if IsValid(self.EZconnectorPlug) then SafeRemoveEntity(self.EZconnectorPlug) end
	end
elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

	local glowMaterial = Material("sprites/glow04_noz")

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		---
		local BasePos = self:LocalToWorld(self:OBBCenter())
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 12000000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		--if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(State == STATE_BROKEN)then DetailDraw = false end -- look incomplete to indicate damage, save on gpu comp too
		---
		self:DrawModel()
		---

		if State == JMod.EZ_STATE_ON then
        	render.SetMaterial(glowMaterial)
			render.DrawSprite(SelfPos + Up * 235, 50, 50, Color(0, 255, 0))
		end

		if DetailDraw then
			if Closeness < 20000 and State == JMod.EZ_STATE_ON then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)

				local DisplayAng2 = SelfAng:GetCopy()
				DisplayAng2:RotateAroundAxis(DisplayAng2:Right(), 90)
				DisplayAng2:RotateAroundAxis(DisplayAng2:Up(), -90)
				local Opacity = math.random(50, 150)
				local Elec = self:GetElectricity()
				local R, G, B = JMod.GoodBadColor(Elec / 1000)

				cam.Start3D2D(SelfPos + Forward * 8 + Up * 200, DisplayAng, .25)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(Elec)) .. "/" .. tostring(math.Round(self.MaxElectricity)), "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

				cam.Start3D2D(SelfPos - Forward * 8 + Up * 200, DisplayAng2, .25)
				draw.SimpleTextOutlined("POWER", "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(Elec)) .. "/" .. tostring(math.Round(self.MaxElectricity)), "JMod-Display", 0, 30, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
		language.Add("ent_jack_gmod_ezpowerbank", "EZ Power Bank")
	end
end