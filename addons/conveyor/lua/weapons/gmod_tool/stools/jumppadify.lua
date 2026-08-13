
TOOL.Category = "Construction"
TOOL.Name = "#tool.jumppadify.name"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
if CLIENT then
	TOOL.Information = {
		{ name = "left" }
	}

  language.Add("tool.jumppadify.name", "Jumppadify")
  language.Add("tool.jumppadify.desc", "Make a prop into a jumppad.")
  language.Add("tool.jumppadify.left", "Prop to jumppad")
  language.Add("Undone_jumppad", "Undone jumppadified prop")
end

function TOOL:LeftClick( trace )
  if (trace.Hit && IsValid(trace.Entity) && IsValid(trace.Entity:GetPhysicsObject())) then
    local e = trace.Entity
    local pos = e:GetPos()
    local ang = e:GetAngles()
    local mot = e:GetPhysicsObject():IsMotionEnabled()
    local mod = e:GetModel()
    e:Remove()
    
    local jumppad = ents.Create("sent_jumppad_custom")
    if (!IsValid(jumppad)) then
      print("Error spawning jumppad")
    end

    undo.Create("jumppad")
    undo.AddEntity(jumppad)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    jumppad:SetPos(pos)
    jumppad:SetAngles(ang)
    jumppad:SetModel(mod)
    jumppad:PhysicsInit(SOLID_VPHYSICS)
    jumppad:SetMoveType(MOVETYPE_VPHYSICS)
    jumppad:SetSolid(SOLID_VPHYSICS)
    jumppad:Spawn()
    jumppad:GetPhysicsObject():EnableMotion(mot)

    return true;
  end
end
 
function TOOL:RightClick( trace )
end
--[[
function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Example TOOL", Description = "Just an little example" })
 
	panel:AddControl("CheckBox", {
	    Label = "A Boolean Value",
	    Command = "example_bool"
	})
	panel:AddControl("Slider", {
	    Label = "Example Number",
	    Type = "Float",
	    Min = "0",
	    Max = "10000",
	    Command = "example_number"
	})
 
	panel:AddControl("Color", {
	    Label = "A Color",
	    Red = "example_color_r",
	    Blue = "example_color_b",
	    Green = "example_color_g",
	    Alpha = "example_color_a",
	    ShowHSV = 1,
	    ShowRGB = 1,
	    Multiplier = 255 --You can change this to make the rgba values go up to any value
	})
end
--]]