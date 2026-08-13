local math, Sound, timer, Color, table, Vector, Angle, util, RunConsoleCommand = math, Sound, timer, Color, table, Vector, Angle, util, RunConsoleCommand

RunConsoleCommand("gmod_mcore_test", "1")
RunConsoleCommand("r_threaded_particles", "1")
RunConsoleCommand("r_queued_ropes", "1")
RunConsoleCommand("cl_threaded_client_leaf_system", "1")
RunConsoleCommand("r_threaded_renderables", "1")
RunConsoleCommand("mat_queue_mode", "2")

net.Receive("lanrp.ChatPrint", function()
    local tbl = net.ReadTable()

    chat.AddText(unpack(tbl))
end)

net.Receive("PlayLocalSound", function()
    local SoundString = net.ReadString()

    surface.PlaySound(SoundString)
end)

local clr_hint, clr_hint2 = Color(255, 255, 255, 30), Color(0, 0, 0, 10)
hook.Add( "PostDrawHUD", "PhysGunTool", function()
    local ply = LocalPlayer()

    if not IsValid(ply) then return end 
    if not ply:Alive() then return end 
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "weapon_physgun" then return end

    local W, H, Build = ScrW(), ScrH()
    local ToolBox = ply:GetWeapon("wep_jack_gmod_eztoolbox")

    if IsValid(ToolBox) and ToolBox:GetNW2Bool("EZoneHandedBuild", false) then
        draw.SimpleTextOutlined("ALT+LMB: use toolbox onehanded: "..ToolBox:GetSelectedBuild(), "Trebuchet24", W * .4, H * .7 + 60, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
    end
end)

local ShowNukePos
local NukePos

--[[net.Receive( "lanrp.sendnukepos", function()
    ShowNukePos = net.ReadBool()
    NukePos = net.ReadVector()
end)]]

--[[hook.Add( "PostDrawHUD", "DrawRocketPos", function()
    local ply = LocalPlayer()
    local X = ScrH()
    local Y = ScrW()

    if IsValid(ply) and ShowNukePos then
        surface.SetTextColor( 255, 255, 255,255 )
        surface.SetTextPos( X*0.5, Y/3.5 )
        surface.DrawText( "Координаты наведения:")  
        surface.SetTextPos( X*0.5, Y/3.5 + 16)
        surface.DrawText( "X: ~ "..math.Round( math.ceil( 100 * NukePos.x ) / 10000)) 
        surface.SetTextPos( X*0.5, Y/3.5 + 32)
        surface.DrawText( "Y: ~ "..math.Round( math.ceil( 100 * NukePos.y ) / 10000))
    end
end)]]

local DontPhysPickUp = {
    ["build_prop"] = true,
    ["prop_dynamic"] = true,
    ["func_physbox"] = true,
    ["prop_door_rotating"] = true,

}

hook.Add( "PhysgunPickup", "AllowPlayerPickup", function( ply, ent )
    if DontPhysPickUp[ent:GetClass()] then return false end
    if ent:IsNPC() or ent:IsNextBot() then return false end
end)

-------ПЕРЕМЕЩЕНИЕ-------
hook.Add("SetupMove", "NoStrafe", function(ply, mv, cmd )
    if ply:KeyDown( IN_SPEED ) then
        mv:SetSideSpeed( 0 )
    end
        
    local factor = math.Remap(math.Clamp(math.abs(cmd:GetMouseX() / 5), 0, 50), 0, 50, 1, 0.2)
    ply:SetRunSpeed(Lerp(FrameTime() * 15, ply:GetRunSpeed(), ply:GetRunSpeed() * factor))
end)

local plyLastJump = {}

hook.Add("StartCommand", "BlockJump", function(ply, cmd)
    if not plyLastJump[ply] then
        plyLastJump[ply] = 0
    end

    if ply:IsPlayer() and ply:GetMoveType() ~= MOVETYPE_NOCLIP and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= "character_omniman" then

        if plyLastJump[ply] + 1.5 > CurTime() then
            cmd:RemoveKey(IN_JUMP)
        elseif ply:KeyDown(IN_JUMP) then

            plyLastJump[ply] = CurTime()
        end
    end
end)

hook.Add("PlayerStartVoice", "ImageOnVoice", function( ply, plyIndex )
	if ply ~= LocalPlayer() then
        if ply:GetPos():Distance2DSqr(LocalPlayer():GetPos()) >= 200^2 then
            return false
        end
    end
end)


local MetaClientModel = FindMetaTable("CSEnt")

MetaClientModel.old_DrawModel = FindMetaTable("Entity").DrawModel

function MetaClientModel:DrawModel()
    if self:GetModel() == "models/props_c17/substation_stripebox01a.mdl" then
        self:old_DrawModel()
    elseif ((LocalPlayer():GetFOV() * EyePos():Distance2DSqr(self:GetPos()) / 10000) <= 256^2) or (self:GetPos():Distance2DSqr( Vector(0,0,0) ) <= 10^2) then
        self:old_DrawModel()
    end
end
