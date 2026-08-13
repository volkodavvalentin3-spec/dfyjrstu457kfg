ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Textscreen"
ENT.Author = "PolandGingerbreads"
ENT.Category = "TextScreens"
ENT.Spawnable = true

ENT.SpawnAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/plates/plate075x105.mdl"
ENT.Material = "models/props_pipes/GutterMetal01a"
ENT.Color = Color(255, 255, 255, 255)
ENT.Mass = 20
ENT.DrawAngles = Angle(0, 90, 0)
ENT.DrawPos = Vector(-6, 0, 1.55)
ENT.FontSize = 13
ENT.MaxLines = 3
ENT.Font = "TextscreenFont"
ENT.OutlineWidht = 3

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "TextValue")
	self:NetworkVar("Vector", 0, "TextColor")
end
