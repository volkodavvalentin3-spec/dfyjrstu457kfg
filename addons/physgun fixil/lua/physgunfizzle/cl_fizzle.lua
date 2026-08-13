local mat = Material("sprites/light_ignorez")
local mat2 = Material("sprites/glow04_noz")

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
local function FizzleDraw(vm, ply, wpn)
    if not ply:Alive() then return end

    if ply:IsPhysgunFizzling() and not ply.PhysgunFizzleActive then
        ply.PhysgunFizzleActive = true
    end

    if ply:IsPhysgunFizzling() and LocalPlayer() == ply and wpn:GetClass() == "weapon_physgun" then

        --[[
            Note: SendWeaponAnim() does not seem to have any effect in a listen/dedicated server,
            though it works fine in singleplayer. Probably needs a shared context instead of
            client or server only. A fix is TODO.
        ]]
        if GetConVar("sv_physfiz_unjam"):GetBool() and (ply.FizzleLastKeys or 0) > 0 then
            wpn:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        end

        if (ply.PhysgunFizzleNext or 0) < CurTime() then
            ply.PhysgunFizzleNext = CurTime() + math.random() * 0.5 + 0.3

            if GetConVar("cl_physfiz_sounds"):GetBool() then
                surface.PlaySound("ambient/energy/spark" .. math.random(1, 6) .. ".wav")
            end

            wpn:SendWeaponAnim(ACT_VM_RELOAD)
        end

        local bpos, bang = Vector(0, 0, 0), Angle(0, 0, 0)
        local m = vm:GetBoneMatrix(vm:LookupBone("Base"))

        if m then
            bpos, bang = m:GetTranslation(), m:GetAngles()
            bpos = bpos + vm:GetForward() * 24 + vm:GetRight() * 0 + vm:GetUp() * -4
        end

        local siz = math.sin(SysTime() * 8) * 16 + 48
        render.SetMaterial(mat)
        render.DrawSprite(bpos, siz, siz, ply:GetWeaponColor():ToColor())
    end

    if not ply:IsPhysgunFizzling() and ply.PhysgunFizzleActive then
        ply.PhysgunFizzleActive = false
        surface.PlaySound("ambient/energy/weld1.wav")

        if wpn:GetClass() == "weapon_physgun" then
            wpn:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        end
    end
end

hook.Add("PostDrawViewModel", "PhysgunFizzle", FizzleDraw)

local function FizzleDrawWorld()
    for _, ply in player.Iterator() do
        if ply == LocalPlayer() or not ply:Alive() or not IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() ~= "weapon_physgun" or not ply:IsPhysgunFizzling() or not IsValid(ply) then continue end
        local bpos, bang = Vector(0, 0, 0), Angle(0, 0, 0)
        local m = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Anim_Attachment_RH"))

        if m then
            bpos, bang = m:GetTranslation(), m:GetAngles()
            bpos = bpos + bang:Forward() * -4 + bang:Right() * -6 + bang:Up() * 14
        end

        local tr = util.QuickTrace(LocalPlayer():EyePos(), bpos - LocalPlayer():EyePos(), LocalPlayer())

        if not tr.Hit or tr.Entity == ply then
            local siz = math.sin(SysTime() * 8) * 16 + 48
            render.SetMaterial(mat2)
            render.DrawSprite(bpos, siz, siz, GetConVar("cl_physfiz_whiteflash"):GetBool() and Color(255, 255, 255) or ply:GetWeaponColor():ToColor())
        end
    end
end

hook.Add("PostDrawTranslucentRenderables", "PhysgunFizzle", FizzleDrawWorld)