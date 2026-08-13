if killicon and killicon.Add then
    killicon.Add( "tfa_doifg42", "vgui/hud/tfa_doifg42", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_Fg42.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/fg42/fg42_fp.wav"
--})

sound.Add(
{
    name = "Weapon_Fg42.FetchMag",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_mag_fetch.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_magin.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_maghit.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_magout.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_boltback.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_rattle.wav"
})
sound.Add(
{
    name = "Weapon_Fg42.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/fg42/handling/fg42_empty.wav"
})