function EFFECT:Init(data)
    local pos = data:GetOrigin()

    local dist = 10000
	local distSqr = dist * dist

	if LocalPlayer():GetPos():DistToSqr(pos) > distSqr then return end

	local emitter = ParticleEmitter(pos)

    --[[local flash = emitter:Add("particle/particle_glow_04", pos)
    if flash then
        flash:SetColor(255, 250, 255, 255)
        flash:SetDieTime(1)
        flash:SetStartAlpha(255)
        flash:SetEndAlpha(0)
        flash:SetStartSize(0)
        flash:SetEndSize(300)
        flash:SetRoll(math.Rand(0, 360))
    end]]

    for i = 1, math.Rand(10, 20) do
        local SmokeTargetValue = 30 * math.random(1,2)

        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos)
        if particle then
            particle:SetDieTime(math.Rand(3, 10))
            particle:SetStartAlpha(SmokeTargetValue)
            particle:SetEndAlpha(0)
            particle:SetStartSize(50)
            particle:SetEndSize(math.Rand(100, 300))
            particle:SetColor(255, 255, 255)
            particle:SetGravity(JMod.Wind * 10)
            particle:SetCollide(true)
            particle:SetBounce(1)
            particle:SetAirResistance(2)
            particle:SetVelocity( VectorRand() * 100 )
        end
    end

    for i = 1, math.Rand(10, 20) do
        local SmokeTargetValue = 30 * math.random(1,2)

        local particle = emitter:Add("particle/fire", pos + Vector(math.Rand(-15,15), math.Rand(-15,15), math.Rand(-15,15)))
        if particle then
            particle:SetDieTime(math.Rand(3, 13))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(5, 20))
            particle:SetEndSize(0)
            particle:SetColor(255, 255, 255)
            particle:SetGravity(Vector(0,0,-10))
            particle:SetCollide(true)
            particle:SetBounce(1)
            particle:SetAirResistance(1)
            particle:SetVelocity( Vector(0,0,5) + VectorRand() * 100 )

            --- Vector(math.Rand(-0.5, 0.5), math.Rand(-0.5, 0.5), 1) * 100
        end
    end

    for i = 1, math.Rand(50, 60) do

        local SmokeTargetValue = 30 * math.random(1,2)

        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos)
        if particle then
            particle:SetDieTime(math.Rand(40, 70))
            particle:SetStartAlpha(SmokeTargetValue)
            particle:SetEndAlpha(0)
            particle:SetStartSize(30)
            particle:SetEndSize(math.Rand(500, 600))
            particle:SetColor(255, 255, 255)
            particle:SetGravity(JMod.Wind * Vector(0,0,-10))
            particle:SetCollide(true)
            particle:SetBounce(1)
            particle:SetAirResistance(math.Rand(10,15))
            particle:SetVelocity( VectorRand() * 100 )
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end