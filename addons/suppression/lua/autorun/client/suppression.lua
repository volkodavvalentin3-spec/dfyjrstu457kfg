print("[Suppression] Client loaded.")

local suppression_viewpunch = CreateConVar("suppression_viewpunch", 1, {FCVAR_ARCHIVE})
local suppression_viewpunch_intensity = CreateConVar("suppression_viewpunch_intensity", 1, {FCVAR_ARCHIVE})
local suppression_buildupspeed = CreateConVar("suppression_buildupspeed", 1, {FCVAR_ARCHIVE})
local suppression_sharpen = CreateConVar("suppression_sharpen", 1, {FCVAR_ARCHIVE})
local suppression_sharpen_intensity = CreateConVar("suppression_sharpen_intensity", 1, {FCVAR_ARCHIVE})
local suppression_bloom = CreateConVar("suppression_bloom", 1, {FCVAR_ARCHIVE})
local suppression_blur = CreateConVar("suppression_blur", 0, {FCVAR_ARCHIVE}) // very performance heavy. should be off by default
local supression_blur_style = CreateConVar("supression_blur_style", 1, {FCVAR_ARCHIVE})
local supression_blur_intensity = CreateConVar("supression_blur_intensity", 1, {FCVAR_ARCHIVE})
local suppression_bloom_intensity = CreateConVar("suppression_bloom_intensity", 1, {FCVAR_ARCHIVE})
local suppression_enabled = CreateConVar("suppression_enabled", 1, {FCVAR_ARCHIVE})
local suppression_gasp_enabled = CreateConVar("suppression_gasp_enabled", 1, {FCVAR_ARCHIVE})
local suppression_enable_vehicle = CreateConVar("suppression_enable_vehicle", 1, {FCVAR_ARCHIVE})
local suppression_self_suppress = CreateConVar("suppression_self_suppress", 0, {FCVAR_ARCHIVE})


--local effect_amount = 0

local function readVectorUncompressed()
	local tempVec = Vector(0,0,0)
	tempVec.x = net.ReadFloat()
	tempVec.y = net.ReadFloat()
	tempVec.z = net.ReadFloat()
	return tempVec
end

--[[hook.Add("EntityFireBullets", "suppression_EntityFireBullets", function(attacker, data)
	if not suppression_enabled:GetBool() then return end

	if LocalPlayer():InVehicle() and not suppression_enable_vehicle:GetBool() then return end 

	--[[local tr = util.TraceLine({
		start = src,
		endpos = src + dir * 100000,
		mask = CONTENTS_WINDOW + CONTENTS_SOLID + CONTENTS_AREAPORTAL + CONTENTS_MONSTERCLIP + CONTENTS_CURRENT_0
	})

	local distance_from_line, nearest_point, dist_along_the_line = util.DistanceToLine(tr.StartPos, tr.HitPos, LocalPlayer():GetPos())

	for _, Projectile in next, ProjectileInfo:GetProjectiles() do
		PrintTable(Projectile)
	end

	if LocalPlayer():Alive() and nearest_point:Distance(LocalPlayer():GetPos()) < 100 then
		effect_amount = math.Clamp(effect_amount + 0.08 * suppression_buildupspeed:GetFloat(), 0, 1)
		sound.Play("bul_snap/supersonic_snap_" .. math.random(1,18) .. ".wav", nearest_point, 75, 100, 1)
		sound.Play("bul_flyby/subsonic_" .. math.random(1,27) .. ".wav", nearest_point, 75, 100, 1)
		if suppression_viewpunch:GetBool() then
			local angle = Angle(math.Rand(-1.5, 1.5) * (effect_amount * (suppression_viewpunch_intensity:GetFloat())), 
							  math.Rand(-1.5, 1.5) * (effect_amount * (suppression_viewpunch_intensity:GetFloat())), 
				              math.Rand(-1.5, 1.5) * (effect_amount * (suppression_viewpunch_intensity:GetFloat())))
			Viewpunch(angle)
		end
	end
end)

local started_effect = false
hook.Add("Think", "suppression_loop", function() 
	if effect_amount == 0 then
		if started_effect then
			if suppression_gasp_enabled:GetBool() then
				timer.Simple(0.5, function()
					// just to ensure we dont spam the gasp
					if effect_amount == 0 then LocalPlayer():EmitSound("gasp/focus_gasp_0".. math.random(1,6) ..".wav", 75, math.random(90,110)) end
				end)
			end
			
			started_effect = false
		end
	 	return 
	end

	effect_amount = math.Clamp(effect_amount - 0.2 * FrameTime(), 0, 1)
	started_effect = true
end)

local sharpen_lerp = 0
local bloom_lerp = 0
local effect_lerp = 0
hook.Add("RenderScreenspaceEffects", "suppression_ApplySuppression", function()
	if effect_amount == 0 then return end

	if suppression_sharpen:GetBool() then
		sharpen_lerp = Lerp(6 * FrameTime(), sharpen_lerp, effect_amount * (suppression_sharpen_intensity:GetFloat()))
		DrawSharpen(sharpen_lerp , 0.4)
	end

	if suppression_bloom:GetBool() then
		bloom_lerp = Lerp(6 * FrameTime(), bloom_lerp, effect_amount * (suppression_bloom_intensity:GetFloat()) )
		DrawBloom(0.30, bloom_lerp , 0.33, 4.5, 1, 0, 1, 1, 1)
	end

	if suppression_blur:GetBool() then
		effect_lerp = Lerp(6 * FrameTime(), effect_lerp, effect_amount)
		if (supression_blur_style:GetFloat()) == 0 then
			DrawBokehDOF(effect_lerp * supression_blur_intensity:GetFloat(), 0, 0 )
		else
			DrawBokehDOF(effect_lerp * supression_blur_intensity:GetFloat(), 0.05, 0.25 )
		end
	end
end)

local m = Material("vignette/vignette")
local alphanew = 0
hook.Add("RenderScreenspaceEffects", "suppression_vignette", function()
	if effect_amount == 0 then return end

	alphanew = Lerp(6 * FrameTime(), alphanew, effect_amount)

	render.SetMaterial(m)
	m:SetFloat("$alpha", alphanew)

	for i = 1, 4 do render.DrawScreenQuad() end
end)

hook.Add("PlayerInitialSpawn", "suppression_Initialize", function(ply)
	effect_amount = 0
end)

hook.Add("PlayerDeath", "suppression_ClearDeath", function(ply, i, a)
	effect_amount = 0
end)]]
