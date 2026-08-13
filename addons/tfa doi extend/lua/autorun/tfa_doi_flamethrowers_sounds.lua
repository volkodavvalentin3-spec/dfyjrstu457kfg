if killicon and killicon.Add then
    killicon.Add( "tfa_doi_flamethrower_american", "vgui/hud/tfa_doi_flamethrower_american", Color( 0, 0, 0, 255 ) )
end

if killicon and killicon.Add then
    killicon.Add( "tfa_doi_flamethrower_german", "vgui/hud/tfa_doi_flamethrower_german", Color( 0, 0, 0, 255 ) )
end


sound.Add(
{
    name = "Weapon_Flamethrower.turnon",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/flamethrower/flamethrower_turnon.wav"
})

sound.Add(
{
    name = "Weapon_Flamethrower.Empty",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/flamethrower/flamethrower_empty.wav"
})

sound.Add(
{
    name = "Weapon_Flamethrower.in",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/flamethrower/flamethrower_in.wav"
})

sound.Add(
{
    name = "Weapon_Flamethrower.loop",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/flamethrower/flamethrower_loop.wav"
})

sound.Add(
{
    name = "Weapon_Flamethrower.end",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/flamethrower/flamethrower_end.wav"
})
