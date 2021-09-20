ts_vehicles_common = {}

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

dofile(modpath.."/engine.lua")
dofile(modpath.."/tanks.lua")
dofile(modpath.."/stations.lua")

minetest.register_craftitem("ts_vehicles_common:composite_material", {
    description = "Composite Material for Vehicles",
    inventory_image = "ts_vehicles_common_composite_material.png",
})

minetest.register_craft({
    output = "ts_vehicles_common:composite_material",
    recipe = {
        {"default:steel_ingot", "techage:ta4_carbon_fiber", "basic_materials:plastic_sheet"},
        {"default:copper_ingot", "techage:canister_epoxy", "default:mese_crystal_fragment"},
        {"basic_materials:plastic_sheet", "techage:ta4_carbon_fiber", "default:steel_ingot"},
    },
    replacements = {
        {"techage:canister_epoxy", "techage:ta3_canister_empty"}
    }
})

minetest.register_craftitem(":techage:rubber_powder", {
    description = "Rubber Powder",
    inventory_image = "techage_powder_inv.png^[colorize:#a47645:120",
    groups = {powder = 1},
})

techage.recipes.add("ta4_doser", {
    output = "techage:rubber_powder 1",
    input = {
        "techage:fueloil 1",
        "techage:leave_powder 1",
    }
})

minetest.register_craftitem(":techage:vulcanized_rubber", {
    description = "Vulcanized Rubber",
    inventory_image = "techage_ceramic_material.png^[multiply:#322a24"
})

techage.furnace.register_recipe({
    time = 3,
    output = "techage:vulcanized_rubber",
    recipe = {"techage:rubber_powder"},
})

minetest.register_craftitem("ts_vehicles_common:universal_key", {
    description = "Universal Key for Vehicles (Staff only)",
    inventory_image = "ts_vehicles_common_universal_key.png",
})

minetest.register_craft({
    output = "ts_vehicles_common:universal_key",
    type = "shapeless",
    recipe = {"ts_vehicles_common:composite_material", "default:skeleton_key"},
})

ts_vehicles_common.register_restricted_item("ts_vehicles_common:universal_key")

minetest.register_tool("ts_vehicles_common:lifting_jack", {
    description = "Lifting Jack for Vehicles",
    inventory_image = "ts_vehicles_common_lifting_jack.png",
    on_use = function(itemstack, player, pointed_thing)
        if pointed_thing.type == "object" then
            local object = pointed_thing.ref
            minetest.chat_send_all(dump(object))
            if object.get_luaentity and object:get_luaentity().name and ts_vehicles.registered_vehicle_bases[object:get_luaentity().name] then
                object:move_to(vector.add(object:get_pos(), vector.new(0, 1.1, 0)))
                itemstack:add_wear(1000)
            end
        end
        return itemstack
    end
})

minetest.register_craft({
    output = "ts_vehicles_common:lifting_jack",
    recipe = {
        {"ts_vehicles_common:composite_material", "dye:orange", "basic_materials:steel_bar"},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    },
})