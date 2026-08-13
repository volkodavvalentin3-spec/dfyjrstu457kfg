AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sent_conveyor"

ENT.PrintName = "Speedpad"
ENT.Author = "Digaly"
ENT.Contact = ""
ENT.Purpose = "See for yourself."
ENT.Information = "See for yourself."
ENT.Category = "Speedpads + Jumppads"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = true

if SERVER then
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

    function ENT:Initialize()
        self:SetModel("models/hunter/plates/plate1x5.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMaterial("digaly/speedpad_normal/speedpad_normal")
        self:SetSpeed(500)
        self:SetColor(Color(100, 100, 255, 255))

        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end
end