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

		self.DamageCooldown = CurTime() + 1
	end

	function ENT:OnRemove()

	end
end