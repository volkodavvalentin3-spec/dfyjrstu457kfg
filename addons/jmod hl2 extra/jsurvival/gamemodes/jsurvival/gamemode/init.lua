JMod = JMod or {}
JSMod = JSMod or {}

AddCSLuaFile("sh_loader.lua")
include("sh_loader.lua")

resource.AddWorkshop("1919689921")
resource.AddWorkshop("3310371040")

function GM:Initialize()
end

local color_white = Color(255, 255, 255)
hook.Add("PlayerInitialSpawn", "JS_INITIAL_PLAYERSPAWN", function(ply)
    timer.Simple(15, function()
        BetterChatPrint(ply, "Чтобы начать выживать, вам лучше забиндить эту команду 'jmod_ez_inv' на I или любую другую.", color_white)
        BetterChatPrint(ply, "Затем в инвентаре, нажмите 'scrounge'", color_white)
        BetterChatPrint(ply, "По округе появятся пропы, которые нужны для крафта верстака.", color_white)
    end)
end)

hook.Add( "Move", "NewMoveSystem", function( ply, mv )
	value = mv:GetMaxSpeed()

	local IsSprint = (ply:IsSprinting() and mv:GetForwardSpeed() > 1) and 0.06 or 0.4

	ply:SetRunSpeed(Lerp(IsSprint, ply:GetRunSpeed(), (ply:IsSprinting() and mv:GetForwardSpeed() > 1) and 280 or ply:GetWalkSpeed()))
	ply:SetWalkSpeed(Lerp( (mv:GetForwardSpeed() > 1 and 0.03) or 1, ply:GetWalkSpeed(), (mv:GetForwardSpeed() > 1 and 180) or 90))
	ply:SetSlowWalkSpeed(Lerp( (ply:GetVelocity():Length() > 1 and 0.03) or 1, ply:GetSlowWalkSpeed(), (ply:GetVelocity():Length() > 1 and 100) or 20))

	mv:SetMaxSpeed(value)
	mv:SetMaxClientSpeed(value)

	if ply:IsSprinting() then
		ply:SetJumpPower(0)
	else
		ply:SetJumpPower(200)
	end

	local armorfrac = math.Clamp((ply.EZarmor.speedfrac or 1) * 1.1, 0, 1)
	if armorfrac != nil then
		value = mv:GetMaxSpeed() * armorfrac --math.max(armorfrac,0.75)
		mv:SetMaxSpeed(value)
		mv:SetMaxClientSpeed(value)
	end

end)

hook.Remove("Move","JMOD_ARMOR_MOVE")

hook.Add("SetupMove", "JS_SPRINT", function(ply, mv, cmd)
    if ply:InVehicle() then return end
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
end)

hook.Add("PlayerSwitchFlashlight", "JS_SWITCH_FLASHLIGHT", function(ply, enabled) if not JMod.PlyHasArmorEff(ply, "HEVsuit") and not JMod.PlyHasArmorEff(ply, "flashlight") and enabled then return false end end)
hook.Add("PlayerSwitchWeapon", "JS_INTERRUPT_WEAPON_SWITCH", function(ply, oldWep, newWep) if ply:IsValid() and newWep:IsValid() then 
      --JMod.AddToInventory(ply, oldWep) 
    end end)
function GM:PlayerLoadout(ply) 
    local walkspeed = GetConVar("js_walkspeed")
    local runspeed = GetConVar("js_runspeed")
    ply:Give("wep_jack_gmod_hands") --ply:Give("wep_jack_gmod_eztoolbox")
    ply:SetDuckSpeed( 0.4 )
	ply:SetUnDuckSpeed( 0.3 )
	ply:SetCanZoom( false )
end
if SERVER then
	function GM:PlayerSpawnProp(ply, model)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnRagdoll(ply, model)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnSENT(ply, class)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnSWEP(ply, class, info)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnObject(ply)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerGiveSWEP(ply, class, swep)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnNPC(ply, npc_type, weapon)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
	function GM:PlayerSpawnVehicle(ply, model, name, table)
		if JMod.IsAdmin(ply) then 
			return true 
		else
			return false
		end
	end
end