if killicon and killicon.Add then
    killicon.Add( "tfa_doiithaca37", "vgui/hud/tfa_doiithaca37", Color( 0, 0, 0, 255 ) )
end

--sound.Add(
--{
--    name = "Weapon_Ithaca.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    soundlevel = 75,
--    sound = "weapons/ithaca/ithaca_fp2.wav"
--})

sound.Add(
{
    name = "Weapon_Ithaca.Pumpback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ithaca/handling/ithaca_pumpback.wav"
})
sound.Add(
{
    name = "Weapon_Ithaca.Pumpforward",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ithaca/handling/ithaca_pumpforward.wav"
})
sound.Add(
{
    name = "Weapon_Ithaca.LeanIn",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ithaca/handling/ithaca_lean_in.wav"
})
sound.Add(
{
    name = "Weapon_Ithaca.ShellInsert",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/ithaca/handling/ithaca_shell_insert_1.wav",
				"weapons/ithaca/handling/ithaca_shell_insert_2.wav",
				"weapons/ithaca/handling/ithaca_shell_insert_3.wav",
			}
})
sound.Add(
{
    name = "Weapon_Ithaca.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/ithaca/handling/ithaca_rattle.wav"
})