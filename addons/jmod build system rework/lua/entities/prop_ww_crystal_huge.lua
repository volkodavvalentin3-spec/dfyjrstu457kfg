-- FumoFumo 2025
AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "#prop_ww_crystal_huge"
ENT.PhysicsSounds = true
ENT.Category	= "WWars"
ENT.Spawnable	= true

local vecUp = Vector( 0, 0, 1 )

local CRYSTAL_HEALTH = 25000

local COLOR_NORMAL = Color( 255, 255, 255 )
local COLOR_DEAD = Color( 255, 0, 0 )

function ENT:Initialize()

	self:SetModel( "models/jmod_construction/crystal_huge.mdl" )

	self:SetMoveType( MOVETYPE_VPHYSICS )

	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self.ShadowParams = {}

		self.ArrivePos = Vector( 0, 0, 0 )

		self.CrystalHealth = CRYSTAL_HEALTH

		self.HColor = COLOR_NORMAL

		self.WasUsed = false

	end

	if CLIENT then

	end

end

if SERVER then

	function ENT:Use( activator )

		if self.WasUsed then return end

		self:PhysicsInit( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()

		if IsValid( phys ) then
		
			phys:Wake()

			self.ArrivePos = self:GetPos() + vecUp * 2048

			self:StartMotionController()

			self.SeqActive = true

			self.WasUsed = true

		end

	end

	function ENT:PhysicsSimulate( phys, deltaTime )

		local physPos = phys:GetPos()
		local physAng = phys:GetAngles()

		phys:Wake()

		self.ShadowParams.secondstoarrive = deltaTime * 16

		self.ShadowParams.pos = self.ArrivePos
		self.ShadowParams.maxspeed = 75
		self.ShadowParams.maxspeeddamp = 75

		self.ShadowParams.angle = Angle( 0, physAng.y + 5, 0 )
		self.ShadowParams.maxangular = 25
		self.ShadowParams.delta = deltatTime
		self.ShadowParams.maxangulardamp = 25

		phys:ComputeShadowControl( self.ShadowParams )

	end

	function ENT:OnTakeDamage( dmgInfo )

		local dmg = dmgInfo:GetDamage()

		if dmg < 15 then return end

		local newHealth = self.CrystalHealth - dmg

		self.CrystalHealth = newHealth

		self.HColor = COLOR_NORMAL:Lerp( COLOR_DEAD, ( 1 - newHealth / CRYSTAL_HEALTH ) )

		print( 1 - newHealth / CRYSTAL_HEALTH )

		print( self.HColor )

		print( newHealth )

		self:SetColor( self.HColor )

		if newHealth <= 0 then
			self:Remove()
			return
		end

	end

	function ENT:Think()
	
		if ( self:GetPos() - self.ArrivePos ):Length() < 0.01 and self.SeqActive then
			self:StopMotionController()
			self:PhysicsInitStatic( SOLID_VPHYSICS )
			self.SeqActive = false
		end

	end

end

if CLIENT then
	function ENT:Think()

		self:SetNextClientThink( CurTime() )
		return true
	end
end