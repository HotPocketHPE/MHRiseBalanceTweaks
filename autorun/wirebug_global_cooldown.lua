
local ConfigData = require("MHRBT_config")

local function GetLocalPlayer()
    local playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    if playerManager == nil then return end
    local player = playerManager:call("findMasterPlayer")
    if player == nil then return end
    return player
end

-- Vars written to in pre method, then used to update fields in post method
local _wirebugShouldModifyTime
local _wirebugIndex
local _wirebugTime

-- TODO see if modifying value arguments on the stack is possible
local function PreSetWirebugTime(args)
    _wirebugShouldModifyTime = false
    local callingPlayer = sdk.to_managed_object(args[2])
    -- is this check needed?
    if not GetLocalPlayer():get_address() == callingPlayer:get_address() then return end

    _wirebugShouldModifyTime = true
    _wirebugIndex = sdk.to_int64(args[3])
    _wirebugTime = sdk.to_float(args[4]) * ConfigData.WirebugRechargeTimeMultiplier
    return
end

local function WriteModifiedWirebugTime()
    local wireGaugeArr = GetLocalPlayer():get_field("_HunterWireGauge")
    if wireGaugeArr == nil then return end
    local wireGaugeData = wireGaugeArr:get_element(_wirebugIndex)
    wireGaugeData:set_field("_RecastTimer", _wirebugTime)
    wireGaugeData:set_field("_RecastTimerMax", _wirebugTime)
end

local function PostSetWirebugTime(retval)
    if (_wirebugShouldModifyTime) then
        WriteModifiedWirebugTime()
    end
    _wirebugShouldModifyTime = false
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