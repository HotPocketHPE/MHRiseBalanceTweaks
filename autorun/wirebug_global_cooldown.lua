
local ConfigData = require("MHRBT_config")

local function GetLocalPlayer()
    local playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    if playerManager == nil then return end
    local player = playerManager:call("findMasterPlayer")
    if player == nil then return end
    return player
end

local function PreSetWirebugTime(args)

    local callingPlayer = sdk.to_managed_object(args[2])
    -- is this check needed?
    if GetLocalPlayer():get_address() ~= callingPlayer:get_address() then return end

    local wirebugNewTime = sdk.to_float(args[4]) * ConfigData.WirebugRechargeTimeMultiplier
    args[4] = sdk.float_to_ptr(_wirebugTime)
    return
end

local function PostSetWirebugTime(retval)
    return retval
end

local function HookSetWirebugTime()
    local playerBaseTypedef = sdk.find_type_definition("snow.player.PlayerBase")
    if playerBaseTypedef == nil then
        log.error("Wirebug time hook failed! Couldn't find snow.player.PlayerBase typedef")
        return
    end

    local wirebugCastMethod = playerBaseTypedef:get_method("useHunterWireGauge")
    if wirebugCastMethod == nil then
        log.error("Wirebug time hook failed! Couldn't find useHunterWireGauge method def")
        return
    end

    sdk.hook(wirebugCastMethod, PreSetWirebugTime, PostSetWirebugTime)
end

HookSetWirebugTime()