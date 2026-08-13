AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "sent_speedtube"
DEFINE_BASECLASS("sent_speedtube")

ENT.PrintName = "Speedtube x50"
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
        BaseClass.Initialize(self)

        self:SetColor(Color(255, 100, 100, 255))
		self:SetSpeed(5000)
    end
end