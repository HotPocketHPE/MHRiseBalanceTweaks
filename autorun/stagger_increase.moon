

PreHook = (args) -> return

PostHook = (retval) -> 
    log.debug("Hooked part")
    normalPartDamageMod = sdk.to_float(retval)
    return sdk.float_to_ptr(normalPartDamageMod * 50.0)


HookPartDamage = ->
    staggerMethod = sdk.find_type_definition("snow.enemy.EnemyCharacterBase")\get_method("getPartsDamageAdjustRate")
    sdk.hook(staggerMethod, PreHook, PostHook)

HookPartDamage!