minetest.register_craftitem("ts_vehicles_common:universal_key", {
    description = "Universal Key for Vehicles (Staff only)",
    inventory_image = "ts_vehicles_common_universal_key.png",
})

minetest.register_craft({
    output = "ts_vehicles_common:universal_key",
    type = "shapeless",
    recipe = { "ts_vehicles_common:composite_material", "default:skeleton_key" },
})

ts_vehicles_common.register_restricted_item("ts_vehicles_common:universal_key")

minetest.register_tool("ts_vehicles_common:lifting_jack", {
    description = "Lifting Jack for Vehicles",
    inventory_image = "ts_vehicles_common_lifting_jack.png",
    on_use = function(itemstack, player, pointed_thing)
        if pointed_thing.type == "object" then
            local object = pointed_thing.ref
            if object and object.get_luaentity and object:get_luaentity() and object:get_luaentity().name and ts_vehicles.registered_vehicle_bases[object:get_luaentity().name] then
                if ts_vehicles.helpers.is_owner(object:get_luaentity()._id, player:get_player_name()) then
                    object:move_to(vector.add(object:get_pos(), vector.new(0, 1.1, 0)))
                    itemstack:add_wear(1000)
                end
            end
        end
        return itemstack
    end
})

minetest.register_craft({
    output = "ts_vehicles_common:lifting_jack",
    recipe = {
        { "ts_vehicles_common:composite_material", "dye:orange", "basic_materials:steel_bar" },
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    },
})