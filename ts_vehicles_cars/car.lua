-- Vehicle Data
local VD = ts_vehicles.get

local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_cars:car", {
    inventory_image = "ts_vehicles_cars_construction_stand.png",
    description = "Car",
    item_description = "Car Construction Stand",
    collisionbox = { -1.375, -0.5, -1.375, 1.375, 1.5, 1.375 },
    selectionbox = { -1.375, -0.5, -1.375, 1.375, 1.5, 1.375 },
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
    driver_pos = { x = -5, y = 2, z = 4 },
    passenger_pos = {
        { x = 5, y = 2, z = 4 },
        { x = -5, y = 2, z = -9.125 },
        { x = 5, y = 2, z = -9.125 },
    },
    get_fallback_textures = function()
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
        local has_multiple = function(group, max) return ts_vehicles.helpers.multiple_have_group(parts, group, max) end
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
        if has("wrapping") and not (has("chassis_front") and has("chassis_back") and has("doors")) then
            return false, "A full chassis (incl. doors) is required to install a wrapping."
        end
        if has_multiple("wrapping", 10) then
            return false, "Too many wrappings."
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
        if has("auxiliary_tank") and not (has("chassis_front") and has("chassis_back")) then
            return false, "A full chassis is required to mount this auxiliary tank or battery."
        end
        if has_multiple("auxiliary_tank") then
            return false, "A car cannot have multiple auxiliary tanks or batteries."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "storage_capacity", parts) < ts_vehicles.storage.get_total_count(id) then
            return false, "Not enough space."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "gasoline_capacity", parts) < (vd.data.gasoline or 0) then
            return false, "Not enough gasoline capacity."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "hydrogen_capacity", parts) < (vd.data.hydrogen or 0) then
            return false, "Not enough hydrogen capacity."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "electricity_capacity", parts) < (vd.data.electricity or 0) then
            return false, "Not enough electricity capacity."
        end
        return ts_vehicles_common.is_wrapping_structure_sound(self, parts)
    end,
    legacy_data = {
        counts = {
            ["ts_vehicles_cars:tire"] = 4,
            ["ts_vehicles_cars:seat"] = 4,
        },
        colors = {
            ["ts_vehicles_cars:car_chassis"] = "chassis",
            ["ts_vehicles_cars:car_chassis_pillars_a"] = "pillars_a",
            ["ts_vehicles_cars:car_chassis_pillars_bc"] = "pillars_bc",
            ["ts_vehicles_cars:car_roof"] = "roof",
            ["ts_vehicles_cars:car_interior"] = "interior",
            ["ts_vehicles_cars:seat"] = "seats",
            ["ts_vehicles_cars:chassis_text"] = "chassis_text",
            ["ts_vehicles_cars:chassis_stripe"] = "chassis_stripe",
        },
        functions = {
            ["ts_vehicles_common:text"] = function(self, part)
                local vd = VD(self._id)
                local text = vd.data.chassis_text
                if text then
                    local meta = part:get_meta()
                    meta:set_string("side", text)
                    meta:set_string("front", text)
                    meta:set_string("back", text)
                    meta:set_int("set", 1)
                    vd.data.chassis_text = nil
                end
            end,
            ["ts_vehicles_common:wrapping"] = function(self, part)
                local vd = VD(self._id)
                if vd.tmp["ts_vehicles_common:wrapping_color_adjusted"] then
                    local meta = part:get_meta()
                    meta:set_string("side", "Stripe")
                    meta:set_string("front", "Stripe")
                    meta:set_string("back", "Stripe")
                end
            end,
        },
    },
    gasoline_hose_offset = vector.new(1.3, .45, -1.7),
    hydrogen_hose_offset = vector.new(1.3, .45, -1.7),
    electricity_hose_offset = vector.new(1.3, .45, -1.7),
    texts = {
        front = { name = "Front", lines = 1 },
        side = { name = "Sides", lines = 1 },
        back = { name = "Back", lines = 1 },
    },
    wrappings = {
        front = { name = "Front", values = { "Stripe", "Lines" } },
        side = { name = "Sides", values = { "Stripe", "Lines", "Battenberg A", "Battenberg B" } },
        back = { name = "Back", values = { "Stripe", "Lines", "Chevron A", "Chevron B" } },
    },
})

minetest.register_craft({
    output = "ts_vehicles_cars:car",
    recipe = {
        { "default:steelblock", "", "default:steelblock" },
        { "", "dye:yellow", "" },
        { "default:steelblock", "", "default:steelblock" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis", {
    description = "Car Chassis",
    inventory_image = "ts_vehicles_cars_car_chassis.png",
    storage_capacity = 5000,
    groups = { chassis_front = 1, doors = 1, chassis_back = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis",
    recipe = {
        { "ts_vehicles_common:composite_material", "", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:car_chassis_pillars_bc", {
    description = "Car Pillar (B/C)",
    inventory_image = "ts_vehicles_cars_pillars_bc.png",
    groups = { chassis_pillars_b = 1, chassis_pillars_c = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:car_chassis_pillars_bc",
    recipe = {
        { "", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:tire", {
    quantity = 4,
    get_textures = function()
        return {
            tires = "ts_vehicles_ct.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:base_plate", {
    get_textures = function()
        return {
            base_plate = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            front = "ts_vehicles_cf.png^[multiply:" .. color .. "^ts_vehicles_cf_.png",
            back = "ts_vehicles_cb.png^[multiply:" .. color,
            side = "ts_vehicles_cs.png^[multiply:" .. color,
        }
    end,
    get_fallback_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            interior = "ts_vehicles_ci.png^[multiply:" .. color
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_a", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            pillars_a = "ts_vehicles_cp.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_chassis_pillars_bc", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            pillars_bc = "ts_vehicles_cp.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:windscreen", {
    get_textures = function()
        return {
            glass = "ts_vehicles_cws.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:windows", {
    get_textures = function()
        return {
            glass = "ts_vehicles_cw.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_roof", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            roof = "ts_vehicles_cr.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:car_interior", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            interior = "ts_vehicles_ci.png^[multiply:" .. color .. "^ts_vehicles_ci_.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_common:seat", {
    quantity = 4,
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            seats = "wool_white.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:direction_indicator", {
    get_overlay_textures = function()
        return {
            front = "(ts_vehicles_cdf.png)",
            back = "(ts_vehicles_cdb.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        local tmp = {}
        if vd.lights.left or vd.lights.warn then
            tmp[#tmp + 1] = "(ts_vehicles_cdl_.png)"
        end
        if vd.lights.right or vd.lights.warn then
            tmp[#tmp + 1] = "(ts_vehicles_cdr_.png)"
        end
        if #tmp > 0 then
            return {
                chassis_1 = table.concat(tmp, "^")
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_front", {
    get_overlay_textures = function()
        return {
            front = "(ts_vehicles_cfl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.front then
            return {
                chassis = "(ts_vehicles_cfl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_back", {
    get_overlay_textures = function()
        return {
            back = "(ts_vehicles_cbl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.stop then
            return {
                chassis = "(ts_vehicles_cbl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:lights_reversing", {
    get_overlay_textures = function()
        return {
            back = "(ts_vehicles_crl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.v < 0 then
            return {
                chassis = "(ts_vehicles_crl_.png)",
            }
        end
    end
})

for _, def in ipairs(ts_vehicles_cars.lightbars) do
    ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:" .. def.id .. "_light", {
        get_textures = function()
            return {
                roof_attachment = def.off
            }
        end,
        get_light_textures = function(id)
            local vd = VD(id)
            local result = {}
            local text = ts_vehicles.write(vd.data.roof_top_text, 64, 16, 1, "#c00", 1, true)
            result.roof_attachment = text and "[combine:128x128:32,38=(" .. E(text) .. "):32,102=(" .. E(text) .. ")" or nil
            if vd.lights.special then
                result.roof_attachment_1 = def.on1
                result.roof_attachment_2 = def.on2
            end
            return result
        end,
        get_light_overlay_textures = function(id)
            local vd = VD(id)
            if vd.lights.special then
                return {
                    chassis_1 = "ts_vehicles_csl_.png"
                }
            end
        end
    })
end

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_cars:license_plate", {
    get_overlay_textures = function(id)
        local vd = VD(id)
        local text = ts_vehicles.write(vd.data.license_plate_text, 80, 16, 1, "#000")
        return {
            front = "ts_vehicles_clpf.png^[combine:384x384:152,348=(" .. E(text) .. ")",
            back = "ts_vehicles_clpb.png^[combine:384x384:152,340=(" .. E(text) .. ")"
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_common:text", {
    get_overlay_textures = function(id, part)
        local meta = part:get_meta()
        local front = ts_vehicles.write(meta:get_string("front"), 160, 16, 1, ts_vehicles.get_part_color(part), 2, true)
        local side = ts_vehicles.write(meta:get_string("side"), 160, 16, 1, ts_vehicles.get_part_color(part), 2, true)
        local back = ts_vehicles.write(meta:get_string("back"), 160, 16, 1, ts_vehicles.get_part_color(part), 2, true)
        return {
            front = front and "[combine:384x384:32,176=(" .. E(front) .. ")" or nil,
            side = side and "[combine:320x320:0,236=(" .. E(side) .. ")" or nil,
            back = back and "[combine:384x384:32,176=(" .. E(back) .. ")" or nil,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:car", "ts_vehicles_common:wrapping", {
    get_overlay_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        local meta = part:get_meta()
        local wrappings = ts_vehicles.registered_vehicle_bases["ts_vehicles_cars:car"].wrappings
        local side_number = ts_vehicles.helpers.index_of(wrappings.side.values, meta:get_string("side"))
        local front_number = ts_vehicles.helpers.index_of(wrappings.front.values, meta:get_string("front"))
        local back_number = ts_vehicles.helpers.index_of(wrappings.back.values, meta:get_string("back"))
        local front = {}
        local back = {}
        local side = ""
        if side_number then
            front[#front + 1] = "(ts_vehicles_cws" .. side_number .. "f.png^[multiply:" .. color .. ")"
            back[#back + 1] = "(ts_vehicles_cws" .. side_number .. "b.png^[multiply:" .. color .. ")"
            side = "(ts_vehicles_cws" .. side_number .. "s.png^[multiply:" .. color .. ")"
        end
        if front_number then
            front[#front + 1] = "(ts_vehicles_cwf" .. front_number .. ".png^[multiply:" .. color .. ")"
        end
        if back_number then
            back[#back + 1] = "(ts_vehicles_cwb" .. back_number .. ".png^[multiply:" .. color .. ")"
        end
        return {
            front = #front > 0 and table.concat(front, "^") or nil,
            side = side ~= "" and side or nil,
            back = #back > 0 and table.concat(back, "^") or nil,
        }
    end,
})

ts_vehicles_common.register_engine_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_tank_compatibility("ts_vehicles_cars:car")
ts_vehicles_common.register_aux_tank_compatibility("ts_vehicles_cars:car")