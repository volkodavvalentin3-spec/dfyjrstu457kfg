AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetTextValue("Нажмите Е что бы написать")
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

    net.Start("textscreen_menu_open")
        print(self)
        net.WriteEntity(self)
    net.Send(ply)

end
