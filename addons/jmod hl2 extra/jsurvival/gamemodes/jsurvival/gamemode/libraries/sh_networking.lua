
JSMod = JSMod or {}

local function CheckBadType(name, object)
	if (isfunction(object)) then
		ErrorNoHalt("Net var '" .. name .. "' contains a bad object type!")

		return true
	elseif (istable(object)) then
		for k, v in pairs(object) do
			if (CheckBadType(name, k) or CheckBadType(name, v)) then
				return true
			end
		end
	end
end

if (CLIENT) then
	local entityMeta = FindMetaTable("Entity")
	local playerMeta = FindMetaTable("Player")

	JSMod.net = JSMod.net or {}
	JSMod.net.globals = JSMod.net.globals or {}

	net.Receive("JSModGlobalVarSet", function()
		local key, var = net.ReadString(), net.ReadType()

		JSMod.net.globals[key] = var

		hook.Run("OnGlobalVarSet", key, var)
	end)

	net.Receive("JSModNetVarSet", function()
		local index = net.ReadUInt(16)

		local key = net.ReadString()
		local var = net.ReadType()

		JSMod.net[index] = JSMod.net[index] or {}
		JSMod.net[index][key] = var

		hook.Run("OnNetVarSet", index, key, var)
	end)

	net.Receive("JSModNetVarDelete", function()
		JSMod.net[net.ReadUInt(16)] = nil
	end)

	net.Receive("JSModLocalVarSet", function()
		local key = net.ReadString()
		local var = net.ReadType()

		JSMod.net[LocalPlayer():EntIndex()] = JSMod.net[LocalPlayer():EntIndex()] or {}
		JSMod.net[LocalPlayer():EntIndex()][key] = var

		hook.Run("OnLocalVarSet", key, var)

		if key == "Crazy" then
			--LocalPlayer():ChatPrint(var)
			LocalCrazy = LocalCrazy + var
		end
	end)

	function GetNetVar(key, default) -- luacheck: globals GetNetVar
		local value = JSMod.net.globals[key]

		return value != nil and value or default
	end

	function entityMeta:GetNetVar(key, default)
		local index = self:EntIndex()

		if (JSMod.net[index] and JSMod.net[index][key] != nil) then
			return JSMod.net[index][key]
		end

		return default
	end

	function playerMeta:SetLocalVar(key, value)
		if (CheckBadType(key, value)) then return end

		JSMod.net[self] = JSMod.net[self] or {}
		JSMod.net[self][key] = value
	end

	playerMeta.GetLocalVar = entityMeta.GetNetVar

	hook.Add("InitPostEntity", "OnRequestFullUpdate_JSMod", function()
		LocalPlayer():SyncVars()
	end)

	function playerMeta:SyncVars()
		net.Start("JSMod_request_fullupdate")
		net.SendToServer()
	end
else
	util.AddNetworkString("JSMod_request_fullupdate")

	net.Receive("JSMod_request_fullupdate",function(len,ply)
		ply.cooldown_sendnet = ply.cooldown_sendnet or 0
		if ply.cooldown_sendnet < CurTime() then
			ply.cooldown_sendnet = CurTime() + 1

			ply:SyncVars()
		end
	end)

	gameevent.Listen( "OnRequestFullUpdate" )
	hook.Add("OnRequestFullUpdate", "OnRequestFullUpdate_JSMod", function(data)
		local id = data.userid
		local ply = Player(id)

		ply:SyncVars()
	end)


	local entityMeta = FindMetaTable("Entity")
	local playerMeta = FindMetaTable("Player")

	JSMod.net = JSMod.net or {}
	JSMod.net.list = JSMod.net.list or {}
	JSMod.net.locals = JSMod.net.locals or {}
	JSMod.net.globals = JSMod.net.globals or {}

	util.AddNetworkString("JSModGlobalVarSet")
	util.AddNetworkString("JSModLocalVarSet")
	util.AddNetworkString("JSModNetVarSet")
	util.AddNetworkString("JSModNetVarDelete")

	function GetNetVar(key, default)
		local value = JSMod.net.globals[key]

		return value != nil and value or default
	end

	function SetNetVar(key, value, receiver)
		if (CheckBadType(key, value)) then return end
		--if (GetNetVar(key) == value) then return end

		JSMod.net.globals[key] = value

		net.Start("JSModGlobalVarSet")
		net.WriteString(key)
		net.WriteType(value)

		if (receiver == nil) then
			net.Broadcast()
		else
			net.Send(receiver)
		end
	end

	function playerMeta:SyncVars()
		for k, v in pairs(JSMod.net.globals) do
			net.Start("JSModGlobalVarSet")
				net.WriteString(k)
				net.WriteType(v)
			net.Send(self)
		end

		for k, v in pairs(JSMod.net.locals[self] or {}) do
			net.Start("JSModLocalVarSet")
				net.WriteString(k)
				net.WriteType(v)
			net.Send(self)
		end

		for entity, data in pairs(JSMod.net.list) do
			if (IsValid(entity)) then
				local index = entity:EntIndex()

				for k, v in pairs(data) do
					net.Start("JSModNetVarSet")
						net.WriteUInt(index, 16)
						net.WriteString(k)
						net.WriteType(v)
					net.Send(self)
				end
			end
		end
	end

	function playerMeta:GetLocalVar(key, default)
		if (JSMod.net.locals[self] and JSMod.net.locals[self][key] != nil) then
			return JSMod.net.locals[self][key]
		end

		return default
	end

	function playerMeta:SetLocalVar(key, value)
		if (CheckBadType(key, value)) then return end

		JSMod.net.locals[self] = JSMod.net.locals[self] or {}
		JSMod.net.locals[self][key] = value

		net.Start("JSModLocalVarSet")
			net.WriteString(key)
			net.WriteType(value)
		net.Send(self)
	end

	function entityMeta:GetNetVar(key, default)
		if (JSMod.net.list[self] and JSMod.net.list[self][key] != nil) then
			return JSMod.net.list[self][key]
		end

		return default
	end

	function entityMeta:SetNetVar(key, value, receiver)
		if (CheckBadType(key, value)) then return end

		JSMod.net.list[self] = JSMod.net.list[self] or {}

		if (JSMod.net.list[self][key] != value) then
			JSMod.net.list[self][key] = value
		end

		self:SendNetVar(key, receiver)
	end

	function entityMeta:SendNetVar(key, receiver)
		net.Start("JSModNetVarSet")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteString(key)
		net.WriteType(JSMod.net.list[self] and JSMod.net.list[self][key])

		if (receiver == nil) then
			net.Broadcast()
		else
			net.Send(receiver)
		end
	end

	function entityMeta:ClearNetVars(receiver)
		JSMod.net.list[self] = nil
		JSMod.net.locals[self] = nil

		net.Start("JSModNetVarDelete")
		net.WriteUInt(self:EntIndex(), 16)

		if (receiver == nil) then
			net.Broadcast()
		else
			net.Send(receiver)
		end
	end

	hook.Add("EntityRemoved","JSMod_clear_net",function(ent,fullUpdate)
		--ent:ClearNetVars()
	end)

	hook.Add("PlayerDisconnected","JSMod_clear_net",function(ply)
		ply:ClearNetVars()
	end)
end