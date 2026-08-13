function EFFECT:Init(data)
    local pos = data:GetOrigin()

	local emitter = ParticleEmitter(pos)

    local particle = emitter:Add("particle/smokesprites_000"..math.random(1,3), pos + Vector(0,0,math.random(5,10)))
    if particle then
        particle:SetDieTime(math.Rand(15, 30)) -- Долгий "туман"
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(300)
        particle:SetEndSize(math.Rand(300, 350))
        particle:SetColor(255, 255, 255) -- Серо-коричневый
        particle:SetGravity(VectorRand() * 2) -- Медленно поднимается
        particle:SetCollide(true)
        particle:SetBounce(1)
    end

    emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
