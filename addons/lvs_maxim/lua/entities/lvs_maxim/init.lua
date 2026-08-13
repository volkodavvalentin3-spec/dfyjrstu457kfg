AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(-40,0,-10), Angle(0,-90,0) )
	local pos, ang = self:GetBonePosition(self.Bones.root)

	--[[self.SNDTurret = self:AddSoundEmitter( pos, "maxim/shoot.wav", "maxim/shoot.wav" )
	self.SNDTurret:SetSoundLevel( 95 )
	self.SNDTurret:SetParent( self, ID )]]

	self:AddTrailerHitch( Vector(-35,0,1), LVS.HITCHTYPE_FEMALE )
end

function ENT:OnCollision( data, physobj )
	if self:WorldToLocal( data.HitPos ).z < 1 then return true end -- dont detect collision  when the lower part of the model touches the ground

	return false
end