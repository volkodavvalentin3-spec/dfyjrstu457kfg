-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Chlorine Gas"
ENT.Author = "Jackarunda, Freaking Fission"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.ThinkRate = 2
ENT.AffectRange = 300
ENT.MaxLife = 100
ENT.MaxVel = 200

if SERVER then
	function ENT:CustomInit()
		local Time = CurTime()
		self.NextDmg = Time + 2.5
		self.CurVel = self.CurVel or VectorRand() * 50
		self.AirResistance = 1
	end

	function ENT:DamageObj(obj)
		local Time = CurTime()
		if obj:IsPlayer() then
			local faceProt, skinProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)

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

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos, Time = self:GetPos(), CurTime()
		local RandDir = VectorRand(-6, 6)
		RandDir.z = RandDir.z * .5
		local Force = RandDir + (JMod.Wind * 50) + Vector(0, 0, -8)

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
			if obj:IsPlayer() then
				if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
					if obj.EZgasParticle and not(obj.EZvirusParticle) then
						-- repel in accordance with Ideal Gas Law
						local Vec = (obj:GetPos() - SelfPos):GetNormalized()
						Force = Force - Vec * .5
					elseif self.NextDmg < Time and self:ShouldDamage(obj) then
						self:DamageObj(obj)
					end
				end
			end
		end

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
			local distanceBetween = SelfPos:DistToSqr(obj:GetPos())

			if obj != self and obj:GetClass() == self:GetClass() then
				if distanceBetween < 175^2 then
					local Vec = (obj:GetPos()-SelfPos):GetNormalized()
					Force= Force - Vec * 32
				end
			end

		end
	
		-- apply acceleration
		self.CurVel = self.CurVel + Force / 0.5

		-- apply air resistance
		self.CurVel = self.CurVel / 1.5

		-- apply max velocity
		self.CurVel = self.CurVel:GetNormalized() * math.min(self.CurVel:Length(), self.MaxVel)

		-- observe current velocity
		local NewPos = SelfPos + self.CurVel 

		-- make sure we're not gonna hit something. If so, bounce
		local MoveTrace = util.TraceLine({
			start = SelfPos,
			endpos = NewPos,
			filter = { self, self.Canister },
			mask = MASK_SHOT
		})
		if not MoveTrace.Hit then
			-- move unobstructed
			self:SetPos(NewPos + MoveTrace.HitNormal * 1)
		else
			-- bounce in accordance with Ideal Gas Law
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 10)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length() * .8
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
			self.CurVel = -(CurVelAng:Forward() * Speed)
		end
	end

elseif CLIENT then
	local Mat = Material("effects/smoke_b")
	local DebugMat = Material("sprites/mat_jack_jackconfetti")

	function ENT:Initialize()
		self.Col = Color(math.random(225,235),255,math.random(80,90))
		--self.Visible = true
		self.Show = true
		self.siz = 0.01
		self.RenderPos = self:GetPos()
		self.Opacity = 1

		self.DieTime = CurTime() + self:GetNW2Float( 'lifetime' )
		self.Birth = CurTime() 
	
		self.Diffuse = 3

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		
		self:SetModelScale(2)
	end

	--[[function ENT:Think()
		local Time = CurTime()

		if self.TimeDiffuse == nil or Time >= self.TimeDiffuse then
			for k,gas in ipairs(ents.FindInSphere(self:GetPos(), 700)) do
				if gas != self and gas:GetClass() == self:GetClass() then
					local distanceBetween = self:GetPos():DistToSqr(gas:GetPos())

					if distanceBetween >= 700^2 then
						self.Diffuse = 1
					else
						self.Diffuse = 3
					end
				end
				
				self.TimeDiffuse = Time + 1
			end
		end
	end]]

	function ENT:DrawTranslucent()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 50, 50, Color(136, 214, 71, 200))
		end

		local Time = CurTime()

		local OpacityTarget

		if self.DieTime == nil or self.DieTime - 2 > Time then
			OpacityTarget = 44 * self.Diffuse
		else
			OpacityTarget = 0 
		end

		local SizeTarget = 500

		self.siz = math.Round( Lerp(FrameTime() * 0.5, self.siz, SizeTarget), 0)

		self.Opacity = math.Round(Lerp(FrameTime() * 3, self.Opacity, OpacityTarget), 0)
		
		--[[if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end
		self.Show = self.Visible]]

		if self.Opacity > 0 then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(self.RenderPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, self.Opacity))
			self.RenderPos = LerpVector(FrameTime() / 10, self.RenderPos, SelfPos)
			--self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
