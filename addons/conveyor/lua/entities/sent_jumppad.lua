AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Jumppad"
ENT.Author = "Digaly"
ENT.Contact = ""
ENT.Purpose = "See for yourself."
ENT.Information = "See for yourself."
ENT.Category = "Speedpads + Jumppads"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled", { KeyName = "Enabled", Edit = { type = "Boolean", order = 1 } })
    self:NetworkVar("Int", 0, "Height", { KeyName = "Height", Edit = { type = "Number", order = 3 } })
    self:NetworkVar("Bool", 1, "ResetHealth", { KeyName = "ResetHealth", Edit = { type = "Boolean", order = 2 } })

    if SERVER then
        self:SetEnabled(true)
        self:SetHeight(100)
        self:SetResetHealth(true)
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

if SERVER then
    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMaterial("digaly/jumppad/jumppad")

        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end

    function ENT:SpawnFunction(ply, trace)
        if not trace.Hit then return end

        local e = ents.Create(ClassName or self.ClassName or "ent_conveyorbelt")
        if not (e and IsValid(e)) then
            if e.Remove then e:Remove() end
            return
        end
        e:SetPos(trace.HitPos + trace.HitNormal * 16)
        e.Owner = ply
        e:SetAngles(Angle(0, ply:GetAngles().y, 0))
        e:Spawn()
        e:Activate()

        return e
    end

    function ENT:Touch(hitEnt)
        if self:GetEnabled() then
            if IsValid(hitEnt) then

                if hitEnt:IsPlayer() then
                    if not hitEnt:Crouching() then
                        self:EmitSound("digaly/jumppad/bounce.wav", 60, 80)
                        hitEnt:SetVelocity(self:GetUp() * self:GetHeight() * 5)
                        if self:GetResetHealth() then
                            hitEnt:SetHealth(hitEnt:GetMaxHealth())
                        end
                    end
                elseif hitEnt:GetPhysicsObject():IsValid() then
                    if not (hitEnt:GetClass() == self:GetClass()) then
                        self:EmitSound("digaly/jumppad/bounce.wav", 60, 80)
                        hitEnt:GetPhysicsObject():ApplyForceCenter(self:GetUp() * self:GetHeight() * hitEnt:GetPhysicsObject():GetMass())
                    end
                end
            end
        end

        if IsValid(hitEnt) and hitEnt:GetPhysicsObject():IsValid() and not hitEnt:IsPlayer() then
            hitEnt:GetPhysicsObject():Wake()
        end
    end
end