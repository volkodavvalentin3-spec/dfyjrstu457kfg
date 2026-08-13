if killicon and killicon.Add then
    killicon.Add( "tfa_doippk", "vgui/hud/tfa_doippk", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_Ppk.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/ppk/ppk_fp.wav"
--})

sound.Add(
{
    name = "Weapon_Ppk.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_Ppk.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_magout.wav"
})
sound.Add(
{
    name = "Weapon_Ppk.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_magin.wav"
})
sound.Add(
{
    name = "Weapon_Ppk.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_maghit.wav"
})
sound.Add(
{
    name = "Weapon_Ppk.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_Ppk.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ppk/handling/ppk_empty.wav"
})
