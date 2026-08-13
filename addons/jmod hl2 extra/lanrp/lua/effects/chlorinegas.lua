function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local size = data:GetScale()

    local dist = 10000
	local distSqr = dist * dist

	if LocalPlayer():GetPos():DistToSqr(pos) > distSqr then return end

	local emitter = ParticleEmitter(pos)

    for i = 1, (math.Rand(2, 10) * size) do
        local smokeIntensity = Lerp

        local SmokeTargetValue = 30 * math.random(1,2)

        local Range = 300 * size
        local StartPos = pos + Vector(math.random(-Range, Range), math.random(-Range, Range), math.random(0, Range/2))
	    local DownTr = util.TraceLine({
	    	start = StartPos,
	    	endpos = StartPos - Vector(0, 0, Range * 2),
	    })

        pos = DownTr.HitPos

        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos + Vector(0,0,math.random(5,10)))
        if particle then
            particle:SetDieTime(math.Rand(15, 30)) -- Долгий "туман"
            particle:SetStartAlpha(SmokeTargetValue)
            particle:SetEndAlpha(0)
            particle:SetStartSize(0)
            particle:SetEndSize(math.Rand(300, 350))
            particle:SetColor(math.random(225,235),255,math.random(80,90))
            particle:SetGravity(JMod.Wind * 5 + VectorRand() * 1.5) -- Медленно поднимается
            particle:SetCollide(true)
            particle:SetBounce(1)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--no
