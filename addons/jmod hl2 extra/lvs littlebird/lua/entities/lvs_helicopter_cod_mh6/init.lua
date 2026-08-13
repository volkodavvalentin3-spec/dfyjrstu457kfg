AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(26.898,14.85,-62.513), Angle(0,-90,9.768) )
	DriverSeat:SetCameraDistance( -0.3 )
	DriverSeat:SetCameraHeight( -0.05 )
	
	self:SetSkin(math.random(0,4))
	self:SetBodygroup(1,1)
	
	local PassengerSeats = {
	    {
			pos = Vector(26.898,-15.423,-62.513),
			ang = Angle(0,-90,9.768)		
		},
		{
			pos = Vector(26.206,43.538,-81.022),
			ang = Angle(0,4.717,0)
		},
		{
			pos = Vector(2.621,42.956,-81.022),
			ang = Angle(0,4.717,0)
		},
		{
			pos = Vector(-20.579,41.377,-81.022),
			ang = Angle(0,4.717,0)
		},
		{
			pos = Vector(26.206,-43.538,-81.022),
			ang = Angle(0,176,0)
		},
		{
			pos = Vector(2.621,-42.956,-81.022),
			ang = Angle(0,176,0)
		},
		{
			pos = Vector(-20.579,-41.377,-81.022),
			ang = Angle(0,176,0)
		}
	}
		for num, v in pairs( PassengerSeats ) do
		local Pod = self:AddPassengerSeat( v.pos, v.ang )

	
	end

	self:AddEngineSound( Vector(0,0,0) )

	--self:AddRotor( pos, angle, radius, turn_speed_and_direction )
	self.Rotor = self:AddRotor( Vector(0,0,-2), Angle(0,0,0), 170, -400 )
	self.Rotor:SetHP( 30 )
	
	self.TailRotor = self:AddRotor( Vector( -188.762, 12.433, -39.754 ), Angle( 0, 0, 90 ), 35, 0 )
    self.TailRotor:SetHP( 30 )
    function self.TailRotor:OnDestroyed( rotor )
        local id = rotor:LookupBone( "Tail Rotor" )
        rotor:ManipulateBoneScale( id, Vector( 0, 0, 0 ) )
        rotor:EmitSound( "physics/metal/metal_box_break2.wav" )
        rotor:DestroySteering( -2.5 )
    end
	
	self:AddDS( {
    pos = Vector(-30,0,-40),
    ang = Angle(0,0,0),
    mins = Vector(-40,-20,-30),
    maxs =  Vector(10,20,30),
    Callback = function( tbl, ent, dmginfo )
     dmginfo:ScaleDamage( 3 )
    end
} )
	
	self:AddDSArmor( {
    pos = Vector(-10,0,-40),
    ang = Angle(0,0,0),
    mins = Vector(-10,-30,-40),
    maxs =  Vector(0,30,30),
    Callback = function( tbl, ent, dmginfo )
    end
} )
	
	function self.Rotor:OnDestroyed( base )
		base:SetBodygroup( 3, 2 )
		base:DestroyEngine()
		
		self:EmitSound( "lvs_custom/shared/heli_break.wav" )
		self:EmitSound( "physics/metal/metal_box_break2.wav" )
	end

end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )
    return pos, angles, fov
end

function ENT:SetRotor( PhysRot )
	self:SetBodygroup( 3, PhysRot and 0 or 1 ) 
end

function ENT:GetMissileOffset()
	return Vector(-60,0,0)
end

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs_custom/shared/light_heli_start.wav" )
		else
		self:EmitSound( "lvs_custom/shared/heli_shutdown.wav" )
	end
end

function ENT:OnTick()
	local PhysRot = self:GetThrottle() < 0.95

	if not self:IsEngineDestroyed() then
		self:SetRotor( PhysRot )
	end
end

function ENT:OnCollision( data, physobj )
	if self:IsPlayerHolding() then return false end

	if data.Speed > 60 and data.DeltaTime > 0.2 then
		local VelDif = data.OurOldVelocity:Length() - data.OurNewVelocity:Length()

		if VelDif > 200 then
			local part = self:FindDS( data.HitPos - data.OurOldVelocity:GetNormalized() * 25 )

			if part then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 1000 )
				dmginfo:SetDamageType( DMG_CRUSH )
				part:Callback( self, dmginfo )
			end
		end
	end

	return false
end
