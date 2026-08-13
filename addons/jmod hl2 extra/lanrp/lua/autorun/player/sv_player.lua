local ply_meta = FindMetaTable("Player")

--[[local OLD_entscreate = ents.Create
function ents.Create(class)
    debug.Trace()
    return OLD_entscreate(class)
end]]

--[[hook.Add("DoPlayerDeath", "DROP", function(ply, attacker, dmg )
    ply.droped = {}

    for _, wep in ipairs( ply:GetWeapons() ) do
        if not ply.droped[wep] then
            
            if wep:GetClass() == "wep_jack_gmod_hands" then continue end

            print(wep)
            ply.droped[wep] = true
            ply:DropWeapon(wep)
        end
    end
end)]]


hook.Add( "GetFallDamage", "MagicFly", function( ply, speed )
    print( ply:GetActiveWeapon():GetClass(), ply)
	if ply:GetActiveWeapon():GetClass() == "magic_flight" then return 0 end
end )

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

util.AddNetworkString("lanrp.getBaseName")
util.AddNetworkString("lanrp.setBaseName")
util.AddNetworkString("lanrp.ChatPrint")

function ply_meta:LanRPChatPrint(...)
    net.Start("lanrp.ChatPrint")
        net.WriteTable({...})
    net.Send(self)
end

clr_red = Color(200, 0, 0)
net.Receive("lanrp.getBaseName", function(_, ply)
    local ent = net.ReadEntity()

    if IsValid(ent) then
        ply.Dead = false
        ply:Spawn()

        local base = BaseSpawnPlayer(ply, ent, true)
        if not base then 
            BetterChatPrint(ply, "Точка не дееспособна!", clr_red) 
            
            local squad = SquadMenu:GetSquad(ply:GetSquadID())

            for k,v in pairs(squad.SpawnsBase) do
                if k:GetCapital() then
                    local r = k:SpawnPlayer(ply, true)

                    if not r then 
                        BetterChatPrint(ply, "Точка не дееспособна!", clr_red) 
                    end
                end
            end
        
        end
    else
        ply.Dead = false
        ply:Spawn() 
    end
end)

hook.Add("PlayerDisconnected", "LeaveBalance", function(ply)
    ply:Kill()
end)

local vec_clr = Vector(1, 1, 1)
hook.Add("DoPlayerDeath", "FADEDEATH", function(ply, attacker, dmg )
    ply.Dead = true
    ply:ScreenFade( SCREENFADE.OUT, color_black, 2, 5 )

    local squad = SquadMenu:GetSquad(ply:GetSquadID())

    local AllSpawns = {}

    if ply:GetSquadID() != -1 then
        AllSpawns = table.Copy(squad.SpawnsBase)

        if table.Count(squad.Alliance) > 0 then

            for k,v in pairs(squad.Alliance) do
                local AllianceSquad = SquadMenu:GetSquad(k)
    
                table.Merge(AllSpawns, AllianceSquad.SpawnsBase)
            end
        end

        for k,v in pairs(AllSpawns) do
			if not IsValid(k) then
				AllSpawns[k] = nil
			end
		end
    end
    
    timer.Simple(5, function()
        if not IsValid(ply) then return end
        
        if ply:GetSquadID() == -1 or table.Count(AllSpawns) <= 0 then
            ply.Dead = false
            ply:Spawn()
        else
            local count = table.Count(AllSpawns)

            if count == 1 then
                local base
                
                for k, v in pairs(AllSpawns) do
                    base = k
                    break
                end

                ply.Dead = false
                ply:Spawn()

                if IsValid(base) then
                    local r = BaseSpawnPlayer(ply, base, true)
                    if not r then BetterChatPrint(ply, "база не в дееспособном состоянии!", clr_red) end
                end
            else
                net.Start("lanrp.getBaseName")
                net.WriteTable(AllSpawns)
                net.Send(ply)
            end
        end

        if ply:GetSquadID() == -1 then
            ply:SetPlayerColor(vec_clr)
        else
            ply:SetPlayerColor(Vector( squad.r / 255, squad.g / 255, squad.b / 255 ))
        end
    end)
end)

hook.Add("PlayerDeathThink", "FADEDEATHThink", function(ply)
    if ply.Dead then
        return false
    end
end)

JMOD_DROP_ENT = {}
JMOD_WEP_ENT = {}
DROP_BLACK_LIST = {}
DONT_PICKUP_ENT = {}

for k, v in pairs(JMod.WeaponTable) do
    JMOD_WEP_ENT[v.swep] = v.ent
end

JMOD_WEP_ENT["wep_jack_gmod_eztoolbox"] = "ent_jack_gmod_eztoolbox"
JMOD_WEP_ENT["wep_jack_gmod_ezaxe"] = "ent_jack_gmod_ezaxe"
JMOD_WEP_ENT["wep_jack_gmod_ezpickaxe"] = "ent_jack_gmod_ezpickaxe"
JMOD_WEP_ENT["wep_jack_gmod_ezshovel"] = "ent_jack_gmod_ezshovel"
JMOD_WEP_ENT["wep_jack_gmod_ezbucket"] = "ent_jack_gmod_ezbucket"
JMOD_WEP_ENT["wep_jack_gmod_ezmedkit"] = "ent_jack_gmod_ezmedkit"

JMOD_WEP_ENT["wep_lanrp_jmod_kar98k"] = "ent_lanrp_jmod_kar98k"

DROP_BLACK_LIST["wep_jack_gmod_hands"] = true
DROP_BLACK_LIST["wep_jack_gmod_ezflamethrower"] = true
DROP_BLACK_LIST["builder"] = true
DROP_BLACK_LIST["gmod_camera"] = true
DROP_BLACK_LIST["gmod_camera"] = true

DROP_BLACK_LIST["magic_shield"] = true
DROP_BLACK_LIST["magic_zombie"] = true
DROP_BLACK_LIST["magic_popcorn"] = true
DROP_BLACK_LIST["magic_flight"] = true
DROP_BLACK_LIST["light"] = true
DROP_BLACK_LIST["cloack"] = true
DROP_BLACK_LIST["healbeam"] = true






JMOD_DROP_ENT["weapon_physgun"] = true
JMOD_DROP_ENT["weapon_trenchwhistle"] = true
JMOD_DROP_ENT["binocle"] = true
JMOD_DROP_ENT["weapon_lvsrepair"] = true
JMOD_DROP_ENT["radiophone"] = true

DONT_PICKUP_ENT["radiophone"] = true

local UniqAmmoCheck = {
    [43] = true,
    [39] = true,
    --[55] = true,
}

local UniqAmmo = {
    [43] = "ent_jack_gmod_ezammobox_bppc",
    [39] = "ent_jack_gmod_ezmunitions",
    --[55] = "ent_jack_gmod_ezmunitions",
}


util.AddNetworkString( "PlayLocalSound" )

function ply_meta:PlayLocalSound(soundpath)
    net.Start("PlayLocalSound")
    net.WriteString(soundpath)
    net.Send(self)
end

local function SquadRagdollUse(ply, ent)
    if not ent.Squad then return end

    local EntSquad = SquadMenu:GetSquad( ent.Squad.id )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    if MySquad == nil then return end
    if EntSquad == nil then return end

    if not ent.EzWarUse and not MySquad.SquadsInWar[ent.Squad.id] and (ent.ExamineTime <= CurTime()) then
        BetterChatPrint(ply, "Вы осмотрели жетон", color_white)
        ply:LanRPChatPrint(color_white, "Фракция - ", Color(EntSquad.r,EntSquad.g,EntSquad.b), ent.Squad.name)
        --BetterChatPrint(ply, "Фракция - " .. ent.Squad.name, color_white)
        BetterChatPrint(ply, ent.Owner:Nick(), color_white)

        ent.ExamineTime = CurTime() + 2
        return
    end

    if MySquad.SquadsInWar != nil and MySquad.SquadsInWar[ent.Squad.id] and not ent.EzWarUse then
        BetterChatPrint(ply, "Вы забрали жетон", color_white)
        ply:LanRPChatPrint(color_white, "Фракция - ", Color(EntSquad.r,EntSquad.g,EntSquad.b), ent.Squad.name)
        --BetterChatPrint(ply, "Фракция - " .. ent.Squad.name, color_white)
        BetterChatPrint(ply, ent.Owner:Nick(), color_white)

        local Leader = player.GetBySteamID( MySquad.leaderId )

        EntSquad:AddHealth(-1)

        if EntSquad:GetHealth() <= 0 then
            GAMEMODE:SetJBux(Leader, GAMEMODE:GetJBux(Leader) + GAMEMODE:GetJBux(ent.Owner) / 2)
        end

        --print(EntSquad:GetHealth())
        if not table.IsEmpty(EntSquad.Alliance) then
            for k,v in pairs(EntSquad.Alliance) do
                SquadMenu:GetSquad(k):AddHealth(-1)

                if SquadMenu:GetSquad(k):GetHealth() <= 0 then
                    GAMEMODE:SetJBux(Leader, GAMEMODE:GetJBux(Leader) + GAMEMODE:GetJBux(player.GetBySteamID( SquadMenu:GetSquad(k).leaderId )) / 2)
                end
            end
        end

        ent.EzWarUse = true
    end
end

hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
    if not ply:IsSuperAdmin() then
        return false
    end
end )

hook.Add("PlayerUse", "RagdollUse", function(ply, ent)
    if ent:GetClass() == "prop_ragdoll" then
        if ply:GetActiveWeapon():GetClass() == "wep_jack_gmod_hands" and ply:KeyDown(IN_ATTACK2) and ent.EZragdoll then
            
            SquadRagdollUse(ply, ent)
            
            if ent.EzUse then return end
            
            for k,v in pairs(ent.wepinv.Weapons) do
                if DROP_BLACK_LIST[v.Class] then continue end

                local classent = v.Class

                if string.StartsWith(v.Class, "wep_jack") or string.StartsWith(v.Class, "wep_lanrp") then
                    
                    classent = JMOD_WEP_ENT[v.Class]
                end
                if v.Class and (JMOD_DROP_ENT[v.Class] and not DONT_PICKUP_ENT[v.Class]) or weapons.Get(v.Class).IsTFAWeapon then
                    local wep = ents.Create("ent_weapondrop")
                    wep:SetModel(v.Model)
                    wep:SetPos(ent:GetPos() + Vector(0,0,10))
                    wep:SetAngles(VectorRand():Angle())
                    wep:Spawn()
                    wep:SetWeaponClass(v.Class)

                    wep:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 100))
                elseif v.Class and not DONT_PICKUP_ENT[v.Class] then
                    local wep = ents.Create(classent)
                    wep:SetPos(ent:GetPos() + Vector(0,0,10))
                    wep:SetAngles(VectorRand():Angle())
                    wep:Spawn()
                    
                    wep.MagRounds = v.Clip1
                    --wep:SetClip2( v.Clip2 )

                    --[[if v.Class == "wep_jack_gmod_eztoolbox" then
                        if v.Electricity >= 0 then
                            wep:SetElectricity(v.Electricity)
                        end
                    end]]

                    if v.Class == "weapon_lvsrepair" then
                        if v.Gas >= 0 then
                            wep:SetGas(v.Gas)
                        end
                    end

                    if IsValid(wep:GetPhysicsObject()) then
                        wep:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 100))
                    end
                end
            end

            GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ent.Money)

            local ammocount = 0

            local largeammocount = 0

            local MyAmmo = {}

            for k,v in pairs(ent.wepinv.Ammo) do
                if UniqAmmoCheck[k] and UniqAmmo[k] == "ent_jack_gmod_ezammobox_bppc" then
                    local uniqammoent = ents.Create(UniqAmmo[k])

                    uniqammoent:SetPos(ent:GetPos() + Vector(0,0,20))
                    uniqammoent:SetAngles(VectorRand():Angle())
                    uniqammoent:Spawn()

                    uniqammoent:SetCount(v)
                    uniqammoent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 100))
                elseif UniqAmmoCheck[k] then
                    largeammocount = largeammocount + v
                else
                    ammocount = ammocount + v
                end

                
                table.remove(ent.wepinv.Ammo, k)
            end

            if ammocount > 1 then
                local ammoent = ents.Create("ent_jack_gmod_ezammo")

                ammoent:SetPos(ent:GetPos() + Vector(0,0,20))
                ammoent:SetAngles(VectorRand():Angle())
                ammoent:Spawn()

                ammoent:SetResource(math.Clamp(ammocount / 3, 0, 200))
                ammoent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 100))
            end

            if largeammocount > 0 then 
                local ammoent = ents.Create("ent_jack_gmod_ezmunitions")

                ammoent:SetPos(ent:GetPos() + Vector(0,0,20))
                ammoent:SetAngles(VectorRand():Angle())
                ammoent:Spawn()
                ammoent:SetResource(math.Clamp(largeammocount, 0, 200))
                ammoent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0) + VectorRand() * math.Rand(0, 100))
            end

            ent.EzUse = true

            ent.wepinv = nil
        end
    end
end)

function ply_meta:IsSlotEmpty( slot )
    for _, v in ipairs( self:GetWeapons() ) do 
        if slot == SlotBlacklist[v:GetClass()] then continue end
        --print(v:GetClass())
        if v:GetSlot() == slot then return false end 
    end

    return true
end

-------ПЕРЕМЕЩЕНИЕ-------
hook.Add("SetupMove", "NoStrafe", function(ply, mv, cmd )
    if ply:KeyDown( IN_SPEED ) then
        mv:SetSideSpeed( 0 )
    end
        
    local factor = math.Remap(math.Clamp(math.abs(cmd:GetMouseX() / 5), 0, 50), 0, 50, 1, 0.2)
    ply:SetRunSpeed(Lerp(FrameTime() * 15, ply:GetRunSpeed(), ply:GetRunSpeed() * factor))
end)
--------------------------
SlotBlacklist = {

    ["weapon_physgun"] = 0,

    ["weapon_empty_hands"] = 0,
    
    ["wep_jack_gmod_hands"] = 0,

    ["wep_jack_gmod_ezshovel"] = 1,

    ["wep_jack_gmod_ezpickaxe"] = 1,
    
    ["binocle"] = 5,

    ["radiophone"] = 5,
    
    ["weapon_trenchwhistle"] = 0,

    ["tfa_doi_marinebayonet"] = 0,

    ["builder"] = 0,

    ["wep_jack_gmod_eztoolbox"] = 0,

    ["wep_jack_gmod_ezmedkit"] = 0,

    ["gmod_tool"] = 5,
    
    ["gmod_camera"] = 5,

}


hook.Add( "CanPlayerUnfreeze", "BuildFix", function( ply, ent, phys )
    if ent:GetClass() == "build_prop" then return false end
end)


local DontPhysPickUp = {
    ["build_prop"] = true,
    ["prop_dynamic"] = true,
    ["func_physbox"] = true,
    ["prop_door_rotating"] = true,
    ["ent_jack_gmod_ezcornstalk"] = true,
    ["ent_jack_gmod_eztree"] = true,
    ["ent_jack_gmod_ezwheat"] = true,
}

local LVSWhitelist = {
    ["joes_sam_turret_lvs"] = true,
}


hook.Add( "PhysgunPickup", "AllowPlayerPickup", function( ply, ent )
    if ent:IsPlayer() and not ply:IsSuperAdmin() then
        return false
    end
    
    local squad = SquadMenu:GetSquad(ply:GetSquadID())

    if ent.PhysGunNotTouch then return false end

    if (ent.squad ~= nil and SquadMenu:GetSquad(ent.squad)) and (ent.squad ~= ply:GetSquadID() and squad.Alliance[ent.squad] == nil) then return false end 
    
    if DontPhysPickUp[ent:GetClass()] then return false end

    if string.find(ent:GetClass(), "lvs") and not LVSWhitelist[ent:GetClass()] then return false end

    if not (ply:IsAdmin() or ply:IsSuperAdmin()) and ent:IsNPC() or ent:IsNextBot() then return false end

    --[[if not IsValid(JMod.GetEZowner(ent)) or JMod.GetEZowner(ent) == Entity(0) then return true end

    if JMod.GetEZowner(ent):GetSquadID() != nil then
        return true
   	elseif ply:GetSquadID() == JMod.GetEZowner(ent):GetSquadID() then
        return true
    end]]
    
    return true
end)

hook.Add("PlayerCanPickupWeapon", "OneSlot", function(ply, weapon )
    --if v.classname == weapon:GetClass() then return false end
    if ply:IsSlotEmpty(weapon:GetSlot()) then
        if IsValid(weapon) then
            ply:PickupWeapon(weapon)
        end
    end
end)

local LANRP_EnablePhysGunFreeze = CreateConVar( "LANRP_EnablePhysGunFreeze", 0, FCVAR_LUA_SERVER, "выключает возможность фризить 0 1", 0, 1)

local PhysFreezeEnt = {
    ["sent_conveyor"] = true,
    --["ent_new_powerline"] = true,
    --["ent_rus_gmod_ezpowerline"] = true,
}

hook.Add( "OnPhysgunFreeze", "PhysFreezeRemove", function( weapon, ply )
        return false
end)

hook.Add( "OnPhysgunFreeze", "PhysFreezeRemove", function( weapon, phys, ent, ply )
  
    if LANRP_EnablePhysGunFreeze:GetInt() == 0 then
    
        if not IsValid(ent) then return end
        
        ent.PhysGunFreeze = true

        if timer.Exists("Freeze " .. ent:EntIndex()) then
            timer.Start("Freeze " .. ent:EntIndex())
        else
            timer.Create( "Freeze " .. ent:EntIndex(), 4, 1, function()
                if not IsValid(ent) then return end
                
                local tr = util.TraceLine( {
                    start = ent:GetPos(),
                    endpos = ent:GetPos() - Vector(0, 0, 15),
                    filter = ent,
                } )
    
                debugoverlay.Line( ent:GetPos(), tr.HitPos, 1, Color( 0, 255, 0), true )
    
                if not (PhysFreezeEnt[ent:GetClass()] and tr.HitWorld) then
                    ent.PhysGunFreeze = false
                    phys:EnableMotion(true)
                    phys:Wake()
                end
            end)
        end

    end

    if LANRP_EnablePhysGunFreeze:GetInt() == 1 then
        return true
    end
end)

hook.Add( "OnPhysgunFreeze", "PhysGunTool", function( weapon, phys, ent, ply )
    local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)

    if Alt and ply:HasWeapon("wep_jack_gmod_eztoolbox") --[[and IsFirstTimePredicted()]] then
        local ToolBox = ply:GetWeapon("wep_jack_gmod_eztoolbox")
        local SelectedBuild = ToolBox:GetSelectedBuild()
        local BuildInfo = JMod.Config.Craftables[SelectedBuild]
        if BuildInfo and BuildInfo.oneHanded then
            ToolBox:BuildItem(SelectedBuild)
        end
    end
end)

------------------FIX WAKE---------------------------
hook.Add( "OnPhysgunPickup", "FixWake", function(ply, ent)

    timer.Create("FixWake " .. ent:EntIndex(), 0.1, 0, function()
        ent:GetPhysicsObject():Wake()
    end)

end)

hook.Add( "PhysgunDrop", "FixWake", function(ply, ent)
    timer.Remove("FixWake " .. ent:EntIndex())
end)
-------------------------------------------------

------------------Stress system---------------------------
--[[hook.Add( "OnPhysgunPickup", "StressSystem", function(ply, ent)

    ent:SetTrigger( true )

    local OldStartTouch = ent.StartTouch

    ent.StartTouch = function(ent2, arg1)

        if IsValid(ent2:GetPhysicsObject()) and not ent2:IsPlayer() then
            ent2.MotionEnabled = ent2:GetPhysicsObject():IsMotionEnabled()

            if ent2:GetPhysicsObject():IsMotionEnabled() then
                ent2:GetPhysicsObject():EnableMotion(false)
            end

            print("START")
        end

        return OldStartTouch(ent2, arg1)
    end

    local OldEndTouch = ent.EndTouch

    ent.EndTouch = function(ent2, arg1)

        if IsValid(ent2:GetPhysicsObject()) and not ent2:IsPlayer() then
            ent2:GetPhysicsObject():EnableMotion(ent2.MotionEnabled)

            print("END")
        end

        return OldEndTouch(ent2, arg1)
    end

end)]]

concommand.Add( "grabobject", function(ply)
    local ent = ply:GetEyeTrace().Entity

    if ply.GrabObject == nil then
        ply.GrabObject = true
    else
        ply.GrabObject = not ply.GrabObject
    end

    local NewAngle = Angle(0,0,0)

    if ent.OldCollisionGroup  == nil then
        ent.OldCollisionGroup = ent:GetCollisionGroup()
    end

    local Range = ply:GetPos():Distance(ent:GetPos())
    
    if ply.GrabObject then

        --[[hook.Add( "StartCommand", "MouseSettings " .. ply:EntIndex(), function( ply, cmd )

            if ply:KeyDown( IN_ATTACK2 ) then

                if cmd:GetMouseWheel() != 0 then
                    Range = math.Clamp(Range + cmd:GetMouseWheel(), 128, 512)
                end

                if NewAngle.y == 360 then
                    NewAngle.y = 0
                else
                    NewAngle.y = NewAngle.y + cmd:GetMouseX() / 5
                end
            end
        end)]]

        hook.Add("Think", "GrabObject " .. ply:EntIndex(), function()
            local mins = ent:OBBMins()
	        local maxs = ent:OBBMaxs()

            ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

            local tr = util.TraceHull( {
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:GetAimVector() * Range,
                maxs = maxs,
                mins = mins,
                filter = {ent, ply}
            } )

            local plyEye = ply:EyeAngles()
            plyEye.pitch = 0 
            plyEye.roll = 0

            --[[if (ply:KeyDown( IN_WALK ) and ply:KeyDown( IN_ATTACK2 )) then
                if NewAngle.y == 360 then
                    NewAngle.y = 0
                else
                    NewAngle.y = NewAngle.y + 3
                end

            elseif ply:KeyDown( IN_ATTACK2 ) then
                if NewAngle.y == 0 then
                    NewAngle.y = 360
                else
                    NewAngle.y = NewAngle.y - 3
                end
            end]]

            ent:SetPos(LerpVector(FrameTime() * 2.5, ent:GetPos(), tr.HitPos))
            ent:SetAngles(plyEye + NewAngle)
        end)
    else
        hook.Remove("Think", "GrabObject " .. ply:EntIndex())
        hook.Remove("StartCommand", "MouseSettings " .. ply:EntIndex())
        ent:GetPhysicsObject():Wake()
        ent:SetCollisionGroup(ent.OldCollisionGroup)
        ent.OldCollisionGroup = nil
    end
    
end)

hook.Add( "PhysgunDrop", "StressSystem", function(ply, ent)
    --ent:SetTrigger( false )
    
    ent:GetPhysicsObject():SetVelocity(Vector(0,0,0))
    ent:GetPhysicsObject():SetAngleVelocity(Vector(0,0,0))
    ent:SetPos(ent:GetPos())
    ent:SetAngles(ent:GetAngles())
end)
-------------------------------------------------


------------------NUKE---------------------------
--[[util.AddNetworkString("lanrp.sendnukepos")

hook.Add( "OnPhysgunPickup", "ShowNukePos", function(ply, ent )
    if ent:GetClass() == "ent_jack_gmod_eznukerocket" then
        
        net.Start("lanrp.sendnukepos")
        net.WriteBool(true)
        net.WriteVector(ent:CalculateLastPos())
        net.Send(ply)

        timer.Create("ShowNukePos " .. ply:EntIndex(), 0.1, 0, function()
            net.Start("lanrp.sendnukepos")
            net.WriteBool(true)
            net.WriteVector(ent:CalculateLastPos())
            net.Send(ply)

            local predictedPath = ent:CalculateRocketPosition(Vector(651, -6649, 72))

            net.Start("DrawRocketPos")
            net.WriteTable(predictedPath)
            net.Send(JMod.GetEZowner(ent))
        end)

    end
end)

hook.Add( "PhysgunDrop", "StopNukePos", function(ply, ent )
    if ent:GetClass() == "ent_jack_gmod_eznukerocket" then
        timer.Remove("ShowNukePos " .. ply:EntIndex())

        net.Start("lanrp.sendnukepos")
        net.WriteBool(false)
        net.Send(ply)
    end
end)]]
-------------------------------------------------

hook.Add( "OnPhysgunPickup", "PhysBalanceIN", function(ply, ent)
    if not ent:IsPlayerHolding() then
        ply.EntOldCollisionGroup = ent:GetCollisionGroup()
        ent:SetCollisionGroup(COLLISION_GROUP_NPC_ACTOR)
    end
end)

hook.Add( "PhysgunDrop", "PhysBalanceOUT", function(ply, ent )
    if ply.EntOldCollisionGroup then
        ent:SetCollisionGroup(ply.EntOldCollisionGroup)
        ply.EntOldCollisionGroup = nil
    end
end)

hook.Add( "PlayerNoClip", "FeelFreeToTurnItOff", function( ply, desiredState )
    --[[if ply:IsAdmin() or ply:IsSuperAdmin() then
	    ply.noclip = not ply.noclip or false 

        if ply.noclip then
	    	ply:ConCommand("ulx cloak")
	    else
	    	ply:ConCommand("ulx uncloak")
	    end
    end]]

    if ( desiredState == false ) then -- the player wants to turn noclip off
        return true -- always allow
    elseif ( ply:IsAdmin() ) then
        return true -- allow administrators to enter noclip
    end
end )
