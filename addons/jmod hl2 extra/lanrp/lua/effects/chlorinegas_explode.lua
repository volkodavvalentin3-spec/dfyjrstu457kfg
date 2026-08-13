function EFFECT:Init(data)
    local pos = data:GetOrigin()

    local dist = 10000
	local distSqr = dist * dist

	if LocalPlayer():GetPos():DistToSqr(pos) > distSqr then return end

	local emitter = ParticleEmitter(pos)

    --[[for i = 1, math.Rand(10, 20) do
        local SmokeTargetValue = 30 * math.random(1,2)

        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos)
        if particle then
            particle:SetDieTime(math.Rand(3, 10))
            particle:SetStartAlpha(SmokeTargetValue)
            particle:SetEndAlpha(0)
            particle:SetStartSize(50)
            particle:SetEndSize(math.Rand(100, 300))
            particle:SetColor(math.random(225,235),255,math.random(80,90))
            particle:SetGravity(JMod.Wind * 10)
            particle:SetCollide(true)
            particle:SetBounce(1)
            particle:SetAirResistance(2)
            particle:SetVelocity( VectorRand() * 130 )
        end
    end]]

    for i = 1, math.Rand(50, 60) do

        local SmokeTargetValue = 30 * math.random(1,2)

        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos)
        if particle then
            particle:SetDieTime(math.Rand(40, 70))
            particle:SetStartAlpha(SmokeTargetValue)
            particle:SetEndAlpha(0)
            particle:SetStartSize(70)
            particle:SetEndSize(math.Rand(500, 600))
            particle:SetColor(math.random(225,235),255,math.random(80,90))
            particle:SetGravity(JMod.Wind * Vector(0,0,-50))
            particle:SetCollide(true)
            particle:SetBounce(1)
            particle:SetAirResistance(math.Rand(25,30))
            particle:SetVelocity( VectorRand() * 130 )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end