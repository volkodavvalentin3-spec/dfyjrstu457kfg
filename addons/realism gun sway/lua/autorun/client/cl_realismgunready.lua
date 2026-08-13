local cl_realismGunReady_enabled = 1
local cl_realismGunReady_bindkey = CreateClientConVar("cl_realismGunReady_bindkey",81,true)

local high_AngP = -5
local high_AngY = 0
local high_AngR = -10
local high_PosForward = -10
local high_PosUp = -3
local high_PosRight = -3

local high_AngP_running = -30
local high_AngY_running = 20
local high_AngR_running = 30
local high_PosForward_running = -10
local high_PosUp_running = 0
local high_PosRight_running = 7

local low_AngP = 15
local low_AngY = 0
local low_AngR = 0
local low_PosForward = 0
local low_PosUp = 0
local low_PosRight = 0

local nowPos = Vector()
local nowAng = Angle()

local shouldPull = 0
local attEnt,attId = nil
local pullLength_Update = 0
local mgbase_toggleaim = nil
timer.Simple(1,function()
	--??????????????????????????????
	mgbase_toggleaim = GetConVar("mgbase_toggleaim")
end)

local function realismGunReadyLerp(weapon, vm, oldPos, oldAng, pos, ang)
	if(cl_realismGunReady_enabled != 1) then
		return
	end


	local p = LocalPlayer()

	local angFactor = (-math.pow(math.abs(ang.p),2)/math.pow(90,2)+1)

	--自动收枪
	--mw距离检测
	if(weapon.GetAimDelta) then
		if (CurTime() - pullLength_Update > 1) then
			pullLength_Update = CurTime()
			if(vm.FindAttachment and shouldPull == 0 and weapon:GetAimDelta()== 0) then
				attEnt,attId = vm:FindAttachment("muzzle")
				local muzzle = attEnt:GetAttachment(attId)
				--PrintTable(vm:GetAttachments())
				--PrintTable(vm:GetAttachment(1))
				
				if(muzzle) then
					weapon.pullLength =  math.floor((muzzle.Pos - vm:GetPos()):Length())
					--weapon.pullLength =weapon:GetModelRadius() + attEnt:GetModelRadius()
				end
			end
		end
		--print(weapon.pullLength)
		if(!weapon.pullLength) then weapon.pullLength = 30 end
		local tr = util.TraceLine({
			start = pos,
			endpos = pos+ weapon.pullLength * ang:Forward(),
			filter = p
		})
		if tr.Hit then
			timer.Simple(0,function()
				shouldPull = 1
			end)
		else
			timer.Simple(0,function()
				shouldPull = 0
			end)
		end
	else
		shouldPull = 0
	end
	
	if(shouldPull == 1 and weapon.realismGunReady_state==0) then
		--自动收枪
		nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle(high_AngP * angFactor,high_AngY * angFactor,high_AngR))
		nowPos = LerpVector(FrameTime() * 5, nowPos, Vector(high_PosForward,high_PosUp,high_PosRight))

	elseif weapon.realismGunReady_state == 1 and !p.realismGunReady_inRunning then
		nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle(high_AngP * angFactor,high_AngY * angFactor,high_AngR))
		--nowPos = LerpVector( FrameTime() * 5, nowPos, ang:Forward()*high_PosForward+ang:Up()*high_PosUp+ang:Right()*high_PosRight)
		if(!weapon.GetAimDelta or !weapon:HasFlag("Reloading")) then
			nowPos = LerpVector(FrameTime() * 5, nowPos, Vector(high_PosForward,high_PosUp,high_PosRight))
		else
			--mw武器换弹时稍微拉远
			nowPos = LerpVector(FrameTime() * 7, nowPos, Vector(high_PosForward+3,high_PosUp-3,high_PosRight))
		end

		-- local boneLForearm = vm:LookupBone("ValveBiped.Bip01_L_Forearm")
		-- if (boneLForearm) then
		-- 	--设置前臂
		-- 	vm:ManipulateBonePosition(boneLForearm, Vector(0, 0, 0))
		-- end
		-- local boneLHand = vm:LookupBone("ValveBiped.Bip01_L_Hand")
		-- if (boneLHand) then
		-- 	--旋转手掌
		-- 	vm:ManipulateBoneAngles(boneLHand, Angle(0, 0, 0))
		-- end

	elseif weapon.realismGunReady_state == 1 and p.realismGunReady_inRunning then
		nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle(high_AngP_running * angFactor,high_AngY_running * angFactor,high_AngR_running))
		nowPos = LerpVector(FrameTime() * 5, nowPos, Vector(high_PosForward_running,high_PosUp_running,high_PosRight_running))

		--nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle(high_AngP,high_AngY,high_AngR))
		--nowPos = LerpVector(FrameTime() * 5, nowPos, Vector(high_PosForward,high_PosUp,high_PosRight))
		-- local boneLForearm = vm:LookupBone("ValveBiped.Bip01_L_Forearm")
		-- if (boneLForearm) then
		-- 	--设置前臂
		-- 	vm:ManipulateBonePosition(boneLForearm, Vector(0, 0, 0))
		-- end
		-- local boneLHand = vm:LookupBone("ValveBiped.Bip01_L_Hand")
		-- if (boneLHand) then
		-- 	--旋转手掌
		-- 	vm:ManipulateBoneAngles(boneLHand, Angle(0, 0, 50))
		-- end

	elseif weapon.realismGunReady_state == -1 then
		nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle(low_AngP,low_AngY,low_AngR))
		nowPos = LerpVector(FrameTime() * 5, nowPos, Vector(low_PosForward,low_PosUp,low_PosRight))
	else
		nowAng = LerpAngle(FrameTime() * 5 , nowAng, Angle())
		nowPos= LerpVector(FrameTime() * 5, nowPos, Vector())
	end

	--开镜过渡
	--mw  weapon:GetAimDelta()       0-1
	--arc9 weapon:GetSightDelta()    0-1
	--arccw  weapon:GetSightDelta()  1-0
	--tfa  weapon:GetIronSightsProgress()  0-1 不能取到0和1，而是近似值
	if(weapon.GetAimDelta) then
		nowAng = nowAng * (1-math.pow(weapon:GetAimDelta(),3))
		nowPos = nowPos * (1-math.pow(weapon:GetAimDelta(),3))
		-- nowAng = nowAng * (1-weapon:GetAimDelta())
		-- nowPos = nowPos * (1-weapon:GetAimDelta())
	elseif(weapon.GetSightDelta) then
		if(!weapon.ARC9) then
			--arccw
			nowAng = nowAng * weapon:GetSightDelta()
			nowPos = nowPos * weapon:GetSightDelta()
		else
			--arc9
			-- nowAng = nowAng * (1-math.pow(weapon:GetSightDelta(),3))
			-- nowPos = nowPos * (1-math.pow(weapon:GetSightDelta(),3))
			nowAng = nowAng * (1-weapon:GetSightDelta())
			nowPos = nowPos * (1-weapon:GetSightDelta())
		end
	elseif(weapon.GetIronSightsProgress) then
		if(weapon:GetIronSightsProgress()>0.995) then
			nowAng = nowAng * 0
			nowPos = nowPos * 0
		elseif(weapon:GetIronSightsProgress()>0.005) then
			nowAng = nowAng * (1-math.pow(weapon:GetIronSightsProgress(),5))
			nowPos = nowPos * (1-math.pow(weapon:GetIronSightsProgress(),5))
		else
			nowAng = nowAng * 1
			nowPos = nowPos * 1
		end
	else
		nowAng = nowAng * 0
		nowPos = nowPos * 0
	end
	--

	ang:SetUnpacked(ang.p+nowAng.p, ang.y+nowAng.y, ang.r+nowAng.r)
	--pos:Add(nowPos)
	pos:Add(ang:Forward() * nowPos.x)
	pos:Add(ang:Up() * nowPos.y)
	pos:Add(ang:Right() *nowPos.z)

end

local function realismGunReadyInput(ply, bind, pressed, code)
	if(cl_realismGunReady_enabled == 1) then
		local weapon = ply:GetActiveWeapon()
		if IsValid(weapon) then
			if(weapon.realismGunReady_state == nil) then
				weapon.realismGunReady_state = 0
			end

			if input.IsKeyDown(cl_realismGunReady_bindkey:GetInt()) then
			--if input.IsKeyDown(KEY_LALT) then
				if bind == "invprev" then
					-- 向下滚动
					weapon.realismGunReady_state = math.Clamp(weapon.realismGunReady_state-0.5,-1,1)
					return true
				elseif bind == "invnext" then
					-- 向上滚动
					weapon.realismGunReady_state = math.Clamp(weapon.realismGunReady_state+0.5,-1,1)
					return true
				end
			end
		end
	end
end

hook.Add("CalcViewModelView", "realism_Gun_Ready", realismGunReadyLerp)

-- 监听鼠标滚轮事件
hook.Add( "PlayerBindPress", "realism_Gun_Ready_InputBind", realismGunReadyInput )

--监听奔跑状态，阻止玩家按键
hook.Add( "CreateMove", "realism_Gun_Ready_InputCommand", function(cmd )
	if(cl_realismGunReady_enabled == 1) then
		local ply = LocalPlayer()
		
		if IsValid(ply) then
			--监听奔跑状态
			if cmd:KeyDown(IN_SPEED) then
				ply.realismGunReady_inRunning = true
			else
				ply.realismGunReady_inRunning = false
			end
			--阻止玩家开火
			if math.abs(nowAng.p) > 3 then
				--print(cmd:GetButtons())
				cmd:RemoveKey(IN_ATTACK)
			end
			--自动收枪时，阻止玩家瞄准
			local weapon = ply:GetActiveWeapon()
			if(IsValid(weapon) and weapon.GetAimDelta and shouldPull == 1) then
				cmd:RemoveKey(IN_ATTACK2)
				if(mgbase_toggleaim and mgbase_toggleaim:GetInt() == 1 and weapon:GetAimDelta()>0) then--mw设置为切换瞄准时进行的特殊处理
					cmd:AddKey(IN_ATTACK2)
				end
			end
		end
	end
end )