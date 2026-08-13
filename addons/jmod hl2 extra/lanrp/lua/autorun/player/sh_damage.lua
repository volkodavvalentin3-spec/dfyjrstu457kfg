PlayerMeta = FindMetaTable("Player")

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

CrazyScream = {
    "LANRP/pain/Screams_Male_1.ogg",
    "LANRP/pain/Screams_Male_3.ogg",
    --"LANRP/pain/male_scream1.ogg",
    --"LANRP/pain/male_scream2.ogg",
    "LANRP/pain/male_cry1.ogg",
    "LANRP/pain/male_cry2.ogg",
    "LANRP/pain/burn/death_burn1.wav",
    "LANRP/pain/burn/death_burn3.wav",
    "LANRP/pain/burn/death_burn7.wav",
    "LANRP/pain/burn/death_burn11.wav",
    "LANRP/pain/burn/death_burn19.wav",
    "LANRP/pain/burn/death_burn30.wav",
    "LANRP/pain/burn/death_burn15.wav",
}

local afterdeath = {
    "LANRP/pain/badlung2.wav",
    "LANRP/pain/badlung2.wav",
    "LANRP/pain/throat.ogg",
}

local HorrorSound = {}

local horrorsound, _ = file.Find( "sound/LANRP/horror/*", "THIRDPARTY" )

for k,v in pairs(horrorsound) do
    table.insert(HorrorSound, "LANRP/horror/" .. v)
end

local HorrorImage = {}

local horrorimagefile, _ = file.Find( "materials/horror/*", "THIRDPARTY" )

for k,v in pairs(horrorimagefile) do
    table.insert(HorrorImage, "horror/" .. v)
end

for i, snd in ipairs(CrazyScream) do
    Sound(snd)
end

for i, snd in ipairs(afterdeath) do
    Sound(snd)
end

function PlayerBrutalDeathSounds(ent, dmg)
    if dmg == DMG_BLAST or DMG_SONIC or DMG_CRUSH then
        ent:EmitSound("LANRP/pain/explode/death_explode"..math.random(1,50)..".wav",140, 100, 1, CHAN_VOICE)
        EmitFarSound(ent:GetPos(), math.random(49,98), 0, 25000, 3000)
    else
        
        if math.random(1,2) == 1 then
            ent:EmitSound("lanrp/pain/bullet/death_bullet" .. math.random(1,49) .. ".wav",140, 100, 1, CHAN_VOICE)
        end
        
        EmitFarSound(ent:GetPos(),math.random(99,147), 0, 25000, 3000)
    end

    timer.Simple(0.5, function()
        if IsValid(ent) and ent:GetVelocity():Length() > 500 then
            ent:EmitSound("LANRP/pain/flying/death_fly"..math.random(1,15)..".wav",140, 100, 1, CHAN_VOICE)
        end
    end)
    

    --[[timer.Simple(math.Rand(1,2), function()
        if not IsValid(ent) then return end

        if math.random(1, 2) == 1 then

            for i = 0, math.random(3, 4) do
                if not IsValid(ent) then break end

                timer.Simple(i, function()
                    ent:EmitSound(table.Random(afterdeath), 75, 100, 1, CHAN_VOICE)
                end)
            end
        end

    end)]]
end

hook.Add( "PostPlayerDeath", "PlayerBrutalDeathSounds", function(ply) 
    local rag = ply.oldragdoll

    if not ply.MutePainSound then
        PlayerBrutalDeathSounds(rag)
    end

    for _, ent in pairs( ents.FindInSphere( ply:GetPos(), 400 ) ) do
        if ent:IsPlayer() and ply ~= ent then
            if ply:GetSquadID() ~= ent:GetSquadID() then
                ent:SetCrazy(ent:GetCrazy() + math.Rand(0.1, 0.15))
            else
                ent:SetCrazy(ent:GetCrazy() + math.Rand(0.2,0.55))
                ent:CrazyEffect()
            end
        end
    end

end)



hook.Add("DoPlayerDeath", "RemoveCrazy", function(ply, attacker, dmg)
    ply.MutePainSound = ply:IsOnFire()

    ply.DeathType = dmg:GetDamageType()

    timer.Remove(ply:EntIndex() .. " Crazy")
end)

hook.Add("DoPlayerDeath", "DropWeapon", function(ply, attacker, dmg)
    if IsValid(ply:GetActiveWeapon()) then 
        if ply:GetActiveWeapon().IsTFAWeapon then
            
            local Wep = ply:GetActiveWeapon()

            local ent = ents.Create("ent_weapondrop")
			local ang = ply:GetAngles()
			ent:SetPos(ply:GetPos() + ang:Forward() * 25 + Vector(0, 0, 50))
			ent:SetAngles(ply:GetAngles())	
			ent:SetModel(Wep:GetModel())
            ent:SetWeaponClass(Wep:GetClass())

            ent.Clip1 = Wep:Clip1()
			ent.Clip2 = Wep:Clip2()

			ent:Spawn()
			ent:GetPhysicsObject():SetVelocity(ply:GetAimVector() * 100)
            ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 50))
			ent:Activate()
        end
    end
end)

local clr_red1, clr_red2 = Color( 255, 0, 0, 255 ), Color( 255, 0, 0, 128 )
hook.Add( "PostEntityTakeDamage", "PainDeathSound", function( ply, dmg )
    

    if ply:IsPlayer() then
        
        if (ply:Health() - dmg:GetDamage()) <= 0 then return end

        if (dmg:GetDamage() >= 12 or dmg:IsBulletDamage()) and dmg:GetDamageType() ~= DMG_BURN then

            ply:SetCrazy(ply:GetCrazy() + dmg:GetDamage() / 100)

            ply:ScreenFade( SCREENFADE.IN, clr_red1, 0.3, 0 )

            if math.random(1, 2) == 1 then
                ply:EmitSound("LANRP/pain/blunt/death_blunt" .. math.random(1, 25) ..".wav", 140, 100, 1, CHAN_VOICE) -- боль

                EmitFarSound(ply:GetPos(),math.random(148, 172), 0, 20000, 3000)
                
            end

            timer.Simple(math.Rand(1,2), function()
                if IsValid(ply) and ply:Alive() then
                    if math.random(1, 15) == 1 then
                        ply:EmitSound("LANRP/pain/fatigue" .. math.random(1, 3) ..".ogg", 100, 100, 1, CHAN_VOICE) -- тремор
                        --EmitFarSound(ply:GetPos(),"LANRP/pain/fatigue" .. math.random(1, 3) ..".ogg", 0, 25000)
                    elseif math.random(1, 30) == 1 then
                        --ply:ScreenFade( SCREENFADE.IN, clr_red2, 1.5, 2.5 )
                        --ply:EmitSound(table.Random(CrazyScream), 140, 100, 1, CHAN_VOICE)
                        --EmitFarSound(ply:GetPos(),table.Random(CrazyScream), 0, 25000, 3000)
                        ply:SetCrazy(ply:GetCrazy() + 0.5)
                    end
                end
            end)
        end


        if dmg:IsExplosionDamage() then

            ply:SetCrazy(ply:GetCrazy() + 0.3)

            if math.random(1, 10) == 1 then
                --ply:ScreenFade( SCREENFADE.IN, clr_red2, 1.5, 2.5 )
                ply:EmitSound(table.Random(CrazyScream), 140, 100, 1, CHAN_VOICE)
                ply:SetCrazy(ply:GetCrazy() + 0.5)
            end
        end

        if not ply.FireScream or ply.FireScream <= CurTime() then
            --if dmg:GetDamageType() == DMG_BURN then
                if ply:IsOnFire() then

                    ply:SetCrazy(ply:GetCrazy() + math.Rand(0.3, 0.4))

                    ply:EmitSound("LANRP/pain/agony_male" .. math.random(1, 10) ..".ogg", 140, 100, 1, CHAN_AUTO) -- огонь
                    ply.FireScream = CurTime() + 7
                end
            --end
        end
    end
end )


--CRAZY
if SERVER then
    util.AddNetworkString("CrazyEffect")
end

function PlayerMeta:SetCrazy(value)
    if (self:InVehicle() or self:GetColor().a == 0 ) and (self:GetCrazy() < value) then return end

    self:SetLocalVar("Crazy", math.Clamp(value, 0, 1))
end

function PlayerMeta:GetCrazy()
    if SERVER then
        return self:GetLocalVar("Crazy")
    else
        return LocalCrazy
    end 
end

function PlayerMeta:CrazyEffect()
    if not self:InVehicle() or self:GetColor().a == 0 then

        --
        if SERVER then
            net.Start("CrazyEffect")
            net.Send(self)
       -- else
        --    ClientCrazyEffect()
        end

        if SERVER then
            if math.random(1, 10) == 1 then
                --ply:ScreenFade( SCREENFADE.IN, clr_red2, 1.5, 2.5 )
                self:EmitSound(table.Random(CrazyScream), 140, 100, 1, CHAN_VOICE)
                EmitFarSound(self:GetPos(),math.random(38, 48), 0, 25000, 3000)
                --ply:SetCrazy(ply:GetCrazy() + 0.5)
            end
        end
    end
end

hook.Add("PlayerSpawn", "CrazyValue", function(ply)
    ply:SetCrazy(0)

    --[[timer.Create(ply:EntIndex() .. " Crazy", 1, 0, function()
        if ply:GetCrazy() == 0 then return end
        
        ply:SetCrazy(ply:GetCrazy() - 0.1)

            if math.random(1,6) == 1 and ply:GetCrazy() >= 0.5 then
                if math.random(1, 10) == 1 then
                --ply:ScreenFade( SCREENFADE.IN, clr_red2, 1.5, 2.5 )
                    --ply:EmitSound(table.Random(CrazyScream), 140, 100, 1, CHAN_VOICE)
                    --EmitFarSound(ply:GetPos(),math.random(38, 48), 0, 25000, 3000)
                --ply:SetCrazy(ply:GetCrazy() + 0.5)
                end

            end
        --end
    end)]]
end)

if CLIENT then
    local images = {}
    local selectedimage = 1
    local imagealpha = 0

    local bluramount = 0

    local bright = 0
    local cont = 1
    local mulr = 0
    local sharp = 0
    local shake = 0

    LocalCrazy = 0

    local ScreenHorrorImage = table.Random(HorrorImage)

    local Lerp = Lerp

    hook.Add("PlayerSpawn", "CrazyValue", function(ply)
        images = {}
        selectedimage = 1
        imagealpha = 0
    
        bluramount = 0
    
        bright = 0
        cont = 1
        mulr = 0
        sharp = 0
    
        curserandom = 3

        LocalCrazy = 0
    end)

    function ClientCrazyEffect()
        bright = -1

        timer.Simple(math.Rand(0,1.5), function()
            surface.PlaySound( table.Random(HorrorSound) )

            if math.random(1, 3) == 1 then
                timer.Simple(math.Rand(0,1.5), function()
                    surface.PlaySound( table.Random(HorrorSound) )
                end)
            end
        end)
        
        imagealpha = 255

        shake = 100

        ScreenHorrorImage = table.Random(HorrorImage)

        --ViewPunch( Angle( math.random(-10,10), math.random(-10,10), math.random(-10,10) ) )

        for i = 0, 5 do
            if i >= 1 then
                ViewPunch( Angle( math.random(-5,5), math.random(-5,5), math.random(-5,5) ) )

                timer.Simple(i / 10, function()
                    ViewPunch( Angle( math.random(-1,1), math.random(-1,1), math.random(-1,1) ) )
                end)
            end 
        end
    end

    net.Receive("CrazyEffect", function(len, ply)
        --local cursed = math.random(1,curserandom)
        --local cursed2 = math.random(1,curserandom)
        
        bright = -1

        timer.Simple(math.Rand(0,1.5), function()
            surface.PlaySound( table.Random(HorrorSound) )

            if math.random(1, 3) == 1 then
                timer.Simple(math.Rand(0,1.5), function()
                    surface.PlaySound( table.Random(HorrorSound) )
                end)
            end
        end)
        
        imagealpha = 255

        shake = 100

        ScreenHorrorImage = table.Random(HorrorImage)

        --ViewPunch( Angle( math.random(-10,10), math.random(-10,10), math.random(-10,10) ) )

        for i = 0, 5 do
            if i >= 1 then
                ViewPunch( Angle( math.random(-5,5), math.random(-5,5), math.random(-5,5) ) )

                timer.Simple(i / 10, function()
                    ViewPunch( Angle( math.random(-1,1), math.random(-1,1), math.random(-1,1) ) )
                end)
            end 
        end
    end)


    
    hook.Add("Think", "CrazyCalc", function()
        local ply = LocalPlayer()
        if ply:GetCrazy() == nil then return end

        LocalCrazy = math.Clamp(LocalCrazy, 0, 1)

        LocalCrazy = LocalCrazy - 0.002

        cont = Lerp(FrameTime(), cont, LocalCrazy * 2 + 1)
        bluramount = Lerp(FrameTime() / 1, bluramount, LocalCrazy > 0.5 and LocalCrazy * 80 or LocalCrazy * 150)
        sharp = Lerp(FrameTime(), sharp, LocalCrazy * 5)
        mulr = Lerp(FrameTime(), mulr, LocalCrazy > 0.5 and LocalCrazy * 2 or 0)
        bright = math.max(Lerp(FrameTime() * 10, bright, LocalCrazy * -0.5), -0.37)

        shake = Lerp(FrameTime() / 2, shake, 0)

        if LocalCrazy >= 0.5 then
            ply:SetDSP( 26, false )
        else
            ply:SetDSP( 1, false )
        end

        if math.random(1,600) == 1 and LocalCrazy >= 0.5 then
            --ply:CrazyEffect()
            ClientCrazyEffect()
            --ply:ChatPrint("gavno")
        end
    end)

    hook.Add("HUDPaint", "CrazyImage", function()
        surface.SetDrawColor(255,255,255,imagealpha)
        surface.SetMaterial(Material(ScreenHorrorImage, "noclamp smooth"))
        surface.DrawTexturedRect(0,0,ScrW(),ScrH())
        --surface.DrawTexturedRect((0.5+math.cos(CurTime()*2)/2)*800,(0.5+math.sin(CurTime())/2)*350,(0.5+math.sin(CurTime()*2)/2)*800,(0.5+math.cos(CurTime()*2)/2)*800) --used for testing
    end)

    hook.Add("RenderScreenspaceEffects", "CrazyColor", function()
        local ft = RealFrameTime()
        local Lerp = Lerp

        --[[bluramount = Lerp(ft/10, bluramount, 0)
        cont = Lerp(ft/10, cont, 1)
        bright = Lerp(ft/10, bright, 0)
        mulr = Lerp(ft/10, mulr,0 or 30)
        sharp = Lerp(ft/20, sharp, 0)]]

        imagealpha = Lerp(ft*2, imagealpha, 0)

        DrawMotionBlur(0.01,bluramount/100,0)
        DrawColorModify({
            [ "$pp_colour_brightness" ] = bright,
            [ "$pp_colour_contrast" ] = cont,
            [ "$pp_colour_colour" ] = 1,
            [ "$pp_colour_mulr" ] = mulr
        })
        DrawSharpen(sharp, sharp)
    end)


    --[[/ y value
    phase -= frequency * deltaTime;
    y = Math.sin(phase) * amplitude;

    // x value
    waveSpeed = frequency * wavelength * deltaTime;
    x -= waveSpeed; // do this for each point in your wave line to shift the wave left]]
    
    --local NewFov = LocalPlayer():GetFOV()

    hook.Add( "CalcView", "CrazyView", function( ply, pos, angles, fov )
        if ply:Alive() then
            local Crazy = (ply:GetCrazy() or 0) * 1000
            local pulse = math.Rand(-shake, shake)
            local NewAngle = angles

            --if ply:GetCrazy() > 0.5 then
                --NewAngle.r = pulse
            --else
                NewAngle = Lerp(FrameTime() / 2, angles, angles + Angle(pulse,pulse,pulse))
            --end

            --print(NewAngle.r, pulse)

            local view = {
                origin = pos,
                angles = NewAngle,
                fov = fov,
            }
        
            return view
        end
    end )
end