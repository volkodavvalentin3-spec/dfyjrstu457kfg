include("shared.lua")


net.Receive( "set_schneider_range", function()
	
	local ent = net.ReadEntity()
    local range = net.ReadFloat()
    local turn = net.ReadFloat()
	if !IsValid(ent) then return end
	
    SetSchneiderRange(ent, range, turn)
end)

SchneiderRange = 50
SchneiderTurn = 0

function SetSchneiderRange(ent, range, turn)

    local TrueVector = (ent:GetPos() + (ent:GetAngles():Forward() * SchneiderRange * 45) + ent:GetAngles():Right() * SchneiderTurn * 45) + Vector(0,0, 1024)

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 180)
    frame:SetTitle("Гаубица")
    frame:Center()
    frame:MakePopup()
    frame.OnClose = function(self)
        net.Start("set_schneider_range")
            net.WriteEntity(ent)
            net.WriteBool(false)
            net.WriteFloat(SchneiderRange)
            net.WriteFloat(SchneiderTurn)
        net.SendToServer()
    end

    local Xvector = vgui.Create( "DLabel", frame )
    Xvector:SetPos( 25, 40 )
    Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))

    local Yvector = vgui.Create( "DLabel", frame )
    Yvector:SetPos( 75, 40 )
    Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))

    local slider = vgui.Create("DNumSlider", frame)
    slider:SetText( "Расстояние" )
    slider:SetPos(25, 70)
    slider:SetSize(250, 20)
    slider:SetMin(50)
    slider:SetMax(250) -- Максимальное расстояние в метрах
    slider:SetValue(range)
    slider:SetDecimals(0)
    slider.OnValueChanged = function(self, value)
        SchneiderRange = math.Round(value, 0)

        local newangel = ent:GetAngles()
        newangel.y = newangel.y + -SchneiderTurn

        local TrueVector = (ent:GetPos() + (newangel:Forward() * SchneiderRange * 45)) + Vector(0,0, 1024)

        debugoverlay.Axis(TrueVector, newangel, 100, 3, true)

        Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))
        Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))
    end

    local angleSlider = vgui.Create("DNumSlider", frame)
    angleSlider:SetText( "Угол" )
    angleSlider:SetPos(25, 100)
    angleSlider:SetSize(250, 20)
    angleSlider:SetMin(-30)
    angleSlider:SetMax(30) -- Максимальный угол в градусах
    angleSlider:SetValue(turn)
    angleSlider:SetDecimals(0)
    angleSlider.OnValueChanged = function(self, value)
        SchneiderTurn = math.Round(value, 0)
        
        local newangel = ent:GetAngles()
        newangel.y = newangel.y + -SchneiderTurn

        local TrueVector = (ent:GetPos() + (newangel:Forward() * SchneiderRange * 45)) + Vector(0,0, 1024)

        debugoverlay.Axis(TrueVector, newangel, 100, 3, true)

        Xvector:SetText( "X: " .. math.Round(math.ceil(100*TrueVector.x)/10000))
        Yvector:SetText( "Y: " .. math.Round(math.ceil(100*TrueVector.y)/10000))
    end

    local button = vgui.Create("DButton", frame)
    button:SetPos(100, 140)
    button:SetSize(100, 30)
    button:SetText("ВЫСТРЕЛ")
    button.DoClick = function()
        net.Start("set_schneider_range")
            net.WriteEntity(ent)
            net.WriteBool(true)
            net.WriteFloat(SchneiderRange)
            net.WriteFloat(SchneiderTurn)
        net.SendToServer()

        frame:Close()
    end
end

concommand.Add("open_artillery_panel", SetSchneiderRange)