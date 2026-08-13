if killicon and killicon.Add then
    killicon.Add( "tfa_doiluger", "vgui/hud/tfa_doiluger", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_P08.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/p08/p08_fp.wav"
--})

sound.Add(
{
    name = "Weapon_P08.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p08/handling/p08_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_P08.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p08/handling/p08_magout.wav"
})
sound.Add(
{
    name = "Weapon_P08.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p08/handling/p08_magin.wav"
})
sound.Add(
{
    name = "Weapon_P08.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p08/handling/p08_maghit.wav"
})
sound.Add(
{
    name = "Weapon_P08.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p08/handling/p08_boltrelease.wav"
})
