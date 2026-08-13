local base_folder = "autorun/"

local function LoadModuleFolder(modulenm) 
    local full_folder = base_folder
    if modulenm and modulenm ~= "" then 
        full_folder = full_folder .. modulenm
    end

    local files, folders = file.Find(full_folder .. "*", "LUA")
    for _, ifolder in ipairs(folders) do
        LoadModuleFolder(modulenm .. ifolder .. "/")
    end

    for _, CL in ipairs(file.Find(full_folder .. "cl_*.lua", "LUA")) do
        if SERVER then AddCSLuaFile(full_folder .. CL) end
        if CLIENT then include(full_folder .. CL) end
    end

    for _, SH in ipairs(file.Find(full_folder .. "sh_*.lua", "LUA")) do
        if SERVER then AddCSLuaFile(full_folder .. SH) end
        include(full_folder .. SH)
    end

    if SERVER then
        for _, SV in ipairs(file.Find(full_folder .. "sv_*.lua", "LUA")) do
            include(full_folder .. SV)
        end
    end
end

LoadModuleFolder("") 