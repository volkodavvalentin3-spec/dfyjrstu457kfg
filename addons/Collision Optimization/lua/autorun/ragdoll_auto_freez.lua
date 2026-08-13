CreateConVar("ragdoll_freeze_time", "3", FCVAR_ARCHIVE, "Time in seconds before a ragdoll is considered immobile and frozen")
CreateConVar("ragdoll_freeze_sensitivity", "80", FCVAR_ARCHIVE, "Sensitivity for detecting ragdoll movement (velocity threshold)")
CreateConVar("ragdoll_freeze_collision", "2", FCVAR_ARCHIVE, "Collision type for frozen ragdolls (1: NPC & entities, 2: Entities only, 3: No collisions)")

local ragdollLastMoveTime = {}

local function FreezeImmobileRagdolls()
    local currentTime = CurTime()
    local freezeTime = GetConVar("ragdoll_freeze_time"):GetFloat()
    local sensitivity = GetConVar("ragdoll_freeze_sensitivity"):GetFloat()
    local collisionType = GetConVar("ragdoll_freeze_collision"):GetInt()
    
    local collisionGroup
    if collisionType == 1 then
        collisionGroup = COLLISION_GROUP_NONE
    elseif collisionType == 2 then
        collisionGroup = COLLISION_GROUP_WEAPON
    elseif collisionType == 3 then
        collisionGroup = COLLISION_GROUP_DEBRIS_TRIGGER
    elseif collisionType == 4 then
        collisionGroup = COLLISION_GROUP_WORLD
    end
    
    for _, ragdoll in ipairs(ents.FindByClass("prop_ragdoll")) do
        if IsValid(ragdoll) then
            local isImmobile = true
            local physCount = ragdoll:GetPhysicsObjectCount()
            for i = 0, physCount - 1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                if IsValid(phys) then
                    local velocity = phys:GetVelocity():Length()
                    if velocity > sensitivity then
                        isImmobile = false
                        ragdollLastMoveTime[ragdoll] = currentTime
                        break
                    end
                end
            end

            if not ragdollLastMoveTime[ragdoll] then
                ragdollLastMoveTime[ragdoll] = currentTime
            end

            if isImmobile and (currentTime - ragdollLastMoveTime[ragdoll] >= freezeTime) then
                for i = 0, physCount - 1 do
                    local phys = ragdoll:GetPhysicsObjectNum(i)
                    if IsValid(phys) then
                        phys:EnableMotion(false)
                        phys:Sleep()
                    end
                end
                ragdoll:SetCollisionGroup(collisionGroup)
            else
                ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            end
        end
    end
end

timer.Create("FreezeImmobileRagdollsTimer",1, 0.2, FreezeImmobileRagdolls)
print("[MCG Ragdoll Freeze] Script loaded successfully.")

concommand.Add("npc_auto_freeze_reset", function()
    RunConsoleCommand("ragdoll_freeze_time", "3")
    RunConsoleCommand("ragdoll_freeze_sensitivity", "80")
    RunConsoleCommand("ragdoll_freeze_collision", "2")
end)
