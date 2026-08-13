local ply_meta = FindMetaTable("Player")

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

SquadStyle = {
    ["officer"] = {
        "ent_jack_gmod_ezarmor_schirmmuetze",
        "ent_jack_gmod_ezarmor_backpack",
        "ent_jack_gmod_ezarmor_gasmask",
        "ent_jack_gmod_ezarmor_mltorso",
        "ent_jack_gmod_ezarmor_pouch",
        "ent_jack_gmod_ezarmor_lrshoulder",
        "ent_jack_gmod_ezsmokenade",
        "ent_jack_gmod_ezflarenade",
        "ent_jack_gmod_ezifakpacket",
        "tfa_doisw1917",
        "weapon_trenchwhistle",
        "tfa_doi_marinebayonet",
        "binocle",
        "weapon_physgun",
    },

    {
        name = "nazi",
        image = "entities/ent_jack_gmod_ezarmor_nazihead.png",
        result = {
            "ent_jack_gmod_ezarmor_nazihead",
			"ent_jack_gmod_ezarmor_backpack",
			"ent_jack_gmod_ezarmor_gasmask",
			"ent_jack_gmod_ezarmor_ltorso",
			"ent_jack_gmod_ezarmor_pouch",
			"ent_jack_gmod_ezsticknade",
			"ent_jack_gmod_ezifakpacket",
			function() 
                if math.random(1, 100) <= 30 then 
                    return "tfa_doik98" 
                elseif  math.random(1, 3) == 1 then
                    return "tfa_doistg44"
                else
                    return "tfa_doimp40" 
                end 
            end,
			"tfa_doi_marinebayonet",
            "wep_jack_gmod_ezshovel"
        }
    },
    {
        name = "adrian",
        image = "entities/ent_jack_gmod_ezarmor_adrianhead.png",
        result = {
            "ent_jack_gmod_ezarmor_adrianhead",
            "ent_jack_gmod_ezarmor_backpack",
            "ent_jack_gmod_ezarmor_gasmask",
            "ent_jack_gmod_ezarmor_ltorso",
            "ent_jack_gmod_ezarmor_pouch",
            "ent_jack_gmod_ezsticknade",
            "ent_jack_gmod_ezifakpacket",
            "tfa_doienfield",
            "tfa_doi_marinebayonet",
            "wep_jack_gmod_ezshovel"
        }
    },
    {
        name = "western",
        image = "entities/ent_jack_gmod_ezarmor_ushead.png",
        result = {
            "ent_jack_gmod_ezarmor_ushead",
            "ent_jack_gmod_ezarmor_backpack",
            "ent_jack_gmod_ezarmor_gasmask",
            "ent_jack_gmod_ezarmor_ltorso",
            "ent_jack_gmod_ezarmor_pouch",
            "ent_jack_gmod_ezsticknade",
            "ent_jack_gmod_ezifakpacket",
            function() 
                if math.random(1, 100) <= 30 then 
                    if math.random(0, 1) == 1 then
                        return "tfa_doim3greasegun" 
                    else
                        return "tfa_doithompsonm1a1" 
                    end  
                else 
                    return "tfa_doispringfield" 
                end
            end,
            "tfa_doi_marinebayonet",
            "wep_jack_gmod_ezshovel"
        }
    },
    {
        name = "soviet",
        image = "entities/ent_jack_gmod_ezarmor_sovhead.png",
        result = {
            "ent_jack_gmod_ezarmor_sovhead",
            "ent_jack_gmod_ezarmor_backpack",
            "ent_jack_gmod_ezarmor_gasmask",
            "ent_jack_gmod_ezarmor_ltorso",
            "ent_jack_gmod_ezarmor_pouch",
            "ent_jack_gmod_ezsticknade",
            "ent_jack_gmod_ezifakpacket",
            function() if math.random(1, 100) <= 30 then return "tfa_doik98" else return "tfa_smc_ppsh_drum" end end,
            "tfa_doi_marinebayonet",
            "wep_jack_gmod_ezshovel"
        }
    },
}

SquadStyleVechicle = {
    {
        name = "nazi",
        lighttank = "lvs_pz38t_mow",
        mediumtank = "lvs_pz4g_mow",
        tankkiller = "lvs_jpz4_mow",
        heavytank = "lvs_wheeldrive_dodtiger",
        lightcar = "lvs_wheeldrive_dodkuebelwagen",
        antitank = "lvs_trailer_pak40",
        --
        helmet = "ent_jack_gmod_ezarmor_nazihead",

        pistol = function() 
                    if math.random(1, 3) == 1 then 
                        return "tfa_doic96" 
                    elseif math.random(1, 3) == 2 then
                        return "tfa_doip38" 
                    else 
                        return "tfa_doiluger" 
                    end
                end,
        rifle = "tfa_doik98",
        semirifle = "tfa_doig43",
        assaultrifle = function() 
                        if math.random(1, 2) == 1 then 
                            return "tfa_doimp40" 
                        else 
                            return "tfa_doistg44" 
                        end
                    end,
        sniperrifle = "tfa_doik98_scop",
        machinegun = "tfa_doimg42",
        grenadelauncher = "tfa_doi_panzerschreck",
        specialgun = "tfa_doistg44",
    },
    {
        name = "adrian",
        lighttank = "lvs_t60",
        mediumtank = "lvs_t34_42",
        tankkiller = "lvs_su85_tb",
        heavytank = "lvs_is2_mow",
        lightcar = "lvs_wheeldrive_dodwillyjeep",
        antitank = "lvs_trailer_zis3",
        --
        helmet = "ent_jack_gmod_ezarmor_adrianhead",

        pistol = "tfa_doippk",
        rifle = "tfa_doienfield",
        semirifle = "tfa_doig43",
        assaultrifle = "tfa_doimp40",
        sniperrifle = "tfa_doienfield_scop",
        machinegun = "tfa_doilewis",
        grenadelauncher = "tfa_doi_bazooka",
        specialgun = "tfa_doi_m16a1",
    },
    {
        name = "western",
        lighttank = "lvs_m3_stuart_tb",
        mediumtank = "lvs_m4_mow",
        tankkiller = "lvs_m10_mow",
        heavytank = "lvs_churchill_mow",
        lightcar = "lvs_wheeldrive_dodwillyjeep",
        antitank = "lvs_trailer_75mle1897",
        --
        helmet = "ent_jack_gmod_ezarmor_ushead",

        pistol = "tfa_doim1911",
        rifle = "tfa_doispringfield",
        semirifle = function() 
                        if math.random(1, 2) == 1 then 
                            return "tfa_doim1carbine" 
                        else 
                            return "tfa_doim1garand" 
                        end
                    end,
        assaultrifle = function() 
                        if math.random(1, 3) == 1 then 
                            return "tfa_doithompsonm1a1" 
                        elseif math.random(1, 3) == 2 then
                            return "tfa_doim3greasegun" 
                        else 
                            return "tfa_doisten" 
                        end
                    end,
        sniperrifle = "tfa_doispringfield_scop",
        machinegun = "tfa_doim1919",
        grenadelauncher = "tfa_doi_bazooka",
        specialgun = "tfa_doi_m16a1",
    },
    {
        name = "soviet",
        lighttank = "lvs_t60",
        mediumtank = "lvs_t34_42",
        tankkiller = "lvs_su85_tb",
        heavytank = "lvs_is2_mow",
        lightcar = "lvs_wheeldrive_dodwillyjeep",
        antitank = "lvs_trailer_zis3",
        --
        helmet = "ent_jack_gmod_ezarmor_sovhead",

        pistol = "tfa_doippk",
        rifle = "tfa_doik98",
        semirifle = "tfa_doig43",
        assaultrifle = "tfa_smc_ppsh_drum",
        sniperrifle = "tfa_doik98_scop",
        machinegun = "tfa_doimg34",
        grenadelauncher = "tfa_doi_bazooka",
        specialgun = "tfa_rs2v_akm",
    },
}

if SERVER then

    util.AddNetworkString("lanrp.StartMessage")

    resource.AddFile( "resource/fonts/BloggerSansBold.ttf" )

    --lua_run Entity(1):SendMessageOnTop("НАЧАЛАСЬ ЯДЕРНАЯ ВОЙНА")
    function ply_meta:SendMessageOnTop(text, color, small)
        net.Start("lanrp.StartMessage")
        net.WriteBool(small)
        net.WriteString(text)
        net.WriteColor(color)
        net.Send(self)
    end

    concommand.Add( "SendMessageOnTop", function( ply, cmd, args )
        if ply:IsSuperAdmin() then
            for _, ply in player.Iterator() do
                ply:SendMessageOnTop(unpack(args), Color(120, 0, 0))
                ply:PlayLocalSound("LANRP/nuke/nuclear war.wav") 
            end
        end
    end)

    ----------ГОВНО------------
    local function comma_value(amount)
        local formatted = amount
        while true do  
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end

    function format_num(amount, decimal, prefix, neg_prefix)
        local str_amount,  formatted, famount, remain
    
        decimal = decimal or 2  -- default 2 decimal places
        neg_prefix = neg_prefix or "-" -- default negative sign
    
        famount = math.abs(math.Round(amount,decimal))
        famount = math.floor(famount)
    
        remain = math.Round(math.abs(amount) - famount, decimal)
    
              -- comma to separate the thousands
        formatted = comma_value(famount)
    
              -- attach the decimal portion
        if (decimal > 0) then
          remain = string.sub(tostring(remain),3)
          formatted = formatted .. "." .. remain ..
                      string.rep("0", decimal - string.len(remain))
        end
    
              -- attach prefix string e.g '$' 
        formatted = (prefix or "") .. formatted 
    
              -- if value is negative then format accordingly
        if (amount < 0) then
            if (neg_prefix == "()") then
                formatted = "(" .. formatted .. ")"
            else
                formatted = neg_prefix .. formatted 
            end
        end
    
        return formatted
    end
    -----------------------

else

    surface.CreateFont( "BigScareMessage", {
        font = "Blogger Sans",
        extended = true,
        size = 100,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )

    surface.CreateFont( "SmallScareMessage", {
        font = "Blogger Sans",
        extended = true,
        size = 70,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )

    surface.CreateFont( "ArmorButtonText", {
        font = "Blogger Sans",
        extended = true,
        size = 40,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    } )

    local function DisplayMessage(text, color)
        local alpha = 0
        local fadeIn = true
        local fadeOutTime = 3.5
        local startTime = CurTime()
        local scale = 0.7

        hook.Add("PostDrawHUD", "ShowMessage", function()
            surface.SetFont("BigScareMessage")
            local textWidth, textHeight = surface.GetTextSize(text)
            
            -- Анимация масштаба
            if fadeIn then
                scale = Lerp( math.ease.OutExpo(FrameTime() * 2), scale, 1 )
            end
            
            -- Вычисляем позицию с учетом масштаба
            local scaledWidth = textWidth * scale
            local scaledHeight = textHeight * scale
            local x = (ScrW() / 2) - (scaledWidth / 2)
            local y = (ScrH() / 3) - (scaledHeight / 2)

            if fadeIn and alpha < 255 then
                alpha = alpha + FrameTime() * 1500
                if alpha >= 255 then
                    alpha = 255
                    fadeIn = false
                    startTime = CurTime()
                end
            end

            if not fadeIn and CurTime() >= startTime + fadeOutTime then
                alpha = alpha - FrameTime() * 500
                if alpha <= 0 then
                    hook.Remove("PostDrawHUD", "ShowMessage")
                    return
                end
            end
            
            -- Рисуем текст с масштабированием
            local mat = Matrix()
            mat:Translate(Vector(x, y, 0))
            mat:Scale(Vector(scale, scale, 1))
            
            cam.PushModelMatrix(mat)
            draw.SimpleText(text, "BigScareMessage", 0, 0, Color(color.r, color.g, color.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            cam.PopModelMatrix()
        end)
    end

    local function DisplaySmallMessage(text, color)
        local alpha = 0
        local fadeIn = true
        local fadeOutTime = 2.4
        local startTime = CurTime()
        local scale = 0.5

        hook.Add("PostDrawHUD", "ShowSmallMessage", function()
            surface.SetFont("SmallScareMessage")
            local textWidth, textHeight = surface.GetTextSize(text)
            
            -- Анимация масштаба
            --if fadeIn then
            local frame_time = FrameTime()
            local curtime = CurTime()

            local frac = math.ease.OutExpo(frame_time * 0.5)


            scale = Lerp( frac, scale, 1 )
            --end

            --print(scale)
            
            -- Вычисляем позицию с учетом масштаба
            local scaledWidth = textWidth * scale
            local scaledHeight = textHeight * scale

            

            local x = (ScrW() / 2) - (scaledWidth / 2)
            local y = (ScrH() / 1.5) - (scaledHeight / 2)

            x = Lerp(frac, x, x + math.Rand(-50,50))
            y = Lerp(frac, y, y + math.Rand(-50,50))

            if fadeIn and alpha < 255 then
                alpha = alpha + frame_time * 1000
                if alpha >= 255 then
                    alpha = 255
                    fadeIn = false
                    startTime = curtime
                end
            end

            if not fadeIn and curtime >= startTime + fadeOutTime then
                alpha = alpha - frame_time * 500
                if alpha <= 0 then
                    hook.Remove("PostDrawHUD", "ShowSmallMessage")
                    return
                end
            end
            
            -- Рисуем текст с масштабированием
            local mat = Matrix()
            mat:Translate(Vector(x, y, 0))
            mat:Scale(Vector(scale, scale, 1))
            
            cam.PushModelMatrix(mat)
            draw.SimpleText(text, "SmallScareMessage", 0, 0, Color(color.r, color.g, color.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            cam.PopModelMatrix()

            for i = 1, 3 do
                surface.SetFont("SmallScareMessage")
                local textWidth, textHeight = surface.GetTextSize(text)
                
                local scaledWidth = textWidth * scale
                local scaledHeight = textHeight * scale
                local x = (ScrW() / 2) - (scaledWidth / 2)
                local y = (ScrH() / 1.5) - (scaledHeight / 2)

                x = Lerp(frac, x, x + math.Rand(-550,550))
                y = Lerp(frac, y, y + math.Rand(-550,550))

                -- Рисуем текст с масштабированием
                local mat = Matrix()
                mat:Translate(Vector(x, y, 0))
                mat:Scale(Vector(scale, scale, 1))

                cam.PushModelMatrix(mat)
                draw.SimpleText(text, "SmallScareMessage", 0, 0, Color(color.r, color.g, color.b, alpha / 3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                cam.PopModelMatrix()
            end
        end)
    end

    concommand.Add( "SmallMessage", function( ply, cmd, args )
        if ply:IsSuperAdmin() then
            DisplaySmallMessage("УМРИ В БОЮ", Color(130,0, 0))
        end
    end)

    net.Receive("lanrp.StartMessage", function()
        if net.ReadBool() then
            DisplaySmallMessage(net.ReadString(), net.ReadColor())
        else
            DisplayMessage(net.ReadString(), net.ReadColor())
        end
    end)












    ---------ГЛОБАЛЬНОЕ СООБЩЕНИЕ--------------
    net.Receive("lanrp.sendGlobalMessage", function(len, ply)
        Derma_StringRequest(
            "",
            "Напишите сообщение, которое увидет весь мир",
            "",
            function(text)
                net.Start("lanrp.sendGlobalMessage")
                net.WriteString(text)
                net.WriteBool(true)
                net.SendToServer()
            end,
            function(text)
                net.Start("lanrp.sendGlobalMessage")
                net.WriteString(text)
                net.WriteBool(false)
                net.SendToServer()
            end
       )

    end)

    ---------ГЛОБАЛЬНОЕ СООБЩЕНИЕ--------------
    net.Receive("lanrp.sendHumanResources", function(len, ply)
        Derma_Query(
            "Будет пополнено 25 единиц",
            "Людские ресурсы:",
            "Принять",
                function() 
                    net.Start("lanrp.sendHumanResources")
                    net.WriteBool(true)
                    net.SendToServer() 
                end,
    	    "Отклонить",
    	        function() 
                    net.Start("lanrp.sendHumanResources")
                    net.WriteBool(false)
                    net.SendToServer() 
                end
    )

    end)

    concommand.Add( "RemoveAllVgui", function( ply, cmd, args )
        for k, v in pairs(vgui.GetAll()) do
            v:Remove()
        end
    end)
    
    local UnHoverColor = Color(200,200,200) 
    local HoverColor = Color(255,255,255) 

    ---------МОБИЛИЗАЦИЯ--------------
    function DermaSquadStyle(squaddata, squadmenu)
        local MainFrame = vgui.Create("DFrame")
        MainFrame:SetTitle("Выбор снаряжения")
        MainFrame:SetSize(400,470)
        MainFrame:Center()
        MainFrame:MakePopup()
        MainFrame:SetDraggable(true)
        MainFrame:ShowCloseButton(true)

        function MainFrame:OnClose()
            
        end

        function MainFrame:Paint( w, h ) 
            draw.RoundedBox( 10, 0, 0, w, h, Color( 30, 30, 30, 200) )
        end

        local SpanwsScrollPanel = vgui.Create("DScrollPanel", MainFrame)
        SpanwsScrollPanel:Dock(FILL)

        for k, v in pairs(SquadStyle) do
            if not isnumber(k) then continue end

            local NewPanel = SpanwsScrollPanel:Add("EditablePanel")
            NewPanel:SetTall(150)
            NewPanel:Dock(TOP)

            --[[NewPanel.Paint = function(this)
                
            end]]

            local ArmorImage = NewPanel:Add("DImage")
            ArmorImage:SetPos(0, 0)
            ArmorImage:SetSize(150, 150)
            ArmorImage:SetImage(v.image)
            ArmorImage:Dock(LEFT)
            --ArmorImage:DockMargin(0, 0, 0, 5)

            local ArmorButton = NewPanel:Add("DButton")

            ArmorButton:SetText("")
            ArmorButton:SetSize( 400, 100 )	
            ArmorButton:SetZPos(-1)
        
            ArmorButton:Dock(RIGHT)
            ArmorButton:DockMargin(150, 0, 5, 5)

            function ArmorButton:Paint( w, h ) 
                draw.RoundedBox( 10, 0, 0, w, h, Color( 50, 50, 50, 200) )

                draw.SimpleText(v.name, "ArmorButtonText", w * 0.7, h / 2, (ArmorButton:IsHovered() and HoverColor) or UnHoverColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            function ArmorButton:OnCursorEntered()
                surface.PlaySound("snds_jack_gmod/ez_gui/hover_ready.ogg")
            end

            function ArmorButton:DoClick()

                SquadMenu.StartCommand( SquadMenu.SETUP_SQUAD )
                SquadMenu.WriteTable( squaddata )
                net.WriteUInt( k, 5)
                net.SendToServer()

                surface.PlaySound("snds_jack_gmod/ez_gui/click_big.ogg")

                MainFrame:Remove()
            end

            --function MainFrame:OnClose()
            --    squadbuttons:SetEnabled( true )
            --    squadbuttons:SetText( "create_squad" )
            --end
        end
    end

    ---------РАЗВЕДДАННЫЕ--------------
    net.Receive("lanrp.sendIntelligenceData", function(len, ply)
        local WarSquads = net.ReadTable()

        if WarSquads == nil then return end
        if table.IsEmpty(WarSquads) then return end

        local MainFrame = vgui.Create("DFrame")
        MainFrame:SetTitle("Дислокация")
        MainFrame:SetSize(200,200)
        MainFrame:Center()
        MainFrame:MakePopup()
        MainFrame:SetDraggable(false)
        MainFrame:ShowCloseButton(false)

        local SpanwsScrollPanel = vgui.Create("DScrollPanel", MainFrame)
        SpanwsScrollPanel:Dock(FILL)

        for k, v in pairs(WarSquads) do
            local squad = AllSquads[k]

            if squad == nil then continue end

            local SquadButton = SpanwsScrollPanel:Add("DButton")

            SquadButton:SetText(squad.name)
            SquadButton:SetZPos(-1)
        

            SquadButton:Dock(TOP)
            SquadButton:DockMargin(0, 0, 0, 5)

            function SquadButton:DoClick()
                net.Start("lanrp.sendIntelligenceData")
                net.WriteFloat(squad.id)
                net.SendToServer()

                MainFrame:Remove()
            end
        end

    end)

    ---------НАЗВАНИЕ БАЗЫ--------------
    net.Receive("lanrp.setBaseName", function(len, ply)
        local ent = net.ReadEntity()

        Derma_StringRequest(
            "",
            "Выберите название точки дислокации",
            "",
            function(text)
                net.Start("lanrp.setBaseName")
                net.WriteEntity(ent)
                net.WriteString(text)
                net.SendToServer()
            end
       )

    end)

    net.Receive("lanrp.getBaseName", function(len, ply)
        local SpawnBase = net.ReadTable()

        if SpawnBase == nil then return end

        local MainFrame = vgui.Create("DFrame")
        MainFrame:SetTitle("Дислокация")
        MainFrame:SetSize(200,200)
        MainFrame:Center()
        MainFrame:MakePopup()
        MainFrame:SetDraggable(false)
        MainFrame:ShowCloseButton(false)

        local SpanwsScrollPanel = vgui.Create("DScrollPanel", MainFrame)
        SpanwsScrollPanel:Dock(FILL)

        for k, v in SortedPairsByValue(SpawnBase) do

            if not IsValid(k) then
                SpawnBase[k] = nil
                continue 
            end
				
			if k == LocalPlayer() then continue end

            local SpawnButton = SpanwsScrollPanel:Add("DButton")

            if k:GetClass() == "ent_jack_sleepingbag" then
                SpawnButton:SetText(v .. " | КРОВАТЬ")
            elseif k:IsPlayer() then
                SpawnButton:SetText(v .. " | " .. k:GetNWInt("RadioManSpawns"))
                SpawnButton:SetZPos(-1)
            elseif k:GetCapital() then
                SpawnButton:SetText(v .. " | СТОЛИЦА")
                SpawnButton:SetZPos(-1)
            else
                SpawnButton:SetText(v .. " | " .. k:GetSupplies())
            end

            SpawnButton:Dock(TOP)
            SpawnButton:DockMargin(0, 0, 0, 5)

            function SpawnButton:DoClick()
                net.Start("lanrp.getBaseName")
                net.WriteEntity(k)
                net.SendToServer()

                MainFrame:Remove()
            end
        end

    end)


    ---------КРЕДИТ---------
    net.Receive("lanrp.UpdateLoan", function(len, ply)
        local money = net.ReadInt(20)
        local debt = net.ReadInt(9)
        
        local squad = SquadMenu.mySquad

        squad.Loan.money = money
        squad.Loan.Debt = debt
    end)

    net.Receive("lanrp.MakeLoan", function(len, ply)
        local Loan = net.ReadTable()
        
        local squad = SquadMenu.mySquad

        if Loan.money == nil then
            OpenLoanMenu(squad)
        else
            OpenDebtMenu(Loan.money)
        end
    end)

    function LoanCalculations(amount)
        local baseRate = 0.05
        local dynamicRate = math.min(0.3, 0.000035 * amount)
    
        local interestRate = baseRate + dynamicRate
    
        local overpayment = amount * interestRate
        local amountToReturn = amount + overpayment
        
        return amountToReturn, interestRate
    end

    function OpenLoanMenu(squad)
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 300)
        frame:SetTitle("Оформление кредита")
        frame:Center()
        frame:MakePopup()
        
        local infoLabel = vgui.Create("DLabel", frame)
        infoLabel:SetPos(20, 40)
        infoLabel:SetText("Введите желаемую сумму кредита:")
        infoLabel:SizeToContents()
        
        --[[local moneyEntry = vgui.Create("DTextEntry", frame)
        moneyEntry:SetPos(20, 70)
        moneyEntry:SetSize(360, 30)
        moneyEntry:SetNumeric(true)
        moneyEntry:SetPlaceholderText("Сумма кредита")]]

        local moneyEntry = vgui.Create( "DNumSlider", frame )
        moneyEntry:SetPos( 20, 70 )			
        moneyEntry:SetSize( 360, 30 )		
        moneyEntry:SetText( "Сумма кредита" )
        moneyEntry:SetMin( 0 )				 
        moneyEntry:SetMax( 350000 )			
        moneyEntry:SetDecimals( 0 )			
        
        local downPaymentLabel = vgui.Create("DLabel", frame)
        downPaymentLabel:SetPos(20, 120)
        downPaymentLabel:SetText("Первоначальный взнос: $0")
        downPaymentLabel:SizeToContents()
        
        local interestLabel = vgui.Create("DLabel", frame)
        interestLabel:SetPos(20, 140)
        interestLabel:SetText("Проценты по кредиту (10%): $0")
        interestLabel:SizeToContents()
        
        local totalLabel = vgui.Create("DLabel", frame)
        totalLabel:SetPos(20, 160)
        totalLabel:SetText("Итого к возврату: $0")
        totalLabel:SizeToContents()
        
        local submitBtn = vgui.Create("DButton", frame)
        submitBtn:SetPos(20, 220)
        submitBtn:SetSize(360, 40)
        submitBtn:SetText("Оформить кредит")
        
        local function UpdateCalculations()
            local amount = tonumber(moneyEntry:GetValue()) or 0

            if amount > 350000 then
                amount = math.Clamp(amount, 1, 350000)
                moneyEntry:SetText( tostring(amount) )
            end

            local baseRate = 0.05
            local dynamicRate = math.min(0.3, 0.000035 * amount)

            local interestRate = baseRate + dynamicRate

            local downPayment = math.Round(amount * 0.05, 0)
            local overpayment = amount * interestRate
            local amountToReturn = amount + overpayment

            downPaymentLabel:SetText("Залог: $" .. downPayment)
            interestLabel:SetText("Проценты по кредиту (" .. math.Round(interestRate * 100, 0) .. "%): " .. format_num(overpayment, 0) .. "$")
            totalLabel:SetText("Итого к возврату: " .. format_num(amountToReturn, 0) .. "$")

            downPaymentLabel:SizeToContents()
            interestLabel:SizeToContents()
            totalLabel:SizeToContents()
        end

        moneyEntry.OnValueChanged = UpdateCalculations

        submitBtn.DoClick = function()
            local amount = tonumber(moneyEntry:GetValue()) or 0
            if amount <= 0 then
                Derma_Message("Введите корректную сумму кредита!", "Ошибка", "OK")
                return
            end

            if squad.money < amount * 0.05 then
                Derma_Message("Не хватает денег для залога!", "Ошибка", "OK")
                return
            end

            --Derma_Message("Кредит на сумму " .. format_num(amount, 0) .. "$ успешно оформлен!", "Успех", "OK")

            net.Start("lanrp.MakeLoan")
            net.WriteInt(amount, 20)
            net.SendToServer()

            frame:Close()
        end

        UpdateCalculations()
    end

    function OpenDebtMenu(value)
        --[[local Debt = LoanCalculations(value)

        Derma_Query(
            "Вы готовы оплатить: " .. format_num(Debt, 0) .. "$ ?",

            "Оплачивание кредита",

            "Да",
            function() 
                net.Start("lanrp.UpdateLoan")
			    net.SendToServer()
            end,

	        "Нет",
	        function() end
        )]]

        local squad = SquadMenu.mySquad

        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 230)
        frame:SetTitle("Погашение кредита")
        frame:Center()
        frame:MakePopup()
        
        local infoLabel = vgui.Create("DLabel", frame)
        infoLabel:SetPos(20, 40)
        infoLabel:SetText("Ваш текущий долг: " .. format_num(squad.Loan.money, 0))
        infoLabel:SizeToContents()

        local moneyEntry = vgui.Create( "DNumSlider", frame )
        moneyEntry:SetPos( 20, 70 )			
        moneyEntry:SetSize( 360, 30 )		
        moneyEntry:SetText( "Сумма возврата" )
        moneyEntry:SetMin( 0 )				 
        moneyEntry:SetMax( squad.Loan.money )		
        moneyEntry:SetValue( 0 )	
        moneyEntry:SetDecimals( 0 )			
        
        local downPaymentLabel = vgui.Create("DLabel", frame)
        downPaymentLabel:SetPos(20, 120)
        downPaymentLabel:SetText("Возвращение долга: 0%")
        downPaymentLabel:SizeToContents()
        
        local interestLabel = vgui.Create("DLabel", frame)
        interestLabel:SetPos(20, 140)
        interestLabel:SetText("Остаток: $" .. squad.Loan.money)
        interestLabel:SizeToContents()
        
        --[[local totalLabel = vgui.Create("DLabel", frame)
        totalLabel:SetPos(20, 160)
        totalLabel:SetText("Итого к возврату: $0")
        totalLabel:SizeToContents()]]
        
        local submitBtn = vgui.Create("DButton", frame)
        submitBtn:SetPos(20, 170)
        submitBtn:SetSize(360, 40)
        submitBtn:SetText("Погасить")
        
        local function UpdateCalculations()
            local amount = tonumber(moneyEntry:GetValue()) or 0
            
            local dynamicRate = math.floor(amount / (squad.Loan.money * 5/100)) * (squad.Loan.money * 5/100)

            local downPayment = (dynamicRate / squad.Loan.money) * 100

            downPaymentLabel:SetText("Возвращение долга: " .. downPayment .. "%")
            downPaymentLabel:SizeToContents()

            interestLabel:SetText("Остаток: $" .. format_num(squad.Loan.money - amount, 0))
            interestLabel:SizeToContents()

        end

        moneyEntry.OnValueChanged = UpdateCalculations

        submitBtn.DoClick = function()
            local amount = tonumber(moneyEntry:GetValue()) or 0
            if amount <= 0 then
                Derma_Message("Введите корректную сумму!", "Ошибка", "OK")
                return
            end

            if squad.money < amount then
                Derma_Message("Не хватает денег для погашения!", "Ошибка", "OK")
                return
            end

            net.Start("lanrp.UpdateLoan")
            net.WriteFloat(amount)
			net.SendToServer()

            frame:Close()
        end

        UpdateCalculations()
    end
end