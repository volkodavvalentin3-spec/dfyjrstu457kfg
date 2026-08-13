AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "ChlorineGas"
ENT.Author = "LANCOM"
ENT.Spawnable = false

ENT.Size = 1
ENT.DamageCooldown = 0
ENT.Life = 60

if SERVER then
	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:SetNoDraw(true)
		self:SetModel("models/Gibs/HGIBS.mdl")

		self.DamageCooldown = CurTime() + 1
	end

	function ENT:Use(ply)
	end

	function ENT:Think()
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetScale(self.Size)
		util.Effect("chlorinegas", Eff)

		if CurTime() < self.DamageCooldown then return end	

		if self.Life > 0 then
			self.Life = self.Life - 1
		elseif self.Life > -2 then
			self:Remove()
		end

		local Range = 512 * self.Size
		local SelfPos = self:GetPos()

		if Range <= 0 then return end

		for key, obj in pairs(ents.FindInSphere(SelfPos, Range)) do
			--Player(133):ChatPrint(tostring(obj))
			--Player(133):ChatPrint(tostring(SelfPos))
			--Player(133):SetPos(SelfPos)
			if not obj:IsPlayer() then continue end

			if self.Life > 0 then
				self:DamageObj(obj)
			end
		end

		self.DamageCooldown = CurTime() + 1
	end

	function ENT:DamageObj(obj)
		local Time = CurTime()
		if obj:IsPlayer() then
			local faceProt, skinProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)

			--print(obj)
			local Dmg, Helf = DamageInfo(), obj:Health()
			Dmg:SetDamageType(DMG_NERVEGAS)
			Dmg:SetDamage(math.random(3, 10) * JMod.Config.Particles.PoisonGasDamage * 1)
			Dmg:SetInflictor(self)
			Dmg:SetAttacker(JMod.GetEZowner(self) or self)
			Dmg:SetDamagePosition(obj:GetPos())
			obj:TakeDamageInfo(Dmg)

			JMod.DepleteArmorChemicalCharge(obj, (faceProt + skinProt) * 4 * .07)

			if faceProt < 1 then
				obj.EZpoison = (obj.EZpoison or 0) + 3
				
				net.Start("JMod_VisionBlur")
				net.WriteFloat(5 * math.Clamp(1 - faceProt, 0, 1))
				net.WriteFloat(2)
				net.WriteBit(false)
				net.Send(obj)
				JMod.Hint(obj, "tear gas")
				JMod.TryCough(obj)
			end
		elseif obj:IsNPC() then
			obj.EZNPCincapacitate = Time + math.Rand(2, 5)
		end

		if math.random(1, 20) == 1 then
			local Dmg = DamageInfo()
			Dmg:SetDamageType(DMG_NERVEGAS)
			Dmg:SetDamage(math.random(1, 4) * JMod.Config.Particles.PoisonGasDamage * 1.2)
			Dmg:SetInflictor(self)
			Dmg:SetAttacker(JMod.GetEZowner(self))
			Dmg:SetDamagePosition(obj:GetPos())
			obj:TakeDamageInfo(Dmg)
		end
	end

	function ENT:OnRemove()

	end
end