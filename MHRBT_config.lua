if _ConfigDataCache ~= nil then
    return _ConfigDataCache
end

local ConfigData = {}

ConfigData.WirebugRechargeTimeMultiplier = 3.0

_ConfigDataCache = ConfigData

return ConfigData