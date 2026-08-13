
TOOL.Category = "Construction"
TOOL.Name = "#tool.speedpadify.name"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
if CLIENT then
	TOOL.Information = {
		{ name = "left" }
	}

  language.Add("tool.speedpadify.name", "Speedpadify")
  language.Add("tool.speedpadify.desc", "Make a prop into a speedpad.")
  language.Add("tool.speedpadify.left", "Prop to speedpad")
  language.Add("Undone_speedpad", "Undone speedpadified prop")
end

function TOOL:LeftClick( trace )
  if (trace.Hit && IsValid(trace.Entity) && IsValid(trace.Entity:GetPhysicsObject())) then
    local e = trace.Entity
    local pos = e:GetPos()
    local ang = e:GetAngles()
    local mot = e:GetPhysicsObject():IsMotionEnabled()
    local mod = e:GetModel()
    local col = e:GetColor()
    local mat = e:GetMaterial()
    e:Remove()
    
    local speedpad = ents.Create("sent_speedpad_custom")
    if (!IsValid(speedpad)) then
      print("Error spawning speedpad")
    end

    undo.Create("speedpad")
    undo.AddEntity(speedpad)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    speedpad:SetPos(pos)
    speedpad:SetAngles(ang)
    speedpad:SetModel(mod)
    speedpad:SetColor(col)
    speedpad:SetMaterial(mat)
    speedpad:PhysicsInit(SOLID_VPHYSICS)
    speedpad:SetMoveType(MOVETYPE_VPHYSICS)
    speedpad:SetSolid(SOLID_VPHYSICS)
    speedpad:Spawn()
    speedpad:GetPhysicsObject():EnableMotion(mot)

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