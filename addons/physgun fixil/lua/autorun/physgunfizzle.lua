AddCSLuaFile()
PhysgunFizzle = {}

-- Client
if CLIENT then
    include("physgunfizzle/cl_fizzle.lua")
else
    AddCSLuaFile("physgunfizzle/cl_fizzle.lua")
end

-- Shared
include("physgunfizzle/sh_fizzle.lua")
AddCSLuaFile("physgunfizzle/sh_fizzle.lua")

include("physgunfizzle/sh_config.lua")
AddCSLuaFile("physgunfizzle/sh_config.lua")

-- Server
if SERVER then
    include("physgunfizzle/sv_fizzle.lua")
end