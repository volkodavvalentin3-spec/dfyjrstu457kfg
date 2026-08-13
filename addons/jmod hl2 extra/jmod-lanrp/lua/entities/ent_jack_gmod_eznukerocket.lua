-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Nuclear ICBM"
ENT.Spawnable = true -- temporary, until we fix the textures and drawfunc
ENT.AdminOnly = true
---
ENT.JModPreferredCarryAngles = Angle(0, 90, 0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, 90, 0)

ENT.Skin = 0

ENT.WhistleSound = "bomb/nukefly.wav"
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
end

---

if SERVER then

    local ruslan_red = Color(180, 22, 22)
    
    hook.Add("JMod_CanKitBuild", "NukeRocket", function(ply, wep, BuildInfo)
         if BuildInfo.results == "ent_jack_gmod_eznukerocket" then
            
            local squad = SquadMenu:GetSquad(ply:GetSquadID())

            if squad.YaderkaCrafted then return end

            squad.YaderkaCrafted = true

            -- тут сообщение

            timer.Simple(6, function()
                if squad then
                    for k, v in pairs(player.GetAll()) do
                        v:LanRPChatPrint(ruslan_red, "Фракция ", Color(squad.r,squad.g,squad.b), squad.name, ruslan_red, " создала ядерное оружие.")
                        v:PlayLocalSound("hoi4/NukeSpawn.wav")
                    end
                end
            end)
         end
    end)


    function ENT:SpawnFunction(ply, tr)
        local SpawnPos = tr.HitPos + tr.HitNormal * 40
        local ent = ents.Create(self.ClassName)
        ent:SetAngles(Angle(0, 0, 0))
        ent:SetPos(SpawnPos)
        JMod.SetEZowner(ent, ply)
        ent:Spawn()
        ent:Activate()
        --local effectdata=EffectData()
        --effectdata:SetEntity(ent)
        --util.Effect("propspawn",effectdata)

        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/props_ww_weapons/missile_nuke01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS, Vector( 0, 0, 23 ))
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)

        self:SetSkin(self.Skin)

        ---
        timer.Simple(.01, function()
            self:GetPhysicsObject():SetMass(500)
            self:GetPhysicsObject():Wake()
            self:GetPhysicsObject():EnableDrag(false)
        end)

        ---
        self:SetState(STATE_OFF)
        --self.NextDet = 0
        self.FuelLeft = 1000

        if istable(WireLib) then
            self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Launch"}, {"Directly detonates rocket", "Arms rocket", "Launches rocket"})
            self.Outputs = WireLib.CreateOutputs(self, {"State", "Fuel"}, {"-1 broken \n 0 off \n 1 armed \n 2 launched", "Fuel left in the tank"})
        end
    end

    function ENT:TriggerInput(iname, value)
        if iname == "Detonate" and value > 0 then
            self:Detonate()
        elseif iname == "Arm" and value > 0 then
            self:SetState(STATE_ARMED)
        elseif iname == "Arm" and value == 0 then
            self:SetState(STATE_OFF)
        elseif iname == "Launch" and value > 0 then
            self:SetState(STATE_ARMED)
            self:Launch()
        end
    end

    function ENT:PhysicsCollide(data, physobj)
        if not IsValid(self) then return end

        if data.DeltaTime > 0.2 then
            if data.Speed > 50 then
                self:EmitSound("Canister.ImpactHard")
            end

            if (self:GetState() == STATE_LAUNCHED) and data.HitEntity:GetClass() == "lvs_missile" then
                self:Break()
            end

            local DetSpd = 300
            if (data.Speed > DetSpd) and (self:GetState() == STATE_LAUNCHED) then
                self:Detonate()
                return
            end
            --
            if data.Speed > 2000 then
                self:Break()
            end
        end
    end

    function StartNuclearWar()
        for _, ply in player.Iterator() do
            ply:SendMessageOnTop("НАЧАЛАСЬ ЯДЕРНАЯ ВОЙНА", Color(120, 0, 0))
            ply:PlayLocalSound("LANRP/nuke/nuclear war.wav") 
        end

        SetGlobalVar( "NuclearWar", true)

        timer.Create("NuclearWar", 600, 1, function()
            for _, ply in player.Iterator() do
                ply:LanRPChatPrint(Color(87, 87, 255), "[Глобальное сообщение] ", Color(120, 0, 0), "Закончилась ядерная война!")
                ply:PlayLocalSound("hoi4/War_declaration_01.wav")
            end

            SetGlobalVar( "NuclearWar", false)
        end)
    end

    function ENT:Break()
        if not GetGlobalVar( "NuclearWar") and self:GetState() == STATE_LAUNCHED then
            timer.Simple(10, function()
                StartNuclearWar()
            end)
        end

        if self:GetState() == STATE_BROKEN then return end
        self:SetState(STATE_BROKEN)
        self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

        for i = 1, 20 do
            JMod.DamageSpark(self)
        end

        --[[for k = 1, 10 do
            local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
            Gas:SetPos(self:GetPos())
            JMod.SetEZowner(Gas, JMod.GetEZowner(self))
            Gas:Spawn()
            Gas:Activate()
            Gas.CurVel = VectorRand() * math.random(-100, 100)
        end]]

        self:Remove()
        --SafeRemoveEntityDelayed(self, 10)
    end

    function ENT:OnTakeDamage(dmginfo)
        if IsValid(self.DropOwner) then
            local Att = dmginfo:GetAttacker()
            if IsValid(Att) and (self.DropOwner == Att) then return end
        end

        self:TakePhysicsDamage(dmginfo)

        if JMod.LinCh(dmginfo:GetDamage(), 120, 400) then
            --if math.random(1, 3) == 1 then
                self:Break()
            --else
            --    JMod.SetEZowner(self, dmginfo:GetAttacker())
            --    self:Detonate()
            --end
        end
    end

    function ENT:JModEZremoteTriggerFunc(ply)
        if not (IsValid(ply) and ply:Alive() and (ply == self.EZowner)) then return end
        if not ((self:GetState() == STATE_LAUNCHED)) then return end
        self:Detonate()
    end

    concommand.Add( "StartNuclearWar", function( ply, cmd, args )
        if ply:IsSuperAdmin() then
            StartNuclearWar()
        end
    end)
    
    util.AddNetworkString("ChooseTarget")

    function ENT:Use(activator)
        local State = self:GetState()
        if State < 0 then return end

        local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

        if State == STATE_OFF then
            if Alt then
                --[[local squad = SquadMenu:GetSquad(activator:GetSquadID())

                if not squad then return end

                if not GetConVar("sv_cheats"):GetBool() then
                    if squad.hp >= 50 and not GetGlobalVar("NuclearWar") then 
                        activator:LanRPChatPrint(Color(255,255,255), "Мораль вашей фракции должна быть ниже ", Color(255,0,0), "50", Color(255,255,255), " единиц.") 
                        return 
                    end
                end
                ]]

                net.Start("ChooseTarget")
                net.WriteEntity(self)
                net.Send(activator)

                --[[JMod.SetEZowner(self, activator)
                self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 120)
                self:SetState(STATE_ARMED)
                self.EZlaunchableWeaponArmedTime = CurTime()
                JMod.Hint(activator, "launch")]]
            else
                --activator:PickupObject(self)
                JMod.Hint(activator, "arm")
            end
        elseif State == STATE_ARMED then
            self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 60, 120)
            self:SetState(STATE_OFF)
            JMod.SetEZowner(self, activator)
            self.EZlaunchableWeaponArmedTime = nil
        end
    end

    local function SendClientNukeEffect(pos, range)
        net.Start("JMod_NuclearBlast")
        net.WriteVector(pos)
        net.WriteFloat(range)
        net.WriteFloat(1)
        net.Broadcast()
    end

    function ENT:Detonate()  
        if self.Exploded then return end
        self.Exploded = true
        local SelfPos, Att, Power, Range = self:GetPos() + Vector(0, 0, 100), JMod.GetEZowner(self), JMod.Config.Explosives.Nuke.PowerMult, 1

		local oldselfpos = self:GetPos()
        --[[JMod.Sploom(Att,SelfPos,500)
        timer.Simple(.1, function()
            JMod.BlastDamageIgnoreWorld(SelfPos, Att, nil, 1200, 6000)
        end)]]

        ---
        SendClientNukeEffect(SelfPos, 12000)
        util.ScreenShake(SelfPos, 1000, 10, 10, 2000 * Range)
        local Eff = "pcf_jack_nuke_ground"

        if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
            Eff = "pcf_jack_nuke_air"
        end

        for i = 1, 19 do
            sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 150, math.random(80, 110))
        end

        ---
        if (JMod.Config.QoL.NukeFlashLightEnabled) then
            local NukeFlash = ents.Create("ent_jack_gmod_nukeflash")
            NukeFlash:SetPos(SelfPos + Vector(0, 0, 32))
            NukeFlash.LifeDuration = 10
            NukeFlash.MaxAltitude = 500
            NukeFlash:Spawn()
            NukeFlash:Activate()
        end

        ---
        --[[for h = 1, 30 do
            timer.Simple(h / 10, function()
                local ThermalRadiation = DamageInfo()
                ThermalRadiation:SetDamageType(DMG_BURN)
                ThermalRadiation:SetDamage(25 / h)
                ThermalRadiation:SetAttacker(Att)
                ThermalRadiation:SetInflictor(game.GetWorld())
                util.BlastDamageInfo(ThermalRadiation, SelfPos, 15000)
            end)
        end]]

        for _, ply in player.Iterator() do 
            if ply:GetPos():Distance(SelfPos + Vector(0,0, 120)) <= 15000 then
                local TraceSee = util.TraceLine( {
                    start = SelfPos,
                    endpos = ply:GetPos(),
                })

                if not TraceSee.HitWorld and not ply:IsOnFire() then
                    ply:Ignite(30)
                end
            end

            if ply:GetPos():Distance(SelfPos) <= 8000 then
                ply:GodEnable()
                ply:SetLaggedMovementValue(0.3)
                ply:StripWeapons()

                timer.Simple(4.5, function()
                    ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255 ), 2, 3 )
                end)

                timer.Simple(6, function()
                    if IsValid(ply) and ply:Alive() then
                        ply:Extinguish()
                        ply:GodDisable()
                        ply:SetLaggedMovementValue(1)

                        ply:Kill()
                    end
                end)
            end
        end

        ---
        for k, ply in player.Iterator() do
            local Dist = ply:GetPos():Distance(SelfPos)

            if Dist > 1000 then
                timer.Simple(Dist / 6000, function()
                    ply:EmitSound("snds_jack_gmod/nuke_far.ogg", 55, 100)
                    util.ScreenShake(ply:GetPos(), 1000, 10, 10, 100)
                end)
            end
        end

        ---
        for i = 1, 20 do
            timer.Simple(i / 5, function()
                SelfPos = SelfPos + Vector(0, 0, 128)
                ---
                local powa, renj = 10 + i * 2.5, 1 + i / 10

                ---
                if i == 1 then
                    JMod.EMP(SelfPos, renj * 15000)

                    for k, ent in pairs(ents.FindInSphere(SelfPos, renj)) do
                        if ent:GetClass() == "npc_helicopter" then
                            ent:Fire("selfdestruct", "", math.Rand(0, 2))
                        end
                    end
                end

                ---
				debugoverlay.Sphere( SelfPos, 250 * i, 2, Color( 255, 0, 0 ), true )
                util.BlastDamage(game.GetWorld(), Att, SelfPos, 400 * i, 6000 / i + 50)

                ---
                JMod.WreckBuildings(nil, SelfPos, powa, renj, i < 3)
                JMod.BlastDoors(nil, SelfPos, powa, renj, i < 3)
                ---
                SendClientNukeEffect(SelfPos, 2000 * renj)

                ---
                if i == 10 then
                    JMod.DecalSplosion(SelfPos + Vector(0, 0, 500) + Vector(0, 0, 1000), "GiantScorch", 8000, 40)
                end

                ---
                --[[if i == 20 then
                    for j = 1, 10 do
                        timer.Simple(j / 10, function()
                            for k = 1, 20 do
                                local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
                                Gas:SetPos(oldselfpos + Vector(math.random(-500, 500), math.random(-500, 500), math.random(-400, 0)))
                                JMod.SetEZowner(Gas, Att)
                                Gas:Spawn()
                                Gas:Activate()
                                Gas.CurVel = (Vector(math.random(-500, 500), math.random(-500, 500), math.random(-100, 0)))
                            end
                        end)
                    end
                end]]
            end)
        end

        ---
        self:Remove()

        timer.Simple(0, function()
            ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
        end)

        ---
    end

    function ENT:OnRemove()
    end
    --

    function ENT:CalculateLastPos() 
        local Grav = physenv.GetGravity() / 3
        local Vel = self:GetUp() * 2000
        local MissilePos = self:GetPos()
        local positions = {}
        
        local timeStep = 1
        local maxIterations = 5000
        
        for i = 1, maxIterations do
            Vel = Vel + Grav * timeStep
            
            local newPos = MissilePos + Vel * timeStep
            
            local trace = util.TraceLine({
                start = MissilePos,
                endpos = newPos,
                filter = self
            })
            
            if trace.Hit then
                break
            end
            
            MissilePos = newPos
        end
    
        return MissilePos 
    end

    function ENT:CalculateRocketPosition()
        local Grav = physenv.GetGravity() / 3
        local startPos = self:GetPos()
        local positions = {}

        local targetPos = self.TargetPos
        
        local delta = targetPos - startPos
        local horizontalDist = Vector(delta.x, delta.y, 0):Length()
        local heightDiff = delta.z
        
        local peakHeight = 5000 
        
        local timeToTarget = math.sqrt(2 * peakHeight / Grav:Length()) * 2
        local horizontalSpeed = horizontalDist / timeToTarget
        local verticalSpeed = math.sqrt(2 * Grav:Length() * peakHeight)
        
        local Vel = Vector(
            delta.x / horizontalDist * horizontalSpeed,
            delta.y / horizontalDist * horizontalSpeed,
            verticalSpeed
        )

        local timeStep = 0.1
        local maxIterations = 5000
        local MissilePos = startPos

        for i = 1, maxIterations do
            Vel = Vel + Grav * timeStep
            local newPos = MissilePos + Vel * timeStep

            local trace = util.TraceLine({
                start = MissilePos,
                endpos = newPos,
                filter = self,
                mask = MASK_SOLID_BRUSHONLY
            })

            positions[#positions + 1] = MissilePos

            if trace.Hit then
                positions[#positions + 1] = trace.HitPos
                break
            end

            MissilePos = newPos
            
            if (newPos - startPos):Length() > horizontalDist * 1.5 and newPos.z < targetPos.z then
                break
            end
        end

        return positions
    end

    local ruslan_red = Color(180, 22, 22)

    util.AddNetworkString("DrawRocketPos")

    function ENT:Launch()
        local squad = SquadMenu:GetSquad(JMod.GetEZowner(self):GetSquadID())

        if not squad then return end

        if self:GetRenderMode() == RENDERMODE_NONE then
            JMod.GetEZowner(self):LanRPChatPrint(Color(255,0,0), "Ошибка: ", Color(255,255,255), "Ракета должна быть распакована!")
            return
        end

        if not GetConVar("sv_cheats"):GetBool() and not GetGlobalVar("NuclearWar") then
            if not JMod.GetEZowner(self):IsSuperAdmin() and table.Count(squad.membersById) < 3 then
                JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "Ваша фракция слишком немощна, чтобы запускать ядерные ракеты.") 
                return 
            end

            if table.Count(squad.SquadsInWar) <= 0 then
                JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,0), "В мирное время нельзя запускать ракеты.") 
                return 
            end

            if not squad.Defenders and squad.hp > 50 then 
                JMod.GetEZowner(self):LanRPChatPrint(Color(255,255,255), "Мораль вашей фракции должна быть ниже ", Color(255,0,0), "50", Color(255,255,255), " единиц.") 
                return 
            end

            if squad.Defenders then
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
                    return 
                end
            end
        end
        
        if squad.Defenders then
            timer.Simple(10, function()
                if squad then
                    squad.Defenders = false
                end  
            end)
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

        --[[timer.Simple(0, function()
            local predictedPath = self:CalculateRocketPosition()

            net.Start("DrawRocketPos")
            net.WriteTable(predictedPath)
            net.Send(JMod.GetEZowner(self))

            --JMod.GetEZowner(self):SetPos(self:CalculateLastPos())
        end)]]
        
        --[[timer.Simple(2, function()

            for _, pos in ipairs(predictedPath) do
                debugoverlay.Axis( pos, Angle(0,0,0), 100, 5, true )
            end
        end)]]

        --JMod.GetEZowner(self):SetPos(self:CalculateLastPos()) 

        JMod.Hint(JMod.GetEZowner(self), "backblast", self:GetPos())
        --------------
        
        if squad.YaderkaLaunched == nil then
            squad.YaderkaLaunched = CurTime()
        end

        if squad and squad.YaderkaLaunched <= CurTime() then
            for k, v in pairs(player.GetAll()) do
                v:LanRPChatPrint(ruslan_red, "Фракция ", Color(squad.r,squad.g,squad.b), squad.name, ruslan_red, " запустила ракеты!")
                v:PlayLocalSound("hoi4/NukeLaunch.wav")

                local random = math.random(1, 100)
                if random <= 15 then
                    timer.Simple(3, function()
                        v:LanRPChatPrint(ruslan_red, "Нам всем конец...")
                    end)
                end
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

        if not GetGlobalVar( "NuclearWar") then
            timer.Simple(5, function()
                StartNuclearWar()
            end)
        end
    end

    function ENT:OnRemove()
        --[[if not GetGlobalVar( "NuclearWar") and self:GetState() == STATE_LAUNCHED then
            timer.Simple(10, function()
                StartNuclearWar()
            end)
        end]]
    end

    function ENT:UpdateTransmitState()
        if self:GetState() == STATE_LAUNCHED then
            return TRANSMIT_ALWAYS
        else
            return TRANSMIT_PVS
        end
	end

    function ENT:EZdetonateOverride(detonator)
        self:Detonate()
    end

    function ENT:Think()
        if istable(WireLib) then
            WireLib.TriggerOutput(self, "State", self:GetState())
            WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
        end
        local ThrustDir = -self:GetUp()

        local Phys = self:GetPhysicsObject()
        --JMod.AeroDrag(self, -ThrustDir, .75)

        if self:GetState() == STATE_LAUNCHED then

            if self.Path != nil then

                local AimDir
                local Dir

                if not self.InSky then
                    if self:GetPos():Distance(self.SkyPos) <= 500 then

                        if self.Path[self.NextPos] == nil then self:SetState(STATE_OFF) return end

                        self.SkyPos = LerpVector(FrameTime(), self.SkyPos, self.Path[self.NextPos])
                        
                        if self:GetPos():Distance(self.SkyPos) <= 50 then
                            self.InSky = true
                        end
                    end
    
                    AimDir = (self.SkyPos - self:GetPos()):Angle() + Angle(90,0,0)
                    Dir = (self.SkyPos - self:GetPos()):GetNormalized()
                else  

                    if self.Path[self.NextPos] == nil then
                        self:Detonate()
                        return 
                    else
                        if self:GetPos():Distance(self.Path[self.NextPos]) <= 500 then
                            self.NextPos = self.NextPos + 1
                        end
        
                        AimDir = (self.Path[self.NextPos] - self:GetPos()):Angle() + Angle(90,0,0)
                        Dir = (self.Path[self.NextPos] - self:GetPos()):GetNormalized()
                    end   
                end 

                Phys:SetVelocity(Dir * 1000)
                self:SetAngles(LerpAngle(FrameTime() * 3, self:GetAngles(), AimDir))
                --self:SetAngles(AimDir)
            end
        end

        self:NextThink(CurTime() + .05)

        return true
    end

    net.Receive("ChooseTarget", function( len, ply )
        local ent = net.ReadEntity()
        local TargetPos = net.ReadVector()

        ent.TargetPos = TargetPos

        local CheckPath = ent:CalculateRocketPosition()

        if CheckPath[50] == nil then
            ply:LanRPChatPrint(Color(255,0,0), "Ошибка: ", Color(255,255,255), "Ракета не смогла расчитать маневр!") 
            return
        end

        JMod.SetEZowner(ent, ply)
        ent.squad = ply:GetSquadID()
        ent:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 120)
        ent:SetState(STATE_ARMED)
        ent.EZlaunchableWeaponArmedTime = CurTime()
        JMod.Hint(ply, "launch")
    end)
elseif CLIENT then

    net.Receive("DrawRocketPos", function()
        local predictedPath = net.ReadTable()

        for _, pos in ipairs(predictedPath) do
            debugoverlay.Axis( pos, Angle(0,0,0), 100, 0.5, true )
        end
    end)

    net.Receive("ChooseTarget", function( len )
        local ent = net.ReadEntity()

        local frame = vgui.Create("DFrame")
        frame:SetTitle("Установка цели для ракеты")
        frame:SetSize(300, 200)
        frame:Center()
        frame:MakePopup()

        local xLabel = vgui.Create("DLabel", frame)
        xLabel:SetText("X координата:")
        xLabel:SetPos(20, 40)
        xLabel:SizeToContents()

        local xEntry = vgui.Create("DTextEntry", frame)
        xEntry:SetPos(120, 40)
        xEntry:SetSize(150, 20)
        --xEntry:SetText(0)

        local yLabel = vgui.Create("DLabel", frame)
        yLabel:SetText("Y координата:")
        yLabel:SetPos(20, 70)
        yLabel:SizeToContents()

        local yEntry = vgui.Create("DTextEntry", frame)
        yEntry:SetPos(120, 70)
        yEntry:SetSize(150, 20)
        --yEntry:SetText(tostring(0))

        local setButton = vgui.Create("DButton", frame)
        setButton:SetText("Установить цель")
        setButton:SetPos(20, 140)
        setButton:SetSize(260, 50)
        setButton.DoClick = function()
            local x = tonumber(xEntry:GetValue() * 100) or ent:GetPos().x
            local y = tonumber(yEntry:GetValue() * 100) or ent:GetPos().x

            local tr = util.TraceLine( {
                start = ent:GetPos(),
                endpos = ent:GetPos() - Vector(0,0,10000),
            } )

            local z = tr.HitPos.z

            ent.TargetPos = Vector(x, y, z)
            --LocalPlayer():ChatPrint("Цель установлена на: " .. tostring(ent.TargetPos))

            net.Start("ChooseTarget")
            net.WriteEntity(ent)
            net.WriteVector(ent.TargetPos)
            net.SendToServer()

            frame:Close()
        end
    end)
    
    function ENT:Initialize()
        self.snd = CreateSound(self, self.WhistleSound)
		self.snd:SetSoundLevel( 120 )
		self.snd:PlayEx(0,250)

        self.snd2 = CreateSound(self, "gunsounds/rpg_rocket_loop.wav")
        self.snd2:SetSoundLevel( 120 )
        self.snd2:PlayEx(0,250)
    end
    --
    local GlowSprite = Material("mat_jack_gmod_glowsprite")
    local Trefoil = Material("png_jack_gmod_radiation.png")

    function ENT:Draw()
        local Pos, Ang, Dir = self:GetPos(), self:GetAngles(), -self:GetUp()
        self:DrawModel()

        if self:GetState() == STATE_LAUNCHED then
            self.BurnoutTime = self.BurnoutTime or CurTime() + 2

            if self.BurnoutTime > CurTime() then
                render.SetMaterial(GlowSprite)

                for i = 1, 10 do
                    local Inv = 10 - i
                    render.DrawSprite(Pos + Dir * (i * 10 + math.random(100, 130)), 8 * Inv, 8 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
                end

                local dlight = DynamicLight(self:EntIndex())

                if dlight then
                    dlight.pos = Pos + Dir * 130
                    dlight.r = 255
                    dlight.g = 175
                    dlight.b = 100
                    dlight.brightness = 2
                    dlight.Decay = 200
                    dlight.Size = 400
                    dlight.DieTime = CurTime() + .5
                end
            end
        end
    end

    function ENT:CalcDoppler()
		local MAX_DISTANCE = 10000  -- Максимальное расстояние для эффекта
        local MIN_PITCH = 0.5       -- Минимальная высота звука
        local MAX_PITCH = 5.0       -- Максимальная высота звука
        local BASE_PITCH = 1     -- Базовая высота звука

        local listener = LocalPlayer()
        
        local sourcePos = self:GetPos()
        local listenerPos = listener:GetPos()
        local distance = sourcePos:Distance(listenerPos)
        
        local distanceFactor = math.Clamp(distance / MAX_DISTANCE, 0, 1)
        
        local sourceVel = self:GetVelocity()
        local listenerVel = listener:GetVelocity()
        local relativeVel = sourceVel - listenerVel
        
        local dirToListener = (listenerPos - sourcePos):GetNormalized()
        local velDot = relativeVel:Dot(dirToListener)
        

        local dopplerFactor = 1 + (velDot / 1000)
        local distancePitch = BASE_PITCH * (1 - distanceFactor * 0.5) 
        
        local finalPitch = math.Clamp(distancePitch * dopplerFactor, MIN_PITCH, MAX_PITCH)
        
        return finalPitch
	end
	--

	function ENT:Think()
		if self.snd and self:GetState() == STATE_LAUNCHED then
			self.snd:ChangePitch(100 * self:CalcDoppler(), 1 )
			self.snd:ChangeVolume(math.Clamp((self:GetVelocity():LengthSqr() - 150000) / 5000,0,1), 2)
		end

        if self.snd2 and self:GetState() == STATE_LAUNCHED then
			self.snd2:ChangePitch(100 * self:CalcDoppler(), 1 )
			self.snd2:ChangeVolume(math.Clamp((self:GetVelocity():LengthSqr() - 150000) / 100000,0,1), 2)
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

	function ENT:OnRemove()
		if self.snd then
			self.snd:Stop()
		end

        if self.snd2 then
			self.snd2:Stop()
		end

        NukeEnts[self] = nil

        --[[if IsValid(self.Part) then
            self.Part:Remove()
        end]]
	end

    NukeEnts = {}

    local GlowSprite = Material("sprites/mat_jack_basicglow")
	local GlowSprite2 = Material("particle/fire")
	local HotGlowSprite = Material("particles/fire_glow")

	local hdrMat = Material("particle/particle_glow_02")
	local HDRcolor = Color(0,0,0,160)

    hook.Add( "HUDPaint", "NukeRender", function()
		if NukeEnts != nil then
			for ent, v in pairs(NukeEnts) do
				if ent == nil then continue end
				if not IsValid(ent) then NukeEnts[ent] = nil continue end

				local data2D = ent:GetPos():ToScreen()

				if not data2D.visible then continue end

				local pos = Vector(data2D.x, data2D.y, data2D.z)

				local tr = util.TraceLine( {
					start = ent:GetPos(),
					endpos = EyePos(),
					filter = {LocalPlayer(), ent, ent.LVS},
				} )

				if tr.Hit then continue end  

				local EyeVec = EyePos() - pos
				local Dist = EyeVec:Length()
				local SpriteSize = math.Clamp(Dist / 500, 100, 500)
				local offset = 50


				--if render.GetHDREnabled() then
					surface.SetMaterial( hdrMat )
					surface.SetDrawColor( HDRcolor )
					surface.DrawTexturedRect( data2D.x - 50, data2D.y - 50, SpriteSize, SpriteSize )
				--end

				surface.SetMaterial( GlowSprite )
				surface.SetDrawColor( Color(255,255,255, math.Rand(200,255)) )
				surface.DrawTexturedRect( data2D.x - offset, data2D.y - offset, SpriteSize, SpriteSize )

				surface.SetMaterial( HotGlowSprite )
				surface.SetDrawColor( color_white )
				surface.DrawTexturedRect( data2D.x - (offset / 1.5), data2D.y - (offset / 1.5), SpriteSize / 1.5, SpriteSize / 1.5)
			end
		end
	end)
    


    language.Add("ent_jack_gmod_eznukerocket", "EZ Nuke Rocket")
end
