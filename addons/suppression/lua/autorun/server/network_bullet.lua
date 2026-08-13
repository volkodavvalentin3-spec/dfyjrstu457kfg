print("[Suppression] Server loaded.")

util.AddNetworkString("suppression_fire_event")

local function writeVectorUncompressed(vector)
    net.WriteFloat(vector.x)
    net.WriteFloat(vector.y)
    net.WriteFloat(vector.z)
end

local function networkGunshotEvent(data)
    timer.Simple(0, function() 
        net.Start("suppression_fire_event", false)
            writeVectorUncompressed(data.Src)
            writeVectorUncompressed(data.Dir)
            net.WriteEntity(data.Entity)
        net.Broadcast()
    end)
end

--[[function arc9_suppression_detour(args)
    local bullet = args[2]
    local attacker = bullet.Attacker
    
    if attacker.suppression_shotThisTick == nil then attacker.suppression_shotThisTick = false end
    if attacker.suppression_shotThisTick then return end
    if table.Count(bullet.Damaged) != 0 or bullet.suppr_detected then return end

    local weapon = bullet.Weapon
    local weaponClass = weapon:GetClass()
    local pos = attacker:GetShootPos()
    local ammotype = bullet.Weapon.Primary.Ammo
    local dir = bullet.Vel:Angle():Forward()
    local vel = bullet.Vel

    timer.Simple(0, function()
        data = {}
        data.Src = pos
        data.Dir = dir
        data.Vel = vel
        data.Spread = Vector(0,0,0)
        data.Ammotype = ammotype
        data.Entity = attacker
        data.Weapon = attacker:GetActiveWeapon()
        networkGunshotEvent(data)
    end)
    
    bullet.suppr_detected = true
    attacker.suppression_shotThisTick = true

    timer.Simple(engine.TickInterval()*2, function() attacker.suppression_shotThisTick = false end)
end]]

--[[hook.Add("InitPostEntity", "suppression_create_physbul_hooks", function()
    if ARC9 then
        function suppr_wrapfunction(a)    -- a = old function
          return function(...)
            local args = { ... }
            arc9_suppression_detour(args)
            return a(...)
          end
        end
        ARC9.SendBullet = suppr_wrapfunction(ARC9.SendBullet)
    end

    if TFA then
        hook.Add("Think", "suppression_detecttfaphys", function()
            local latestPhysBullet = TFA.Ballistics.Bullets["bullet_registry"][table.Count(TFA.Ballistics.Bullets["bullet_registry"])]
            if latestPhysBullet == nil then return end
            if latestPhysBullet["suppr_detected"] then return end

            local weapon = latestPhysBullet["inflictor"]
            local weaponClass = weapon:GetClass()

            local pos = latestPhysBullet["bul"]["Src"]
            local ammotype = weapon.Primary.Ammo
            local dir = latestPhysBullet["velocity"]:Angle():Forward()
            local vel = latestPhysBullet["velocity"]
            local entity = latestPhysBullet["inflictor"]:GetOwner()

            if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
            if entity.suppression_shotThisTick then return end
            entity.suppression_shotThisTick = true
            timer.Simple(engine.TickInterval()*2, function() entity.suppression_shotThisTick = false end)

            data = {}
            data.Src = pos
            data.Dir = dir
            data.Vel = vel
            data.Spread = Vector(0,0,0)
            data.Ammotype = ammotype
            data.Entity = latestPhysBullet["inflictor"]:GetOwner()
            data.Weapon = latestPhysBullet["inflictor"]
            networkGunshotEvent(data)

            latestPhysBullet["suppr_detected"] = true
        end)
    end

    if ArcCW then
        hook.Add("Think", "suppression_detectarccwphys", function()
            if ArcCW.PhysBullets[table.Count(ArcCW.PhysBullets)] == nil then return end
            local latestPhysBullet = ArcCW.PhysBullets[table.Count(ArcCW.PhysBullets)]
            if latestPhysBullet["suppr_detected"] then return end
            if latestPhysBullet["Attacker"] == Entity(0) then return end
            local entity = latestPhysBullet["Attacker"]

            if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
            if entity.suppression_shotThisTick then return end
            entity.suppression_shotThisTick = true
            timer.Simple(engine.TickInterval()*2, function() entity.suppression_shotThisTick = false end)

            local weapon = latestPhysBullet["Weapon"]
            local weaponClass = weapon:GetClass()

            local pos = latestPhysBullet["Pos"]
            local ammotype = weapon.Primary.Ammo
            local dir = latestPhysBullet["Vel"]:Angle():Forward()
            local vel = latestPhysBullet["Vel"]

            data = {}
            data.Src = pos
            data.Dir = dir
            data.Vel = vel
            data.Spread = Vector(0,0,0)
            data.Ammotype = ammotype
            data.Entity = latestPhysBullet["Attacker"]
            data.Weapon = latestPhysBullet["Attacker"]:GetActiveWeapon()
            networkGunshotEvent(data)
            
            latestPhysBullet["suppr_detected"] = true
        end)
    end

    if MW_ATTS then -- global var from mw2019 sweps
        hook.Add("OnEntityCreated", "suppression_detectmw2019phys", function(ent)
            if ent:GetClass() != "mg_sniper_bullet" and ent:GetClass() != "mg_slug" then return end
            timer.Simple(0, function()
                local attacker = ent:GetOwner()
                local entity = attacker
                local weapon = attacker:GetActiveWeapon()
                local pos = ent.LastPos
                local dir = (ent:GetPos() - ent.LastPos):GetNormalized()
                local vel = ent:GetAngles():Forward() * ent.Projectile.Speed
                local ammotype = "none"
                if weapon.Primary and weapon.Primary.Ammo then ammotype = weapon.Primary.Ammo end

                if entity.suppression_shotThisTick == nil then entity.suppression_shotThisTick = false end
                if entity.suppression_shotThisTick then return end
                entity.suppression_shotThisTick = true
                timer.Simple(engine.TickInterval()*2, function() entity.suppression_shotThisTick = false end)

                data = {}
                data.Src = pos
                data.Dir = dir
                data.Vel = vel
                data.Spread = Vector(0,0,0)
                data.Ammotype = ammotype
                data.Entity = attacker
                data.Weapon = attacker:GetActiveWeapon()

                networkGunshotEvent(data)
            end)
        end)
    end

    hook.Remove("InitPostEntity", "suppression_create_physbul_hooks")
end)]]

