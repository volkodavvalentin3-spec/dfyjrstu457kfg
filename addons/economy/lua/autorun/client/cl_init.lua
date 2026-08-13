include("autorun/server/economic_init.lua")
include("graph.lua")
include("derma.lua")
include("cl_warehouse.lua")

concommand.Add("jmod_ez_econ", function()
    DrawDerma()
end) 