if killicon and killicon.Add then
    killicon.Add("ent_panzerfaust_shell", "vgui/hud/tfa_doi_panzerfaust", Color( 0, 0, 0, 255 ))
end

sound.Add(
{
    name = "Weapon_Panzerfaust.1",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Panzerfaust/panzerfaust_fp.wav"
})

sound.Add(
{
    name = "Weapon_Panzerfaust.Pin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Panzerfaust/handling/Panzerfaust_pinout.wav"
})
sound.Add(
{
    name = "Weapon_Panzerfaust.Sight",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Panzerfaust/handling/Panzerfaust_sightup.wav"
})
sound.Add(
{
    name = "Weapon_Panzerfaust.Shoulder",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/Panzerfaust/handling/Panzerfaust_shoulder.wav"
})