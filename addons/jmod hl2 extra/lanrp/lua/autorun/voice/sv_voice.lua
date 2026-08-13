LanRp = LanRp or {}

LanRp.VoiceLines = {
    ["normal"] = {
        "voice/bloopers/goon/speak_1.ogg",
        "voice/bloopers/goon/speak_2.ogg",
        "voice/bloopers/goon/speak_3.ogg",
        "voice/bloopers/goon/speak_4.ogg",
    },

    ["korps"] = {
        "voice/bloopers/papers/korps1.ogg",
        "voice/bloopers/papers/korps2.ogg",
        "voice/bloopers/papers/korps3.ogg",
        "voice/bloopers/papers/korps4.ogg",
    },

    ["wilson"] = {
        "voice/bloopers/dont_starve/wilson_blooper.ogg",
    },

    ["wolfgang"] = {
        "voice/bloopers/dont_starve/wolfgang_blooper.ogg",
    },

    ["woodie"] = {
        "voice/bloopers/dont_starve/woodie_blooper.ogg",
    },

    ["wurt"] = {
        "voice/bloopers/dont_starve/wurt_blooper.ogg",
    },

    ["wx78"] = {
        "voice/bloopers/dont_starve/wx78_blooper.ogg",
    },

    ["ber"] = {
        "voice/new_barks/ber.ogg",
    },

    ["lan"] = {
        "voice/new_barks/lan.ogg",
    },

    ["rx"] = {
        "voice/new_barks/rx1.ogg",
        "voice/new_barks/rx2.ogg",
        "voice/new_barks/rx3.ogg",
    },

    ["papyrus"] = {
        "voice/bloopers/undertale/voice_papyrus.ogg",
    },

    ["sans"] = {
        "voice/bloopers/undertale/voice_sans.ogg",
    },
}


local math, Sound, timer, Color, table, Vector, Angle, util = math, Sound, timer, Color, table, Vector, Angle, util
hook.Add( "PlayerSpawn", "VoiceApply", function(ply)
	if ply:GetPData("voice") == nil then
		ply:SetPData( "voice", "normal")
    end
end)

hook.Add( "PlayerSay", "VoiceSpeech", function( ply, text )

    local voice = ply:GetPData("voice")
    local len = math.Clamp(string.len( text ), 0, 30)
    
    local text_split = string.Split( text, " " )

    if text_split[1] == "!voice" and text_split[2] == nil then
        for k,_ in pairs(LanRp.VoiceLines) do
            ply:ChatPrint(k)
        end

        return true
    end

    if text_split[1] == "!voice" and LanRp.VoiceLines[text_split[2]] then
        ply:ChatPrint("Вы выбрали голос " .. text_split[2])

        ply:SetPData( "voice", text_split[2])
        return true
    end

    local voice = ply:GetPData("voice")
    local len = math.Clamp(string.len( text ), 0, 30)
    local words = string.ToTable( text )

    local time = 0

    for i = 1, len do
        local bukva = words[i-1]
        if bukva == " " then time = time + 0.4 continue end
        if bukva == "," then time = time + 0.5 continue end
        if bukva == "." then time = time + 0.6 continue end
    
        time = time + 0.1
    
        timer.Simple(time, function() 

            if not ply:Alive() then return end

            if voice == "none" then
                ply:EmitSound( table.Random(LanRp.VoiceLines["human"]), 75, math.random(65, 150), 1, CHAN_AUTO ) 
            else
                ply:EmitSound( table.Random(LanRp.VoiceLines[voice]), 75, math.random(65, 150), 1, CHAN_AUTO )
            end
        end)
    end
end )