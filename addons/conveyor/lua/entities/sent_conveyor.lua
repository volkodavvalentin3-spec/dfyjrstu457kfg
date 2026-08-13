AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Conveyor belt"
ENT.Author = "Digaly"
ENT.Contact = ""
ENT.Purpose = "See for yourself."
ENT.Information = "See for yourself."
ENT.Category = "Speedpads + Jumppads"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled", { KeyName = "Enabled", Edit = { type = "Boolean", order = 1 } })
    self:NetworkVar("Bool", 1, "SnapAngles", { KeyName = "SnapAngles", Edit = { type = "Boolean", order = 2 } })
    self:NetworkVar("Int", 0, "Speed", { KeyName = "Speed", Edit = { type = "Number", order = 3 } })
    self:NetworkVar("Bool", 2, "DirRight", { KeyName = "DirRight"} )

    if SERVER then
        self:SetEnabled(true)
        self:SetSnapAngles(false)
        self:SetSpeed(100)
        self:SetDirRight(true)
    end
end

function SpeedpadFilter( self, ent, ply ) -- A function that determines whether an entity is valid for this property
    if ( !IsValid( ent ) ) then return false end
    if ( ent:IsPlayer() ) then return false end
    if ( !gamemode.Call( "CanProperty", ply, "ignite", ent ) ) then return false end
    
    local class = ent:GetClass()
    if (string.sub(class, 0, 13) != "sent_speedpad" && string.sub(class, 0, 13) != "sent_speedtube" && string.sub(class, 0, 13) != "sent_speedpipe") then return false end;

    return true
end

properties.Add( "DIGALY_SP500", {
	MenuLabel = "#Set normal speed (x5)", -- Name to display on the context menu
	Order = 900, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_blue.png", -- The icon to display next to the property

	Filter = SpeedpadFilter,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

        ent:SetColor(Color(100, 100, 255, 255))
		ent:SetSpeed(500)
	end
})

properties.Add( "DIGALY_SP1000", {
	MenuLabel = "#Set fast speed (x20)", -- Name to display on the context menu
	Order = 901, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_orange.png", -- The icon to display next to the property

	Filter = SpeedpadFilter,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

        ent:SetColor(Color(255, 128, 100, 255))
		ent:SetSpeed(2000)
	end
})

properties.Add( "DIGALY_SP2000", {
	MenuLabel = "#Set hyper speed (x50)", -- Name to display on the context menu
	Order = 902, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_red.png", -- The icon to display next to the property

	Filter = SpeedpadFilter,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

        ent:SetColor(Color(255, 100, 100, 255))
		ent:SetSpeed(5000)
	end
})

properties.Add( "DIGALY_SP5000", {
	MenuLabel = "#Set illegal speed (x10000)", -- Name to display on the context menu
	Order = 903, -- The order to display this property relative to other properties
	MenuIcon = "icon16/flag_pink.png", -- The icon to display next to the property

	Filter = SpeedpadFilter,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, player ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
		if ( !self:Filter( ent, player ) ) then return end

        ent:SetColor(Color(255, 100, 255, 255))
		ent:SetSpeed(1000000)
	end
})

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/digaly/conveyorbelt/conveyorbelt.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType( SIMPLE_USE )

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
        e:SetAngles(Angle(-90, ply:GetAngles().y, 0))
        e:Spawn()
        e:Activate()

        return e
    end

    function ENT:Use(ply)
        if ply:IsPlayer() and ply:KeyDown(JMod.Config.General.AltFunctionKey) then
            if self:GetEnabled() then
                self:SetEnabled(false)
            else
                self:SetEnabled(true)
            end
        end
    end

    function ENT:Touch(hitEnt)
        if self:GetEnabled() then
            local m = -1

            if self:GetClass() == "sent_conveyor" then
                if self:GetAngles().x < 0 then
                    m = 1
                end
            end

            local d = self:GetRight()

            if not self:GetDirRight() then
                d = self:GetUp() * -1
            end

            if IsValid(hitEnt) then
                if hitEnt:IsPlayer() then
                    hitEnt:SetVelocity(d * (self:GetSpeed() / 10) * m)
                elseif hitEnt:GetPhysicsObject():IsValid() then
                    if not (hitEnt:GetClass() == self:GetClass()) then

                        if self:GetSnapAngles() then
                            hitEnt:SetAngles(self:GetAngles())
                        end

                        hitEnt:GetPhysicsObject():SetVelocity(d * self:GetSpeed() * m)
                    end
                end
            end
        end

        if IsValid(hitEnt) and hitEnt:GetPhysicsObject():IsValid() and not hitEnt:IsPlayer() then
            hitEnt:GetPhysicsObject():Wake()
        end
    end

    function ENT:Think()
        if self:GetClass() == "sent_conveyor" then
            if self:GetEnabled() then
                self:SetSubMaterial(0, "digaly/conveyorbelt/BeltOuter")
                self:SetSubMaterial(1, "digaly/conveyorbelt/BeltInner")
            else
                self:SetSubMaterial(0, "digaly/conveyorbelt/BeltStatic")
                self:SetSubMaterial(1, "digaly/conveyorbelt/BeltStatic")
            end
        end
    end
end