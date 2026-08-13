print("nm ond")

//if SERVER then
//  AddCSLuaFile("client/environmentcontrolclient.lua")
//    include("server/environmentcontrolserver.lua")
//else
//    include("client/environmentcontrolclient.lua")
//end

local night_sky = "sky_borealis01"
local sky =  GetConVar( "sv_skyname" )
local current = current or sky:GetString()

local env_ambientLight_cv = GetConVar("Environment_ambientLightLevel") 
local env_sunLight_cv = GetConVar("Environment_SunLightLevel")
local env_radiosityZero_cv =  GetConVar("Environment_ForceRadiosityZero")
local env_noStaticSelfIllum = GetConVar("Environment_DisableStaticSelfIllum")

local fog_opt = { 
    day = Color(0.73, 0.60, 0.40),
    night = Color(0.13, 0.11, 0.16),
    fog = Color(0.27, 0.25, 0.22), 
}

local function SetNightSky()
    //sky:SetString(night_sky)
    print(sky)
    RunConsoleCommand("sv_skyname", night_sky)
end

local function ResetDay()
    // code for return to daymode
//    sky:SetString(current)
    env_ambientLight_cv:SetInt(12)
    env_sunLight_cv:SetInt(12) 
    env_radiosityZero_cv:SetBool(false)
    env_noStaticSelfIllum:SetBool(false)
end

local function SetLightToNight()
    env_ambientLight_cv:SetInt(1)
	env_sunLight_cv:SetInt(1)
    env_radiosityZero_cv:SetBool(true)
    env_noStaticSelfIllum:SetBool(true)
    local col = fog_opt.night

    //render.FogColor( col.r * 255, col.y * 255, col.z * 255 )

    SetNightSky()
end
if SERVER then
    concommand.Add("night_mode", function()
        SetLightToNight()
    end)


    concommand.Add("night_mode_reset", function()
        ResetDay()
    end)
end