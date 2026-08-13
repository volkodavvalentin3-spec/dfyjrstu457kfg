util.AddNetworkString("RagdollStartDecaying")


local ENT = FindMetaTable("Entity")


--]]==============================================================================================================================[[--

local DecaySound = {
    "LANRP/corpse/flies_single_01.ogg",
    "LANRP/corpse/flies_single_02.ogg",
    "LANRP/corpse/flies_single_03.ogg",
    "LANRP/corpse/flies_single_04.ogg",
    "LANRP/corpse/flies_single_05.ogg",
    "LANRP/corpse/flies_single_06.ogg",
    "LANRP/corpse/flies_single_07.ogg",
    "LANRP/corpse/flies_single_08.ogg",
    "LANRP/corpse/flies_single_09.ogg",
    "LANRP/corpse/flies_single_10.ogg",
    "LANRP/corpse/flies_single_11.ogg",
    "LANRP/corpse/flies_single_12.ogg",
    "LANRP/corpse/flies_single_13.ogg",
}

local HorrorAmbient = {}

local HAsounds, _ = file.Find( "sound/LANRP/ambient/*", "THIRDPARTY" )

for k,v in pairs(HAsounds) do
    table.insert(HorrorAmbient, "LANRP/ambient/" .. v)
end

function ENT:StartDecaying()
    -- self.DecaySkeleton = ents.Create("base_gmodentity")
    -- self.DecaySkeleton:SetModel("models/player/skeleton.mdl")
    -- self.DecaySkeleton:SetPos(self:GetPos())
    -- self.DecaySkeleton:SetParent(self)
    -- self.DecaySkeleton:AddEffects(EF_BONEMERGE)
    -- self.DecaySkeleton:SetNoDraw(true)

    -- local brighness = math.Rand(0.35, 0.5)
    -- self.DecaySkeleton:SetColor(Color(150*brighness, 150*brighness, 150*brighness))

    -- self.DecaySkeleton:Spawn()


    net.Start("RagdollStartDecaying")
    net.WriteEntity(self)
    net.WriteEntity(self.DecaySkeleton)
    net.Broadcast()


    if GetConVar("ragdolldecay_remove_after_decay_time"):GetBool() then
        SafeRemoveEntityDelayed(self,
            2+GetConVar("ragdolldecay_start_time"):GetFloat()
            +GetConVar("ragdolldecay_remove_after_decay_time"):GetFloat()
            +GetConVar("ragdolldecay_duration"):GetFloat()
        )
    end

    timer.Simple(15+GetConVar("ragdolldecay_duration"):GetFloat(), function()
        if IsValid(self) then
            self.DecayDelay = 0
            self.DecayDelaySound = 0 
            hook.Add( "Think", "RagdollDecay " .. self:EntIndex(), function()

                if CurTime() >= self.DecayDelaySound then

                    if math.random(1,100) <= 8 then
                        self:EmitSound(table.Random(HorrorAmbient), 75, math.random(90, 110), 1)
		            end

                    self:EmitSound(table.Random(DecaySound), 75, math.random(90, 110), 1)
                    self.DecayDelaySound = CurTime() + 1
                end

                if CurTime() < self.DecayDelay then return end	
                
                --[[if math.random(0,100) >= 10 then
                    local Gas = ents.Create("ent_jack_gmod_ezvirusparticle")
				    Gas:SetPos(self:GetPos() + Vector(0,0,15))
				    Gas:Spawn()
				    Gas:Activate()
				    Gas.CurVel = self:GetPhysicsObject():GetVelocity() + self:GetUp() 
                    Gas.Canister = self
                end]]

                local Eff = EffectData()
	            Eff:SetOrigin(self:GetPos())
	            util.Effect("virusgas", Eff)

                JMod.TryVirusInfectInRange(self, nil, 0, 0)

	            self.DecayDelay = CurTime() + 2
            end )

            self:CallOnRemove( "RagdollDecay", function( ent ) hook.Remove( "Think", "RagdollDecay " .. ent:EntIndex() ) end )
        end
    end)
end
--]]==============================================================================================================================[[--
hook.Add("CreateEntityRagdoll", "CrunchyDecay", function( ent, rag )
    if !GetConVar("ragdolldecay_enable"):GetBool() then return end

    if RagdollDecay_IsFleshMaterial[ rag:GetBoneSurfaceProp(0) ] then -- Only fleshy mfs shall decay

        timer.Simple(2+GetConVar("ragdolldecay_start_time"):GetFloat(), function()
            if !IsValid(rag) then return end
            rag:StartDecaying()
        end)
    end
end)
--]]==============================================================================================================================[[--