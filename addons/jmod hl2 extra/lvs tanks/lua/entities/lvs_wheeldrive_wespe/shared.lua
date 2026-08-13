
ENT.Base = "lvs_tank_wheeldrive"

ENT.PrintName = "Wespe"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - Tanks"

ENT.VehicleCategory = "Tanks"
ENT.VehicleSubCategory = "Light"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/diggercars/pz2/wespe_updated.mdl"
ENT.MDL_DESTROYED = "models/diggercars/pz2/wespe_dead.mdl"

ENT.GibModels = {
	"models/diggercars/pz2/wespe_gib1.mdl",
	"models/diggercars/pz2/wespe_gib2.mdl",
	"models/diggercars/pz2/wespe_gib3.mdl",
	"models/gibs/manhack_gib01.mdl",
	"models/gibs/manhack_gib02.mdl",
	"models/gibs/manhack_gib03.mdl",
	"models/gibs/manhack_gib04.mdl",
	"models/props_c17/canisterchunk01a.mdl",
	"models/props_c17/canisterchunk01d.mdl",
}

ENT.AITEAM = 1

ENT.MaxHealth = 800

--damage system
ENT.DSArmorIgnoreForce = 800
ENT.FrontArmor = 1200
ENT.TurretArmor = 200
ENT.RearArmor = 600

ENT.SteerSpeed = 1
ENT.SteerReturnSpeed = 2

ENT.PhysicsWeightScale = 2
ENT.PhysicsDampingSpeed = 1000
ENT.PhysicsInertia = Vector(6000,6000,1500)

ENT.MaxVelocity = 450
ENT.MaxVelocityReverse = 150

ENT.EngineCurve = 0.1
ENT.EngineCurveBoostLow = 2

ENT.EngineTorque = 300

ENT.TransMinGearHoldTime = 0.1
ENT.TransShiftSpeed = 0

ENT.TransGears = 3
ENT.TransGearsReverse = 1

ENT.MouseSteerAngle = 45

ENT.lvsShowInSpawner = true

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/pz2/eng_idle_loop.wav",
		Volume = 1,
		Pitch = 70,
		PitchMul = 30,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/vehicles/pz2/eng_loop.wav",
		Volume = 1,
		Pitch = 20,
		PitchMul = 100,
		SoundLevel = 85,
		SoundType = LVS.SOUNDTYPE_NONE,
		UseDoppler = true,
	}
}

ENT.ExhaustPositions = {
	{
		pos = Vector(-110,-28.7,45.8),
		ang = Angle(-130,0,0)
	},
}

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 32
	weapon.Delay = 4
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0.25
	weapon.StartAttack = function( ent )
	
		if self:GetAI() then return end

		self:MakeProjectile()
	end
	weapon.FinishAttack = function( ent )
		if self:GetAI() then return end

		self:FireProjectile()
	end
	weapon.Attack = function( ent )
		if not self:GetAI() then return end

		self:MakeProjectile()
		self:FireProjectile()
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()

		ent:LVSPaintHitMarker( Pos2D )

		local ID = self:LookupAttachment( "muzzle" )
		local Muzzle = self:GetAttachment( ID )
		if not Muzzle then return end

		local color_red = Color(0,0,0,255)
		local HudTargets = {}
		local Grav = physenv.GetGravity()
		local FT = RealFrameTime()
		local Pos = Muzzle.Pos
		local Vel = Muzzle.Ang:Forward() * 3000
		local Iteration = 0
		while Iteration < 5000 do
			Iteration = Iteration + 0.005
		
			Vel = Vel + Grav * FT
		
			local StartPos = Pos
			local EndPos = Pos + Vel * FT
		
			local trace = util.TraceLine( {
				start = StartPos,
				endpos = EndPos,
				mask = MASK_SOLID_BRUSHONLY,
			} )

			Pos = EndPos
			self:SetNWVector("SightPos",Pos)
		
			if trace.Hit then
				break
			end
		end
		local TargetPos = Pos:ToScreen()

		surface.SetTextColor( 255, 255, 255,255 )
		surface.SetTextPos( X*0.165, Y/2 )
		surface.DrawText( "Координаты наведения:")  
		surface.SetTextPos( X*0.165, Y/2 + 16)
		surface.DrawText( "X: ~ "..math.Round(((math.ceil(100*Pos.x))/100)/1))  
		surface.SetTextPos( X*0.165, Y/2 + 32)
		surface.DrawText( "Y: ~ "..math.Round(((math.ceil(100*Pos.y))/100)/1))
		--[[surface.SetTextPos( X*0.165, Y/2 + 48)
		surface.DrawText( "Z: ~ "..math.Round(((math.ceil(100*Pos.z))/100)/1))]]
	end
	self:AddWeapon( weapon )

	-- turret rotation disabler
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/tank_noturret.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.OnSelect = function( ent, old, new  )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( false )
		end
	end
	weapon.OnDeselect = function( ent, old, new  )
		if ent.SetTurretEnabled then
			ent:SetTurretEnabled( true )
		end
	end
	self:AddWeapon( weapon )
end
