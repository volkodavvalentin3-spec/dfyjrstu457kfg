-- FumoFumo 2025
AddCSLuaFile()

ENT.Type		= "anim"
ENT.PrintName	= "EZ Cigarettes"
ENT.PhysicsSounds = true
ENT.Category	= "JMod - EZ Misc."
ENT.Spawnable	= false

ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle( 90, 180, 0 )

local smokeSnd = Sound( "ww_items/cigarettes.wav" )

local breakSnd = Sound( "physics/cardboard/cardboard_box_impact_bullet1.wav" )

function ENT:Initialize()

--	self:SetModel( "models/props_ww_items/cigarette_case01.mdl" )

	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		self:PhysWake()

	end

	self:SetSkin( math.random( 0, 2 ) )

end

if SERVER then

	function ENT:Use( ply )

		local plyAlt = JMod.IsAltUsing( ply )

		if plyAlt then
			local oldCrazy = ply:GetCrazy()
			if not ply.NextSmoke then ply.NextSmoke = CurTime() end
			local nextSmoke = ply.NextSmoke <= CurTime()
			if nextSmoke then
				sound.Play( smokeSnd, ply:GetPos(), 100, 100, 1, 0 )

				timer.Simple( 1.5, function()
					if IsValid( ply ) and nextSmoke then
						ply:SetCrazy( ply:GetCrazy() - 0.5 )
						ply.NextSmoke = CurTime() + 10
					end
				end )
				self:Remove()
			end
		else
			local grndEnt = ply:GetGroundEntity()

			if grndEnt ~= self and self:GetPhysicsObject():GetMass() <= 40 then
				ply:PickupObject(self)
			end
		end
	end

	function ENT:OnTakeDamage( dmginfo )

		self:TakePhysicsDamage( dmginfo )

		if dmginfo:GetDamage() >= 50 then
			self:EmitSound( breakSnd, 75, 100, 1, CHAN_AUTO, 0, 1 )
			self:Remove()
		end
	end
end

if CLIENT then
	language.Add("ent_fumo_lanrp_cigarettes", "EZ Cigarettes")
end