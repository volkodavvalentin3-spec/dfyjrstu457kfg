CreateConVar("proximity_radius", 3000, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Radius, in which players can hear each other.")
CreateConVar("proximity_mute", 0.3, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Volume of players, when they're behind the walls. (0-1)", 0, 1)
CreateConVar("proximity_enabled", 1, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Switches between global and proximity voice chat.", 0, 1)

--[[hook.Add( "PlayerCanHearPlayersVoice", "Maximum Range", function(listener, talker)
    local maxDistance = GetConVar("proximity_radius"):GetInt()
    local proximityEnabled = GetConVar("proximity_enabled"):GetInt()

    if proximityEnabled == 0 then
		return true, false
	end
	
    local distance = listener:GetPos():Distance(talker:GetPos())

    if distance > maxDistance then
        return false, false
    end

    return true, true
end)]]