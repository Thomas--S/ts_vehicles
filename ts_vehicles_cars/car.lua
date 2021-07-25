local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_cars:car", {
    inventory_image = "ts_vehicles_cars_construction_stand_inv.png",
    description = "Car",
    item_description = "Car Construction Stand",
    collisionbox = {-1.375, -0.5, -1.25, 1.375, 1.5, 1.375},
    selectionbox = {-1.375, -0.5, -1.25, 1.375, 1.5, 1.375},
    mesh = "ts_vehicles_cars_car.obj",
    -- The names are intentional; the mapping to the actual textures should happen in API,
    -- according to the get_texture functions of the registered compatibilities.
    textures = {
        "base_plate",
        "tires",
        "front",
        "back",
        "side",
        "interior",
        "seats",
        "pillars_a",
        "pillars_bc",
        "glass",
        "roof",
        "roof_attachment"
    },
    on_step = ts_vehicles.car_on_step,
    initial_parts = {},
    driver_pos = { x = -5, y = 2, z = 4 },
    passenger_pos = {
        { x = 5, y = 2, z = 4 },
        { x = -5, y = 2, z = -9.125 },
        { x = 5, y = 2, z = -9.125 },
    },
    get_fallback_textures = function(self)
        return {
            tires = "ts_vehicles_cars_construction_stand.png"
        }
    end,
    is_driveable = function(self)
        local has = function(group) return ts_vehicles.helpers.any_has_group(self._parts, group) end
        if not has("base_plate") then return false, "A car needs a base plate." end
        if not has("tires") then return false, "A car needs a tires." end
        if not (has("chassis_front") and has("chassis_back") and has("doors")) then
            return false, "A car needs a chassis (incl. doors)."
        end
        if not has("windscreen") then return false, "A car needs a windscreen." end
        if not has("interior") then return false, "A car needs an interior." end
        if not has("seats") then return false, "A car needs seats." end
        if not has("direction_indicator") then return false, "A car needs direction indicators." end
        if not has("lights_front") then return false, "A car needs front lights." end
        if not has("lights_back") then return false, "A car needs back lights." end
        if not has("lights_reversing") then return false, "A car needs reversing lights." end
        if not has("engine") then return false, "A car needs an engine." end
        if not has("main_tank") then return false, "A car needs a tank or battery." end
        return true
    end,
    is_structure_sound = function(self, parts)
        parts = parts or self._parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        local has_multiple = function(group) return ts_vehicles.helpers.multiple_have_group(parts, group) end
        if has_multiple("base_plate") then
            return false, "A car cannot have multiple base plates."
        end
        if has("tires") and not has("base_plate") then
            return false, "A base plate is required to mount the tires."
        end
        if has_multiple("tires") then
            return false, "A car cannot have multiple sets of tires."
        end
        if (has("chassis_front") or has("chassis_back")) and not has("base_plate") then
            return false, "A base plate is required to mount the chassis."
        end
        if has_multiple("chassis_front") or has_multiple("chassis_back") then
            return false, "A car cannot have multiple chassis."
        end
        if has("doors") and not (has("chassis_front") and has("chassis_back")) then
            return false, "A chassis is required to mount the doors."
        end
        if has_multiple("doors") then
            return false, "A car cannot have multiple sets of doors."
        end
        if (has("chassis_pillars_a") or has("chassis_pillars_b") or has("chassis_pillars_c"))
            and not (has("chassis_front") and has("chassis_back") and has("doors"))
        then
            return false, "A full chassis (incl. doors) is required to mount the pillars."
        end
        if has_multiple("chassis_pillars_a") or has_multiple("chassis_pillars_b") or has_multiple("chassis_pillars_c") then
            return false, "A car cannot have multiple pairs of the same pillars."
        end
        if has("windscreen") and not has("chassis_pillars_a") then
            return false, "Pillars (A) are required to mount the windscreen."
        end
        if has_multiple("windscreen") then
            return false, "A car cannot have multiple windscreens."
        end
        if has("windows") and not (has("chassis_pillars_a") and has("chassis_pillars_b") and has("chassis_pillars_c")) then
            return false, "Pillars (A, B and C) are required to mount the windows."
        end
        if has_multiple("windows") then
            return false, "A car cannot have multiple sets of windows."
        end
        if has("roof") and not (has("chassis_pillars_a") and has("chassis_pillars_b") and has("chassis_pillars_c")) then
            return false, "Pillars (A, B and C) are required to mount the roof."
        end
        if has_multiple("roof") then
            return false, "A car cannot have multiple roofs."
        end
        if has("interior") and not (has("chassis_front") and has("chassis_back") and has("doors")) then
            return false, "A full chassis (incl. doors) is required to mount the interior."
        end
        if has_multiple("interior") then
            return false, "A car cannot have multiple interiors."
        end
        if has("seats") and not has("base_plate") then
            return false, "A base plate is required to mount the seats."
        end
        if has_multiple("seats") then
            return false, "A car cannot have multiple sets of seats."
        end
        if has("light") and not (has("chassis_front") and has("chassis_back") and has("doors")) then
            return false, "A full chassis (incl. doors) is required to mount lights."
        end
        if has_multiple("lights_front") or has_multiple("lights_back") or has_multiple("lights_reversing") or has_multiple("direction_indicator") then
            return false, "A car cannot have multiple lights of the same type."
        end
        if has("license_plate") and not (has("chassis_front") and has("chassis_back")) then
            return false, "A full chassis is required to mount the license plates."
        end
        if has_multiple("license_plate") then
            return false, "A car cannot have multiple license plates."
        end
        if has("chassis_accessory") and not (has("chassis_front") and has("chassis_back") and has("doors")) then
            return false, "A full chassis (incl. doors) is required to mount accessories."
        end
        if has("roof_attachment") and not has("roof") then
            return false, "A roof is required to mount a roof top attachment."
        end
        if has_multiple("roof_attachment") then
            return false, "A car cannot have multiple roof top attachments."
        end
        if has("engine") and not has("chassis_front") then
            return false, "A chassis is required to mount the engine."
        end
        if has_multiple("engine") then
            return false, "A car cannot have multiple engines."
        end
        if has("main_tank") and not (has("chassis_front") and has("chassis_back")) then
            return false, "A full chassis is required to mount this tank or battery."
        end
        if has_multiple("main_tank") then
            return false, "A car cannot have multiple tanks or batteries."
        end
        if ts_vehicles.helpers.get_total_value(self, "storage_capacity", parts) < ts_vehicles.storage.get_total_count(self) then
            return false, "Not enough space."
        end
        if ts_vehicles.helpers.get_total_value(self, "gasoline_capacity", parts) < (self._data.gasoline or 0) then
            return false, "Not enough gasoline capacity."
        end
        if ts_vehicles.helpers.get_total_value(self, "hydrogen_capacity", parts) < (self._data.hydrogen or 0) then
            return false, "Not enough hydrogen capacity."
        end
        return true
    end,

    can_remove_part = function(self, part_name)
        if not ts_vehicles.helpers.contains(self._parts, part_name) then
            return false, "Part does not exist on vehicle!"
        end

        local def = ts_vehicles.registered_vehicle_bases[self.name]
        local parts_copy = table.copy(self._parts)
        table.remove(parts_copy, ts_vehicles.helpers.index_of(parts_copy, part_name))
        local is_structure_sound, reason = def.is_structure_sound(self, parts_copy)
        if not is_structure_sound then
            return false, reason
        end
        return true, nil
    end,

    get_part_drop = function(self, part_name)
        if not ts_vehicles.helpers.contains(self._parts, part_name) then
            return nil
        end

        local part_def = ts_vehicles.registered_parts[part_name]
        if part_def and part_def.groups then
            if part_def.groups.tires or part_def.groups.seats then
                return ItemStack(part_name.." 4")
            end
        end
        return ItemStack(part_name)
    end,

    can_add_part = function(self, item)
        local def = ts_vehicles.registered_vehicle_bases[self.name]
        local part_name = item:get_name()
        local parts_copy = table.copy(self._parts)
        table.insert(parts_copy, part_name)
        local is_structure_sound, reason = def.is_structure_sound(self, parts_copy)
        if not is_structure_sound then
            return false, reason
        end
        local part_def = ts_vehicles.registered_parts[part_name]
        if part_def and part_def.groups then
            if part_def.groups.tires or part_def.groups.seats then
                if item:get_count() < 4 then
                    return false, "Not enough items; 4 are required."
                end
                item:take_item(4)
                return true, nil, item
            end
        end
        item:take_item()
        return true, nil, item
    end,

    gasoline_hose_offset = vector.new(1.3, .45, -1.7),
    hydrogen_hose_offset = vector.new(1.3, .45, -1.7),
    electricity_hose_offset = vector.new(1.3, .45, -1.7),
})

-- TODO Move to another file

ts_vehicles.register_part("ts_vehicles_cars:base_plate", {
    description = "Car Base Plate",
    inventory_image = "ts_vehicles_cars_base_plate.png^[mask:ts_vehicles_cars_base_plate_inv_mask.png",
    groups = { base_plate = 1, },
})

ts_vehicles.register_part("ts_vehicles_cars:tires", {
    description = "Tires",
    inventory_image = "ts_vehicles_cars_tire.png",
    groups = { tires = 1, },
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis", {
    description = "Car Chassis",
    inventory_image = "ts_vehicles_cars_car_chassis_inv.png",
    storage_capacity = 5000,
    groups = { chassis_front = 1, doors = 1, chassis_back = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.chassis_color = color
            self._data.chassis_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.chassis_color then
            drop:get_meta():set_string("color", self._data.chassis_color)
        end
        if self._data.chassis_description then
            drop:get_meta():set_string("description", self._data.chassis_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_a", {
    description = "Car Pillar (A)",
    inventory_image = "ts_vehicles_cars_pillars_a_inv.png",
    groups = { chassis_pillars_a = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.pillars_a_color = color
            self._data.pillars_a_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.pillars_a_color then
            drop:get_meta():set_string("color", self._data.pillars_a_color)
        end
        if self._data.pillars_a_description then
            drop:get_meta():set_string("description", self._data.pillars_a_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_bc", {
    description = "Car Pillar (B/C)",
    inventory_image = "ts_vehicles_cars_pillars_bc_inv.png",
    groups = { chassis_pillars_b = 1, chassis_pillars_c = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.pillars_bc_color = color
            self._data.pillars_bc_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.pillars_bc_color then
            drop:get_meta():set_string("color", self._data.pillars_bc_color)
        end
        if self._data.pillars_bc_description then
            drop:get_meta():set_string("description", self._data.pillars_bc_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:windscreen", {
    description = "Car Windscreen",
    inventory_image = "ts_vehicles_cars_windscreen.png",
    groups = { windscreen = 1, },
})

ts_vehicles.register_part("ts_vehicles_cars:car_windows", {
    description = "Car Windows",
    inventory_image = "ts_vehicles_cars_windows.png",
    groups = { windscreen = 1, windows = 1},
})

ts_vehicles.register_part("ts_vehicles_cars:car_roof", {
    description = "Car Roof",
    inventory_image = "ts_vehicles_cars_base_plate_inv_mask.png",
    groups = { roof = 1},
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.roof_color = color
            self._data.roof_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.roof_color then
            drop:get_meta():set_string("color", self._data.roof_color)
        end
        if self._data.roof_description then
            drop:get_meta():set_string("description", self._data.roof_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:car_interior", {
    description = "Car Interior",
    inventory_image = "ts_vehicles_cars_car_interior_inv.png",
    groups = { interior = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.interior_color = color
            self._data.interior_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.interior_color then
            drop:get_meta():set_string("color", self._data.interior_color)
        end
        if self._data.interior_description then
            drop:get_meta():set_string("description", self._data.interior_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:car_seats", {
    description = "Seats",
    inventory_image = "ts_vehicles_cars_seat_inv.png",
    groups = { seats = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.seats_color = color
            self._data.seats_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.seats_color then
            drop:get_meta():set_string("color", self._data.seats_color)
        end
        if self._data.seats_description then
            drop:get_meta():set_string("description", self._data.seats_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:direction_indicator", {
    description = "Direction Indicators",
    inventory_image = "ts_vehicles_cars_direction_indicators_inv.png",
    groups = { light = 1, direction_indicator = 1 },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_front", {
    description = "Front Lights",
    inventory_image = "ts_vehicles_cars_light_front_inv.png",
    groups = { light = 1, lights_front = 1 },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_back", {
    description = "Back Lights",
    inventory_image = "ts_vehicles_cars_light_back_inv.png",
    groups = { light = 1, lights_back = 1 },
})

ts_vehicles.register_part("ts_vehicles_cars:lights_reversing", {
    description = "Reversing Lights",
    inventory_image = "ts_vehicles_cars_light_reversing_inv.png",
    groups = { light = 1, lights_reversing = 1 },
})

local lightbar_colors = {blue = "Blue", amber = "Amber"}
for color, desc in pairs(lightbar_colors) do
    ts_vehicles.register_part("ts_vehicles_cars:"..color.."_light", {
        description = desc.." Light",
        inventory_image = "ts_vehicles_cars_"..color.."_light_on.png^[mask:ts_vehicles_cars_roof_attachment_inv_mask.png",
        groups = { roof_attachment = 1, },
        get_formspec = function(self, player)
            local fs = ""
            fs = fs.."style_type[label;font_size=*2]"
            fs = fs.."style_type[label;font=bold]"
            fs = fs.."label[0,.25;Set text for the information matrix on the light bar]"
            fs = fs.."style_type[label;font_size=*1]"
            fs = fs.."style_type[label;font=normal]"
            fs = fs.."field[0,1;3,1;text;;"..minetest.formspec_escape(self._data.roof_top_text or "").."]"
            fs = fs.."button[3,1;1.5,1;set;Set]"
            return fs
        end,
        on_receive_fields = function(self, player, fields)
            if fields.text and (fields.set or fields.key_enter_field == "text") then
                self._data.roof_top_text = fields.text
            end
        end,
        after_part_remove = function(self, drop)
            self._data.roof_top_text = nil
        end,
    })
end

ts_vehicles.register_part("ts_vehicles_cars:license_plate", {
    description = "License Plate",
    inventory_image = "ts_vehicles_cars_license_plate_inv.png",
    groups = { license_plate = 1, },
    get_formspec = function(self, player)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the license plate]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."field[0,1;3,1;text;;"..minetest.formspec_escape(self._data.license_plate_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            self._data.license_plate_text = fields.text
        end
    end,
    after_part_add = function(self, item)
        self._data.license_plate_text = "ID-"..tostring(self._id)
    end,
    after_part_remove = function(self, drop)
        self._data.license_plate_text = nil
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:chassis_text", {
    description = "Text on chassis",
    inventory_image = "ts_vehicles_cars_chassis_text_inv.png",
    groups = { chassis_accessory = 1, },
    colorable = true,
    default_color = "#000",
    get_formspec = function(self, player)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the chassis]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."field[0,1;3,1;text;;"..minetest.formspec_escape(self._data.chassis_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            self._data.chassis_text = fields.text
        end
    end,
    after_part_add = function(self, item)
        self._data.chassis_text = "Placeholder Text"
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.chassis_text_color = color
            self._data.chassis_text_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        self._data.chassis_text = nil
        if self._data.chassis_text_color then
            drop:get_meta():set_string("color", self._data.chassis_text_color)
        end
        if self._data.chassis_text_description then
            drop:get_meta():set_string("description", self._data.chassis_text_description)
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_cars:chassis_stripe", {
    description = "Stripe on chassis",
    inventory_image = "ts_vehicles_cars_car_chassis_stripe_side.png",
    groups = { chassis_accessory = 1, },
    colorable = true,
    default_color = "#fff",
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            self._data.chassis_stripe_color = color
            self._data.chassis_stripe_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        if self._data.chassis_stripe_color then
            drop:get_meta():set_string("color", self._data.chassis_stripe_color)
        end
        if self._data.chassis_stripe_description then
            drop:get_meta():set_string("description", self._data.chassis_stripe_description)
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:tires", {
    get_textures = function(self)
        return {
            tires = "ts_vehicles_cars_tire.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:base_plate", {
    get_textures = function(self)
        return {
            base_plate = "ts_vehicles_cars_base_plate.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.chassis_color then
            color = self._data.chassis_color
        end
        return {
            front = "ts_vehicles_cars_car_front.png^[multiply:"..color.."^ts_vehicles_cars_car_front_overlay.png",
            back = "ts_vehicles_cars_car_back.png^[multiply:"..color,
            side = "ts_vehicles_cars_car_side.png^[multiply:"..color,
        }
    end,
    get_fallback_textures = function(self)
        local color = "#fff"
        if self._data.chassis_color then
            color = self._data.chassis_color
        end
        return {
            interior = "ts_vehicles_cars_car_interior_chassis.png^[multiply:"..color
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_a", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.pillars_a_color then
            color = self._data.pillars_a_color
        end
        return {
            pillars_a = "ts_vehicles_cars_car_pillar.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_bc", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.pillars_bc_color then
            color = self._data.pillars_bc_color
        end
        return {
            pillars_bc = "ts_vehicles_cars_car_pillar.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:windscreen", {
    get_textures = function(self)
        return {
            glass = "ts_vehicles_cars_car_windscreen.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_windows", {
    get_textures = function(self)
        return {
            glass = "ts_vehicles_cars_car_windows.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_roof", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.roof_color then
            color = self._data.roof_color
        end
        return {
            roof = "ts_vehicles_cars_car_roof.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_interior", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.interior_color then
            color = self._data.interior_color
        end
        return {
            interior = "ts_vehicles_cars_car_interior.png^[multiply:"..color.."^ts_vehicles_cars_car_interior_overlay.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_seats", {
    get_textures = function(self)
        local color = "#fff"
        if self._data.seats_color then
            color = self._data.seats_color
        end
        return {
            seats = "wool_white.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:direction_indicator", {
    get_overlay_textures = function(self)
        local front_left = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#000:25)"
        local front_right = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#000:25^[transformFX)"
        local back_left = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#000:25)"
        local back_right = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#000:25^[transformFX)"
        local interior = {}
        if self and self._even_step then
            if self._lights.left or self._lights.warn then
                front_left = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#fff:25)"
                back_left = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#fff:25)"
                interior[#interior+1] = "ts_vehicles_cars_car_interior_directional_left.png"
            end
            if self._lights.right or self._lights.warn then
                front_right = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#fff:25^[transformFX)"
                back_right = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#fff:25^[transformFX)"
                interior[#interior+1] = "ts_vehicles_cars_car_interior_directional_right.png"
            end
        end
        local result = {
            front = front_left.."^"..front_right,
            back = back_left.."^"..back_right,
        }
        if #interior > 0 then
            result.interior = table.concat(interior, "^")
        end
        return result
    end,

    get_light_overlay_textures = function(self)
        local front = {}
        local back = {}
        local result = {}
        if self and self._even_step then
            if self._lights.left or self._lights.warn then
                front[#front+1] = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#fff:25)"
                back[#back+1] = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#fff:25)"
            end
            if self._lights.right or self._lights.warn then
                front[#front+1] = "(ts_vehicles_cars_car_front_directional_left.png^[colorize:#fff:25^[transformFX)"
                back[#back+1] = "(ts_vehicles_cars_car_back_directional_left.png^[colorize:#fff:25^[transformFX)"
            end
        end
        if #front > 0 then
            result.front = table.concat(front, "^")
        end
        if #back > 0 then
            result.back = table.concat(back, "^")
        end
        return result
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_front", {
    get_overlay_textures = function(self)
        if self and self._lights.front then
            return {
                front = "(ts_vehicles_cars_car_front_light.png^[colorize:#fff:25)",
                interior = "ts_vehicles_cars_car_interior_light.png",
            }
        else
            return {
                front = "(ts_vehicles_cars_car_front_light.png^[colorize:#000:25)",
            }
        end
    end,

    get_light_overlay_textures = function(self)
        if self and self._lights.front then
            return {
                front = "(ts_vehicles_cars_car_front_light.png^[colorize:#fff:25)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_back", {
    get_overlay_textures = function(self)
        if self and self._lights.stop then
            return {
                back = "(ts_vehicles_cars_car_back_light.png^[colorize:#fff:25)",
            }
        else
            return {
                back = "(ts_vehicles_cars_car_back_light.png^[colorize:#000:25)",
            }
        end
    end,

    get_light_overlay_textures = function(self)
        if self and self._lights.stop then
            return {
                back = "(ts_vehicles_cars_car_back_light.png^[colorize:#fff:25)",
            }
        elseif self and self._lights.front then
            return {
                back = "(ts_vehicles_cars_car_back_light.png^[colorize:#000:25)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_reversing", {
    get_overlay_textures = function(self)
        if self and self._v < 0 then
            return {
                back = "(ts_vehicles_cars_car_reversing_light.png^[colorize:#fff:25)",
            }
        else
            return {
                back = "(ts_vehicles_cars_car_reversing_light.png^[colorize:#000:25)",
            }
        end
    end,

    get_light_overlay_textures = function(self)
        if self and self._v < 0 then
            return {
                back = "(ts_vehicles_cars_car_reversing_light.png^[colorize:#fff:25)",
            }
        end
    end
})

for color, desc in pairs(lightbar_colors) do
    ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:"..color.."_light", {
        get_textures = function(self)
            if not (self and self._lights.special) then
                local texture = "ts_vehicles_cars_"..color.."_light_off.png"
                if ts_vehicles.writing then
                    local text = font_api.get_font("metro"):render(self._data.roof_top_text or "", 64, 16, {
                        lines = 1,
                        halign = "center",
                        valign = "center",
                        color= "#c00",
                    })
                    texture = "[combine:128x128:0,0=("..E(texture).."\\^[resize\\:128x128):32,38=("..E(text).."):32,102=("..E(text)..")"
                end
                return {
                    roof_attachment = texture
                }
            end
        end,
        get_overlay_textures = function(self)
            if self and self._even_step and self._lights.special then
                return {
                    interior = "ts_vehicles_cars_car_interior_special.png"
                }
            end
        end,
        get_light_textures = function(self)
            if self and self._lights.special then
                local texture = "ts_vehicles_cars_"..color.."_light_on.png"..(self._even_step and "^[transformFX" or "")
                if ts_vehicles.writing then
                    local text = font_api.get_font("metro"):render(self._data.roof_top_text or "", 64, 16, {
                        lines = 1,
                        halign = "center",
                        valign = "center",
                        color= "#c00",
                    })
                    texture = "[combine:128x128:0,0=("..E(texture).."\\^[resize\\:128x128):32,38=("..E(text).."):32,102=("..E(text)..")"
                end
                return {
                    roof_attachment = texture
                }
            end
        end,
    })
end

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:license_plate", {
    get_overlay_textures = function(self)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(self._data.license_plate_text or "", 80, 16, {
                lines = 1,
                halign = "center",
                valign = "center",
                color = "#000",
            })
            return {
                front = "ts_vehicles_cars_car_license_plate_front.png^[combine:384x384:152,348=("..E(text)..")",
                back = "ts_vehicles_cars_car_license_plate_back.png^[combine:384x384:152,340=("..E(text)..")"
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:chassis_text", {
    get_overlay_textures = function(self)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(self._data.chassis_text or "", 160, 16, {
                lines = 1,
                halign = "center",
                valign = "center",
                color = self._data.chassis_text_color or "#000",
            }).."^[resize:320x32"
            return {
                front = "[combine:384x384:32,176=("..E(text)..")",
                side = "[combine:320x320:0,236=("..E(text)..")",
                back = "[combine:384x384:32,176=("..E(text)..")",
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:chassis_stripe", {
    get_overlay_textures = function(self)
        local color = self._data.chassis_stripe_color or "#fff"
        return {
            front = "ts_vehicles_api_blank.png^(ts_vehicles_cars_car_chassis_stripe_front.png^[colorize:"..color..")",
            side = "ts_vehicles_api_blank.png^(ts_vehicles_cars_car_chassis_stripe_side.png^[colorize:"..color..")",
            back = "ts_vehicles_api_blank.png^(ts_vehicles_cars_car_chassis_stripe_back.png^[colorize:"..color..")",
        }
    end,
})

ts_vehicles_common.register_engine_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_tank_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_aux_tank_compatibility("ts_vehicles_cars:car")