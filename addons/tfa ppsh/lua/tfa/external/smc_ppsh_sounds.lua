local path = "smc/weapons/ppsh/"

sound.Add( {
	name = "TFA_INS2_ppsh.1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 115 },
	sound = {"smc/weapons/ppsh/ppsh_1.wav", "smc/weapons/ppsh/ppsh_2.wav", "smc/weapons/ppsh/ppsh_3.wav"}
} )

sound.Add( {
	name = "TFA_PPSH_LOOP.1",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 100,
	pitch = { 100, 105 },
	sound = {"smc/weapons/ppsh/ppsh_loop.wav"}
} )

sound.Add( {
	name = "TFA_PPSH_TAIL.1",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 100,
	pitch = { 80, 115 },
	sound = {"smc/weapons/ppsh/ppsh_tail1.wav"}
} )


TFA.AddWeaponSound("SMC_PPSH.Magout", path .. "ppsh_magout.wav")
TFA.AddWeaponSound("SMC_PPSH.Magin", path .. "ppsh_magin.wav")
TFA.AddWeaponSound("SMC_PPSH.Boltback", path .. "ppsh_boltback.wav")
TFA.AddWeaponSound("SMC_PPSH.Boltlock", path .. "ppsh_boltrelease.wav")
TFA.AddWeaponSound("SMC_PPSH.DrumMagHit", path .. "ppsh_hit.wav")
TFA.AddWeaponSound("SMC_PPSH.ROF", path .. "ppsh_rof.wav")
