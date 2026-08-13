local L = SquadMenu.GetLanguageText
local colors = SquadMenu.Theme

local UpdateButton = function( button, text, enabled )
    button:SetEnabled( enabled )
    button:SetText( L( text ) )
    button:SizeToContentsX( 10 )
    button:GetParent():InvalidateLayout()
end

local PANEL = {}
local DEFAULT_HEIGHT = 48
local COLOR_BLACK = Color( 0, 0, 0, 255 )

function PANEL:Init()
    self.squad = {
        id = 0,
        name = "-",
        leaderName = "-",
        color = COLOR_BLACK
    }

    self:SetCursor( "hand" )
    self:SetExpanded( false )

    self.icon = vgui.Create( "DImage", self )
    self.icon:SetSize( 24, 24 )

    self.buttonJoin = vgui.Create( "DButton", self )
    self.buttonJoin:SetTall( 32 )

    self.buttonJoin.DoClick = function()
        if self.leaveOnClick then
            SquadMenu.LeaveMySquad( self.buttonJoin )
        else
            UpdateButton( self.buttonJoin, "waiting_response", false )

            SquadMenu.StartCommand( SquadMenu.JOIN_SQUAD )
            net.WriteUInt( self.squad.id, 16 )
            net.SendToServer()
        end
    end

    self.memberCount = vgui.Create( "DPanel", self )
    self.memberCount:SetTall( 32 )
    self.memberCount:SetPaintBackground( false )
    self.memberCount:DockPadding( 4, 0, 4, 0 )

    SquadMenu.ApplyTheme( self.buttonJoin )
end

function PANEL:PerformLayout( w )
    local joinWidth = self.buttonJoin:GetWide()

    self.icon:SetPos( 12, 12 )
    self.buttonJoin:SetPos( w - joinWidth - 4, 8 )
    self.memberCount:SetPos( w - joinWidth - self.memberCount:GetWide() - 8, 8 )
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 4, 0, 0, w, h, COLOR_BLACK )

    if self:IsHovered() then
        draw.RoundedBox( 4, 0, 0, w, DEFAULT_HEIGHT, colors.buttonBackground )
    end

    surface.SetDrawColor( self.squad.color:Unpack() )
    surface.DrawRect( 0, 0, 4, h )

    draw.SimpleText( self.squad.name, "Trebuchet18", 48, 4 + DEFAULT_HEIGHT * 0.5, colors.buttonText, 0, 4 )
    draw.SimpleText( self.squad.leaderName or "<Server>", "DefaultSmall", 48, 1 + DEFAULT_HEIGHT * 0.5, colors.buttonTextDisabled, 0, 3 )

    local fi = 1
    local wi = 1 
    for k,v in pairs(self.squad.Alliance) do
        local squad = AllSquads[k]

        if not squad then continue end

        --Friendly icon
        surface.SetMaterial(Material("icon16/group.png"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(205, 2 + DEFAULT_HEIGHT * 0.12, 16, 16)
        
        draw.RoundedBox( 4, 200 + (25 * fi), 1 + DEFAULT_HEIGHT * 0.09, 20, 20, Color(squad.color.r, squad.color.g, squad.color.b, 100) )

        --icon
        surface.SetMaterial(Material(squad.icon))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(202 + (25 * fi), 2 + DEFAULT_HEIGHT * 0.09, 16, 16)
        fi = fi + 1
    end

    for k,v in pairs(self.squad.SquadsInWar) do
        local squad = AllSquads[k]

        if not squad then continue end

        --Friendly icon
        surface.SetMaterial(Material("icon16/fire.png"))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(205, 2 + DEFAULT_HEIGHT * 0.6, 16, 16)
        
        draw.RoundedBox( 4, 200 + (25 * wi), 1 + DEFAULT_HEIGHT * 0.56, 20, 20, Color(squad.color.r, squad.color.g, squad.color.b, 100) )

        --icon
        surface.SetMaterial(Material(squad.icon))
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(202 + (25 * wi), 2 + DEFAULT_HEIGHT * 0.62, 16, 16)
        wi = wi + 1
    end
    
end

function PANEL:OnMousePressed( keyCode )
    if keyCode == MOUSE_LEFT then
        self:SetExpanded( not self.isExpanded, true )
    end

    if keyCode == MOUSE_RIGHT then
        SquadChoice(self.squad, SquadMenu.mySquad)
    end
end

--- Set the squad data.
--- `squad` is a table that comes from `squad:GetBasicInfo`.
function PANEL:SetSquad( squad )
    squad.color = Color( squad.r, squad.g, squad.b )

    self.squad = squad
    self.icon:SetImage( squad.icon )

    local maxMembers = SquadMenu.GetMemberLimit()
    local count = #squad.members

    self.leaveOnClick = squad.id == ( SquadMenu.mySquad and SquadMenu.mySquad.id or -1 )

    if self.leaveOnClick then
        UpdateButton( self.buttonJoin, "leave_squad", true )
    elseif count < maxMembers then
        UpdateButton( self.buttonJoin, squad.isPublic and "join" or "request_to_join", true )
    else
        UpdateButton( self.buttonJoin, "full_squad", false )
    end

    self.memberCount:Clear()

    local labelCount = vgui.Create( "DLabel", self.memberCount )
    labelCount:SetText( count .. "/" .. maxMembers )
    labelCount:SizeToContents()
    labelCount:Dock( FILL )

    local left, _, right = self.memberCount:GetDockPadding()
    local labelWide = labelCount:GetWide() + left + right + 4

    local iconCount = vgui.Create( "DImage", self.memberCount )
    iconCount:Dock( LEFT )
    iconCount:DockMargin( 0, 8, 4, 8 )
    iconCount:SetWide( 16 )
    iconCount:SetImage( "icon16/user.png" )

    self.memberCount:SetWide( labelWide + iconCount:GetWide() )
end

function SquadChoice(squad, mysquad)
    local Menu = DermaMenu()

    local MeInSquad = false

    if LocalPlayer():GetSquadID() == -1 then return end 

    if mysquad.leaderId != LocalPlayer():SteamID() then return end 

    for k,v in pairs(squad["members"]) do

        if LocalPlayer():SteamID() == v[1] then
            
            MeInSquad = true
            break
        end
    end
    
    --[[local btnDebug = Menu:AddOption( "принт", function()
        PrintTable(squad)
    end)
    btnDebug:SetIcon( "icon16/bomb.png" )]]

    
    if MeInSquad then return end

    local DLabelDip = vgui.Create( "DLabel", Menu )
    DLabelDip:SetContentAlignment(5)
    DLabelDip:SetText( "Дипломатия" )
    DLabelDip:SetColor( Color(63,63,63) )

    Menu:AddSpacer()

    --PrintTable(mysquad)
    local btnMoney = Menu:AddOption( "Перевести Деньги", function()

        local money = SquadMenu.mySquad.money

		local ply = player.GetBySteamID( squad.leaderId )

		if ply:IsPlayer() then
			Request = Derma_StringRequest(
				"Дать денег " .. squad.name,
				"Введите количество денег. Ваше текущее количество JBux: " .. money,
				"",
				function(text) RunConsoleCommand("js_jbux_donate", ply:Nick(), text) end
			)
		end
        
    end )
    btnMoney:SetIcon( "icon16/money.png" )

    Menu:AddSpacer()

    if mysquad.AllianceRequest[squad.id] then
        local Child, btnAllian_Parent = Menu:AddSubMenu( "Альянс" )
        btnAllian_Parent:SetIcon( "icon16/error.png" )
        Child:AddOption( "Принять", function() 

            SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_ANSWER )
            net.WriteUInt( squad.id, 16 )
            net.WriteBool(true)
            net.SendToServer()

        end):SetIcon( "icon16/accept.png" )

        Child:AddOption( "Отклонить", function() 

            SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_ANSWER )
            net.WriteUInt( squad.id, 16 )
            net.WriteBool(false)
            net.SendToServer()

        end):SetIcon( "icon16/cancel.png" )
    elseif mysquad.Alliance[squad.id] then
        local btnAllian = Menu:AddOption( "Расстрогнуть Альянс", function()
            --PrintTable(squad)

            SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_REQUEST )
            net.WriteUInt( squad.id, 16 )
            net.SendToServer()
            
        end )
        btnAllian:SetIcon( "icon16/emoticon_unhappy.png" )
    elseif not mysquad.SquadsInWar[squad.id] then 
        local btnAllian = Menu:AddOption( "Предложить Альянс", function()
            --PrintTable(squad)

            SquadMenu.StartCommand( SquadMenu.SQUAD_FRIENDS_REQUEST )
            net.WriteUInt( squad.id, 16 )
            net.SendToServer()
            
        end )
        btnAllian:SetIcon( "icon16/emoticon_wink.png" )
    end

    if not mysquad.Alliance[squad.id] then
        --PrintTable(SquadMenu.mySquad)
        --print(mysquad.SquadsInWar[squad.id])
        if not mysquad.PactNoWar[squad.id] then
            if mysquad.SquadsInWar[squad.id] == nil then
                local btnWar = Menu:AddOption( "Объявить Войну", function()

                    SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
                    net.WriteUInt( squad.id, 16 )
                    net.WriteBool(true)
                    net.SendToServer()

                end)
                btnWar:SetIcon( "icon16/bomb.png" )

                if not mysquad.PactNoWarRequest[squad.id] then
                    local btnWar = Menu:AddOption( "Пакт о Ненападении", function()

                        net.Start("SQUAD_PACTNOWAR_REQUEST")
                        net.WriteInt( squad.id, 16 )
                        net.SendToServer()

                    end)
                    btnWar:SetIcon( "icon16/lock.png" )
                else
                    local Child, btnAllian_Parent = Menu:AddSubMenu( "Пакт о Ненападении" )
                    btnAllian_Parent:SetIcon( "icon16/error.png" )
                    Child:AddOption( "Принять", function() 
                    
                        net.Start("SQUAD_PACTNOWAR_ANSWER")
                        net.WriteInt( squad.id, 16 )
                        net.WriteBool(true)
                        net.SendToServer()
                    
                    end):SetIcon( "icon16/accept.png" )
                
                    Child:AddOption( "Отклонить", function() 
                    
                        net.Start("SQUAD_PACTNOWAR_ANSWER")
                        net.WriteInt( squad.id, 16 )
                        net.WriteBool(false)
                        net.SendToServer()
                    
                    end):SetIcon( "icon16/cancel.png" )
                end
            else
                --[[local btnWar = Menu:AddOption( "Капитуляция", function()

                    SquadMenu.StartCommand( SquadMenu.SQUAD_WAR )
                    net.WriteUInt( squad.id, 16 )
                    net.WriteBool(false)
                    net.SendToServer()

                end)
                btnWar:SetIcon( "icon16/flag_yellow.png" )]]

                if not mysquad.EndWarRequest[squad.id] then
                    local btnReqWar = Menu:AddOption( "Прекращение Огня", function()

                        SquadMenu.StartCommand( SquadMenu.SQUAD_ENDWAR_REQUEST )
                        net.WriteUInt( squad.id, 16 )
                        net.SendToServer()

                    end)
                    btnReqWar:SetIcon( "icon16/flag_green.png" )
                else
                    local Child, btnAllian_Parent = Menu:AddSubMenu( "Прекращение Огня" )
                    btnAllian_Parent:SetIcon( "icon16/error.png" )
                    Child:AddOption( "Принять", function() 
                    
                        SquadMenu.StartCommand( SquadMenu.SQUAD_ENDWAR_ANSWER )
                        net.WriteUInt( squad.id, 16 )
                        net.WriteBool(true)
                        net.SendToServer()
                    
                    end):SetIcon( "icon16/accept.png" )
                
                    Child:AddOption( "Отклонить", function() 
                    
                        SquadMenu.StartCommand( SquadMenu.SQUAD_ENDWAR_ANSWER )
                        net.WriteUInt( squad.id, 16 )
                        net.WriteBool(false)
                        net.SendToServer()
                    
                    end):SetIcon( "icon16/cancel.png" )
                end
            end
        end
    end

    -- Open the menu
    Menu:Open()
end

function PANEL:SetExpanded( expanded, scroll )
    self.isExpanded = expanded

    local height = DEFAULT_HEIGHT
    local memberHeight = 30

    if expanded then
        height = height + 4 + memberHeight * math.min( #self.squad.members, 5 )
    end

    self:SetTall( height )
    self:InvalidateLayout()

    if expanded and scroll then
        self:GetParent():GetParent():ScrollToChild( self )
    end

    if self.membersScroll then
        self.membersScroll:Remove()
        self.membersScroll = nil
    end

    if not expanded then return end

    local membersScroll = vgui.Create( "DScrollPanel", self )
    membersScroll:Dock( FILL )
    membersScroll:DockMargin( 0, DEFAULT_HEIGHT, 0, 0 )
    membersScroll.pnlCanvas:DockPadding( 6, 2, 2, 2 )

    self.membersScroll = membersScroll

    local byId = SquadMenu.AllPlayersById()

    for _, m in ipairs( self.squad.members ) do
        local id = m[1]

        local line = vgui.Create( "DPanel", membersScroll )
        line:SetBackgroundColor( colors.panelBackground )
        line:SetTall( memberHeight - 2 )
        line:Dock( TOP )
        line:DockMargin( 0, 0, 0, 2 )

        local name = vgui.Create( "DLabel", line )
        name:SetText( m[2] )
        name:Dock( FILL )

        local avatar = vgui.Create( "AvatarImage", line )
        avatar:SetWide( 20 )
        avatar:Dock( LEFT )
        avatar:DockMargin( 4, 4, 4, 4 )

        if byId[id] then
            avatar:SetPlayer( byId[id], 64 )
        end

        if id == self.squad.leaderId then
            line:SetZPos( -1 )

            local leaderIcon = vgui.Create( "DImage", line )
            leaderIcon:SetWide( 16 )
            leaderIcon:SetImage( "icon16/award_star_gold_3.png" )
            leaderIcon:Dock( RIGHT )
            leaderIcon:DockMargin( 0, 6, 4, 6 )
        end
    end
end

vgui.Register( "Squad_Line", PANEL, "DPanel" )
