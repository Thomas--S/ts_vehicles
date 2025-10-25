ts_vehicles_common.register_gas_turbine_compatibility = function(vehicle)
    ts_vehicles_common.register_gas_turbine_gasoline()
    ts_vehicles_common.register_gas_turbine_hydrogen()
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gas_turbine_gasoline", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gas_turbine_hydrogen", {})
end

local gas_turbine_gasoline_registered = false
ts_vehicles_common.register_gas_turbine_gasoline = function()
    if gas_turbine_gasoline_registered then
        return
    end
    gas_turbine_gasoline_registered = true

    ts_vehicles.register_part("ts_vehicles_common:gas_turbine_gasoline", {
        description = "Gas Turbine (Gasoline)",
        inventory_image = "ts_vehicles_common_gas_turbine_gasoline.png",
        groups = { gas_turbine = 1, },
        gasoline_consumption = 0.25,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gas_turbine_gasoline",
        recipe = {
            { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
            { "techage:ta5_ceramic_turbine", "default:steelblock", "basic_materials:gear_steel" },
            { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        },
    })
end

local gas_turbine_hydrogen_registered = false
ts_vehicles_common.register_gas_turbine_hydrogen = function()
    if gas_turbine_hydrogen_registered then
        return
    end
    gas_turbine_hydrogen_registered = true

    ts_vehicles.register_part("ts_vehicles_common:gas_turbine_hydrogen", {
        description = "Gas Turbine (Hydrogen)",
        inventory_image = "ts_vehicles_common_gas_turbine_hydrogen.png",
        groups = { gas_turbine = 1, },
        hydrogen_consumption = 1.75,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gas_turbine_hydrogen",
        recipe = {
            { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
            { "techage:ta5_ceramic_turbine", "techage:ta4_fuelcellstack", "basic_materials:gear_steel" },
            { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        },
    })
end
