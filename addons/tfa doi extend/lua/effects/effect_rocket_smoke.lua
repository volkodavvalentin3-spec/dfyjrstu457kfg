function EFFECT:Init( data )
self.Emitter = ParticleEmitter( data:GetOrigin() )
local particle = self.Emitter:Add( "particle/particle_smokegrenade1", data:GetOrigin() )
particle:SetDieTime( 3 )
particle:SetStartAlpha( 150 )
particle:SetEndAlpha( 0 )
particle:SetStartSize( 32 )
particle:SetEndSize( 16 )
particle:SetVelocity( Vector( 0, 0, 50 ) )
particle:SetRoll( math.Rand( 0, 360 ) )
particle:SetColor( 50, 50, 50 )
particle:SetCollide( true )
particle:SetBounce( 1 )
end

function EFFECT:Render()
end