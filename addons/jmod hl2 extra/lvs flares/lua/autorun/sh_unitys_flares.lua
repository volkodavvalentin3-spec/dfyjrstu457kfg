UF = UF or {}
UF.Flares = {}

UF.IsFlareVehicleConfigurationInitialized = false
--- This table contains configuration for vehicles that require a flare setup
UF.FlareVehicleConfigurations = {}

function UF:RegisterFlare(flare)
    table.insert(self.Flares, flare)
end

function UF:UnRegisterFlare(flare)
    table.RemoveByValue(self.Flares, flare)
end

function UF:GetFlares()
    return self.Flares or {}
end

function UF:RegisterFlareVehicleConfiguration(class, ejectPositions, seat, totalFlares, burstAmount)
    class = string.Trim(class or "")

    if (class == "") then error("Invalid Flare Vehicle Configuration: No vehicle class") end
    if (not istable(ejectPositions)) then error("Invalid Flare Vehicle Configuration: No eject positions") end

    UF.FlareVehicleConfigurations[class] = {
        seat = seat or 1,
        totalFlares = totalFlares or 16,
        burstAmount = burstAmount or 5,
        ejectPositions = ejectPositions
    }
end


local function CreateFlare(ent, flareTable)
    local pos = ent:LocalToWorld(flareTable.pos)
    local dir = isfunction(flareTable.dir) and flareTable.dir(ent) or Vector()
    local dirMulti = flareTable.dirMulti or 0

    local veh = ent:GetVehicle()
    local projectile = ents.Create("unity_flare")
    projectile:SetPos(pos)
    projectile:SetAngles(Angle())
    projectile:Spawn()
    projectile:Activate()
    projectile:SetEntityFilter(ent:GetCrosshairFilterEnts())
    local offsetDir = Vector(dir)
    offsetDir:Rotate(Angle(0,90,0))
    projectile:GetPhysicsObject():SetVelocity(veh:GetVelocity() + veh:GetRight() * math.random(-100,100) + dir * dirMulti)
end

local function CreateFlareWeapon(veh, configuration)
    local ejectPositions = configuration.ejectPositions
    local burstAmount = configuration.burstAmount
    local flares = configuration.totalFlares

    if (SERVER) then
        veh.SNDFlare = veh:AddSoundEmitter(Vector(0,0,0), "unitys_flares/flare_deploy_ext.mp3", "unitys_flares/flare_deploy_ext.mp3")
        veh.SNDFlare:SetSoundLevel(110)

        veh.SNDFlareInterface = veh:AddSoundEmitter(Vector(0,0,0), nil, "unitys_flares/flare_deploy_int.mp3")
        veh.SNDFlareInterface:SetSoundLevel(160)

        veh.SNDAlarm = veh:AddSoundEmitter(Vector(0,0,0), nil, "unitys_flares/laserlock.mp3")
        veh.SNDAlarm:SetSoundLevel(110)

        function veh:OnLaserLock(locking)
            if (self:GetAI() and not self.HasLaserLock and locking) then
                timer.Simple(math.random(0,5), function ()
                    if (IsValid(self)) then
                        self.FlareSystem.Attack(self)
                    end
                end)
            end
            self.HasLaserLock = locking

            if (not locking or self.NextLaserLockSound > CurTime()) then return end
            self.NextLaserLockSound = CurTime() + 0.2
            self.SNDAlarm:PlayOnce( 100, 1 )
        end
    end

    local flareSystem = {}
    flareSystem.Icon = Material("unitys_flares/flares.png")
    flareSystem.Ammo = flares * burstAmount
    flareSystem.Delay = 2
    flareSystem.HeatRateUp = 0
    flareSystem.HeatRateDown = 0
    flareSystem.UseableByAI = false
    flareSystem.Attack = function(ent)
        if (not IsValid(ent:GetVehicle())) then return end
        local vehicle = ent:GetVehicle()

        vehicle.SNDFlareInterface:PlayOnce( 100 + math.Rand(-3,3), 1 )
        timer.Create("timer_flares" .. tostring(ent) .. math.random(0,10000), 0.1, burstAmount, function ()
            if (not IsValid(ent) or not IsValid(ent:GetVehicle())) then return end

            for i, v in ipairs(ejectPositions or {}) do
                CreateFlare(vehicle, v)
                vehicle.SNDFlare:PlayOnce(100 + math.Rand(-3,3), 1)

                ent:TakeAmmo()
            end
        end)
    end
    flareSystem.OnSelect = function(ent )
        ent:EmitSound("physics/metal/weapon_impact_soft3.wav")
    end
    flareSystem.OnOverheat = function(ent )
        ent:EmitSound("lvs/overheat.wav")
    end
    veh.FlareSystem = flareSystem

    return flareSystem
end

local function GetVehicleConfiguration(class)
    if (not UF.IsFlareVehicleConfigurationInitialized) then hook.Run("LoadFlareConfiguration", UF) end

    return UF.FlareVehicleConfigurations[class]
end

hook.Add("PreRegisterSENT", "UnitysFlares.SetupFlareWeapons", function (ent, class)
    local configuration = GetVehicleConfiguration(class)
    if (not configuration) then return end

    ent.OldInitWeapons = ent.InitWeapons
    ent.NextLaserLockSound = 0

    ent.InitWeapons = function (self)
        if (isfunction(ent.OldInitWeapons)) then
            self:OldInitWeapons()
        end

        self:AddWeapon(CreateFlareWeapon(self, configuration), configuration.seat)
    end
end)

UF.CONST = {}
UF.CONST.BACKWARDS = function (veh) return veh:GetForward() * -1 end
UF.CONST.RIGHT = function (veh) return veh:GetRight() end
UF.CONST.LEFT = function (veh) return veh:GetRight() * -1 end
hook.Add("LoadFlareConfiguration", "UnitysFlares.SetupStarWarsFlareConfiguration", function ()
    UF:RegisterFlareVehicleConfiguration("lvs_starfighter_arc170",
            {
                {
                    pos = Vector(-41, 0, -50),
                    dir = UF.CONST.BACKWARDS,
                    dirMulti = 1000,
                },
            },
            2
    )

    UF:RegisterFlareVehicleConfiguration("lvs_repulsorlift_gunship",
            {
                {
                    pos = Vector(-435, 31, 194),
                    dir = UF.CONST.BACKWARDS,
                },
                {
                    pos = Vector(-435, -31, 194),
                    dir = UF.CONST.BACKWARDS,
                },
                {
                    pos = Vector(-410.12, 51, 184),
                    dir = UF.CONST.LEFT,
                    dirMulti = 1000
                },
                {
                    pos = Vector(-410.12, -51, 184),
                    dir = UF.CONST.RIGHT,
                    dirMulti = 1000
                },
            },
            2,
            24
    )

    UF:RegisterFlareVehicleConfiguration("lvs_repulsorlift_dropship",
            {
                {
                    pos = Vector(-435, 31, 194),
                    dir = UF.CONST.BACKWARDS,
                },
                {
                    pos = Vector(-435, -31, 194),
                    dir = UF.CONST.BACKWARDS,
                },
                {
                    pos = Vector(-410.12, 51, 184),
                    dir = UF.CONST.LEFT,
                    dirMulti = 1000
                },
                {
                    pos = Vector(-410.12, -51, 184),
                    dir = UF.CONST.RIGHT,
                    dirMulti = 1000
                },
            },
            2,
        24
    )
end)

hook.Add("LoadFlareConfiguration", "UnitysFlares.SetupHelicoptersFlareConfiguration", function ()
    UF:RegisterFlareVehicleConfiguration("lvs_helicopter_combine",
            {
                {
                    pos = Vector(-95.54, -1.86, -3.59),
                    dir = UF.CONST.BACKWARDS,
                    dirMulti = 1000,
                },
            }
    )

    --[[UF:RegisterFlareVehicleConfiguration("lvs_helicopter_rebel",
            {
                {
                    pos = Vector(-136, 59, -17),
                    dir = UF.CONST.LEFT,
                    dirMulti = 1000,
                },
                {
                    pos = Vector(-136, -59, -17),
                    dir = UF.CONST.RIGHT,
                    dirMulti = 1000,
                },
            },
            0, -- Which seat should control the flares. Default 0.
            16, -- The total times the flares can be used. Default 16.
            2 -- The amount of individual flares that should be deployed per burst. Default 5.       
    )]]
end)
