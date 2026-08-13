if killicon and killicon.Add then
    killicon.Add( "tfa_doiwebley", "vgui/hud/tfa_doiwebley", Color( 0, 0, 0, 255 ) )
end

--sound.Add({
--    name = "Weapon_webley.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    sound = "weapons/webley/webley_fp.wav"
--})

sound.Add(
{
    name = "Weapon_webley.CockHammer",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_cock_hammer.wav"
})
sound.Add(
{
    name = "Weapon_webley.LeanIn",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_lean_in.wav"
})
sound.Add(
{
    name = "Weapon_webley.OpenChamber",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_open_chamber.wav"
})
sound.Add(
{
    name = "Weapon_webley.DumpRounds",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/webley/handling/webley_dump_rounds_01.wav",
				"weapons/webley/handling/webley_dump_rounds_02.wav",
				"weapons/webley/handling/webley_dump_rounds_03.wav",
			}
})
sound.Add(
{
    name = "Weapon_webley.RoundInsertSpeedLoader",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_speed_loader_insert_01.wav"
})
sound.Add(
{
    name = "Weapon_webley.CloseChamber",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_close_chamber.wav"
})
sound.Add(
{
    name = "Weapon_webley.Empty",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/webley/handling/webley_empty.wav"
})
