if killicon and killicon.Add then
    killicon.Add( "tfa_doim1912", "vgui/hud/tfa_doim1912", Color( 0, 0, 0, 255 ) )
end


--sound.Add(
--{
--    name = "Weapon_M1912.1",
--    channel = CHAN_USER_BASE+10,
--    volume = 1.0,
--    soundlevel = 75,
--    sound = "weapons/m1912/m1912_fp2.wav"
--})

sound.Add(
{
    name = "Weapon_M1912.Boltback",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1912/handling/ithaca_pumpback.wav"
})
sound.Add(
{
    name = "Weapon_M1912.Boltrelease",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1912/handling/ithaca_pumpforward.wav"
})
sound.Add(
{
    name = "Weapon_M1912.LeanIn",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1912/handling/ithaca_lean_in.wav"
})
sound.Add(
{
    name = "Weapon_M1912.ShellInsert",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/m1912/handling/ithaca_shell_insert_1.wav",
				"weapons/m1912/handling/ithaca_shell_insert_2.wav",
				"weapons/m1912/handling/ithaca_shell_insert_3.wav",
			}
})
sound.Add(
{
    name = "Weapon_M1912.Rattle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/m1912/handling/ithaca_rattle.wav"
})
sound.Add(
{
    name = "Weapon_M1912.ShellInsertSingle",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/m1912/handling/ithaca_single_shell_insert_1.wav",
				"weapons/m1912/handling/ithaca_single_shell_insert_2.wav",
				"weapons/m1912/handling/ithaca_single_shell_insert_3.wav",
			}
})

