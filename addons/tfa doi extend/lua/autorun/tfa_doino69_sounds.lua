if killicon and killicon.Add then
    killicon.Add( "tfa_doi_thrownno96", "vgui/hud/tfa_doi_no69", Color( 0, 0, 0, 255 ) )
end

sound.Add(
{
    name = "Weapon_No69.ArmDraw",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/no69/handling/no69_armdraw.wav"
})
sound.Add(
{
    name = "Weapon_No69.ArmThrow",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/no69/handling/no69_throw.wav"
})
sound.Add(
{
    name = "Weapon_No69.CapOff",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/no69/handling/no69_capoff.wav"
})