JSMod = JSMod or {}

JSMod.ResourceToJBux = {
	[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 0.5,
	[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = 10,
	[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = 12,
	[JMod.EZ_RESOURCE_TYPES.OIL] = 1,
	[JMod.EZ_RESOURCE_TYPES.RUBBER] = .5,
	[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .25,
	[JMod.EZ_RESOURCE_TYPES.WOOD] = .1,
	[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .3,
	[JMod.EZ_RESOURCE_TYPES.FUEL] = 2,
	[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = 1,
	[JMod.EZ_RESOURCE_TYPES.STEEL] = .4,
	--[JMod.EZ_RESOURCE_TYPES.LEAD] = .4,
	--[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .5,
	[JMod.EZ_RESOURCE_TYPES.COPPER] = .6,
	[JMod.EZ_RESOURCE_TYPES.URANIUM] = 5,
	--[JMod.EZ_RESOURCE_TYPES.TITANIUM] = 7.5,
	[JMod.EZ_RESOURCE_TYPES.GOLD] = 25,
	[JMod.EZ_RESOURCE_TYPES.SILVER] = 15,
	[JMod.EZ_RESOURCE_TYPES.DIAMOND] = 100,
	--[JMod.EZ_RESOURCE_TYPES.PLATINUM] = 150,
	[JMod.EZ_RESOURCE_TYPES.ANTIMATTER] = 1000
}
JSMod.ItemToJBux = {
	["ent_jack_gmod_ezarmor"] = 50,
	["ent_jack_gmod_ezgrenade"] = 100,
	["ent_jack_gmod_eztoolbox"] = 30,
	["ent_weapondrop"] = 150,
	["ent_jack_gmod_ezmedkit"] = 50,
	["ent_jack_gmod_eztnt"] = 300,
}
			
JSMod.CurrentResourcePrices = table.FullCopy(JSMod.ResourceToJBux)

for key, price in pairs(JSMod.ResourceToJBux) do
    JSMod.CurrentResourcePrices[JMod.EZ_RESOURCE_ENTITIES[key]] = price
end

JSMod.JBuxList = JSMod.JBuxList or {}

if (SERVER) then
	util.AddNetworkString("JS_GiveMoney")
	util.AddNetworkString("JS_ShowSquad")

	hook.Add("ShowSpare1", "GiveMoneyButton", function(ply)
		net.Start("JS_GiveMoney")
		net.WriteFloat(SquadMenu:GetSquad(ply:GetSquadID()).money)
		net.Send(ply)
	end)

	hook.Add("ShowSpare2", "ShowSquad", function(ply)
		net.Start("JS_ShowSquad")
		net.Send(ply)
	end)

	hook.Add("ShowTeam", "PLUV", function(ply)
		--if ply.Pliv == nil or ply.Pliv <= CurTime() then
			ply:Say("!motd")
			--ply.Pliv = CurTime() + 600
		--end
	end)
else

	local Request

	net.Receive("JS_GiveMoney", function()
		local money = net.ReadFloat()
		if IsValid(Request) then
			return
		end

		local trace = LocalPlayer():GetEyeTrace()

		local ply = trace.Entity

		if ply:IsPlayer() then
			Request = Derma_StringRequest(
				"Дать денег " .. ply:Nick(),
				"Введите количество денег. Ваше текущее количество JBux: " .. money,
				"",
				function(text) RunConsoleCommand("js_jbux_donate", ply:Nick(), text) end
			)
		end
	end)

	net.Receive("JS_ShowSquad", function()
		RunConsoleCommand("say", "!squad")
	end)
end

function GM:CalcJBuxWorth(item, amount)
	if not item then return 0 end
	amount = amount or 1

	local typToCheck = type(item)
	local JBuxToGain = 0
	local Exportables = {}

	if typToCheck == "Entity" then
		if IsValid(item) then
			JBuxToGain = JBuxToGain + (JSMod.ItemToJBux[item:GetClass()] or JSMod.ItemToJBux[item.Base] or (weapons.Get(item:GetWeaponClass()).IsTFAWeapon and 25)) * amount
		end
	elseif typToCheck == "string" then
		/*
		if JSMod.CurrentResourcePrices[item] then
			JBuxToGain = JSMod.CurrentResourcePrices[item] * amount
		elseif JSMod.ItemToJBux[item] then
			JBuxToGain = JSMod.ItemToJBux[item] * amount
		end
		*/
		JBuxToGain = JBuxToGain + ECONOMIC:GetPrice(item, amount)
	elseif typToCheck == "table" then
		for typ, amt in pairs(item) do
			JBuxToGain = JBuxToGain + GAMEMODE:CalcJBuxWorth(typ, amt)
		end
	end
	return JBuxToGain, Exportables
end

local function FindItemJBuxPrice(item)
	for pkg, info in pairs(JMod.Config.RadioSpecs.AvailablePackages) do
		if info.JBuxPrice and (isstring(info.results) and info.results == item) or (info.results[1] == item) then
			price = info.JBuxPrice

			return price
		end
	end

	return 0
end

function GM:AutoCalcPrice(contents, searchRadioManifest)
	local typ = type(contents)
	local price = 0

	if typ == "string" then
		local RadioPrice = (searchRadioManifest and FindItemJBuxPrice(contents)) or 0
		if ECONOMIC:GetIndex(contents) then
			price = ECONOMIC:GetPrice(contents) * 100
		elseif RadioPrice <= 0 and JSMod.ItemToJBux[contents] then
			price = JSMod.ItemToJBux[contents]
		else
			price = RadioPrice
		end
	end

	if typ == "table" then
		for k, v in pairs(contents) do
			typ = type(v)

			if typ == "string" then
				local RadioPrice = (searchRadioManifest and FindItemJBuxPrice(v)) or 0
				if ECONOMIC:GetIndex(v) then
					price = ECONOMIC:GetPrice(v) * 100
				elseif RadioPrice <= 0 and JSMod.ItemToJBux[v] then
					price = price + JSMod.ItemToJBux[v]
				else
					price = price + RadioPrice
				end
			elseif typ == "table" then
				-- special case, this is a randomized table
				if v[1] == "RAND" then
					local Amt = v[#v]
					local Items = {}

					for i = 2, #v - 1 do
						if JSMod.ItemToJBux[v[i]] then
							table.insert(Items, v[i])
							price = price + JSMod.ItemToJBux[v[i]]
						/*elseif JSMod.CurrentResourcePrices[v[i]] or JSMod.ResourceToJBux[v[i]] then
							price = price + (JSMod.CurrentResourcePrices[v[i]] or JSMod.ResourceToJBux[v[i]]) * (100 * JSMod.Config.ResourceEconomy.MaxResourceMult)
						end
						*/
						elseif ECONOMIC:GetIndex(v[i]) then
							price = price + ECONOMIC:GetPrice(v[i]) * 100
						end
					end

					price = price / Amt
				elseif ECONOMIC:GetIndex(v[1]) then
					-- the only other supported table contains a count as [2] and potentially a resourceAmt as [3]
					/*
					for i = 1, v[2] or 1 do
						price = price + (JSMod.CurrentResourcePrices[v[1]]) or JSMod.ResourceToJBux[v[1]] * (v[3] or (100 * JMod.Config.ResourceEconomy.MaxResourceMult))
					end

					for i = 1, v[2] or 1 do
						price = price + JSMod.CurrentResourcePrices[v[1]] * (v[3] or 100 * JSMod.Config.ResourceEconomy.MaxResourceMult)
					end
					*/
					//PrintTable(v)
					
					/*
					for i = 1, v[2] or 1 do
						price = price + ECONOMIC:GetPrice(v[1]) * (v[3] or (100 * JMod.Config.ResourceEconomy.MaxResourceMult))
					end
					*/
					/*
					if v[3] then
						for i = 1, v[2] do
							price = price + ECONOMIC:GetPrice(v[1]) * (v[3])
						end
					else
						price = price + ECONOMIC:GetPrice(v[1]) * (v[2] or (100 * JMod.Config.ResourceEconomy.MaxResourceMult))
					end
					*/
					for i = 1, v[2] or 1 do
						price = price + ECONOMIC:GetPrice(v[1]) * (v[3] or 100)
					end
				end
			end
		end
	end

	return price
end
