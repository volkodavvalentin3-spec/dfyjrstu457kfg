if killicon and killicon.Add then
    killicon.Add("tfa_doi_panzerschreck", "vgui/hud/tfa_doi_panzerschreck", Color( 0, 0, 0, 255 ))
end

sound.Add(
{
    name = "Weapon_panzerschreck.1",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/panzerschreck_fp.wav"
})

sound.Add(
{
    name = "Weapon_panzerschreck.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_endgrab.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.Shoulder",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_shoulder.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.ReShoulder",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_reshoulder.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.Fetch",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_fetch.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.Load1",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_load1.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.Load2",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_load2.wav"
})
sound.Add(
{
    name = "Weapon_panzerschreck.Wire",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_wire.wav"
})

sound.Add(
{
    name = "Weapon_panzerschreck.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/panzerschreck/handling/panzerschreck_empty.wav"
})