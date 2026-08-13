if killicon and killicon.Add then
    killicon.Add( "tfa_doiwelrod", "vgui/hud/tfa_doiwelrod", Color( 0, 0, 0, 255 ) )
end

sound.Add({
    name = "Weapon_Welrod.1",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/welrod_fp.wav"
})

sound.Add(
{
    name = "Weapon_Welrod.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_magin.wav"
})
sound.Add(
{
    name = "Weapon_Welrod.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_magout.wav"
})
sound.Add(
{
    name = "Weapon_Welrod.TwistOpen",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_twist_open.wav"
})
sound.Add(
{
    name = "Weapon_Welrod.TwistClose",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_twist_close.wav"
})
sound.Add(
{
    name = "Weapon_Welrod.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_boltback.wav"
})
sound.Add(
{
    name = "Weapon_Welrod.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/welrod/handling/welrod_boltrelease.wav"
})