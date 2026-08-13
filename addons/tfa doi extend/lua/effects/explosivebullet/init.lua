function EFFECT:Init(data)
	self.Pos 		= data:GetOrigin()		// Origin determines the global position of the effect			//
	self.Scale 		= data:GetScale()		// Scale determines how large the effect is				//
	self.Normal 		= data:GetNormal()		// Normal determines the direction of impact for the effect				//
	self.Emitter 		= ParticleEmitter( self.Pos )	// Emitter must be there so you don't get an error			//

	for i=1,6 do 
	local flashfx = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.Pos )
		if (flashfx) then
			flashfx:SetVelocity( self.Normal*80 + VectorRand()*50 )
			flashfx:SetAirResistance( 250 )
			flashfx:SetDieTime( 0.2 )
			flashfx:SetStartAlpha( 255 )
			flashfx:SetEndAlpha( 0 )
			flashfx:SetStartSize( self.Scale*300 )
			flashfx:SetEndSize( 0 )
			flashfx:SetRoll( math.Rand(-180,180) )
			flashfx:SetRollDelta( math.Rand(-2,2) )
			flashfx:SetColor(255,255,255)	
		end
	end
end

 

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end