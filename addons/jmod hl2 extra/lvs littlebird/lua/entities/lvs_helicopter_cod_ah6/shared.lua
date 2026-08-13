
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "AH-6 Littlebird"
ENT.Category = "[LVS] - Helicopters"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lfs_merydian/ah6_lb.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 325

ENT.MaxVelocity = 2550

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.8

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1.3
ENT.TurnRateRoll = 1

ENT.brrt = CurTime()

ENT.ForceLinearDampingMultiplier = 1.4

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.GibModels = {
	"models/lvs_custom/mh6/ah6_gib1.mdl",
	"models/lvs_custom/mh6/ah6_gib2.mdl",
	"models/lvs_custom/mh6/ah6_gib3.mdl",
	"models/lvs_custom/mh6/ah6_gib4.mdl",
	"models/lvs_custom/mh6/ah6_gib5.mdl",
	"models/lvs_custom/mh6/ah6_gib6.mdl",
}

ENT.EngineSounds = {
	{
	    sound = "^lvs_custom/ah6/rotor.wav",
		sound_int = "lvs_custom/ah6/ah6_cockpit.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =110,
		UseDoppler = true,
	},
	{
	    sound = "^lvs_custom/ah6/engine.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =105,
		UseDoppler = true,
	},
		{
	    sound = "lvs_custom/ah6/ah6_turbine.wav",
		sound_int = "",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =70,
		UseDoppler = true,
	},
}

ENT.Networked_PhysBullets = true

ENT.CustomAttachments = {
	[1] = {
		Pos = Vector(1, 37.804, -93.79),
		Ang = Angle(-0.573, -0.05, 0.455)
	},
	[2] = {
		Pos = Vector(1, -37.804, -93.79),
		Ang = Angle(-0.573, 0.05, 0.261 ) 
	}
}

ENT.FlyByAdvance = 1 -- how many second the flyby sound is advanced
ENT.FlyBySound = "AH6_FLYBY" -- which sound to play on fly by

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "LightsEnabled" )
	self:AddDT( "Bool", "SignalsEnabled" )
end

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/dual_mg.png")
	weapon.Ammo = 1000
	weapon.Delay = 0.01
	weapon.HeatRateUp = 0.35
	weapon.HeatRateDown = 0.22
	weapon.StartAttack = function( ent )
    ent.GunSound = ent:StartLoopingSound("AH6_MGLOOP")
	ent.GunSound2 = ent:StartLoopingSound("AH6_MGLOOPDistance")
	ent.GunSound3 = ent:StartLoopingSound("AH6_MGSTART")
	ent.GunSound4 = ent:StartLoopingSound("AH6_MGSTARTDistance")
	ent.GunSound5 = ent:StartLoopingSound("AH6_MGWHINELOOP")
	end
	weapon.FinishAttack = function( ent )
    ent:EmitSound("AH6_MGSTOP")
	ent:EmitSound("AH6_MGSTOPTDistance")
    ent:StopLoopingSound( ent.GunSound )
	ent:StopLoopingSound( ent.GunSound2 )
	ent:StopLoopingSound( ent.GunSound3 )
	ent:StopLoopingSound( ent.GunSound4 )
	ent:StopLoopingSound( ent.GunSound5 )

	if ent.brrt <= CurTime() then
		ent.brrt = CurTime() + 2
		EmitFarSound(self:GetPos(), math.random(175,178), 3500, 9000, 1000, 20000)
	end
end
	
	
	weapon.Attack = function( ent )
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:LocalToWorld( Vector(16.005,37.804 * (self.FireLeft and 1 or -1),-82.79) ) )
		effectdata:SetNormal( ent:GetForward() )
		effectdata:SetEntity( ent )
		effectdata:SetScale( 1 )
		util.Effect( "lvs_muzzle", effectdata )
			
        local effectdata = EffectData()
		effectdata:SetOrigin( ent:LocalToWorld( Vector(1,37.804 * (self.FireLeft and 1 or -1),-93.79) ) )
		effectdata:SetAngles( Angle (90,0,0) )
		effectdata:SetEntity( ent )
		effectdata:SetScale( 1 )
	    util.Effect( "RifleShellEject", effectdata, true, true )			

 	 	ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(37.005,37.804 * (self.FireLeft and 1 or -1),-82.79) ) )
		bullet.Dir 	= ent:GetForward() + ent:GetUp() * 0.01 + ent:GetRight() * (self.FireLeft and 0.0075 or -0.0075)
		bullet.Spread 	= Vector( 0.001,  0.015, 0.015 )
		bullet.TracerName = "lvs_tracer_orange"
		bullet.Force	= 5
		bullet.HullSize 	= 15
		bullet.Damage	= 22
		bullet.Velocity = 10000
		bullet.SplashDamage = 8
		bullet.SplashDamageRadius = 30
		bullet.Attacker 	= ent:GetDriver()

		//bullet.LVS_IsCustomAtachment
		//print(bullet.Attacker)

		//print(ent:WorldToLocalAngles(bullet.Dir:Angle()))

	    self.barrelSpinAdd = self.barrelSpinAdd and (self.barrelSpinAdd - self.barrelSpinAdd * FrameTime() * 5) or 0
	    self.barrelSpin = self.barrelSpin and (self.barrelSpin + self.barrelSpinAdd) or 0
		
	    self:ManipulateBoneAngles( 3, Angle(self.barrelSpin,0,0) )
	    self:ManipulateBoneAngles( 2, Angle(self.barrelSpin,0,0) )
		

		bullet.LVS_isCustomAttachment = true
		bullet.LVS_attachment = self.FireLeft and 1 or 2

		ent:LVSFireBullet( bullet )
		self.barrelSpinAdd = 30

		--EmitFarSound(ent:GetPos(), "LANRP/realism/weapon/dist/mg/mg42_dist.mp3", 2000, 25000)

		ent:TakeAmmo( 2 )
		
		weapon.OnSelect = function( ent ) ent:EmitSound("lvs_custom/ah6/select_minigun.wav") end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("AH6_MGLAST_OVERHEAT") end
		end
	self:AddWeapon( weapon )
	
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 14
	weapon.Delay = 0.2
	weapon.HeatRateUp = 2
	weapon.HeatRateDown = 0.5
	weapon.Attack = function( ent )

		ent.FireLeft = not ent.FireLeft

		local Driver = ent:GetDriver()
		local Target = ent:GetEyeTrace().HitPos

		local projectile = ents.Create( "ent_jack_gmod_ezherocket" )
		projectile:SetPos( ent:LocalToWorld( Vector(17.36,50.89 * (self.FireLeft and 1 or -1),-83.39) ) )
		projectile:SetAngles( ent:LocalToWorldAngles( Angle(0,-90,5)))
		--projectile:SetParent( ent )
		projectile:SetOwner(ent)
		projectile:Spawn()
		projectile:Activate()

		projectile:SetState(1)
		projectile:Launch()
		--[[projectile.GetTarget = function( missile ) return missile end
		projectile.GetTargetPos = function( missile )
			if missile.HasReachedTarget then
				return missile:LocalToWorld( Vector(100,0,0) )
			end

			if (missile:GetPos() - Target):Length() < 100 then
				missile.HasReachedTarget = true
			end
			return Target
		end]]
		--projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		--projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		--projectile:SetSpeed( ent:GetVelocity():Length() + 6000 )
		--projectile:SetDamage( 400 )
		--projectile:SetRadius( 250 )
		--projectile:Enable()
		projectile:EmitSound("npc/waste_scanner/grenade_fire.wav")

		EmitFarSound(self:GetPos(), 190, 3500, 40000)

		ent:TakeAmmo()
	end
	
	weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_missile.wav")
	end
	self:AddWeapon( weapon )
	
	--[[local weapon = {}
	weapon.Icon = Material("lvs/weapons/light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetLightsEnabled then return end

		if ent:GetAI() then return end

		ent:SetLightsEnabled( not ent:GetLightsEnabled() )
		ent:EmitSound( "items/flashlight1.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_light.wav")
	end
	self:AddWeapon( weapon )
	
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/wing_light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetSignalsEnabled then return end

		if ent:GetAI() then return end

		ent:SetSignalsEnabled( not ent:GetSignalsEnabled() )
		ent:EmitSound( "buttons/lightswitch2.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_signal.wav")
	end
	self:AddWeapon( weapon )]]
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_ah6", "vgui/killicons/iw4_choppergunner")
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_mh6", "vgui/killicons/iw4_choppergunner")
end

if killicon and killicon.Add then
	killicon.Add("lvs_helicopter_cod_mh6alt", "vgui/killicons/iw4_choppergunner")
end

sound.Add( {
	name = "AH6_MGLOOP",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/gunloop.wav"
} )

sound.Add( {
	name = "AH6_MGWHINELOOP",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 70,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/whineloop.wav"
} )

sound.Add( {
	name = "AH6_MGLOOPDistance",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 140,
	pitch = {90,100},
	sound = "^lvs_custom/ah6/gunloopdistant.wav"
} )

sound.Add( {
	name = "AH6_MGSTART",
	channel = CHAN_AUTO,
	volume = 0.7,
	level = 70,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstart.wav"
} )

sound.Add( {
	name = "AH6_MGSTARTDistance",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 140,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstartdistant.wav"
} )

sound.Add( {
	name = "AH6_MGSTOP",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstop.wav"
} )

sound.Add( {
	name = "AH6_MGSTOPTDistance",
	channel = CHAN_AUTO,
	volume = 0.6,
	level = 140,
	pitch = {100},
	sound = "^lvs_custom/ah6/gunstopdistant.wav"
} )

sound.Add( {
	name = "AH6_MGLAST_OVERHEAT",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 70,
	pitch = {100},
	sound = "lvs_custom/ah6/last.wav"
} )

sound.Add( {
	name = "AH6_FLYBY",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 110,
	pitch = {100},
	sound = {"lvs_custom/ah6/flyby-01.wav","lvs_custom/ah6/flyby-02.wav","lvs_custom/ah6/flyby-03.wav","lvs_custom/ah6/flyby-04.wav"}
} )
