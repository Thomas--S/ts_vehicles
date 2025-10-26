-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.register_part("ts_vehicles_cars:base_plate", {
    description = "Car/Truck Base Plate",
    inventory_image = "ts_vehicles_cbp.png^[mask:ts_vehicles_cars_base_plate_inv_mask.png",
    groups = { base_plate = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_cars:base_plate",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:car_roof", {
    description = "Car/Truck Roof",
    inventory_image = "ts_vehicles_cars_base_plate_inv_mask.png",
    groups = { roof = 1 },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_roof",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_a", {
    description = "Car/Truck Pillar (A)",
    inventory_image = "ts_vehicles_cars_pillars_a.png",
    groups = { chassis_pillars_a = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis_pillars_a",
    recipe = {
        { "ts_vehicles_common:composite_material", "", "" },
        { "ts_vehicles_common:composite_material", "", "" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:car_interior", {
    description = "Car/Truck Interior",
    inventory_image = "ts_vehicles_cars_car_interior.png",
    groups = { interior = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_interior",
    recipe = {
        { "basic_materials:plastic_sheet", "techage:ta4_leds", "" },
        { "wool:white", "wool:white", "wool:white" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:tire", {
    description = "Tire",
    inventory_image = "ts_vehicles_ct.png",
    groups = { tires = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_cars:tire",
    recipe = {
        { "", "techage:vulcanized_rubber", "" },
        { "techage:vulcanized_rubber", "default:steel_ingot", "techage:vulcanized_rubber" },
        { "", "techage:vulcanized_rubber", "" },
    },
})

ts_vehicles_common.register_seat()
minetest.register_alias("ts_vehicles_cars:seat", "ts_vehicles_common:seat")

ts_vehicles.register_part("ts_vehicles_cars:direction_indicator", {
    description = "Direction Indicators",
    inventory_image = "ts_vehicles_cars_direction_indicators.png",
    groups = { light = 1, direction_indicator = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:direction_indicator",
    type = "shapeless",
    recipe = { "techage:simplelamp_off", "dye:orange", "ts_vehicles_common:composite_material", "xpanes:pane_flat" },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_front", {
    description = "Front Lights",
    inventory_image = "ts_vehicles_cars_lights_front.png",
    groups = { light = 1, lights_front = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_front",
    type = "shapeless",
    recipe = { "techage:simplelamp_off", "techage:simplelamp_off", "ts_vehicles_common:composite_material", "xpanes:pane_flat" },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_back", {
    description = "Back Lights",
    inventory_image = "ts_vehicles_cars_lights_back.png",
    groups = { light = 1, lights_back = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_back",
    type = "shapeless",
    recipe = { "techage:simplelamp_off", "dye:red", "ts_vehicles_common:composite_material", "xpanes:pane_flat" },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_reversing", {
    description = "Reversing Lights",
    inventory_image = "ts_vehicles_cars_lights_reversing.png",
    groups = { light = 1, lights_reversing = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_reversing",
    type = "shapeless",
    recipe = { "techage:simplelamp_off", "ts_vehicles_common:composite_material", "xpanes:pane_flat" },
})

ts_vehicles.register_part("ts_vehicles_cars:license_plate", {
    description = "License Plate",
    inventory_image = "ts_vehicles_cars_license_plate.png",
    groups = { license_plate = 1, },
    get_formspec = function(self, player)
        local vd = VD(self._id)
        local fs = ""
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[0,.25;Set text for the license plate]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        fs = fs .. "field[0,1;3,1;text;;" .. minetest.formspec_escape(vd.data.license_plate_text or "") .. "]"
        fs = fs .. "button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            local vd = VD(self._id)
            vd.data.license_plate_text = fields.text:sub(1, 15)
            vd.tmp.base_textures_set = false
        end
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.license_plate_text = "ID-" .. tostring(self._id)
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.license_plate_text = nil
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:license_plate",
    recipe = {
        { "", "dye:black", "" },
        { "dye:white", "dye:white", "dye:white" },
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
    },
})

ts_vehicles_common.register_text()
minetest.register_alias("ts_vehicles_cars:chassis_text", "ts_vehicles_common:text")
minetest.register_alias("ts_vehicles_cars:panels_text", "ts_vehicles_common:text")
minetest.register_alias("ts_vehicles_cars:tarp_text", "ts_vehicles_common:text")

ts_vehicles_common.register_wrapping()
minetest.register_alias("ts_vehicles_cars:chassis_stripe", "ts_vehicles_common:wrapping")

ts_vehicles.register_part("ts_vehicles_cars:windscreen", {
    description = "Car Windscreen",
    inventory_image = "ts_vehicles_cars_windscreen.png",
    groups = { windscreen = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_cars:windscreen",
    recipe = {
        { "", "ts_vehicles_common:composite_material", "" },
        { "xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat" },
        { "", "ts_vehicles_common:composite_material", "" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:windows", {
    description = "Car/Truck Windows (incl. Windscreen)",
    inventory_image = "ts_vehicles_cars_windows.png",
    groups = { windscreen = 1, windows = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:windows",
    type = "shapeless",
    recipe = { "ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen" },
})