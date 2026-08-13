AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "RusLanConnection"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.PrintName = "EZ pipe"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.MaxConnectionRange = 512

---
ENT.Model = "models/props_c17/FurnitureWashingmachine001a.mdl"
ENT.JModGUIcolorable = true
---

ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS
}

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		JMod.Hint(ply, self.ClassName)
		
		return ent
	end

	function ENT:CustomInit()
		self:SetMaterial("phoenix_storms/dome")
		self.EZPipeConnections = {}
		self.Trans = {}

		self.IN = {}
		self.OUT = {}
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed > 80) and (data.DeltaTime > 0.2) then
			self:EmitSound("Metal_Box.ImpactSoft")
		end
		
		if self:GetState() == JMod.EZ_STATE_BROKEN then return end

		local ent = data.HitEntity
		if not IsValid(ent) then return end

		local Phys = ent:GetPhysicsObject()

		if IsValid(Phys) and table.Count(self.OUT) > 0 and table.Count(self.IN) <= 0 and data.DeltaTime >= 0.1
		and ent.IsJackyEZresource and table.Count(self.IN) >= 0 then
			self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
				
			table.insert(self.Trans, {enttype = ent.EZsupplies, amount = ent:GetResource()})

			ent:Remove()	
		end
	end

	function ENT:Use(ply)
		if self:GetState() == JMod.EZ_STATE_BROKEN then return end

		if not IsValid(self.EZowner) then
			JMod.SetEZowner(ent, ply)
			self.EZowner = ply
			return
		end

		if ply:GetSquadID() == self.EZowner:GetSquadID() then
			if ply:KeyDown(IN_WALK) then

				if table.Count(self.OUT) >= 2 then return end

				if table.Count(self.IN) <= 0 then 
					JMod.SetEZowner(self, ply)
					net.Start("JMod_ColorAndArm")
					net.WriteEntity(self)
					net.Send(ply)
				end

				if IsValid(self.Plugy) then 
					self.Plugy:Remove()
				end

				local Plugy = ents.Create("ent_rus_gmod_ezplugpipe")
				if not IsValid(Plugy) then return end
				Plugy:SetPos(self:GetPos() + Vector(0, 0, 50)) -- Adjust the position as needed
				Plugy:SetAngles(self:GetAngles())
				Plugy:Spawn()
				Plugy:Activate()

				self.Plugy = Plugy
				Plugy.EZconnector = self
				local ropeLength = self.MaxConnectionRange or 1000
				local Rope = constraint.Rope(self, Plugy, 0, 0, Vector(0,0,0), Vector(10,0,0), ropeLength, 0, 1000, 10, "cable/cable2", false)
				Plugy.Rope = Rope

				ply:DropObject()
				ply:PickupObject(Plugy)
			elseif table.Count(self.OUT) >= 1 then 
				for k,v in pairs(self.OUT) do
					self.EZPipeConnections[k]:Remove()
					k.IN[self] = nil
				end

				self.OUT = {}

				self:EmitSound("physics/metal/metal_barrel_impact_hard1.wav", 65, math.random(80, 120))
				return
			elseif IsValid(self.Plugy) then 
				self:EmitSound("physics/metal/metal_barrel_impact_hard1.wav", 65, math.random(80, 120))
				self.Plugy:Remove()
			end
		end
	end

	function ENT:Think()
		local count = table.Count(self.OUT)
		
		if count > 0 then
			for k, v in pairs(self.Trans) do
				local res_count = math.Round(v.amount / count)
				local brick = res_count == v.amount

				for ent, _ in pairs(self.OUT) do

					if ent:GetClass() == "ent_rus_jsmod_pipe" or ent:GetClass() == "ent_rus_sorter" then
						table.insert(ent.Trans, {enttype = v.enttype, amount = res_count})
					else
						--[[local Accepted = ]]ent:TryLoadResource(v.enttype, res_count)

						--[[if Accepted < res_count then
							self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
							self:EmitSound("Metal_Box.ImpactSoft")

							JMod.MachineSpawnResource(self, v.enttype, res_count - Accepted, self:WorldToLocal(self:GetPos() + self:GetUp() * 16 + self:GetForward() * 32), Angle(0, 0, 0), self:GetForward() * 10, false)

							table.remove(self.Trans, k)
						end]]
					end

					if brick then break end
				end

				self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
				self:EmitSound("Metal_Box.ImpactSoft")

				table.remove(self.Trans, k)
				
				break
			end
		else
			for k, v in pairs(self.Trans) do
				self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
				self:EmitSound("Metal_Box.ImpactSoft")

				JMod.MachineSpawnResource(self, v.enttype, v.amount, self:WorldToLocal(self:GetPos() + self:GetUp() * 16 + self:GetForward() * 32), Angle(0, 0, 0), self:GetForward() * 10, false)

				table.remove(self.Trans, k)
				break
			end
		end

		self:NextThink(CurTime() + 2)
		return true
	end

	function ENT:OnRemove()
		for k,v in pairs(self.OUT) do
			if IsValid(self.EZPipeConnections[k]) then
				self.EZPipeConnections[k]:Remove()
			end
			
			if IsValid(k) then
				k.IN[self] = nil
			end
		end

		for k,v in pairs(self.IN) do
			if IsValid(k) then
				k.OUT[self] = nil
			end
		end
	end
end