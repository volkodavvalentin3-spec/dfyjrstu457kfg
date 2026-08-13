AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

CreateClientConVar( "build_prop_gibs_enable", 1, true, false, "1-gibs enabled 0-gibs disabled", 0, 1 )

ENT.Model = ""
ENT.Connects = {}
ENT.Collides = {}
ENT.HP = 1000
ENT.Mass = 100000

ENT.DamageIgnoreEnt = {
	["ent_jack_gmod_ezsticknade"] = true,
	["ent_jack_gmod_ezmortarshell"] = true,
	--["ent_jack_gmod_ezhebomb"] = true,
    ["ent_jack_gmod_ezbomblet"] = true,
}

local sound_break = {
    [MAT_WOOD] = {
        "physics/wood/wood_box_impact_hard1.wav",
        "physics/wood/wood_box_impact_hard2.wav",
        "physics/wood/wood_box_impact_hard3.wav",
        "physics/wood/wood_box_Impact_hard4.wav",
        "physics/wood/wood_box_impact_hard5.wav",
        "physics/wood/wood_box_impact_hard6.wav",
    },
    [MAT_CONCRETE] = {
        "physics/concrete/concrete_break2.wav",
        "physics/concrete/concrete_break3.wav",
    },
    [MAT_METAL] = {
        "physics/metal/metal_barrel_impact_hard1.wav",
        "physics/metal/metal_barrel_impact_hard2.wav",
        "physics/metal/metal_barrel_impact_hard3.wav",
        "physics/metal/metal_barrel_impact_hard5.wav",
        "physics/metal/metal_barrel_impact_hard6.wav",
        "physics/metal/metal_barrel_impact_hard7.wav",
    },
    [MAT_GLASS] = {
        "physics/glass/glass_sheet_break1.wav",
        "physics/glass/glass_sheet_break2.wav",
        "physics/glass/glass_sheet_break3.wav",
        "physics/glass/glass_sheet_impact_hard1.wav",
        "physics/glass/glass_sheet_impact_hard2.wav",
        "physics/glass/glass_sheet_impact_hard3.wav",
    },
    [MAT_GRATE] = {
        "physics/wood/wood_box_impact_hard1.wav",
        "physics/wood/wood_box_impact_hard2.wav",
        "physics/wood/wood_box_impact_hard3.wav",
        "physics/wood/wood_box_Impact_hard4.wav",
        "physics/wood/wood_box_impact_hard5.wav",
        "physics/wood/wood_box_impact_hard6.wav",
    },
}

if SERVER then
    util.AddNetworkString("gib_prop")
end

--[[
local function Gib(mat, pos)
    if !BuildConf.Gibs[mat] then return end
    local force = Vector()
    for i = 1, 3 do
        local gib = ents.Create("prop_physics")
        local model = BuildConf.Gibs[mat][math.random(1, #BuildConf.Gibs[mat])]
        gib:SetModel(model)
        gib:SetPos(pos)
        gib:SetCollisionGroup(COLLISION_GROUP_WORLD)
        gib:Spawn()
        gib:SetVelocity(force)

        timer.Simple(0, function()
            local phys = gib:GetPhysicsObject()
            if phys:IsValid() then
                force:Random()
                phys:AddAngleVelocity(force*phys:GetMass()*math.random(100,1000))
                phys:ApplyForceCenter(force*phys:GetMass()*math.random(100,1000))
            end
        end)

        timer.Simple(8, function()
            if gib:IsValid() then
                gib:Remove()
            end
        end)
    end
end
--]]

local function Gib(mat, pos)
    if !BuildConf.Gibs[mat] then return end
    local force = Vector()
    for i = 1, 3 do
        local model = BuildConf.Gibs[mat][math.random(1, #BuildConf.Gibs[mat])]
        local gib = ents.CreateClientProp( model )
        gib:SetModel(model)
        gib:SetPos(pos)
        gib:Spawn()
        gib:SetVelocity(force)

        timer.Simple(0, function()
            local phys = gib:GetPhysicsObject()
            if phys:IsValid() then
                force:Random()
                phys:AddAngleVelocity(force*phys:GetMass()*math.random(100,1000))
                phys:ApplyForceCenter(force*phys:GetMass()*math.random(100,1000))
            end
        end)

        timer.Simple(8, function()
            if gib:IsValid() then
                gib:Remove()
            end
        end)
    end
end

function ENT:NoCollideWithProp(ent)
    if IsValid(self.Collides[ent]) then return end
    local nocolide = constraint.NoCollide( self, ent, 0, 0, true)
    self.Collides[ent] = nocolide
end

function ENT:WeldToCloseProps()
    local add_offset = Vector(1,1,1)

    local find_cube = {
        self:OBBMins()-add_offset,
        self:OBBMaxs()+add_offset,
    }

    local pnts = {}

    for x = 1, 2 do
        for y = 1, 2 do
            for z = 1, 2 do
                pnts[#pnts+1] = Vector( find_cube[x]["x"],
                                        find_cube[y]["y"],
                                        find_cube[z]["z"])
            end
        end
    end

    local vmin, vmax = self:LocalToWorld(pnts[1]), self:LocalToWorld(pnts[1])

    for k, v in pairs(pnts) do
        v = self:LocalToWorld(v)
        for kk, vv in pairs(v:ToTable()) do
            vmin[kk] = math.min(vmin[kk], vv)
            vmax[kk] = math.max(vmax[kk], vv)
        end
    end

    debugoverlay.Box( vector_origin, vmin, vmax, 4, Color( 0, 255, 0,10) , true)

    for _, ent in pairs(ents.FindInBox(vmin, vmax )) do
        if ent:GetClass() != "build_prop" then continue end
        if self:GetPos():Distance(ent:GetPos()) > 180 then continue end // disable to weld with diagonal pos prop
        if ent == self then continue end
        -- local weld = constraint.Weld( self, ent, 0, 0, 100000, false, false )

        -- weld.Ent1 = self
        -- weld.Ent2 = ent
        
        -- self.Connects[ent] = weld
        -- ent.Connects[self] = self.Connects[ent]

        self.Connects[ent] = true
        ent.Connects[self] = true

        debugoverlay.Line( self:GetPos(), ent:GetPos(), 4, Color(255,255,255,255), true)
    end
end

function ENT:CheckWorld()
    local find_cube = {
        self:OBBMins(),
        self:OBBMaxs(),
    }

    local pnts = {}

    for x = 1, 2 do
        for y = 1, 2 do
            for z = 1, 2 do
                pnts[#pnts+1] = Vector( find_cube[x]["x"],
                                        find_cube[y]["y"],
                                        find_cube[z]["z"])
            end
        end
    end

    for k, v in pairs(pnts) do
        local p = self:LocalToWorld(v)
        pnts[k] = p
        debugoverlay.Cross(p, 10,4, Color(255,0,0), true)
        if !util.IsInWorld(p) then
            self.Support = true//constraint.Weld(self, game.GetWorld(),0,0,0, false)
            return true
        end
    end

    local tr = {filter = self, collisiongroup = COLLISION_GROUP_WORLD, output = {}}

    for i = 0, 3 do
        tr.start = pnts[i+1]
        tr.endpos = pnts[#pnts-i]
        util.TraceLine(tr)
        if tr.output.HitWorld then
            self.Support = true //constraint.Weld(self, game.GetWorld(),0,0,0, false)
            return true
        end
    end

    if self.Typ == BUILD_FENCE then
        local tr = {filter = self, collisiongroup = COLLISION_GROUP_WORLD, output = {}}
        tr.start = self:GetPos()
        tr.endpos = tr.start - Vector(0,0,5)
        util.TraceLine(tr)
        if tr.output.HitWorld then
            self.Support = true //constraint.Weld(self, game.GetWorld(),0,0,0, false)
            return true
        end
    end

    return false
end



function ENT:Initialize()
    if !self.Model then self:Remove() end 
    self:SetModel(self.Model)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:DrawShadow(false)
    
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject() 

        if (phys:IsValid()) then
            self.OldMass = phys:GetMass() 
            phys:SetMass(self.Mass)

            if !self.CreatedBySave then
                self:WeldToCloseProps()
                local found = self:CheckWorld()

                if table.Count(self.Connects) > 0 or found then
                    self:SetUnFreezable( true )
                    phys:EnableMotion( false )
                else
                    phys:Wake()
                end
            else   
                if table.Count(self.Connects) > 0 or self.Support then
                    self:SetUnFreezable( true )
                    phys:EnableMotion( false )
                else
                    phys:Wake()
                end
            end
        end
    end
end

//
// это даст прирост фпс
//

ENT.Draw = ENT.DrawModel


-- function ENT:Draw()
--     self:DrawModel()
-- end

function ENT:GetAllConnectedProps()
    return self.Connects
end


local function WeldingStructure(ent_start, destruct_table)
    local welded_ents = {}

    local i = 1
    /* minimum version
    local function recurs_weld(par)
        welded_ents[par] = true
        
        for child, _ in pairs(par:GetAllConnectedProps()) do
            if !child:IsValid() then continue end
            i = i + 1
            if !welded_ents[child] then                
                local _, w = constraint.Weld( par, child, 0, 0, 100000, true, false)
                welded_ents[child] = true
                recurs_weld(child)
            end
        end
    end
    recurs_weld(ent_start)
    */
    local i = 0
    for ent, _ in pairs(destruct_table) do
        local con_ent = ent:GetAllConnectedProps()
        
        for con_ent, w in pairs(ent:GetAllConnectedProps()) do
            //if IsValid(w) then continue end
            //if ent == con_ent then continue end
            local _, weld = constraint.Weld( ent, con_ent, 0, 0, 100000, true, false)
            ent.Connects[ent] = weld
            i = i + 1
        end
    end

    print("connected props", i)
end

local dont_lomat = false

function ENT:ConnectedPropRemoved(removed_ent)
    //if return true
    if dont_lomat then return true end
    if self.Falled then return end

    local have_support = false
    local all_ents = {}

    local i = 1
    local function get2(par)
        all_ents[par] = true
        for child, wel in pairs(par:GetAllConnectedProps()) do
            if !child:IsValid() then continue end
            if child.Support then
                //if child.Support:IsValid() then
                    have_support = true
                    return
                //end
            end
            if have_support then
                break
            end
            i = i + 1 
            if !all_ents[child] then
                all_ents[child] = true
                get2(child) 
            end
        end
    end



    all_ents[self] = true
    get2(self)

    if have_support then return end
            
    WeldingStructure(self, all_ents)

    for ent, _ in pairs(all_ents) do
        if not IsValid(ent) then continue end
        
        if ent.Door then
            //ent.Door:Input("Break")    
            JMod.BlastThatDoor(ent.Door, Vector(0,0,0))
            timer.Simple(5, function()
                if IsValid(ent.Door) then
                    ent.Door:Remove()
                end
            end)
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            //self:BecameAlive()
            phys:EnableMotion( true )
            phys:Wake()

            timer.Simple(math.random(15, 60), function()
                if IsValid(ent) then
                    ent:BreakingEffect()
                    ent:Remove()
                end
            end)
        end

        ent.Falled = true
    end
end

function ENT:StartCheck()
    if dont_lomat then return true end

    for ent, con in pairs(self.Connects) do
        if !ent:IsValid() then continue end
        //if IsValid(con) then con:Remove() end
        ent.Connects[self] = nil
        ent:ConnectedPropRemoved(removed)

        
    end
end

function ENT:OnRemove()
    if !self.Breaking then
        self:StartCheck()
    end

    --[[for k,v in pairs(self:GetAllConnectedProps()) do
        if math.random(1,100) <= 40 then
            if IsValid(k) then
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    //self:BecameAlive()
                    phys:EnableMotion( true )
                    phys:Wake()
                
                    k:StartCheck()
                
                    timer.Simple(math.random(15, 60), function()
                        if IsValid(k) then
                            k:BreakingEffect()
                            k:Remove()
                        end
                    end)
                end
            end
        end
    end]]

    if CLIENT then
        if GetConVar( "build_prop_gibs_enable" ):GetInt() == 1 then
            local brkProp = util.GetModelInfo( self:GetModel() )

            local brkMat = util.GetSurfaceData( util.GetSurfaceIndex( brkProp.SurfacePropName ) )
            ---Gib( brkMat.material, self:GetPos())
        end
    end
end


local force_to_break = 800

local function getMul(m)
    if m <= 200 then
        return 1
    elseif m < 500 then
        return 1.5
    else return 2 end
end

function ENT:BreakingEffect()
    local mat = self:GetMaterialType()

    local eff = EffectData()
    eff:SetOrigin(self:GetPos())
    eff:SetScale(1.5)
    util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)

    if !sound_break[mat] then
        mat = MAT_CONCRETE
    end

    local snd = sound_break[mat][math.random(1,#sound_break[mat])]

    sound.Play(snd, self:GetPos(),SNDLVL_180dB, math.random(30, 50))
--    Gib(self:GetMaterialType(), self:GetPos())
end

function ENT:BecomeAlive()
    //self:SetMoveType(MOVETYPE_VPHYSICS)
    self:RemoveFlags(FL_STATICPROP)

    //self:PhysicsInit(SOLID_VPHYSICS)
end

function ENT:PhysicsCollide( data, phys )
    if dont_lomat then return true end
     
    if data.DeltaTime < 0.2 then return end

    if data.HitEntity:IsPlayer() then return end

    if data.Speed < 20 and data.HitEntity:GetClass() ~= "build_prop" then
        data.HitObject:Sleep()
    end
 
    --print(phys)
    if data.HitObject:GetMass() > 200 then
        ICEPhysCallback(phys:GetEntity(), data)
    end
    
    if self.Typ == BUILD_FOUND or self.Support then return end 
    if data.HitEntity:IsPlayer() then return end
    
    local force = data.Speed * getMul(data.HitObject:GetMass())
    local colent = data.HitEntity
    local phys_colent = data.HitObject

    if colent == Entity(0) and self.CollidedWithWorld == nil then
        if math.random(0,1) == 1 then
            self:BreakingEffect()
            self:Remove()
        else
            self.CollidedWithWorld = true
        end
    end

    if colent:GetClass() ~= "build_prop" then return end

    if phys_colent:IsMotionEnabled() then
        self:NoCollideWithProp(colent)
    end

    if force > force_to_break then
        if !phys:IsMotionEnabled() then // freezed block collide with unfreezed (fences and car)
            if colent:IsValid() then
                //self:BecomeAlive()
                phys:EnableMotion(true)
                self:StartCheck()

                timer.Simple(math.random(15, 60), function()
                    if IsValid(self) then
                        self:BreakingEffect()
                        self:Remove()
                    end
                end)
            end
        else
            if math.random(0,3) == 1 then
                self:BreakingEffect()
                self:Remove()
            else
                self:StartCheck()
            end
        end
    end

end

function ENT:OnTakeDamage(dmg)
    local mat = self:GetMaterialType()
    
    if self.DamageIgnoreEnt[dmg:GetInflictor():GetClass()] then return end

    if !(mat == MAT_WOOD and dmg:GetDamageType() == DMG_BURN) and !(dmg:IsExplosionDamage() or dmg:GetDamageType() == DMG_MISSILEDEFENSE) then
        return
    end

    if dmg:IsExplosionDamage() then
        dmg:SetDamage( dmg:GetDamage() / 2)
    elseif dmg:GetDamageType() == DMG_MISSILEDEFENSE then
        dmg:SetDamage( dmg:GetDamage() / 2 )
    end

    self.HP = self.HP - dmg:GetDamage()
    //print(self.HP, dmg:GetDamage())

    if !sound_break[mat] then
        mat = MAT_CONCRETE
    end

    if dmg:GetDamageType() != DMG_BURN then
        local snd = sound_break[mat][math.random(1,#sound_break[mat])]
        sound.Play(snd, self:GetPos(),SNDLVL_180dB, math.random(30, 50))

        sound.Play("lanrp/realism/weapon/dist/explosion/explosion_inside_0" .. math.random(1,9) .. ".ogg", self:GetPos(),SNDLVL_180dB, math.random(30, 50))
    end

    if self.HP < 1 then
        local maxToFall = 2
        local fallen = 0
        for k,v in pairs(self:GetAllConnectedProps()) do
            if math.random(1,100) <= 20 then
                fallen = fallen + 1
                if maxToFall == fallen then break end
                if IsValid(k) then
                    local phys = k:GetPhysicsObject()
                    if IsValid(phys) then
                        //self:BecameAlive()
                        phys:EnableMotion( true )
                        phys:Wake()
                    
                        k:StartCheck()
                    
                        timer.Simple(math.random(15, 60), function()
                            if IsValid(k) then
                                k:BreakingEffect()
                                k:Remove()
                            end
                        end)
                    end
                end
            end
        end

        if math.random(1,100) <= 60 then
            local phys = self:GetPhysicsObject()
            if IsValid(phys) then
                //self:BecameAlive()
                phys:EnableMotion( true )
                phys:Wake()

                self:StartCheck()

                timer.Simple(math.random(15, 60), function()
                    if IsValid(self) then
                        self:BreakingEffect()
                        self:Remove()
                    end
                end)
            end
        else
            self:BreakingEffect()
            --self.Breaking = true
            self:Remove()
            //self:StartCheck()
        end
    else
        // dont know about this
        local f = dmg:GetDamageForce()
        timer.Simple(0.01, function()
            if !self:IsValid() then return end
            local phys = self:GetPhysicsObject()
            if phys then
                if phys:IsMotionEnabled() then
                    phys:ApplyForceCenter(f)
                end
            end
        end)
        
    end
    return dmg:GetDamage()
end
