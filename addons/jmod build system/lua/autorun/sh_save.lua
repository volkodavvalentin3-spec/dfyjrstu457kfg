local path = ""
if SERVER then
    util.AddNetworkString("buildmode_save")
    util.AddNetworkString("buildmode_save_open")

end
local function ReconvertData(data)
    local count = table.Count(data)
    local savedata = {
        count = count,
        build = {}
    }

    for k, v in pairs(data) do
        
        if BuildGetCateg(k:GetModel()) != BUILD_GATE then
            local build_block = {
                id = k:EntIndex(),
                typ = BuildGetCateg(k:GetModel()),
                model = k:GetModel(),
                skin = k:GetSkin(),
                support = v.support,
                pos = k:GetPos(),
                ang = k:GetAngles(),
            }

            build_block.childs = {}
            for kk, vv in pairs(v.childs) do
                table.insert(build_block.childs, kk:EntIndex())
            end
            if IsValid(k.Door) then
                build_block.door = {
                    model = k.Door:GetModel(),
                    skin  = k.Door:GetSkin(),
                }
            end

            savedata.build[build_block.id] = build_block
        else

            local build_block = {
                id = k:EntIndex(),
                typ = BUILD_GATE,
                model = k:GetModel(),
                pos = k:GetPos(),
                ang = k:GetAngles(),
            }

            savedata.build[build_block.id] = build_block

        end
    end

    return util.TableToJSON( savedata, true )
end

local function GetAllBuildable(ent)
    if !IsValid(ent) then return {} end
    if !ent.GetAllConnectedProps then return {} end
    local data = {}
    local i = 1

    local function get2(par)
        data[par] = {
            ent = par,
            childs = {},
            support = par.Support == true,
            id = i,
        }
 
        for child, wel in pairs(par:GetAllConnectedProps()) do      
            i = i + 1
            if !IsValid(child) then continue end
            if !ent.GetAllConnectedProps then continue end

            //if !data[child] then
                data[par]["childs"][child] = true
                if !data[child] then
                    get2(child)
                end
            //end
        end
    end

    get2(ent)

    return data
end

local function SaveBuild(fn)
    local save_data = {}
    for k, entity in pairs(ents.FindByClass("build_prop")) do
        if save_data[entity] then continue end

        if IsValid(entity) then
            if !entity.GetAllConnectedProps then continue end
            
            print("Save build: start save from", entity)
            local build = GetAllBuildable(entity)
            print("Save build: collected ", table.Count(build))

            //PrintTable(build)

            table.Merge(save_data, build)
        end

    end

    //PrintTable(save_data)

    for k, entity in pairs(ents.FindByClass("prop_ww_door")) do
        local gate = {
            ent = entity,
        }

        //print(entity)
        save_data[entity] = gate
    end

    -- for k, entity in pairs(ents.FindByClass("prop_ww_doo")) do
        
    --         id = k:EntIndex(),
    --         typ = BuildGetCateg(k:GetModel()),
    --         model = k:GetModel(),
    --         skin = k:GetSkin(),
    --         support = v.support,
    --         pos = k:GetPos(),
    --         ang = k:GetAngles(),
    -- end

//PrintTable(save_data)

    print("Save build: collected props: ", table.Count(save_data))

    local json = ReconvertData(save_data)

    local nfile = ""
    if fn then
        nfile = path..fn..".txt"
    else
        nfile = path.."build_"..tostring(math.random(100000,1000000))..".txt"
    end

    //print(nfile)


    if file.Write( nfile, json ) then
        print("Save build: "..nfile.." file saved", file.Size( nfile, "DATA" ))
        
    else
        print("Save build: "..nfile.." CANT SAVE!")
    end
end



net.Receive("buildmode_save", function(_, ply)
    if !ply:IsAdmin() then return end
    local fn = net.ReadString()

    //print(fn)
    SaveBuild(fn)
end)

concommand.Add("build_save", function(ply, _, arg)
    if CLIENT then
        net.Start("buildmode_save")
        net.WriteString(tostring(arg[1]))
        net.SendToServer()
    else
        SaveBuild(ply, tostring(arg[1]))
    end
end)


-- ===================================================================

local function createDoor(ent_wall, model, skin)
    local offset = BUILD_DOORHOLE_OFFSET[ent_wall:GetModel()] or BUILD_DOOR_OFFSET
    local offset_ang = BUILD_DOOR_OFFSET_ANG

    local door = ents.Create("prop_door_rotating")
    door:SetModel(model)
    door:SetSkin(skin or 0)
    door:SetPos(ent_wall:LocalToWorld(offset))
    door:SetAngles(ent_wall:LocalToWorldAngles(offset_ang))

    door.IsBuildDoor = true
    door:Spawn()
    door:SetBodygroup(1, 2)
end

function BuildOpenSave(fn)
    local fpath = path..fn..".txt"
    local json_data = file.Read(fpath)
    
    if json_data == nil or json_data == "" then
        print("Save build: error open file - "..fpath)
        return
    end


    local save_data = util.JSONToTable(json_data)

    if !save_data then
        print("Save build: error open file (NIL table after json) - "..fpath)
        return
    elseif table.IsEmpty(save_data) then
        print("Save build: error open file (EMPTY table after json)- "..fpath)
        return
    end

    local props_list = {}

                -- id = k:EntIndex(),
                -- typ = BuildGetCateg(k:GetModel()),
                -- model = k:GetModel(),
                -- skin = k:GetSkin(),
                -- support = v.support,
                -- pos = k:GetPos(),
                -- ang = k:GetAngles(),

    local props_created = false
    -- local function CreateProp()
    --     local prop
    --     local idk
    --     while true do
    --         local idk = next(save_data.build, idk)
    --         if not idk then
   
    --             props_created = true
    --             break
    --         end

            
    --         local data = save_data.build[idk]
    --         if data.typ == BUILD_GATE then
    --             prop = ents.Create("prop_ww_door")
    --             prop:SetPos(data.pos)
    --             prop:SetAngle(data.ang)
    --             prop:Spawn()
    --         else
    --             prop = ents.Create("build_prop")
    --             prop:SetPos(data.pos)
    --             prop:SetAngle(data.ang)
    --             prop:SetModel(data.model)
    --             prop:SetSkin(data.skin)

    --             prop.support = data.support
    --             prop.Support = data.support
                
    --             prop.CreatedBySave = true

    --             props_list[data.id] = prop
    --         end
    --     end
    -- end

    local idk
 
    local function SpawnProps()
        idk = next(save_data.build, idk)
        if not idk then
            print("Save build, end")
            idk = nil
            timer.Remove("Save_SpawnProps")
            return
        end


        local prop = props_list[idk]
        if prop then
            prop:Spawn()
        end
    end

    local function ApplyConnection()
        idk = next(save_data.build, idk)

        if not idk then
            print("Save build, connections end, start spawn")

            idk = nil
            timer.Remove("Save_SpawnProps")
            timer.Create("Save_SpawnProps", 0.01, 0,SpawnProps )
            return
        end

        local data = save_data.build[idk]
        local prop = props_list[idk]

        if !prop then return end

        for _, idd in pairs(data.childs) do
            local child_prop = props_list[idd]
            prop.Connects[child_prop] = true
            child_prop.Connects[prop] = true
        end
    end

    print("Save build: start spawning props")
    timer.Create("Save_SpawnProps", 0.01, 0, function()
        idk = next(save_data.build, idk)
        if not idk then
            print("Save build, props created, connections start")
            idk = nil
            timer.Remove("Save_SpawnProps")
            timer.Create("Save_SpawnProps", 0.01, 0, ApplyConnection)
            return
        end

        local data = save_data.build[idk]

                //local data = save_data.build[idk]
        if data.typ == BUILD_GATE then
            local prop = ents.Create("prop_ww_door")
            
            prop:SetPos(data.pos)
            prop:SetAngles(data.ang)
            prop:Spawn()

        else
            local prop = ents.Create("build_prop")
            prop:SetPos(data.pos)
            prop:SetAngles(data.ang)
            prop:SetModel(data.model)
            prop:SetSkin(data.skin)

            prop.Typ = data.typ
            prop.Support = data.support
            prop.CreatedBySave = true

            if data.door then
                createDoor(prop, data.door.model, data.door.skin)
            end

            props_list[data.id] = prop
        end
    end)
end



net.Receive("buildmode_save_open", function(_, ply)
    if !ply:IsAdmin() then return end
    local fn = net.ReadString()

    BuildOpenSave(fn)
end)

concommand.Add("build_opensave", function(ply, _, arg)
    if CLIENT then
        net.Start("buildmode_save_open")
        net.WriteString(tostring(arg[1]))
        net.SendToServer()
    else
        SaveBuild()
    end
end)

