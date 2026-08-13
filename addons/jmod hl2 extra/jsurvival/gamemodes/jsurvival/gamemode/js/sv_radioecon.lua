local color_orange = Color(255, 136, 0)
local color_red = Color(255, 0, 0)
local clr_blue = Color(87, 87, 255)

concommand.Add("js_jbux_check", function(ply, cmd, args)
	BetterChatPrint(ply, "У тебя есть " .. tostring(GAMEMODE:GetJBux(ply)) .. " JBux!", color_orange)
end, "Показывает сколько у тебя деняг.")

concommand.Add("addmoney", function(ply, cmd, args)
	if ply:IsSuperAdmin() then
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + args[1])
	end
end)

concommand.Add("js_jbux_donate", function(ply, cmd, args)
	if not ply:Alive() then return end

	local squad = SquadMenu:GetSquad(ply:GetSquadID())

	if squad.Loan.money ~= nil then
		BetterChatPrint(ply, "Вы не можете переводить деньги, пока у вас кредит!", color_red)
		return
	end

	local target = tostring(args[1])
	local amt = tonumber(args[2])

	if not amt then return end

	amt = math.floor(amt)

	amt = math.Clamp(amt, 0, GAMEMODE:GetJBux(ply))

	if not amt or (amt == 0) then return end

	local recipient
	for k, v in player.Iterator() do
		if string.lower(v:Nick()) == string.lower(target) then
			recipient = v
			break
		end
	end

	if recipient and (recipient:Alive()) then
		GAMEMODE:SetJBux(recipient, GAMEMODE:GetJBux(recipient) + amt, true)
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) - amt, true)

		BetterChatPrint(recipient, "Ты получил " .. tostring(amt) .. " JBux!", color_orange)
		BetterChatPrint(ply, "Ты пожертвовал " .. tostring(amt) .. " JBux!", color_orange)
	elseif string.lower(target) == "team" then
		recipient = ply:Team()
		GAMEMODE:SetJBux(recipient, GAMEMODE:GetJBux(recipient) + amt, true)
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) - amt, true)

		BetterChatPrint(ply, "Ты пожертвовал " .. tostring(amt) .. " JBux!", color_orange)
	end
end, function(cmd, args)
	local NameTable = {}

	for k, v in player.Iterator() do
		NameTable[k] = cmd .. " \"" .. v:Nick() .. "\""
	end

	return NameTable
end, "Donates JBux to someone or your team")

--[[hook.Add("PlayerSpawn", "JSMOD_ECONPLAYERSPAWN", function(ply, transition)
	if transition then return end
	timer.Simple(1, function()
		if IsValid(ply) then ply:ConCommand("js_jbux_check") end
	end)
end)]]

--local StandardRate = 200 -- To cover fuel ;)
hook.Add("JMod_CanRadioRequest", "JSMOD_MONEY_CHECK", function(ply, transceiver, pkg)
	local station = JMod.EZ_RADIO_STATIONS[transceiver:GetOutpostID()]

	local squad = SquadMenu:GetSquad(ply:GetSquadID())

	local Debt = squad.Loan.Debt or 0

	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages[pkg]
	if not PackageSpecs then return end
	local ReqAmount = (PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false))

	if GetGlobalVar("NuclearWar") and PackageSpecs.category ~= ".Squad" then return false, "Поставки временно прекращены из-за применения ядерного оружия." end 

	ReqAmount = ReqAmount * (1 + (Debt / 100))

	if (ReqAmount <= 0) or PackageSpecs.JBuxFree then return end
	local PlyAmt = GAMEMODE:GetJBux(ply)
	if PlyAmt < ReqAmount then 
		return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
	else
		GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
	end
end)

hook.Add("JMod_RadioDelivery", "JSMOD_SPEED_MODIFIER", function(ply, transceiver, pkg, DeliveryTime, Pos) 
	local station = JMod.EZ_RADIO_STATIONS[transceiver:GetOutpostID()]

	if pkg == "fulton-export" then

		return DeliveryTime * 2, Pos
	end
end)


local NextStockUpdate = 0
hook.Add("Think", "JSMOD_STOCKSIM", function()
	local Time = CurTime()

	if (Time > NextStockUpdate) then 
		NextStockUpdate = Time + 60

		JSMod.CurrentResourcePrices = JSMod.CurrentResourcePrices or table.FullCopy(JSMod.ResourceToJBux)
	end
end)

Airstrikes = {
	["hebombs"] = { func = function(station, dropPos, DropVelocity) 
			local delay = 2
			local AreaRadius = 1200
			for i = 1, 6 do
				timer.Simple(i * delay, function()
					local Bomb = ents.Create("ent_jack_gmod_ezhebomb")
					Bomb:SetPos(dropPos + Vector(math.random(-AreaRadius, AreaRadius), math.random(-AreaRadius, AreaRadius), 0))
					Bomb:SetAngles(station.outpostDirection:Angle())
					Bomb:Spawn()
					Bomb:Activate()
					timer.Simple(0, function()
						if IsValid(Bomb) then
							--Bomb:GetPhysicsObject():SetVelocity(DropVelocity)
							Bomb:GetPhysicsObject():SetMass(500)
							Bomb:SetState(1)
						end
					end)
					Bomb.DropOwner = game.GetWorld()
				end)
			end
		end
	},
	["smallbombs"] = { func = function(station, dropPos, DropVelocity)
			--local PlanePos = dropPos - station.outpostDirection * 800 - Vector(0, 0, 10)
			for i = 1, 2 do
				timer.Simple(i * .5, function()
					local Bomb = ents.Create("ent_jack_gmod_ezbomb")
					local AreaRadius = 1000
					Bomb:SetPos(dropPos + Vector(math.random(-AreaRadius, AreaRadius), math.random(-AreaRadius, AreaRadius), 0))
					Bomb:SetAngles(station.outpostDirection:Angle())
					Bomb:Spawn()
					Bomb:Activate()
					timer.Simple(0, function()
						if IsValid(Bomb) then
							--Bomb:GetPhysicsObject():SetVelocity(DropVelocity)
							Bomb:GetPhysicsObject():SetMass(500)
							Bomb:SetState(1)
						end
					end)
					Bomb.DropOwner = game.GetWorld()
					--PlanePos = PlanePos + station.outpostDirection * 1000
				end)
			end
		end
	},
	["rockets"] = { func = function(station, dropPos, DropVelocity) 
		for i = 1, 25 do
			timer.Simple(math.Rand(.5, 10), function()
				local Rocket = ents.Create("ent_jack_gmod_ezherocket")
				local AreaRadius = 500
				Rocket:SetPos(dropPos + Vector(math.random(-AreaRadius, AreaRadius), math.random(-AreaRadius, AreaRadius), 0))
				Rocket:SetAngles(Angle(0, 0, -90))
				Rocket:Spawn()
				Rocket:Activate()
				Rocket:SetState(1)
				timer.Simple(.1, function()
					if IsValid(Rocket) then
						Rocket:Launch()
					end
				end)
			end)
		end
	end},
}

local function StartAirstrike(pkg, transceiver, id, ply)
	local Station = JMod.EZ_RADIO_STATIONS[id]
	Station.lastCaller = transceiver
	local Time = CurTime()
	local DeliveryTime, Pos = math.ceil(JMod.Config.RadioSpecs.DeliveryTimeMult * math.Rand(3, 6)), ply:GetPos()
	local newTime, newPos = hook.Run("JMod_RadioDelivery", ply, transceiver, pkg, DeliveryTime, Pos)
	DeliveryTime = newTime or DeliveryTime
	Pos = newPos or Pos
	JMod.Hint(ply, "aid wait")
	Station.state = JMod.EZ_STATION_STATE_DELIVERING
	Station.nextDeliveryTime = Time + DeliveryTime
	Station.deliveryLocation = Pos
	Station.deliveryType = pkg
	Station.notified = false
	Station.nextNotifyTime = Time + (DeliveryTime - 5)
	JMod.NotifyAllRadios(id) -- do a notify to update all radio states
end

--[[hook.Add("JMod_CanRadioRequest", "JSMOD_AIRSTRIKE_CHECK", function(ply, transceiver, pkg)
	--[[local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "airstrike") and (SplitString[2] and Airstrikes[SplitString[2]]--) then
		
--[[
	--ГОВНО КОДИНГ
	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages[pkg]
	local ReqAmount = PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false)

	ReqAmount = ReqAmount + StandardRate
	if (ReqAmount <= 0) or PackageSpecs.JBuxFree then return end
	local PlyAmt = GAMEMODE:GetJBux(ply)
	if PlyAmt <= ReqAmount then 
		return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
	else
		GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
	end
	-----

		StartAirstrike(pkg, transceiver, transceiver:GetOutpostID(), ply)
		return false, "Вызываем огонь Артиллерии!"
	end
end)]]

--[[hook.Add("JMod_RadioDelivery", "JSMOD_AIRSTRIKE_START", function(ply, transceiver, pkg, DeliveryTime, Pos) 
	--[[local station = JMod.EZ_RADIO_STATIONS[transceiver:GetOutpostID()]
	local ExplodedString = string.Split(pkg, " ")
	if ExplodedString[1] == "airstrike" and Airstrikes[ExplodedString[2]] --[[then

		station.airstrikeType = ExplodedString[2]

		local StrikePos = transceiver:GetPos()
		for k, nade in ipairs(ents.FindByClass("ent_jack_gmod_ezsignalnade")) do
			--print(nade, nade:GetState())
			if (nade:GetState() == JMod.EZ_STATE_ARMED) then
				if JMod.GetEZowner(nade):Team() == ply:Team() then
					StrikePos = nade:GetPos()
				end
			end
		end
		return DeliveryTime * 1, StrikePos
	end
end)]]

hook.Add("JMod_OnRadioDeliver", "JSMOD_AIRSTRIKE", function(stationID, dropPos) 
	local station = JMod.EZ_RADIO_STATIONS[stationID]
	if station.airstrikeType then
		--
		local DropVelocity = station.outpostDirection * 1000
		local Eff = EffectData()
		Eff:SetOrigin(dropPos)
		Eff:SetStart(-DropVelocity * .4)
		util.Effect("eff_jack_gmod_jetflyby", Eff, true, true)
		--
		local StrikeType = station.airstrikeType
		timer.Simple(.1, function()
			if not StrikeType then return end
			
			Airstrikes[StrikeType].func(station, dropPos, DropVelocity)
		end)

		station.airstrikeType = nil
		JMod.NotifyAllRadios(stationID, "good drop")
		return true
	end
end)

------------МОБИЛИЗАЦИЯ--------------

hook.Add("JMod_CanRadioRequest", "JSMOD_MOBILIZATION", function(ply, transceiver, pkg)
	if pkg == "mobilization" then
		local SquadId = ply:GetSquadID()
		local Squad = SquadMenu:GetSquad(SquadId)

		local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["mobilization"]
		local ReqAmount = PackageSpecs.JBuxPrice

		if not table.IsEmpty(Squad.SquadsInWar) then
			if Squad.Mobilization == nil or Squad.MobilizationColldown == nil or Squad.MobilizationColldown < CurTime() then
				if Squad:IsLeader(ply) then

					local Debt = squad.Loan.Debt or 0

					local ReqAmount = PackageSpecs.JBuxPrice

					ReqAmount = ReqAmount * (1 + (Debt / 100))

					--[[if ReqAmount <= 0 then return end
					local PlyAmt = GAMEMODE:GetJBux(ply)
					if PlyAmt < ReqAmount then 
						return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
					else
						GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
					end]]
				
					local MobArmorValue = squad.Style
					local plys = player.GetAll()
				
					local SquadColor = Color(squad.r, squad.g, squad.b)
				
					if squad ~= nil then
						squad.Mobilization = {}
					
						for k,v in pairs(squad.membersById) do
							local member = player.GetBySteamID(k)
						
							squad.Mobilization[member] = 5
						end
					
						squad.MobilizationColldown = CurTime() + 300
					
						for i = 1, #plys do
							local ply2 = plys[i]
						
							ply2:LanRPChatPrint(clr_blue, "[Глобальное сообщение] ", color_white, "Фракция ", SquadColor, squad.name, color_white, " Мобилизировала войска!")
							ply2:PlayLocalSound("hoi4/faction_join_sfx_01.wav")
						end
					end

					--GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
					return false, "Мобилизирование членов фракции!"
				else
					GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
					return false, "Вы не лидер фракции!"
				end
			else
				GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
				return false, "Прошло слишком мало времени с последней мобилизации. Осталось " .. math.Round((Squad.MobilizationColldown - CurTime()) / 60, 0) .. " мин."
			end
		else
			return false, "Нельзя мобилизировать в мирное время."
		end
	end
end)

-----ПОДДЕРЖКА ПЕХОТЫ------

hook.Add("JMod_CanRadioRequest", "JSMOD_INFANTRY_SUPPORT", function(ply, transceiver, pkg)
	local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "infantry") and (SplitString[2] == "support") then

		local SquadId = ply:GetSquadID()
		local squad = SquadMenu:GetSquad(SquadId)

		local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["infantry support"]
		
		--local Debt = squad.Loan.Debt or 0

		local ReqAmount = PackageSpecs.JBuxPrice

		--ReqAmount = ReqAmount * (1 + (Debt / 100))

		local haveradio = false  

		if ply.EZarmor then
			if ply.EZarmor.effects.radio and ply:HasWeapon("radiophone") then
				haveradio = true
			end
		end

		if not haveradio then 
			GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
			return false, "Тебе нужно иметь портативное радио." 
		end

		if ply:GetNWInt("RadioManSpawns") >= 1 then
			return false, "Подкрепление все еще активно." 
		end

		if not table.IsEmpty(squad.SquadsInWar) then
			
			ply:SetNWInt( "RadioManSpawns", 15 ) 

			squad.SpawnsBase[ply] = ply:Nick()

			return false, "Командование приняло ваш запрос."
		else
			GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
			return false, "Нельзя вызвать поддержку в мирное время."
		end
		
	end
end)


hook.Add( "PlayerDeath", "RemoveRadioSpawn", function( ply, inflictor, attacker )
	if ply:GetSquadID() ~= -1 then
		local squad = SquadMenu:GetSquad(ply:GetSquadID())
		squad.SpawnsBase[ply] = nil
	end
end)

hook.Add( "PlayerSpawn", "ResetRadioSpawn", function( ply, inflictor, attacker )
	ply:SetNWInt( "RadioManSpawns", 0 ) 
end)

-------------------------

-----ПОПОЛНЕНИЕ МОРАЛИ------

util.AddNetworkString( "lanrp.sendHumanResources" )

hook.Add("JMod_CanRadioRequest", "JSMOD_HUMAN_RESERVES", function(ply, transceiver, pkg)
	local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "human") and (SplitString[2] == "reserves") then

		local SquadId = ply:GetSquadID()
		local Squad = SquadMenu:GetSquad(SquadId)

		local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["human reserves"]
		--[[local ReqAmount = PackageSpecs.JBuxPrice

		local Debt = math.Max(squad.Loan.Debt or 100, 1)

		if ReqAmount <= 0 then return end
		local PlyAmt = GAMEMODE:GetJBux(ply)
		if PlyAmt < ReqAmount then 
			return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
		else
			GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
		end]]

		if not table.IsEmpty(Squad.SquadsInWar) then
			if Squad.ReservesCooldown == nil or Squad.ReservesCooldown <= CurTime() then
				net.Start("lanrp.sendHumanResources")
				net.Send(ply)

				return false, "Пополнение людских ресурсов"
			else
				GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
				return false, "Прошло слишком мало времени с последнего пополнения." --[[ Осталось " .. (math.Round(((Squad.ReservesCooldown - CurTime()) / 60), 0) .. " минут."]]
			end
		else
			GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
			return false, "Нельзя пополнять людские ресурсы в мирное время."
		end
		
	end
end)

net.Receive("lanrp.sendHumanResources", function(_, ply)
	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["human reserves"]
	local ReqAmount = PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false)

	local apply = net.ReadBool()

	local plys = player.GetAll()

	local SquadId = ply:GetSquadID()
    local Squad = SquadMenu:GetSquad(SquadId)

	if not apply then
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
		
		return
	end


	local SquadColor = Color(Squad.r, Squad.g, Squad.b)

	timer.Simple(5, function()
		if Squad then
			
			Squad:AddHealth(25)
			Squad.ReservesCooldown = CurTime() + 60

			for i = 1, #plys do
				local ply2 = plys[i]
			
				ply2:LanRPChatPrint(clr_blue, "[Глобальное сообщение] ", color_white, "Фракция ", SquadColor, Squad.name, color_white, " вызвала подмогу!")
				ply2:PlayLocalSound("hoi4/faction_join_sfx_01.wav")

			end
		end
	end)
end)

-------------------------


-----РАЗВЕД ДАННЫЕ------

util.AddNetworkString( "lanrp.sendIntelligenceData" )

hook.Add("JMod_CanRadioRequest", "JSMOD_INTEL_DATA", function(ply, transceiver, pkg)
	local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "intelligence") and (SplitString[2] == "data") then

		local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["intelligence data"]
		local ReqAmount = PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false)

		local SquadId = ply:GetSquadID()
		local Squad = SquadMenu:GetSquad(SquadId)

		if not table.IsEmpty(Squad.SquadsInWar) then
			if Squad.IntelDataCooldown == nil or Squad.IntelDataCooldown <= CurTime() then
				net.Start("lanrp.sendIntelligenceData")
				net.WriteTable(Squad.SquadsInWar)
				net.Send(ply)

				return false, "Запрос на разведданные"
			else
				GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
				return false, "Прошло слишком мало с последнего запроса"
			end
		else
			GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
			return false, "Нет доступных целей"
		end
			
	end
end)

net.Receive("lanrp.sendIntelligenceData", function(_, ply)
	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["intelligence data"]
	local ReqAmount = PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false)

	local SquadId = ply:GetSquadID()
    local Squad = SquadMenu:GetSquad(SquadId)

	local WarSquadId = net.ReadFloat()
	local WarSquad = SquadMenu:GetSquad(WarSquadId)

	local SquadColor = Color(Squad.r, Squad.g, Squad.b)
	local WarSquadColor = Color(WarSquad.r, WarSquad.g, WarSquad.b)

	local health = WarSquad:GetHealth()
	WarSquadHpColor = (health * 200) / 100

	ply:LanRPChatPrint(color_white, "Информация будет доставлена через 15 секунд!")

	timer.Simple(15, function()
		if Squad != nil then
			for k,v in pairs(Squad.membersById) do
				local ply = player.GetBySteamID(k)
	
				ply:LanRPChatPrint(WarSquadColor, WarSquad.name, color_white, " имеет ", Color(WarSquadHpColor, 0, 0), tostring(health), color_white, "!" ) 
				ply:PlayLocalSound("hoi4/News_Event.wav")
			end
		end
	end)
end)

-------------------------

---GLOBAL MESSAGE----

util.AddNetworkString( "lanrp.sendGlobalMessage" )

hook.Add("JMod_CanRadioRequest", "JSMOD_GLOBAL_MESSAGE", function(ply, transceiver, pkg)
	local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "global") and (SplitString[2] == "message") then

		net.Start("lanrp.sendGlobalMessage")
		net.Send(ply)

		ply:SelectWeapon("wep_jack_gmod_hands")

		return false, "Сейчас вас услышит весь мир"
			
	end
end)

net.Receive("lanrp.sendGlobalMessage", function(_, ply)
	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages["global message"]
	local ReqAmount = PackageSpecs.JBuxPrice or GAMEMODE:AutoCalcPrice(PackageSpecs.results, false)

	--[[if (ReqAmount <= 0) or PackageSpecs.JBuxFree then return end
	
	if PlyAmt <= ReqAmount then
		return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
	else
		GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
	end]]

	local message = net.ReadString()
	local apply = net.ReadBool()

	local plys = player.GetAll()

	local SquadId = ply:GetSquadID()
    local Squad = SquadMenu:GetSquad(SquadId)

	if not apply then
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + ReqAmount)
		
		return
	end

	local SquadColor = Color(Squad.r, Squad.g, Squad.b)

	timer.Simple(5, function()
		for i = 1, #plys do
			local ply2 = plys[i]
	
			ply2:LanRPChatPrint(clr_blue, "[Глобальное сообщение] ", SquadColor, ply:Nick(), color_white, ": ", message)
			ply2:PlayLocalSound("hoi4/News_Event.wav")
			
		end
	end)
end)

---КРЕДИТ----

util.AddNetworkString( "lanrp.MakeLoan" )
util.AddNetworkString( "lanrp.UpdateLoan" )

hook.Add("JMod_CanRadioRequest", "JSMOD_MAKE_LOAN", function(ply, transceiver, pkg)
	local SplitString = string.Split(pkg, " ")
	if (SplitString[1] == "make") and (SplitString[2] == "loan") then

		if ply:GetSquadID() ~= -1 then
			net.Start("lanrp.MakeLoan")
			net.WriteTable(SquadMenu:GetSquad(ply:GetSquadID()).Loan)
			net.Send(ply)

			ply:SelectWeapon("wep_jack_gmod_hands")
		end

		return false, "Рассчитываем процент по кредиту"
			
	end
end)

function LoanCalculations(amount)
	local baseRate = 0.05
	local dynamicRate = math.min(0.3, 0.00005 * amount)

	local interestRate = baseRate + dynamicRate

	local overpayment = amount * interestRate
	local amountToReturn = amount + overpayment
	
	return amountToReturn, interestRate
end

function LoanRepayment(loanmoney, amount)
    local dynamicRate = math.floor(amount / (loanmoney * 5/100)) * (loanmoney * 5/100)
    local downPayment = (dynamicRate / loanmoney) * 100

	return downPayment
end

net.Receive("lanrp.UpdateLoan", function(len, ply)

	local squad = SquadMenu:GetSquad(ply:GetSquadID())

	local amount = net.ReadFloat()

	if GAMEMODE:GetJBux(ply) - amount < 0 then
		ply:LanRPChatPrint(Color(255,255,0), "Не хватает денег для погашения кредита.")
	else
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) - amount)

		local olddebt = squad.Loan.money
		
		if squad.Loan.money - amount > 0.9 then

			squad.Loan.money = squad.Loan.money - amount
			squad.Loan.Debt = math.max(squad.Loan.Debt - LoanRepayment(squad.Loan.money, amount), 0)

			timer.Simple(0.5, function()
				for k,v in pairs(squad.membersById) do
					local member = player.GetBySteamID(k)
				
					member:LanRPChatPrint(Color(squad.r,squad.g,squad.b), ply:Nick(), Color(255,255,255), " выплатил ", Color(0,210,0), format_num(amount, 0) .. "$", Color(255,255,255), " из ", Color(0,210,0), format_num(olddebt, 0) .. "$") 
					member:LanRPChatPrint(Color(255,255,255), "----------------------------------------------------") 
					member:LanRPChatPrint(Color(255,255,255), "погашено " .. LoanRepayment(olddebt, amount) .. "% | Долг " .. squad.Loan.Debt .. "%")
					member:PlayLocalSound("hoi4/event_popup_01.wav")

					net.Start("lanrp.UpdateLoan")
					net.WriteInt(squad.Loan.money, 20)
					net.WriteInt(squad.Loan.Debt, 9)
					net.Send(member)
				end
			end)
		else
			timer.Simple(0.5, function()
				for k,v in pairs(squad.membersById) do
					local member = player.GetBySteamID(k)
				
					member:LanRPChatPrint(Color(squad.r,squad.g,squad.b), ply:Nick(), Color(255,255,255), " успешно погасил кредит!") 
					member:PlayLocalSound("hoi4/event_popup_01.wav")
				end
			end)
			squad:DeleteLoanDebt()
		end
	end
end)

net.Receive("lanrp.MakeLoan", function(_, ply)

	local money = net.ReadInt(20)

	local squad = SquadMenu:GetSquad(ply:GetSquadID())

	local amountToReturn, interestRate = LoanCalculations(money)

	timer.Simple(2, function()
		GAMEMODE:SetJBux(ply, GAMEMODE:GetJBux(ply) + money)

		for k,v in pairs(squad.membersById) do
			local member = player.GetBySteamID(k)

			member:LanRPChatPrint(Color(squad.r, squad.g, squad.b), ply:Nick(), Color(255,255,255), " взял кредит в размере - ", Color(0,210,0), format_num(money, 0), "$")
			member:LanRPChatPrint(Color(255,255,255), "----------------------------------------------------") 
			member:LanRPChatPrint(Color(255,255,255), "Проценты по кредиту " .. interestRate * 100 .. "%")
			member:LanRPChatPrint(Color(255,255,255), "Итого к возврату: ", Color(0,210,0), format_num(amountToReturn, 0) .. "$")
			member:PlayLocalSound("hoi4/naval_result_alert.wav")

			net.Start("lanrp.UpdateLoan")
			net.WriteInt(money, 20)
			net.WriteInt(0, 9)
			net.Send(member)
		end

		squad:MakeLoanDebt(amountToReturn)

	end)
end)


---VECHICLE SPAWN----

Vechicles = {
	["truck"] = { func = function(station, dropPos, DropVelocity, ply) 
			
		local Vechicle = ents.Create("lvs_wheeldrive_citroen_type23")
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},

	["car"] = { func = function(station, dropPos, DropVelocity, ply) 
		local squad = SquadMenu:GetSquad( ply:GetSquadID() )
		local Vechicle = ents.Create(SquadStyleVechicle[squad.Style].lightcar)
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},

	--[[["western car"] = { func = function(station, dropPos, DropVelocity) 
			
		local Vechicle = ents.Create("lvs_wheeldrive_dodwillyjeep")
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},]]

	["anti aircraft truck"] = { func = function(station, dropPos, DropVelocity) 
			
		local Vechicle = ents.Create("lvs_wheeldrive_dodhalftrack_us")
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle() + Angle(0,90,0))
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},

	["light tank"] = { func = function(station, dropPos, DropVelocity, ply) 
		local squad = SquadMenu:GetSquad( ply:GetSquadID() )
		local Vechicle = ents.Create(SquadStyleVechicle[squad.Style].lighttank)
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},

	["tank killer"] = { func = function(station, dropPos, DropVelocity, ply) 
		local squad = SquadMenu:GetSquad( ply:GetSquadID() )
		local Vechicle = ents.Create(SquadStyleVechicle[squad.Style].tankkiller)
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},

	["medium tank"] = { func = function(station, dropPos, DropVelocity, ply) 
		local squad = SquadMenu:GetSquad( ply:GetSquadID() )
		local Vechicle = ents.Create(SquadStyleVechicle[squad.Style].mediumtank)
		Vechicle:SetPos(dropPos)
		Vechicle:SetAngles(station.outpostDirection:Angle())
		Vechicle:Spawn()
		Vechicle:Activate()

		timer.Simple(0, function()
			if IsValid(Vechicle) then
				Vechicle:GetPhysicsObject():SetVelocity(-DropVelocity)
			end
		end)

		timer.Simple(3, function()
			if IsValid(Vechicle) then
				local Chute = ents.Create("ent_jack_gmod_ezparachute")
				Chute:SetPos(Vechicle:LocalToWorld(Vechicle:OBBCenter()))
				Chute:SetNW2Entity("Owner", Vechicle)
				--Chute.ParachuteName = "Parachute"
				Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
				Chute.Drag = 5
				Chute.MdlOffset = 50
				Chute.ChuteColor = Color(255, 255, 255)
				Chute:Spawn()
				Chute:Activate()
				Chute:SetNW2Float("ChuteProg", 2)
				Vechicle:SetNW2Bool("EZparachuting", true)
				Vechicle.EZparachute = Chute

				Vechicle:GetPhysicsObject():SetAngleDragCoefficient(200)

				timer.Simple(3, function()
					if IsValid(Vechicle) then
						Vechicle:GetPhysicsObject():SetAngleDragCoefficient(0)
					end
				end)
			end
		end)
	end
	},
}

local function SpawnVechicle(pkg, transceiver, id, ply)
	local Station = JMod.EZ_RADIO_STATIONS[id]
	Station.lastCaller = transceiver

	Station.deliveryCategory = "Vechicle"

	local AreaRadius = 512

	local Time = CurTime()
	local DeliveryTime, Pos = math.ceil(JMod.Config.RadioSpecs.DeliveryTimeMult * math.Rand(3, 6)), transceiver:GetPos() + Vector(math.random(-AreaRadius, AreaRadius), math.random(-AreaRadius, AreaRadius), 0)
	local newTime, newPos = hook.Run("JMod_RadioDelivery", ply, transceiver, pkg, DeliveryTime, Pos)
	DeliveryTime = newTime or DeliveryTime
	Pos = newPos or Pos
	JMod.Hint(ply, "aid wait")
	Station.state = JMod.EZ_STATION_STATE_DELIVERING
	Station.nextDeliveryTime = Time + DeliveryTime
	Station.deliveryLocation = Pos
	Station.deliveryType = pkg
	Station.notified = false
	Station.nextNotifyTime = Time + (DeliveryTime - 5)
	Station.Player = ply
	JMod.NotifyAllRadios(id) -- do a notify to update all radio states
end

hook.Add("JMod_CanRadioRequest", "JSMOD_PRE_VECHICLE", function(ply, transceiver, pkg)
	if pkg == "custom" then
		return
	end

	local PackageSpecs = JMod.Config.RadioSpecs.AvailablePackages[pkg]

	if PackageSpecs.category == "Vechicle" then

		--[[local ReqAmount = PackageSpecs.JBuxPrice --+ 

		local squad = SquadMenu:GetSquad(ply:GetSquadID()) 

		local Debt = math.Max(squad.Loan.Debt or 100, 1)

		if ReqAmount <= 0 then return end
		local PlyAmt = GAMEMODE:GetJBux(ply)
		if PlyAmt < ReqAmount then 
			return false, "Недостаточно JBux! (Тебе нужно еще: " .. tostring(ReqAmount - PlyAmt) .. ")" 
		else
			GAMEMODE:SetJBux(ply, PlyAmt - ReqAmount)
		end]]

		SpawnVechicle(pkg, transceiver, transceiver:GetOutpostID(), ply)
		return false, "Принято, сбрасываем экстренный транспорт!"
			
	end
end)

hook.Add("JMod_OnRadioDeliver", "JSMOD_VECHICLE_SPAWN", function(stationID, dropPos) 
	local station = JMod.EZ_RADIO_STATIONS[stationID]
	if station.deliveryCategory ~= nil and station.deliveryCategory == "Vechicle" then
		--
		
		local Plane = ents.Create("ent_aboot_jsmod_ezcargoplane")
		Plane:SetPos(dropPos)
		Plane:SetAngles(station.outpostDirection:Angle())
		Plane:Spawn()

		for _, ply in player.Iterator() do
			if IsValid(ply) then
				local Pos = ply:GetPos()
				local Dist = Pos:Distance(dropPos)
				if Dist < 10000 then
					local Direction = (Pos - dropPos):GetNormalized()
					sound.Play("@julton/cargo_plane_flyby_mono.wav", Pos + Vector(0, 0, 100), 160, 100, 1)
				end
			end
		end

		local DropVelocity = station.outpostDirection * 300

		timer.Simple(10, function()
			--if IsValid(station) then
				Vechicles[station.deliveryType].func(station, dropPos, DropVelocity, station.Player)
				station.deliveryCategory = nil
			--end
		end)

		return true
	end
end)