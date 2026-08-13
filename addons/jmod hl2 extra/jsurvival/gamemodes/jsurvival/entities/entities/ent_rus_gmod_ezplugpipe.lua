-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ plugpipe"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = true
--- func_breakable
ENT.JModPreferredCarryAngles = Angle(180, 0, 0)
ENT.Model = "models/props_lab/tpplug.mdl"

local STATE_BROKEN, STATE_UNHOOKED, STATE_HOOKED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end

		---
		self:SetState(STATE_UNHOOKED)
		self.NextStick = self.NextStick or CurTime() + 0.5
	end

	function ENT:PhysicsCollide(data, physobj)
		local Time = CurTime()
		if Time > self.NextStick and data.DeltaTime > 0.2 and data.Speed > 50 then

			self:EmitSound("snd_jack_claythunk.ogg", 55, math.random(80, 120))

			if self:IsPlayerHolding() then

				local Ent = data.HitEntity

				if not Ent.IsJackyEZcrate and Ent.IsJackyEZmachine and not Ent.EZpowerProducer and Ent:GetState() == JMod.EZ_STATE_BROKEN then return end

				if IsValid(Ent) and (Ent.EZconsumes or Ent.IsJackyEZcrate) and Ent ~= self.EZconnector then
					timer.Simple(0, function()
						local ConnectionRange = self.EZconnector.MaxConnectionRange or 1000
						local PlayerHolding = nil
						local NearbyPlayers = ents.FindInSphere(self:GetPos(), 100)

						for i = 1, #NearbyPlayers do
							local ply = NearbyPlayers[i]
							if ply:IsPlayer() then--and (JMod.GetPlayerHeldEntity(ply) == self) then
								PlayerHolding = ply
							end
						end

						if IsValid(PlayerHolding) and PlayerHolding:KeyDown(JMod.Config.General.AltFunctionKey) then
							local PluginPos = Ent:OBBCenter()
							local DistanceBetween = (self.EZconnector:GetPos() - Ent:LocalToWorld(PluginPos)):Length()
							ConnectionRange = math.min(ConnectionRange, DistanceBetween + 10)
						end

						if not Ent.EZPipeConnections then
							Ent.EZPipeConnections = {}
						end

						if not Ent.IN then
							Ent.IN = {}
						end

						------PLUG----
						if self.EZconnector.OUT[Ent] then return end
						if self.EZconnector.IN[Ent] then return end
						if table.Count(self.EZconnector.OUT) >= 2 then return end

						cable = constraint.Rope(self.EZconnector, Ent, 0, 0, Vector(0, 0, 0), Vector(0,0,0), self.EZconnector.MaxConnectionRange or 1000, 10, 500, 20, "cable/cable2")

						self.EZconnector.OUT[Ent] = true
						Ent.IN[self.EZconnector] = true

						cable.IN = self.EZconnector
						cable.OUT = Ent

						if Ent:GetClass() == "ent_rus_jsmod_pipe" or Ent:GetClass() == "ent_rus_sorter" then
							Ent:SetColor(self.EZconnector:GetColor())
						end

						Ent.EZPipeConnections[self.EZconnector] = cable
						self.EZconnector.EZPipeConnections[Ent] = cable

						cable:CallOnRemove( "RemoveCable", function( ent ) 
							local pipe1 = ent.IN 
							local pipe2 = ent.OUT
							pipe1:EmitSound("physics/metal/metal_barrel_impact_hard1.wav", 65, math.random(80, 120))
							pipe2:EmitSound("physics/metal/metal_barrel_impact_hard1.wav", 65, math.random(80, 120))

							pipe1.OUT[pipe2] = nil
							pipe2.IN[pipe1] = nil
						end)

						if cable then SafeRemoveEntity(self) end
					end)
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if not(self:GetState() == STATE_BROKEN) and JMod.LinCh(Dmg, 30, 100) then
			sound.Play("Metal_Box.Break", self:GetPos())
			self:SetState(STATE_BROKEN)
			SafeRemoveEntityDelayed(self, 2)
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local ply = activator or activatorAgain
		if not IsValid(ply) then return end
		JMod.SetEZowner(self, ply)
			
		if self:IsPlayerHolding() then return end

		ply:PickupObject( self )

	end

	function ENT:Think()
		if not(IsValid(self.Rope)) then SafeRemoveEntity(self) end
	end

	function ENT:OnRemove()
	end

elseif CLIENT then
	function ENT:Initialize()
	end

	--
	--local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezhook", "EZ Hook")
end
