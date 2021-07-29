ts_vehicles_common = {}

local modpath = minetest.get_modpath("ts_vehicles_common")

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