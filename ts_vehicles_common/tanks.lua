ts_vehicles_common.register_tank_compatibility = function(vehicle)
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gasoline_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:hydrogen_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:battery", {})
end

ts_vehicles_common.register_aux_tank_compatibility = function(vehicle)
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_gasoline_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_hydrogen_tank", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:auxiliary_battery", {})
end

ts_vehicles.register_part("ts_vehicles_common:gasoline_tank", {
    inventory_image = "ts_vehicles_common_gasoline_tank.png",
    description = "Gasoline Tank",
    gasoline_capacity = 70,
    groups = { main_tank = 1, }
})

ts_vehicles.register_part("ts_vehicles_common:hydrogen_tank", {
    inventory_image = "ts_vehicles_common_hydrogen_tank.png",
    description = "Hydrogen Tank",
    hydrogen_capacity = 500,
    groups = { main_tank = 1, }
})

ts_vehicles.register_part("ts_vehicles_common:battery", {
    inventory_image = "ts_vehicles_common_battery.png",
    description = "Battery",
    electricity_capacity = 1000,
    groups = { main_tank = 1, }
})