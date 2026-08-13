if killicon and killicon.Add then
    killicon.Add( "tfa_doistg44", "vgui/hud/tfa_doistg44", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_Stg44.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/Stg44/stg44_fp.wav"
--})

sound.Add(
{
    name = "Weapon_Stg44.MagRelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_magin.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_magout.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.MagoutRattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_magout_rattle.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_rattle.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_boltback.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_Stg44.Hit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Stg44/handling/Stg44_maghit.wav"
})