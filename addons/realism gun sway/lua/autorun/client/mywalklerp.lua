local Lerp_enable = CreateClientConVar("My_WalkViewModelLerp_enable", "1", true)
CreateClientConVar("My_WalkViewModelLerp_Rate", "1.5", true)
CreateClientConVar("My_WalkViewModelLerp_speed", "2.5", true)

local addr = 0
local addForward = 0
local function WalkViewModelLerp(weapon, vm, oldPos, oldAng, pos, ang)
	if(GetConVarNumber("cl_realismGunSway_enabled") != 1) then
		return
	end
	if(Lerp_enable:GetInt() != 1) then
		return
	end

	local scale = GetConVarNumber("My_WalkViewModelLerp_Rate");
	local speed = GetConVarNumber("My_WalkViewModelLerp_speed");

	local p = LocalPlayer()

	--获取玩家速度
	local vel = p:GetVelocity()

	--水平速度和前后速度
	vel:Div(p:GetWalkSpeed())

	local movementAngles = Angle(0, p:EyeAngles().y, 0)

	--左右方向向量
	local dotX = 0
	dotX = movementAngles:Right():Dot(vel)
	dotX = dotX * -1
	dotX = math.Clamp(dotX, -1.25, 1.25)

	--addr = dotX * scale * FrameTime() * 100

	if(dotX > 0.2) then
		if(addr < 3 * scale) then
			if(addr<0) then
				addr = addr + speed * FrameTime() * 5 * 2
			else
				addr = addr + speed * FrameTime() * 5
			end
		end
	elseif(dotX < -0.2) then
		if(addr > (-3) * scale) then
			if(addr>0) then
				addr = addr - speed * FrameTime() * 5 * 2
			else
				addr = addr - speed * FrameTime() * 5
			end
		end
	else
		--addr = addr / math.Clamp((FrameTime() * 100),1.1,2)
		addr = addr / (1+ speed*FrameTime())
	end


	--前后方向向量
	local dotY = 0
	dotY = movementAngles:Forward():Dot(vel)
	dotY = dotY * -1
	dotY = math.Clamp(dotY, -2, 2)

	if(dotY > 0.2) then
		if(addForward < 0.5 * scale) then
			if(addForward<0) then
				addForward = addForward + speed * FrameTime() * 0.5 * 2
			else
				addForward = addForward + speed * FrameTime() * 0.5
			end
		end
	elseif(dotY < -0.2) then
		if(addForward > (-0.5) * scale) then
			if(addForward>0) then
				addForward = addForward - speed * FrameTime() * 0.5 * 2
			else
				addForward = addForward - speed * FrameTime() * 0.5
			end
		end
	else
		--addr = addr / math.Clamp((FrameTime() * 100),1.1,2)
		addForward = addForward / (1+ speed*FrameTime())
	end


	--开镜过渡
	--mw  weapon:GetAimDelta()       0-1
	--arc9 weapon:GetSightDelta()    0-1
	--arccw  weapon:GetSightDelta()  1-0
	--tfa  weapon:GetIronSightsProgress()  0-1 不能取到0和1，而是近似值
	if(weapon.GetAimDelta) then
		addr = addr * weapon:GetAimDelta()
		addForward = addForward * weapon:GetAimDelta()
		
		--适配MW镜内放大
		if(weapon.MWB_DoingScope!=nil) then
			addForward = addForward *math.Clamp(weapon:GetAimModeDelta(), 0,1)
			weapon.MWB_LaggerAngR = addr
		end
		--
	elseif(weapon.GetSightDelta) then
		if(!weapon.ARC9) then
			--arccw
			addr = addr * (1-weapon:GetSightDelta())
			addForward = addForward * (1-weapon:GetSightDelta())
		else
			--arc9
			addr = addr * weapon:GetSightDelta()
			addForward = addForward * weapon:GetSightDelta()

			if(weapon:IsScoping()) then
				addr = 0
				addForward = 0
			end
		end
	elseif(weapon.GetIronSightsProgress) then
		if(weapon:GetIronSightsProgress()>0.995) then
			addr = addr * 1
			addForward = addForward * 1
		elseif(weapon:GetIronSightsProgress()>0.005) then
			addr = addr * weapon:GetIronSightsProgress()
			addForward = addForward * weapon:GetIronSightsProgress()
		else
			addr = addr * 0
			addForward = addForward * 0
		end
	else
		addr = addr * 0
		addForward = addForward * 0
	end
	--

	ang:SetUnpacked(ang.p, ang.y, ang.r-addr)
	pos:Add(ang:Forward() * addForward)

end

hook.Add("CalcViewModelView", "My_WalkViewModelLerp", WalkViewModelLerp)