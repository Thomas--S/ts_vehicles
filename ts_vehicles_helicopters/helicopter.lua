-- Vehicle Data
local VD = ts_vehicles.get

local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_helicopters:helicopter", {
    inventory_image = "ts_vehicles_helicopters_skid.png",
    description = "Helicopter",
    item_description = "Helicopter Skid",
    collisionbox = { -1.5, -0.5, -1.5, 1.5, 2.5, 1.5 },
    selectionbox = { -1.5, -0.5, -1.5, 1.5, 2.5, 1.5 },
    scale_factor = 1,
    mesh = "ts_vehicles_helicopter.b3d",
    lighting_mesh = "ts_vehicles_helicopter_lighting.b3d",
    lighting_scale = 1,
    -- The names are intentional; the mapping to the actual textures should happen in API,
    -- according to the get_texture functions of the registered compatibilities.
    textures = {
        "skid",
        "hull",
        "back",
        "interior",
        "tail",
        "rotor_hub",
        "main_rotor",
        "tail_rotor",
        "windows",
        "control",
        "seats",
        "beacon",
        "acl_left",
        "acl_right",
        "nav_tail",
        "nav_left",
        "nav_right",
    },
    lighting_textures = {
        "front",
        "interior",
        "interior_blink",
        "beacon",
        "acl_left",
        "acl_right",
        "nav_tail",
        "nav_left",
        "nav_right",
    },
    on_step = ts_vehicles.helicopter_on_step,
    driver_pos = { x = -5, y = 4.5, z = 5 },
    passenger_pos = {
        { x = 5, y = 4.5, z = 5 },
    },
    get_textures = function()
        return {
            skid = "ts_vehicles_hg.png",
        }
    end,
    is_driveable = function(self)
        local parts = VD(self._id).parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        if not has("hull") then return false, "A helicopter needs a hull." end
        if not has("tail") then return false, "A helicopter needs a tail." end
        if not has("main_rotor") then return false, "A helicopter needs a main rotor." end
        if not has("tail_rotor") then return false, "A helicopter needs a tail rotor." end
        if not has("windows") then return false, "A helicopter needs windows." end
        if not has("seats") then return false, "A helicopter needs seats." end
        if not has("control_stick") then return false, "A helicopter needs a control stick." end
        if not has("anti_collision_lights") then return false, "A helicopter needs anti-collision lights." end
        if not has("navigation_lights") then return false, "A helicopter needs navigation lights." end
        if not has("landing_light") then return false, "A helicopter needs a landing light." end
        if not has("gas_turbine") then return false, "A helicopter needs an gas turbine." end
        if not has("main_tank") then return false, "A helicopter needs a tank." end
        if not has("control_panel") then return false, "A helicopter needs a control panel." end
        return true
    end,
    is_structure_sound = function(self, parts)
        local id = self._id
        local vd = VD(id)
        parts = parts or vd.parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        local has_multiple = function(group, max) return ts_vehicles.helpers.multiple_have_group(parts, group, max) end
        if has_multiple("hull") then
            return false, "A helicopter cannot have multiple hulls."
        end
        if has("tail") and not has("hull") then
            return false, "A hull is required to mount the tail."
        end
        if has_multiple("tail") then
            return false, "A helicopter cannot have multiple tails."
        end
        if has_multiple("main_rotor") then
            return false, "A helicopter cannot have multiple main rotors."
        end
        if has("tail_rotor") and not has("tail") then
            return false, "A tail is required to mount the tail rotor."
        end
        if has_multiple("tail_rotor") then
            return false, "A helicopter cannot have multiple tail rotors."
        end
        if has("windows") and not has("hull") then
            return false, "A hull is required to mount the windows."
        end
        if has_multiple("windows") then
            return false, "A helicopter cannot have multiple sets of windows."
        end
        if has("seats") and not has("hull") then
            return false, "A hull is required to mount the seats."
        end
        if has_multiple("seats") then
            return false, "A helicopter cannot have multiple sets of seats."
        end
        if has("control_stick") and not has("hull") then
            return false, "A hull is required to mount the control stick."
        end
        if has_multiple("control_stick") then
            return false, "A helicopter cannot have multiple control sticks."
        end
        if has("control_panel") and not has("hull") then
            return false, "A hull is required to mount the control panel."
        end
        if has_multiple("control_panel") then
            return false, "A helicopter cannot have multiple control panels."
        end
        if has("anti_collision_lights") and not has("hull") then
            return false, "A hull is required to mount the anti-collision lights."
        end
        if has_multiple("anti_collision_lights") then
            return false, "A helicopter cannot have multiple sets of anti-collision lights."
        end
        if has("navigation_lights") and not has("hull") then
            return false, "A hull is required to mount the navigation lights."
        end
        if has_multiple("navigation_lights") then
            return false, "A helicopter cannot have multiple sets of navigation lights."
        end
        if has("landing_light") and not has("hull") then
            return false, "A hull is required to mount the landing light."
        end
        if has_multiple("landing_light") then
            return false, "A helicopter cannot have multiple landing lights."
        end
        if has_multiple("search_light") then
            return false, "A helicopter cannot have multiple search lights."
        end
        if has("wrapping") and not (has("hull") and has("tail")) then
            return false, "A hull and a tail are required to install a wrapping."
        end
        if has_multiple("wrapping", 10) then
            return false, "Too many wrappings."
        end
        if has("gas_turbine") and not (has("hull") and has("tail")) then
            return false, "A hull and a tail are required to mount the gas turbine."
        end
        if has_multiple("gas_turbine") then
            return false, "A helicopter cannot have multiple gas turbines."
        end
        if has("main_tank") and not (has("hull") and has("tail")) then
            return false, "A hull and a tail are required to mount this tank or battery."
        end
        if has_multiple("main_tank") then
            return false, "A helicopter cannot have multiple fuel tanks."
        end
        if has("auxiliary_tank") and not (has("hull") and has("tail")) then
            return false, "A hull and a tail are required to mount this auxiliary tank or battery."
        end
        if has_multiple("auxiliary_tank") then
            return false, "A helicopter cannot have multiple auxiliary tanks or batteries."
        end
        if has("payload_tank") and not (has("hull") and has("tail")) then
            return false, "A hull and a tail are required to mount this payload tank."
        end
        if has_multiple("payload_tank") then
            return false, "A helicopter cannot have multiple payload tanks."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "storage_capacity", parts) < ts_vehicles.storage.get_total_count(id) then
            return false, "Not enough space."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "payload_tank_capacity", parts) < (vd.data.payload_tank_amount or 0) then
            return false, "Not enough payload tank capacity."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "gasoline_capacity", parts) < (vd.data.gasoline or 0) then
            return false, "Not enough gasoline capacity."
        end
        if ts_vehicles.helpers.get_total_value(self._id, "hydrogen_capacity", parts) < (vd.data.hydrogen or 0) then
            return false, "Not enough hydrogen capacity."
        end
        return ts_vehicles_common.is_wrapping_structure_sound(self, parts)
    end,
    gasoline_hose_offset = vector.new(.9, .35, -1.6),
    hydrogen_hose_offset = vector.new(.9, .35, -1.6),
    electricity_hose_offset = vector.new(.9, .35, -1.6),
    payload_tank_hose_offset = vector.new(-.9, .35, -1.6),
    texts = {
        hull = { name = "Hull", lines = 1 },
        tail = { name = "Tail", lines = 1 },
    },
    wrappings = {
        hull = { name = "Hull", values = { "Stripe", "Lines" } },
    },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter",
    recipe = {
        { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        { "techage:aluminum", "", "techage:aluminum" },
        { "default:steelblock", "default:steelblock", "default:steelblock" },
    },
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_hull", {
    description = "Helicopter Hull",
    inventory_image = "ts_vehicles_helicopters_hull.png",
    storage_capacity = 5000,
    groups = { hull = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_hull",
    recipe = {
        { "", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_hull", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            hull = "ts_vehicles_hh.png^[multiply:" .. color,
            back = "ts_vehicles_hg.png",
            interior = "ts_vehicles_hi.png^[multiply:" .. color .. "^ts_vehicles_hi_.png",
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_tail", {
    description = "Helicopter Tail",
    inventory_image = "ts_vehicles_helicopters_tail.png",
    groups = { tail = 1, },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_tail",
    recipe = {
        { "", "", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_tail", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            tail = "ts_vehicles_ht.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_main_rotor", {
    description = "Helicopter Main Rotor",
    inventory_image = "ts_vehicles_helicopters_main_rotor.png",
    groups = { main_rotor = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_main_rotor",
    recipe = {
        { "ts_vehicles_common:lw_composite_material", "", "ts_vehicles_common:lw_composite_material" },
        { "", "basic_materials:gear_steel", "" },
        { "ts_vehicles_common:lw_composite_material", "", "ts_vehicles_common:lw_composite_material" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_main_rotor", {
    get_textures = function()
        return {
            main_rotor = "ts_vehicles_hmr.png",
            rotor_hub = "ts_vehicles_hg.png",
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_tail_rotor", {
    description = "Helicopter Tail Rotor",
    inventory_image = "ts_vehicles_helicopters_tail_rotor.png",
    groups = { tail_rotor = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_tail_rotor",
    recipe = {
        { "", "ts_vehicles_common:lw_composite_material", "" },
        { "ts_vehicles_common:lw_composite_material", "basic_materials:gear_steel", "ts_vehicles_common:lw_composite_material" },
        { "", "ts_vehicles_common:lw_composite_material", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_tail_rotor", {
    get_textures = function()
        return {
            tail_rotor = "ts_vehicles_htr.png",
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_windows", {
    description = "Helicopter Windows",
    inventory_image = "ts_vehicles_helicopters_windows.png",
    groups = { windows = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_windows",
    recipe = {
        { "xpanes:pane_flat", "ts_vehicles_common:lw_composite_material", "xpanes:pane_flat" },
        { "xpanes:pane_flat", "ts_vehicles_common:lw_composite_material", "xpanes:pane_flat" },
        { "xpanes:pane_flat", "ts_vehicles_common:lw_composite_material", "xpanes:pane_flat" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_windows", {
    get_textures = function()
        return {
            windows = "ts_vehicles_hw.png",
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_control_stick", {
    description = "Helicopter Control Stick",
    inventory_image = "ts_vehicles_helicopters_control_stick.png",
    groups = { control_stick = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_control_stick",
    recipe = {
        { "", "", "" },
        { "ts_vehicles_common:lw_composite_material", "basic_materials:ic", "ts_vehicles_common:lw_composite_material" },
        { "", "basic_materials:steel_bar", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_control_stick", {
    get_textures = function()
        return {
            control = "ts_vehicles_hcs.png",
        }
    end,
})

local draw_cp_slot = function(def)
    -- Total width: 2.54
    local fs = ""
    fs = fs .. "style[" .. def.id .. "_label;textcolor=black;content_offset=0,0]"
    fs = fs ..
        string.format("image_button[%f,1.625;2.04,.5;ts_vehicles_api_blank.png;%s_label;%s;false;false;]", def.x + .25,
            def.id, def.label)
    fs = fs .. string.format("box[%f,2.375;2.04,1;#3d3d3dff]", def.x + .25)
    if def.animated_image then
        fs = fs .. string.format("animated_image[%f,2.625;.5,.5;;%s;2;1000]", def.x + 1.02, def.animated_image)
    else
        fs = fs .. string.format("box[%f,2.625;.5,.5;%s]", def.x + 1.02, def.color)
    end
    fs = fs .. string.format("box[%f,2.75;.25,.25;#898989ff]", def.x + .51)
    fs = fs .. string.format("box[%f,2.75;.25,.25;#898989ff]", def.x + 1.78)
    if def.action then
        fs = fs ..
            string.format("button[%f,3.625;2.04,.625;%s_%s;%s]", def.x + .25, def.id, def.action.id, def.action.label)
    end
    return fs
end

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_control_panel", {
    description = "Helicopter Control Panel",
    inventory_image = "ts_vehicles_helicopters_control_panel.png",
    groups = { control_panel = 1, },
    get_formspec = function(self, player, part)
        local player_name = player:get_player_name()
        local old_entity = ts_vehicles.player_currently_editing_entity[player_name]
        local old_part = ts_vehicles.player_currently_editing_part[player_name]

        minetest.after(5.5, function()
            if ts_vehicles.player_currently_editing_entity[player_name] == old_entity and ts_vehicles.player_currently_editing_part[player_name] == old_part then
                local part_stack = VD(self._id).parts[old_part]
                local part_name = part_stack and part_stack:get_name() or ""
                if part_name == "ts_vehicles_helicopters:helicopter_control_panel" then
                    ts_vehicles.show_formspec(self, player)
                end
            end
        end)

        local vd = VD(self._id)
        local fs = ""
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[0,.25;Control Panel]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        if not vd.driver then
            fs = fs .. "label[0,1;A pilot must sit in the helicopter to use the control panel.]"
            return fs
        end
        fs = fs .. "box[0,1;16,4;#898989ff]"
        fs = fs .. "box[.375,1.375;.25,.25;#3d3d3dff]"
        fs = fs .. "box[.375,4.375;.25,.25;#3d3d3dff]"
        fs = fs .. "box[15.375,1.375;.25,.25;#3d3d3dff]"
        fs = fs .. "box[15.375,4.375;.25,.25;#3d3d3dff]"
        for i = 1, 5 do
            fs = fs .. string.format("box[%f,1.375;.125,3.25;#3d3d3dff]", .375 + (i * 2.54) - .125 / 2)
        end
        local engine_action = nil
        if (not vd.data.state or vd.data.state == "stopped" or vd.data.state == "stopping")
            and ts_vehicles.get_fuel_ratio(self._id) > 0
            and vd.lights.nav and vd.lights.acl
        then
            engine_action = { id = "start", label = "START" }
        elseif vd.data.state == "started" or vd.data.state == "starting" then
            engine_action = { id = "stop", label = "STOP" }
        end
        fs = fs .. draw_cp_slot({
            x = .375,
            id = "engine",
            label = "Engine",
            color = vd.data.state == "started" and "#ff0000ff" or "#4d0000ff",
            animated_image = vd.data.state == "starting" and "ts_vehicles_helicopters_engine_blink.png" or nil,
            action = engine_action,
        })
        fs = fs .. draw_cp_slot({
            x = 2.915,
            id = "fuel",
            label = "Fuel",
            color = (vd.data.state == "started" or vd.data.state == "starting") and vd.lights.fuel == "on" and "#d5ff00ff" or "#2b3300ff",
            animated_image = (vd.data.state == "started" or vd.data.state == "starting") and vd.lights.fuel == "warn" and "ts_vehicles_helicopters_fuel_blink.png" or nil,
        })
        fs = fs .. draw_cp_slot({
            x = 5.455,
            id = "nav",
            label = "NAV Lights",
            color = vd.lights.nav and "#00e600ff" or "#003300ff",
            action = vd.lights.nav and { id = "off", label = "TURN OFF" } or { id = "on", label = "TURN ON" },
        })
        fs = fs .. draw_cp_slot({
            x = 7.995,
            id = "acl",
            label = "ACL Lights",
            color = vd.lights.acl and "#fdffccff" or "#7e8066ff",
            action = vd.lights.acl and { id = "off", label = "TURN OFF" } or { id = "on", label = "TURN ON" },
        })
        fs = fs .. draw_cp_slot({
            x = 10.535,
            id = "ll",
            label = "Landing Light",
            color = vd.lights.ll and "#ffe69bff" or "#332e1fff",
            action = vd.lights.ll and { id = "off", label = "TURN OFF" } or { id = "on", label = "TURN ON" },
        })
        local search_light_action = nil
        if ts_vehicles.helpers.any_has_group(vd.parts, "search_light") then
            search_light_action = vd.lights.sl and { id = "off", label = "TURN OFF" } or { id = "on", label = "TURN ON" }
        end
        fs = fs .. draw_cp_slot({
            x = 13.075,
            id = "sl",
            label = "Search Light",
            color = vd.lights.sl and "#9bfff0ff" or "#1f3330ff",
            action = search_light_action,
        })
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        local vd = VD(self._id)
        if vd.driver then
            if fields["engine_start"] and (not vd.data.state or vd.data.state == "stopped" or vd.data.state == "stopping")
                and ts_vehicles.get_fuel_ratio(self._id) > 0
                and vd.lights.nav and vd.lights.acl
            then
                vd.data.time_to_state_change = 10 - (vd.data.time_to_state_change or 0)
                vd.data.state = "starting"
                vd.tmp.light_textures_set = false
            elseif fields["engine_stop"] and (vd.data.state == "started" or vd.data.state == "starting") then
                vd.data.time_to_state_change = 10 - (vd.data.time_to_state_change or 0)
                vd.data.state = "stopping"
                vd.lights.nav = false
                vd.lights.acl = false
                vd.lights.ll = false
                vd.lights.sl = false
                vd.tmp.light_textures_set = false
            elseif fields["nav_on"] then
                vd.lights.nav = true
                vd.tmp.light_textures_set = false
            elseif fields["nav_off"] then
                vd.lights.nav = false
                vd.tmp.light_textures_set = false
            elseif fields["acl_on"] then
                vd.lights.acl = true
                vd.tmp.light_textures_set = false
            elseif fields["acl_off"] then
                vd.lights.acl = false
                vd.tmp.light_textures_set = false
            elseif fields["ll_on"] then
                vd.lights.ll = true
                vd.tmp.light_textures_set = false
            elseif fields["ll_off"] then
                vd.lights.ll = false
                vd.tmp.light_textures_set = false
            elseif fields["sl_on"] and ts_vehicles.helpers.any_has_group(vd.parts, "search_light") then
                vd.lights.sl = true
                vd.tmp.light_textures_set = false
            elseif fields["sl_off"] then
                vd.lights.sl = false
                vd.tmp.light_textures_set = false
            end
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_control_panel",
    recipe = {
        { "techage:ta4_leds", "techage:ta4_leds", "techage:ta4_leds" },
        { "ts_vehicles_common:lw_composite_material", "basic_materials:ic", "ts_vehicles_common:lw_composite_material" },
        { "techage:ta4_button_off", "techage:ta4_button_off", "techage:ta4_button_off" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_control_panel", {
    get_overlay_textures = function()
        return {
            interior = "ts_vehicles_hip.png",
        }
    end,
    get_light_overlay_textures = function(id)
        local vd = VD(id)
        local interior = {}
        local interior_blink = {}
        if vd.lights.nav then
            interior[#interior + 1] = "ts_vehicles_hipn.png"
        end
        if vd.lights.acl then
            interior[#interior + 1] = "ts_vehicles_hipa.png"
        end
        if vd.lights.ll then
            interior[#interior + 1] = "ts_vehicles_hipl.png"
        end
        if vd.lights.sl then
            interior[#interior + 1] = "ts_vehicles_hips.png"
        end
        if vd.data.state == "starting" then
            interior_blink[#interior_blink + 1] = "ts_vehicles_hipe.png"
        end
        if vd.data.state == "started" then
            interior[#interior + 1] = "ts_vehicles_hipe.png"
        end
        if vd.data.state == "started" or vd.data.state == "starting" then
            if vd.lights.fuel == "warn" then
                interior_blink[#interior_blink + 1] = "ts_vehicles_hipw.png"
            elseif vd.lights.fuel == "on" then
                interior[#interior + 1] = "ts_vehicles_hipf.png"
            end
        end
        return {
            interior = #interior > 0 and table.concat(interior, "^") or nil,
            interior_blink = #interior_blink > 0 and table.concat(interior_blink, "^") or nil,
        }
    end,
})

ts_vehicles_common.register_seat()
ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:seat", {
    quantity = 2,
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            seats = "wool_white.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:anti_collision_lights", {
    description = "Helicopter Anti-Collision Lights",
    inventory_image = "ts_vehicles_helicopters_acl.png",
    groups = { anti_collision_lights = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:anti_collision_lights",
    recipe = {
        { "dye:white", "", "" },
        { "", "techage:simplelamp_off", "dye:red" },
        { "dye:white", "", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:anti_collision_lights", {
    get_textures = function()
        return {
            beacon = "ts_vehicles_hlr.png",
            acl_left = "ts_vehicles_hlw.png",
            acl_right = "ts_vehicles_hlw.png",
        }
    end,
    get_light_textures = function(id)
        local vd = VD(id)
        if vd.lights.acl then
            return {
                beacon = "ts_vehicles_hlr_.png",
                acl_left = "ts_vehicles_hlw_.png",
                acl_right = "ts_vehicles_hlw_.png",
            }
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:navigation_lights", {
    description = "Helicopter Navigation Lights",
    inventory_image = "ts_vehicles_helicopters_nav.png",
    groups = { navigation_lights = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:navigation_lights",
    recipe = {
        { "dye:green", "", "" },
        { "", "techage:simplelamp_off", "dye:white" },
        { "dye:red", "", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:navigation_lights", {
    get_textures = function()
        return {
            nav_tail = "ts_vehicles_hlw.png",
            nav_left = "ts_vehicles_hlr.png",
            nav_right = "ts_vehicles_hlg.png",
        }
    end,
    get_light_textures = function(id)
        local vd = VD(id)
        if vd.lights.nav then
            return {
                nav_tail = "ts_vehicles_hlw_.png",
                nav_left = "ts_vehicles_hlr_.png",
                nav_right = "ts_vehicles_hlg_.png",
            }
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_landing_light", {
    description = "Helicopter Landing Light",
    inventory_image = "ts_vehicles_helicopters_landing_light.png",
    groups = { landing_light = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_landing_light",
    recipe = {
        { "", "", "" },
        { "", "ts_vehicles_common:lw_composite_material", "" },
        { "", "techage:simplelamp_off", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_landing_light", {
    get_overlay_textures = function()
        return {
            hull = "ts_vehicles_hll.png",
        }
    end,
    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.ll then
            return {
                front = "ts_vehicles_hll_.png",
            }
        end
    end,
})

ts_vehicles.register_part("ts_vehicles_helicopters:helicopter_search_light", {
    description = "Helicopter Search Light",
    inventory_image = "ts_vehicles_helicopters_search_light.png",
    groups = { search_light = 1, },
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:helicopter_search_light",
    recipe = {
        { "", "", "" },
        { "techage:simplelamp_off", "ts_vehicles_common:lw_composite_material", "" },
        { "techage:simplelamp_off", "techage:simplelamp_off", "" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:helicopter_search_light", {
    get_overlay_textures = function()
        return {
            hull = "ts_vehicles_hsl.png",
        }
    end,
    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.sl then
            return {
                front = "ts_vehicles_hsl_.png",
            }
        end
    end,
})

ts_vehicles_common.register_gas_turbine_compatibility("ts_vehicles_helicopters:helicopter")

ts_vehicles_common.register_gasoline_tank()
ts_vehicles_common.register_hydrogen_tank()
ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:gasoline_tank", {
    gasoline_capacity = 280
})
ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:hydrogen_tank", {
    hydrogen_capacity = 2000
})

ts_vehicles_common.register_auxiliary_gasoline_tank()
ts_vehicles_common.register_auxiliary_hydrogen_tank()
ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:auxiliary_gasoline_tank", {
    gasoline_capacity = 280
})
ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:auxiliary_hydrogen_tank", {
    hydrogen_capacity = 2000
})

ts_vehicles.register_part("ts_vehicles_helicopters:payload_tank", {
    description = "Payload Tank for Helicopters",
    inventory_image = "ts_vehicles_helicopters_payload_tank.png",
    groups = { payload_tank = 1, },
    storage_capacity = -4000,
    payload_tank_capacity = 2000,
})

minetest.register_craft({
    output = "ts_vehicles_helicopters:payload_tank",
    recipe = {
        { "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "techage:oiltank", "ts_vehicles_common:lw_composite_material" },
        { "ts_vehicles_common:lw_composite_material", "techage:ta3_pipeS", "techage:ta3_pipeS" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_helicopters:payload_tank", {
    get_overlay_textures = function()
        return {
            hull = "ts_vehicles_hpt_.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:text", {
    get_overlay_textures = function(id, part)
        local meta = part:get_meta()
        local hull = ts_vehicles.write(meta:get_string("hull"), 147, 16, 1, ts_vehicles.get_part_color(part), 1, true)
        local tail = ts_vehicles.write(meta:get_string("tail"), 81, 16, 1, ts_vehicles.get_part_color(part), 1, true)

        return {
            hull = hull and "[combine:396x396:12,72=(" .. E(hull) .. "):12,171=(" .. E(hull) .. ")" or nil,
            tail = tail and "[combine:384x384:69,199=(" .. E(tail) .. "):234,199=(" .. E(tail) .. ")" or nil,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_helicopters:helicopter", "ts_vehicles_common:wrapping", {
    get_overlay_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        local meta = part:get_meta()
        local wrappings = ts_vehicles.registered_vehicle_bases["ts_vehicles_helicopters:helicopter"].wrappings
        local hull_number = ts_vehicles.helpers.index_of(wrappings.hull.values, meta:get_string("hull"))
        local hull = ""
        if hull_number then
            hull = "(ts_vehicles_hwh" .. hull_number .. ".png^[multiply:" .. color .. ")"
        end
        return {
            hull = hull ~= "" and hull or nil,
        }
    end,
})