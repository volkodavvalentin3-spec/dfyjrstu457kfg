if killicon and killicon.Add then
    killicon.Add( "tfa_doig43", "vgui/hud/tfa_doig43", Color( 0, 0, 0, 255 ) )
	killicon.Add( "tfa_doig43_scop", "vgui/hud/tfa_doig43", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_tfa_g43.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/g43/g43_fp.wav"
--})


sound.Add(
{
    name = "Weapon_tfa_g43.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.Magout",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_magout.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.MagFetch",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_magfetch.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_magin.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_rattle.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_boltback.wav"
})
sound.Add(
{
    name = "Weapon_tfa_g43.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/g43/handling/g43_boltrelease.wav"
})
