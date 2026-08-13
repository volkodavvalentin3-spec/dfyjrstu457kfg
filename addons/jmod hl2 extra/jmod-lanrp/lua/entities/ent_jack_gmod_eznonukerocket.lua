AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Base = "ent_jack_gmod_eznukerocket"
ENT.PrintName = "EZ Tactical ICBM"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.Skin = 1

ENT.WhistleSound = "gunsounds/rpg_rocket_loop.wav"
---

local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

local ruslan_red = Color(180, 22, 22)

function ENT:Launch()
    local squad = SquadMenu:GetSquad(JMod.GetEZowner(self):GetSquadID())

    if not squad then return end

    if self:GetRenderMode() == RENDERMODE_NONE then
        JMod.GetEZowner(self):LanRPChatPrint(Color(255,0,0), "Ошибка: ", Color(255,255,255), "Ракета должна быть распакована!")
        return
    end

    if JMod.GetEZowner(self):GetSquadID() == -1 then
        JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "У вас нету фракции, чтобы запускать ракеты.") 
        return 
    end

    if not JMod.GetEZowner(self):IsSuperAdmin() and table.Count(squad.membersById) < 3 then
        JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "Ваша фракция слишком немощна, чтобы запускать ракеты.") 
 --       return 
    end

    if table.Count(squad.SquadsInWar) <= 0 then
        JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "В мирное время нельзя запускать ракеты.") 
        return 
    else
        local BigFaction = false

        for k,v in pairs(squad.SquadsInWar) do
            local warsquad = SquadMenu:GetSquad(k)
        
            if table.Count(warsquad.membersById) >= 3 then 
                BigFaction = true 
                break 
            end
        end
    
        if not BigFaction then
            JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "Фракция врага слишком немощна, чтобы запускать ядерные ракеты.") 
  --          return 
        end
    end

    local rocketUp = self:GetUp()

    local worldUp = Vector(0, 0, 1)

    local angle = math.deg(math.acos(rocketUp:Dot(worldUp)))

    if angle > 15 then
        JMod.GetEZowner(self):LanRPChatPrint(Color(255,0,0), "Ошибка: ", Color(255,255,255), "Ракета должна быть направлена вертикально для запуска!") 
        
        return
    end
    
    if self:GetState() ~= STATE_ARMED then return end
    self:SetState(STATE_LAUNCHED)
    local Phys = self:GetPhysicsObject()
    constraint.RemoveAll(self)
    Phys:EnableMotion(true)
    Phys:Wake()

    self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )

    Phys:ApplyForceCenter(self:GetUp() * 20000)
    Phys:SetAngleDragCoefficient( 1000 )

    self.SkyPos = self:GetPos() + Vector(0,0,3000)

    self.NextPos = 50
    self.Path = self:CalculateRocketPosition()
    ---

    self:EmitSound("snds_jack_gmod/rocket_launch.ogg", 80, math.random(60, 80))
    self:GetPhysicsObject():SetMass(40)

    ---
    for i = 1, 4 do
        util.BlastDamage(self, JMod.GetEZowner(self), self:GetPos() + -self:GetUp() * i * 40, 50, 50)
    end

    util.ScreenShake(self:GetPos(), 20, 255, .5, 300)

    JMod.Hint(JMod.GetEZowner(self), "backblast", self:GetPos())
    --------------
    
    if squad.YaderkaLaunched == nil then
        squad.YaderkaLaunched = CurTime()
    end

    if squad and squad.YaderkaLaunched <= CurTime() then
        for k, v in pairs(player.GetAll()) do
            v:LanRPChatPrint(ruslan_red, "Фракция ", Color(squad.r,squad.g,squad.b), squad.name, ruslan_red, " запустила ракеты!")
            v:PlayLocalSound("hoi4/NukeLaunch.wav")
        end

        squad.YaderkaLaunched = CurTime() + 60
    end

    for _, ply in player.Iterator() do
        if ply:GetPos():Distance(self:GetPos()) >= 10000 then
            timer.Simple(0.5, function()
                if IsValid(ply) then
                    ply:PlayLocalSound("LANRP/nuke/missile_launch_far_0" .. math.random(1,2) .. ".ogg")
                end
            end)
        else
            ply:PlayLocalSound("LANRP/nuke/missile_launch_map_0" .. math.random(1,2) .. ".ogg")
        end
    end
end

function ENT:Break()
    if self:GetState() == STATE_BROKEN then return end
    self:SetState(STATE_BROKEN)
    self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

    for i = 1, 20 do
        JMod.DamageSpark(self)
    end

    self:Remove()
end

function ENT:Detonate()
    if self.Exploded then return end
    self.Exploded = true
    local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)

    local tr = util.TraceLine( {
		start = SelfPos,
		endpos = SelfPos + Vector(0,0,-300),
		filter = self
	} )

    local SelfPos = tr.HitPos

    util.ScreenShake(SelfPos, 1000, 3, 2, 4000)
    local Eff = "500lb_ground"

    if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
        Eff = "500lb_air"
    else
        for i = 1, 100 do
            local Eff2 = EffectData()
            Eff2:SetOrigin(SelfPos)
            util.Effect("battlefieldsmoke", Eff2)
        end
    end

    for i = 1, 3 do
        sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
    end

    if math.random(1,2) == 1 then
        EmitFarSound(self:GetPos(), math.random(179,181), 1000, 1500, 2000, 0)
    else
        EmitFarSound(self:GetPos(), math.random(183,186), 1000, 1500, 2000, 0)
    end

    for _, ent in pairs( ents.FindInSphere( self:GetPos(), 2500 ) ) do
        if ent:IsPlayer() and ply ~= ent then
            ent:SetCrazy(ent:GetCrazy() + math.Rand(0.1,0.2))

            if math.random(1,3) == 1 then
                ent:CrazyEffect()
            end

        end
    end

    util.BlastDamage(self, Att, SelfPos + Vector(0, 0, 300), 800, 600)

    for k, ent in pairs(ents.FindInSphere(SelfPos, 500)) do
        if ent:GetClass() == "npc_helicopter" then
            ent:Fire("selfdestruct", "", math.Rand(0, 2))
        end
    end

    JMod.WreckBuildings(self, SelfPos, 7)
    JMod.BlastDoors(self, SelfPos, 7)

    timer.Simple(.2, function()
        local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

        if Tr.Hit then
            util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
        end
    end)

    self:Remove()

    timer.Simple(.1, function()
        ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
    end)
end

if CLIENT then
    function ENT:Think()
		if self.snd and self:GetState() == STATE_LAUNCHED then
			self.snd:ChangePitch(50 * self:CalcDoppler(), 1 )
			self.snd:ChangeVolume(math.Clamp((self:GetVelocity():LengthSqr() - 150000) / 100000,0,1), 2)
		end

        if self:GetState() == STATE_LAUNCHED and not IsValid(self.Part) then
            if IsValid(self.Part) then
                self.Part:StartEmission( true )
            else
                self.Part = CreateParticleSystem( self, "generic_smoke_infinite", PATTACH_POINT_FOLLOW )
            end
        end

        if self:GetState() == STATE_LAUNCHED then
            NukeEnts[self] = true
        end

	end
end