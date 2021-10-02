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
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
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
        {"", "techage:vulcanized_rubber", ""},
        {"techage:vulcanized_rubber", "default:steel_ingot", "techage:vulcanized_rubber"},
        {"", "techage:vulcanized_rubber", ""},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:seat", {
    description = "Seat",
    inventory_image = "ts_vehicles_cars_seat_inv.png",
    groups = { seats = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.seats_color = color
            vd.data.seats_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.seats_color then
            drop:get_meta():set_string("color", vd.data.seats_color)
        end
        if vd.data.seats_description then
            drop:get_meta():set_string("description", vd.data.seats_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:seat",
    recipe = {
        {"", "", "wool:white"},
        {"", "", "wool:white"},
        {"wool:white", "wool:white", "wool:white"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:direction_indicator", {
    description = "Direction Indicators",
    inventory_image = "ts_vehicles_cars_direction_indicators_inv.png",
    groups = { light = 1, direction_indicator = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:direction_indicator",
    type = "shapeless",
    recipe = {"techage:simplelamp_off", "dye:orange", "ts_vehicles_common:composite_material", "xpanes:pane_flat"},
})



ts_vehicles.register_part("ts_vehicles_cars:lights_front", {
    description = "Front Lights",
    inventory_image = "ts_vehicles_cars_lights_front_inv.png",
    groups = { light = 1, lights_front = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_front",
    type = "shapeless",
    recipe = {"techage:simplelamp_off", "techage:simplelamp_off", "ts_vehicles_common:composite_material", "xpanes:pane_flat"},
})



ts_vehicles.register_part("ts_vehicles_cars:lights_back", {
    description = "Back Lights",
    inventory_image = "ts_vehicles_cars_lights_back_inv.png",
    groups = { light = 1, lights_back = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_back",
    type = "shapeless",
    recipe = {"techage:simplelamp_off", "dye:red", "ts_vehicles_common:composite_material", "xpanes:pane_flat"},
})



ts_vehicles.register_part("ts_vehicles_cars:lights_reversing", {
    description = "Reversing Lights",
    inventory_image = "ts_vehicles_cars_lights_reversing_inv.png",
    groups = { light = 1, lights_reversing = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:lights_reversing",
    type = "shapeless",
    recipe = {"techage:simplelamp_off", "ts_vehicles_common:composite_material", "xpanes:pane_flat"},
})



ts_vehicles.register_part("ts_vehicles_cars:license_plate", {
    description = "License Plate",
    inventory_image = "ts_vehicles_cars_license_plate_inv.png",
    groups = { license_plate = 1, },
    get_formspec = function(self, player)
        local vd = VD(self._id)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the license plate]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."field[0,1;3,1;text;;"..minetest.formspec_escape(vd.data.license_plate_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            local vd = VD(self._id)
            vd.data.license_plate_text = fields.text
            vd.tmp.base_textures_set = false
        end
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.license_plate_text = "ID-"..tostring(self._id)
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.license_plate_text = nil
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:license_plate",
    recipe = {
        {"", "dye:black", ""},
        {"dye:white", "dye:white", "dye:white"},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:chassis_text", {
    description = "Text on car chassis/truck cabin",
    inventory_image = "ts_vehicles_cars_chassis_text_inv.png",
    groups = { chassis_accessory = 1, cabin_accessory = 1 },
    colorable = true,
    default_color = "#000",
    get_formspec = function(self, player)
        local vd = VD(self._id)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the chassis]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."textarea[0,1;3,1;text;;"..minetest.formspec_escape(vd.data.chassis_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            local vd = VD(self._id)
            vd.data.chassis_text = fields.text
            vd.tmp.base_textures_set = false
        end
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.chassis_text = "Placeholder Text"
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            vd.data.chassis_text_color = color
            vd.data.chassis_text_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.chassis_text = nil
        if vd.data.chassis_text_color then
            drop:get_meta():set_string("color", vd.data.chassis_text_color)
        end
        if vd.data.chassis_text_description then
            drop:get_meta():set_string("description", vd.data.chassis_text_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:chassis_text",
    recipe = {
        {"", "dye:black", ""},
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:chassis_stripe", {
    description = "Stripe on car chassis/truck cabin",
    inventory_image = "ts_vehicles_css.png",
    groups = { chassis_accessory = 1, cabin_accessory = 1 },
    colorable = true,
    default_color = "#fff",
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.chassis_stripe_color = color
            vd.data.chassis_stripe_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.chassis_stripe_color then
            drop:get_meta():set_string("color", vd.data.chassis_stripe_color)
        end
        if vd.data.chassis_stripe_description then
            drop:get_meta():set_string("description", vd.data.chassis_stripe_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:chassis_stripe",
    recipe = {
        {"dye:white", "dye:white", "dye:white"},
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:windscreen", {
    description = "Car Windscreen",
    inventory_image = "ts_vehicles_cars_windscreen.png",
    groups = { windscreen = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_cars:windscreen",
    recipe = {
        {"", "ts_vehicles_common:composite_material", ""},
        {"xpanes:pane_flat", "xpanes:pane_flat", "xpanes:pane_flat"},
        {"", "ts_vehicles_common:composite_material", ""},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:windows", {
    description = "Car/Truck Windows (incl. Windscreen)",
    inventory_image = "ts_vehicles_cars_windows.png",
    groups = { windscreen = 1, windows = 1},
})

minetest.register_craft({
    output = "ts_vehicles_cars:windows",
    type = "shapeless",
    recipe = {"ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen", "ts_vehicles_cars:windscreen"},
})