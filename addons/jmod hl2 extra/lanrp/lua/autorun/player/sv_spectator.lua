

hook.Add( "PlayerUse", "SpectateUseBlock", function( ply, ent )
	if ply.SpectateMode then
        return false
    end

    return true
end )

hook.Add("PlayerSpawn", "SpectateOrNot", function(ply)
    ply.SpectateMode = false
end)