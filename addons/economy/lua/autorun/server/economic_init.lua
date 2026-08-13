include("economic_config.lua")
include("economic.lua")
 
function AddItemsInEconomic()
    for k, v in pairs(ECONOMIC_CONFIG) do
        ECONOMIC:AddNewItem(unpack(v))
    end
end   
     
AddItemsInEconomic() 

ECONOMIC:Start()   