include("shared.lua")
--[[local posX = {
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
	0.29,
	0.29,
}
local posY = {
	0.29,
	0.29,
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
}
local COLOR_GREEN = Color(0,255,0,255)
local COLOR_BLACK = Color(0,0,0,255)
local COLOR_WHITE = Color(255,255,255,255)
local COLOR_WHITE_HOVERED = Color(200,200,200,150)
local HOOK_ADDED = false
local LANGUAGE
local ints = {
	[8] = 1,
	[2] = 2,
	[4] = 3,
}
local function DrawCircle( X, Y, radius )
	local segmentdist = 360 / ( 2 * math.pi * radius / 2 )	
	for a = 0, 360, segmentdist do
		surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
	end
end
function SWEP:DrawHUD()
	local X = ScrW()
	local Y = ScrH()

	surface.SetDrawColor(0,0,0,self.Zoom.Val*255)
	surface.SetTexture(surface.GetTextureID("models/sw/shared/sights/binoculars"))
	surface.DrawTexturedRect(0,-(X-Y)/2,X,X)
	local tr = self:GetOwner():GetEyeTrace()
	local range = (math.ceil(100*(tr.StartPos:Distance(tr.HitPos)*0.024))/100)
	if tr.HitSky then
		range = "-"
	else
		range = range.."m"
	end
	surface.SetTextColor( 255, 255, 255, self.Zoom.Val*255 )
	surface.SetTextPos( X*0.165, Y/2 )
	surface.DrawText( "Range: "..range )
	surface.SetTextPos( X*0.165, Y/2 + 16)
	surface.DrawText( "X: "..(math.Round(math.ceil(100*tr.HitPos.x)/10000)))
	surface.SetTextPos( X * 0.165, Y/2 + 32)
	surface.DrawText( "Y: "..(math.Round(math.ceil(100*tr.HitPos.y)/10000)))
	surface.SetTextPos( X*0.165, Y/2 + 48)
	--surface.DrawText( "Z: "..(math.ceil(100*tr.HitPos.z)/100) )
end
function SWEP:CalcView(ply,pos,ang,fov)
	return pos,ang,fov - (self.Zoom.Val * self.Zoom.FOV)
end
function SWEP:AdjustMouseSensitivity()
	return self:GetOwner():KeyDown(IN_ATTACK2) and 0.1 or 1
end
function SWEP:CalcViewModelView(ViewModel,OldEyePos)
	if self.Zoom.Val > 0.8 then
		return Vector(0,0,0)
	else
		return OldEyePos - Vector(0,0,1.3)
	end
end
function SWEP:Think()
	local keydown = self:GetOwner():KeyDown(IN_ATTACK2)
	self.Zoom.Val = math.Clamp(self.Zoom.Val + (keydown and self.Zoom.Rate or -self.Zoom.Rate),0,1)	
	if keydown and not self.IsZooming then
		self.IsZooming = true
		self.IsUnZooming = false	
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	elseif !keydown and not self.IsUnZooming and self.IsZooming then
		self.IsZooming = false
		self.IsUnZooming = true		
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end
	if keydown then
		local Zoom = self.Zoom.FOV
		local ZoomSwitch = self:GetOwner():KeyDown(IN_SPEED)
		if self.OldZoomSwitch ~= ZoomSwitch then
			if ZoomSwitch and Zoom == 70 then
				self.Zoom.FOV = 40
			elseif ZoomSwitch and Zoom == 40 then
				self.Zoom.FOV = 70
			end
			self.OldZoomSwitch = ZoomSwitch
		end
	end
end]]

local WorldModel = ClientsideModel(SWEP.WorldModel)

-- Settings...
WorldModel:SetSkin(1)
WorldModel:SetNoDraw(true)

function SWEP:DrawWorldModel()
	local _Owner = self:GetOwner()

	if (IsValid(_Owner)) then
		-- Specify a good position
		local offsetVec = Vector(0, -3, -2)
		local offsetAng = Angle(-85,0, 0)

		local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
		if !boneid then return end

		local matrix = _Owner:GetBoneMatrix(boneid)
		if !matrix then return end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)

		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end