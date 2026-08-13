if killicon and killicon.Add then
    killicon.Add( "tfa_doibrowninghp", "vgui/hud/tfa_doibrowninghp", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_browninghp.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/browninghp/browning_hp_fp.wav"
--})

sound.Add(
{
    name = "Weapon_browninghp.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_browninghp.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_magout.wav"
})
sound.Add(
{
    name = "Weapon_browninghp.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_magin.wav"
})
sound.Add(
{
    name = "Weapon_browninghp.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_maghit.wav"
})
sound.Add(
{
    name = "Weapon_browninghp.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_browninghp.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/browninghp/handling/browning_hp_empty.wav"
})
