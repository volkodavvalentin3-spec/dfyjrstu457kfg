ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Textscreen (noresize)"
ENT.Author = "PolandGingerbreads"
ENT.Category = "TextScreens"
ENT.Spawnable = true

ENT.SpawnAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/plates/plate075x105.mdl"
ENT.Material = "models/props_pipes/GutterMetal01a"
ENT.Color = Color(255, 255, 255, 255)
ENT.Mass = 20

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "TextValue")
	self:NetworkVar("Vector", 0, "TextColor")
end
