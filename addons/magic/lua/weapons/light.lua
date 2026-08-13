SWEP.PrintName			= "lighting" -- This will be shown in the spawn menu, and in the weapon selection menu
SWEP.Author			= "vasi" -- These two options will be shown when you have the weapon highlighted in the weapon selection menu
SWEP.Instructions		= "lkm for ubit"

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

SWEP.ShootSound = Sound( "ambient/energy/zap6.wav" )


function SWEP:Deploy()
	self:SetHoldType( "fist" )
end

if (SERVER) then
	util.AddNetworkString("spell")
end

function SWEP:PrimaryAttack()
	if(CLIENT) then return end
	local owner=self:GetOwner()

	self:SetNextPrimaryFire( CurTime() + 2 )
	local target_pos=owner:GetEyeTrace()["HitPos"]
	local owner_pos=owner:WorldSpaceCenter()
	if owner_pos:Distance(target_pos)<=1500 then
		--print(owner_pos:Distance(target_pos))
		net.Start("spell")
			net.WriteEntity(self)
		net.Broadcast()
		self:spell_lightning()
	end
end
 


function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + 0.1 )

end


function SWEP:spell_lightning(entowner)
	local entowner = self:GetOwner()
	local target_t=entowner:GetEyeTrace()
	local target=target_t["Entity"]
	local target_pos=target_t["HitPos"]
	local points={}
	local dmg=33

	if target:IsWorld() or (!target:IsPlayer() and !target:IsNPC()) then

		local Sploom = ents.Create("env_explosion")
		local mag=50
		local radius =100
		Sploom:SetPos(target_pos)
		Sploom:SetOwner(attacker or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude", mag or "1")

		if radius then
			Sploom:SetKeyValue("iRadiusOverride", radius)
		end

		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode", "", 0)
	elseif target:IsPlayer() or target:IsNPC() then

		local points=FindChain(target)

		for i=1,#points do
			points[i]:TakeDamage( dmg )
		end

		for i=1,#points do
			if points[i]:IsPlayer() then
				points[i]:Freeze(true)
			end
		end
		
		timer.Simple(0.5,function ()
			for i=1,#points do
				if points[i]:IsPlayer() then
					points[i]:Freeze()
				end
			end
		end)
		


	end

end


function SWEP:spell_lightning_client()
	local entowner = self:GetOwner()

	self:EmitSound(self.ShootSound)
	
	local target_t = entowner:GetEyeTrace()
	local target=target_t["Entity"]
	local target_pos=target_t["HitPos"]
	--local t_pos = target:WorldSpaceCenter()
	local points={}
	--table.insert(points,hands)
	--table.insert(points,t_pos)
	local points_fin={}
	if target:IsWorld() or (!target:IsPlayer() and !target:IsNPC()) then
		
		local points={target_pos}
		points_fin=getpoints(entowner, points)
		
		EmitSound(self.ShootSound,points_fin[#points_fin])

		local teslaData = EffectData()
		teslaData:SetEntity(target)
		teslaData:SetMagnitude(6)
		teslaData:SetScale(5)
		teslaData:SetOrigin(target_pos)
		util.Effect("TeslaHitBoxes", teslaData)

		local spark = EffectData()
		spark:SetOrigin(target_pos)
		spark:SetMagnitude(5)
		spark:SetScale(0.1)
		spark:SetNormal(target_t.HitNormal)
		spark:SetRadius(5)

		util.Effect("Sparks", spark)
			
	elseif target:IsPlayer() or target:IsNPC() then
		local points=FindChain(target)
		local points={points[1],points[2],points[3],points[4]}
		local teslaData = EffectData()

		local points_pos={}
		for k, ply in pairs(points) do
			table.insert(points_pos, ply:WorldSpaceCenter())
			EmitSound(self.ShootSound, points_pos[k])
			teslaData:SetEntity(ply)
			teslaData:SetMagnitude(6)
			teslaData:SetScale(5)
			teslaData:SetOrigin(ply:WorldSpaceCenter())

			util.Effect("TeslaHitBoxes", teslaData)
		end


		points_fin=getpoints(entowner,points_pos)

	end

	local mat = Material("cable/blue_elec", "noclamp smooth")

	

	local ind = tostring(math.random(1000,10000))

	hook.Add( "PostDrawOpaqueRenderables", "RenderBeam"..ind, function()
		local c_t = {Color( 51, 174, 255,128),Color(255,255,255,128)}
		local c_t2 = {Color( 192, 230, 255,128),Color(255,255,255,128)}
		
		render.SetColorMaterial()

		render.StartBeam(#points_fin)
		for i=1, (#points_fin) do
			local ii=i % 2
			render.AddBeam(points_fin[i], 7, ii-1, c_t[ii])
		end
		render.EndBeam()

		render.StartBeam(#points_fin)
		for i=1, (#points_fin) do
			local ii=i % 2
			render.AddBeam(points_fin[i], 4, ii-1, c_t2[2])
		end
		render.EndBeam()

	end)
	timer.Simple( 0.2,function () hook.Remove("PostDrawOpaqueRenderables", "RenderBeam"..ind) end)

end
net.Receive("spell", function (ply)
	local entity =net.ReadEntity()
	//local entowner=entity:GetOwner()

	entity:spell_lightning_client(entowner)

end)


function getpoints(hands,points)
	local pos_hands=hands:WorldSpaceCenter()

	local step=50
	local points_pos ={}
	local points_pos2={}
	table.insert(points_pos2,pos_hands)
	for i=1,#points do
		table.insert(points_pos,points[i])
	end


	table.insert(points_pos,1,pos_hands)
	local dir, len, num_branch = {}, {},{}
	local cur_dist={}
	for i=1,#points_pos-1 do

		local vec=points_pos[i+1]-points_pos[i]

		table.insert(dir,vec:GetNormalized())
		table.insert(len,points_pos[i]:Distance(points_pos[i+1]))
		table.insert(cur_dist,50)
	end


	for i=1,#len do
		table.insert(num_branch,len[i]%step)
	end

	for i=1,#dir do
		table.insert(points_pos2, points_pos[i])
		while cur_dist[i] < len[i] do
			--local v=Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5))
			local v=Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
			local p=(points_pos[i]+dir[i]*cur_dist[i])+v
			table.insert(points_pos2, p)
			cur_dist[i] = cur_dist[i] + step
		end

	end
	table.insert(points_pos2, points_pos[#points_pos])

	return points_pos2
end


function FindChain(target)
	local function findCloser(target, chain, chain_normal)
		chain[target] = true
		table.insert(chain_normal, target)
		for k, ply in pairs(ents.FindInSphere(target:WorldSpaceCenter(), 150)) do
			if chain[ply] then continue end
			if !ply:IsPlayer() and !ply:IsNPC() then continue end
			if !iscan(target,ply) then continue end
			
			findCloser(ply, chain, chain_normal)
		end
	end

	local chain = {}
	local chain_normal = {}


	findCloser(target, chain, chain_normal)
	return chain_normal
end

function iscan(ent1,ent2)
	local pos1=ent1:WorldSpaceCenter()
	local pos2=ent2:WorldSpaceCenter()

	local rez = false
	local tr = util.TraceLine({
		start = pos1, endpos = pos2, mask = MASK_ALL, filter = ent1
	})

	if tr["Entity"]==ent2 then

		rez=true
	end

	return rez
end


