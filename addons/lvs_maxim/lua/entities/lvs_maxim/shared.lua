ENT.Base = "lvs_base_wheeldrive_trailer"

ENT.PrintName = "MAXIM"
ENT.Author = "asyol (chupac)"
ENT.Information = ""
ENT.Category = "[LVS]"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/maxim gun/maximgun.mdl"
ENT.AITEAM = 2

ENT.MaxHealth = 100
ENT.PhysicsWeightScale = 2
ENT.PhysicsMass = 800
ENT.PhysicsInertia = Vector(475,452,162)
ENT.PhysicsDampingSpeed = 4000
ENT.PhysicsDampingForward = false
ENT.PhysicsDampingReverse = false

ENT.Bones = {
	root = 0,
	gun_rotate = 1,
	gun_pitch = 2,
	arc = 3,
	wheel_l = 4,
	wheel_r = 5,
}

ENT.BonesAng = {
	pitch = Angle(),
	rotate = Angle(),
}

function ENT:CalcMainActivity( ply )
	if ply ~= self:GetDriver() then return self:CalcMainActivityPassenger( ply ) end

	if ply.m_bWasNoclipping then 
		ply.m_bWasNoclipping = nil 
		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM ) 
		
		if CLIENT then 
			ply:SetIK( true )
		end 
	end 

	ply.CalcIdeal = ACT_STAND
	ply.CalcSeqOverride = ply:LookupSequence( "cidle_pistol" )

	return ply.CalcIdeal, ply.CalcSeqOverride
end

function ENT:InitWeapons()
	local kord = {}
	kord.Icon = Material("lvs/weapons/hmg.png")
	kord.Ammo = 150
	kord.Delay = 0.1
	kord.HeatRateUp = 0.15
	kord.HeatRateDown = 0.15	
	kord.Attack = function( ent )
		local pos, ang = self:GetBonePosition(self.Bones.gun_pitch)

		local bullet = {}
		bullet.Src 	= pos + ang:Forward()*2 + ang:Up() * 3
		bullet.Dir 	= ang:Forward()
		bullet.Spread 	= Vector(0.02,0.02,0.02)
		bullet.TracerName = "lvs_tracer_yellow"
		bullet.Force	= 5
		bullet.HullSize = 10
		bullet.Damage	= 12
		bullet.Velocity = 1000
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )
		
		ParticleEffect("muzzleflash_akm_3rd",pos + ang:Forward()*2 + ang:Up() * 3,ang,nil)
		util.ScreenShake( pos, 1, 5, 1, 150, true, nil )

		local ej = ang + Angle(0,90,0)

		local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetAngles(ej)
		util.Effect( "RifleShellEject", effectdata )

		ent:TakeAmmo( 1 )

		ent:EmitSound("maxim/shoot.wav", 95, 100, 1, CHAN_WEAPON )
	end
	--[[kord.StartAttack = function( ent )
		local base = ent:GetVehicle()
		if not IsValid( base ) or not IsValid( base.SNDTurret ) then return end
		--base.SNDTurret:Play()
	end]]
	kord.FinishAttack = function( ent )
		local base = ent:GetVehicle()
		--if not IsValid( base ) or not IsValid( base.SNDTurret ) then return end
		base:EmitSound("maxim/stop.wav")
		base:StopSound("maxim/shoot.wav")
		--base.SNDTurret:Stop()
	end
	kord.OnThink = function( ent, active )
		if not active then return end
		local base = ent:GetVehicle()
		if !ent:GetDriver():IsValid() then return end
		if not IsValid( base ) then return end
		
		local pos_pitch, ang_pitch = self:GetBonePosition(self.Bones.gun_pitch)
		local pos_yaw, ang_yaw =  self:GetBonePosition(self.Bones.gun_rotate)
	
		ang_pitch = self:WorldToLocalAngles(ang_pitch)
		ang_yaw = self:WorldToLocalAngles(ang_yaw)

		ang_yaw.y = ang_yaw.y - 90

		local Angles = self:WorldToLocalAngles( ent:GetAimVector():Angle() )
		Angles:Normalize()

		local Pitch = math.Clamp( Lerp(3 * FrameTime(), ang_pitch.p, Angles.p), -20, 20 )
		local Yaw = math.Clamp( Lerp(3 * FrameTime(), ang_yaw.y , Angles.y ), -40, 40 )

		local pitch = Angle(Pitch,0,0)
		local yaw = Angle(0,0,Yaw)

		self:ManipulateBoneAngles(self.Bones.gun_pitch, pitch )
		self:ManipulateBoneAngles(self.Bones.gun_rotate, yaw)
	end
	kord.CalcView = function( ent, ply, pos, angles, fov, pod )
		if not pod:GetThirdPersonMode() then
		   if ply:lvsKeyDown("ZOOM") then

				local pos, ang = self:GetBonePosition(self.Bones.gun_pitch)

				pos = pos + ang:Forward()*-18 + ang:Up() * 7.32 + ang:Right()*-1.07
				
				local view = {}
				view.origin = pos
				view.angles = ang
				view.fov = 60
				view.drawviewer = true
				return view	
			else
				return self:LVSCalcView( ply, pos, angles, fov, pod )
			end
		else
			return self:LVSCalcView( ply, pos, angles, fov, pod )
		end
	end
	
	--[[kord.HudPaint = function( ent, X, Y, ply )
		local pos, ang = self:GetBonePosition(self.Bones.gun_pitch)
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos + ang:Forward() * 500000,
			filter = ent:GetCrosshairFilterEnts()
		} )
		local Crosshair = tr.HitPos:ToScreen() 
		ent:PaintCrosshairCenter( Crosshair, Color(255,255,255,255) )
		ent:LVSPaintHitMarker( Crosshair )
	end]]
	self:AddWeapon( kord )
end

function ENT:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	ply:SetPlaybackRate( 1 )

	if CLIENT then
		local ply = self:GetDriver()
		if IsValid( ply )  then

			local pos_pitch, ang_pitch = self:GetBonePosition(self.Bones.gun_pitch)
			local pos_yaw, ang_yaw =  self:GetBonePosition(self.Bones.gun_rotate)
		
			ang_pitch = self:WorldToLocalAngles(ang_pitch)
			ang_yaw = self:WorldToLocalAngles(ang_yaw)

			ang_yaw.y = ang_yaw.y - 90

			local Pitch = math.Remap( -ang_pitch.p,-20,20,20,40)	
			local Yaw = math.Remap( -ang_yaw.y,-40,40,0,40) 

			ply:SetPoseParameter( "aim_pitch", Pitch * 1.5 )
			ply:SetPoseParameter( "aim_yaw", Yaw * 1.5 )

			ply:SetPoseParameter( "head_pitch", -Pitch * 2 )
			ply:SetPoseParameter( "head_yaw", -Yaw * 3 )

			ply:SetPoseParameter( "move_x", 0 )
			ply:SetPoseParameter( "move_y", 0 )

			ply:InvalidateBoneCache()

			GAMEMODE:GrabEarAnimation( ply )
			GAMEMODE:MouthMoveAnimation( ply )
		end
	end

	return false
end

function ENT:PhysicsCollide( data, phys )
	if data.Speed > 10 and data.DeltaTime > 0.2 and data.HitEntity:GetClass() == "ent_jack_gmod_ezammo" then
		local ammobox = data.HitEntity
		local AmmoIsSet = false

		for PodID, data in pairs( self.WEAPONS ) do
			for id, weapon in pairs( data ) do
				local MaxAmmo = weapon.Ammo or -1
				local CurAmmo = weapon._CurAmmo or MaxAmmo

				if MaxAmmo <= 100 then continue end

				local NeedAmmo = (MaxAmmo - CurAmmo) / 2

				print(NeedAmmo, CurAmmo)
				if CurAmmo == MaxAmmo then continue end
				if CurAmmo == -1 then continue end

				if NeedAmmo < 200 then
					ammobox:SetResource(ammobox:GetResource() - NeedAmmo)

					if ammobox:GetResource() <= 0 then
						timer.Simple(0.1, function()
							SafeRemoveEntity(ammobox)
						end)
					end

					self.WEAPONS[PodID][ id ]._CurAmmo = math.min( CurAmmo + (MaxAmmo - CurAmmo), MaxAmmo )
					AmmoIsSet = true
				else
					self.WEAPONS[PodID][ id ]._CurAmmo = math.min( CurAmmo + ammobox:GetResource(), MaxAmmo )
					SafeRemoveEntity(ammobox)
					AmmoIsSet = true
				end
			end
		end

		if AmmoIsSet then
			self:SetNWAmmo( self:GetAmmo() )

			for _, pod in pairs( self:GetPassengerSeats() ) do
				local weapon = pod:lvsGetWeapon()

				if not IsValid( weapon ) then continue end

				weapon:SetNWAmmo( weapon:GetAmmo() )
			end

			JMod.ResourceEffect(ammobox.EZsupplies, ammobox:LocalToWorld(ammobox:OBBCenter()), self:LocalToWorld(self:OBBCenter()), ammobox:GetResource(), 1, 1, 1)
			self:OnRefueled()
		end
	end
end