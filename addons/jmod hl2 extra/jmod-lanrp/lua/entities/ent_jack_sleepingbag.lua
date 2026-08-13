AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Sleeping Bag"
ENT.Author = "Basipek, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.EZrespawnPoint = true
ENT.Mass = 35
ENT.JModEZstorable = true
ENT.SpawnCount = 0

local STATE_ROLLED, STATE_UNROLLED = 0, 1
local MODEL_ROLLED, MODEL_UNROLLED = "models/jmod/props/sleeping_bag_rolled.mdl","models/jmod/props/sleeping_bag.mdl"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "BaseTitle")
	self:NetworkVar("Int", 0, "State")
end

function ENT:GetCapital()
	return false
end

local function IsInside(pos)
	local tr = util.TraceHull({
		start = pos, endpos = pos,
		maxs = Vector(20, 20, 20), mins = Vector(-20, -20, -20),
		filter = function(ent)
			if ent:GetClass() == "prop_ragdoll" then
				return false 
			end 
				
			if scripted_ents.IsBasedOn( ent:GetClass(), "ent_jack_gmod_ezresource" ) then 
				--print(ent:GetClass()) 
				return false 
			end

			return true
		end
	})

	return tr.Hit
end

if SERVER then
	function ENT:Initialize()
		self:SetState(STATE_ROLLED)
		self:SetModel(MODEL_ROLLED)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
		JMod.SetEZowner(self, nil)

		local phys = self:GetPhysicsObject()

		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(35)
			self:SetColor(Color(100, 100, 100))
		end
		
		self:SetUseType(SIMPLE_USE)

		self:SetBaseTitle("none")
	end
	
	function ENT:RollUp()
		self:SetState(STATE_ROLLED)
		--JMod.SetEZowner(self, nil)

		self:SetModel(MODEL_ROLLED)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)    
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(self.Mass)
		end
		self:SetPos(self:GetPos() + Vector(0, 0, 20))
		
		self:SetColor(Color(100, 100, 100))

		self:SetBaseTitle("none")

		if self.squad then
			local squad = SquadMenu:GetSquad(self.squad)
			squad.SpawnsBase[self] = nil
		end

		self.squad = nil
	end

	function ENT:UnRoll()
		self:SetState(STATE_UNROLLED)
		self:SetModel(MODEL_UNROLLED)
		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)    
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(self.Mass)
		end
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Tr = util.TraceLine({
			start = SelfPos + Vector(0, 0, 50),
			endpos = SelfPos - Vector(0, 0, 100),
			filter = { self, self.EZowner }
		})
		if (Tr.Hit) then
			self:SetPos(Tr.HitPos + Tr.HitNormal)
			local Ang = Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			self:SetAngles(Ang)
		end
		sound.Play("snd_jack_clothunequip.ogg", self:GetPos(), 65, math.random(90, 110))
	end

	function ENT:Use(activator)
		if not activator:IsPlayer() then return end
	
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

		if Alt then
			if self:GetState() == STATE_UNROLLED then
				self:RollUp()
			elseif self:GetState() == STATE_ROLLED then
				self:UnRoll()
			end
		elseif (self:GetState() == STATE_UNROLLED) then
			if not self.squad or self.squad == activator:GetSquadID() then
				local Col = activator:GetPlayerColor()
				self:SetColor(Color(255 * Col.x, 255 * Col.y, 255 * Col.z))

				net.Start("lanrp.setBaseName")
				net.WriteEntity(self)
				net.Send(activator)
			end
		elseif (self:GetState() == STATE_ROLLED) then
			JMod.Hint(activator, "sleeping bag unroll first")
			activator:PickupObject(self)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if (dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT)) and math.random(1, 3) == 2 then
			self:Remove()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.Speed > 50 and data.DeltaTime > 0.2 then
			self:EmitSound("Flesh.ImpactSoft")
		end
	end

	function ENT:SpawnPlayer(ply, dead)
		local squad = SquadMenu:GetSquad(ply:GetSquadID())
		local pos = self:LocalToWorld(Vector(0, 0, 15))
		local pos_to_check = self:LocalToWorld(Vector(0, 0, 50))

		if IsInside(pos_to_check) then return false end

		ply:SetPos(pos)

		if dead then

			if squad.Mobilization then
				if squad.Mobilization[ply] > 0 then
					for k, v in pairs(squad:IsLeader(ply) and SquadStyle["officer"] or SquadStyle[squad.Style].result) do
						
						if type(v) == "function" then v = v() end

						local ent = ents.Create(v)
						ent:Spawn()

						if scripted_ents.IsBasedOn( ent:GetClass(), "ent_jack_gmod_ezarmor" ) then
							if ent:GetClass() == "ent_jack_gmod_ezarmor_gasmask" then
								ent:SetColor(Color(50,50,50))
								JMod.AddToInventory(ply, ent)
								continue 
							end

							JMod.EZ_Equip_Armor(ply, ent, true)
							continue
						end

						if ent:IsWeapon() then
							ply:PickupWeapon(ent)
							continue
						end

						JMod.AddToInventory(ply, ent)
					end
					squad.Mobilization[ply] = squad.Mobilization[ply] - 1
				else
					squad.Mobilization[ply] = nil
				end
			else
				local GrabWeapon = false
				local GrabVest = false
				local GrabHelmet = false

				for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 300)) do

					if GrabVest and GrabHelmet and GrabWeapon then
						break
					end

					if ent:GetClass() == "ent_weapondrop" and not GrabWeapon then
						if weapons.Get(ent:GetWeaponClass()).IsTFAWeapon then
							local weptable = weapons.Get(ent.Class)

							if weptable.Slot == 3 or 2 then 
								ent.forcegrab = true
								ent:Use(ply)

								GrabWeapon = true

								for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
									if ent:GetClass() == "ent_jack_gmod_ezammo" then
										for i = 1, 2 do
											if IsValid(ent) then
												JMod.GiveAmmo(ply, ent)
											end
										end
										break
									elseif ent:GetClass() == "ent_aboot_gmod_ezammocrate" and ent.EZsupplies ~= "munitions" then
										for i = 1, 2 do
											if IsValid(ent) then
												ent:GivePlyAmmo(ply, false)
											end

										end
										break
									end
								end
							end

						end
					end

					if scripted_ents.IsBasedOn( ent:GetClass(), "ent_jack_gmod_ezarmor" ) then
						if ent.Specs.slots.chest and not GrabVest then
							JMod.EZ_Equip_Armor(ply, ent)
							GrabVest = true
						end

						if ent.Specs.slots.head and not GrabHelmet then
							JMod.EZ_Equip_Armor(ply, ent)
							GrabHelmet = true
						end
					end

				end
			end
		end

		self:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(40, 70))

		self.SpawnCount = self.SpawnCount + 1

		if self.SpawnCount >= 5 then
			self:Remove()
		end

		if dead then
			if ply:GetSquadID() == -1 then
        	    ply:SetPlayerColor(Vector(1, 1, 1))
        	else
        	    ply:SetPlayerColor(Vector( squad.r / 255, squad.g / 255, squad.b / 255 ))
        	end
		end
		
		return true
	end

	function ENT:OnRemove()
		if self:GetBaseTitle() ~= "none" and self.squad then
			local squad = SquadMenu:GetSquad(self.squad)

			squad.SpawnsBase[self] = nil
		end
	end
else
	function ENT:Draw()
		self:DrawModel()

		local SelfPos, SelfAng = self:LocalToWorld(Vector(0, -10, -33)), self:LocalToWorldAngles(Angle(-90, 90, 0))
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		---
		local BasePos = self:LocalToWorld(self:OBBCenter())
		local Obscured = util.TraceLine({start = EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 12000000 -- cutoff point is 400 units when the fov is 90 degrees
		---
		--if((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		---

		if DetailDraw and Closeness < 20000 and self:GetState() == STATE_UNROLLED then
			local DisplayAng = SelfAng:GetCopy()
			DisplayAng:RotateAroundAxis(DisplayAng:Right(), -90)
			DisplayAng:RotateAroundAxis(DisplayAng:Up(), 90)

			local DisplayAng2 = SelfAng:GetCopy()
			DisplayAng2:RotateAroundAxis(DisplayAng2:Right(), 90)
			DisplayAng2:RotateAroundAxis(DisplayAng2:Up(), -90)
			local Opacity = math.random(50, 150)
			--local R, G, B = JMod.GoodBadColor(Elec / 1000)

			local title = self:GetBaseTitle()
			title = title == "none" and "Нет названия!" or title

			cam.Start3D2D(SelfPos + Forward * 42 - Up * 6, DisplayAng, .25)
			draw.SimpleTextOutlined(title, "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
			cam.End3D2D()
		end
	end
end