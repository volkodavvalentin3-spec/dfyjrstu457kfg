if killicon and killicon.Add then
    killicon.Add( "tfa_doim1911", "vgui/hud/tfa_doim1911", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_M1911.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/m1911/m1911_fp.wav"
--})

sound.Add(
{
    name = "Weapon_M1911.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_M1911.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_magout.wav"
})
sound.Add(
{
    name = "Weapon_M1911.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_magin.wav"
})
sound.Add(
{
    name = "Weapon_M1911.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_maghit.wav"
})
sound.Add(
{
    name = "Weapon_M1911.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_M1911.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1911/handling/m1911_empty2.wav"
})
