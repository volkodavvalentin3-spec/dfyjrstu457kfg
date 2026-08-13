local proximityEnabled = CreateConVar("proximity_enabled", 1, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Switches between global and proximity voice chat.", 0, 1)
local maxDistance = CreateConVar("proximity_radius", 3000, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Radius, in which players can hear each other.")
local muteVolume = CreateConVar("proximity_mute", 0.3, { FCVAR_ARCHIVE,FCVAR_REPLICATED }, "Volume of players, when they're behind the walls. (0-1)", 0, 1)

local function UpdateVoiceDSP(listener, talker)
    if not IsValid(listener) or not IsValid(talker) or listener == talker then return end
	
    if not proximityEnabled:GetBool() then
        talker:SetVoiceVolumeScale(1)
        return
    end

    local distance = listener:GetPos():Distance2DSqr(talker:GetPos())

    local maxdist = maxDistance:GetInt() ^ 2

    if distance > maxdist then return end

    local trace = util.TraceLine({
        start = listener:EyePos(),
        endpos = talker:EyePos(),
        filter = function(ent)
            return ent != listener and ent != talker and (not ent:IsPlayer() or not ent:IsNPC()) and ent:GetClass() != "prop_physics"
        end
    })

	local volume = 1
	local mute = muteVolume:GetFloat()
	
	if distance < 200 then
		mute = math.min(muteVolume:GetFloat() * 2, 1)
	end

	if talker:WaterLevel() == 3 then
		mute = math.max(muteVolume:GetFloat() / 2, 0)
	end
    if trace.Hit or talker:WaterLevel() == 3 then
		volume = (((distance / maxdist) * -1) + 1) * mute
    else
		volume = (((distance / maxdist) * -1) + 1)
    end
	
	talker:SetVoiceVolumeScale(volume)
end

hook.Add("Think", "ClientVoiceFilterThink", function()
    local listener = LocalPlayer()
    if not IsValid(listener) then return end

    for _, talker in ipairs(player.GetAll()) do
        if talker ~= listener and talker:IsSpeaking() then
            UpdateVoiceDSP(listener, talker)
        end
    end
    
end)

hook.Add("PlayerEndVoice", "ClientVoiceFilterEnd", function(ply)
    ply:SetVoiceVolumeScale(1)
end)