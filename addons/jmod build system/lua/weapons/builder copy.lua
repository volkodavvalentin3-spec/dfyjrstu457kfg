AddCSLuaFile("sh_config.lua")
AddCSLuaFile("cl_selector.lua")
include("sh_config.lua")
include("cl_selector.lua")

SWEP.PrintName			= "Build"
SWEP.Author			= "vayysya"
SWEP.Instructions		= ""
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none" 

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/jmod/ez/c_repairkit.mdl"
SWEP.WorldModel			= "models/jmod/ez/c_repairkit.mdl"

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

if SERVER then
    util.AddNetworkString("build_select_mode")
    util.AddNetworkString("build_create")
    util.AddNetworkString("build_create_door")
end

// unused
local cv_ang_view   = CreateClientConVar( "b_ang_from_view", "0", true, false)        // ang related to user view or not
local cv_move_time  = CreateClientConVar( "b_move_speed", "0.25", true, false)         //
local cv_move_mult  = CreateClientConVar( "b_move_mult", "4", true, false)            //
local cv_rot_mult   = CreateClientConVar( "b_rotate_mult", "4", true, false)          //

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "BuildType")
    self:NetworkVar("Int", 1, "BuildModel")
end

function SWEP:Reload()

end

function SWEP:Initialize()
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
    end

    self.BuildCoolDWN = CurTime()
end

function SWEP:Deploy()
    self:ResetSelection()
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
        self.ModeOffset = false
        self.AngleSnapping = false
        self.AngleSnap = Angle()
    end
end

function SWEP:Holster()
    if CLIENT then
        self:RemoveGhost()
    end
    return true
end 
 
function SWEP:PrimaryAttack()
    if SERVER then return end
    if self.BlockBuild then return end
    if self:GetBuildType() == 0 or self:GetBuildModel() == 0 then return end
    //print(CurTime() - self:GetNextPrimaryFire())
    if self.NextFire >= CurTime() then return end

    local CanPlace = false 

    // check dibilniy prop
    local tr = util.TraceLine({
        start = self.ModelPos,
        endpos = self.ModelPos,
    })

    if self:GetBuildType() == BUILD_FOUND then
        local TrCheck = util.QuickTrace(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * 300, self:GetOwner())

        if not TrCheck.Hit then
            self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Тебе надо строить на земле")
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
        net.Start("build_create")
        net.WriteVector(self.ModelPos)
        net.WriteAngle(self.ModelAng)
        net.SendToServer()
    end

    self.NextFire = CurTime() + 1
end

function SWEP:CreateDoor(ent_wall)
    if IsValid(ent_wall.Door) then return end
    local model, skn = self:GetStrModel()

    if BuildConf.DoorAllowed[ent_wall:GetModel()] != true then return end
    
    local door = ents.Create("prop_door_rotating")
    door:SetModel(model)
    door:SetSkin(skn or 0)
    door:SetPos(ent_wall:LocalToWorld(BUILD_DOOR_OFFSET))
    door:SetAngles(ent_wall:GetAngles()+ Angle(0,90,0))

    door.IsBuildDoor = true
    door:Spawn()
    door:SetBodygroup(1, 2)

    ent_wall.Door = door

    self.BuildCoolDWN = CurTime() + 0.5

    local pos = ent_wall:GetPos()
    pos.z = pos.z+50

    local eff = EffectData()
	eff:SetOrigin(pos)
	eff:SetScale(1)
	util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
    sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(50, 70))
end

function SWEP:CreateProp(pos, ang)
    if self.BuildCoolDWN > CurTime() then return end

    local prop = ents.Create("build_prop")
    prop.Model = self:GetStrModel()
    prop:SetPos(pos)
    prop:SetAngles(ang)
    prop.Owner = self:GetOwner()
    prop:SetNWEntity("Owner", self:GetOwner())
    prop.HP = BuildConf.HP[self:GetBuildType()]
    
    prop:Spawn()

    self.BuildCoolDWN = CurTime() + 0.5

    local eff = EffectData()
	eff:SetOrigin(pos)
	eff:SetScale(1)
	util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
    sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(50, 70))
end

function SWEP:GetStrModel()
    if istable(BuildConf.Models[self:GetBuildType()][self:GetBuildModel()]) then
        return BuildConf.Models[self:GetBuildType()][self:GetBuildModel()].m , BuildConf.Models[self:GetBuildType()][self:GetBuildModel()].s
    else
        return BuildConf.Models[self:GetBuildType()][self:GetBuildModel()]
    end
end

function SWEP:SecondaryAttack()

end

function SWEP:CreateGhost()
    local model, skn = self:GetStrModel()

    if model then
        local ghost = ClientsideModel(model)
        ghost:SetSkin(skn or 0)
        ghost:SetColor( Color( 255, 255, 255, 200 ) ) 
        ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
        
        self.BuildGhost = ghost
    end
end

function SWEP:RemoveGhost()
    if self.BuildGhost then self.BuildGhost:Remove() end
end

function SWEP:OnRemove()
    if CLIENT then
        self:RemoveGhost()
    end
end

local function normaliz(vec)
    vec.x = vec.x / math.abs(vec.x)
    vec.y = vec.y / math.abs(vec.y)
    vec.z = vec.z / math.abs(vec.z)
end

local function vecabs(vec)
    local vect = Vector()
    vect.x = math.abs(vec.x)
    vect.y = math.abs(vec.y)
    vect.z = math.abs(vec.z)
    return vect
end

local function get_k()
    local kx, ky, kz = 0, 0, 0
    if input.IsButtonDown(KEY_PAD_8) then kx = 1 elseif input.IsButtonDown(KEY_PAD_2) then kx = -1 end
    if input.IsButtonDown(KEY_PAD_4) then ky = 1 elseif input.IsButtonDown(KEY_PAD_6) then ky = -1 end
    if input.IsButtonDown(KEY_PAD_1) then kz = 1 elseif input.IsButtonDown(KEY_PAD_3) then kz = -1 end

    return kx, ky, kz
end

local angkub = {
    [0] = { // x
        [1] = 180, // y
        [-1] = 0,
        [0]  = 0,
    },
    [1] = {
        [1] = 90, // y
        [0] = 90,
        [-1] = 90,
    },
    [-1] = {
        [1] = -90,
        [-1] = -90,
        [0] = -90,

    }
}

local angkub2 = {
    [0] = { // x
        [1] = 0, // y
        [-1] = 180,
        [0]  = 180,
    },
    [1] = {
        [-1] = -90,
        [0] = -90,
        [1] = -90,
    },
    [-1] = {
        [-1] = 90,
        [0] = 90,
        [1] = 90,
    }
}

local function getang(x,y, found)
    local ang = Angle()
    if found then
        ang.y = angkub2[x][y]
    else
        ang.y = angkub[x][y]
    end
    return ang
end

local WALL_T = 4.2
local PLATE_T = 4

if CLIENT then
    local function snapping_vec(vec, k, snap)
        if math.abs(vec[k]) > snap then
            vec[k] = 1 * ( vec[k] / math.abs(vec[k]) )
        else
            vec[k] = 0
        end
    end

    local align_limx = 0
    local align_limy = 0

    function SWEP:InterpMouse()
        if self.INInterpMouse then return end
        local ply = self:GetOwner()
        local cd = 0
        hook.Add("InputMouseApply", "BuildGetMouse", function(cmd,x,y)
            if cd > CurTime() then return true end

            if ply:KeyDown(IN_WALK) then
                y = math.Clamp(math.SnapTo(y/5,4),-16,16)
                self.ModelOffset.z = math.Clamp(self.ModelOffset.z - y, -128, 128)
                cd = CurTime() + 0.05
            else

                if self.AngleSnapping then
                    align_limy = align_limy + y/20
                    if math.abs(align_limy) > 10 then
                        self.AngleSnap.y = self.AngleSnap.y + (90 * (align_limy / math.abs(align_limy)))
                        align_limy = 0
                    end
                else

                    local mode = self:GetBuildType()
                    local mid = ply:KeyDown( IN_USE )

                    if ply:KeyDown(IN_SPEED) and (mode == BUILD_PLATE or mode == BUILD_CEIL) then
                        if mid then
                            y = math.SnapTo(y/2,90)
                            self.ModelOffsetAng.p = self.ModelOffsetAng.p + y
                            cd = CurTime() + 0.05
                        else
                            self.ModelOffsetAng.p = self.ModelOffsetAng.p + y/20
                        end
                    else
                        if mid then
                            x = math.SnapTo(x/2,90)
                            self.ModelOffsetAng.y = self.ModelOffsetAng.y + x
                            cd = CurTime() + 0.05
                        else
                            self.ModelOffsetAng.y = self.ModelOffsetAng.y + x/20
                        end
                    end
                end
            end
            
            cmd:SetMouseX(0)
            cmd:SetMouseY(0)
            
            return true
        end)
        self.INInterpMouse = true
    end

    function SWEP:StopInterpMouse()
        if !self.INInterpMouse then return end
        hook.Remove("InputMouseApply", "BuildGetMouse")
        self.INInterpMouse = nil
    end

    function SWEP:Think()
        local ply = self:GetOwner()

        if ply:KeyPressed(IN_RELOAD) then
            if ply:KeyDown(IN_WALK) then
                self.ModelOffset:Zero()
                self.ModelOffsetAng:Zero()
            else
                self:ShowSelector(true)
            end
        elseif ply:KeyReleased(IN_RELOAD) then
            self:ShowSelector(false)
        end

        if self.BuildGhost then
            if ply:KeyPressed(IN_ATTACK2) then
                self:InterpMouse()
            elseif ply:KeyReleased(IN_ATTACK2) then
                self:StopInterpMouse()
            end           
           
            if !self.BuildGhost:IsValid() or self:GetBuildType() == 0 or self:GetBuildModel() == 0 then return end
            local ghost = self.BuildGhost
            local owner = self:GetOwner()
            local t = util.TraceLine({
                start = owner:GetShootPos(),
                endpos = owner:GetShootPos() + ( owner:GetAimVector() * 300 ),
                filter = owner,
            }, ghost)
            
            local pos = t.HitPos
            
            local eye_angs = self:GetOwner():EyeAngles()
            if !cv_ang_view:GetBool() then eye_angs:Zero() end

            if BuildConf.ModelWithOffset[self:GetStrModel()] then
                local off = BuildConf.ModelWithOffset[self:GetStrModel()]
                --print(off.vec,  off.ang)
                eye_angs = eye_angs + off.ang
            end

            eye_angs.p, eye_angs.r = 0, 0
            local b_typ = self:GetBuildType()

            if t.Entity:IsValid() then
                if t.Entity:GetClass() != "build_prop" then
                    self.BlockBuild = true
                    return
                end
                
                local prop, model, typ = t.Entity, t.Entity:GetModel(), BuildGetCateg(t.Entity:GetModel())

                if (typ == BUILD_FOUND or typ == BUILD_PLATE) and (b_typ  == BUILD_FOUND or b_typ  == BUILD_STAIR or b_typ  == BUILD_PLATE)  then
                    local hull = BuildConf.ModelsHullType[typ]
                    local b_hull = BuildConf.ModelsHullType[b_typ]

                    local absh = vecabs(hull[2])
                    local lpos = prop:WorldToLocal(t.HitPos)
                    lpos = lpos / absh
 
                    local lpos_ang = Vector()
                    local snap_to = 1

                    if b_typ == BUILD_STAIR or b_typ == BUILD_PLATE or b_typ == BUILD_FOUND then
                        snapping_vec(lpos, "z", 1)
                        if lpos.z == 0 then
                            snapping_vec(lpos, "x", 1)
                            snapping_vec(lpos, "y", 1)
                        else
                            snapping_vec(lpos, "x", 0.5)
                            snapping_vec(lpos, "y", 0.5)
                        end
                    else
                        for k,v in pairs(lpos:ToTable()) do
                            snapping_vec(lpos, k, snap_to)
                        end
                    end

                    if b_typ == BUILD_PLATE or b_typ == BUILD_FOUND then
                        if math.abs(lpos.x) == 1 or math.abs(lpos.y) == 1 then
                            lpos.z = 0
                        end
                    end

                    local h = hull[1] - hull[2]
                    local ang = getang(lpos.x, lpos.y, true)
                    local height = Vector()

                    if b_typ == BUILD_STAIR and (typ == BUILD_PLATE or typ == BUILD_FOUND) then
                        if lpos.z != 0 then
                            lpos.x, lpos.y = 0, 0
                        end
                        local hz = BuildConf.ModelsHullType[BUILD_FOUND]
                        if typ == BUILD_PLATE then
                            height = Vector(0,0, hz[1].z - PLATE_T )
                        end

                        height.x = height.x + self.ModelOffset.x
                        height.y = height.y + self.ModelOffset.y

                    elseif b_typ == BUILD_PLATE and typ == BUILD_FOUND then
                        if math.abs(lpos.z) == 1 then
                            height = Vector(0,0, (hull[1].z - PLATE_T))
                        else
                            height = Vector(0,0, (hull[1].z - PLATE_T))
                        end
                    elseif b_typ == BUILD_FOUND and typ == BUILD_PLATE then
                        height = Vector(0,0, b_hull[1].z - PLATE_T)
                    elseif b_typ == BUILD_PLATE and typ == b_typ then
                        local hz = BuildConf.ModelsHullType[BUILD_FOUND]
                        height = Vector(0,0, (hz[1].z - hz[2].z)-PLATE_T*2) 
                        height.z = height.z * lpos.z
                    end

                    if b_typ == BUILD_PLATE then
                        height.z = height.z + self.ModelOffset.z
                    elseif b_typ == BUILD_PLATE then
                        height = height + self.ModelOffset
                    end

                    pos = prop:LocalToWorld(height + lpos*h )
                    if b_typ == BUILD_STAIR then
                        eye_angs = prop:GetAngles() + ang
                        if math.abs(lpos.z) == 1 then
                            eye_angs = prop:GetAngles() + self.AngleSnap
                        end
                    else
                        eye_angs = prop:GetAngles()
                    end
                elseif (typ == BUILD_WALLS or typ == BUILD_FOUND or typ == BUILD_PLATE) and b_typ == BUILD_WALLS then
                    local hull = BuildConf.ModelsHullType[BUILD_FOUND]
                    local hull_w = BuildConf.ModelsHullType[BUILD_WALLS]
                    local absh = vecabs(hull[2])

                    local lpos = prop:WorldToLocal(t.HitPos)
                    
                    lpos.z = 0
                    lpos = lpos / absh

                    snap_to = 0.8
                    for k,v in pairs(lpos:ToTable()) do
                        snapping_vec(lpos, k, snap_to)
                    end

                    local h = hull[1] - hull[2]
                    local hw = hull_w[1] - hull_w[2]
                    local ppos = lpos*h/2


                    ppos.z = ppos.z + hw.z
                    ppos.x = (math.abs(ppos.x)-WALL_T) * lpos.x
                    ppos.y = (math.abs(ppos.y)-WALL_T) * lpos.y

                    local ang = getang(lpos.x, lpos.y)

                    if lpos.x == 0 and lpos.y == 0 then
                        //print(self.AngleSnap)
                        ang = ang + self.AngleSnap
                    end

                    if typ == BUILD_PLATE then
                        ppos.z = (ppos.z / 2) + PLATE_T
                    end

                    if BuildConf.ModelWithOffset[self:GetStrModel()] then
                        local off = BuildConf.ModelWithOffset[self:GetStrModel()]
                        ang = ang + off.ang
                    end

                    pos = prop:LocalToWorld(ppos)
                    eye_angs = prop:GetAngles() + ang
                elseif (typ == BUILD_FOUND or typ == BUILD_PLATE or typ == BUILD_CEIL) and b_typ == BUILD_CEIL then
                    local hull = BuildConf.ModelsHullType[BUILD_FOUND]
                    local hull_c = BuildConf.ModelsHull[self:GetStrModel()]
                    local absh = vecabs(hull[2])
                    local height = Vector(0,0, (hull[1].z - hull[2].z)*1.5)
                    local height_c = Vector(0,0, hull_c[1].z)

                    local lpos = prop:WorldToLocal(t.HitPos)

                    lpos.z = 0
                    lpos = lpos / absh

                    local snap_to = 1
                    if typ == BUILD_CEIL then
                        snap_to = 0.5
                    end
                    for k,v in pairs(lpos:ToTable()) do
                        snapping_vec(lpos, k, 1)
                    end

                    if typ == BUILD_CEIL then
                        lpos.z = 0
                    end

                    local ang = getang(lpos.x, lpos.y)
                    if typ == BUILD_FOUND then
                        height.z = height.z - PLATE_T*2
                    elseif typ == BUILD_PLATE then
                        height.z = (height.z / 1.5) - PLATE_T
                    elseif typ == BUILD_CEIL then
                        local h = hull_c[2] - hull_c[1]
                        height_c.z = 0
                        height = h * -lpos
                    end

                    ang = ang + self.AngleSnap

                    eye_angs = prop:GetAngles() + ang
                    pos = prop:GetPos() + height + height_c
                elseif (typ == BUILD_WALLS) and b_typ == BUILD_DOOR then
                    local offset = BUILD_DOOR_OFFSET
                    
                    pos = prop:LocalToWorld(offset)
                    eye_angs = prop:GetAngles() + Angle(0,90,0)
                    self.DoorHole = prop
                else
                    self.DoorHole = nil
                    local hull = BuildConf.ModelsHullType[b_typ] or BuildConf.ModelsHull[self:GetStrModel()]

                    if !hull then
                        //print(123)
                        self.BlockBuild = true
                        return
                    end
                    local h = hull[1] - hull[2]
                    h.x, h.y, h.z = 0, 0, h.z / 2
                    pos = pos + h
                    eye_angs = eye_angs + self.ModelOffsetAng
                    //print(self.ModelOffsetAng)
                end
                if b_typ != BUILD_OTHER then
                    self.AngleSnapping = true
                end
            else
                local hull = BuildConf.ModelsHullType[b_typ] or BuildConf.ModelsHull[self:GetStrModel()]

                if !hull then
                    self.BlockBuild = true
                    return
                end
                local h = hull[1] - hull[2]
                h.x, h.y, h.z = 0, 0, h.z / 2
                pos = pos + h

                if b_typ == BUILD_FOUND then
                    pos.z = pos.z + self.ModelOffset.z
                end
                eye_angs = eye_angs + self.ModelOffsetAng 
                
                self.AngleSnapping = false
            end


            self.BlockBuild = false
            ghost:SetPos(pos)
            ghost:SetAngles(eye_angs)
    
            self.ModelPos = pos
            self.ModelAng = eye_angs
        end
    end
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

    --local pos_off = self.ModelOffset
    --local ang_off = self.ModelOffsetAng
    --local cur_mod_ang = self.ModelAng

    local mod = string_build[self:GetBuildType()]
    if !mod then mod = string_build[BUILD_NIL] end

	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( posx, posy )
	surface.SetFont( "HudDefault" )

	surface.DrawText( "Build mode: "..mod )

    surface.SetTextPos( posx-50, posy - str_dist*10)
    surface.DrawText( "HOW TO USE: " )
    surface.SetTextPos( posx-50, posy - str_dist*9)
    surface.DrawText( "RMB + mouse to rotate" )
    surface.SetTextPos( posx-50, posy - str_dist*8)
    surface.DrawText( "RMB + ALT for change z coordinate" )
    surface.SetTextPos( posx-50, posy - str_dist*7)
    surface.DrawText( "RMB + SHIFT for change pitch coordinate " )
    surface.SetTextPos( posx-50, posy - str_dist*6)
    surface.DrawText( "RMB + E for for rotate in 90 " )
    

    if self:GetBuildType() ~= 0 then
        draw.SimpleTextOutlined("Требуется ".. BuildConf.RecourceReq[self:GetBuildType()][JMod.EZ_RESOURCE_TYPES.CERAMIC] .. " Ceramic для постройки", "Trebuchet24", w * .75, h * .7 - 5, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
    end
end

-- if SERVER then
--     net.Receive("build_select_mode", function(_, ply)
--         local t = net.ReadUInt(4)
--         local m = net.ReadUInt(8)

--         local wep = ply:GetActiveWeapon()

--         if wep:GetClass() == "builder" then
--             wep:SetBuildType(t)
--             wep:SetBuildModel(m)
--         end
--     end)

--     net.Receive("build_create", function(_, ply)
--         local pos = net.ReadVector()
--         local ang = net.ReadAngle()

--         local wep = ply:GetActiveWeapon()

--         local UzhePostroili = false
--         local canbuild = false

--         if UzhePostroili then return end
        
--         --debugoverlay.Sphere( wep:GetOwner():GetPos(), 3000, 10,Color( 255, 255, 255 ), false )

--         if not GetConVar("sv_cheats"):GetBool() then
--             local squad = SquadMenu:GetSquad(ply:GetSquadID())
--             if JMod.HaveResourcesToPerformTask(nil, 350, BuildConf.RecourceReq[wep:GetBuildType()], wep) then
                    
--                 if ply:GetSquadID() == nil then return end
                    
--                 for k, ent in pairs(ents.FindInSphere(wep:GetOwner():GetPos(), 3000)) do
--                     if ent:GetClass() == "ent_rus_spawnbase" then
--                         --print(JMod.GetEZowner(ent))
--                         if JMod.GetEZowner(ent) ~= nil and JMod.GetEZowner(ent):IsPlayer() then
--                             if ((JMod.GetEZowner(ent):GetSquadID() == ply:GetSquadID()) or squad.Alliance[JMod.GetEZowner(ent):GetSquadID()]) and ent:GetBaseTitle() ~= "none" then
--                                 canbuild = true
--                                 if wep:GetClass() == "builder" then
--                                     wep:CreateProp(pos, ang)
--                                 end
--                             end
--                         end
--                     end
--                 end

--                 if not canbuild then
--                     ply:PrintMessage(HUD_PRINTCENTER, "Нужно строить рядом с базой")
--                 else
--                     JMod.ConsumeResourcesInRange(BuildConf.RecourceReq[wep:GetBuildType()], ply:GetShootPos(), 350, wep, false, false, 1)
--                 end

--             else
--                 ply:PrintMessage(HUD_PRINTCENTER, "Не хватает ресурсов для постройки")
--             end
--         else
--             if wep:GetClass() == "builder" then
--                 wep:CreateProp(pos, ang)
--             end
--         end

--         UzhePostroili = true

--     end)

--     net.Receive("build_create_door", function(_, ply)
--         local door_hole = net.ReadEntity()
--         local wep = ply:GetActiveWeapon()

--         if wep:GetClass() == "builder" then
--             wep:CreateDoor(door_hole)
--         end
--     end)
-- end
