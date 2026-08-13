if killicon and killicon.Add then
    killicon.Add( "tfa_doi_thrownmk2", "vgui/hud/tfa_doi_mk2", Color( 0, 0, 0, 255 ) )
end


sound.Add(
{
    name = "Weapon_mk2.Pin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_pullpin.wav"
})
sound.Add(
{
    name = "Weapon_mk2.Throw",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_throw.wav"
})
sound.Add(
{
    name = "Weapon_mk2.PinPull",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_pinpull.wav"
})
sound.Add(
{
    name = "Weapon_mk2.SpoonEject",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_spooneject.wav"
})
sound.Add(
{
    name = "Weapon_mk2.LeftArmMovement",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_armdraw.wav"
})
sound.Add(
{
    name = "Weapon_mk2.ArmDraw",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_armdraw.wav"
})
sound.Add(
{
    name = "Weapon_mk2.ArmThrow",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/mk2/handling/mk2_throw_01.wav"
})

sound.Add(
{
    name = "Weapon_mk2.Bounce",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/mk2/mk2_bounce_01.wav",
				"weapons/mk2/mk2_bounce_02.wav",
				"weapons/mk2/mk2_bounce_03.wav",
				"weapons/mk2/mk2_bounce_04.wav",
			}
})
