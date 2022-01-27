
ConfigData = require("MHRBT_config")

GetLocalPlayer = ->
    playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
    if playerManager == nil then return
    player = playerManager\call("findMasterPlayer")
    if player == nil then return
    return player

PreSetWirebugTime = (args) ->
    callingPlayer = sdk.to_managed_object(args[2])
    -- is this check needed?
    if GetLocalPlayer!\get_address! ~= callingPlayer\get_address! then return

    wirebugNewTime = sdk.to_float(args[4]) * ConfigData.WirebugRechargeTimeMultiplier
    args[4] = sdk.float_to_ptr(wirebugNewTime)
    return

PostSetWirebugTime = (retval) -> return retval

HookSetWirebugTime = ->
    playerBaseTypedef = sdk.find_type_definition("snow.player.PlayerBase")
    if playerBaseTypedef == nil
        log.error("Wirebug time hook failed! Couldn't find snow.player.PlayerBase typedef")
        return

    wirebugCastMethod = playerBaseTypedef\get_method("useHunterWireGauge")
    if wirebugCastMethod == nil
        log.error("Wirebug time hook failed! Couldn't find useHunterWireGauge method def")
        return

    sdk.hook(wirebugCastMethod, PreSetWirebugTime, PostSetWirebugTime)

HookSetWirebugTime!