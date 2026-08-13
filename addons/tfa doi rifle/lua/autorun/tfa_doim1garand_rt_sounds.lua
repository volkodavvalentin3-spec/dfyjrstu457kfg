if killicon and killicon.Add then
    killicon.Add( "tfa_doim1garand_scop", "vgui/hud/tfa_doim1garand_scop", Color( 0, 0, 0, 255 ) )
	killicon.Add( "tfa_doim1garand", "vgui/hud/tfa_doim1garand", Color( 0, 0, 0, 255 ) )
end


--sound.Add({
--    name = "Weapon_Garand.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/m1garand/garand_fp.wav"
--})

sound.Add({
	name = 			"Weapon_Garand.Ping",
	channel = CHAN_USER_BASE+12,
	volume = 		1.0,
	sound = "weapons/m1garand/handling/garand_nan.wav"
})

sound.Add({
	name = 			"Weapon_Garand.Ping2",
	channel = CHAN_STATIC,
	volume = 		1.0,
	sound = 		{	"weapons/m1garand/handling/garand_ping_01.wav",
						"weapons/m1garand/handling/garand_ping_02.wav",
						"weapons/m1garand/handling/garand_ping_03.wav",
						"weapons/m1garand/handling/garand_ping_04.wav",
						"weapons/m1garand/handling/garand_ping_05.wav",
					}
})

sound.Add(
{
    name = "Weapon_Garand.Magrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_magrelease.wav"
})
sound.Add(
{
    name = "Weapon_Garand.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_boltback.wav"
})
sound.Add(
{
    name = "Weapon_Garand.Magout",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_magout.wav"
})
sound.Add(
{
    name = "Weapon_Garand.MagFetch",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_fetchmag.wav"
})
sound.Add(
{
    name = "Weapon_Garand.Magin",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_magin.wav"
})
sound.Add(
{
    name = "Weapon_Garand.MagHit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_maghit.wav"
})
sound.Add(
{
    name = "Weapon_Garand.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_boltrelease.wav"
})
sound.Add(
{
    name = "Weapon_Garand.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1garand/handling/garand_rattle.wav"
})
