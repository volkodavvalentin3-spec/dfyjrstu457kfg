local meta = FindMetaTable("Player")

function meta:IsPhysgunFizzling()
    if not GetConVar("physfiz_enabled"):GetBool() then return false end

    return self:GetNWFloat("PhysgunFizzleEnd", 0) > CurTime()
end

function meta:SetPhysgunFizzle(t)
    self:SetNWFloat("PhysgunFizzleEnd", t or 0)
end

function meta:AddPhysgunFizzle(t, override)
    self:SetNWFloat("PhysgunFizzleEnd", override and (CurTime() + t) or math.max(self:GetNWFloat("PhysgunFizzleEnd", 0), CurTime()) + t)
end

function meta:GetPhysgunFizzleTime()
    if not self:IsPhysgunFizzling() then return -1 end
    return self:GetNWFloat("PhysgunFizzleEnd", 0) - CurTime()
end

local function FizzleCommand(ply, ucmd)
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ply:IsPhysgunFizzling() then
        if CLIENT and GetConVar("sv_physfiz_unjam"):GetBool() then
            local curKey = (ucmd:KeyDown(IN_ATTACK) and 1 or 0) + (ucmd:KeyDown(IN_ATTACK2) and 2 or 0) + (ucmd:KeyDown(IN_RELOAD) and 4 or 0)
            local amt = 0

            if bit.band(curKey, 1) ~= 0 and bit.band(ply.FizzleLastKeys, 1) == 0 then
                amt = amt + 1
            end

            if bit.band(curKey, 2) ~= 0 and bit.band(ply.FizzleLastKeys, 2) == 0 then
                amt = amt + 1
            end

            if bit.band(curKey, 4) ~= 0 and bit.band(ply.FizzleLastKeys, 4) == 0 then
                amt = amt + 1
            end

            ply.FizzleLastKeys = curKey

            if amt > 0 then
                net.Start("physgunfizzle_unjam")
                    net.WriteUInt(amt, 2)
                net.SendToServer()
                surface.PlaySound("physics/metal/metal_box_footstep" .. math.random(1, 4) .. ".wav")
            end
        end

        ucmd:RemoveKey(IN_ATTACK)
        ucmd:RemoveKey(IN_ATTACK2)
        ucmd:RemoveKey(IN_RELOAD)
    end
end

hook.Add("StartCommand", "PhysgunFizzle", FizzleCommand)