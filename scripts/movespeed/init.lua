
-- requesting "movespeed/api" will automatically call this.
-- if you do not request the api at init, you should at least request this.

local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath

require(path .."movespeed/hooks")