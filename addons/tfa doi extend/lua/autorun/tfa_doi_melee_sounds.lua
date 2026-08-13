if killicon and killicon.Add then
    killicon.Add( "tfa_doi_etoolger", "vgui/hud/tfa_doi_etoolger", Color( 0, 0, 0, 255 ) )
end

if killicon and killicon.Add then
    killicon.Add( "tfa_doi_marinebayonet", "vgui/hud/tfa_doi_marinebayonet", Color( 0, 0, 0, 255 ) )
end


sound.Add(
{
    name = "tfa_doi_Knife.Slash",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = {  "weapons/melee/knife/knife_slash1.wav",
	           "weapons/melee/knife/knife_slash2.wav",
			}
})

sound.Add(
{
    name = "tfa_doi_Knife.Slash2",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/melee/knife/knife_slash3.wav"
})

sound.Add(
{
    name = "tfa_doi_knife.Hitwall",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = "weapons/melee/knife/knife_hitwall1.wav"
})

sound.Add(
{
    name = "tfa_doi_knife.Hit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/melee/knife/knife_hit1.wav",
				"weapons/melee/knife/knife_hit2.wav",
				"weapons/melee/knife/knife_hit3.wav",
				"weapons/melee/knife/knife_hit4.wav",
			}
})

--tool

sound.Add(
{
    name = "tfa_doi_tool.Slash",
    channel = CHAN_USER_BASE+10,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/melee/entrenchingtool/ent_tool_stabmiss1.wav",
				"weapons/melee/entrenchingtool/ent_tool_stabmiss2.wav",
			}
})

sound.Add(
{
    name = "tfa_doi_tool.Hitwall",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/melee/entrenchingtool/ent_tool_attack_1.wav",
				"weapons/melee/entrenchingtool/ent_tool_attack_2.wav",
			}
})

sound.Add(
{
    name = "tfa_doi_tool.Hit",
    channel = CHAN_ITEM,
    volume = 1.0,
    soundlevel = 75,
    sound = {	"weapons/melee/entrenchingtool/ent_tool_attack_1.wav",
				"weapons/melee/entrenchingtool/ent_tool_attack_2.wav",
			}
})