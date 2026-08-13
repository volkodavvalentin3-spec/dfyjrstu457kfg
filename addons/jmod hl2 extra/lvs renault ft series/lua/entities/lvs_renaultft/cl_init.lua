include("shared.lua")
include("sh_tracks.lua")
include("cl_tankview.lua")
include("cl_optics.lua")
include("sh_turret.lua")

function ENT:OnSpawn( PObj )
    -- This controls which seat sees the turret optics.
    self.OpticsPodIndex = {[self.TurretSeatIndex] = true}
end