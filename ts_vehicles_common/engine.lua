-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles_common.register_engine_compatibility = function(vehicle)
    ts_vehicles_common.register_gasoline_engines()
    ts_vehicles_common.register_hydrogen_engines()
    ts_vehicles_common.register_electric_engines()
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

local gasoline_engines_registered = false
ts_vehicles_common.register_gasoline_engines = function()
    if gasoline_engines_registered then
        return
    end
    gasoline_engines_registered = true

    ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_4_cylinders", {
        description = "Gasoline Engine (4 cylinders)",
        inventory_image = "ts_vehicles_common_gasoline_engine_4_cylinders.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 20
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        gasoline_consumption = 0.1,
    })

    ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_6_cylinders", {
        description = "Gasoline Engine (6 cylinders)",
        inventory_image = "ts_vehicles_common_gasoline_engine_6_cylinders.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 25
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        gasoline_consumption = 0.1125,
    })

    ts_vehicles.register_part("ts_vehicles_common:gasoline_engine_8_cylinders", {
        description = "Gasoline Engine (8 cylinders)",
        inventory_image = "ts_vehicles_common_gasoline_engine_8_cylinders.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 30
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        gasoline_consumption = 0.125,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gasoline_engine_4_cylinders",
        recipe = {
            { "basic_materials:ic", "ts_vehicles_common:composite_material", "techage:ta3_pipeS" },
            { "basic_materials:steel_bar", "default:steelblock", "basic_materials:gear_steel" },
            { "default:mese_crystal", "ts_vehicles_common:composite_material", "default:mese_crystal" },
        },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gasoline_engine_6_cylinders",
        type = "shapeless",
        recipe = { "ts_vehicles_common:gasoline_engine_4_cylinders", "ts_vehicles_common:gasoline_engine_4_cylinders" },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:gasoline_engine_8_cylinders",
        type = "shapeless",
        recipe = { "ts_vehicles_common:gasoline_engine_6_cylinders", "ts_vehicles_common:gasoline_engine_6_cylinders" },
    })
end

local hydrogen_engines_registered = false
ts_vehicles_common.register_hydrogen_engines = function()
    if hydrogen_engines_registered then
        return
    end
    hydrogen_engines_registered = true

    ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_small", {
        description = "Hydrogen Engine (small)",
        inventory_image = "ts_vehicles_common_hydrogen_engine_small.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 20
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        hydrogen_consumption = 0.7,
    })

    ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_medium", {
        description = "Hydrogen Engine (medium)",
        inventory_image = "ts_vehicles_common_hydrogen_engine_medium.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 25
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        hydrogen_consumption = 0.7875,
    })

    ts_vehicles.register_part("ts_vehicles_common:hydrogen_engine_large", {
        description = "Hydrogen Engine (large)",
        inventory_image = "ts_vehicles_common_hydrogen_engine_large.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 30
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        hydrogen_consumption = 0.875,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:hydrogen_engine_small",
        recipe = {
            { "basic_materials:ic", "ts_vehicles_common:composite_material", "techage:ta3_pipeS" },
            { "basic_materials:steel_bar", "techage:ta4_fuelcellstack", "basic_materials:gear_steel" },
            { "default:mese_crystal", "ts_vehicles_common:composite_material", "default:mese_crystal" },
        },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:hydrogen_engine_medium",
        type = "shapeless",
        recipe = { "ts_vehicles_common:hydrogen_engine_small", "ts_vehicles_common:hydrogen_engine_small" },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:hydrogen_engine_large",
        type = "shapeless",
        recipe = { "ts_vehicles_common:hydrogen_engine_medium", "ts_vehicles_common:hydrogen_engine_medium" },
    })
end

local electric_engines_registered = false
ts_vehicles_common.register_electric_engines = function()
    if electric_engines_registered then
        return
    end
    electric_engines_registered = true

    ts_vehicles.register_part("ts_vehicles_common:electric_engine_small", {
        description = "Electric Engine (small)",
        inventory_image = "ts_vehicles_common_electric_engine_small.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 20
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        electricity_consumption = 1.4,
    })

    ts_vehicles.register_part("ts_vehicles_common:electric_engine_medium", {
        description = "Electric Engine (medium)",
        inventory_image = "ts_vehicles_common_electric_engine_medium.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 25
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        electricity_consumption = 1.575,
    })

    ts_vehicles.register_part("ts_vehicles_common:electric_engine_large", {
        description = "Electric Engine (large)",
        inventory_image = "ts_vehicles_common_electric_engine_large.png",
        after_part_add = function(self, item)
            VD(self._id).data.engine_power = 30
        end,
        after_part_remove = function(self, drop)
            VD(self._id).data.engine_power = 0
        end,
        groups = { engine = 1, },
        electricity_consumption = 1.75,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:electric_engine_small",
        recipe = {
            { "basic_materials:ic", "ts_vehicles_common:composite_material", "techage:electric_cableS" },
            { "basic_materials:steel_bar", "basic_materials:motor", "basic_materials:gear_steel" },
            { "default:mese_crystal", "ts_vehicles_common:composite_material", "default:mese_crystal" },
        },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:electric_engine_medium",
        type = "shapeless",
        recipe = { "ts_vehicles_common:electric_engine_small", "ts_vehicles_common:electric_engine_small" },
    })

    minetest.register_craft({
        output = "ts_vehicles_common:electric_engine_large",
        type = "shapeless",
        recipe = { "ts_vehicles_common:electric_engine_medium", "ts_vehicles_common:electric_engine_medium" },
    })
end
