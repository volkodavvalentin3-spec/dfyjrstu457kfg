-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Mortar"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = true
ENT.AdminSpawnable = true
--ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/surgeon/mortar34.mdl"
ENT.Mass = 25
ENT.JModEZstorable = true

ENT.JModPreferredCarryAngles = Angle(0,90,0)
--ENT.EZcolorable = true
--ENT.EZbuoyancy = .3
--
ENT.EZconsumes={
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
}
ENT.Base="ent_jack_gmod_ezmachine_base"
---
ENT.StaticPerfSpecs={
	MaxDurability=10,
	Armor=1
}

ENT.AmmoWhiteList = {
	["ent_jack_gmod_ezmortarshell"] = true,
	["ent_jack_gmod_ezmortarshell_smoke"] = true,
}

ENT.MaxShells = 5
ENT.Shells = nil

ENT.Range = 50
ENT.Turn = 0

local STATE_BROKEN,STATE_FINE=-1,0

if SERVER then

	util.AddNetworkString( "set_mortar_range" )

	net.Receive( "set_mortar_range", function(len, ply)
		local ent = net.ReadEntity()
		local fire = net.ReadBool()
	
		local range = net.ReadFloat()
		local turn = net.ReadFloat()
	
		ent.Range = range
		ent.Turn = turn
	
		if fire then
			if ent.Shells != nil then
				ent:FireJmodProjectile(ply)
			end
		end
	
	end)

	function ENT:OnBreak()
		self:GibBreakClient( self:GetVelocity() )
		self:Remove()
	end

	function ENT:FireJmodProjectile(ply)
	
		local SelfAngles = self:GetAngles()

		--[[local CanFire = util.TraceLine( {
			start = self:GetPos() + Vector(0,0,20),
			endpos = self:GetPos() + SelfAngles:Forward() * 700 * SelfAngles:Up() * 10,
			filter = self
		} )
	
		--ply:SetPos(CanFire.HitPos)

		debugoverlay.Line(self:GetPos() + Vector(0,0,20), self:GetPos() + SelfAngles:Forward() * 700 * SelfAngles:Up() * 10, 3, Color(0,255,0), true)
	
		if CanFire.Hit then
			ply:LanRPChatPrint(Color(230,0,0), "Ты не можешь стрелять, пока перед тобой преграда.")
			return
		end]]
	
		--local SelfAngles = self:GetAngles()
		SelfAngles.p = 0 
		SelfAngles.r = 0
	
		local LieVector = self:GetPos() + (-SelfAngles:Right() * -1 * self.Range * 45) + SelfAngles:Right() * self.Turn * 45
	
		local RangeDistance = math.Clamp(self:GetPos():Distance( LieVector ) / 2100, 0, 2)
	
		local TrueVector = util.TraceLine( {
			start = LieVector + Vector(0,0,2048),
			endpos = LieVector + Vector(0,0,5000 * RangeDistance),
			mask = MASK_SOLID_BRUSHONLY
		} )
	
		local projectile = ents.Create(self.Shells)
		projectile.Arm = true
		projectile:SetPos( TrueVector.HitPos + Vector(math.random( -600 * RangeDistance, 600 * RangeDistance), math.random( -600 * RangeDistance, 600 * RangeDistance), 0))
		projectile:SetAngles( Angle(90,0,0) )
		projectile:Spawn()
		projectile:Activate()
	
		projectile:SetCollisionGroup( COLLISION_GROUP_WORLD)

		--
		--timer.Simple(3.5, function()
			--EmitFarSound(projectile:GetPos(), math.random(187,189), 1000, 3000, 0, 3000)
			projectile:EmitSound("LANRP/realism/weapon/shot/mortar_sound/mtr_incoming_" .. math.random(1,3) .. ".wav", 85, 100, 1, CHAN_AUTO )
		--end)
	
		debugoverlay.Line(LieVector, projectile:GetPos(), 10, Color(255,255,255), true)
	
		--[[timer.Simple(0.1, function()
			if IsValid(projectile) then
				projectile:SetCollisionGroup( COLLISION_GROUP_NONE)
			end
		end)]]
	
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetNormal( self:GetAngles():Right() )
		effectdata:SetEntity( self )
		util.Effect( "lvs_haubitze_muzzle", effectdata )
	
		local PhysObj = projectile:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:ApplyForceCenter( Vector(0,0,-1000) )
		end

		self:EmitSound("weapons/mortar/mortar_fire1.wav", 75, 100, 1, CHAN_AUTO )
	
		EmitFarSound(self:GetPos(), math.random(33,37), 3500, 5000, 2000, 0)
	
		self.Shells = nil
	end

	function ENT:CustomInit()
		self:PrecacheGibs()
		
		timer.Simple(0, function()
			self:SetColor(color_white)
		end)
	end

	function ENT:Use(ply)
		
		if ply:KeyDown(IN_WALK) then
			net.Start("set_mortar_range")
			net.WriteEntity(self)
			net.WriteFloat(self.Range)
			net.WriteFloat(self.Turn)
			net.Send(ply)
		else
			ply:PickupObject( self ) 
		end
			
	end

	function ENT:PhysicsCollide( data, phys )
		local ent = data.HitEntity

		if ( data.Speed > 25 ) then
			if self.Shells == nil and self.AmmoWhiteList[ent:GetClass()] then
				self.Shells = ent:GetClass()
				ent:Remove()
			end
		end
	end

	
else
	net.Receive( "set_mortar_range", function()
	
		local ent = net.ReadEntity()
		local range = net.ReadFloat()
		local turn = net.ReadFloat()
		if !IsValid(ent) then return end
		
		SetMortarRange(ent, range, turn)
	end)
	
	MortarRange = 50
	MortarTurn = 0
	
	function SetMortarRange(ent, range, turn)
	
		local TrueVector = (ent:GetPos() + (-ent:GetAngles():Right()* -1 * MortarRange * 45) + ent:GetAngles():Right() * MortarTurn * 45) + Vector(0,0, 1024)
	
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 180)
		frame:SetTitle("Миномет")
		frame:Center()
		frame:MakePopup()
		frame.OnClose = function(self)
			net.Start("set_mortar_range")
				net.WriteEntity(ent)
				net.WriteBool(false)
				net.WriteFloat(MortarRange)
				net.WriteFloat(MortarTurn)
			net.SendToServer()
		end
	
		local Xvector = vgui.Create( "DLabel", frame )
		Xvector:SetPos( 25, 40 )
		Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))
	
		local Yvector = vgui.Create( "DLabel", frame )
		Yvector:SetPos( 75, 40 )
		Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))
	
		local slider = vgui.Create("DNumSlider", frame)
		slider:SetText( "Расстояние" )
		slider:SetPos(25, 70)
		slider:SetSize(250, 20)
		slider:SetMin(50)
		slider:SetMax(150) -- Максимальное расстояние в метрах
		slider:SetValue(range)
		slider:SetDecimals(0)
		slider.OnValueChanged = function(self, value)
			MortarRange = math.Round(value, 0)
	
			local newangel = ent:GetAngles()
			newangel.y = newangel.y + -MortarTurn

			local TrueVector = (ent:GetPos() + (newangel:Right() * MortarRange * 45)) + Vector(0,0, 1024)

			debugoverlay.Axis(TrueVector, newangel, 100, 3, true)
	
			Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))
			Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))
		end
	
		local angleSlider = vgui.Create("DNumSlider", frame)
		angleSlider:SetText( "Угол" )
		angleSlider:SetPos(25, 100)
		angleSlider:SetSize(250, 20)
		angleSlider:SetMin(-30)
		angleSlider:SetMax(30) -- Максимальный угол в градусах
		angleSlider:SetValue(turn)
		angleSlider:SetDecimals(0)
		angleSlider.OnValueChanged = function(self, value)
			MortarTurn = math.Round(value, 0)

			local newangel = ent:GetAngles()
			newangel.y = newangel.y + -MortarTurn

			local TrueVector = (ent:GetPos() + (newangel:Right() * MortarRange * 45)) + Vector(0,0, 1024)

			debugoverlay.Axis(TrueVector, newangel, 100, 3, true)
	
			Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))
			Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))
		end
	
		local button = vgui.Create("DButton", frame)
		button:SetPos(100, 140)
		button:SetSize(100, 30)
		button:SetText("ВЫСТРЕЛ")
		button.DoClick = function()
			net.Start("set_mortar_range")
				net.WriteEntity(ent)
				net.WriteBool(true)
				net.WriteFloat(MortarRange)
				net.WriteFloat(MortarTurn)
			net.SendToServer()
	
			frame:Close()
		end
	end
end
