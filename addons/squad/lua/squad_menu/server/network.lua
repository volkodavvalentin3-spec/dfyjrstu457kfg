local meta = FindMetaTable("Player")

function meta:SetSquadCooldown()
    local t = 15 -- 15 minutes
    t = t * 60

    self:SetNWFloat("squad.cooldown", CurTime() + t)
end

function meta:GetSquadCooldown()
    return self:GetNWFloat("squad.cooldown", 0)
end

function meta:CanCreateSquad()
    return CurTime() >= self:GetSquadCooldown()
end

SQUADLIMIT = 6 -- ставим число на одно больше

--[[----------------]]--

util.AddNetworkString( "squad_menu.command")

function SquadMenu.StartEvent( event, data )
    data = data or {}
    data.event = event

    SquadMenu.StartCommand( SquadMenu.BROADCAST_EVENT )
    SquadMenu.WriteTable( data )
end

local commands = {}
local PID = SquadMenu.GetPlayerId

commands[SquadMenu.SQUAD_LIST] = function( ply, need_flags )
    local data = {}

    for _, squad in pairs( SquadMenu.squads ) do
        data[#data + 1] = squad:GetBasicInfo()
    end

    SquadMenu.StartCommand( SquadMenu.SQUAD_LIST )
    SquadMenu.WriteTable( data )

    if need_flags then
        net.WriteBool(true)

        local flags = {}
        local ent_flags = ents.FindByClass("prop_ww_flag")

        for i = 1, #ent_flags do
            local flag = ent_flags[i]
            flags[#flags + 1] = {flag:EntIndex(), flag.squad}
        end

        net.WriteTable(flags, true)
    else
        net.WriteBool(false)
    end
    net.Send( ply )
end

commands[SquadMenu.SETUP_SQUAD] = function( ply )
    if not ply:CanCreateSquad() then
        local t = ply:GetSquadCooldown() - CurTime()
        t = math.floor(t / 60)

        BetterChatPrint(ply, "Подожи " .. t .. " минут перед тем как создать команду!", Color(255,255,0))
        --ply:ChatPrint("Подожи " .. t .. " минут перед тем как создать команду!")
        return
    end

    local squadId = ply:GetSquadID()
    local plyId = PID( ply )
    local data = SquadMenu.ReadTable()
    local SquadStyle = net.ReadUInt(5)

    if squadId == -1 and  table.Count(SquadMenu.squads) >= SQUADLIMIT then
        BetterChatPrint(ply, "Слишком много фракций! Вступай уже в существущую.", Color(255,255,0))
        return
    end

    if type( data.name ) == "string" then
        local shouldAllow, name = hook.Run( "ShouldAllowSquadName", data.name, ply )

        if shouldAllow == false then
            data.name = name or "?"
        end
    end

    -- Update existing squad if this ply is the leader.
    if squadId ~= -1 then
        local squad = SquadMenu:GetSquad( squadId )
        if not squad then return end
        if squad.leaderId ~= plyId then return end

        squad:SetBasicInfo( data )
        squad:SyncWithMembers()

        SquadMenu.PrintF( "Edited squad #%d for %s", squadId, ply:SteamID() )

        SquadMenu.StartEvent( "squad_created", { id = squadId } )
        net.Broadcast()

        return
    end

    local New = (squadId == -1)

    local squad = SquadMenu:CreateSquad()
    squad:SetBasicInfo( data )
    squad:SetLeader( ply )
    squad:AddMember( ply )

    SquadMenu.StartEvent( "squad_created", {
        id = squad.id,
        name = squad.name,
        leaderName = squad.leaderName,
        r = squad.r,
        g = squad.g,
        b = squad.b
    } )

    if New then
        local squad = SquadMenu:GetSquad( ply:GetSquadID() )
        squad.Style = SquadStyle
    end

    net.Broadcast()
end

commands[SquadMenu.JOIN_SQUAD] = function( ply )
    local squadId = net.ReadUInt( 16 )
    local squad = SquadMenu:GetSquad( squadId )

    if squad then
        squad:RequestToJoin( ply )
    end
end

commands[SquadMenu.LEAVE_SQUAD] = function( ply )
    local squadId = ply:GetSquadID()
    if squadId == -1 then return end

    local squad = SquadMenu:GetSquad( squadId )

    if squad then
        squad:RemoveMember( ply, SquadMenu.LEAVE_REASON_LEFT )
    end
end

commands[SquadMenu.ACCEPT_REQUESTS] = function( ply )
    local squadId = ply:GetSquadID()
    if squadId == -1 then return end

    local squad = SquadMenu:GetSquad( squadId )
    local ids = SquadMenu.ReadTable()

    if squad and squad.leaderId == PID( ply ) then
        squad:AcceptRequests( ids )
    end
end

commands[SquadMenu.KICK] = function( ply )
    local squadId = ply:GetSquadID()
    if squadId == -1 then return end

    local plyId = PID( ply )
    local squad = SquadMenu:GetSquad( squadId )

    if squad and squad.leaderId == plyId then
        local targetId = net.ReadString()
        if targetId == plyId then return end

        local byId = SquadMenu.AllPlayersById()
        if not byId[targetId] then return end

        squad:RemoveMember( byId[targetId], SquadMenu.LEAVE_REASON_KICKED )
    end
end

commands[SquadMenu.SETLEADER] = function( ply )
    local squadId = ply:GetSquadID()
    if squadId == -1 then return end

    local plyId = PID( ply )
    local squad = SquadMenu:GetSquad( squadId )

    if squad then
        local targetId = net.ReadString()
        if targetId == plyId then return end

        local byId = SquadMenu.AllPlayersById()
        if not byId[targetId] then return end

        squad:SetLeader( byId[targetId] )

        for k,v in pairs(squad.membersById) do
            local ply = player.GetBySteamID(k)

            if IsValid(ply) then
                ply:LanRPChatPrint(Color(squad.r, squad.g, squad.b), squad.leaderName, Color(255,255,0), " - ваш новый лидер!") 
                ply:PlayLocalSound("hoi4/News_Event.wav")

                SquadMenu.StartCommand( SquadMenu.SETLEADER )
                net.WriteString(targetId)
                net.Send(ply)
            end
        end
    end
end

commands[SquadMenu.SQUAD_FRIENDS_REQUEST] = function( ply )
    local squadId = net.ReadUInt( 16 )
    if squadId == -1 then return end

    local FriendSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(FriendSquad.r, FriendSquad.g, FriendSquad.b)

    if FriendSquad.Alliance[MySquadId] then
        for _, v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(255,255,0), "Фракция ", color1, MySquad.name, Color(255,255,0), " больше не в альянсе с ", color2, FriendSquad.name, Color(255,255,0))
            --BetterChatPrint(v, "Фракция " .. MySquad.name .. " больше не в альянсе с " .. FriendSquad.name, Color(255, 0, 0))
            v:PlayLocalSound("hoi4/News_Event.wav")
        end

        FriendSquad.Alliance[MySquadId] = nil
        MySquad.Alliance[squadId] = nil

        SquadMenu.StartCommand(SquadMenu.SQUAD_FRIENDS_REQUEST)
        net.WriteUInt(squadId, 16)
        net.Send(ply)
        return
    end

    if FriendSquad.AllianceRequest[MySquadId] then BetterChatPrint(ply, "Вы уже отправили запрос!", Color(255, 255, 0)) return end
    FriendSquad.AllianceRequest[MySquadId] = true

    local Leader = player.GetBySteamID( FriendSquad.leaderId )

    if IsValid( Leader ) then
        SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_REQUEST )
        net.WriteInt( MySquadId, 16 )
        net.Send( Leader )
    end

    BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " предлагает вам альянс", Color(0,255,0))
    Leader:PlayLocalSound("hoi4/diplomatic_notification_0" .. math.random(1,8) .. ".wav")
end

commands[SquadMenu.SQUAD_FRIENDS_ANSWER] = function( ply )
    local squadId = net.ReadUInt(16)
    local answer = net.ReadBool()
    if squadId == -1 then return end

    local FriendSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local Leader = player.GetBySteamID( FriendSquad.leaderId )

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(FriendSquad.r, FriendSquad.g, FriendSquad.b)

    if answer then
        FriendSquad.Alliance[MySquadId] = true
        MySquad.Alliance[squadId] = true

        FriendSquad.AllianceRequest[MySquadId] = nil
        MySquad.AllianceRequest[squadId] = nil

        SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_ANSWER )
        net.WriteUInt( squadId, 16 )
        net.WriteUInt( MySquadId, 16 )
        net.WriteBool(true)
        net.Broadcast()

        for _,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(120,120,255), "Фракция ", color1, MySquad.name, Color(120,120,255), " в альянсе с ", color2, FriendSquad.name, Color(120,120,255))
            --BetterChatPrint(v, "Фракция " .. MySquad.name .. " в альянсе с " .. FriendSquad.name, Color(120,120,255))
            v:PlayLocalSound("hoi4/News_Event.wav")
        end
    else
        SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_ANSWER )
        net.WriteUInt( squadId, 16 )
        net.WriteUInt( MySquadId, 16 )
        net.WriteBool(false)
        net.Broadcast()

        FriendSquad.AllianceRequest[MySquadId] = nil
        MySquad.AllianceRequest[squadId] = nil

        BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " отклонила ваше предложение создать альянс.", Color(255,255,0))
        Leader:PlayLocalSound("sounhoi4/News_Event.wav")
    end
end

commands[SquadMenu.SQUAD_WAR] = function( ply )
    local squadId = net.ReadUInt(16)
    local answer = net.ReadBool()
    if squadId == -1 then return end

    local WarSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local Leader = player.GetBySteamID( WarSquad.leaderId )

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(WarSquad.r, WarSquad.g, WarSquad.b)

    color_white = Color(255, 255, 255)

    local color1_light, _, _ = ColorToHSL(color1)
    color1_light = HSLToColor(color1_light, 1, 0.35)

    local color2_light, _, _ = ColorToHSL(color2)
    color2_light = HSLToColor(color2_light, 1, 0.35)

    if answer then
        MySquad.SquadsInWar[squadId] = true

        MySquad.PactNoWarRequest[squadId] = nil

        MySquad.AllianceRequest[squadId] = nil
        
        if MySquad.Alliance ~= nil then
            for k,v in pairs(MySquad.Alliance) do
                WarSquad.SquadsInWar[k] = true

                SquadMenu:GetSquad(k).SquadsInWar[squadId] = true
                SquadMenu:GetSquad(k).AllianceRequest[MySquadId] = nil
                SquadMenu:GetSquad(k).PactNoWarRequest[squadId] = nil

                SquadMenu:GetSquad(k):MakeTimer()

                WarSquad.AllianceRequest[k] = nil
                
                SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
                net.WriteUInt( k, 16 )
                net.WriteUInt( squadId, 16 )
                net.WriteBool(true)
                net.Broadcast()
            end
        end

        WarSquad.Defenders = true

        WarSquad.SquadsInWar[MySquadId] = true

        WarSquad.PactNoWarRequest[MySquadId] = nil

        WarSquad.AllianceRequest[MySquadId] = nil

        MySquad:MakeTimer()
        WarSquad:MakeTimer()

        if WarSquad.Alliance ~= nil then
            for k,v in pairs(WarSquad.Alliance) do
                MySquad.SquadsInWar[k] = true

                SquadMenu:GetSquad(k).SquadsInWar[MySquadId] = true
                SquadMenu:GetSquad(k).Defenders = true
                SquadMenu:GetSquad(k).AllianceRequest[MySquadId] = nil
                SquadMenu:GetSquad(k).PactNoWarRequest[squadId] = nil

                SquadMenu:GetSquad(k):MakeTimer()

                MySquad.AllianceRequest[k] = nil

                SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
                net.WriteUInt( k, 16 )
                net.WriteUInt( MySquadId, 16 )
                net.WriteBool(true)
                net.Broadcast()
            end
        end

        SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
        net.WriteUInt( squadId, 16 )
        net.WriteUInt( MySquadId, 16 )
        net.WriteBool(true)
        net.Broadcast()

        GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + 15000)

        GAMEMODE:SetJBux(Leader, GAMEMODE:GetJBux(Leader) + 5000)

        for _,v in ipairs(player.GetAll()) do

            if WarSquad.Alliance == nil or table.Count(WarSquad.Alliance) <= 0 then
                v:LanRPChatPrint(Color(182,0,0), "Фракция ", color1_light, MySquad.name, Color(182,0,0), " объявила войну ", color2_light, WarSquad.name, Color(182,0,0), "!")
                v:PlayLocalSound("hoi4/Enemy_trigger_alert_01.wav")
            else
                v:LanRPChatPrint(Color(182,0,0), "Фракция ", color1_light, MySquad.name, Color(182,0,0), " объявила войну ", color2_light, WarSquad.name, Color(182,0,0), " и ее альянсам!")
                v:PlayLocalSound("hoi4/Enemy_trigger_alert_01.wav")
            end

        end
    else
        MySquad.SquadsInWar[squadId] = nil

        WarSquad.SquadsInWar[MySquadId] = nil

        SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
        net.WriteUInt( MySquadId, 16 )
        net.WriteUInt( squadId, 16 )
        net.WriteBool(false)
        net.Broadcast()

        GAMEMODE:SetJBux(ply, math.max(GAMEMODE:GetJBux(ply) - math.Max(GAMEMODE:GetJBux(ply) / 2, 10000), 0))

        GAMEMODE:SetJBux(Leader, GAMEMODE:GetJBux(Leader) + math.Max(GAMEMODE:GetJBux(ply) / 1.5, 30000))

        --local MyMembers = MySquad.membersById
        --local WarMembers = WarSquad.membersById
        
        WarSquad:StopTimer()
        WarSquad:AddHealth(50)
        
        MySquad:StopTimer()
        MySquad:AddHealth(25)  

        for k,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(255,255,0), "Фракция ", color1, MySquad.name, Color(255,255,0), " сдалась перед фракцией ", color2, WarSquad.name, Color(255,255,0))
            --BetterChatPrint(v, "Фракция " .. MySquad.name .. " сдалась перед фракцией " .. WarSquad.name, Color(255,255,0))
            v:PlayLocalSound("hoi4/War_declaration_01.wav")
        end
    end
end


commands[SquadMenu.SQUAD_ENDWAR_REQUEST] = function( ply )
    local squadId = net.ReadUInt( 16 )
    if squadId == -1 then return end

    local WarSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(WarSquad.r, WarSquad.g, WarSquad.b)

    if WarSquad.EndWarRequest[MySquadId] then BetterChatPrint(ply, "Вы уже отправили запрос!", Color(255, 255, 0)) return end
    WarSquad.EndWarRequest[MySquadId] = true

    local Leader = player.GetBySteamID( WarSquad.leaderId )

    if IsValid( Leader ) then
        SquadMenu.StartCommand( SquadMenu.SQUAD_ENDWAR_REQUEST )
        net.WriteInt( MySquadId, 16 )
        net.Send( Leader )
    end

    BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " предлагает вам мирный договор", Color(255,187,0))
    Leader:PlayLocalSound("hoi4/diplomatic_notification_0" .. math.random(1,8) .. ".wav")
end

commands[SquadMenu.SQUAD_ENDWAR_ANSWER] = function( ply )
    local squadId = net.ReadUInt(16)
    local answer = net.ReadBool()
    if squadId == -1 then return end

    local WarSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local Leader = player.GetBySteamID( WarSquad.leaderId )

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(WarSquad.r, WarSquad.g, WarSquad.b)

    if answer then
        WarSquad.EndWarRequest[MySquadId] = nil
        MySquad.EndWarRequest[squadId] = nil

        MySquad.SquadsInWar[squadId] = nil

        WarSquad.SquadsInWar[MySquadId] = nil

        SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
        net.WriteUInt( MySquadId, 16 )
        net.WriteUInt( squadId, 16 )
        net.WriteBool(false)
        net.Broadcast()

        if MySquad.Defenders then
            if table.Count(MySquad.SquadsInWar) <= 0 then
                MySquad.Defenders = false
            end
        end

        if WarSquad.Defenders then
            if table.Count(MySquad.SquadsInWar) <= 0 then
                WarSquad.Defenders = false
            end
        end

        --local MyMembers = MySquad.membersById
        --local WarMembers = WarSquad.membersById
        
        WarSquad:StopTimer()
        WarSquad:AddHealth(25)
        
        MySquad:StopTimer()
        MySquad:AddHealth(25)  

        for k,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(255,255,255), "Фракция ", color1, MySquad.name, Color(255,255,255), " подписала мирный договор c ", color2, WarSquad.name, Color(255,255,255))
            v:PlayLocalSound("hoi4/War_declaration_01.wav")
        end
    else
        SquadMenu.StartCommand( SquadMenu.SQUAD_ENDWAR_ANSWER )
        net.WriteUInt( squadId, 16 )
        net.WriteUInt( MySquadId, 16 )
        net.WriteBool(false)
        net.Broadcast()

        WarSquad.AllianceRequest[MySquadId] = nil
        MySquad.AllianceRequest[squadId] = nil

        WarSquad.EndWarRequest[MySquadId] = nil
        MySquad.EndWarRequest[squadId] = nil

        BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " отклонила предложение о прекращении огня.", Color(255,255,0))
        Leader:PlayLocalSound("hoi4/diplomatic_notification_0" .. math.random(1,8) .. ".wav")
    end
end

util.AddNetworkString("SQUAD_PACTNOWAR_REQUEST")

net.Receive("SQUAD_PACTNOWAR_REQUEST", function( len, ply )
    local squadId = net.ReadInt( 16 )
    if squadId == -1 then return end

    local WarSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(WarSquad.r, WarSquad.g, WarSquad.b)

    if WarSquad.PactNoWarRequest[MySquadId] then BetterChatPrint(ply, "Вы уже отправили запрос!", Color(255, 255, 0)) return end
    WarSquad.PactNoWarRequest[MySquadId] = true

    local Leader = player.GetBySteamID( WarSquad.leaderId )

    if IsValid( Leader ) then
        net.Start( "SQUAD_PACTNOWAR_REQUEST" )
        net.WriteInt( MySquadId, 16 )
        net.Send( Leader )
    end

    BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " предлагает вам пакт о ненападении", Color(255, 255, 0))
    Leader:PlayLocalSound("hoi4/diplomatic_notification_0" .. math.random(1,8) .. ".wav")
end)

util.AddNetworkString("SQUAD_PACTNOWAR_ANSWER")

net.Receive("SQUAD_PACTNOWAR_ANSWER", function( len, ply )
    local squadId = net.ReadInt(16)
    local answer = net.ReadBool()
    if squadId == -1 then return end

    local WarSquad = SquadMenu:GetSquad( squadId )
    local MySquadId = ply:GetSquadID()
    local MySquad = SquadMenu:GetSquad(MySquadId)

    local Me = player.GetBySteamID( MySquad.leaderId )
    local Leader = player.GetBySteamID( WarSquad.leaderId )

    local color1 = Color(MySquad.r, MySquad.g, MySquad.b)
    local color2 = Color(WarSquad.r, WarSquad.g, WarSquad.b)

    if answer then
        WarSquad.PactNoWarRequest[MySquadId] = nil
        MySquad.PactNoWarRequest[squadId] = nil

        MySquad.PactNoWar[squadId] = true

        WarSquad.PactNoWar[MySquadId] = true

        net.Start( "SQUAD_PACTNOWAR_ANSWER" )
        net.WriteInt( MySquadId, 16 )
        net.WriteInt( squadId, 16 )
        net.WriteBool(true)
        net.Broadcast()

        for k,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(255,255,255), "Фракция ", color1, MySquad.name, Color(255,255,255), " подписала пакт о ненападении c ", color2, WarSquad.name)
            v:PlayLocalSound("hoi4/News_Event.wav")
        end

        timer.Simple(300, function()
            if MySquad == nil then WarSquad.PactNoWar[MySquadId] = nil return end
            if WarSquad == nil then MySquad.PactNoWar[squadId] = nil return end

            MySquad.PactNoWar[squadId] = nil
            WarSquad.PactNoWar[MySquadId] = nil

            net.Start( "SQUAD_PACTNOWAR_ANSWER" )
            net.WriteInt( MySquadId, 16 )
            net.WriteInt( squadId, 16 )
            net.WriteBool(false)
            net.Broadcast()

            for k,v in ipairs(player.GetAll()) do
                v:LanRPChatPrint(Color(255,255,255), "Закончился срок пакта о не нападении между ", color1, MySquad.name, Color(255,255,255), " и ", color2, WarSquad.name)
                v:PlayLocalSound("hoi4/News_Event.wav")
            end
        end)
    else
        net.Start( "SQUAD_ENDWAR_ANSWER" )
        net.WriteInt( squadId, 16 )
        net.WriteInt( MySquadId, 16 )
        net.WriteBool(false)
        net.Broadcast()

        WarSquad.PactNoWarRequest[MySquadId] = nil
        MySquad.PactNoWarRequest[squadId] = nil

        BetterChatPrint(Leader, "Фракция " .. MySquad.name .. " отклонила ваше предложение пакта о ненападении.", Color(255,255,0))
        Leader:PlayLocalSound("hoi4/News_Event.wav")
    end
end)

-- Safeguard against spam
local cooldowns = {
    [SquadMenu.SQUAD_LIST] = { interval = 0.5, players = {} },
    [SquadMenu.SETUP_SQUAD] = { interval = 1, players = {} },
    [SquadMenu.JOIN_SQUAD] = { interval = 0.1, players = {} },
    [SquadMenu.LEAVE_SQUAD] = { interval = 1, players = {} },
    [SquadMenu.ACCEPT_REQUESTS] = { interval = 0.2, players = {} },
    [SquadMenu.KICK] = { interval = 0.1, players = {} },
    [SquadMenu.SETLEADER] = { interval = 0.1, players = {} },
    [SquadMenu.SQUAD_FRIENDS_REQUEST] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_FRIENDS_ANSWER] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_WAR] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_ENDWAR_REQUEST] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_ENDWAR_ANSWER] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_ENDWAR_REQUEST] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_ENDWAR_ANSWER] = { interval = 1, players = {} },
    --[[[SquadMenu.SQUAD_PACTNOWAR_REQUEST] = { interval = 1, players = {} },
    [SquadMenu.SQUAD_PACTNOWAR_ANSWER] = { interval = 1, players = {} },]]
}

net.Receive( "squad_menu.command", function( _, ply )
    local id = ply:SteamID()
    local cmd = net.ReadUInt( SquadMenu.COMMAND_SIZE )

    if not commands[cmd] then
        SquadMenu.PrintF( "%s <%s> sent a unknown network command! (%d)", ply:Nick(), id, cmd )
        return
    end

    local t = RealTime()
    local players = cooldowns[cmd].players

    if players[id] and players[id] > t then
        SquadMenu.PrintF( "%s <%s> sent network commands too fast!", ply:Nick(), id )
        return
    end

    players[id] = t + cooldowns[cmd].interval
    commands[cmd]( ply )
end )

hook.Add("PlayerAuthed", "SquadMenu.CheckSquads", function(ply)
    timer.Simple(25, function()
        commands[SquadMenu.SQUAD_LIST](ply, true)
    end)
end)

hook.Add( "PlayerDisconnected", "SquadMenu.NetCleanup", function( ply )
    local id = ply:SteamID()

    for _, c in pairs( cooldowns ) do
        c.players[id] = nil
    end
end )

concommand.Add("sync_squads", function(ply)
    commands[SquadMenu.SQUAD_LIST](ply, true)
end)