AddCSLuaFile("sh_config.lua")
include("sh_config.lua")
AddCSLuaFile("cl_selector.lua")
include("cl_selector.lua")
  
SWEP.PrintName			= "Build"
SWEP.Author			= "vayysya" 
SWEP.Instructions		= ""
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none" 

SWEP.Weight			    = 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			    = 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""


SWEP.NextFireCD = 0.5

if SERVER then
    util.AddNetworkString("build_select_mode")
    util.AddNetworkString("build_create")
    util.AddNetworkString("build_create_door")
end

local have_jmod = GetConVar("build_jmod")
local jmod_eff  = GetConVar("build_jmod_effects")
local use_normal = GetConVar("build_use_normal_props")

local cv_ang_view   = CreateClientConVar( "b_ang_from_view", "0", true, false)        // ang related to user view or not
local cv_view_opt   = CreateClientConVar( "b_view_opt", "0", true, false)
local max_drag_mw      = CreateClientConVar( "b_drag_mw", "4", true, false)

local function JModSmoke(pos)
    // we gonna use jmod smoke if we have it
    if JMod == nil then return end
    if !jmod_eff:GetBool() then return end

    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetScale(1.5)
    util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)

end


local function vecabs(vec)
    local vect = Vector()
    vect.x = math.abs(vec.x)
    vect.y = math.abs(vec.y)
    vect.z = math.abs(vec.z)
    return vect
end

local function getang(x,y, walls)
    if math.abs(x) == 1 and math.abs(y) == 1 then
        x = 0
    end

    local ang = Vector(x,y, 0):Angle()

    ang.p = 0 

    return ang
end

local function snapping_vec(vec, k, snap)
    if math.abs(vec[k]) > snap then
        vec[k] = 1 * ( vec[k] / math.abs(vec[k]) )
    else
        vec[k] = 0
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "BuildType")
    self:NetworkVar("Int", 1, "BuildModel")
    self:NetworkVar("Int", 2, "BuildModelSkin")
end


function SWEP:Initialize()
    if CLIENT then
        self:ResetSelection()
    end

    self.BuildCoolDWN = CurTime()
end

function SWEP:Deploy()
    self:ResetSelection()
    return true
end

function SWEP:Holster()
    if CLIENT then
        self:StopInterpMouse()
        self:RemoveGhost()
    end
    return true
end 
 
function SWEP:ResetSelection()
    self:SetBuildType(BUILD_NIL)
    self:SetBuildModel(0)
    
    if CLIENT then
        self.ModelOffset        = Vector()
        self.ModelOffsetAng     = Angle()
        self.ModelPos           = Vector()
        self.ModelAng   = Angle()
        self.BlockBuild = false
        self.NextFire = CurTime()
        self.ModeOffset = false
        self.AngleSnapping = false
        self.AngleSnap = Angle()
        self.DoorHole = nil

        //print("RESET")
    end
end

function SWEP:CreateGhost()
    local model, _ = self:GetStrModel()
    local skn = self:GetBuildModelSkin()
    if model then
        local ghost = ClientsideModel(model)
        ghost:SetSkin(skn or 0)
        ghost:SetColor( Color( 255, 255, 255, 200 ) )  
        ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
        
        self.BuildGhost = ghost
    end
end

function SWEP:GetStrModel()

    if self:GetBuildType() == 0 or self:GetBuildModel() == 0 then return "" end

    if istable(BuildConf.Models[self:GetBuildType()][self:GetBuildModel()]) then
        return BuildConf.Models[self:GetBuildType()][self:GetBuildModel()].mdl , BuildConf.Models[self:GetBuildType()][self:GetBuildModel()].skin
    else
        return BuildConf.Models[self:GetBuildType()][self:GetBuildModel()]
    end
end

function SWEP:RemoveGhost()
    if self.BuildGhost then self.BuildGhost:Remove() end
end

function SWEP:OnRemove()
    if CLIENT then
        self:RemoveGhost()
        self:StopInterpMouse()
    end
end



local copy_cld = 0
function SWEP:CopyModel()
    if copy_cld > CurTime() then return end
    local owner = self:GetOwner()

    local t = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + ( owner:GetAimVector() * 300 ),
        filter = owner,
    })

    local ent = t.Entity

    if !ent:IsValid() then return end

    local mod, skn = ent:GetModel(), ent:GetSkin()
    copy_cld = CurTime() + 0.1

    local categ, mid = BuildGetModelID(mod, skn)
    self:SetBuildType(categ)
    self:SetBuildModel(mid)

    net.Start("build_select_mode")
    net.WriteUInt(categ, 4)
    net.WriteUInt(mid, 8)
    net.SendToServer()

    self:RemoveGhost()
    if categ == 0 or mid == 0 then return end
    self:CreateGhost()
end


if CLIENT then
    local align_limx = 0
    local align_limy = 0

    local function absfloor(a)
        return math.floor(math.abs(a)) * (a/math.abs(a))
    end

    // управление мышью
    function SWEP:InterpMouse()
        if self.INInterpMouse then return end
        local ply = self:GetOwner()
        
        local cd = 0
        local wheeled = false

        hook.Add( "PlayerBindPress", "BuildOverride", function( ply, bind, pressed )
            if bind == "invnext" or bind == "invprev" then
                return true
            end
        end )

        hook.Add("InputMouseApply", "BuildGetMouse", function(cmd,x,y)
            if !self:IsValid()  then
                hook.Remove("InputMouseApply", "BuildGetMouse")
                hook.Remove("PlayerBindPress", "BuildOverride")        
                return
            end
            if cd > CurTime() then return true end
            local wh = cmd:GetMouseWheel()

            if (y == 0 and x == 0 and wh == 0) then return true end

            local max_drag = max_drag_mw:GetInt()
            
            if math.abs(wh) > 0 then
                wh = math.abs(wh) / wh
                wheeled = true
                cd = CurTime() + 0.01
            else
                wheeled = false
            end

            if y == 0 then
                y = wh
            else
                y = math.Clamp( absfloor(y / 5), -max_drag, max_drag )
            end

            if x == 0 then
                x = wh
            else
                x = math.Clamp(  absfloor(x / 5), -max_drag, max_drag )
            end

            if ply:KeyDown(IN_WALK) then
                self.ModelOffset.z = math.Clamp(self.ModelOffset.z - y, -128, 128)
            else
                if self.AngleSnapping then
                    align_limy = align_limy + (x/max_drag)
                    
                    if math.abs(align_limy) > 20  then
                        self.AngleSnap.y = self.AngleSnap.y + (90 * (align_limy / math.abs(align_limy)))
                        align_limy = 0
                    end
                else
                    local mode = self:GetBuildType()
                    local mid = ply:KeyDown( IN_USE )

                    if mid then
                        if ply:KeyDown(IN_SPEED) and (mode == BUILD_PLATE or mode == BUILD_CEIL) then
                            if math.abs(y) > 0 then
                                self.ModelOffsetAng.p = self.ModelOffsetAng.p + (90 * (y / math.abs(y))) 
                                cd = CurTime() + 0.1
                            end
                        else
                            if math.abs(x) > 0 then
                                self.ModelOffsetAng.y = self.ModelOffsetAng.y + (90 * (x / math.abs(x)))
                                cd = CurTime() + 0.1
                            end 
                        end
                    else
                        if ply:KeyDown(IN_SPEED) and (mode == BUILD_PLATE or mode == BUILD_CEIL) then
                            self.ModelOffsetAng.p = self.ModelOffsetAng.p + y
                            cd = CurTime() + 0.01
                        else
                            self.ModelOffsetAng.y = self.ModelOffsetAng.y + x
                            cd = CurTime() + 0.01 
                        end
                    end
 
                end
            end

            self.ModelOffsetAng:Normalize()
            self.AngleSnap:Normalize()

            cmd:SetMouseX(0)
            cmd:SetMouseY(0)
        
            return true
        end)

        self.INInterpMouse = true
    end

    function SWEP:StopInterpMouse()
        if !self.INInterpMouse then return end
        hook.Remove("InputMouseApply", "BuildGetMouse")
        hook.Remove("PlayerBindPress", "BuildOverride")

        self.INInterpMouse = nil
    end

    
    function SWEP:Think()
        local ply = self:GetOwner()

        if ply:KeyPressed(IN_RELOAD) then
            if ply:KeyDown(IN_WALK) then
                self.ModelOffset:Zero()
                self.ModelOffsetAng:Zero()
                self.AngleSnap:Zero()
            else
                self:ShowSelector(true)
            end
        elseif ply:KeyReleased(IN_RELOAD) then
            self:ShowSelector(false)
        end

        if input.IsMouseDown( MOUSE_MIDDLE ) then
            self:CopyModel()
        end

        // dont want to create render hook
        // set pos ghost there
        local ghost = self.BuildGhost

        if !IsValid(ghost) then return end
        
        if ply:KeyPressed(IN_ATTACK2) then
            self:InterpMouse()
        elseif ply:KeyReleased(IN_ATTACK2) then
            self:StopInterpMouse()
        end

    
        offset_ang = self.ModelOffsetAng 

        //print(self.AngleSnapping)

        if self.AngleSnapping then
            offset_ang = self.AngleSnap
            //self.ModelOffsetAng = self.AngleSnap
        end

        local pos, ang = self:GetPropPos(self.ModelOffset, offset_ang)
    
        //print(pos, ang)

        ghost:SetPos(pos)
        ghost:SetAngles(ang)

        self.ModelAng = ang
        
    end

end


function SWEP:GetPropPos(build_offset, build_ang) // build_ang - angle from client

    if CLIENT then
        self.AngleSnapping = false
    end

    local owner = self:GetOwner()
    local build_model = self:GetStrModel()
    local build_type = self:GetBuildType()

    local build_hull = BuildConf.ModelsHull[build_model] or BuildConf.ModelsHullType[build_type] 

    local offset_pos = Vector()
    local offset_ang = Angle()

    if BuildConf.ModelWithOffset[build_model] then
        local off = BuildConf.ModelWithOffset[build_model]

        offset_pos = off.vec
        offset_ang = off.ang
    end 


    local final_pos = Vector()
    local final_ang = Angle()

    local trace = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + ( owner:GetAimVector() * 300 ),
        filter = owner,
    })

    local hitPos = trace.HitPos
    local final_pos = hitPos
    local prop = trace.Entity

    if build_type != BUILD_DOOR then
        if !build_hull then 
            return final_pos, final_ang
        end
    end

    if !IsValid(prop) then // world
        local hull = Vector() 
        if build_type != BUILD_DOOR then
            hull = build_hull[1] - build_hull[2]
        end
        final_pos = hitPos + Vector(0, 0, hull.z/2)

        //PrintTable(build_hull)

        //print(hull)

        if build_type == BUILD_FOUND then
            final_pos.z = final_pos.z + build_offset.z
        end
        if build_type != BUILD_DOOR then
            final_ang = final_ang + build_ang
        end
        return final_pos + offset_pos, final_ang 
    end

    if (prop:GetClass() != "build_prop") and !(prop:GetClass() == "prop_physics" and prop:GetNWBool("CreatedByBuilder"))then
        return final_pos, final_ang
    end

    local trace_model, trace_type = prop:GetModel(), BuildGetCateg(prop:GetModel())
    local trace_hull =  BuildConf.ModelsHull[trace_model] or BuildConf.ModelsHullType[trace_type] 

    if !trace_hull then 
        return final_pos, final_ang
    end


    if CLIENT then
        self.AngleSnapping = true
    end



    //print(build_type, trace_type) 

    if build_type == BUILD_FOUND or build_type == BUILD_STAIR then
        local absh = vecabs(build_hull[2])
        local trace_absh = vecabs(trace_hull[2])

        local normal_dir = prop:WorldToLocal(hitPos)
        normal_dir = normal_dir / absh

        snapping_vec(normal_dir, "z", 1)

        if normal_dir.z == 0 then
            snapping_vec(normal_dir, "x", 1)
            snapping_vec(normal_dir, "y", 1)
        else
            snapping_vec(normal_dir, "x", 0.5)
            snapping_vec(normal_dir, "y", 0.5)
        end
 
        //if b_typ == BUILD_PLATE or b_typ == BUILD_FOUND then
        if math.abs(normal_dir.x) == 1 or math.abs(normal_dir.y) == 1 then
            normal_dir.z = 0
        end
        //end
                    //if b_typ == BUILD_STAIR or b_typ == BUILD_PLATE or b_typ == BUILD_FOUND then
                        -- snapping_vec(lpos, "z", 1)
                        -- if lpos.z == 0 then
                        --     snapping_vec(lpos, "x", 1)
                        --     snapping_vec(lpos, "y", 1)
                        -- else
                        --     snapping_vec(lpos, "x", 0.5)
                        --     snapping_vec(lpos, "y", 0.5)
                        -- end
                    //else
                       // for k,v in pairs(lpos:ToTable()) do
                       //     snapping_vec(lpos, k, snap_to)
                       // end
                    //end

        if trace_type == BUILD_FOUND then
            //print(offset_pos)
            final_pos = prop:LocalToWorld((normal_dir * absh * 2) + offset_pos)
            final_ang = prop:LocalToWorldAngles(build_ang)
 
        elseif trace_type == BUILD_PLATE then
            local height = Vector()

            height.z = (absh.z ) + (trace_absh.z) + build_offset.z

            final_pos = prop:LocalToWorld(height + normal_dir * absh * 2 )
        end

        if build_type == BUILD_STAIR then
            local ang = getang(normal_dir.x, normal_dir.y) //+ build_ang

            //ang.y = ang.y + 90
            ang.y = ang.y + 90 + build_ang.y

            final_ang = prop:LocalToWorldAngles(ang)
        end

    elseif build_type == BUILD_PLATE then


        local absh = vecabs(build_hull[2])
        local trace_absh = vecabs(trace_hull[2])

        local normal_dir = prop:WorldToLocal(hitPos)

        normal_dir = normal_dir / absh

        snapping_vec(normal_dir, "z", 1)

        if normal_dir.z == 0 then
            snapping_vec(normal_dir, "x", 1)
            snapping_vec(normal_dir, "y", 1)
        else
            snapping_vec(normal_dir, "x", 0.5)
            snapping_vec(normal_dir, "y", 0.5)
        end
 

        if normal_dir.x != 0 or normal_dir.y != 0 then
            normal_dir.z = 0
        end
        local height = Vector()

        if trace_type == BUILD_FOUND then
            if normal_dir.z != 0 and (normal_dir.x == 0 and normal_dir.y == 0) then
                height.z = build_offset.z + trace_absh.z * 3 - absh.z * 3
            else
                height.z = build_offset.z + trace_absh.z * 1 - absh.z
            end
        
            final_pos = prop:LocalToWorld((normal_dir * absh * 2) + height)
            final_ang = prop:GetAngles()

        elseif trace_type == BUILD_PLATE then
            if normal_dir.z != 0 and (normal_dir.x == 0 and normal_dir.y == 0) then
                local found_absh = vecabs(BuildConf.ModelsHullType[BUILD_FOUND][2])
                height.z = build_offset.z + (found_absh.z * 2) - absh.z * 2
            else
                height.z = build_offset.z
            end

            final_pos = prop:LocalToWorld((normal_dir * absh * 2) + height)
            final_ang = prop:GetAngles()
            
        end


    elseif build_type == BUILD_WALLS then


        local absh = vecabs(build_hull[2])
        local trace_absh = vecabs(trace_hull[2])

        local normal_dir = prop:WorldToLocal(hitPos)

        normal_dir = normal_dir / absh

        snapping_vec(normal_dir, "x", 0.8)
        snapping_vec(normal_dir, "y", 0.8)




        local height = Vector()

        if trace_type == BUILD_WALLS then
            normal_dir.x, normal_dir.y, normal_dir.z  = 0, 0, 1

            final_pos = prop:LocalToWorld((normal_dir * absh * 2) + offset_pos)
            final_ang = prop:LocalToWorldAngles(build_ang)
        elseif trace_type == BUILD_FOUND or trace_type == BUILD_PLATE then
            local found_absh = vecabs(BuildConf.ModelsHullType[BUILD_FOUND][2])
            
            normal_dir.z = 1            
            height.z = found_absh.z + offset_pos.z

            local m_offsets = Vector(absh.y+offset_pos.y, absh.y+offset_pos.y, 0) * normal_dir
            local ang = getang(normal_dir.x, normal_dir.y, true) + build_ang

            if normal_dir.x == 0 and normal_dir.y == 0 then
                ang = ang + build_ang
            end
            
            //ang.y = ang.y //+ 90

            final_pos = prop:LocalToWorld((normal_dir * trace_absh ) + height - m_offsets)
            final_ang = prop:LocalToWorldAngles(ang + offset_ang)
        end

    elseif build_type == BUILD_GATE then 
        //local absh = vecabs(build_hull[2])
        local absh = vecabs(BuildConf.ModelsHullType[BUILD_WALLS][2])

        local trace_absh = vecabs(trace_hull[2])

        local normal_dir = prop:WorldToLocal(hitPos)

        normal_dir = normal_dir / absh

        
        //snapping_vec(normal_dir, "x", 0.7)
        //snapping_vec(normal_dir, "y", 0.7)

        if math.abs(normal_dir.x) > math.abs(normal_dir.y) then
            normal_dir.x = normal_dir.x / math.abs(normal_dir.x) -- в -1/1
            normal_dir.y = 0
        else
            normal_dir.y = normal_dir.y / math.abs(normal_dir.y)
            normal_dir.x = 0

        end

        //print(normal_dir)
        //PrintTable(build_hull)
        local height = Vector()

        -- if trace_type == BUILD_WALLS then
        --     normal_dir.x, normal_dir.y, normal_dir.z  = 0, 0, 1

        --     final_pos = prop:LocalToWorld((normal_dir * absh * 2) + offset_pos)
        --     final_ang = prop:LocalToWorldAngles(build_ang)
        if trace_type == BUILD_FOUND or trace_type == BUILD_PLATE then
            //local found_absh = vecabs(BuildConf.ModelsHullType[BUILD_FOUND][2])
            //local wall_absh = vecabs(BuildConf.ModelsHullType[BUILD_WALLS][2])
            //local absh = vecabs(build_hull[2])
            
            normal_dir.z = 1            
            height.z = offset_pos.z

            local m_offsets = Vector(absh.y+offset_pos.y, absh.y+offset_pos.y, 0) * normal_dir
            local gate_offset = Vector()////Vector(0,32,0) * normal_dir

            local ang = getang(normal_dir.x, normal_dir.y, true) + build_ang

            local pos = LocalToWorld(Vector(0,64,0), Angle(),((normal_dir * trace_absh)  + height ) - m_offsets, Angle(ang + offset_ang) )

            ang.y = ang.y //+ 90

            final_pos = prop:LocalToWorld(pos)
            final_ang = prop:LocalToWorldAngles(ang + offset_ang)

            //print((normal_dir * trace_absh ) + height - m_offsets ) 
        end
        
    elseif build_type == BUILD_CEIL then
        local absh = vecabs(build_hull[2])
        local trace_absh = vecabs(trace_hull[2])

        local normal_dir = prop:WorldToLocal(hitPos)

        normal_dir = normal_dir / absh
        snapping_vec(normal_dir, "z", 1)

            snapping_vec(normal_dir, "x", 0.5)
            snapping_vec(normal_dir, "y", 0.5)

        if normal_dir.x != 0 or normal_dir.y != 0 then
            normal_dir.z = 0
        end
        local height = Vector()

        if trace_type == BUILD_FOUND or trace_type == BUILD_PLATE then
            local found_absh = vecabs(BuildConf.ModelsHullType[BUILD_FOUND][2])

            normal_dir.z = 1            
            height.z = (found_absh.z * 2) + absh.z  
            local ang = getang(normal_dir.x, normal_dir.y, true) + build_ang

            ang.y = ang.y + 90

            //print(ang)

            normal_dir.x, normal_dir.y = 0, 0

            final_pos = prop:LocalToWorld((normal_dir * trace_absh ) + height )
            final_ang = prop:LocalToWorldAngles(ang)
        elseif trace_type == BUILD_CEIL then
            if normal_dir.z != 0 and (normal_dir.x == 0 and normal_dir.y == 0) then
                local found_absh = vecabs(BuildConf.ModelsHullType[BUILD_FOUND][2])
                height.z = (found_absh.z * 2) - absh.z * 2
            end

            final_pos = prop:LocalToWorld((normal_dir * absh * 2) + height)
            final_ang = prop:LocalToWorldAngles(build_ang)
        end

    elseif build_type == BUILD_DOOR and trace_type == BUILD_WALLS then

        if !BuildConf.DoorAllowed[prop:GetModel()] then
            self.DoorHole = nil
            return final_pos, final_ang
        end
        local offset = BUILD_DOORHOLE_OFFSET[prop:GetModel()] or BUILD_DOOR_OFFSET

        final_pos = prop:LocalToWorld(offset)
        final_ang = prop:LocalToWorldAngles(BUILD_DOOR_OFFSET_ANG)
        self.DoorHole = prop
    else // other and fences 
        local hull = Vector()
        if build_type != BUILD_DOOR then
            hull = build_hull[1] - build_hull[2]
        end
        final_pos = hitPos + Vector(0, 0, hull.z / 2)

        if build_type == BUILD_FOUND then
            final_pos.z = final_pos.z + build_offset.z
        end
        if build_type != BUILD_DOOR then
            final_ang = final_ang + build_ang
        end
        //return final_pos, final_ang 
        self.AngleSnapping = false

            
    end

    //print(build_type)

   // print(final_ang, 123)

    return final_pos, final_ang
end

function SWEP:CreateGate(pos_offset, ang_offset)
 //print("SPAWN PROP")
    //debug.Trace()
    if self.BuildCoolDWN > CurTime() then return end

    local model = self:GetStrModel()
    local pos, ang = self:GetPropPos(pos_offset, ang_offset)


    local prop = ents.Create("prop_ww_door")
    prop.Model = model
    prop:SetPos(pos)
    prop:SetAngles(ang)
    //prop.Typ = self:GetBuildType()
    prop.Owner = self:GetOwner()
    prop:SetNWEntity("Owner", self:GetOwner())
    prop:Spawn()
    prop:SetSkin(self:GetBuildModelSkin())

    -- undo.Create("build_prop")
    --     undo.AddEntity(prop)
    --     undo.SetPlayer(self:GetOwner())
    -- undo.Finish()

    -- self:GetOwner():AddCleanup( "build_prop", prop )

    JModSmoke(pos)

    sound.Play("physics/concrete/concrete_block_impact_hard"..tostring(math.random(1,3))..".wav", pos + VectorRand(), 70, math.random(80,100))
    if jmod_eff:GetBool() then
        sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(50, 70))
    end

    self.BuildCoolDWN = CurTime() + 0.5
end

function SWEP:CreateProp(pos_offset, ang_offset)
    //print("SPAWN PROP")
    //debug.Trace()
    if self.BuildCoolDWN > CurTime() then return end

    local model = self:GetStrModel()
    local pos, ang = self:GetPropPos(pos_offset, ang_offset)


    if self:GetBuildType() == BUILD_GATE then
        self:CreateGate(pos_offset, ang_offset)
        return
    end


    local prop = ents.Create("build_prop")
    prop.Model = model
    prop:SetPos(pos)
    prop:SetAngles(ang)
    prop.Typ = self:GetBuildType()
    prop.Owner = self:GetOwner()
    prop:SetNWEntity("Owner", self:GetOwner())
    prop:Spawn()
    prop:SetSkin(self:GetBuildModelSkin())

    -- undo.Create("build_prop")
    --     undo.AddEntity(prop)
    --     undo.SetPlayer(self:GetOwner())
    -- undo.Finish()

    //self:GetOwner():AddCleanup( "build_prop", prop )

    JModSmoke(pos)

    sound.Play("physics/concrete/concrete_block_impact_hard"..tostring(math.random(1,3))..".wav", pos + VectorRand(), 70, math.random(80,100))
    if jmod_eff:GetBool() then
        sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(50, 70))
    end

    self.BuildCoolDWN = CurTime() + 0.5
end


function SWEP:CreateDoor(ent_wall)
    if IsValid(ent_wall.Door) then return end
    if ent_wall:GetPhysicsObject():IsMotionEnabled() then return end
    local model, skn = self:GetStrModel()

    if BuildConf.DoorAllowed[ent_wall:GetModel()] != true then return end
    
    local offset = BUILD_DOORHOLE_OFFSET[ent_wall:GetModel()] or BUILD_DOOR_OFFSET
    local offset_ang = BUILD_DOOR_OFFSET_ANG

    local door = ents.Create("prop_door_rotating")
    door:SetModel(model)
    door:SetSkin(skn or 0)
    door:SetPos(ent_wall:LocalToWorld(offset))
    door:SetAngles(ent_wall:LocalToWorldAngles(offset_ang))

    door.IsBuildDoor = true
    door:Spawn()
    door:SetBodygroup(1, 2)

    ent_wall.Door = door

    self.BuildCoolDWN = CurTime() + 0.1

    local pos = ent_wall:GetPos()
    pos.z = pos.z+50

    JModSmoke(pos)

    sound.Play("physics/wood/wood_box_impact_hard1.wav"..tostring(math.random(1,6))..".wav", pos + VectorRand(), 70, math.random(80,100))
    if jmod_eff:GetBool() then
        sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(50, 70))
     end

    undo.Create("build_prop")
        undo.AddEntity(door)
        undo.SetPlayer(self:GetOwner())
    undo.Finish()
    
    self:GetOwner():AddCleanup( "build_prop", prop )
end


function SWEP:PrimaryAttack()
    if game.SinglePlayer() then
        self:CallOnClient( "PrimaryAttack")
    end
    
    //self:SetNextPrimaryFire(CurTime() + 1)  -- не работает

    if SERVER then return end

    if self.NextFire > CurTime() then return end

    offset_ang = self.ModelOffsetAng 

    if self.AngleSnapping then
        offset_ang = self.AngleSnap
    end

    local pos, ang = self:GetPropPos(self.ModelOffset, offset_ang)

    local tr = util.TraceLine({
        start = self.ModelPos,
        endpos = self.ModelPos,
    })


    if self:GetBuildType() == BUILD_FOUND then
        local TrCheck = util.QuickTrace(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * 300, self:GetOwner())

        if not TrCheck.Hit then
            self:GetOwner():PrintMessage(HUD_PRINTCENTER, "You need place this on ground")
            return
        end
    end

    if tr.Entity:IsValid() then
        notification.AddLegacy( "Can't spawn prop!", NOTIFY_GENERIC, 2 )
        surface.PlaySound( "buttons/button15.wav" )
        return
    end

    if self:GetBuildType() == BUILD_DOOR and self.DoorHole:IsValid() then
        local doormodel = self.DoorHole:GetModel()

        if BuildConf.DoorAllowed[doormodel] != true then return end

        net.Start("build_create_door")
        net.WriteEntity(self.DoorHole)
        net.SendToServer()
    else
        local ang = self.ModelOffsetAng
        if self.AngleSnapping then
            ang = self.AngleSnap
        end

        net.Start("build_create")
        net.WriteVector(self.ModelOffset)
        net.WriteAngle(ang)
        net.SendToServer()
    end

    self.NextFire = CurTime() + self.NextFireCD

end


BUILD_NIL   = 0
BUILD_FENCE = 1
BUILD_FOUND = 2
BUILD_WALLS = 3
BUILD_STAIR = 4
BUILD_CEIL  = 5
BUILD_OTHER = 6
BUILD_PLATE = 7


local string_build = {
    [BUILD_NIL] = "N/A",
    [BUILD_FENCE] = "Fences",
    [BUILD_FOUND]  = "Foundation",
    [BUILD_WALLS] = "Walls",
    [BUILD_STAIR] = "Stairs",
    [BUILD_CEIL] = "Roof",
    [BUILD_OTHER] = "Other",
    [BUILD_PLATE] = "Ceil",
    [BUILD_DOOR] = "Door",
}

local str_dist = 17
function SWEP:DrawHUD()
    local h,w = ScrH(), ScrW()
    local posx, posy = w/2 + w/4, h/2 + h/4

    local mod = string_build[self:GetBuildType()]
    if !mod then mod = string_build[BUILD_NIL] end

	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( posx, posy+str_dist*2 )
	surface.SetFont( "HudDefault" )

	surface.DrawText( "Build mode: "..mod )

    surface.SetTextPos( posx-50, posy - str_dist*10)
    surface.DrawText( "HOW TO USE: " )
    surface.SetTextPos( posx-50, posy - str_dist*9)
    surface.DrawText( string.upper(input.LookupBinding( "reload" ) or "R") .." for change mode" )
    surface.SetTextPos( posx-50, posy - str_dist*8)
    surface.DrawText( "RMB + mouse (or mouse wheel) to rotate" )

    local bind_alt = input.LookupBinding( "walk" ) or "unbinded! (+walk, ALT) "
    surface.SetTextPos( posx-50, posy - str_dist*7)
    surface.DrawText( "RMB + "..bind_alt.." for change z coordinate" )
    surface.SetTextPos( posx-50, posy - str_dist*6)
    surface.DrawText( "RMB + "..string.upper(input.LookupBinding( "speed" ) or "shift").." for change pitch coordinate " )
    surface.SetTextPos( posx-50, posy - str_dist*5)
    surface.DrawText( "RMB + "..string.upper(input.LookupBinding( "use" ) or "USE").." for for rotate in 90 " )
    surface.SetTextPos( posx-50, posy - str_dist*4)
    surface.DrawText( bind_alt.." + "..string.upper(input.LookupBinding( "reload" ) or "RELOAD").." for reset settings" )

    surface.SetTextPos( posx-50, posy - str_dist*3)
    surface.DrawText( "Mid mouse for copy model" )

    if cv_view_opt:GetBool() then
        local pos_off = tostring(self.ModelOffset)
        local ang_off = tostring(self.ModelOffsetAng)
        local cur_mod_ang = tostring(self.ModelAng)
    
        surface.SetTextPos( posx-50, posy - str_dist*2)
        surface.DrawText( "POS: ".. pos_off )
        surface.SetTextPos( posx-50, posy - str_dist*1)
        surface.DrawText( "ANG: ".. ang_off )
        surface.SetTextPos( posx-50, posy)
        surface.DrawText( "CURRENT ANG: "..cur_mod_ang )
    end
    
    -- if have_jmod:GetBool() and JMod != nil then
        if self:GetBuildType() ~= 0 then
            draw.SimpleTextOutlined("You need ".. BuildConf.RecourceReq[self:GetBuildType()][JMod.EZ_RESOURCE_TYPES.CERAMIC] .. " Ceramic for building this", "Trebuchet24",posx-50, posy + str_dist*4, Color(255, 255, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
        end
    -- end

    if self:GetBuildType() == BUILD_DOOR then
        draw.SimpleTextOutlined("PLACE DOOR IN WALL WITH DOORHOLE!", "Trebuchet24",w/2, h/2, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
    end
end

//PrintTable(BuildConf.RecourceReq)

if SERVER then
    net.Receive("build_select_mode", function(_, ply)
        local t = net.ReadUInt(4)
        local m = net.ReadUInt(8)
        local s = net.ReadUInt(8)
        local wep = ply:GetActiveWeapon()

        if wep:GetClass() == "builder" or  wep:GetClass() == "builder2" then
            wep:SetBuildType(t)
            wep:SetBuildModel(m)
            wep:SetBuildModelSkin(s)
        end
    end)

    net.Receive("build_create", function(_, ply)
        local pos = net.ReadVector()
        local ang = net.ReadAngle()

        local wep = ply:GetActiveWeapon()


        local UzhePostroili = false
        local canbuild = false
        local ceramica = false

        if UzhePostroili then return end
        
        --debugoverlay.Sphere( wep:GetOwner():GetPos(), 3000, 10,Color( 255, 255, 255 ), false )

        if not GetConVar("sv_cheats"):GetBool() then
            local squad = SquadMenu:GetSquad(wep:GetOwner():GetSquadID())
                    
            if wep:GetOwner():GetSquadID() == nil then return end
                
            for k, ent in pairs(ents.FindInSphere(wep:GetOwner():GetPos(), 3000)) do
                if ent:GetClass() == "ent_rus_spawnbase" then
                    if IsValid(JMod.GetEZowner(ent)) then

                        if ((JMod.GetEZowner(ent):GetSquadID() == wep:GetOwner():GetSquadID()) or squad.Alliance[JMod.GetEZowner(ent):GetSquadID()]) and ent:GetBaseTitle() ~= "none" then
                            canbuild = true

                            if JMod.HaveResourcesToPerformTask(nil, 350, BuildConf.RecourceReq[wep:GetBuildType()], wep) then
                                ceramica = true
                                JMod.ConsumeResourcesInRange(BuildConf.RecourceReq[wep:GetBuildType()], wep:GetOwner():GetShootPos(), 350, wep, false, false, 1)
                                break
                            elseif JMod.HaveResourcesToPerformTask(nil, 350, BuildConf.RecourceReq[wep:GetBuildType()], ent) then
                                ceramica = true
                                JMod.ConsumeResourcesInRange(BuildConf.RecourceReq[wep:GetBuildType()], ent:GetPos(), 350, ent, false, false, 1)
                                break
                            end
                        end

                    end
                end
            end
            
            if not canbuild then
                wep:GetOwner():PrintMessage(HUD_PRINTCENTER, "Нужно строить рядом с базой")
            elseif not ceramica then
                wep:GetOwner():PrintMessage(HUD_PRINTCENTER, "Не хватает ресурсов")
            else
                wep:CreateProp(pos, ang)
            end
        else
            wep:CreateProp(pos, ang)
        end

        UzhePostroili = true

        //alreadyBuilded = true
    end)

    net.Receive("build_create_door", function(_, ply)
        local door_hole = net.ReadEntity()
        local wep = ply:GetActiveWeapon()

        if wep:GetClass() != "builder" and wep:GetClass() != "builder2" then return end

        if (not GetConVar("sv_cheats"):GetBool() and (have_jmod:GetBool() and JMod != nil)) then
            if JMod.HaveResourcesToPerformTask(nil, 350, BuildConf.RecourceReq[wep:GetBuildType()], wep) then
                local succes = wep:CreateDoor(door_hole)
                if succes then
                    JMod.ConsumeResourcesInRange(BuildConf.RecourceReq[wep:GetBuildType()], wep:GetOwner():GetShootPos(), 350, wep, false, false, 1)
                end
            else
                wep:GetOwner():PrintMessage(HUD_PRINTCENTER, "Not enough resources")
            end
        else
            wep:CreateDoor(door_hole)
         end
    end)
end

