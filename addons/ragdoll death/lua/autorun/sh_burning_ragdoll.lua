local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

local function TransformRagdoll(ragdoll)
    if not IsValid(ragdoll) then
        return
    end

    if ragdoll:GetModel() == "models/player/skeleton.mdl" then
        SafeRemoveEntityDelayed( ragdoll, 5 )
        return
    end

    local ragdollPos = ragdoll:GetPos()
    local ragdollAng = ragdoll:GetAngles()
    local ragdollVel = ragdoll:GetVelocity()

    local newModel = "models/player/charple.mdl"
    if ragdoll:GetModel() == newModel then
        newModel = "models/player/skeleton.mdl"
    end

    -- Create the new ragdoll at the same position and orientation
    local newRagdoll = ents.Create("prop_ragdoll")
    newRagdoll:SetModel(newModel)
    newRagdoll:SetPos(ragdollPos)
    newRagdoll:SetAngles(ragdollAng)
    newRagdoll:Spawn()

    newRagdoll.EzWarUse = true

    -- Set the pose of the new ragdoll
    for i = 0, newRagdoll:GetPhysicsObjectCount() - 1 do
        local bone = newRagdoll:GetPhysicsObjectNum(i)
        if IsValid(bone) then
            local ragdollBone = ragdoll:GetPhysicsObjectNum(i)
            if IsValid(ragdollBone) then
                bone:SetPos(ragdollBone:GetPos())
                bone:SetAngles(ragdollBone:GetAngles())
                bone:EnableMotion(false)
            end
        end
    end

    -- Copy velocity to the new ragdoll
    --newRagdoll:GetPhysicsObject():SetVelocity(ragdollVel)
    newRagdoll:SetCollisionGroup(ragdoll:GetCollisionGroup())

    SafeRemoveEntityDelayed( newRagdoll, 60 )

    -- Remove the original ragdoll
    ragdoll:Remove()
end

hook.Add("EntityTakeDamage", "Detect", function(ragdoll, dmginf)
	if ragdoll:GetClass() == "prop_ragdoll" and dmginf:IsDamageType(DMG_BURN) then
        
        ragdoll.fireStart = ragdoll.fireStart or CurTime() + 7

        if ragdoll.fireStart <= CurTime() then
            TransformRagdoll(ragdoll)
        end

    end
end)
