-- Vehicle Data
local VD = ts_vehicles.get

local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_cars:car", {
    inventory_image = "ts_vehicles_cars_construction_stand_inv.png",
    description = "Car",
    item_description = "Car Construction Stand",
    collisionbox = {-1.375, -0.5, -1.375, 1.375, 1.5, 1.375},
    selectionbox = {-1.375, -0.5, -1.375, 1.375, 1.5, 1.375},
    scale_factor = .8,
    mesh = "ts_vehicles_cars_car.obj",
    lighting_mesh = "ts_vehicles_cars_car.b3d",
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
    lighting_textures = {
        "chassis_1",
        "chassis_2",
        "chassis",
        "roof_attachment_1",
        "roof_attachment_2",
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
            tires = "ts_vehicles_ccs.png"
        }
    end,
    is_driveable = function(self)
        local parts = VD(self._id).parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        if not has("base_plate") then return false, "A car needs a base plate." end
        if not has("tires") then return false, "A car needs tires." end
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
        local id = self._id
        local vd = VD(id)
        parts = parts or vd.parts
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
        if ts_vehicles.helpers.get_total_value(self, "storage_capacity", parts) < ts_vehicles.storage.get_total_count(id) then
            return false, "Not enough space."
        end
        if ts_vehicles.helpers.get_total_value(self, "gasoline_capacity", parts) < (vd.data.gasoline or 0) then
            return false, "Not enough gasoline capacity."
        end
        if ts_vehicles.helpers.get_total_value(self, "hydrogen_capacity", parts) < (vd.data.hydrogen or 0) then
            return false, "Not enough hydrogen capacity."
        end
        if ts_vehicles.helpers.get_total_value(self, "electricity_capacity", parts) < (vd.data.electricity or 0) then
            return false, "Not enough electricity capacity."
        end
        return true
    end,

    can_remove_part = function(self, part_name)
        local parts = VD(self._id).parts
        if not ts_vehicles.helpers.contains(parts, part_name) then
            return false, "Part does not exist on vehicle!"
        end

        local def = ts_vehicles.registered_vehicle_bases[self.name]
        local parts_copy = table.copy(parts)
        table.remove(parts_copy, ts_vehicles.helpers.index_of(parts_copy, part_name))
        local is_structure_sound, reason = def.is_structure_sound(self, parts_copy)
        if not is_structure_sound then
            return false, reason
        end
        return true, nil
    end,

    get_part_drop = function(self, part_name)
        if not ts_vehicles.helpers.contains(VD(self._id).parts, part_name) then
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
        local parts_copy = table.copy(VD(self._id).parts)
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

minetest.register_craft({
    output = "ts_vehicles_cars:car",
    recipe = {
        {"default:steelblock", "", "default:steelblock"},
        {"", "dye:yellow", ""},
        {"default:steelblock", "", "default:steelblock"},
    },
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
            local vd = VD(self._id)
            vd.data.chassis_color = color
            vd.data.chassis_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.chassis_color then
            drop:get_meta():set_string("color", vd.data.chassis_color)
        end
        if vd.data.chassis_description then
            drop:get_meta():set_string("description", vd.data.chassis_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis",
    recipe = {
        {"ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_a", {
    description = "Car/Truck Pillar (A)",
    inventory_image = "ts_vehicles_cars_pillars_a_inv.png",
    groups = { chassis_pillars_a = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.pillars_a_color = color
            vd.data.pillars_a_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.pillars_a_color then
            drop:get_meta():set_string("color", vd.data.pillars_a_color)
        end
        if vd.data.pillars_a_description then
            drop:get_meta():set_string("description", vd.data.pillars_a_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis_pillars_a",
    recipe = {
        {"ts_vehicles_common:composite_material", "", ""},
        {"ts_vehicles_common:composite_material", "", ""},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_bc", {
    description = "Car Pillar (B/C)",
    inventory_image = "ts_vehicles_cars_pillars_bc_inv.png",
    groups = { chassis_pillars_b = 1, chassis_pillars_c = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.pillars_bc_color = color
            vd.data.pillars_bc_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.pillars_bc_color then
            drop:get_meta():set_string("color", vd.data.pillars_bc_color)
        end
        if vd.data.pillars_bc_description then
            drop:get_meta():set_string("description", vd.data.pillars_bc_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis_pillars_bc",
    recipe = {
        {"", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:car_roof", {
    description = "Car/Truck Roof",
    inventory_image = "ts_vehicles_cars_base_plate_inv_mask.png",
    groups = { roof = 1},
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.roof_color = color
            vd.data.roof_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.roof_color then
            drop:get_meta():set_string("color", vd.data.roof_color)
        end
        if vd.data.roof_description then
            drop:get_meta():set_string("description", vd.data.roof_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_roof",
    recipe = {
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:car_interior", {
    description = "Car/Truck Interior",
    inventory_image = "ts_vehicles_cars_car_interior_inv.png",
    groups = { interior = 1, },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.interior_color = color
            vd.data.interior_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.interior_color then
            drop:get_meta():set_string("color", vd.data.interior_color)
        end
        if vd.data.interior_description then
            drop:get_meta():set_string("description", vd.data.interior_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_interior",
    recipe = {
        {"basic_materials:plastic_sheet", "techage:ta4_leds", ""},
        {"wool:white", "wool:white", "wool:white"},
    },
})



ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:tire", {
    get_textures = function(self)
        return {
            tires = "ts_vehicles_ct.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:base_plate", {
    get_textures = function(self)
        return {
            base_plate = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.chassis_color then
            color = vd.data.chassis_color
        end
        return {
            front = "ts_vehicles_cf.png^[multiply:"..color.."^ts_vehicles_cf_.png",
            back = "ts_vehicles_cb.png^[multiply:"..color,
            side = "ts_vehicles_cs.png^[multiply:"..color,
        }
    end,
    get_fallback_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.chassis_color then
            color = vd.data.chassis_color
        end
        return {
            interior = "ts_vehicles_ci.png^[multiply:"..color
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_a", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.pillars_a_color then
            color = vd.data.pillars_a_color
        end
        return {
            pillars_a = "ts_vehicles_cp.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_bc", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.pillars_bc_color then
            color = vd.data.pillars_bc_color
        end
        return {
            pillars_bc = "ts_vehicles_cp.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:windscreen", {
    get_textures = function(self)
        return {
            glass = "ts_vehicles_cws.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:windows", {
    get_textures = function(self)
        return {
            glass = "ts_vehicles_cw.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_roof", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.roof_color then
            color = vd.data.roof_color
        end
        return {
            roof = "ts_vehicles_cr.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_interior", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.interior_color then
            color = vd.data.interior_color
        end
        return {
            interior = "ts_vehicles_ci.png^[multiply:"..color.."^ts_vehicles_ci_.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:seat", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.seats_color then
            color = vd.data.seats_color
        end
        return {
            seats = "wool_white.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:direction_indicator", {
    get_overlay_textures = function(self)
        return {
            front = "(ts_vehicles_cdf.png)",
            back = "(ts_vehicles_cdb.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        local tmp = {}
        if vd.lights.left or vd.lights.warn then
            tmp[#tmp+1] = "(ts_vehicles_cdl_.png)"
        end
        if vd.lights.right or vd.lights.warn then
            tmp[#tmp+1] = "(ts_vehicles_cdr_.png)"
        end
        if #tmp > 0 then
            return {
                chassis_1 = table.concat(tmp, "^")
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_front", {
    get_overlay_textures = function(self)
        return {
            front = "(ts_vehicles_cfl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.lights.front then
            return {
                chassis = "(ts_vehicles_cfl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_back", {
    get_overlay_textures = function(self)
        return {
            back = "(ts_vehicles_cbl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.lights.stop then
            return {
                chassis = "(ts_vehicles_cbl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_reversing", {
    get_overlay_textures = function(self)
        return {
            back = "(ts_vehicles_crl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.v < 0 then
            return {
                chassis = "(ts_vehicles_crl_.png)",
            }
        end
    end
})

for _,def in ipairs(ts_vehicles_cars.lightbars) do
    ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:"..def.id.."_light", {
        get_textures = function(self)
            return {
                roof_attachment = def.off
            }
        end,
        get_light_textures = function(self)
            local vd = VD(self._id)
            local result = {}
            if ts_vehicles.writing then
                local text = font_api.get_font("metro"):render(vd.data.roof_top_text or "", 64, 16, {
                    lines = 1,
                    halign = "center",
                    valign = "center",
                    color= "#c00",
                })
                result.roof_attachment = "[combine:128x128:32,38=("..E(text).."):32,102=("..E(text)..")"
            end
            if vd.lights.special then
                result.roof_attachment_1 = def.on1
                result.roof_attachment_2 = def.on2
            end
            return result
        end,
        get_light_overlay_textures = function(self)
            local vd = VD(self._id)
            if vd.lights.special then
                return {
                    chassis_1 = "ts_vehicles_csl_.png"
                }
            end
        end
    })
end

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:license_plate", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(vd.data.license_plate_text or "", 80, 16, {
                lines = 1,
                halign = "center",
                valign = "center",
                color = "#000",
            })
            return {
                front = "ts_vehicles_clpf.png^[combine:384x384:152,348=("..E(text)..")",
                back = "ts_vehicles_clpb.png^[combine:384x384:152,340=("..E(text)..")"
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:chassis_text", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(vd.data.chassis_text or "", 160, 16, {
                lines = 1,
                halign = "center",
                valign = "center",
                color = vd.data.chassis_text_color or "#000",
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
        local vd = VD(self._id)
        local color = vd.data.chassis_stripe_color or "#fff"
        return {
            front = "(ts_vehicles_csf.png^[multiply:"..color..")",
            side = "(ts_vehicles_css.png^[multiply:"..color..")",
            back = "(ts_vehicles_csb.png^[multiply:"..color..")",
        }
    end,
})

ts_vehicles_common.register_engine_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_tank_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_aux_tank_compatibility("ts_vehicles_cars:car")