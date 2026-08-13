AddCSLuaFile()

include("systems/c_hitboxsystem.lua")
include("systems/c_lagcompensationmanager.lua")
include("systems/c_projectilemanager.lua")
include("systems/c_projectilesystem.lua")

include("systems/bulletphysicssettings.lua")

local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

// Utility modules
local net = include("utility/extranet.lua")

local BulletPhysics = {}
_G.BulletPhysics = BulletPhysics

-- Cached functions
local player_GetCount = player.GetCount
local player_GetAll = player.GetAll

local function Fallback(tbl, index, fallback)
    if not tbl then return end
    if not index then return end

    if tbl[index] == nil then
        tbl[index] = fallback
    end
    return tbl[index]
end

-- Hook name
local HookIndentifier = "BPhys_"
BulletPhysics.HookIdentifier = HookIndentifier

-- Initialize the systems
local BulletPhysicsProjectileSystem = C_ProjectileSystem:New()
BulletPhysics.ProjectileSystem = BulletPhysicsProjectileSystem


// Settings

/////////////////////////////////////////////////////////////////////////////////////////////////////


local function getDigitsPos(float)
    local i = 1
    local f, float = 0, math.abs(float)
    if float == 0 then return 0 end
    while true do
        if i > 7 then return 0 end
        f = float * 10^i
        if f > 1 then return i-1 end
        i = i + 1
    end
end

-- Network bullets created by global managers
local function OnCreateProjectile(self, BulletInfo)
    local BulletInfo = BulletInfo

    Fallback(BulletInfo, "Settings", {})

    local ConvarSettings = BulletPhysicsGetConvars()
    Fallback(BulletInfo.Settings, "Speed", ConvarSettings.Speed:GetInt())
    Fallback(BulletInfo.Settings, "Gravity", ConvarSettings.Gravity:GetInt())
    Fallback(BulletInfo.Settings, "EnableSounds", ConvarSettings.EnableSounds:GetBool())
    Fallback(BulletInfo.Settings, "ShouldBounce", ConvarSettings.ShouldBounce:GetBool())

    -- Send messages to players other than attacker
    //PrintTable(BulletInfo)
    net.Start(HookIndentifier .. "NetworkBullets", true)
    /*                                                                          old version
        net.WriteEntity(BulletInfo.Attacker)
        net.WriteFloat(BulletInfo.Settings.Speed)
        net.WriteFloat(BulletInfo.Settings.Gravity)
        net.WriteBool(BulletInfo.Settings.ShouldBounce)
        net.WriteBool(BulletInfo.Settings.EnableSounds)
        net.WriteVectorFloat(BulletInfo.Dir)
        net.WriteVectorFloat(BulletInfo.Src)
        */
        --[[                                                                     109
        net.WriteEntity(BulletInfo.Attacker)
        if BulletInfo.Attacker:IsPlayer() then 
            net.WriteVectorFloat(BulletInfo.Src)
        else
            net.WriteVectorFloat(BulletInfo.Dir)

            net.WriteVectorFloat(BulletInfo.Src)
        end
        --]]
        // 43
        //if true then return end
        net.WriteEntity(BulletInfo.Attacker)

        if BulletInfo.Attacker:IsPlayer() then
            local bullet_dir = BulletInfo.Dir 

            //print(BulletInfo.Attacker, bullet_dir, bullet_dir:Angle())
            
            local digit = math.min( getDigitsPos(bullet_dir.x),
                                    getDigitsPos(bullet_dir.y),
                                    getDigitsPos(bullet_dir.z))
                                    
            local bullet_dir = bullet_dir * 10^digit
            net.WriteUInt(digit, 3)
            net.WriteNormal(bullet_dir)
        elseif BulletInfo.Attacker.Networked_PhysBullets--[[BulletInfo.Attacker:IsVehicle() and BulletInfo.Attacker.Networked_PhysBullets--]] then
            net.WriteBool(BulletInfo.LVS_isCustomAttachment)
            net.WriteUInt(BulletInfo.LVS_attachment,5)
            
            local bullet_dir = BulletInfo._dDir//BulletInfo.Dir

            local digit = math.min( getDigitsPos(bullet_dir.x),
                        getDigitsPos(bullet_dir.y),
                        getDigitsPos(bullet_dir.z))
                                    
            local bullet_dir = bullet_dir * 10^digit
            net.WriteUInt(digit, 3)
            net.WriteNormal(bullet_dir)
        else
            net.WriteVectorFloat(BulletInfo.Dir)
            net.WriteVectorFloat(BulletInfo.Src)
        end

    net.OmitBroad(BulletInfo.Attacker)
end

-- Create a manager for the player
local function AssignManager(Player)
    -- Returns if the player already has a manager
    local PlayerManager = Player:GetProjectileManager()
    if PlayerManager then 
        BulletPhysicsProjectileSystem:RemoveManager(PlayerManager)
        Player:RemoveProjectileManager()
    end
    local NewManager = BulletPhysicsProjectileSystem:NewManager()

    -- Make the manager predicted
    NewManager:EnablePrediction()

    NewManager:AttachToPlayer(Player)
    -- Network bullets to other players
    if SERVER then
        NewManager.OnCreateProjectile = OnCreateProjectile
    end
end


-- Only available on server
if SERVER then
    -- Network string for sending bullets to clients
    util.AddNetworkString(HookIndentifier .. "NetworkBullets")
    util.AddNetworkString(HookIndentifier .. "ClientReady")

    net.Receive(HookIndentifier .. "ClientReady", function(_, Player)
        AssignManager(Player)
    end)

    -- Allow for lua refresh
    local PlayerCount = player_GetCount()
    local Players = player_GetAll()

    for i = 1, PlayerCount do
        AssignManager(Players[i])
    end

    -- Create the server manager
    BulletPhysicsProjectileSystem:CreateGlobalManager()
    BulletPhysicsProjectileSystem:GetGlobalManager().OnCreateProjectile = OnCreateProjectile



    //function weapons.GetListByCategory()
    //    local Categories = {}
    
    //    local WeaponList = weapons.GetList()
    
    //    for k, Weapon in next, WeaponList do
    //        if Weapon.Category and Weapon.Spawnable then
    //            local Category = Fallback(Categories, Weapon.Category, {})

    //            Category[#Category+1] = Weapon
    //        end
    //    end
    //    return Categories
    //end

    //--PrintTable(GetWeaponsByCategory())

    //for k,v in pairs(weapons.GetListByCategory()) do
    //    --print(#v, k)
    //    --print(string.format("(%G) - %s", #v, k))
    //end
end

if CLIENT then
    hook.Add("InitPostEntity", HookIndentifier .. "LocalPlayerSpawned", function()
        AssignManager(LocalPlayer())
        _G.BulletPhysicsClientInitialized = true

        net.Start(HookIndentifier .. "ClientReady")
        net.SendToServer()
    end)

    -- Allow for lua refresh
    if _G.BulletPhysicsClientInitialized then
        AssignManager(LocalPlayer())
    end

    -- Create the client manager
    BulletPhysicsProjectileSystem:CreateGlobalManager()

    -- Receive bullets from sources other than localplayer
    net.Receive(HookIndentifier .. "NetworkBullets", function()
        local BulletInfo = {}
        BulletInfo.Settings = {}
/*

        BulletInfo.Attacker = net.ReadEntity()
        BulletInfo.Settings.Speed = net.ReadFloat()
        BulletInfo.Settings.Gravity = net.ReadFloat()
        BulletInfo.Settings.ShouldBounce = net.ReadBool()
        BulletInfo.Settings.EnableSounds = net.ReadBool()

        BulletInfo.Dir = net.ReadVectorFloat()
        BulletInfo.Src = net.ReadVectorFloat()

        */

        local ConvarSettings = BulletPhysicsGetConvars()

        local speed = ConvarSettings.Speed:GetInt()
        local gravity = ConvarSettings.Gravity:GetInt()
        local enableSounds = ConvarSettings.EnableSounds:GetBool()
        local shouldBounce = ConvarSettings.ShouldBounce:GetBool()

        BulletInfo.Attacker = net.ReadEntity()


        BulletInfo.Settings.Speed = speed
        BulletInfo.Settings.Gravity = gravity
        BulletInfo.Settings.ShouldBounce = shouldBounce
        BulletInfo.Settings.EnableSounds = enableSounds

        /*
        if BulletInfo.Attacker:IsPlayer() then
            BulletInfo.Dir = net.ReadVectorFloat()
            BulletInfo.Src = BulletInfo.Attacker:EyePos()
        else    
            BulletInfo.Dir = net.ReadVectorFloat()
            BulletInfo.Src = net.ReadVectorFloat()
        end
 
        PrintTable(BulletInfo)
        */

        if BulletInfo.Attacker:IsPlayer() then
            local digits     = net.ReadUInt(3)
            local bullet_dir = net.ReadNormal() / 10^digits

            BulletInfo.Dir = bullet_dir + BulletInfo.Attacker:EyeAngles():Forward()
            BulletInfo.Src = BulletInfo.Attacker:EyePos()
        elseif --[[BulletInfo.Attacker:IsVehicle() and--]] BulletInfo.Attacker.Networked_PhysBullets then
            local isCustomAttachment = net.ReadBool()
            local attachment_id = net.ReadUInt(5)

            local digits     = net.ReadUInt(3)
            local bullet_dir = net.ReadNormal() / 10^digits

            if isCustomAttachment then
                local attach_data = BulletInfo.Attacker.CustomAttachments[attachment_id]
                //PrintTable(attach_data)
                //print(attach_data.Pos)
                BulletInfo.Src = BulletInfo.Attacker:LocalToWorld(attach_data.Pos)
                BulletInfo.Dir = BulletInfo.Attacker:LocalToWorldAngles(attach_data.Ang):Forward() + bullet_dir
            else
                
                local attach_data = BulletInfo.Attacker:GetAttachment(attachment_id)//BulletInfo.Attacker.CustomAttachments
                
                BulletInfo.Src = attach_data.Pos
                BulletInfo.Dir = attach_data.Ang + bullet_dir
                
                //BulletInfo

            end
        else
            BulletInfo.Dir = net.ReadVectorFloat()
            BulletInfo.Src = net.ReadVectorFloat()
        end

        local wep

        if BulletInfo.Attacker.GetActiveWeapon then
            wep = BulletInfo.Attacker:GetActiveWeapon()
        end

        if IsValid(wep) and wep.IsTFA and wep:GetClass() ~= "tfa_doiwelrod" then

            local soundname = "lanrp/realism/weapon/dist/universal/dist_shot.mp3"

            local pos = BulletInfo.Attacker:GetPos()

            if wep.TrueDistantSound then
                soundname = wep.TrueDistantSound    
            end

            if wep.Holdtype == "pistol" or wep.Holdtype == "revolver" then
				soundname = "LANRP/realism/weapon/dist/pistol/m1911_dist.mp3"		
	    	end

            if LocalPlayer():GetPos():Distance(pos) >= 2000--[[ and LocalPlayer():GetPos():Distance(ent:GetPos()) <= 25000]] then
        
                timer.Simple(LocalPlayer():GetPos():Distance(pos) / 9000, function()
                    sound.PlayFile("sound/" .. soundname, "3d", function( station, errCode, errStr )
                        if ( IsValid( station ) ) then
                            station:SetPos(pos)
                            station:Set3DFadeDistance( 7000, 20000 )
                            --station:Play()
                        end
                    end)
                end)
            
            
                if math.random(1,100) <= 15 then
                
                    local num = math.random(1,21) 
                
                    if num <= 9 then
                        num = "0" .. num
                    end
                
                    timer.Simple(LocalPlayer():GetPos():Distance(pos) / 9000, function()
                        sound.PlayFile("sound/" .. "lanrp/realism/weapon/dist/universal/ww2_distant_firefight_" .. num .. ".ogg", "3d", function( station, errCode, errStr )
                            if ( IsValid( station ) ) then
                                station:SetPos(pos)
                                station:Set3DFadeDistance( 10000, 20000 )
                                --station:Play()
                            end
                        end)
                    end)
                
                    if math.random(1,100) <= 10 then
                        timer.Simple(LocalPlayer():GetPos():Distance(pos) / 9000, function()
                            sound.PlayFile("sound/" .. "lanrp/realism/weapon/dist/universal/dist_crowd_warzone_0" .. math.random(1,7) .. ".ogg", "3d", function( station, errCode, errStr )
                                if ( IsValid( station ) ) then
                                    station:SetPos(pos)
                                    station:Set3DFadeDistance( 10000, 20000 )
                                    --station:Play()
                                end
                            end)
                        end)
                    end
                end
            end
        end
        
        local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()
        local Projectile = Manager:CreateProjectile(BulletInfo)
    end)
end


// Shared

-- Run predicted managers
hook.Add("SetupMove", HookIndentifier .. "PredictedManagerLogic", function(Player, CMoveData, CUserCmd)
    -- Run manager for the player
    local Manager = Player:GetProjectileManager()
    if Manager then
        Manager:OnSetupMove(Player, CMoveData, CUserCmd)
    end
end)

-- Run unpredicted managers
hook.Add("Tick", HookIndentifier .. "UnpredictedManagerLogic", function()
    -- Run managers for every projectile system
    for _, Manager in ipairs(BulletPhysicsProjectileSystem:GetManagers()) do
        -- Run the manager
        Manager:OnSetupMoveUnpredicted()
    end

    local GlobalManager = BulletPhysicsProjectileSystem:GetGlobalManager()
    GlobalManager:OnSetupMoveUnpredicted()
end)

-- Detours the FireBullets function
EntityMeta = FindMetaTable("Entity")
EntityMeta._FireBullets = EntityMeta._FireBullets or EntityMeta.FireBullets
function EntityMeta:FireBullets(BulletInfo)
    if not IsFirstTimePredicted() then return end

    local ConvarSettings = BulletPhysicsGetConvars()
    -- Master killswitch
    if not ConvarSettings.Enabled:GetBool() then
        self:_FireBullets(BulletInfo)
        return
    end

    -- Localize BulletInfo to prevent editing of the table outside the function
    local BulletInfo = table.Copy(BulletInfo)

    -- Sets the bullet's attacker
    BulletInfo.Attacker = self

    -- Remove callback function
    BulletInfo.Callback = nil

    -- Track which bullets are which
    BulletInfo.TracerName = "Projectile"

    //PrintTable(BulletInfo)
    //print(BulletInfo.LVS_IsCustomAttachment,BulletInfo.LVS_attachment)
    -- Create the table if it doesnt exist
    Fallback(BulletInfo, "Settings", {})

    Fallback(BulletInfo.Settings, "Speed", ConvarSettings.Speed:GetInt())
    Fallback(BulletInfo.Settings, "Gravity", ConvarSettings.Gravity:GetInt())
    Fallback(BulletInfo.Settings, "EnableSounds", ConvarSettings.EnableSounds:GetBool())
    Fallback(BulletInfo.Settings, "ShouldBounce", ConvarSettings.ShouldBounce:GetBool())
    
    -- Shoot many bullets
    local Num = BulletInfo.Num or 1
    for NumBullets = 1, Num do
        -- Save bullet.dir for later so we can revert back (Spread modifies the direction)
        local Dir = BulletInfo.Dir
        
        if BulletInfo.Spread then
            ProjectileInfo:CalculateSpread(BulletInfo, engine.TickCount(), NumBullets)
        end

        if self:IsPlayer() then
            -- Get the player's assigned manager
            local Manager = self:GetProjectileManager()

            -- Create the projectile
            Manager:CreateProjectile(BulletInfo)
        elseif SERVER then
            -- Gets the serverside manager
            local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()

            -- Create the projectile
            Manager:CreateProjectile(BulletInfo)
        end

        -- Revert back
        BulletInfo.Dir = Dir
    end
end

-- Override bullets from engine weapons
hook.Add("PostEntityFireBullets", HookIndentifier .. "FireBullets", function(Entity, BulletInfo)
    if not IsFirstTimePredicted() then return end

    local ConvarSettings = BulletPhysicsGetConvars()
    if not ConvarSettings.Enabled:GetBool() then
        return true
    end

    -- Dont override our bullets (Shouldnt need this but here we are)
    if BulletInfo.TracerName == "Projectile" then return true end

    local BulletInfo = BulletInfo

    local Trace = BulletInfo.Trace
    BulletInfo.Dir = (Trace.HitPos - Trace.StartPos):GetNormalized()
    BulletInfo.Src = Trace.StartPos
    BulletInfo.Attacker = Entity

    Entity:FireBullets(BulletInfo)

    -- Suppress the bullet
    return false
end)


/////////////////////////////////////////////////////////////////////////////////////////////////////

-- Rendering

if CLIENT then
    hook.Add("Think", HookIndentifier .. "ProjectileInterpolation", function()

        -- Interpolate local bullets
        local Manager = LocalPlayer():GetProjectileManager()
        if Manager then
            Manager:InterpolateProjectilePositions()
        end

        -- Interpolate global bullets
        local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()
        if Manager then
            Manager:InterpolateProjectilePositions()
        end
    end)

    hook.Add("Think", HookIndentifier .. "BulletFlyby", function()
        -- Interpolate local bullets
        local Manager = LocalPlayer():GetProjectileManager()
        if Manager then
            Manager:CrackProjectiles()
        end

        -- Interpolate global bullets
        local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()
        if Manager then
            Manager:CrackProjectiles()
        end
    end)

    hook.Add("Think", HookIndentifier .. "BulletSuppression", function()

        local Manager = LocalPlayer():GetProjectileManager()
        if Manager then
            Manager:SupressProjectiles()
        end


        local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()
        if Manager then
            Manager:SupressProjectiles()
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", HookIndentifier .. "ProjectileRender", function()
        -- Render localplayer's bullets
        local Manager = LocalPlayer():GetProjectileManager()
        if Manager then
            Manager:RenderProjectiles()
        end

        -- Render global bullets
        local Manager = BulletPhysicsProjectileSystem:GetGlobalManager()
        if Manager then
            Manager:RenderProjectiles()
        end
    end)
end