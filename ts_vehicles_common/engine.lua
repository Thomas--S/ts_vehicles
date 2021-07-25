ts_vehicles_common.register_engine_compatibility = function(vehicle)
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gasoline_engine_4_cylinders", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gasoline_engine_6_cylinders", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:gasoline_engine_8_cylinders", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:hydrogen_engine_small", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:hydrogen_engine_medium", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:hydrogen_engine_large", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:electric_engine_small", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:electric_engine_medium", {})
    ts_vehicles.register_compatibility(vehicle, "ts_vehicles_common:electric_engine_large", {})
end

ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_4_cylinders", {
    description = "Gasoline Engine (4 cylinders)",
    inventory_image = "ts_vehicles_common_gasoline_engine_4_cylinders.png",
    after_part_add = function(self, item)
        self._data.engine_power = 20
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    gasoline_consumption = 0.1,
})

ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_6_cylinders", {
    description = "Gasoline Engine (6 cylinders)",
    inventory_image = "ts_vehicles_common_gasoline_engine_6_cylinders.png",
    after_part_add = function(self, item)
        self._data.engine_power = 25
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    gasoline_consumption = 0.1125,
})

ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_8_cylinders", {
    description = "Gasoline Engine (8 cylinders)",
    inventory_image = "ts_vehicles_common_gasoline_engine_8_cylinders.png",
    after_part_add = function(self, item)
        self._data.engine_power = 30
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    gasoline_consumption = 0.125,
})

ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_small", {
    description = "Hydrogen Engine (small)",
    inventory_image = "ts_vehicles_common_hydrogen_engine_small.png",
    after_part_add = function(self, item)
        self._data.engine_power = 20
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    hydrogen_consumption = 0.7,
})

ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_medium", {
    description = "Hydrogen Engine (medium)",
    inventory_image = "ts_vehicles_common_hydrogen_engine_medium.png",
    after_part_add = function(self, item)
        self._data.engine_power = 25
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    hydrogen_consumption = 0.7875,
})

ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_large", {
    description = "Hydrogen Engine (large)",
    inventory_image = "ts_vehicles_common_hydrogen_engine_large.png",
    after_part_add = function(self, item)
        self._data.engine_power = 30
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    hydrogen_consumption = 0.875,
})

ts_vehicles.register_part("ts_vehicles_common:electric_engine_small", {
    description = "Electric Engine (small)",
    inventory_image = "ts_vehicles_common_electric_engine_small.png",
    after_part_add = function(self, item)
        self._data.engine_power = 20
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    electricity_consumption = 1.4,
})

ts_vehicles.register_part("ts_vehicles_common:electric_engine_medium", {
    description = "Electric Engine (medium)",
    inventory_image = "ts_vehicles_common_electric_engine_medium.png",
    after_part_add = function(self, item)
        self._data.engine_power = 25
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    electricity_consumption = 1.575,
})

ts_vehicles.register_part("ts_vehicles_common:electric_engine_large", {
    description = "Electric Engine (large)",
    inventory_image = "ts_vehicles_common_electric_engine_large.png",
    after_part_add = function(self, item)
        self._data.engine_power = 30
    end,
    after_part_remove = function(self, drop)
        self._data.engine_power = 0
    end,
    groups = { engine = 1, },
    electricity_consumption = 1.75,
})