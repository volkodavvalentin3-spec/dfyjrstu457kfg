AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "WeaponDrop"
ENT.Author = "LANCOM"
ENT.Spawnable = false

ENT.JModEZstorable = true

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		timer.Simple(0, function()
			self:GetPhysicsObject():SetMass(5)
			self:GetPhysicsObject():Wake()
		end)
	end

	AccessorFunc(ENT, "Class", "WeaponClass", FORCE_STRING)

	function ENT:Use(ply)
		local wpn_class = self:GetWeaponClass()
		local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)
		
		ply:PickupObject( self )

		if Alt or self.forcegrab then
			
			if ply:GetActiveWeapon().IsTFAWeapon then
				ply:ChatPrint("Вы должны взять руками")
				return 
			end
			
			local WepGetSlot = ents.Create(wpn_class)
			WepGetSlot:Spawn()
			local slot = WepGetSlot:GetSlot()
			WepGetSlot:Remove()

			if not ply:HasWeapon(wpn_class) and ply:IsSlotEmpty(slot) then
				ply:Give(wpn_class)
				ply:SelectWeapon(wpn_class)

				if self.Electricity ~= nil then
					ply:GetActiveWeapon():SetGas(self.Electricity)
				end

				if self.Gas ~= nil then
					ply:GetActiveWeapon():SetGas(self.Gas)
				end

				if self.Clip1 then
					ply:GetActiveWeapon():SetClip1(self.Clip1)
					ply:GetActiveWeapon():SetClip2(self.Clip2)
				end

				if ply:GetActiveWeapon().CustomPickup then
					ply:GetActiveWeapon():CustomPickup(self)
				end

				self:Remove()
			end	
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 100 then
				self:EmitSound("Metal_Box.ImpactHard")
				--self:EmitSound("Canister.ImpactSoft")
			end
		end
	end

	function ENT:OnRemove()

	end
else
	function ENT:Draw()

		self:DrawModel()
		
	end
end