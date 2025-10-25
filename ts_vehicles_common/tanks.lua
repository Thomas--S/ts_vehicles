ts_vehicles_common.register_tank_compatibility = function(vehicle)
    ts_vehicles_common.register_gasoline_tank()
    ts_vehicles_common.register_hydrogen_tank()
    ts_vehicles_common.register_battery()
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gasoline_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:hydrogen_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:battery", {})
end

ts_vehicles_common.register_aux_tank_compatibility = function(vehicle)
    ts_vehicles_common.register_auxiliary_gasoline_tank()
    ts_vehicles_common.register_auxiliary_hydrogen_tank()
    ts_vehicles_common.register_auxiliary_battery()
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_gasoline_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_hydrogen_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_battery", {})
end

local gasoline_tank_registered = false
ts_vehicles_common.register_gasoline_tank = function()
    if gasoline_tank_registered then
        return
    end
    gasoline_tank_registered = true

    ts_vehicles.register_part("ts_vehicles_common:gasoline_tank", {
        inventory_image = "ts_vehicles_common_gasoline_tank.png",
        description = "Gasoline Tank",
        gasoline_capacity = 70,
        groups = { main_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gasoline_tank",
        recipe = {
            { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
            { "techage:ta3_pipeS", "", "ts_vehicles_common:composite_material" },
            { "ts_vehicles_common:composite_material", "techage:ta3_pipeS", "ts_vehicles_common:composite_material" },
        },
    })
end

local hydrogen_tank_registered = false
ts_vehicles_common.register_hydrogen_tank = function()
    if hydrogen_tank_registered then
        return
    end
    hydrogen_tank_registered = true

    ts_vehicles.register_part("ts_vehicles_common:hydrogen_tank", {
        inventory_image = "ts_vehicles_common_hydrogen_tank.png",
        description = "Hydrogen Tank",
        hydrogen_capacity = 500,
        groups = { main_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:hydrogen_tank",
        recipe = {
            { "techage:ta4_carbon_fiber", "techage:canister_epoxy", "techage:ta4_carbon_fiber" },
            { "techage:ta3_pipeS", "ts_vehicles_common:composite_material", "techage:ta3_pipeS" },
            { "techage:ta4_carbon_fiber", "techage:canister_epoxy", "techage:ta4_carbon_fiber" },
        },
        replacements = {
            { "techage:canister_epoxy", "techage:ta3_canister_empty" },
            { "techage:canister_epoxy", "techage:ta3_canister_empty" }
        }
    })
end

local battery_registered = false
ts_vehicles_common.register_battery = function()
    if battery_registered then
        return
    end
    battery_registered = true

    ts_vehicles.register_part("ts_vehicles_common:battery", {
        inventory_image = "ts_vehicles_common_battery.png",
        description = "Battery",
        electricity_capacity = 1000,
        groups = { main_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:battery",
        recipe = {
            { "default:copperblock", "default:tinblock", "ts_vehicles_common:composite_material" },
            { "ts_vehicles_common:composite_material", "default:copperblock", "default:tinblock" },
            { "default:copperblock", "default:tinblock", "ts_vehicles_common:composite_material" },
        },
    })
end

local auxiliary_gasoline_tank_registered = false
ts_vehicles_common.register_auxiliary_gasoline_tank = function()
    if auxiliary_gasoline_tank_registered then
        return
    end
    auxiliary_gasoline_tank_registered = true

    ts_vehicles.register_part("ts_vehicles_common:auxiliary_gasoline_tank", {
        inventory_image = "ts_vehicles_common_gasoline_tank.png^ts_vehicles_common_aux_overlay.png",
        description = "Auxiliary Gasoline Tank",
        storage_capacity = -4000,
        gasoline_capacity = 70,
        groups = { auxiliary_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:auxiliary_gasoline_tank",
        recipe = {
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
            { "", "ts_vehicles_common:gasoline_tank", "" },
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
        },
    })
end

local auxiliary_hydrogen_tank_registered = false
ts_vehicles_common.register_auxiliary_hydrogen_tank = function()
    if auxiliary_hydrogen_tank_registered then
        return
    end
    auxiliary_hydrogen_tank_registered = true

    ts_vehicles.register_part("ts_vehicles_common:auxiliary_hydrogen_tank", {
        inventory_image = "ts_vehicles_common_hydrogen_tank.png^ts_vehicles_common_aux_overlay.png",
        description = "Auxiliary Hydrogen Tank",
        storage_capacity = -4000,
        hydrogen_capacity = 500,
        groups = { auxiliary_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:auxiliary_hydrogen_tank",
        recipe = {
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
            { "", "ts_vehicles_common:hydrogen_tank", "" },
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
        },
    })
end

local auxiliary_battery_registered = false
ts_vehicles_common.register_auxiliary_battery = function()
    if auxiliary_battery_registered then
        return
    end
    auxiliary_battery_registered = true

    ts_vehicles.register_part("ts_vehicles_common:auxiliary_battery", {
        inventory_image = "ts_vehicles_common_battery.png^ts_vehicles_common_aux_overlay.png",
        description = "Auxiliary Battery",
        storage_capacity = -4000,
        electricity_capacity = 1000,
        groups = { auxiliary_tank = 1, }
    })

    minetest.register_craft({
        output = "ts_vehicles_common:auxiliary_battery",
        recipe = {
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
            { "", "ts_vehicles_common:battery", "" },
            { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
        },
    })
end
