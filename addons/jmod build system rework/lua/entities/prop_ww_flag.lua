-- FumoFumo 2025
AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "#prop_ww_flag"
ENT.PhysicsSounds = true
ENT.Category	= "WWars"
ENT.Spawnable	= true

ENT.AutomaticFrameAdvance = true

ENT.JModPreferredCarryAngles = Angle(35,10,0)

ENT.squad = -1

local stickSnd = Sound( "physics/metal/sawblade_stick2.wav" )

local fmod = math.fmod
local abs = math.abs

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "WindDir" )

	if SERVER then
		self:SetWindDir( JMod.Wind )
	end
end

function ENT:Initialize()
	self:SetModel( "models/jmod_construction/flag01.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:DrawShadow( false )

	--self:SetModelScale(3)

	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PhysWake()
	end

	if CLIENT then
		self.FlagDir = Angle( 0, 0, 0 )
		self.CurWind = Angle( 0, 0, 0 )
	end
end

if SERVER then
	util.AddNetworkString("FlagRTUpdate")

	function ENT:Think()
		local ezWind = JMod.Wind

		self:SetWindDir( ezWind )
		self:NextThink( CurTime() + 10 )

		return true 
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Use(ply)
		local SelfPos = self:GetPos()
		local squad = SquadMenu:GetSquad(ply:GetSquadID())

		if ply:KeyDown(IN_WALK) and ((self.squad == -1) or (self.squad == ply:GetSquadID())) and not self:IsConstrained() then
			self.squad = ply:GetSquadID()
			--self:SetColor(Color(squad.r, squad.g, squad.b))

			net.Start("FlagRTUpdate")
			net.WriteEntity(self)
			net.WriteTable(squad)
			--net.SendPVS(self:GetPos())
			net.Broadcast()

			local WorldTr = util.TraceLine({
				start = SelfPos,
				endpos = SelfPos + Vector(0,0,-16),
				filter = self
			})

			if WorldTr.Hit then

				local Eff = EffectData()
				Eff:SetOrigin(WorldTr.HitPos)
				Eff:SetScale(1)
				Eff:SetNormal(WorldTr.HitNormal)
				util.Effect("eff_jack_sminebury", Eff, true, true)

				self:SetAngles(Angle(math.random(-5,5),0,0))
				self:SetPos(WorldTr.HitPos + Vector(0,0,0))

				--ply:ChatPrint(tostring(WorldTr.Entity))

				self:SetCollisionGroup(COLLISION_GROUP_WORLD)

				constraint.Weld( self, IsValid(WorldTr.Entity) and WorldTr.Entity or game.GetWorld(), 0, 0, 0, true, false )
				
				self:EmitSound( stickSnd, 90, 100 )
			end

		elseif self.squad == ply:GetSquadID() or (self.squad == -1) then
			constraint.RemoveConstraints( self, "Weld" )
			ply:PickupObject( self ) 
			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end
end

local function NormalizeAngle( ang )

	ang = fmod( ang, 360 )
	if ang > 180 then
		ang = ang -360
	elseif ang < -180 then
		ang = ang + 360
	end

	return ang
end

if CLIENT then
	function ENT:Think()

		local selfVel = self:GetVelocity()

--		print( selfVel:Length2DSqr() > 2048)
		local windDir = self:GetWindDir()
		self.CurWind = windDir
--		print( windDir )
		if selfVel:Length2DSqr() > 1560 then
			self.CurWind:Zero()
			self.CurWind:Add( -Vector( selfVel.x, selfVel.y, 0 ) )		
		end

		self.CurWind = self.CurWind:Angle()

		local selfAng = self:GetAngles()

		self.CurWind:Sub( selfAng )
		self.CurWind:Normalize()

		local curDir = self.FlagDir.p
		local targetDir = self.CurWind.y

		local diff = NormalizeAngle( targetDir - curDir )

		local dirRate = FrameTime() * 128
		if abs( diff ) <= dirRate then
			self.FlagDir.p = targetDir
		else
			self.FlagDir.p = curDir + ( diff > 0 and dirRate or -dirRate )
		end

--		self.FlagDir.p = Approach( self.FlagDir.p, self.CurWind.y, FrameTime() * 512 )

		self:ManipulateBoneAngles( 0, self.FlagDir , false )

		self:SetNextClientThink( CurTime() )
		return true
	end

	net.Receive("FlagRTUpdate", function()
		local flag = net.ReadEntity()
		local squad = net.ReadTable()
		local rt = SquadsRTS[squad.id]

		FlagMaker(rt.RenderTarget, Color(squad.r, squad.g, squad.b), Material(squad.icon))
		flag:SetSubMaterial(1, "!" .. rt.MatName)
	end)
end	