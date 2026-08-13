if CLIENT then return end


-- Network Strings:

util.AddNetworkString("ragdeath_client")

util.AddNetworkString("ragdeath_server_convar")
util.AddNetworkString("ragdeath_enabled_to_client")

--------------------
-- Server ConVars --
--------------------

local MaxRagdollsVar = CreateConVar("rd_keepmax","2",FCVAR_ARCHIVE,"", 1)
local LifetimeVar = CreateConVar("rd_timeremove","120", FCVAR_ARCHIVE,"")
local CollidePlayersVar = CreateConVar("rd_playercollide","0", FCVAR_ARCHIVE,"")
local AllowBloodVar = CreateConVar("rd_blood", "1", FCVAR_ARCHIVE,"")
local BloodThresholdVar = CreateConVar("rd_blood_threshold", "500", FCVAR_ARCHIVE,"")
local RagDeathEnabledVar = CreateConVar("rd_enable", "1", {FCVAR_ARCHIVE,FCVAR_GAMEDLL,FCVAR_REPLICATED,FCVAR_PROTECTED}, "")
local WeightMulVar = CreateConVar("rd_weight_multiplier", "1", FCVAR_ARCHIVE,"")


----------------
--  Variables --
----------------

local DeathRagdolls = {} -- Stores an array of ragdolls for all players
						 -- Each player may have more than 1 ragdoll



------------------
-- Blood decals --
------------------

-- Called when ragdolls collide with something. Adds blood decals
local function OnRagdollCollide(collider, colData  )	
	if AllowBloodVar:GetBool() then
		if colData.Speed < BloodThresholdVar:GetFloat() then return end
		local pos = colData.HitPos
		local norm = colData.OurOldVelocity:GetNormalized()
		util.Decal("Blood",pos,pos + colData.HitNormal * 20)
	end
end


----------------------------
----- Helper functions -----
----------------------------


-- Removes all ragdolls belonging to the given player
-- Removes the player from the DeathRagdolls table
local function RemovePlayerRagdolls(ply)
	if not DeathRagdolls[ply] then return end
	for index, ragdoll in pairs(DeathRagdolls[ply]) do
		if IsValid(ragdoll) then
			ragdoll:Remove()
		end
	end
	table.Empty(DeathRagdolls[ply])
	DeathRagdolls[ply] = nil
end


-- Removes all ragdolls by calling RemovePlayerRagdolls for all players
function RemoveAllRagdolls()
	for ply in pairs(DeathRagdolls) do
		RemovePlayerRagdolls(ply)
	end
end

local function EnableServerRagdolls()
	for ply in pairs(DeathRagdolls) do
		ply:SetShouldServerRagdoll(true)
	end
end

-- Loops through the given ragdolls bones and multiplies the mass with the multiplier
-- If multiplier is 0, disables gravity for the bones
local function ApplyWeightMultiplier(rag, mul)
	for i=0, rag:GetPhysicsObjectCount()-1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if mul == 0 then
			phys:EnableGravity(false)
		else
			--phys.oldmass = phys:GetMass()
			phys:SetMass(phys:GetMass()*mul)
			phys:SetDamping( 25, 25 )

			timer.Simple(0.05, function()
				if IsValid(phys) then
					phys:SetDamping( 0, 0 )
				end
			end)
		end
	end
end
------------------------
-- Main functionality --
------------------------

-- This hook is called when the ragdoll is automatically created by GMod
hook.Add("CreateEntityRagdoll","RagDeath_Ragdoll",function(owner, rag)
	if type(owner) != "Player" then return end

	timer.Simple(0, function()
		net.Start("ragdeath_client")
		net.WriteEntity(rag)
		net.WriteEntity(owner)
		net.Broadcast()
	end)
	

	-- Add a new empty ragdoll list for the player if they don't already have one
	if not DeathRagdolls[owner] then 
		DeathRagdolls[owner] = {}
	end

	-- Keep removing old ragdolls until we have the maximum
	while #DeathRagdolls[owner]+1 > math.max(MaxRagdollsVar:GetInt(),1) do
		-- Get the last element in the array
		local index = #DeathRagdolls[owner]
		local oldestRagdoll = DeathRagdolls[owner][index]
		-- Destroy the ragdoll
		if IsValid(oldestRagdoll) then oldestRagdoll:Remove() end
		table.remove(DeathRagdolls[owner],index)
	end
	table.insert(DeathRagdolls[owner], 1, rag)
	


	-- Set the collision group to ignore players if the convar is set
	--local group = COLLISION_GROUP_NONE
	--if not CollidePlayersVar:GetBool() then
		--group = COLLISION_GROUP_PASSABLE_DOOR
	--end
	--rag:SetCollisionGroup(group)
	rag:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	local weightMultiplier = WeightMulVar:GetFloat()
	ApplyWeightMultiplier(rag, weightMultiplier)
	
	-- Remove owner (Otherwise owning player won't collide with the ragdoll)
    rag:SetOwner(NULL )

	rag:SetUseType( SIMPLE_USE )

	-- Enable tool interactions
	rag.CanConstrain = true
	rag.GravGunPunt = true
	rag.PhysgunDisabled = false

	rag.wepinv = {}
	owner.droped = {}

	local inventory = {
        --ActiveWeapon = IsValid(owner:GetActiveWeapon()) and owner:GetActiveWeapon():GetClass() or nil,
        Weapons = {},
        Ammo = {}
    }

    for k, v in ipairs(game.GetAmmoTypes()) do
        local amount = owner:GetAmmoCount(k)
        if amount == 0 then continue end
        inventory.Ammo[k] = amount
    end

    for k, v in ipairs(owner:GetWeapons()) do
		if not owner.droped[v] then
        	if inventory.Weapons[v] then return end
			
			if v.IsTFAWeapon and (v == owner:GetActiveWeapon()) then continue end

			local weapon = {
				Class = v:GetClass(),
				Clip1 = v:Clip1(),
				Clip2 = v:Clip2(),
				Model = v:GetModel()
			}

			if v:GetClass() == "weapon_lvsrepair" then
				if v:GetGas() >= 0 then
					weapon.Gas = v:GetGas()
				end
			end

			--[[if v:GetClass() == "wep_jack_gmod_eztoolbox" then
				if v:GetElectricity() >= 0 then
					weapon.Electricity = v:GetElectricity()
				end
			end]]



			owner.droped[v] = true
        	table.insert(inventory.Weapons, weapon)
		end
    end

	rag.Owner = owner
	rag.wepinv = inventory
	rag.EzUse = false
	rag.EzWarUse = false
	rag.ExamineTime = CurTime()

	owner.oldragdoll = rag

	local to_sub = math.Clamp(math.floor(GAMEMODE:GetJBux(owner) * 0.15), 500, 5000)
	to_sub = math.Clamp(to_sub, 0, GAMEMODE:GetJBux(owner))
	
	rag.Money = to_sub

	GAMEMODE:SetJBux(owner, GAMEMODE:GetJBux(owner) - to_sub)
	
	if owner:GetSquadID() != -1 then
		rag.Squad = {id = owner:GetSquadID(), name = SquadMenu:GetSquad(owner:GetSquadID()).name}
	end

	if (owner.EZarmor and owner.EZarmor.items) and IsValid(rag) then

		owner.RagdollArmor = owner.EZarmor
        rag.EZoriginalPlayerModel = owner.EZoriginalPlayerModel

		rag.EZarmorP = {}
		local Parachute = false
		for k, v in pairs(owner.EZarmor.items) do
			local ArmorInfo = JMod.ArmorTable[v.name]
			if not ArmorInfo.plymdl then
				local Index = rag:LookupBone(ArmorInfo.bon)
				local Pos, Ang = rag:GetBonePosition(Index)
				
				if Pos and Ang then
					-- Pos it
					local Right, Forward, Up = Ang:Right(), Ang:Forward(), Ang:Up()
					Pos = Pos + Right * ArmorInfo.pos.x + Forward * ArmorInfo.pos.y + Up * ArmorInfo.pos.z
					Ang:RotateAroundAxis(Right, ArmorInfo.ang.p)
					Ang:RotateAroundAxis(Up, ArmorInfo.ang.y)
					Ang:RotateAroundAxis(Forward, ArmorInfo.ang.r)
					-- Spawn it
					local ArmorPiece = ents.Create(ArmorInfo.ent)
					ArmorPiece:SetPos(Pos)
					ArmorPiece:SetAngles(Ang)
					ArmorPiece:SetOwner(rag)
					ArmorPiece:ManipulateBoneScale(0, ArmorInfo.siz)
					ArmorPiece:Spawn()
					ArmorPiece:Activate()
					ArmorPiece:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
					ArmorPiece:SetColor(v.col)

					rag.EZarmorP[v.name] = ArmorPiece
					if ArmorInfo.eff and ArmorInfo.eff.parachute then
						Parachute = v.name
						local BonePhys = rag:GetPhysicsObjectNum(Index)
						ArmorPiece:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, -100))
					end

					if v.chrg then
						ArmorPiece.Specs.chrg = v.chrg
						ArmorPiece.ArmorCharges = v.chrg
					end
					-- Attach it
					local Weld = constraint.Weld(ArmorPiece, rag, 0, rag:TranslateBoneToPhysBone(Index), 0, true)
					if Weld then
						Weld:Activate()
					end

					rag:CallOnRemove( "RemoveAfterRagdoll" .. "_" .. ArmorPiece:EntIndex(), function( ent )
						--print("RemoveAfterRagdoll" .. "_" .. ArmorPiece:EntIndex())

						if IsValid(ArmorPiece) then
							ArmorPiece:Remove()
						end
					end)
				end
			end
		end

		if IsValid(owner.EZparachute) and Parachute then
			owner.EZparachute:SetNW2Entity("Owner", rag.EZarmorP[Parachute])
			ParachuteEnt = rag.EZarmorP[Parachute]
			ParachuteEnt:SetNW2Bool("EZparachuting", true)
			ParachuteEnt.EZparachute = owner.EZparachute
			ParachuteEnt.EZparachute.AttachBone = 0
			ParachuteEnt.EZparachute.Drag = ParachuteEnt.EZparachute.Drag * 5
		end
		owner:SetNW2Bool("EZparachuting", true)
		owner.EZparachute = nil
	end
	rag.IsEZcorpse = true
	rag.EZragdoll = rag
	--[[timer.Simple(0, function()
		if IsValid(self) and IsValid(self.EZragdoll) then
			self:SetParent(self.EZragdoll)
			self:SetPos(Vector(0, 0, 0))
		else
			SafeRemoveEntity(self)
		end
	end)]]

	-- Add callback for blood decals
	rag:AddCallback( "PhysicsCollide", OnRagdollCollide)
	

end)


-- Called when a player dies. Removes the default ragdoll
hook.Add("PostPlayerDeath","RagDeath_PlayerDeath", function(ply)
	if not RagDeathEnabledVar:GetBool() then return end  -- Stop if the addon isn't enabled
	local defaultRagdoll = ply:GetRagdollEntity()
	if ( defaultRagdoll && defaultRagdoll:IsValid() ) then defaultRagdoll:Remove() end
end)


-- Simply enables the serverside ragdolls for a player.
hook.Add("PlayerSpawn","RagDeath_PlayerSpawn", function(ply)
	ply:SetShouldServerRagdoll(RagDeathEnabledVar:GetBool())
end)


-- Called when a player leaves. Removes all of their ragdolls
hook.Add( "PlayerDisconnected", "RagDeath_PlayerDisconnected", function( ply )
	--RemovePlayerRagdolls(ply)
end )



----------------------
-- Console commands --
----------------------

-- Called when the addon is enabled or disabled
cvars.AddChangeCallback("rd_enable", function()
	local newEnabled = GetConVar("rd_enable"):GetBool()
	if newEnabledt then
		EnableServerRagdolls()
	end
	-- Notify in chat
	PrintMessage(HUD_PRINTTALK,"RagDeath " .. ( ( newEnabled ) and "enabled" or "disabled" ) )
	-- Also send the new addon state to the clients
	-- (Replicated convars dont trigger the convar callback on clients,
	-- so this is a workaround)
	net.Start("ragdeath_enabled_to_client")
	net.WriteBool(newEnabled)
	net.Send(player.GetAll())
	RemoveAllRagdolls()

end)

net.Receive("ragdeath_server_convar", function(len,ply)
	local convar_name = net.ReadString()
	local convar_value = net.ReadString()
	if not ply:IsAdmin() then 
		ply:ChatPrint("You must be an admin to do change the value of " .. convar_name)
		return 
	end
	convar = GetConVar(convar_name)
	convar:SetString(convar_value)
end)

