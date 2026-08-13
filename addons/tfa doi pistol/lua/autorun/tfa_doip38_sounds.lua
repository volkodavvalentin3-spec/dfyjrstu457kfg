if killicon and killicon.Add then
    killicon.Add( "tfa_doip38", "vgui/hud/tfa_doip38", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_P38.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/p38/p38_fp.wav"
--})

sound.Add(
{
    name = "Weapon_p38.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_p38.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_magout.wav"
})
sound.Add(
{
    name = "Weapon_p38.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_magin.wav"
})
sound.Add(
{
    name = "Weapon_p38.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_maghit.wav"
})
sound.Add(
{
    name = "Weapon_p38.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_p38.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/p38/handling/p38_empty.wav"
})
