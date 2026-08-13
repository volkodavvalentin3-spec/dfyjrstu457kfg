if killicon and killicon.Add then
    killicon.Add( "tfa_doimp34", "vgui/hud/tfa_doimp34", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_mp34.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/mp34/mp34_fp2.wav"
--})

sound.Add(
{
    name = "Weapon_mp34.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_magout.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_magin.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Maghit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_maghit.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_boltback.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_boltrelease3.wav"
})
sound.Add(
{
    name = "Weapon_mp34.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mp34/handling/mp34_empty.wav"
})
