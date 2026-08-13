local IsValid = IsValid
local PID = SquadMenu.GetPlayerId
local FindByPID = SquadMenu.FindPlayerById

local Squad = SquadMenu.Squad or {}
SquadMenu.Squad = Squad
Squad.__index = Squad

--- Set the leader of this squad. `ply` can either be
--- a player entity, a ID string that came from `SquadMenu.GetPlayerId`,
--- or `nil` if you want to unset the current squad leader.
function Squad:SetLeader( ply, name )
    if type( ply ) == "string" then
        self.leaderId = ply -- this is a player ID
        self.leaderName = name or "?"

    elseif IsValid( ply ) then
        self.leaderId = PID( ply )
        self.leaderName = ply:Nick()

    else
        self.leaderId = nil
        self.leaderName = nil

        SquadMenu.PrintF( "Removed leader from squad #%d", self.id )
        return
    end

    SquadMenu.PrintF( "New leader for squad #%d: %s <%s>", self.id, self.leaderName, self.leaderId )
end

function Squad:IsLeader(ply)
    if ply == player.GetBySteamID( self.leaderId ) then
        return true
    end

    return false
end

--- Get a table containing a list of active squad members.
--- Returns an array of player entities that are currently on the server.
function Squad:GetActiveMembers()
    local members, count = {}, 0
    local byId = SquadMenu.AllPlayersById()

    for id, _ in pairs( self.membersById ) do
        if byId[id] then
            count = count + 1
            members[count] = byId[id]
        end
    end

    return members, count
end

--- Get a ready-to-be-stringified table containing details from this squad.
function Squad:GetBasicInfo()
    local info = {
        id = self.id,
        name = self.name,
        icon = self.icon,
        members = {},

        isPublic = self.isPublic,

        hp = self.hp,
        money = self.money,

        r = self.r,
        g = self.g,
        b = self.b,

        AllianceRequest = self.AllianceRequest,
        Alliance = self.Alliance,
        SquadsInWar = self.SquadsInWar,
        EndWarRequest = self.EndWarRequest,
        PactNoWarRequest = self.PactNoWarRequest,
        PactNoWar = self.PactNoWar,
        Sanctions = self.Sanctions,
        Loan = self.Loan,

        SpawnsBase = self.SpawnsBase,
    }

    if self.leaderId then
        info.leaderId = self.leaderId
        info.leaderName = self.leaderName
    end

    local count = 0

    for id, name in pairs( self.membersById ) do
        count = count + 1
        info.members[count] = { id, name }
    end

    return info
end

local ValidateString = SquadMenu.ValidateString
local ValidateNumber = SquadMenu.ValidateNumber

--- Set the details of this squad using a table.
function Squad:SetBasicInfo( info )
    self.name = ValidateString( info.name, "Unnamed", SquadMenu.MAX_NAME_LENGTH )
    self.icon = ValidateString( info.icon, "icon16/flag_blue.png", 256 )

    self.enableRings = info.enableRings == true
    self.friendlyFire = info.friendlyFire == true
    self.isPublic = info.isPublic == true

    self.r = ValidateNumber( info.r, 255, 0, 255 )
    self.g = ValidateNumber( info.g, 255, 0, 255 )
    self.b = ValidateNumber( info.b, 255, 0, 255 )

    SquadMenu.blockDamage[self.id] = Either( self.friendlyFire, nil, true )
end

--- Send details and a list of members to all squad members.
--- You should never set `immediate` to `true` unless you know what you're doing.
function Squad:SyncWithMembers( immediate )
    if not immediate then
        -- avoid spamming the networking system
        timer.Remove( "SquadMenu.Sync" .. self.id )
        timer.Create( "SquadMenu.Sync" .. self.id, 0.5, 1, function()
            self:SyncWithMembers( true )
        end )

        return
    end

    local members, count = self:GetActiveMembers()
    if count == 0 then return end

    local data = self:GetBasicInfo()

    SquadMenu.StartCommand( SquadMenu.SETUP_SQUAD )
    SquadMenu.WriteTable( data )
    net.Send( members )
end

--- Send the requests list to the squad leader.
function Squad:SyncRequests()
    local leader = FindByPID( self.leaderId )
    if not IsValid( leader ) then return end

    SquadMenu.StartCommand( SquadMenu.REQUESTS_LIST )
    SquadMenu.WriteTable( self.requestsById )
    net.Send( leader )
end

--- Turns `p` into a id and player entity depending on what `p` is.
local function ParsePlayerArg( p )
    if type( p ) == "string" then
        return p, FindByPID( p )
    end

    return PID( p ), p
end

--- Add a player as a new member.
--- `p` can be a player id from `SquadMenu.GetPlayerId` or a player entity.
function Squad:AddMember( p )
    local id, ply = ParsePlayerArg( p )
    if self.membersById[id] then return end

    local count = table.Count( self.membersById )
    if count >= SquadMenu.GetMemberLimit() then return end

    local name = id

    if IsValid( ply ) then
        local oldSquad = SquadMenu:GetSquad( ply:GetSquadID() )

        if oldSquad then
            oldSquad:RemoveMember( ply, SquadMenu.LEAVE_REASON_LEFT )
        end

        ply:SetNWInt( "squad_menu.id", self.id )
        name = ply:Nick()

        ply:SetPlayerColor(Vector( self.r / 255, self.g / 255, self.b / 255 ) )
    end

    self.membersById[id] = name
    self:SyncWithMembers()

    -- We don't send the requests list to the squad leaders (2nd "true" parameter)
    -- because "player_joined_squad" will already tell them to remove
    -- this player from their own copies of the join requests list.
    SquadMenu:CleanupRequests( id, true )

    SquadMenu.StartEvent( "player_joined_squad", {
        squadId = self.id,
        playerId = id
    } )
    net.Broadcast()

    hook.Run( "SquadMenu_OnJoinedSquad", self.id, ply, id )
end

--- Remove a player from this squad's members list.
--- `ply` can be a player id from `SquadMenu.GetPlayerId` or a player entity.
--- `reasonId` can be `nil` or one of the values from `SquadMenu.LEAVE_REASON_*`.
function Squad:RemoveMember( p, reasonId )
    local id, ply = ParsePlayerArg( p )
    if not self.membersById[id] then return end

    if id == self.leaderId then
        pcall( hook.Run, "SquadMenu_OnLeftSquad", self.id, ply, id )

        if reasonId == SquadMenu.LEAVE_REASON_DISCONNECT and table.Count(self.membersById) > 1 then 

            local NewLeader

            for k,v in pairs(self.membersById) do
                local member = player.GetBySteamID(k)
    
                if ply == member then continue end
    
                self:SetLeader( member )
    
                NewLeader = member
                
                break
            end
    
            for k,v in pairs(self.membersById) do
                local member = player.GetBySteamID(k)
    
                member:LanRPChatPrint(Color(self.r, self.g, self.b), self.leaderName, Color(255,255,0), " - ваш новый лидер!") 
                member:PlayLocalSound("hoi4/News_Event.wav")
    
                SquadMenu.StartCommand( SquadMenu.SETLEADER )
                net.WriteString(k)
                net.Send(member)
            end
        else

            self:Delete(true)

            return

        end
    end

    self.membersById[id] = nil
    self:SyncWithMembers()

    if not IsValid( ply ) then return end

    ply:SetNWInt( "squad_menu.id", -1 )

    if reasonId ~= nil then
        SquadMenu.StartCommand( SquadMenu.LEAVE_SQUAD )
        net.WriteUInt( reasonId, 3 )
        net.Send( ply )
    end

    hook.Run( "SquadMenu_OnLeftSquad", self.id, ply, id )
end

function Squad:SetHealth(value)
    self.hp = value
    
    local members = self.membersById

    local color1 = Color(self.r, self.g, self.b)

    local color1_light, _, _ = ColorToHSL(color1)
    color1_light = HSLToColor(color1_light, 1, 0.35)

    for k, v in pairs(members) do
        SquadMenu.StartCommand(SquadMenu.SQUAD_HEALTH)
        net.WriteInt(self.hp, 9)
        net.Send(player.GetBySteamID(k))
    end

    if self:GetHealth() <= 0 then
        for _,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(182,0,0), "Фракция ", color1_light, self.name, Color(182,0,0), " была полностью уничтожена.")
            v:PlayLocalSound("hoi4/Low_health_energy_01.wav")
        end

        for k, v in pairs(members) do
            player.GetBySteamID(k):SetSquadCooldown()
        end

        --timer.Simple(0, function()
            self:Delete(false)
        --end)
    end
end

function Squad:AddHealth(value)
    self.hp = math.Clamp(self.hp + value, 0, 200)

    local members = self.membersById

    local color1 = Color(self.r, self.g, self.b)

    local color1_light, _, _ = ColorToHSL(color1)
    color1_light = HSLToColor(color1_light, 1, 0.35)

    for k, v in pairs(members) do
        if IsValid(player.GetBySteamID(k)) then
            SquadMenu.StartCommand(SquadMenu.SQUAD_HEALTH)
            net.WriteInt(self.hp, 9)
            net.Send(player.GetBySteamID(k))
        end
    end

    if self.hp <= 0 then
        for _,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(182,0,0), "Фракция ", color1_light, self.name, Color(182,0,0), " была полностью уничтожена.")
            v:PlayLocalSound("hoi4/Low_health_energy_01.wav")
        end

        for k, v in pairs(members) do
            player.GetBySteamID(k):SetSquadCooldown()
        end

        --timer.Simple(0, function()
            self:Delete(false)
        --end)
    end
end

function Squad:GetHealth()
    return self.hp
end

function Squad:MakeTimer()
    if not timer.Exists("SquadMenu.War" .. self.id) then
        timer.Create( "SquadMenu.War" .. self.id, 30, 0, function()


            local color1 = Color(self.r, self.g, self.b)

            local color1_light, _, _ = ColorToHSL(color1)
            color1_light = HSLToColor(color1_light, 1, 0.35)

            local members = self.membersById

            local TrueStart = false 
            
            for k,v in pairs(self.SquadsInWar) do
                local warsquad = SquadMenu:GetSquad(k)

                --print(self:GetHealth(), warsquad:GetHealth(), TrueStart)
                if self:GetHealth() < 200 or warsquad:GetHealth() < 200 then
                    TrueStart = true
                end
            end

            if TrueStart then
                if (self:GetHealth() <= 0 or not table.IsEmpty( self.SquadsInWar )) then

                    local members = table.Count(members)
                    
                    if members == 2 then
                        self:AddHealth(-5)
                    elseif members == 1 then
                        self:AddHealth(-10)
                    else
                        self:AddHealth(-1)
                    end
                    

                else
                    timer.Remove("SquadMenu.War" .. self.id)
                end
            end
        end)
    end
end

function Squad:StopTimer()
    if timer.Exists("SquadMenu.War" .. self.id) then
        timer.Remove("SquadMenu.War" .. self.id)
    end
end

function Squad:MakeLoanDebt(value)
    if not timer.Exists("SquadMenu.LoanDebt" .. self.id) then
        self.Loan.money = value
        self.Loan.Debt = self.Loan.Debt or 0
        
        for k,v in pairs(self.membersById) do
            local member = player.GetBySteamID(k)

            net.Start("lanrp.UpdateLoan")
		    net.WriteInt(self.Loan.money, 20)
		    net.WriteInt(0, 9)
		    net.Send(member)
        end

        local time = 300
        timer.Create( "SquadMenu.LoanDebt" .. self.id, time, 0, function()
            self.Loan.Debt = self.Loan.Debt or 0

            self.Loan.Debt = math.Min(self.Loan.Debt + 5 , 200)

            for k,v in pairs(self.membersById) do
                local member = player.GetBySteamID(k)

                net.Start("lanrp.UpdateLoan")
			    net.WriteInt(self.Loan.money, 20)
			    net.WriteInt(self.Loan.Debt, 9)
			    net.Send(member)
            end

            time = math.Max(time / 2, 30)

            timer.Adjust( "SquadMenu.LoanDebt" .. self.id, time)
        end)
    end
end

function Squad:DeleteLoanDebt()
    if timer.Exists("SquadMenu.LoanDebt" .. self.id) then
        timer.Remove("SquadMenu.LoanDebt" .. self.id)

        self.Loan = {}

        for k,v in pairs(self.membersById) do
            local member = player.GetBySteamID(k)

            net.Start("lanrp.UpdateLoan")
            net.WriteInt(0, 20)
            net.WriteInt(0, 9)
            net.Send(member)
        end
    end
end

--- Add a player to the list of players that
--- requested to join and notify the squad leader.
function Squad:RequestToJoin( ply )
    if self.isPublic then
        self:AddMember( ply )
        return
    end

    local plyId = PID( ply )
    if self.requestsById[plyId] then return end

    self.requestsById[plyId] = ply:Nick()
    self:SyncRequests()
end

--- Accept all the join requests from a list of player IDs.
function Squad:AcceptRequests( ids )
    if not table.IsSequential( ids ) then return end

    local limit = SquadMenu.GetMemberLimit()
    local count = table.Count( self.membersById )

    for _, id in ipairs( ids ) do
        if count >= limit then
            break

        elseif self.requestsById[id] then
            count = count + 1

            self.requestsById[id] = nil
            self:AddMember( id )
        end
    end
end

--- Remove all members from this squad and delete it.
function Squad:Delete(showtext)
    timer.Remove( "SquadMenu.Sync" .. self.id )
    timer.Remove( "SquadMenu.War" .. self.id  )

    local color1 = Color(self.r, self.g, self.b)

    local color1_light, _, _ = ColorToHSL(color1)
    color1_light = HSLToColor(color1_light, 1, 0.35)

    local hasalliance = false 

    if self.Alliance ~= nil then

        hasalliance = true

        for k,v in pairs(self.Alliance) do
            SquadMenu:GetSquad(k).AllianceRequest[self.id] = nil
            SquadMenu:GetSquad(k).Alliance[self.id] = nil
        end
    end

    if self.SquadsInWar ~= nil then
        for k,v in pairs(self.SquadsInWar) do
            SquadMenu:GetSquad(k).SquadsInWar[self.id] = nil
            SquadMenu:GetSquad(k):AddHealth(hasalliance and 25 or 100)

            local Leader = player.GetBySteamID( SquadMenu:GetSquad(k).leaderId )
            GAMEMODE:SetJBux(Leader, GAMEMODE:GetJBux(Leader) + 30000)
        end
    end

    if showtext then
        for _,v in ipairs(player.GetAll()) do
            v:LanRPChatPrint(Color(182,0,0), "Фракция ", color1_light, self.name, Color(182,0,0), " расформировалась...")
            v:PlayLocalSound("hoi4/War_declaration_01.wav")
        end
    end

    local members, count = self:GetActiveMembers()

    if count > 0 then
        for _, ply in ipairs( members ) do
            ply:SetNWInt( "squad_menu.id", -1 )
        end

        SquadMenu.StartCommand( SquadMenu.LEAVE_SQUAD )
        net.WriteUInt( SquadMenu.LEAVE_REASON_DELETED, 3 )
        net.Send( members )
    end

    self.membersById = nil
    self.requestsById = nil

    local id = self.id

    SquadMenu.squads[id] = nil
    SquadMenu.blockDamage[id] = nil

    SquadMenu.PrintF( "Deleted squad #%d", id )

    SquadMenu.StartEvent( "squad_deleted", { id = id } )
    net.Broadcast()
end
