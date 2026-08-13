if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Bipods"
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = {
	TFA.AttachmentColors[""], "I know u want prone...",
	TFA.AttachmentColors["+"], "-80% ADS Recoil",
	TFA.AttachmentColors["-"], "-80% ADS Walking Speed",
}
ATTACHMENT.Icon = "entities/doimg_bipods.png" --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.ShortName = "DOIBIP"

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["mbrake2"] = {
			["active"] = true
		}
	},
	["WElements"] = {
		["mbrake2"] = {
			["active"] = true
		}
	},
	["Primary"] = {
		--["IronRecoilMultiplier"] = function(wep,stat) return stat * 0.1 end,
	},
	["IronRecoilMultiplier"] = function(wep,stat) return stat * 0.4 end,
	["IronSightsMoveSpeed"] = function(wep,stat) return stat * 0.2 end,
}


if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
