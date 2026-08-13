-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Flare Projectile"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Model = "models/kali/weapons/mgsv/magazines/ammunition/40mm grenade.mdl"
ENT.Material = nil
ENT.ModelScale = nil
ENT.ImpactSound = "Grenade.ImpactHard"
ENT.CollisionGroup = COLLISION_GROUP_NONE

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetBodygroup(1, 2)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:GetPhysicsObject():EnableDrag(false)

		self:SetColor(Color(255,0,0))

		--[[
		0 - red
		1 - green
		2 - blue
		]]
		
		self.ParticleColor = 0

		timer.Simple(0, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetMass(2)
			end
		end)

		self.StartFloatingTime = CurTime() + 3
		self.Floating = false

		SafeRemoveEntityDelayed(self, 60)
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:Think()
		local Time = CurTime()

		if (self.StartFloatingTime < Time and not self.Floating) then
			self.Floating = true
			self:GetPhysicsObject():EnableDrag(true)
			self:GetPhysicsObject():SetDamping(20, 20)
		end

		local Vel = self:GetVelocity()

		local Fsh = EffectData()
		Fsh:SetOrigin(self:GetPos())
		Fsh:SetScale(1)
		Fsh:SetNormal(-Vel:GetNormalized())
		Fsh:SetStart(Vel)
		Fsh:SetColor(self.ParticleColor)
		util.Effect("eff_jack_gmod_projectileflareburn", Fsh, true, true)

		if (self.Floating) then self:GetPhysicsObject():ApplyForceCenter(JMod.Wind * 200) end

		self:NextThink(Time + .1)
		return true
	end

	function ENT:PhysicsCollide( data, phys )
		if data.DeltaTime <= 0.1 then
			self:Remove()
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
else

	FlareEnts = {}

	function ENT:Initialize()
		timer.Simple(0.1, function()
			FlareEnts[self] = true
		end)
	end

	function ENT:OnRemove()
		FlareEnts[self] = nil
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")
	local GlowSprite2 = Material("particle/fire")
	local HotGlowSprite = Material("particles/fire_glow")

	local hdrMat = Material("particle/particle_glow_02")
	local HDRcolor = Color(0,0,0,160)

	hook.Add( "HUDPaint", "FlareRender", function()
		if FlareEnts != nil then
			for ent, v in pairs(FlareEnts) do
				if ent == nil then continue end
				if not IsValid(ent) then FlareEnts[ent] = nil continue end

				local data2D = ent:GetPos():ToScreen()

				if not data2D.visible then continue end

				local pos = Vector(data2D.x, data2D.y, data2D.z)

				local tr = util.TraceLine( {
					start = ent:GetPos(),
					endpos = EyePos(),
					filter = {LocalPlayer(), ent, ent.LVS},
				} )

				if tr.Hit then continue end  

				local EyeVec = EyePos() - pos
				local Dist = EyeVec:Length()
				local SpriteSize = math.Clamp(Dist / 500, 100, 500)
				local offset = 50


				--if render.GetHDREnabled() then
					surface.SetMaterial( hdrMat )
					surface.SetDrawColor( HDRcolor )
					surface.DrawTexturedRect( data2D.x - 50, data2D.y - 50, SpriteSize, SpriteSize )
				--end

				surface.SetMaterial( GlowSprite )
				surface.SetDrawColor( ent:GetColor() )
				surface.DrawTexturedRect( data2D.x - offset, data2D.y - offset, SpriteSize, SpriteSize )

				surface.SetMaterial( HotGlowSprite )
				surface.SetDrawColor( color_white )
				surface.DrawTexturedRect( data2D.x - (offset / 1.5), data2D.y - (offset / 1.5), SpriteSize / 1.5, SpriteSize / 1.5)
			end
		end
	end)

	function ENT:Draw()
		self:DrawModel()
		--[[local Pos, Ang = self:GetPos(), self:GetAngles()
		local BurnDir = -self:GetVelocity():GetNormalized()
		local R, G, B = 255, 0, 0

		render.SetMaterial(GlowSprite)
		local EyeVec = EyePos() - Pos
		local EyeDir, Dist = EyeVec:GetNormalized(), EyeVec:Length()
		local DistFrac = math.Clamp(Dist, 0, 400) / 400
		
		local DistSize = Dist / 10

		render.DrawSprite(Pos + BurnDir * 8 + EyeDir * 20, DistSize, DistSize, Color(R, G, B, 255 * DistFrac))

		render.SetMaterial(GlowSprite2)

		render.DrawSprite(Pos + BurnDir * 8 + EyeDir * 20, DistSize * 5, DistSize * 5, Color(R, G, B, 255 * DistFrac))

		render.SetMaterial(HotGlowSprite)

		render.DrawSprite(Pos + BurnDir * 8 + EyeDir * 20, DistSize / 1.5, DistSize / 1.5, Color(255, 255, 255, 255 * DistFrac))]]
	end

	language.Add("ent_jack_gmod_ezflareprojectile", "EZ Flare Projectile")
end
