if killicon and killicon.Add then
    killicon.Add( "tfa_doim1a1para", "vgui/hud/tfa_doim1a1para", Color( 0, 0, 0, 255 ) )
	killicon.Add( "tfa_doim1carbine_early", "vgui/hud/tfa_doim1carbine_early", Color( 0, 0, 0, 255 ) )
	killicon.Add( "tfa_doim2carbine", "vgui/hud/tfa_doim2carbine", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_m1carbine.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/m1carbine/m1carbine_fp.wav"
--})

sound.Add(
{
    name = "Weapon_m1carbine.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_boltback.wav"
})
sound.Add(
{
    name = "Weapon_m1carbine.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_m1carbine.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_magin.wav"
})
sound.Add(
{
    name = "Weapon_m1carbine.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_magout.wav"
})
sound.Add(
{
    name = "Weapon_m1carbine.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_m1carbine.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1carbine/handling/m1carbine_rattle.wav"
})

