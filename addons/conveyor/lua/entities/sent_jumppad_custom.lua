AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sent_jumppad"
DEFINE_BASECLASS("sent_jumppad")

ENT.PrintName = "Jumppad Custom"
ENT.Author = "Digaly"
ENT.Contact = ""
ENT.Purpose = "See for yourself."
ENT.Information = "See for yourself."
ENT.Category = "Speedpads + Jumppads"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Editable = true

if SERVER then
    function ENT:Initialize()
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    end
end