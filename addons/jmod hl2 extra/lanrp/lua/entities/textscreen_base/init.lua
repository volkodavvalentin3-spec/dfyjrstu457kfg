AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("textscreen_menu_open")

local sound_break = {
    "physics/wood/wood_box_impact_hard1.wav",
    "physics/wood/wood_box_impact_hard2.wav",
    "physics/wood/wood_box_impact_hard3.wav",
    "physics/wood/wood_box_Impact_hard4.wav",
    "physics/wood/wood_box_impact_hard5.wav",
    "physics/wood/wood_box_impact_hard6.wav",
}

ENT.HP = 100

function ENT:Initialize()
    self:SetTextValue("Нажмите Е чтобы написать")
    self:SetTextColor(Vector(255, 255, 255))

    self:SetModel(self.Model)
    self:SetColor(self.Color)
    self:SetMaterial( self.Material )
    
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    
    self:SetAngles(self:GetAngles() + self.SpawnAngles)
    
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:Wake()
    end
end

function ENT:Use(ply)

    if ply:GetSquadID() == -1 then ply:ChatPrint("У тебя нет фракции") return end

    if self.TextOwner == nil then
        net.Start("textscreen_menu_open")
        net.WriteEntity(self)
        net.Send(ply)
    elseif self.TextOwner == ply:GetSquadID() then
        net.Start("textscreen_menu_open")
        net.WriteEntity(self)
        net.Send(ply)
    end

end

function ENT:BreakingEffect()
    local mat = self:GetMaterialType()

    local eff = EffectData()
    eff:SetOrigin(self:GetPos())
    eff:SetScale(0.5)
    util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
    local snd = table.Random(sound_break)
    sound.Play(snd, self:GetPos(),SNDLVL_180dB, math.random(30, 50))
end

function ENT:OnTakeDamage(dmg)
    local mat = self:GetMaterialType()

    if !(mat == MAT_WOOD and dmg:GetDamageType() == DMG_BURN or dmg:GetDamageType() == DMG_MISSILEDEFENSE) and !(dmg:IsExplosionDamage()) then
        return
    end

    self.HP = self.HP - dmg:GetDamage()

    if dmg:GetDamageType() != DMG_BURN then
        local snd = table.Random(sound_break)
        sound.Play(snd, self:GetPos(),SNDLVL_180dB, math.random(30, 50))
    end

    if self.HP < 1 then
        self:BreakingEffect()
        self:Remove()
    else

        local f = dmg:GetDamageForce()
        timer.Simple(0.01, function()
            if !self:IsValid() then return end
            local phys = self:GetPhysicsObject()
            if phys then
                if phys:IsMotionEnabled() then
                    phys:ApplyForceCenter(f)
                end
            end
        end)
        
    end
    return dmg:GetDamage()
end

net.Receive("textscreen_menu_open", function( len, ply )
    local TargetEnt = net.ReadEntity()
    local TextData = net.ReadString()
    local ColorData = net.ReadVector()
    TargetEnt:SetTextValue(TextData)
    TargetEnt:SetTextColor(ColorData)

    TargetEnt.TextOwner = ply:GetSquadID() 
end)


