if killicon and killicon.Add then
    killicon.Add( "tfa_doisw1917", "vgui/hud/tfa_doisw1917", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_M1917.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/sw1917/sw1917_fp.wav"
--})

sound.Add(
{
    name = "Weapon_M1917.CockHammer",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/sw1917/handling/sw1917_cock_hammer.wav"
})
sound.Add(
{
    name = "Weapon_M1917.LeanIn",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/sw1917/handling/sw1917_lean_in.wav"
})
sound.Add(
{
    name = "Weapon_M1917.OpenChamber",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/sw1917/handling/sw1917_open_chamber.wav"
})
sound.Add(
{
    name = "Weapon_M1917.DumpRounds",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/sw1917/handling/sw1917_dump_rounds_01.wav",
				"weapons/sw1917/handling/sw1917_dump_rounds_02.wav",
				"weapons/sw1917/handling/sw1917_dump_rounds_03.wav",
			}
})
sound.Add(
{
    name = "Weapon_M1917.MoonClip",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/sw1917/handling/sw1917_moonclip_insert_01.wav",
				"weapons/sw1917/handling/sw1917_moonclip_insert_02.wav",
				"weapons/sw1917/handling/sw1917_moonclip_insert_03.wav",
			}
})
sound.Add(
{
    name = "Weapon_M1917.CloseChamber",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/sw1917/handling/sw1917_close_chamber.wav"
})
sound.Add(
{
    name = "Weapon_M1917.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/sw1917/handling/sw1917_empty.wav"
})
