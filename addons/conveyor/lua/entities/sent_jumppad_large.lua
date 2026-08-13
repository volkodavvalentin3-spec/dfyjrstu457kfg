AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sent_jumppad"
DEFINE_BASECLASS("sent_jumppad")

ENT.PrintName = "Jumppad (large)"
ENT.Author = "Digaly"
ENT.Contact = ""
ENT.Purpose = "See for yourself."
ENT.Information = "See for yourself."
ENT.Category = "Speedpads + Jumppads"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/hunter/plates/plate8x8.mdl")

        BaseClass.Initialize(self)
    end
end