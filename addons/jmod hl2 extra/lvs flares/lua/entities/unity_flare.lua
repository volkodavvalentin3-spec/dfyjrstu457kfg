AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Flare"
ENT.Author = "DolUnity"

ENT.Spawnable = true

if CLIENT then return end

ENT.IdleSound = Sound("unitys_flares/burn.wav")

local color = Color(255, 150, 0)

function ENT:Initialize()
    UF:RegisterFlare(self)

    self:SetModel("models/items/ar2_grenade.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetColor(Color(0,0,0,0))
    self:SetRenderMode(RENDERMODE_TRANSCOLOR)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableGravity(true)
        phys:SetBuoyancyRatio(0)
        phys:SetDragCoefficient(-1)
        phys:SetDamping(0,0)
        phys:SetMass(0.05)
    end
    util.SpriteTrail(self, 0, color_white, false, 1, 30, 2, 5 / ((2 + 10) * 0.5), "trails/smoke.vmt")

    local flare = ents.Create("env_flare")
    flare:SetPos(self:GetPos())
    flare:SetAngles(self:GetAngles())
    flare:SetParent(self)
    flare:SetKeyValue("Scale","10")
    flare:SetKeyValue("spawnflags","4")
    flare:Spawn()
    flare:SetColor(color)

    self.CurrentIdleSound = CreateSound(self, self.IdleSound)
    self.CurrentIdleSound:SetSoundLevel(66)
    self.CurrentIdleSound:PlayEx(1, 100)

    timer.Simple(60, function() if IsValid(self) then self:Remove() end end)

    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetTrigger(true)
end

function ENT:OnTakeDamage()
    self:Remove()
end

function ENT:Think()
    if (bit.band(util.PointContents(self:GetPos()), CONTENTS_WATER) == CONTENTS_WATER) then
        self:Remove()
    end
end

ENT.EntsFilter = {}

function ENT:SetEntityFilter(filter)
    if not istable(filter) then return end

    self.EntsFilter = {}

    for _, ent in pairs(filter) do
        self.EntsFilter[ent] = true
    end
end

function ENT:StartTouch(entity)
    if self.EntsFilter[entity] then return end
end

function ENT:PhysicsCollide(data, entity    )
    if self.EntsFilter[entity:GetEntity()] or (IsValid(entity:GetEntity()) and entity:GetEntity():GetClass() == "trigger_teleport") then return end

    self:Remove()
end

function ENT:OnRemove()
    UF:UnRegisterFlare(self)
    if self.CurrentIdleSound then self.CurrentIdleSound:Stop() end
end
