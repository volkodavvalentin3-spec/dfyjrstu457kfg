AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ent_jack_gmod_ezmachine_base"

ENT.Author = "RusLanConnection"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.PrintName = "EZ sorter"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.MaxConnectionRange = 512

ENT.Model = "models/props_c17/furnitureStove001a.mdl"
ENT.JModGUIcolorable = true

ENT.EZconsumes = {
    JMod.EZ_RESOURCE_TYPES.BASICPARTS
}

function ENT:CustomSetupDataTables()
    self:NetworkVar("String", 0, "TargetResource")

    if SERVER then
        self:SetTargetResource(JMod.EZ_RESOURCE_TYPES.BASICPARTS)
    end
end

if SERVER then
    util.AddNetworkString("LANRP.sorterOpenMenu")
    util.AddNetworkString("LANRP.sorterChange")
    
    function ENT:CustomInit()
        self:SetMaterial("phoenix_storms/dome")
        self.Trans = {}
    end

    function ENT:PhysicsCollide(data, physobj)
        if (data.Speed > 80) and (data.DeltaTime > 0.2) then
            self:EmitSound("Metal_Box.ImpactSoft")
        end
        
        if self:GetState() == JMod.EZ_STATE_BROKEN then return end

        local ent = data.HitEntity
        if not IsValid(ent) then return end

        local Phys = ent:GetPhysicsObject()

        if IsValid(Phys) and data.DeltaTime >= 0.1 and ent.IsJackyEZresource then
            self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
                
            table.insert(self.Trans, {enttype = ent.EZsupplies, amount = ent:GetResource()})

            ent:Remove()    
        end
    end

    function ENT:Use(ply)
        if self:GetState() == JMod.EZ_STATE_BROKEN then return end

        if ply:KeyDown(IN_WALK) and ply:GetSquadID() == self.EZowner:GetSquadID() then
            net.Start("LANRP.sorterOpenMenu")
            net.WriteEntity(self)
            net.Send(ply)
        end
    end
    
    function ENT:Think()
        for k, v in pairs(self.Trans) do
            local pos

            if v.enttype == self:GetTargetResource() then
                pos = Vector(0, -55, 30)
            else
                pos = Vector(0, 55, 30)
            end

            JMod.MachineSpawnResource(self, v.enttype, v.amount, pos, Angle(0, 0, 0), _, false)

            self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(80, 120))
            self:EmitSound("Metal_Box.ImpactSoft")

            table.remove(self.Trans, k)
            
            break
        end

        self:NextThink(CurTime() + 2)
        return true
    end

    net.Receive("LANRP.sorterChange", function(_, ply)
        local ent = net.ReadEntity()
        local resourcik = net.ReadString()

        local tr = ply:GetEyeTrace()

        if IsValid(ent) and ent:GetClass() == "ent_rus_sorter" and tr.Entity == ent
        and ply:GetSquadID() == ent.EZowner:GetSquadID() then
            ent:SetTargetResource(resourcik)
        end
    end)
else
    surface.CreateFont("lanrp.sorter", {
        font = "Roboto",
        size = 24,
        extended = true
    })

    sorterMenushka = nil

    local transparentc = Color(50, 50, 50, 100)

    local blacklist = {
        [JMod.EZ_RESOURCE_TYPES.LEADORE] = true,
        [JMod.EZ_RESOURCE_TYPES.ALUMINUM] = true,
        [JMod.EZ_RESOURCE_TYPES.LEAD] = true,
        [JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = true, 
        [JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = true, 
        [JMod.EZ_RESOURCE_TYPES.TITANIUM] = true, 
        [JMod.EZ_RESOURCE_TYPES.PLATINUM] = true, 
        [JMod.EZ_RESOURCE_TYPES.CONCRETE] = true,
        [JMod.EZ_RESOURCE_TYPES.SAND] = true,
        [JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = true
    }
    
    local blurMat = Material("pp/blurscreen")
	local Dynamic = 0
    
    local function BlurBackground(panel)
		if not (IsValid(panel) and panel:IsVisible()) then return end
		local layers, density, alpha = 1, 1, 255
		local x, y = panel:LocalToScreen(0, 0)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(blurMat)
		local FrameRate, Num, Dark = 1 / FrameTime(), 5, 150
	
		for i = 1, Num do
			blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
			blurMat:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		end
	
		surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
	end

    local function menushka()
        surface.PlaySound("snds_jack_gmod/ez_gui/menu_open.ogg")

        if IsValid(sorterMenushka) then sorterMenushka:Remove() end

        local machine = net.ReadEntity()

        local w, h = ScreenScale(90), ScreenScaleH(230)
        local height = ScreenScaleH(20)
        local icon_size = 30

        local panelka = vgui.Create("DFrame")
        panelka:SetSize(w, h)
        panelka:SetVisible(true)
        panelka:SetDraggable(true)
        panelka:ShowCloseButton(true)

        panelka:SetTitle("Сортировщик")

        function panelka:OnClose()
            surface.PlaySound("snds_jack_gmod/ez_gui/menu_close.ogg")
        end

        function panelka:Paint()
            BlurBackground(self)
        end
    
        panelka:MakePopup()
        panelka:Center()

        local res_list = vgui.Create("DScrollPanel", panelka)

        res_list:SetSize(w, h - 25)
        res_list:SetPos(0, 25)

        res_list.Paint = function() end
        
        panelka.resources = {}

        for k, v in pairs(JMod.EZ_RESOURCE_TYPES) do
            if blacklist[v] then continue end
            
            local ph = vgui.Create("DButton", res_list)
            ph:SetText("")
            ph:SetSize(w, height)

            ph:Dock(TOP)
            ph:DockMargin(0, 0, 0, 2)

            ph.resource = v
            ph.text = string.upper(v)
            ph.icon = JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[v]

            function ph:Paint(ww, hh)
                surface.SetDrawColor(transparentc)
                surface.DrawRect(0, 0, ww, hh)

                surface.SetDrawColor(color_white)
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(10, (hh * 0.5) - (icon_size * 0.5), icon_size, icon_size)

                draw.SimpleText(self.text, "DermaDefault", 10 + icon_size + 10, hh * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            function ph:DoClick()
                surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")

                net.Start("LANRP.sorterChange")
                net.WriteEntity(machine)
                net.WriteString(self.resource)
                net.SendToServer()

                panelka:Remove()
            end

            panelka.resources[#panelka.resources + 1] = {ph, v}
        end

        sorterMenushka = panelka
    end

    net.Receive("LANRP.sorterOpenMenu", menushka)

    local drawvec, drawang = Vector(0, 16, 0), Angle(-90, 0, 90)
    
    function ENT:Draw()
        self:DrawModel()

        JMod.HoloGraphicDisplay(self, drawvec, drawang, .07, 200, function()
			JMod.StandardResourceDisplay(self:GetTargetResource(), "", nil, 0, 0, 200, true, "JMod-Stencil", 220, false, 200, true)
		end)
    end
end