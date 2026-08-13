SWEP.PrintName			= "healbeam" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "vasi" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Instructions		= "lkm for heal,pkm for heal"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= ""

SWEP.ShootSound = Sound( "friends/friend_join.wav" )


function SWEP:Deploy()
	self:SetHoldType( "fist" )
end

if (SERVER) then
	util.AddNetworkString("spell_healbeam")
end
-- Called when the left mouse button is pressed
function SWEP:PrimaryAttack()
	if(CLIENT) then return end
	local owner=self:GetOwner()
	-- This weapon is 'automatic'. This function call below defines
	-- the rate of fire. Here we set it to shoot every 0.5 seconds.
	self:SetNextPrimaryFire( CurTime() + 2 )
    local t=owner:GetEyeTrace()
	local target_pos=t["HitPos"]
    local target=t["Entity"]
	local owner_pos=owner:WorldSpaceCenter()
	if owner_pos:Distance(target_pos)<=250 then
		--print(owner_pos:Distance(target_pos))
		net.Start("spell_healbeam")
			net.WriteEntity(self)
		net.Broadcast()
		self:spell_healbeam(owner)
	end
end
 


function SWEP:SecondaryAttack()
    local hil=20
    local owner=self:GetOwner()
    self:EmitSound(self.ShootSound)
    if owner:Health() <=200 then
        owner:SetHealth(owner:Health()+hil)
		owner:SetCrazy(0)

    end
	self:SetNextSecondaryFire( CurTime() + 2)

end


function SWEP:spell_healbeam(entowner)
	--local entowner = self:GetOwner()
	local target_t=entowner:GetEyeTrace()
	local target=target_t["Entity"]
	local target_pos=target_t["HitPos"]
	local points={}
	local hil=20

	if target:IsWorld() or (!target:IsPlayer() and !target:IsNPC()) then

	elseif target:IsPlayer() or target:IsNPC() then

        if target:Health() <=200 then
	        target:SetHealth(target:Health()+hil)
			target:SetCrazy(0)
		end
        
	end

end


function SWEP:spell_healbeam_client()
	//local hands=entowner:GetHands()
    //local hands_pos=hands:WorldSpaceCenter()
	self:EmitSound(self.ShootSound)
	local entowner = self:GetOwner()
	local target_t=entowner:GetEyeTrace()
	local target=target_t["Entity"]
	local target_pos_world=target_t["HitPos"]
    local target_pos_centre=target:WorldSpaceCenter()

	local points={}

	if target:IsWorld() or (!target:IsPlayer() and !target:IsNPC()) then
		points={entowner:WorldSpaceCenter(),target_pos_world}
	elseif target:IsPlayer() or target:IsNPC() then
		points={entowner:WorldSpaceCenter(),target_pos_centre}
	end

	//local mat = Material("cable/blue_elec", "noclamp smooth")
    local start_beam = CurTime()
    local time_beam = 1

	local ind = tostring(math.random(1000,10000))

	hook.Add( "PostDrawOpaqueRenderables", "RenderBeam"..ind, function()

        local fract = 1-(CurTime() - start_beam) / time_beam

        local alpha = Lerp(fract, 0, 255)
		render.SetColorMaterial()
        
        render.DrawBeam(entowner:WorldSpaceCenter(),points[2],10,0,1,Color(168,228,160,alpha))
        render.DrawBeam(entowner:WorldSpaceCenter(),points[2],7,0,1,Color( 68,148,74,alpha))

	end)
	timer.Simple( 1,function () hook.Remove("PostDrawOpaqueRenderables", "RenderBeam"..ind) end)
end

for k, v in pairs(hook.GetTable()["PostDrawOpaqueRenderables"]) do
	local find = string.find(k, "RenderBeam")
	if find then
		hook.Remove("PostDrawOpaqueRenderables", k)
	end
end
net.Receive("spell_healbeam", function (ply)
	local entity =net.ReadEntity()
	//local entowner=entity:GetOwner()

	entity:spell_healbeam_client(entowner)
end)
