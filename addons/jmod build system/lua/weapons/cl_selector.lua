if SERVER then return end
print( "selector reload" )
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

    -- {
    --     label = "Gates",
    --     type = BUILD_GATE,
    --     models = BuildConf.Models[BUILD_GATE]
    -- },
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
}


surface.CreateFont( "BuildSel", {
    font = "DermaLarge",
    size =  33,
    weight = 500,
    shadow = true,
    antialias = true,
} )
--/// НЕРАБОТАЕТ ПОЧЕМУТО ИНОГДА, ЧУПАК АСЁЛКОДИНГ А РУБАТ НУБ
--[[
local function AddModelsWithSkins(mdl)
    local mdl_skins = {}
    for k, m in pairs(mdl) do
        local count = NumModelSkins( m )
        if count > 1 then
            for i=0, count - 1 do
                table.insert(mdl_skins, {mdl_id = k, mdl = m, skin = i})
            end
        else
 //           print( m .. " has 0 skins" )
            table.insert(mdl_skins, {mdl_id = k, mdl = m, skin = 0})
        end
    end

//    PrintTable(mdl_skins )
    return mdl_skins
end
--]]///ВОТ ЩАС ЗАРАБОТАЕТ

local function AddModelsWithSkins(mdl)
    local mdl_skins = {}
    for k, m in pairs(mdl) do
        local count = util.GetModelInfo( m ).SkinCount
        if count > 1 then
            for i=0, count - 1 do
                table.insert(mdl_skins, {mdl_id = k, mdl = m, skin = i})
            end
        else
 //           print( m .. " has 0 skins" )
            table.insert(mdl_skins, {mdl_id = k, mdl = m, skin = 0})
        end
    end

//    PrintTable(mdl_skins )
    return mdl_skins
end

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
        selector.btns = {}

        local typ = SelectorButtons[categ].type
        local models = SelectorButtons[categ].models
        
        if typ != BUILD_DOOR then
            models = AddModelsWithSkins(models)
        end

        //print(#models)

        if #models < 20 then
            local i = 1

            for degrees = 1, 360, 360 / (#models) do
                local x = (wdt / 2) + math.cos(math.rad(degrees)) * 200
                local y = (wdt / 2) + math.sin(math.rad(degrees)) * 200

                local icon = vgui.Create("SpawnIcon", selector)
                local size = math.Clamp(200-(#models*15)  ,70, 200)
                icon:SetSize(size, size)
                icon:SetPos(x - (size/2), y  - (size/2))

                local mod = models[i]
                //print(mod)
                //PrintTable(mod)
                //if istable(mod) then
                    icon:SetModel( mod.mdl, mod.skin or 0 )
                //end


                icon.type = typ
                icon.id = mod.mdl_id
                icon.skin = mod.skin
                function icon:DoClick()
                    net.Start("build_select_mode")
                    net.WriteUInt(self.type, 4)
                    net.WriteUInt(self.id, 8)
                    net.WriteUInt(self.skin, 8)
                    net.SendToServer()

                    self:GetParent():Remove()

                    wep:SetBuildType(self.type)
                    wep:SetBuildModel(self.id)
                    wep:SetBuildModelSkin(self.skin)


                    wep:RemoveGhost()
                    wep:CreateGhost()

                    selector:Remove()
                end
                
                i = i + 1
            end
        else
            local x, y = 0, 0
            local ymax = #models / 8
            //400/2 - (ymax*75)/2
            local start_y = (wdt / 2) - ((ymax+50)/2)
            
            //print(wdt)
            for i=1, #models do

                
                local xpos = ((x*75)+85) //(x * 200) + 50
                local ypos = ((y*75)+200)

                local icon = vgui.Create("SpawnIcon", selector)
                local size = 100//math.Clamp(200  ,70, 200)
                icon:SetSize(size, size)
                icon:SetPos(xpos - (size/2), ypos  - (size/2))

                local mod = models[i]

                icon:SetModel( mod.mdl, mod.skin or 0 )
    


                icon.type = typ
                icon.id = mod.mdl_id
                icon.skin = mod.skin
                function icon:DoClick()
                    net.Start("build_select_mode")
                    net.WriteUInt(self.type, 4)
                    net.WriteUInt(self.id, 8)
                    net.WriteUInt(self.skin, 8)
                    net.SendToServer()

                    self:GetParent():Remove()

                    wep:SetBuildType(self.type)
                    wep:SetBuildModel(self.id)
                    wep:SetBuildModelSkin(self.skin)


                    wep:RemoveGhost()
                    wep:CreateGhost()

                    selector:Remove()
                end
                x = x + 1
                if x > 7 then
                    y = y + 1
                    x = 0
                end
            end
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
            surface.SetFont("BuildSel")
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