-- Vehicle Data
local VD = ts_vehicles.get

local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_cars:truck", {
    inventory_image = "ts_vehicles_cars_truck_construction_stand.png",
    description = "Truck",
    item_description = "Truck Construction Stand",
    collisionbox = { -1.55, -0.5, -1.55, 1.55, 2, 1.55 },
    selectionbox = { -1.65, -0.5, -1.65, 1.65, 2, 1.65 },
    mesh = "ts_vehicles_cars_truck.obj",
    lighting_mesh = "ts_vehicles_cars_truck.b3d",
    -- The names are intentional; the mapping to the actual textures should happen in API,
    -- according to the get_texture functions of the registered compatibilities.
    textures = {
        "base_plate",
        "tires",
        "cabin",
        "interior",
        "rear_panel",
        "undercarriage",
        "pillars_a",
        "roof",
        "roof_attachment",
        "seats",
        "glass",
        "platform",
        "framework",
        "tank",
        "platform_top",
        "body",
        "body_inside",
        "rear_board",
    },
    lighting_textures = {
        "chassis_1",
        "chassis_2",
        "chassis",
        "rear_board_2",
        "rear_board",
        "rear_board_1",
        "roof_attachment_1",
        "roof_attachment_2",
        "roof_attachment",
    },
    on_step = ts_vehicles.car_on_step,
    efficiency = .7,
    driver_pos = { x = -5, y = 6.5, z = 13.7 },
    passenger_pos = {
        { x = 5, y = 6.5, z = 13.7 },
    },
    get_fallback_textures = function()
        return {
            tires = "ts_vehicles_ctcs.png",
        }
    end,
    is_driveable = function(self)
        local parts = VD(self._id).parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        if not has("undercarriage") then return false, "A truck needs an undercarriage." end
        if not has("base_plate") then return false, "A truck needs a base plate." end
        if not has("tires") then return false, "A truck needs tires." end
        if not has("cabin") then return false, "A truck needs a cabin." end
        if not has("rear_panel") then return false, "A truck needs a cabin rear panel." end
        if not has("windscreen") then return false, "A truck needs a windscreen." end
        if not has("roof") then return false, "A truck needs a roof." end
        if not has("platform") then return false, "A truck needs a platform." end
        if not has("interior") then return false, "A truck needs an interior." end
        if not has("seats") then return false, "A truck needs seats." end
        if not has("direction_indicator") then return false, "A truck needs direction indicators." end
        if not has("lights_front") then return false, "A truck needs front lights." end
        if not has("lights_back") then return false, "A truck needs back lights." end
        if not has("lights_reversing") then return false, "A truck needs reversing lights." end
        if not has("engine") then return false, "A truck needs an engine." end
        if not has("main_tank") then return false, "A truck needs a tank or battery." end
        return true
    end,
    is_structure_sound = function(self, parts)
        local id = self._id
        local vd = VD(id)
        parts = parts or vd.parts
        local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
        local has_multiple = function(group, max) return ts_vehicles.helpers.multiple_have_group(parts, group, max) end
        if has_multiple("undercarriage") then
            return false, "A truck cannot have multiple undercarriages."
        end
        if has("base_plate") and not has("undercarriage") then
            return false, "An undercarriage is required to mount the base plate."
        end
        if has_multiple("base_plate") then
            return false, "A truck cannot have multiple base plates."
        end
        if has("tires") and not has("base_plate") then
            return false, "A base plate is required to mount the tires."
        end
        if has_multiple("tires") then
            return false, "A truck cannot have multiple sets of tires."
        end
        if has("rear_panel") and not has("base_plate") then
            return false, "A base plate is required to mount the cabin rear panel."
        end
        if has_multiple("rear_panel") then
            return false, "A truck cannot have multiple cabin rear panels."
        end
        if has("cabin") and not has("base_plate") then
            return false, "A base plate is required to mount the cabin."
        end
        if has_multiple("cabin") then
            return false, "A truck cannot have multiple cabins."
        end
        if has("chassis_pillars_a") and not has("cabin") then
            return false, "A cabin is required to mount the pillars."
        end
        if has_multiple("chassis_pillars_a") then
            return false, "A truck cannot have multiple pairs of the same pillars."
        end
        if has("windscreen") and not (has("chassis_pillars_a") and has("rear_panel")) then
            return false, "Pillars (A) and a cabin rear panel are required to mount the windscreen."
        end
        if has_multiple("windscreen") then
            return false, "A truck cannot have multiple windscreens."
        end
        if has("roof") and not (has("chassis_pillars_a") and has("rear_panel")) then
            return false, "Pillars (A) and a cabin rear panel are required to mount the roof."
        end
        if has_multiple("roof") then
            return false, "A truck cannot have multiple roofs."
        end
        if has("interior") and not (has("cabin") and has("rear_panel")) then
            return false, "A cabin and a cabin rear panel is required to mount the interior."
        end
        if has_multiple("interior") then
            return false, "A truck cannot have multiple interiors."
        end
        if has("seats") and not has("cabin") then
            return false, "A cabin is required to mount the seats."
        end
        if has_multiple("seats") then
            return false, "A truck cannot have multiple sets of seats."
        end
        if has("light") and not (has("cabin") and has("roof") and has("platform")) then
            return false, "A full cabin (incl. roof) and a platform are required to mount lights."
        end
        if has_multiple("lights_front") or has_multiple("lights_back") or has_multiple("lights_reversing") or has_multiple("direction_indicator") then
            return false, "A truck cannot have multiple lights of the same type."
        end
        if has("license_plate") and not (has("cabin") and has("platform")) then
            return false, "A cabin and a platform are required to mount the license plates."
        end
        if has_multiple("license_plate") then
            return false, "A truck cannot have multiple license plates."
        end
        if has("wrapping") and not (has("cabin") and has("platform")) then
            return false, "A cabin and a platform are required to install a wrapping."
        end
        if has_multiple("wrapping", 10) then
            return false, "Too many wrappings."
        end
        if has("roof_attachment") and not (has("roof") and has("platform")) then
            return false, "A roof and a platform are required to mount a roof top attachment."
        end
        if has_multiple("roof_attachment") then
            return false, "A truck cannot have multiple roof top attachments."
        end
        if has("full_body") and not has("platform") then
            return false, "A platform is required to mount the body."
        end
        if has("full_body") and has("panel") then
            return false, "A truck cannot have a body and side panels."
        end
        if has_multiple("full_body") then
            return false, "A truck cannot have multiple bodies."
        end
        if has("panel") and not has("platform") then
            return false, "A platform is required to mount the panels."
        end
        if has_multiple("panel") then
            return false, "A truck cannot have multiple sets of panels."
        end
        if has("tarp") and not has("panel") then
            return false, "Side panels are required to mount the tarp."
        end
        if has_multiple("tarp") then
            return false, "A truck cannot have multiple tarps."
        end
        if has("tarp") and has("payload_tank") then
            return false, "A truck can either have a tarp or a payload tank, not both."
        end
        if has("rear_board") and not has("panel") then
            return false, "Panels are required to mount the rear board."
        end
        if has("rear_board") and has("payload_tank") then
            return false, "No payload tanks are allowed when using the rear board."
        end
        if has_multiple("rear_board") then
            return false, "A truck cannot have multiple rear boards."
        end
        if has("payload_tank") and not has("panel") then
            return false, "Panels are required before mounting the payload tank."
        end
        if has_multiple("payload_tank") then
            return false, "A truck cannot have multiple payload tanks."
        end
        if has("engine") and not (has("cabin") and has("platform")) then
            return false, "A cabin and a platform are required to mount the engine."
        end
        if has_multiple("engine") then
            return false, "A truck cannot have multiple engines."
        end
        if has("main_tank") and not (has("cabin") and has("platform")) then
            return false, "A cabin and a platform are required to mount this tank or battery."
        end
        if has_multiple("main_tank") then
            return false, "A truck cannot have multiple fuel tanks or batteries."
        end
        if has("auxiliary_tank") and not (has("cabin") and has("platform")) then
            return false, "A cabin and a platform are required to mount this auxiliary tank or battery."
        end
        if has_multiple("auxiliary_tank") then
            return false, "A truck cannot have multiple auxiliary tanks or batteries."
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
        if ts_vehicles.helpers.get_total_value(self._id, "electricity_capacity", parts) < (vd.data.electricity or 0) then
            return false, "Not enough electricity capacity."
        end
        return ts_vehicles_common.is_wrapping_structure_sound(self, parts)
    end,
    legacy_data = {
        counts = {
            ["ts_vehicles_cars:tire"] = 4,
            ["ts_vehicles_cars:seat"] = 2,
        },
        colors = {
            ["ts_vehicles_cars:truck_cabin"] = "cabin",
            ["ts_vehicles_cars:truck_platform"] = "platform",
            ["ts_vehicles_cars:truck_panels"] = "panel",
            ["ts_vehicles_cars:tarp"] = "tarp",
            ["ts_vehicles_cars:payload_tank"] = "tank",
            ["ts_vehicles_cars:combined_module"] = "combined_module",
            ["ts_vehicles_cars:car_chassis_pillars_a"] = "pillars_a",
            ["ts_vehicles_cars:car_roof"] = "roof",
            ["ts_vehicles_cars:car_interior"] = "interior",
            ["ts_vehicles_cars:seat"] = "seats",
            ["ts_vehicles_cars:chassis_stripe"] = "chassis_stripe",
        },
        colors_original_part_names = {
            ["ts_vehicles_cars:panels_text"] = "panels_text",
            ["ts_vehicles_cars:tarp_text"] = "tarp_text",
            ["ts_vehicles_cars:chassis_text"] = "chassis_text",
        },
        functions = {
            ["ts_vehicles_common:text"] = function(self, part)
                local vd = VD(self._id)
                local meta = part:get_meta()
                local original_part_name = meta:get_string("original_part_name")
                if original_part_name == "ts_vehicles_cars:chassis_text" and vd.data.chassis_text then
                    meta:set_string("cabin", vd.data.chassis_text)
                    meta:set_int("set", 1)
                    vd.data.chassis_text = nil
                end
                if original_part_name == "ts_vehicles_cars:panels_text" and vd.data.panels_text then
                    meta:set_string("panels_side", vd.data.panels_text)
                    meta:set_string("panels_back", vd.data.panels_text)
                    meta:set_int("set", 1)
                    vd.data.panels_text = nil
                end
                if original_part_name == "ts_vehicles_cars:tarp_text" and vd.data.tarp_text then
                    meta:set_string("tarp_side", vd.data.tarp_text)
                    meta:set_string("tarp_back", vd.data.tarp_text)
                    meta:set_int("set", 1)
                    vd.data.tarp_text = nil
                end
            end,
            ["ts_vehicles_common:wrapping"] = function(self, part)
                local vd = VD(self._id)
                if vd.tmp["ts_vehicles_common:wrapping_color_adjusted"] then
                    local meta = part:get_meta()
                    meta:set_string("cabin", "Stripe")
                end
            end,
        },
    },
    gasoline_hose_offset = vector.new(1.4, .25, .75),
    hydrogen_hose_offset = vector.new(1.4, .25, .75),
    electricity_hose_offset = vector.new(1.4, .25, .75),
    payload_tank_hose_offset = vector.new(1.4, .25, -2.05),
    texts = {
        cabin = { name = "Cabin", lines = 2 },
        panels_side = { name = "Panels (Side)", lines = 2, requires = "panel" },
        panels_back = { name = "Panels (Back)", lines = 2, requires = "panel" },
        tarp_side = { name = "Tarp (Side)", lines = 3, requires = "tarp" },
        tarp_back = { name = "Tarp (Back)", lines = 3, requires = "tarp" },
    },
    wrappings = {
        cabin = { name = "Cabin", values = { "Stripe", "Lines", "Battenberg A", "Battenberg B" } },
        panels_side = { name = "Panels (Side)", values = { "Battenberg A", "Battenberg B" }, requires = "panel" },
        panels_back = { name = "Panels (Back)", values = { "Chevron A", "Chevron B" }, requires = "panel" },
        tarp_back = { name = "Tarp (Back)", values = { "Stripe", "Lines", "Chevron A", "Chevron B" }, requires = "tarp" },
    },
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck",
    recipe = {
        { "default:steelblock", "", "default:steelblock" },
        { "", "dye:orange", "" },
        { "default:steelblock", "", "default:steelblock" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:truck_undercarriage", {
    description = "Truck Undercarriage",
    inventory_image = "ts_vehicles_cars_truck_undercarriage.png",
    groups = { undercarriage = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_undercarriage",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "", "ts_vehicles_common:composite_material", "" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:truck_cabin_rear_panel", {
    description = "Truck Cabin Rear Panel",
    inventory_image = "ts_vehicles_cbp.png^[mask:ts_vehicles_cars_cabin_rear_panel_inv_mask.png",
    groups = { rear_panel = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_cabin_rear_panel",
    recipe = {
        { "default:steel_ingot", "ts_vehicles_cars:base_plate", "default:steel_ingot" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:truck_cabin", {
    description = "Truck Cabin",
    inventory_image = "ts_vehicles_cars_truck_cabin.png",
    groups = { cabin = 1 },
    colorable = true,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_cabin",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "" },
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:truck_platform", {
    description = "Truck Platform",
    inventory_image = "ts_vehicles_cars_truck_platform.png",
    inventory_overlay = "ts_vehicles_cars_truck_platform_overlay.png",
    groups = { platform = 1 },
    colorable = true,
    storage_capacity = 1000,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_platform",
    recipe = {
        { "ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:truck_panels", {
    description = "Truck Side Panels",
    inventory_image = "ts_vehicles_cars_truck_side_panels.png",
    groups = { panel = 1 },
    colorable = true,
    storage_capacity = 7000,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_panels",
    recipe = {
        { "default:wood", "ts_vehicles_common:composite_material", "default:wood" },
        { "default:wood", "ts_vehicles_common:composite_material", "default:wood" },
        { "default:wood", "ts_vehicles_common:composite_material", "default:wood" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:tarp", {
    description = "Truck Tarp",
    inventory_image = "ts_vehicles_cars_tarp.png",
    groups = { tarp = 1 },
    colorable = true,
    storage_capacity = 10000,
})

minetest.register_craft({
    output = "ts_vehicles_cars:tarp",
    recipe = {
        { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
        { "basic_materials:plastic_sheet", "farming:string", "basic_materials:plastic_sheet" },
        { "basic_materials:plastic_sheet", "farming:string", "basic_materials:plastic_sheet" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:payload_tank", {
    description = "Payload Tank",
    inventory_image = "ts_vehicles_cars_payload_tank.png",
    groups = { payload_tank = 1 },
    colorable = true,
    storage_capacity = -6000,
    payload_tank_capacity = 4000,
})

minetest.register_craft({
    output = "ts_vehicles_cars:payload_tank",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "techage:oiltank", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "techage:ta3_pipeS", "techage:ta3_pipeS" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:combined_module", {
    description = "Combined Tank and Storage Module",
    inventory_image = "ts_vehicles_cars_combined_module.png",
    groups = { full_body = 1 },
    colorable = true,
    storage_capacity = 4000,
    payload_tank_capacity = 2000,
})

minetest.register_craft({
    output = "ts_vehicles_cars:combined_module",
    recipe = {
        { "ts_vehicles_common:composite_material", "ts_vehicles_cars:payload_tank", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "default:mese_block", "ts_vehicles_common:composite_material" },
        { "ts_vehicles_common:composite_material", "techage:chest_ta4", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_part("ts_vehicles_cars:warning_board", {
    description = "Truck Warning Board",
    inventory_image = "ts_vehicles_cars_warning_board.png",
    groups = { rear_board = 1 },
    get_formspec = function(self, player)
        local vd = VD(self._id)
        vd.data.warning_board = vd.data.warning_board or {}
        local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
        local fs = ""
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[0,-.75;Configure the Warning Board]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        fs = fs .. "label[0,0;Choose Slot:]"
        fs = fs .. "button[0,.25;1.5,.75;slot1;Slot 1]"
        fs = fs .. "button[1.5,.25;1.5,.75;slot2;Slot 2]"
        fs = fs .. "button[3,.25;1.5,.75;slot3;Slot 3]"
        fs = fs .. "button[4.5,.25;1.5,.75;slot4;Slot 4]"
        fs = fs .. "button[6,.25;1.5,.75;slot5;Slot 5]"
        fs = fs .. "button[7.5,.25;1.5,.75;off;Off]"
        if current_data then
            fs = fs .. "style_type[textarea;font=mono]"
            fs = fs .. "textarea[0,1.5;5,5.5;symbol;Matrix Image:;" .. minetest.formspec_escape(current_data.symbol or "") .. "]"
            fs = fs .. "style_type[textarea;font=normal]"
            fs = fs .. "textarea[0,7.5;5,1.5;text;Warning Message:;" .. minetest.formspec_escape(current_data.text or "") .. "]"
            fs = fs .. "button[0,9.25;1.5,1;set;Set]"
        end
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        local vd = VD(self._id)
        vd.data.warning_board = vd.data.warning_board or {}
        if fields.text and fields.symbol and fields.set then
            local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
            if current_data then
                current_data.symbol = fields.symbol:sub(1, 300)
                current_data.text = fields.text:sub(1, 200)
            end
        end
        if fields.slot1 then vd.data.warning_board.current_slot = "slot1" end
        if fields.slot2 then vd.data.warning_board.current_slot = "slot2" end
        if fields.slot3 then vd.data.warning_board.current_slot = "slot3" end
        if fields.slot4 then vd.data.warning_board.current_slot = "slot4" end
        if fields.slot5 then vd.data.warning_board.current_slot = "slot5" end
        if fields.off then vd.data.warning_board.current_slot = "off" end
        vd.tmp.light_textures_set = false
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.warning_board = {
            current_slot = "slot1",
            slot1 = {
                symbol = "AAAAAAAMMAAAAAAA AAAAAAMMMMAAAAAA AAAAAAMMMMAAAAAA AAAAAMMAAMMAAAAA AAAAAMMAAMMAAAAA AAAAMMA//AMMAAAA AAAAMMA//AMMAAAA AAAMMAA//AAMMAAA AAAMMAA//AAMMAAA AAMMAAA//AAAMMAA AAMMAAAAAAAAMMAA AMMAAAA//AAAAMMA AMMAAAA//AAAAMMA MMAAAAAAAAAAAAMM MMMMMMMMMMMMMMMM MMMMMMMMMMMMMMMM",
                text = "Achtung! Baustelle\n\nCaution!\nRoad Work Ahead",
            },
            slot2 = {
                symbol = "AAAAAAMMMMAAAAAA AAAAMMMMMMMMAAAA AAMMMMAAAAMMMMAA AAMMAAAAAAAAMMAA AMMAAAAAAAAAAMMA AMMAAAAAAAAAAMMA MMAAAAAAAAAAAAMM MMAA////////AAMM MMAA////////AAMM MMAAAAAAAAAAAAMM AMMAAAAAAAAAAMMA AMMAAAAAAAAAAMMA AAMMAAAAAAAAMMAA AAMMMMAAAAMMMMAA AAAAMMMMMMMMAAAA AAAAAAMMMMAAAAAA",
                text = "KEINE DURCHFAHRT\n\nROAD CLOSED"
            },
            slot3 = {
                symbol = "AAAAAADDDDAAAAAA AAAADDDDDDDDAAAA AADDDDDDDDDDDDAA AADDDDDDDDD//DAA ADDDDDDDDD///DDA ADDDDDDDD///DDDA DDD//DDD///DDDDD DDD//DD///DDDDDD DDD//D///DDDDDDD DDD/////DDDDDDDD ADD////DDDDDDDDA ADD///////DDDDDA AAD///////DDDDAA AADDDDDDDDDDDDAA AAAADDDDDDDDAAAA AAAAAADDDDAAAAAA",
                text = "Links fahren\n\nKeep Left"
            },
            slot4 = {
                symbol = "AAAAAADDDDAAAAAA AAAADDDDDDDDAAAA AADDDDDDDDDDDDAA AAD//DDDDDDDDDAA ADD///DDDDDDDDDA ADDD///DDDDDDDDA DDDDD///DDD//DDD DDDDDD///DD//DDD DDDDDDD///D//DDD DDDDDDDD/////DDD ADDDDDDDD////DDA ADDDDD///////DDA AADDDD///////DAA AADDDDDDDDDDDDAA AAAADDDDDDDDAAAA AAAAAADDDDAAAAAA",
                text = "Rechts fahren\n\nKeep Right"
            },
            slot5 = {
                symbol = "AsAAAAAAAAAAAAsA sssAAAAAAAAAAsss AsssAAAAAAAAsssA AAsssAAAAAAsssAA AAAsssAAAAsssAAA AAAAsssAAsssAAAA AAAAAssssssAAAAA AAAAAAssssAAAAAA AAAAAAssssAAAAAA AAAAAssssssAAAAA AAAAsssAAsssAAAA AAAsssAAAAsssAAA AAsssAAAAAAsssAA AsssAAAAAAAAsssA sssAAAAAAAAAAsss AsAAAAAAAAAAAAsA",
                text = "Fahrspur gesperrt\n\nLane Closed"
            }
        }
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.warning_board = nil
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:warning_board",
    recipe = {
        { "dye:red", "ts_vehicles_cars:amber_light", "dye:red" },
        { "dye:white", "ta4_addons:matrix_screen", "dye:white" },
        { "ts_vehicles_common:composite_material", "techage:ta4_leds", "ts_vehicles_common:composite_material" },
    },
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_undercarriage", {
    get_textures = function()
        return {
            undercarriage = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:tire", {
    quantity = 4,
    get_textures = function()
        return {
            tires = "ts_vehicles_ct.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:base_plate", {
    get_textures = function()
        return {
            base_plate = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_cabin_rear_panel", {
    get_textures = function()
        return {
            rear_panel = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_cabin", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            cabin = "ts_vehicles_ctc.png^[multiply:" .. color .. "^ts_vehicles_ctc_.png",
        }
    end,
    get_fallback_textures = function(id)
        local vd = VD(id)
        local color = "#fff"
        if vd.data.cabin_color then
            color = vd.data.cabin_color
        end
        return {
            interior = "ts_vehicles_cti.png^[multiply:" .. color
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_platform", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            platform_top = "default_wood.png",
            platform = "ts_vehicles_ctp.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_panels", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            framework = "ts_vehicles_ctfp.png^[multiply:" .. color,
            body = "ts_vehicles_ctsp.png^[multiply:" .. color,
            body_inside = "ts_vehicles_ctsp.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:tarp", {
    get_overlay_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            framework = "(ts_vehicles_ctft.png^[multiply:" .. color .. ")",
            body = "(ts_vehicles_ctt.png^[multiply:" .. color .. ")",
            body_inside = "(ts_vehicles_ctt.png^[multiply:" .. color .. ")",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:payload_tank", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            tank = "ts_vehicles_ctpt.png^[multiply:" .. color,
        }
    end,
    get_overlay_textures = function()
        return {
            platform = "ts_vehicles_ctpt_.png"
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:combined_module", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            body = "ts_vehicles_ctcm.png^[multiply:" .. color,
            framework = "ts_vehicles_ctfcm.png^[multiply:" .. color,
        }
    end,
    get_overlay_textures = function()
        return {
            platform = "ts_vehicles_ctpt_.png",
            body = "ts_vehicles_ctcm_.png",
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:warning_board", {
    get_textures = function()
        return {
            rear_board = "ts_vehicles_ctwb.png"
        }
    end,
    get_overlay_textures = function()
        return {
            framework = "ts_vehicles_ctfw.png"
        }
    end,
    get_light_textures = function(id)
        local vd = VD(id)
        local result = {}
        if vd.lights.special then
            result.rear_board_1 = "ts_vehicles_ctwb_.png^[transformFX"
            result.rear_board_2 = "ts_vehicles_ctwb_.png"
        end
        local texture = "[combine:304x304"
        vd.data.warning_board = vd.data.warning_board or {}
        local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
        if ts_vehicles.writing and current_data then
            local text = ts_vehicles.write(current_data.text, 192, 64, 4, "#c80", 1.5)
            texture = texture .. ":8,144=" .. E(text)
        end
        if minetest.get_modpath("ta4_addons") and ta4_addons.base64_to_texture and current_data then
            local symbol = ta4_addons.base64_to_texture(current_data.symbol or "")
            texture = texture .. ":88,8=" .. E(symbol)
        end
        result.rear_board = texture
        return result
    end,
    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.special then
            return {
                chassis_1 = "ts_vehicles_ctsl_.png",
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_chassis_pillars_a", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            pillars_a = "ts_vehicles_cp.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:windows", {
    get_textures = function()
        return {
            glass = "ts_vehicles_ctw.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_roof", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            roof = "ts_vehicles_cr.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_interior", {
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            interior = "ts_vehicles_cti.png^[multiply:" .. color .. "^ts_vehicles_cti_.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_common:seat", {
    quantity = 2,
    get_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        return {
            seats = "wool_white.png^[multiply:" .. color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:direction_indicator", {
    get_overlay_textures = function()
        return {
            cabin = "(ts_vehicles_ctdf.png)",
            platform = "(ts_vehicles_ctdb.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        local tmp = {}
        if vd.lights.left or vd.lights.warn then
            tmp[#tmp + 1] = "(ts_vehicles_ctdl_.png)"
        end
        if vd.lights.right or vd.lights.warn then
            tmp[#tmp + 1] = "(ts_vehicles_ctdr_.png)"
        end
        if #tmp > 0 then
            return {
                chassis_1 = table.concat(tmp, "^")
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_front", {
    get_overlay_textures = function()
        return {
            cabin = "(ts_vehicles_ctfl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.front then
            return {
                chassis = "(ts_vehicles_ctfl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_back", {
    get_overlay_textures = function()
        return {
            platform = "(ts_vehicles_ctbl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.lights.stop then
            return {
                chassis = "(ts_vehicles_ctbl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_reversing", {
    get_overlay_textures = function()
        return {
            platform = "(ts_vehicles_ctrl.png)",
        }
    end,

    get_light_overlay_textures = function(id)
        local vd = VD(id)
        if vd.v < 0 then
            return {
                chassis = "(ts_vehicles_ctrl_.png)",
            }
        end
    end
})

for _, def in ipairs(ts_vehicles_cars.lightbars) do
    ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:" .. def.id .. "_light", {
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
        get_overlay_textures = function()
            return {
                platform = def.off:gsub("%.png", "_tp.png")
            }
        end,
        get_light_overlay_textures = function(id)
            local vd = VD(id)
            if vd.lights.special then
                return {
                    chassis_1 = "(" .. def.on1:gsub("%.png", "_tp.png") .. ")^ts_vehicles_ctsl_.png",
                    chassis_2 = "(" .. def.on2:gsub("%.png", "_tp.png") .. ")"
                }
            end
        end,
    })
end

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:license_plate", {
    get_overlay_textures = function(id)
        local vd = VD(id)
        local text = ts_vehicles.write(vd.data.license_plate_text, 80, 16, 1, "#000")
        return {
            cabin = "ts_vehicles_ctlpf.png^[combine:384x384:152,228=(" .. E(text) .. ")",
            platform = "ts_vehicles_ctlpb.png^[combine:448x448:184,316=(" .. E(text) .. ")"
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_common:text", {
    get_overlay_textures = function(id, part)
        local has = function(group) return ts_vehicles.helpers.any_has_group(VD(id).parts, group) end
        local meta = part:get_meta()
        local cabin = ts_vehicles.write(meta:get_string("cabin"), 152, 32, 2, ts_vehicles.get_part_color(part), 1, true)
        local panels_side = has("panel") and ts_vehicles.write(meta:get_string("panels_side"), 212, 32, 2, ts_vehicles.get_part_color(part), 2, true)
        local panels_back = has("panel") and ts_vehicles.write(meta:get_string("panels_back"), 212, 32, 2, ts_vehicles.get_part_color(part), 1, true)
        local tarp_side = has("tarp") and ts_vehicles.write(meta:get_string("tarp_side"), 212, 48, 3, ts_vehicles.get_part_color(part), 2, true)
        local tarp_back = has("tarp") and ts_vehicles.write(meta:get_string("tarp_back"), 212, 48, 3, ts_vehicles.get_part_color(part), 1, true)
        local body
        if panels_side or panels_back or tarp_side or tarp_back then
            body = "[combine:800x800"
            if panels_side then
                body = body .. ":0,488=(" .. E(panels_side) .. "):0,736=(" .. E(panels_side) .. ")"
            end
            if panels_back then
                body = body .. ":542,752=(" .. E(panels_back) .. ")"
            end
            if tarp_side then
                body = body .. ":0,312=(" .. E(tarp_side) .. "):0,560=(" .. E(tarp_side) .. ")"
            end
            if tarp_back then
                body = body .. ":542,584=(" .. E(tarp_back) .. ")"
            end
        end

        return {
            cabin = cabin and "[combine:384x384:0,52=(" .. E(cabin) .. "):232,52=(" .. E(cabin) .. ")" or nil,
            body = body,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_common:wrapping", {
    get_overlay_textures = function(id, part)
        local color = ts_vehicles.get_part_color(part)
        local meta = part:get_meta()
        local wrappings = ts_vehicles.registered_vehicle_bases["ts_vehicles_cars:truck"].wrappings
        local cabin_number = ts_vehicles.helpers.index_of(wrappings.cabin.values, meta:get_string("cabin"))
        local panels_side_number = ts_vehicles.helpers.index_of(wrappings.panels_side.values, meta:get_string("panels_side"))
        local panels_back_number = ts_vehicles.helpers.index_of(wrappings.panels_back.values, meta:get_string("panels_back"))
        local tarp_back_number = ts_vehicles.helpers.index_of(wrappings.tarp_back.values, meta:get_string("tarp_back"))
        local cabin = ""
        local body = {}
        if cabin_number then
            cabin = "(ts_vehicles_ctwc" .. cabin_number .. ".png^[multiply:" .. color .. ")"
        end
        if panels_side_number then
            body[#body + 1] = "(ts_vehicles_ctwps" .. panels_side_number .. ".png^[multiply:" .. color .. ")"
        end
        if panels_back_number then
            body[#body + 1] = "(ts_vehicles_ctwpb" .. panels_back_number .. ".png^[multiply:" .. color .. ")"
        end
        if tarp_back_number then
            body[#body + 1] = "(ts_vehicles_ctwtb" .. tarp_back_number .. ".png^[multiply:" .. color .. ")"
        end
        return {
            cabin = cabin ~= "" and cabin or nil,
            body = #body > 0 and table.concat(body, "^") or nil,
        }
    end,
})

ts_vehicles_common.register_engine_compatibility("ts_vehicles_cars:truck")
ts_vehicles_common.register_tank_compatibility("ts_vehicles_cars:truck")
ts_vehicles_common.register_aux_tank_compatibility("ts_vehicles_cars:truck")