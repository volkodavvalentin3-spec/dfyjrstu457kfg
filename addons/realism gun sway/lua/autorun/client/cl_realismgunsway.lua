local cl_realismGunSway_enabled = 1
--CreateClientConVar("cl_realismGunSway_flSpeed", "7.0", true)
--CreateClientConVar("cl_realismGunSway_maxflScale", "4.0", true)
local flSensitivity = 0.2
local onlyAimFl = 0
local isReverse = 0 --CreateClientConVar("cl_realismGunSway_reverse", "0", true)
local aimDeadZone = 1 --CreateClientConVar("cl_realismGunSway_aimDeadZone", "1", true)
local shouldNotReturn = 0 --CreateClientConVar("cl_realismGunSway_shouldNotReturn", "1", true)
local deadZoneAngDiff = 1 --CreateClientConVar("cl_realismGunSway_deadZoneAngDiff", "1", true)
local deadZoneSensitivity_X = 1 --CreateClientConVar("cl_realismGunSway_deadZoneSensitivity_X", "1", true)
local deadZoneSensitivity_Y = 1 --CreateClientConVar("cl_realismGunSway_deadZoneSensitivity_Y", "1", true)
local forceTrajector = 1 --CreateClientConVar("cl_realismGunSway_forceTrajector", "1", true)

local lastMouseX = 0
local lastMouseY = 0
local changeX = 0
local changeY = 0
local lagPos = Vector()

local totalChangeX = 0
local totalChangeY = 0

--瞄准死区用到的原始x和y
local ThisX=0
local ThisY=0

local haveScope = false

local freeAngle = Angle()

local existMWRealismFile = file.Exists( "lua/autorun/MWB_MagnificationScope.lua", "GAME" )

local function CalcViewModelLag(weapon, vm, oldPos, oldAng, pos, ang)

	--if(aimDeadZone == 1 and (weapon.GetAimDelta or weapon.GetSightDelta or weapon.GetIronSightsProgress)) then

	if(aimDeadZone == 1 and (weapon.GetAimDelta or weapon.ARC9 or weapon.GetIronSightsProgress) and ((!haveScope) or weapon:GetAimModeDelta()>0 or weapon.realismGunSwaySmooth)) then

		--死区瞄准
		local up = ang:Up()
		local right = ang:Right()
		local diff = Vector()

		-- if(shouldNotReturn == 1) then
		-- 	--viewModel不返回中心时，使用totalChangeX (由于totalChangeX已经关联了-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1)，所以不用再关联了）
		-- 	diff = totalChangeX * (-right) + totalChangeY * up
		-- else
		-- 	--viewModel返回中心时，使用changeX
		-- 	diff = changeX * (-right)*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1) + changeY * up
		-- end
		diff = changeX * (-right)*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1) + changeY * up

		--死区角度偏转系数（系数为0时光瞄准心保持在中心）
		diff = diff * deadZoneAngDiff
		

		if(onlyAimFl != 0) then
			if(weapon.GetAimDelta) then
				diff = diff * weapon:GetAimDelta()
			elseif(weapon.GetSightDelta) then
				if(!weapon.ARC9) then
					--arccw
					diff = diff * (1-weapon:GetSightDelta())
				else
					--arc9
					diff = diff * weapon:GetSightDelta()
				end
			elseif(weapon.GetIronSightsProgress) then
				if(weapon:GetIronSightsProgress()>0.995) then
					diff = diff * 1
				elseif(weapon:GetIronSightsProgress()>0.005) then
					diff = diff * weapon:GetIronSightsProgress()
				else
					diff = diff * 0
				end
			end
		end


		if(isReverse == 0) then
			lagPos = LerpVector(FrameTime() * 5, lagPos, diff * 0.1)
		else
			lagPos = LerpVector(FrameTime() * 5, lagPos, diff * -0.1)
		end

		pos:Add(lagPos)

		--其中mwb必须需要减去角度才能起作用，不同的viewmodelfov对应不同角度
		--除mwb之外其他base可以不修改ang就能产生viewmodel偏移，但不关联fov的话可能落点不大准
		--mw关联fov：使用武器fov除以玩家视角fov
		--arc9本身视图模型就能与玩家摄像头产生关联，但需要利用差值校准落点
		--事实上如果修改了玩家fov，使用LocalPlayer():GetFOV()反而会导致弹道偏移，所以不如直接使用75
		local FOVMultiplier = 0
		if(weapon.GetAimDelta) then
			--mw
			--mw默认ViewModelFOV是64，玩家默认fov是75
			if (existMWRealismFile) then
				FOVMultiplier = weapon.ViewModelFOV / 75 + 0.002* (weapon.ViewModelFOV - 75)
			else
				FOVMultiplier = weapon.ViewModelFOV / 75 + 0.001* (weapon.ViewModelFOV - 75)
			end
			--FOVMultiplier = weapon.ViewModelFOV / 75
			--FOVMultiplier = weapon.ViewModelFOV / LocalPlayer():GetFOV()
		elseif(weapon.ARC9) then
			--arc9
			--FOVMultiplier = 0.01*(weapon:GetViewModelFOV()-LocalPlayer():GetFOV())
			FOVMultiplier = 0.01*(weapon:GetViewModelFOV()-75)
		elseif(weapon.ArcCW) then
			--arccw
			--FOVMultiplier = -0.2 * (weapon.ViewModelFOV - 75)
		elseif(weapon.GetIronSightsProgress) then
			--tfa
			--FOVMultiplier = (0.01+(GetConVar("cl_tfa_viewmodel_multiplier_fov")-1)/30) * (weapon.ViewModelFOV - LocalPlayer():GetFOV())
			--FOVMultiplier = 0.015* (weapon.ViewModelFOV - LocalPlayer():GetFOV())
			FOVMultiplier = 0.02* (weapon.ViewModelFOV - 75)
		end

		--手动强制调整弹道
		FOVMultiplier= FOVMultiplier * forceTrajector
		--

		ang.p = ang.p - freeAngle.p* FOVMultiplier
		ang.y = ang.y - freeAngle.y * FOVMultiplier


		--适配MW镜内放大
		if(weapon.MWB_ScopeMagnificationFov) then
			weapon.MWB_LaggerAngX = freeAngle.y
			weapon.MWB_LaggerAngY = freeAngle.p

			weapon.MWB_LaggerPosX = (lagPos:Dot(right))*weapon.MWB_ScopeMagnificationFov
			weapon.MWB_LaggerPosY = (lagPos:Dot(up))*weapon.MWB_ScopeMagnificationFov
		end
		--
		
	else
		local up = ang:Up()
		local right = ang:Right()

		--local diff = changeX * (-right) + changeY * up
		--当镜头上移时（超过60°比较明显），左右拖动鼠标不是单纯的横向移动镜头，而主要是在对镜头进行旋转
		--所以我对changeX乘以了一个3次方程，这个方程过(0,1),(90,0)点，系数为负。。。使其在竖直90°时changeX为0，竖直0°时有完全的changeX，在60°左右产生较大突变
		--或许应该在此处添加ang.r的旋转以获得更好的效果，但有可能会导致其他镜内放大模组画面旋转
		--或许应该利用弧长和夹角计算切线上的投影长？？？算了，太恶心了
		local diff = changeX * (-right)*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1) + changeY * up

		--开镜过渡
		--mw  weapon:GetAimDelta()       0-1
		--arc9 weapon:GetSightDelta()    0-1
		--arccw  weapon:GetSightDelta()  1-0
		--tfa  weapon:GetIronSightsProgress()  0-1 不能取到0和1，而是近似值
		if(onlyAimFl != 0) then
			if(weapon.GetAimDelta) then
				--mw
				diff = diff * weapon:GetAimDelta()
			elseif(weapon.GetSightDelta) then
				if(!weapon.ARC9) then
					--arccw
					diff = diff * (1-weapon:GetSightDelta())
				else
					--arc9
					diff = diff * weapon:GetSightDelta()
				end
			elseif(weapon.GetIronSightsProgress) then
				--tfa
				if(weapon:GetIronSightsProgress()>0.995) then
					diff = diff * 1
				elseif(weapon:GetIronSightsProgress()>0.005) then
					diff = diff * weapon:GetIronSightsProgress()
				else
					diff = diff * 0
				end
			end
		end
		--

		local flSpeed = 4 --GetConVarNumber("cl_realismGunSway_flSpeed");

		if(isReverse == 0) then
			lagPos = LerpVector(FrameTime() * 5, lagPos, diff * 0.1)
		else
			lagPos = LerpVector(FrameTime() * 5, lagPos, diff * -0.1)
		end

		pos:Add(lagPos)

		--适配MW镜内放大
		if(weapon.MWB_ScopeMagnificationFov) then
			--找出在水平和竖直方向上的向量投影
			weapon.MWB_LaggerPosX = (lagPos:Dot(right))*weapon.MWB_ScopeMagnificationFov
			weapon.MWB_LaggerPosY = (lagPos:Dot(up))*weapon.MWB_ScopeMagnificationFov

			weapon.MWB_LaggerAngX = nil
			weapon.MWB_LaggerAngY = nil
		end
		--
	end

end

hook.Add("CalcView", "realismGunSway_sightAngle", function(ply, origin, ang, fov)
    if !cl_realismGunSway_enabled then return end
	if (aimDeadZone == 0) then return end
	local weapon = ply:GetActiveWeapon()
	--if(!(weapon.GetAimDelta or weapon.GetSightDelta or weapon.GetIronSightsProgress)) then return end
	if(!IsValid(weapon) or !(weapon.GetAimDelta or weapon.ARC9 or weapon.GetIronSightsProgress)) then return end

	--此处偏移玩家摄像机视角（正向是摄像头往回拉）（可以修改子弹落点，大多数base落点参考eyeAng、eyePos）

	local flSpeed = 4 --GetConVarNumber("cl_realismGunSway_flSpeed");
	local maxflScale = 10 --GetConVarNumber("cl_realismGunSway_maxflScale");

	--判断是否安装了倍镜(但如果安装了我的镜内放大模组则值为false)
	haveScope = weapon.GetAimDelta and weapon:GetSight() and weapon:GetSight().Optic and weapon.MWB_DoingScope==nil

	if(shouldNotReturn == 1) then
		--viewModel不回正
		--需要计算总的ChangeX，ChangeY
		totalChangeX=math.Clamp((totalChangeX+0.02*deadZoneSensitivity_X*ThisX*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1)), -maxflScale,maxflScale)
		totalChangeY=math.Clamp(totalChangeY+0.01*deadZoneSensitivity_Y*ThisY, -maxflScale*0.5,maxflScale*0.5)

		--鼠标静止后不要使摄像头继续移动(防止镜头回弹)
		-- if(isReverse ==0) then
		-- 	if(ThisX == 0) then
		-- 		totalChangeX = freeAngle.y
		-- 	end
		-- 	if(ThisY == 0) then
		-- 		totalChangeY = -freeAngle.p
		-- 	end
		-- else
		-- 	if(ThisX == 0) then
		-- 		totalChangeX = -freeAngle.y
		-- 	end
		-- 	if(ThisY == 0) then
		-- 		totalChangeY = freeAngle.p
		-- 	end
		-- end
		--

		if(haveScope) then
			--开镜时取消死区的平滑过渡
			totalChangeX = totalChangeX* math.Clamp(weapon:GetAimModeDelta(), 0,1)
			totalChangeY = totalChangeY* math.Clamp(weapon:GetAimModeDelta(), 0,1)
			if(weapon:GetAimModeDelta()>0 and weapon:GetAimModeDelta()<1) then
				weapon.realismGunSwaySmooth = true
			end
			if(weapon.realismGunSwaySmooth) then
				changeX = 0
				changeY = 0
				lastMouseX = 0
				lastMouseY = 0
			end
			if(weapon.realismGunSwaySmooth and (weapon:GetAimModeDelta()<=0 or weapon:GetAimModeDelta()>=1)) then
				if(!timer.Exists("MWB_realismGunSwaySmooth")) then
					timer.Create("MWB_realismGunSwaySmooth",0.7,1,function()
						weapon.realismGunSwaySmooth = false
					end)
				end
			end
		end

		if(onlyAimFl != 0) then
			if(weapon.GetAimDelta) then
				--mw
				totalChangeX = Lerp(FrameTime() * 10, totalChangeX, totalChangeX* weapon:GetAimDelta())
				totalChangeY = Lerp(FrameTime() * 10, totalChangeY, totalChangeY* weapon:GetAimDelta())
			elseif(weapon.GetSightDelta) then
				if(!weapon.ARC9) then
					--arccw
					totalChangeX = Lerp(FrameTime() * 10, totalChangeX, totalChangeX * (1-weapon:GetSightDelta()))
					totalChangeY = Lerp(FrameTime() * 10, totalChangeY, totalChangeY * (1-weapon:GetSightDelta()))
				else
					--arc9
					totalChangeX = Lerp(FrameTime() * 10, totalChangeX, totalChangeX* weapon:GetSightDelta())
					totalChangeY = Lerp(FrameTime() * 10, totalChangeY, totalChangeY* weapon:GetSightDelta())
				end
			elseif(weapon.GetIronSightsProgress) then
				--tfa
				if(weapon:GetIronSightsProgress()>0.995) then
					totalChangeX = totalChangeX * 1
					totalChangeY = totalChangeY * 1
				elseif(weapon:GetIronSightsProgress()>0.005) then
					totalChangeX = Lerp(FrameTime() * 10, totalChangeX, totalChangeX* weapon:GetIronSightsProgress())
					totalChangeY = Lerp(FrameTime() * 10, totalChangeY, totalChangeY* weapon:GetIronSightsProgress())
				else
					totalChangeX = Lerp(FrameTime() * 10, totalChangeX, 0)
					totalChangeY = Lerp(FrameTime() * 10, totalChangeY, 0)
				end
			end
		end
		
		--用lerp有可能导致镜头偏转延迟
		if(isReverse ==0) then
			--freeAngle = LerpAngle(FrameTime() * flSpeed, freeAngle, Angle(-totalChangeY, totalChangeX, 0))
			freeAngle = Angle(-totalChangeY, totalChangeX, 0)
		else
			--freeAngle = LerpAngle(FrameTime() * flSpeed, freeAngle, Angle(totalChangeY, -totalChangeX, 0))
			freeAngle = Angle(totalChangeY, -totalChangeX, 0)
		end
	else
		--viewModel回正
		local LerpX = -changeX*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1)
		local LerpY = changeY

		if(haveScope) then
			--开镜时取消死区的平滑过渡
			LerpX = LerpX* math.Clamp(weapon:GetAimModeDelta(), 0,1)
			LerpY = LerpY* math.Clamp(weapon:GetAimModeDelta(), 0,1)
			if(weapon:GetAimModeDelta()>0 and weapon:GetAimModeDelta()<1) then
				weapon.realismGunSwaySmooth = true
			end
			if(weapon.realismGunSwaySmooth) then
				changeX = 0
				changeY = 0
				lastMouseX = 0
				lastMouseY = 0
			end
			if(weapon.realismGunSwaySmooth and (weapon:GetAimModeDelta()<=0 or weapon:GetAimModeDelta()>=1)) then
				if(!timer.Exists("MWB_realismGunSwaySmooth")) then
					timer.Create("MWB_realismGunSwaySmooth",0.7,1,function()
						weapon.realismGunSwaySmooth = false
					end)
				end
			end
		end

		if(onlyAimFl != 0) then
			if(weapon.GetAimDelta) then
				--mw
				LerpX = LerpX* weapon:GetAimDelta()
				LerpY = LerpY* weapon:GetAimDelta()
			elseif(weapon.GetSightDelta) then
				if(!weapon.ARC9) then
					--arccw
					LerpX = LerpX * (1-weapon:GetSightDelta())
					LerpY = LerpY * (1-weapon:GetSightDelta())
				else
					--arc9
					LerpX = LerpX * weapon:GetSightDelta()
					LerpY = LerpY * weapon:GetSightDelta()
				end
			elseif(weapon.GetIronSightsProgress) then
				--tfa
				if(weapon:GetIronSightsProgress()>0.995) then
					LerpX = LerpX * 1
					LerpY = LerpY * 1
				elseif(weapon:GetIronSightsProgress()>0.005) then
					LerpX = LerpX * weapon:GetIronSightsProgress()
					LerpY = LerpY * weapon:GetIronSightsProgress()
				else
					LerpX = LerpX * 0
					LerpY = LerpY * 0
				end
			end
		end

		if(isReverse ==0) then
			freeAngle = LerpAngle(FrameTime() * flSpeed, freeAngle, Angle(-LerpY*maxflScale/4, -LerpX*maxflScale/4, 0))
		else
			freeAngle = LerpAngle(FrameTime() * flSpeed, freeAngle, Angle(LerpY*maxflScale/4, LerpX*maxflScale/4, 0))
		end
	end

	ang.p = ang.p + freeAngle.p
    ang.y = ang.y + freeAngle.y

end)

hook.Add("InputMouseApply", "realismGunSway_mouseInput", function(cmd, x, y, ang) 
    if (cl_realismGunSway_enabled != 0) then

		local maxflScale = 10 --GetConVarNumber("cl_realismGunSway_maxflScale");
		local flSpeed = 4 --GetConVarNumber("cl_realismGunSway_flSpeed");

		local weapon = LocalPlayer():GetActiveWeapon()

		if !IsValid(weapon) then return end

		--适配MW镜内放大（防止低倍时画面抖动严重）（好像没必要）
		-- local weapon = LocalPlayer():GetActiveWeapon()
		-- if(weapon.MWB_ScopeMagnificationFov) then
		-- 	if(weapon:GetAimDelta() > 0 && weapon:GetSight() != nil && weapon:GetSight().Optic != nil && weapon:GetAimModeDelta() <= weapon.m_hybridSwitchThreshold) then
		-- 		if(flSpeed>5) then
		-- 			flSpeed = 5
		-- 		end
		-- 	end
		-- end
		--

		--瞄准死区 viewModel不回正
		--需要计算总的ChangeX，ChangeY
		-- if(aimDeadZone == 1) then
		-- 	totalChangeX=math.Clamp((totalChangeX+0.01*x*(-math.pow(math.abs(ang.p),3)/math.pow(90,3)+1)), -maxflScale,maxflScale)
		-- 	totalChangeY=math.Clamp(totalChangeY+0.01*y, -maxflScale,maxflScale)
		-- end
		--

		--防止鼠标输入导致的模型抽搐x
		local MouseX = math.Clamp(x *0.5 *flSensitivity, -maxflScale, maxflScale)
		if(math.abs(MouseX - lastMouseX) < maxflScale*0.2) then
			changeX = Lerp(FrameTime() * flSpeed, changeX, MouseX)
			lastMouseX = MouseX
		else
			if(MouseX - lastMouseX>0) then
				changeX = Lerp(FrameTime() * flSpeed, changeX, lastMouseX + maxflScale*0.2)
				lastMouseX = lastMouseX + maxflScale*0.2
			else
				changeX = Lerp(FrameTime() * flSpeed, changeX, lastMouseX - maxflScale*0.2)
				lastMouseX = lastMouseX - maxflScale*0.2
			end
		end
		

		--防抖y
		--非死区瞄准
		local MouseY = math.Clamp(y *0.5 *flSensitivity, -maxflScale, maxflScale)
		-- if(math.abs(y)>10) then
		-- 	changeY = Lerp(FrameTime() * flSpeed, changeY, MouseY)
		-- else
		-- 	changeY = Lerp(FrameTime() * flSpeed, changeY, 0)
		-- end
		if(math.abs(MouseY - lastMouseY) < maxflScale*0.2) then
			changeY = Lerp(FrameTime() * flSpeed, changeY, MouseY)
			lastMouseY = MouseY
		else
			if(MouseY - lastMouseY>0) then
				changeY = Lerp(FrameTime() * flSpeed, changeY, lastMouseY + maxflScale*0.2)
				lastMouseY = lastMouseY + maxflScale*0.2
			else
				changeY = Lerp(FrameTime() * flSpeed, changeY, lastMouseY - maxflScale*0.2)
				lastMouseY = lastMouseY - maxflScale*0.2
			end
		end


		--死区瞄准直接使用原始x和原始y
		-- ThisX = x * FrameTime() *120
		-- ThisY = y * FrameTime() *120
		if(lastMouseX*x <= 0) then
			ThisX = 0
		else
			ThisX = lastMouseX * FrameTime()*120
		end
		if(lastMouseY*y <= 0) then
			ThisY = 0
		else
			ThisY = lastMouseY * FrameTime()*120
		end

	end
end)


do

	--mwbase weapon:GetAimDelta()
	--tfa weapon:GetIronSights()
	--arc9 weapon:GetInSights()
	--arccw weapon:GetActiveSights()
	local function doLag(weapon, vm, oldPos, oldAng, pos, ang)
		CalcViewModelLag(weapon, vm, oldPos, oldAng, pos, ang)
	end

	if (cl_realismGunSway_enabled != 0) then
		hook.Add("CalcViewModelView", "realismGunSway", doLag)
	end

	cvars.AddChangeCallback("cl_realismGunSway_enabled", function(var, old, new)
		if (tonumber(new) != 0) then
			hook.Add("CalcViewModelView", "realismGunSway", doLag)
		else
			hook.Remove("CalcViewModelView", "realismGunSway")
		end
	end)
end