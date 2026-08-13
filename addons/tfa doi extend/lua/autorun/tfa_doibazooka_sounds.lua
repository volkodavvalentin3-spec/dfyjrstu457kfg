if killicon and killicon.Add then
    killicon.Add("tfa_doi_bazooka", "vgui/hud/tfa_doi_bazooka", Color( 0, 0, 0, 255 ))
end

sound.Add(
{
    name = "Weapon_bazooka.1",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/bazooka_fp.wav"
})

sound.Add(
{
    name = "Weapon_bazooka.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/bazooka_endgrab.wav"
})
sound.Add(
{
    name = "Weapon_bazooka.Shoulder",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/Bazooka_shoulder.wav"
})
sound.Add(
{
    name = "Weapon_bazooka.ReShoulder",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/bazooka_reshoulder.wav"
})
sound.Add(
{
    name = "Weapon_Bazooka.Fetch",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/Bazooka_fetch.wav"
})
sound.Add(
{
    name = "Weapon_Bazooka.Load1",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/Bazooka_load1.wav"
})
sound.Add(
{
    name = "Weapon_Bazooka.Load2",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/Bazooka_load2.wav"
})
sound.Add(
{
    name = "Weapon_Bazooka.Wire",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/bazooka_wire.wav"
})
sound.Add(
{
    name = "Weapon_Bazooka.EndGrab",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Bazooka/handling/Bazooka_endgrab.wav"
})