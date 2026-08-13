local particleCount = 25
local sparkCount = 50
local smokeCount = 20

-- Визуальные параметры
local metalColors = {
    Color(150, 150, 150),
    Color(120, 120, 120),
    Color(180, 160, 140)
}

-- 1. Металлические обломки
local debrisModels = {
    "models/props_junk/vent001_chunk4.mdl",
    "models/props_junk/vent001_chunk8.mdl",
    "models/props_junk/vent001_chunk6.mdl",
    "models/props_c17/canisterchunk01b.mdl",
    "models/props_c17/canisterchunk01c.mdl",
    "models/props_c17/canisterchunk01f.mdl",
    "models/props_c17/canisterchunk01g.mdl",
    "models/props_c17/canisterchunk01h.mdl",
    "models/props_c17/canisterchunk01k.mdl",
    "models/props_c17/oildrumchunk01a.mdl",
    "models/props_c17/oildrumchunk01b.mdl",
    "models/props_c17/oildrumchunk01c.mdl",
    "models/props_c17/oildrumchunk01d.mdl",
    "models/props_c17/oildrumchunk01e.mdl",
    "models/props_debris/metal_panelshard01b.mdl",
    "models/props_debris/metal_panelshard01d.mdl"
}

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal()
    local emitter = ParticleEmitter(pos)
    
    -- 1. Создаем физические обломки (клиентсайд-пропы)
    for i = 1, particleCount do
        local debris = ClientsideModel(debrisModels[math.random(1, #debrisModels)], RENDERGROUP_OPAQUE)
        if IsValid(debris) then
            debris:SetPos(pos + normal * 5)
            debris:SetModelScale(math.Rand(0.2, 0.5), 0)
            debris:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

            -- Физические свойства (имитация физики)
            local phys = debris:GetPhysicsObject()
            if not IsValid(phys) then
                debris:PhysicsInit(SOLID_VPHYSICS)
                phys = debris:GetPhysicsObject()
            end
            
            if IsValid(phys) then
                phys:SetMaterial("metal")
                phys:SetVelocity(normal * math.Rand(100, 200) + VectorRand() * 150 + Vector(0,0,250))
                phys:AddAngleVelocity(VectorRand() * 300)
                phys:EnableGravity(true)
                phys:SetDamping(0.1, 5)
            end
            
            -- Удаление через время
            timer.Simple(math.Rand(5, 10), function()
                if IsValid(debris) then debris:Remove() end
            end)
        end
    end
        
    -- Основная вспышка
    for i=1, 3 do
        local flash = emitter:Add("effects/muzzleflash"..math.random(1,4), pos)
        if flash then
            flash:SetDieTime(0.5)
            flash:SetStartAlpha(255)
            flash:SetEndAlpha(0)
            flash:SetStartSize(150)
            flash:SetEndSize(0)
            flash:SetColor(255, 200, 150)
            flash:SetLighting(false)
        end
    end

    -- Быстро исчезающие искры
    for i=1, 12 do
        local spark = emitter:Add("effects/spark", pos)
        if spark then
            spark:SetVelocity(VectorRand() * 400 + Vector(0,0,100))
            spark:SetDieTime(math.Rand(0.3, 0.6))
            spark:SetStartSize(3)
            spark:SetEndSize(0)
            spark:SetColor(255, 200, 100)
            spark:SetGravity(Vector(0,0,-600))
            spark:SetCollide(true)
            spark:SetBounce(0.3)
        end
    end

    for i=1, 12 do
        local debris = emitter:Add("effects/lvs_base/particle_debris_0" .. math.random(1,2), pos)
        if debris then
            debris:SetVelocity(normal * math.Rand(50, 100) + VectorRand() * 100 + Vector(0,0,100))
            debris:SetDieTime(1)
            debris:SetStartSize(30)
            debris:SetEndSize(100)
            --debris:SetColor(255, 200, 100)
            debris:SetGravity(Vector(0,0,-50))
            debris:SetCollide(true)
            debris:SetBounce(0.3)
        end
    end
    
    -- 2. Искры
    for i = 1, sparkCount do
        local particle = emitter:Add("effects/scotchmuzzleflash4", pos)
        if particle then
            particle:SetVelocity(normal * 200 + VectorRand() * 150)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            
            particle:SetAngles( Angle(0,0, math.random(0, 360)) )
            particle:SetStartSize(math.Rand(2, 3))
            particle:SetEndSize(0)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetColor(255, 200, 100)
            
            particle:SetGravity(Vector(0, 0, -200))
            particle:SetAirResistance(30)
            particle:SetCollide(true)
            particle:SetBounce(0.5)
        end
    end
    
    -- 3. Дым
    for i = 1, smokeCount do
        local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), pos)
        if particle then
            particle:SetVelocity(normal * 50 + VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2.0, 4.0))
            
            particle:SetStartSize(math.Rand(10, 20))
            particle:SetEndSize(math.Rand(30, 50))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            
            local dark = math.random(30, 70)
            particle:SetColor(dark, dark, dark)
            
            particle:SetGravity(Vector(0, 0, 50))
            particle:SetAirResistance(30)
            particle:SetCollide(true)
        end
    end
    
    -- 4. Вспышка при попадании
    local flash = emitter:Add("effects/muzzleflash"..math.random(1,4), pos)
    if flash then
        flash:SetVelocity(normal * 10)
        flash:SetLifeTime(0)
        flash:SetDieTime(0.1)
        flash:SetStartAlpha(255)
        flash:SetEndAlpha(0)
        flash:SetStartSize(30)
        flash:SetEndSize(10)
        flash:SetColor(255, 200, 150)
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return false  -- Эффект одноразовый, не нужно обновлять
end

function EFFECT:Render()
    -- Ничего не рендерим отдельно, все через частицы
end



