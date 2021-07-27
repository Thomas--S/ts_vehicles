ts_vehicles = {}
ts_vehicles.priv = minetest.settings:get("ts_vehicles.priv") or "ban"
ts_vehicles.mod_storage = minetest.get_mod_storage()

ts_vehicles.writing = minetest.global_exists("font_api")

local modpath = minetest.get_modpath("ts_vehicles_api")

dofile(modpath.."/helpers.lua")
dofile(modpath.."/hose.lua")
dofile(modpath.."/storage.lua")
dofile(modpath.."/posture.lua")
dofile(modpath.."/light.lua")
dofile(modpath.."/formspec.lua")
dofile(modpath.."/passengers.lua")
dofile(modpath.."/hud.lua")
dofile(modpath.."/handlers.lua")
dofile(modpath.."/textures.lua")
dofile(modpath.."/movement.lua")
dofile(modpath.."/registration.lua")