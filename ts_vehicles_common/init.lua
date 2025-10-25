ts_vehicles_common = {}

-- Vehicle Data
local VD = ts_vehicles.get

local modpath = minetest.get_modpath("ts_vehicles_common")

local restricted_items = {}

local craft_function = function(itemstack, player, old_craft_grid, craft_inv)
    local itemname = itemstack:get_name()
    if restricted_items[itemname] then
        local playername = player:get_player_name()
        if not minetest.check_player_privs(playername, ts_vehicles.priv) then
            minetest.chat_send_player(playername, minetest.colorize("#ff8800", "Only staff members can craft this item."))
            return ItemStack()
        end
    end
    return itemstack
end

minetest.register_on_craft(craft_function)
minetest.register_craft_predict(craft_function)

function ts_vehicles_common.register_restricted_item(itemname)
    restricted_items[itemname] = 1
    techage.register_uncraftable_items(itemname)
end

dofile(modpath .. "/engine.lua")
dofile(modpath .. "/turbine.lua")
dofile(modpath .. "/tanks.lua")
dofile(modpath .. "/stations.lua")
dofile(modpath .. "/materials.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/seat.lua")
dofile(modpath .. "/wrapping.lua")