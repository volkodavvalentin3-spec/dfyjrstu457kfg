util.AddNetworkString("physgunfizzle_unjam")

hook.Add("PlayerSpawn", "PhysgunFizzle", function(ply)
    ply:SetPhysgunFizzle(0)
end)

hook.Add("PhysgunPickup", "PhysgunFizzle", function(ply, ent)
    if ply:IsPhysgunFizzling() then return false end -- Shouldn't be necessary, but as an anti-cheat measure
end)

hook.Add("OnPhysgunPickup", "PhysgunFizzle", function(ply, ent)
    ent.PhysgunPickup = ply
end)

hook.Add("PhysgunDrop", "PhysgunFizzle", function(ply, ent)
    ent.PhysgunPickup = nil
end)

hook.Add("PhysgunFreeze", "PhysgunFizzle", function(wep, physobj, ent, ply)
    ent.PhysgunPickup = nil
end)

local function FizzleDamage(ent, dmg, took)
    if not GetConVar("physfiz_enabled"):GetBool() then return end
    if not took or dmg:GetAttacker() == ent or dmg:GetAttacker():IsWorld() then return end
    if GetConVar("sv_physfiz_pvponly"):GetBool() and not dmg:GetAttacker():IsPlayer() then return end
    -- Either player took damage while using physgun...
    -- Or ent is a prop held by the player
    local ply = (ent:IsPlayer() and ent:KeyDown(IN_ATTACK) and ent) or (IsValid(ent.PhysgunPickup) and ent.PhysgunPickup:IsPlayer() and ent.PhysgunPickup)
    local isProp = not ent:IsPlayer()
    local wep = ply and ply:GetActiveWeapon()
	
    if ply and (IsValid(wep) and wep:GetClass() == "weapon_physgun") and not ply:IsPhysgunFizzling() then
        local chance = isProp and GetConVar("sv_physfiz_chance_prophit"):GetFloat() or GetConVar("sv_physfiz_chance_playerhit"):GetFloat()
        local threshold = GetConVar("sv_physfiz_chance_damagethreshold"):GetInt()

        if threshold > 0 and dmg:GetDamage() < threshold then
            if GetConVar("sv_physfiz_chance_damagethreshold_linear"):GetBool() then
                chance = chance * math.Clamp(dmg:GetDamage() / threshold, 0, 1)
            else
                chance = 0
            end
        end

        local override = hook.Run("PhysgunFizzleChance", ply, isProp, chance)
        chance = (isnumber(override) and override) or chance

        if math.random() <= chance then
            ply:AddPhysgunFizzle(math.random(GetConVar("sv_physfiz_timemin"):GetFloat(), GetConVar("sv_physfiz_timemax"):GetFloat()))
        end
    end
end

hook.Add("PostEntityTakeDamage", "PhysgunFizzle", FizzleDamage)

hook.Add("PlayerSpawnProp", "PhysgunFizzle", function(ply, mdl)
    if GetConVar("sv_physfiz_blockprop"):GetBool() and ply:IsPhysgunFizzling() then
        ply:SendLua("notification.AddLegacy('You can't do that while your Physics Gun is disabled!', 1, 5)")

        return false
    end
end)

net.Receive("physgunfizzle_unjam", function(len, ply)
    local amt = net.ReadUInt(3)
    if amt > 0 and ply:Alive() and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ply:IsPhysgunFizzling() then
        amt = amt * GetConVar("sv_physfiz_unjam_amount"):GetFloat()
        ply:SetNWFloat("PhysgunFizzleEnd", ply:GetNWFloat("PhysgunFizzleEnd", 0) - amt)
    end
end)