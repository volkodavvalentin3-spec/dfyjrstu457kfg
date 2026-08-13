AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Spawn Base"
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Author = "LANCOM"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true

ENT.EZrespawnPoint = true

ENT.EZupgradable = false

ENT.Model = "models/hunter/blocks/cube2x2x2.mdl"

ENT.Mass = 500

ENT.HurtCooldown = 0

ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS, 
	JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES,
}

ENT.StaticPerfSpecs = { 
	MaxSupplies = 2000,
	MaxDurability = 200,
	Armor = 20
}

local poses = {
	Vector(-100, 0, 0),
	Vector(100, 0, 0),
	Vector(0, 100, 0),
	Vector(0, -100, 0)
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("String", 0, "BaseTitle")
	self:NetworkVar("Int",1,"Supplies")
	self:NetworkVar("Bool",2,"Capital")
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

function GetSpawnPositions(base)
	local traced_poses = {}

	local basepos = base:IsPlayer() and base:GetShootPos() or base:GetPos()

	for i = 1, 4 do
		local pos = base:IsPlayer() and base:LocalToWorld(poses[i] - Vector(0, 0, 0)) or base:LocalToWorld(poses[i] - Vector(0, 0, 50))
		local pos_up = base:GetPos() + Vector(0, 0, 0)
	
		local tr = util.TraceHull({
			start = pos_up,
			endpos = pos,
			mins = Vector( -16, -16, 0 ),
			maxs = Vector( 16, 16, 71 ),
			filter = function(ent)
				if ent == base then
					return false
				end

				if ent:GetClass() == "prop_ragdoll" then
					return false 
				end 
				
				if scripted_ents.IsBasedOn( ent:GetClass(), "ent_jack_gmod_ezresource" ) then 
					--print(ent:GetClass()) 
					return false 
				end
			end
		})

		local checkpos = tr.HitPos + Vector(0, 0, 71 * 0.5)

		if IsInside(checkpos) then continue end

		local tr2 = util.TraceLine( {
			start = base:GetPos(),
			endpos = checkpos,
			filter = base
		} )

		if tr2.Hit then print(tr2.Entity) continue end

		traced_poses[#traced_poses + 1] = tr.HitPos + Vector(0,0,5)
	end

	return traced_poses
end

if SERVER then
	util.AddNetworkString("lanrp.ChooseSpawnBase")

	net.Receive("lanrp.ChooseSpawnBase", function(_, ply)
		local ent = net.ReadEntity()
		local LaseBase = net.ReadEntity()
	
		if IsValid(ent) then
			local PlyOldPos = ply:LocalToWorld(ply:OBBCenter())

			local r = BaseSpawnPlayer(ply, ent, false)
			if not r then BetterChatPrint(ply, "Точка не дееспособна!", clr_red) return end
			
			timer.Simple(0.1, function()
				if IsValid(LaseBase) then
					LaseBase:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(40, 70))
					JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES, PlyOldPos, LaseBase:LocalToWorld(LaseBase:OBBCenter()), 20 / 500, 1, 1)
				end
			end)
		else
			BetterChatPrint(ply, "Точка не дееспособна!", clr_red)
		end
	end)

	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal-- * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		--JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		ent:SetUseType( SIMPLE_USE )

		return ent
	end

	function ENT:CustomInit()
		self:SetMaterial("phoenix_storms/dome")

		--self:SetModelScale(0.8)

		self:SetBaseTitle("none")

		self:SetSupplies(0)

		self.squad = -1

		local tr = util.TraceHull( {
			start = self:GetPos() + Vector(0, 0, 100),
			endpos = self:GetPos() - Vector(0, 0, 1000),
			filter = self,
			mins = self:OBBMins(),
			maxs = self:OBBMaxs(),
		} )

		self:SetPos(tr.HitPos)

		timer.Simple(1, function()
			self:GetPhysicsObject():EnableMotion(false)
		end)
	end

	function ENT:Use(activator)
		local ALT = activator:KeyDown(IN_WALK)
		--print(IsValid(activator) and activator:IsPlayer())
		--print(IsValid(ez_owner) and ez_owner:IsPlayer())
		--print(activator:GetSquadID() == ez_owner:GetSquadID())

		local squad = SquadMenu:GetSquad(activator:GetSquadID())

		--PrintTable(squad.SpawnsBase)

		if ALT then
			if IsValid(activator) and activator:IsPlayer() and ((activator:GetSquadID() == self.squad) or self.squad == -1) and self:GetState() ~= JMod.EZ_STATE_BROKEN then
				net.Start("lanrp.setBaseName")
				net.WriteEntity(self)
				net.Send(activator)
				self.squad = activator:GetSquadID()
			end
		else
			local squad = SquadMenu:GetSquad(activator:GetSquadID())

			local AllSpawns = {}

   			if activator:GetSquadID() != -1 then
   			    AllSpawns = table.Copy(squad.SpawnsBase)

   			    if table.Count(squad.Alliance) > 0 then

   			        for k,v in pairs(squad.Alliance) do
   			            local AllianceSquad = SquadMenu:GetSquad(k)
					
   			            table.Merge(AllSpawns, AllianceSquad.SpawnsBase)
   			        end
   			    end
   			end

			local count = table.Count(AllSpawns)

			if count > 1 then
				net.Start("lanrp.ChooseSpawnBase")
				net.WriteTable(AllSpawns)
				net.WriteEntity(self)
				net.Send(activator)
			end
		end
	end

	function BaseSpawnPlayer(ply, base, dead)
		if base:GetClass() == "ent_rus_spawnbase" then
			local poses = GetSpawnPositions(base)

			if ((base:GetSupplies() < 50) and not base:GetCapital()) or base:GetState() == JMod.EZ_STATE_BROKEN then return false end

			if (#poses <= 0) then return false end
			
			local rand, _ = table.Random(poses)

			ply:SetPos(rand)
		elseif base:GetClass() == "ent_jack_sleepingbag" then
			local pos = base:LocalToWorld(Vector(0, 0, 15))
			local pos_to_check = base:LocalToWorld(Vector(0, 0, 50))

			if IsInside(pos_to_check) then return false end

			ply:SetPos(pos)

			base.SpawnCount = base.SpawnCount + 1

			if base.SpawnCount >= 5 then
				base:Remove()
			end
		elseif base:IsPlayer() then
			local poses = GetSpawnPositions(base)

			if (#poses <= 0) then return false end
			
			local rand, _ = table.Random(poses)

			ply:SetPos(rand)

			base:SetNWInt("RadioManSpawns", base:GetNWInt("RadioManSpawns") - 1)

			if base:GetNWInt("RadioManSpawns") <= 0 then
				local squad = SquadMenu:GetSquad(base:GetSquadID())

				squad.SpawnsBase[base] = nil

				BetterChatPrint(base, "Закончилось подкрепление!", Color(255,255,0))
			end
		end
		

		if dead then

			if squad.Mobilization then
				if squad.Mobilization[ply] and squad.Mobilization[ply] > 0 then
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
				local GrabMask = false

				for k, ent in pairs(ents.FindInSphere(ply:GetPos(), 300)) do

					if GrabVest and GrabHelmet and GrabWeapon and GrabMask then
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

						if ent:GetClass() == "ent_jack_gmod_ezarmor_gasmask" and not GrabMask then
							JMod.EZ_Equip_Armor(ply, ent)
							GrabMask  = true
						end
					end
				end
			end
		end

		if base:GetClass() == "ent_rus_spawnbase" then
			base:SetSupplies(base:GetSupplies() - 50)
		end

		timer.Simple(0.1, function()
			base:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(40, 70))
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES, ply:LocalToWorld(ply:OBBCenter()), base:LocalToWorld(base:OBBCenter()), 20 / 500, 1, 1)
		end)

		if dead then
			local squad = SquadMenu:GetSquad(ply:GetSquadID())
			
			if ply:GetSquadID() == -1 then
        	    ply:SetPlayerColor(Vector(1, 1, 1))
        	else
        	    ply:SetPlayerColor(Vector( squad.r / 255, squad.g / 255, squad.b / 255 ))
        	end
		end

		return true
	end

	function ENT:OnTakeDamage( dmginfo )

		if ( not self.m_bApplyingDamage ) then
			self.m_bApplyingDamage = true
			self:TakeDamageInfo( dmginfo )
			self.m_bApplyingDamage = false
		end

		if dmginfo:IsBulletDamage() then
			dmginfo:ScaleDamage(0)
		end

		if dmginfo:IsDamageType(DMG_CRUSH) then
			dmginfo:ScaleDamage(0)
		end

		if self:GetCapital() then
			dmginfo:ScaleDamage(0.7)
		end

		if self.HurtCooldown <= CurTime() then
			local owner = JMod.GetEZowner(self)

			if not IsValid(owner) then return end
			
			local squad = SquadMenu:GetSquad(owner:GetSquadID())

			if squad != nil then
				for k,v in pairs(squad.membersById) do
					local ply = player.GetBySteamID(k)

					ply:LanRPChatPrint(Color(210,0,0), 'Ваша точка "', color_white, self:GetBaseTitle(), Color(210,0,0), '" под угрозой!')

					ply:PlayLocalSound("ambient/alarms/klaxon1.wav")

					timer.Simple(1, function()
						ply:PlayLocalSound("ambient/alarms/klaxon1.wav")

						timer.Simple(1, function()
							ply:PlayLocalSound("ambient/alarms/klaxon1.wav")
						end)

					end) 
				end
			end

			self.HurtCooldown = CurTime() + 60
		end

		------------------------------

		if not(IsValid(self))then return end
		self:TakePhysicsDamage(dmginfo)
		--
		local DmgMult = self:DetermineDamageMultiplier(dmginfo)
		if(DmgMult <= .01)then return end
		local Damage = dmginfo:GetDamage() * DmgMult
		--jprint(Damage)
		self.Durability = self.Durability - math.Round(Damage, 2)
		self:SetNW2Float("EZdurability", self.Durability)

		if(self.Durability <= 0)then self:Break(dmginfo) end
		if(self.Durability <= (self.MaxDurability * -2))then self:Destroy(dmginfo) end
		----------------------------------------------------------------------
	end

	function ENT:OnBreak()
		local owner = JMod.GetEZowner(self)
		local squad = SquadMenu:GetSquad(owner:GetSquadID())

		for k,v in pairs(squad.membersById) do
			local ply = player.GetBySteamID(k)

			ply:LanRPChatPrint(Color(122,0,0), 'Ваша точка "', Color(216,216,216), self:GetBaseTitle(), Color(122,0,0), '" УНИЧТОЖЕНА!')
			ply:PlayLocalSound("hoi4/Low_health_energy_01.wav")
		end

		if self:GetBaseTitle() ~= "none" and owner:IsPlayer() then
			if table.Count(squad.SquadsInWar) > 0 then
				squad.SpawnsBase[self] = nil
				squad:AddHealth(-5)
			end
		end

		if self:GetCapital() then
			if table.Count(squad.SquadsInWar) > 0 then
				squad:AddHealth(-200)
			end
		end

		JMod.SetEZowner(self, Entity(0))
		self:SetBaseTitle("none")
		self:SetColor(Color(255,255,255))
		self.squad = nil
	end

	function ENT:OnRemove()
		--local squadid = JMod.GetEZowner(self)
		local squad = SquadMenu:GetSquad(self.squad)

		if squad then
			if self:GetBaseTitle() ~= "none" then
				squad.SpawnsBase[self] = nil
			end
		end
	end

	net.Receive("lanrp.setBaseName", function(_, ply)
    	local ent = net.ReadEntity()
    	local text = net.ReadString()

    	if ply:GetSquadID() == -1 then ply:ChatPrint("У вас нету сквада") return end

    	local squad = SquadMenu:GetSquad(ply:GetSquadID())

    	ent:SetBaseTitle(text)
    	squad.SpawnsBase[ent] = text

    	ent:SetColor(Color(squad.r, squad.g, squad.b))

		for k,v in pairs(squad.SpawnsBase) do
			if not IsValid(k) then
				squad.SpawnsBase[k] = nil
			end
		end

		ent.squad = ply:GetSquadID()

		if ent:GetClass() == "ent_jack_sleepingbag" then return end 

    	if table.Count(squad.SpawnsBase) == 1 then
    	    ent:SetCapital(true)
		else
			local HasCapital = false

			for k,v in pairs(squad.SpawnsBase) do
				if k:GetCapital() then
					HasCapital = true
				end
			end

			if HasCapital then
				ent:SetCapital(false)
			else
				ent:SetCapital(true)
			end
			
    	end

    	JMod.SetEZowner(ent, ply)
	end)
else
	surface.CreateFont("spawnbase.font", {
		font = "Roboto",
		size = 32,
		extended = true
	})

	function ENT:CustomInit()
		self.Mdl = ClientsideModel("models/props_c17/substation_stripebox01a.mdl")
		self.Mdl:SetModelScale(1, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.Mdl:SetMaterial("phoenix_storms/dome")
	end

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
		if IsValid(self.Mdl) then
			--self:DrawModel()
			local Pos, Ang = self:GetPos(), self:GetAngles()
			Ang:RotateAroundAxis(Ang:Up(), 90)
			--self:DrawModel()
			self.Mdl:SetRenderOrigin(Pos + Ang:Up() * 45)
			self.Mdl:SetRenderAngles(Ang)

			self.Mdl:DrawModel()
		end
		---

		if DetailDraw then
			if Closeness < 20000 and self:GetState() ~= JMod.EZ_STATE_BROKEN then
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

				cam.Start3D2D(SelfPos + Forward * 42 + Up * 38, DisplayAng, .25)
				draw.SimpleTextOutlined(title, "JMod-Display", 0, 0, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()

				cam.Start3D2D(SelfPos + Forward * 42 + Up * 26, DisplayAng, .18)
				if self:GetCapital() then
					draw.SimpleTextOutlined("СТОЛИЦА", "JMod-Display", 0, 80, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				else
					draw.SimpleTextOutlined("МЕДИКАМЕНТОВ: " .. self:GetSupplies() .. "/" .. self.MaxSupplies, "JMod-Display", 0, 80, Color(200, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				end
				cam.End3D2D()
			end
		end
		
		net.Receive( "lanrp.ChooseSpawnBase", function( len, ply )
			local SpawnBase = net.ReadTable()
			local UseBase = net.ReadEntity()

			if SpawnBase == nil then return end

        	local MainFrame = vgui.Create("DFrame")
        	MainFrame:SetTitle("Дислокация")
        	MainFrame:SetSize(200,200)
        	MainFrame:Center()
        	MainFrame:MakePopup()
        	MainFrame:SetDraggable(false)
        	MainFrame:ShowCloseButton(true)

        	local SpanwsScrollPanel = vgui.Create("DScrollPanel", MainFrame)
        	SpanwsScrollPanel:Dock(FILL)

        	for k, v in SortedPairsByValue(SpawnBase) do

				if not IsValid(k) then
					SpawnBase[k] = nil
					continue 
				end
				
				if k == LocalPlayer() then continue end

        	    local SpawnButton = SpanwsScrollPanel:Add("DButton")

        	    if k:GetClass() == "ent_jack_sleepingbag" then
					SpawnButton:SetText(v .. " | КРОВАТЬ")
				elseif k:IsPlayer() then
					SpawnButton:SetText(v .. " | " .. k:GetNWInt("RadioManSpawns"))
					SpawnButton:SetZPos(-1)
				elseif k:GetCapital() then
					SpawnButton:SetText(v .. " | СТОЛИЦА")
					SpawnButton:SetZPos(-1)
        	    else
        	        SpawnButton:SetText(v .. " | " .. k:GetSupplies())
        	    end

        	    SpawnButton:Dock(TOP)
        	    SpawnButton:DockMargin(0, 0, 0, 5)

        	    function SpawnButton:DoClick()
        	        
					if k ~= UseBase then
						net.Start("lanrp.ChooseSpawnBase")
            			net.WriteEntity(k)
						net.WriteEntity(UseBase)
            			net.SendToServer()
					end
				
        	        MainFrame:Remove()
        	    end
        	end

		end)


		--[[local ply = LocalPlayer()

		local r_ang = RenderAngles()

		local normalized = (ply:EyePos() - self:GetPos()):GetNormalized()

		local poses_ = GetSpawnPositions(self)

		for i = 1, #poses_ do
			local pos = poses_[i]
			local checkpos = pos + Vector(0, 0, 71 * 0.5)

			--debugoverlay.Sphere(checkpos, 2, 0, color_white)
			render.DrawWireframeSphere( checkpos, 2, 10, 10, color_white, true )

			render.DrawWireframeBox( pos, Angle(0,0,0), Vector( -16, -16, 0 ), Vector( 16, 16, 71 ), Color( 255, 0, 0), false )
			render.DrawWireframeBox( checkpos, Angle(0,0,0),Vector( -20, -20, -20 ), Vector( 20, 20, 20 ), color_white, false )

			local tr2 = util.TraceLine( {
				start = self:OBBCenter(),
				endpos = checkpos,
				filter = self
			} )

			if tr2.Hit then render.DrawLine( self:OBBCenter(), tr2.HitPos, Color( 255, 0, 0 ), true ) end

			--debugoverlay.Box( pos, Vector( -16, -16, 0 ), Vector( 16, 16, 71 ), 0, Color( 255, 0, 0) )
			--debugoverlay.Box( checkpos, Vector( -20, -20, -20 ), Vector( 20, 20, 20 ), 0, color_white)
		end
		local pos = self:LocalToWorld(poses[1])
		local pos_up = self:LocalToWorld(poses[1] + Vector(0, 0, 10))]]
	end
end