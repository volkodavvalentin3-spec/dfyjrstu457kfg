//include("sh_config.lua")

if CLIENT then return end

include("sh_save.lua")

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

util.AddNetworkString("build_select_mode")

local function freezeBuild(par)
    local all_ents = {}

    local i = 1
    local function get2(par)
        all_ents[par] = true
        for child, wel in pairs(par:GetAllConnectedProps()) do
            if !child:IsValid() then continue end
            i = i + 1
            if !all_ents[child] then
                all_ents[child] = true
                get2(child) 
            end
        end
    end
    
    get2(par)
    for ent, _ in pairs(all_ents) do
        if !ent:IsValid() then continue end
        local phys = ent:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:EnableMotion( false )
        end
    end
end

concommand.Add("build_freeze", function(ply)
    local t = ply:GetEyeTrace()
    local ent = t.Entity

    if ent:IsValid() then
        if ent:GetClass() == "build_prop" then
            freezeBuild(ent)
        end
    end
end)


hook.Add("PlayerUse", "ForceOpenDoor", function(ply, door)
    if door.IsBuildDoor then
        local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)

        if door.LockColldown ~= nil then
            if door.LockColldown >= CurTime() then
                return false
            end
        end

        if door.Squad == nil and (ply:GetSquadID() ~= -1) then
            door.Squad = ply:GetSquadID()
        end

        if door.isLocked == nil then
            door.isLocked = false
        end

        if door.isOpen == nil then
            door.isOpen = false
        end

        if Alt and ply:GetSquadID() == door.Squad then
            if not door.isLocked then

                door.isLocked = not door.isLocked

                door:Fire("lock")

                door:EmitSound("doors/door_locked2.wav")

                door.LockColldown = CurTime() + 0.5
                return false
            else
                door.isLocked = not door.isLocked

                door:Fire("unlock")

                door:EmitSound("doors/door_latch1.wav")

                door.LockColldown = CurTime() + 0.5
                return false
            end
        end

        if not door.isLocked then
            
            if door.isOpen then
                door:Fire("close")
                door.isOpen = false
            else
                door:Fire("open")
                door.isOpen = true
            end
            
            door.LockColldown = CurTime() + 0.5
        else
            door:EmitSound("doors/door_locked2.wav")
            door.LockColldown = CurTime() + 0.5
            return false
        end
    end
end)