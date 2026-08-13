local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util

concommand.Add( "getwepmodel", function(ply)
    print(ply:GetActiveWeapon():GetModel())
end)

concommand.Add( "getwepclass", function(ply)
    print(ply:GetActiveWeapon():GetClass())
end)


concommand.Add( "getentmodel", function(ply)
    print( ply:GetEyeTrace().Entity:GetModel() )
end)

concommand.Add( "getentclass", function(ply)
    print( ply:GetEyeTrace().Entity:GetClass() )
end)

concommand.Add( "getenttable", function(ply)
    PrintTable(ply:GetEyeTrace().Entity)
end)

concommand.Add( "getwepammo", function(ply)
    print(game.GetAmmoName( ply:GetActiveWeapon():GetPrimaryAmmoType()), ply:GetActiveWeapon():GetPrimaryAmmoType())
end)

concommand.Add( "getentobb", function(ply)
    ply:ChatPrint("max:" .. tostring(ply:GetEyeTrace().Entity:OBBMaxs()))
    ply:ChatPrint("mins:" .. tostring(ply:GetEyeTrace().Entity:OBBMins()))
end)

concommand.Add("delete_in_radius", function(ply, _, arg)
    if ply:IsSuperAdmin() then
        for k, v in pairs(ents.FindInSphere( Player(2):GetPos(), 1024 )) do
            if v:GetModel() == "models/error.mdl" then
                v:Remove()
            end
        end
    end
end)

local particles = {
    ["ent_jack_gmod_ezvirusparticle"] = true,
    ["ent_jack_gmod_ezfalloutparticle"] = true,
    ["ent_jack_gmod_ezchlorineparticle"] = true

}

concommand.Add( "RemoveAllParticle", function(ply)
    if ply:IsSuperAdmin() then 
        for k, ent in ipairs(ents.GetAll()) do
            if particles[ent:GetClass()] then
                ent:Remove()
            end
        end
    end
end)

concommand.Add( "GiveMoney", function( ply, cmd, args )
    if ply:IsSuperAdmin() then 
        local value = tonumber(args[1])

        if value == nil then return end
        if ply:GetSquadID() == -1 then return end

        GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + value, true)
    end
end)
    
