AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Power Line new"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = ""
ENT.Spawnable = true
ENT.AdminSpawnable = true
--
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZNewPowerLine = true
ENT.Model = "models/props_c17/utilitypole03a.mdl"
ENT.Mass = 150
ENT.MaxConnectionRange = 1000
ENT.EZpowerSocket = Vector(0,0,200)
--
ENT.StaticPerfSpecs={ 
	MaxElectricity = 0, // or 1000, idk
	MaxDurability = 100,
	Armor = 2.5
}

JMOD_PowerNets = JMOD_PowerNets or {}

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
		self.EZconnections = {}
		self.PowerLineConnections = {}
		self.EZupgradable = false
		self.EZcolorable = false
		self.PowerFlow = 0

		self:SetModelScale(0.5)

		timer.Simple(1, function()
		
			--self:GetPhysicsObject():EnableMotion(false)

			local tr = util.TraceLine( {
				start = self:GetPos(),
				endpos = self:GetPos() + Vector(0,0,-5),
				filter = self
			} )

			constraint.Weld( self, IsValid(tr.Entity) and tr.Entity or game.GetWorld(), 0, 0, 0, false, true )
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
		for k, v in pairs(self.EZconnections) do
			JMod.RemoveConnection(self, k) 
		end 
	end

	function ENT:TryLoadResource(typ, amnt)
		if !self.PowerNetID then return 0 end

		local taken = JMOD_PowerNet:DistributePower(self.PowerNetID , self, amnt)

		return taken
	end 
 

	function ENT:OnRemove()
		if IsValid(self.EZconnectorPlug) then SafeRemoveEntity(self.EZconnectorPlug) end
		//if self.PowerNetID != nil then
		//	JMOD_PowerNet:RemoveFrom()
		//end
	end

	function ENT:Think()
		if self.PowerNetID then
			debugoverlay.Text( self:GetPos()+Vector(0,0,100), tostring(self).."\nNET: ".. self.PowerNetID, 1, true )
		end
		self:NextThink(CurTime()+1)
		return true
	end

	local function getAllConnectedEnts(parent)
		if !IsValid(parent) then return {} end
		local arr = {}
		local child
		for _, cable in pairs(constraint.FindConstraints(parent, "JModResourceCable")) do
			child = Either(cable.Ent1 == parent, cable.Ent2, cable.Ent1)
			arr[child] = true
		end
		return arr
	end

	function ENT:OnBreak()
		if self.PowerNetID then
			JMOD_PowerNet:RemoveFrom(self.PowerNetID, nil, self)
		end
	end
elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

end