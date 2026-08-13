-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Virus Particle"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZvirusParticle = true
ENT.AffectRange = 300
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self.LifeTime = math.random(50, 100) * JMod.Config.Particles.PoisonGasLingerTime
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + 0.5
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self.CurVel = self.CurVel or VectorRand() * 10
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos = self:GetPos()
		local Force = (VectorRand() * 40) + (JMod.Wind * 5) + Vector(0, 0, -15)

		if (self.NextDmg < CurTime()) then
			JMod.TryVirusInfectInRange(self, JMod.GetEZowner(self), 0, 0)
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
	local Cheating = GetConVar("sv_cheats")
	function ENT:Initialize()
		self.Col = Color(math.random(210, 230),math.random(150, 160),0, math.random(30,40))
		self.Visible = true
		self.Show = true
		self.siz = 0.01
		self.RenderPos = self:GetPos()
		self.Opacity = 10

		self.Diffuse = 1

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = true
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		
		self:SetModelScale(2)
	end

	--[[function ENT:Think()
		local Time = CurTime()

		if self.TimeDiffuse == nil or Time >= self.TimeDiffuse then
			for k,gas in ipairs(ents.FindInSphere(self:GetPos(), 700)) do
				local distanceBetween = self:GetPos():DistToSqr(gas:GetPos())
				if gas != self and gas:GetClass() == self:GetClass() then
					if distanceBetween >= 500^2 then
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
			render.DrawSprite(self:GetPos(), 50, 50, Color(214, 152, 71, 200))
		end

		local Time = CurTime()

		local OpacityTarget

		if self.DieTime == nil or self.DieTime - 2 > Time then
			OpacityTarget = 15 * self.Diffuse
		else
			OpacityTarget = 0 
		end

		local SizeTarget = 500

		self.siz = math.Round( Lerp(FrameTime() * 0.5, self.siz, SizeTarget), 0)

		self.Opacity = math.Round(Lerp(FrameTime() * 4.5, self.Opacity, OpacityTarget), 0)

		if self.Opacity > 0 then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(self.RenderPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, self.Opacity))
			self.RenderPos = LerpVector(FrameTime() * 1, self.RenderPos, SelfPos)
			--self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
