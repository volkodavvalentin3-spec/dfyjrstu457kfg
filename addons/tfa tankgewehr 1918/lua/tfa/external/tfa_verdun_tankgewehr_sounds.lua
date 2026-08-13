local path = "weapons/verdun_tankgewehr/"
local pref = "TFA_WW1_Tankgewehr_1918"
local hudcolor = Color(255, 255, 255, 255)

TFA.AddFireSound(pref .. ".Fire", path .. "t1918_1.wav", true, ")")

TFA.AddWeaponSound(pref .. ".BoltRelease", path .. "t1918_boltrelease.wav")
TFA.AddWeaponSound(pref .. ".Boltback", path .. "t1918_boltback.wav")
TFA.AddWeaponSound(pref .. ".Boltforward", path .. "t1918_boltforward.wav")
TFA.AddWeaponSound(pref .. ".BoltLatch", path .. "t1918_boltlatch.wav")
TFA.AddWeaponSound(pref .. ".Bulletin", path .. "t1918_bulletin.wav")
TFA.AddWeaponSound(pref .. ".Empty", path .. "t1918_empty.wav")

if killicon and killicon.Add then
	killicon.Add("tfa_verdun_tankgewehr", "vgui/hud/tfa_verdun_tankgewehr", hudcolor)
end