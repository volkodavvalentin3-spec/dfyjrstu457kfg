local SelectorButtons = {
    {
        label = "Fence",
        type = BUILD_FENCE,
        models = BuildConf.Models[BUILD_FENCE]
    },
     {
        label = "Foundation",
        type = BUILD_FOUND,
        models = BuildConf.Models[BUILD_FOUND]
    },
    {
        label = "Walls",
        type = BUILD_WALLS,
        models = BuildConf.Models[BUILD_WALLS]
    },
    {
        label = "Plates",
        type = BUILD_PLATE,
        models = BuildConf.Models[BUILD_PLATE]
    },
    {
        label = "Stairs",
        type = BUILD_STAIR,
        models = BuildConf.Models[BUILD_STAIR]
    },
    {
        label = "Roofs",
        type = BUILD_CEIL,
        models = BuildConf.Models[BUILD_CEIL]
    },
    {
        label = "Doors",
        type = BUILD_DOOR,
        models = BuildConf.Models[BUILD_DOOR]
    },
    {
        label = "Other",
        type = BUILD_OTHER,
        models = BuildConf.Models[BUILD_OTHER]
    },
    {
        label = "SETTINGS",
        click = function()
            local frame = vgui.Create("DFrame")
            frame:SetSize(300, 300)
            frame:SetTitle("Settings")
            frame:Center()
            frame:MakePopup()

            local panel = vgui.Create("DPanel", frame)
            panel:Dock(FILL)

            local form = vgui.Create( "DForm", panel )
            form:SetLabel("Settings")
            form:Dock(FILL)
            form:CheckBox( "Set angles to relate for player view", "b_ang_from_view",0 )
            form:CheckBox( "Show angles, pos, etc", "b_view_opt",0 )
            form:NumSlider( "Drag by mouse wheel", "b_drag_mw",1,10,0 )

            form:SetExpanded(true)
        end
    },
    --[[
    {
        label = "X",
        //type = BUILD_OTHER,
        //models = BuildConf.Models[BUILD_OTHER]
        click = function(self)
            self.sel:Remove()
        end
    },
    --]]
}

function SWEP:ShowSelector(open)
    self.SelMenuCD = self.SelMenuCD or 0
    if open then
        if IsValid(self.SelMenu) then return end
    else
        if IsValid(self.SelMenu) then
            self.SelMenu:Remove()
            self.SelMenu = nil

        end    
        return
    end

    local wep = self

    local wdt,hgt = 700, 700
    local selector = vgui.Create("DPanel")
    selector:SetSize(wdt,hgt)
    selector:Center()
    selector:MakePopup()

    local function ShowModels(categ)
        local i = 1
        selector.btns = {}
        local models = SelectorButtons[categ].models
        local typ = SelectorButtons[categ].type
        for degrees = 1, 360, 360 / (#models) do
            local x = (wdt / 2) + math.cos(math.rad(degrees)) * 175
            local y = (wdt / 2) + math.sin(math.rad(degrees)) * 175

            local icon = vgui.Create("SpawnIcon", selector)
            local size = math.Clamp(200-(#models*20)  ,70, 200)
            icon:SetSize(size, size)
            icon:SetPos(x - (size/2), y  - (size/2))

            local mod = models[i]
            if istable(mod) then
                icon:SetModel( mod.m, mod.s )
            else
                icon:SetModel( mod )
            end
            icon.type = typ
            icon.id = i
            function icon:DoClick()
                net.Start("build_select_mode")
                net.WriteUInt(self.type, 4)
                net.WriteUInt(self.id, 8)
                net.SendToServer()

                self:GetParent():Remove()

                wep:SetBuildType(self.type)
                wep:SetBuildModel(self.id)

                wep:RemoveGhost()
                wep:CreateGhost()

                selector:Remove()
            end
            
            
            i = i + 1
        end
    end

    local function ClearAllBtns()
        for i = 1, #selector.btns do
            selector.btns[i]:Remove()
        end
    end


    function selector:Paint(w, h)
    end

    local i = 1
    selector.btns = {}
    for degrees = 1, 360, 360 / (#SelectorButtons) do
        local x = (wdt / 2) + math.cos(math.rad(degrees)) * 175
        local y = (wdt / 2) + math.sin(math.rad(degrees)) * 175

        local btn = vgui.Create("DButton", selector)
        btn:SetPos(x-75,y-75)
        btn:SetSize(150,150)
        btn:SetText("")
        
        btn.id  = i
        //btn.type = SelectorButtons[i].type
        btn.Label = SelectorButtons[i].label
        btn.sel = selector
        if SelectorButtons[i].click then
            btn.DoClick = SelectorButtons[i].click
        else
            function btn:DoClick()
                ClearAllBtns()
                ShowModels(self.id)
            end
        end

        function btn:Paint(w,h)
            surface.SetFont("DermaLarge")

            if self:IsHovered() then
                surface.SetTextColor(255,255,255,255)
            else
                surface.SetTextColor(200,200,200,255)
            end
            
            local tw, th = surface.GetTextSize( self.Label )
            surface.SetTextPos((w/2)- tw/2 , (h / 2)- th/2 )
            surface.DrawText(self.Label)
        end

        selector.btns[i] = btn
        i = i + 1
    end


    self.SelMenu = selector
    self.SelMenuOpen = true
    
end