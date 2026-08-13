-- FumoFumo 2025
AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "#prop_ww_door"
ENT.PhysicsSounds = true
ENT.Category	= "WWars"
ENT.Spawnable	= true

ENT.AutomaticFrameAdvance = true

local seqOpen, seqClose, seqIdle = "open", "close", "idle"

local COLOR_CYAN = Color( 0, 255, 255 )
local COLOR_BLUE = Color( 0, 0, 255 )
local COLOR_RED = Color( 255, 0, 0 )

local sndMove = Sound( "doors/door_metal_rusty_move1.wav" )
local sndOpen = Sound( "doors/door_metal_large_open1.wav" )
local sndClose = Sound( "doors/door_metal_large_close2.wav" )
local sndBlock = Sound( "physics/metal/metal_box_strain1.wav" )

local sndLocked = Sound( "doors/default_locked.wav" )

local sndLock = Sound( "doors/latchlocked2.wav" )
local sndUnlock = Sound( "doors/latchunlocked1.wav" )

local vecDown = Vector( 0, 0, -1 )

local Approach = math.Approach

function ENT:Initialize()

	self:SetModel( "models/jmod_construction/garagedoor01.mdl" )

	self:SetMoveType( MOVETYPE_VPHYSICS )

	self:DrawShadow( false )

	if SERVER then

		self:SetUseType( SIMPLE_USE )

		self:CreateBoneFollowers()

	end

	self:ResetSequence( seqIdle )

	self.IsOpen = false
	self.IsBlocked = false

	self.NextUse = CurTime()

	self.DoorHealth = 800

	self.CurPos = 0
	self.TargetPos = 0

	self.SeqTime = 0

	self.Locked = false

end

if SERVER then

	function ENT:Use( ply )

		local frameTime = FrameTime()

		local plyAlt = JMod.IsAltUsing( ply )

		if plyAlt then
			self.Locked = not self.Locked

			if self.Locked then
				self:EmitSound( sndLock )
			else
				self:EmitSound( sndUnlock )
			end

			return
		end

		if self.Locked or self.NextUse >= CurTime() then
			self:EmitSound( sndLocked )
			return
		end

		if self.IsBlocked then
			self.TargetPos = 1
	
			self.SeqTime = ( 1 - self.CurPos ) / ( 0.5 * frameTime ) * frameTime

			self.IsBlocked = false
		else
			self.TargetPos = self.TargetPos == 0 and 1 or 0
			
			self.SeqTime = 1 / ( 0.5 * frameTime ) * frameTime
		end

		self:EmitSound( sndMove )

		timer.Simple( self.SeqTime, function()
			if self.IsBlocked or not IsValid( self ) then return end

			local snd = self.IsOpen and sndOpen or sndClose
			self:EmitSound( snd )
		end )

		self.IsOpen = not self.IsOpen

		self.NextUse = CurTime() + self.SeqTime + 1

	end

	function ENT:Think()

		self.CurPos = Approach( self.CurPos, self.TargetPos, FrameTime() * 0.5 )

		self:SetPoseParameter( "door_move", self.CurPos )
		self:UpdateBoneFollowers()

		self:NextThink( CurTime() )

		return true
	end

	function ENT:OnTakeDamage( dmgInfo )

--		print( dmgInfo )
--		print( dmgInfo:GetDamageForce():Length() )
		if dmgInfo:GetDamageType() == DMG_BLAST then
			self.DoorHealth = self.DoorHealth - dmgInfo:GetDamage() * 0.5
		end

		debugoverlay.Cross( dmgInfo:GetDamagePosition(), 16, 2, COLOR_BLUE, false )

		if self.DoorHealth <= 0 then
			self:Remove()
		end
	end

	function ENT:OnRemove()

		self:DestroyBoneFollowers()

	end


	local vec1 = Vector( -4, -128 + 8, 0 )

	local vec2 = Vector( 4, 128 - 8, 128 - 8 )

	function ENT:Touch( colEnt )

		local tr = self:GetTouchTrace()
		local hitPos = tr.HitPos
		local selfPos = self:GetPos()
		local selfAng = self:GetAngles()

		if not util.IntersectRayWithOBB( hitPos, vecDown, selfPos, selfAng, vec1, vec2 ) then return end

		if self.TargetPos == 0 and self.CurPos ~= self.TargetPos and not self.IsBlocked then
			if self.CurPos ~= 1 then
				debugoverlay.Cross( hitPos, 32, 1, COLOR_RED, false )
				debugoverlay.BoxAngles( selfPos, vec1, vec2, selfAng, 0.5, COLOR_CYAN )
				self.TargetPos = self.CurPos + FrameTime() * 5
				self.IsBlocked = true
				self:EmitSound( sndBlock )
			end
		end
	end
end

if CLIENT then

	function ENT:Think()

		self:InvalidateBoneCache()

		self:SetNextClientThink( CurTime() )
		return true
	end
end

--[[
if SERVER then

	function ENT:Use( ply )

		if self.NextUse >= CurTime() then return end

		local seq = self.IsOpen and seqClose or seqOpen 

		self:ResetSequence( seq )

		self:EmitSound( sndMove )

		local seqTime = self:SequenceDuration( seq )

		timer.Simple( seqTime, function()
			if self.IsBlocked or not IsValid( self ) then return end
			local snd = self.IsOpen and sndOpen or sndClose
			self:EmitSound( snd )
		end )

		self.IsOpen = not self.IsOpen

		self.IsBlocked = false

		self.NextUse = CurTime() + seqTime + 1

	end

	function ENT:OnTakeDamage( dmgInfo )

		print( dmgInfo )

		debugoverlay.Cross( dmgInfo:GetDamagePosition(), 16, 2, COLOR_BLUE, false )

		self.DoorHealth = self.DoorHealth - dmgInfo:GetDamage()

		if self.DoorHealth <= 0 then
			self:Remove()
		end
		print( self.DoorHealth )
	end

	function ENT:Think()

		self:UpdateBoneFollowers()

		self:NextThink( CurTime() )

		return true
	end

	function ENT:OnRemove()

		self:DestroyBoneFollowers()

	end

	local vec1 = Vector( -4, -128 + 8, 0 )

	local vec2 = Vector( 4, 128 - 8, 128 - 8 )

	function ENT:Touch( colEnt )

		local tr = self:GetTouchTrace()
		local hitPos = tr.HitPos
		local selfPos = self:GetPos()
		local selfAng = self:GetAngles()

		if not util.IntersectRayWithOBB( hitPos, vecDown, selfPos, selfAng, vec1, vec2 ) then return end

		if self:GetSequence() == 2 then
			local cycle = self:GetCycle()
			if cycle ~= 1 then
				debugoverlay.Cross( hitPos, 32, 1, COLOR_RED, false )
				debugoverlay.BoxAngles( selfPos, vec1, vec2, selfAng, 0.5, COLOR_CYAN )
				self:SetSequence( seqOpen )
				self:SetCycle( 1 - cycle )
				self.IsOpen = not self.IsOpen
				self.IsBlocked = true
			end
		end
	end
end
--]]