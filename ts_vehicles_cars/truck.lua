-- Vehicle Data
local VD = ts_vehicles.get

local function E(text)
    return text:gsub("%^", "\\%^"):gsub(":", "\\:")
end

ts_vehicles.register_vehicle_base("ts_vehicles_cars:truck", {
    inventory_image = "ts_vehicles_cars_truck_construction_stand_inv.png",
    description = "Truck",
    item_description = "Truck Construction Stand",
    collisionbox = {-1.55, -0.5, -1.55, 1.55, 2, 1.55},
    selectionbox = {-1.65, -0.5, -1.65, 1.65, 2, 1.65},
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
    initial_parts = {},
    driver_pos = { x = -5, y = 6.5, z = 13.7 },
    passenger_pos = {
        { x = 5, y = 6.5, z = 13.7 },
    },
    get_fallback_textures = function(self)
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
        local has_multiple = function(group) return ts_vehicles.helpers.multiple_have_group(parts, group) end
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
        if has("cabin_accessory") and not has("cabin") then
            return false, "A cabin is required to mount accessories."
        end
        if has("panel_accessory") and not has("panel") then
            return false, "A panel is required to mount accessories."
        end
        if has("tarp_accessory") and not has("tarp") then
            return false, "A tarp is required to mount accessories."
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
        if has("rear_board") and (has("tarp") or has("payload_tank")) then
            return false, "No tarps or payload tanks are allowed when using the rear board."
        end
        if has_multiple("rear_board") then
            return false, "A truck cannot have multiple rear boards."
        end
        if has("payload_tank") and not has("panel") then
            return false, "Panels are required before mounting the payload tank."
        end
        if has_multiple("payload_tank") then
            return false, "A truck cannot have multiple payload tanks"
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
        if ts_vehicles.helpers.get_total_value(self, "storage_capacity", parts) < ts_vehicles.storage.get_total_count(id) then
            return false, "Not enough space."
        end
        if ts_vehicles.helpers.get_total_value(self, "payload_tank_capacity", parts) < (vd.data.payload_tank_amount or 0) then
            return false, "Not enough payload tank capacity."
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
            if part_def.groups.tires then
                return ItemStack(part_name.." 4")
            elseif part_def.groups.seats then
                return ItemStack(part_name.." 2")
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
            if part_def.groups.tires then
                if item:get_count() < 4 then
                    return false, "Not enough items; 4 are required."
                end
                item:take_item(4)
                return true, nil, item
            end
            if part_def.groups.seats then
                if item:get_count() < 2 then
                    return false, "Not enough items; 2 are required."
                end
                item:take_item(2)
                return true, nil, item
            end
        end
        item:take_item()
        return true, nil, item
    end,

    gasoline_hose_offset = vector.new(1.4, .25, .75),
    hydrogen_hose_offset = vector.new(1.4, .25, .75),
    electricity_hose_offset = vector.new(1.4, .25, .75),
    payload_tank_hose_offset = vector.new(1.4, .25, -2.05),
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck",
    recipe = {
        {"default:steelblock", "", "default:steelblock"},
        {"", "dye:orange", ""},
        {"default:steelblock", "", "default:steelblock"},
    },
})



ts_vehicles.register_part("ts_vehicles_cars:truck_undercarriage", {
    description = "Truck Undercarriage",
    inventory_image = "ts_vehicles_cars_truck_undercarriage_inv.png",
    groups = { undercarriage = 1 },
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_undercarriage",
    recipe = {
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"", "ts_vehicles_common:composite_material", ""},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
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
        {"default:steel_ingot", "ts_vehicles_cars:base_plate", "default:steel_ingot"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:truck_cabin", {
    description = "Truck Cabin",
    inventory_image = "ts_vehicles_cars_truck_cabin_inv.png",
    groups = { cabin = 1 },
    colorable = true,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.cabin_color = color
            vd.data.cabin_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.cabin_color then
            drop:get_meta():set_string("color", vd.data.cabin_color)
        end
        if vd.data.cabin_description then
            drop:get_meta():set_string("description", vd.data.cabin_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_cabin",
    recipe = {
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", ""},
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:truck_platform", {
    description = "Truck Platform",
    inventory_image = "ts_vehicles_cars_truck_platform_inv.png",
    inventory_overlay = "ts_vehicles_cars_truck_platform_inv_overlay.png",
    groups = { platform = 1 },
    colorable = true,
    storage_capacity = 1000,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.platform_color = color
            vd.data.platform_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.platform_color then
            drop:get_meta():set_string("color", vd.data.platform_color)
        end
        if vd.data.platform_description then
            drop:get_meta():set_string("description", vd.data.platform_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_platform",
    recipe = {
        {"ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "default:wood", "ts_vehicles_common:composite_material"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:truck_panels", {
    description = "Truck Side Panels",
    inventory_image = "ts_vehicles_cars_truck_side_panels_inv.png",
    groups = { panel = 1 },
    colorable = true,
    storage_capacity = 7000,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.panel_color = color
            vd.data.panel_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.panel_color then
            drop:get_meta():set_string("color", vd.data.panel_color)
        end
        if vd.data.panel_description then
            drop:get_meta():set_string("description", vd.data.panel_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:truck_panels",
    recipe = {
        {"default:wood", "ts_vehicles_common:composite_material", "default:wood"},
        {"default:wood", "ts_vehicles_common:composite_material", "default:wood"},
        {"default:wood", "ts_vehicles_common:composite_material", "default:wood"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:tarp", {
    description = "Truck Tarp",
    inventory_image = "ts_vehicles_cars_tarp_inv.png",
    groups = { tarp = 1 },
    colorable = true,
    storage_capacity = 10000,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.tarp_color = color
            vd.data.tarp_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.tarp_color then
            drop:get_meta():set_string("color", vd.data.tarp_color)
        end
        if vd.data.tarp_description then
            drop:get_meta():set_string("description", vd.data.tarp_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:tarp",
    recipe = {
        {"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
        {"basic_materials:plastic_sheet", "farming:string", "basic_materials:plastic_sheet"},
        {"basic_materials:plastic_sheet", "farming:string", "basic_materials:plastic_sheet"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:payload_tank", {
    description = "Payload Tank",
    inventory_image = "ts_vehicles_cars_payload_tank_inv.png",
    groups = { payload_tank = 1 },
    colorable = true,
    storage_capacity = -7500,
    payload_tank_capacity = 4000,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.tank_color = color
            vd.data.tank_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.tank_color then
            drop:get_meta():set_string("color", vd.data.tank_color)
        end
        if vd.data.tank_description then
            drop:get_meta():set_string("description", vd.data.tank_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:payload_tank",
    recipe = {
        {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "techage:oiltank", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "techage:ta3_pipeS", "techage:ta3_pipeS"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:combined_module", {
    description = "Combined Tank and Storage Module",
    inventory_image = "ts_vehicles_cars_combined_module_inv.png",
    groups = { full_body = 1 },
    colorable = true,
    storage_capacity = 4000,
    payload_tank_capacity = 2000,
    after_part_add = function(self, item)
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            local vd = VD(self._id)
            vd.data.combined_module_color = color
            vd.data.combined_module_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        if vd.data.combined_module_color then
            drop:get_meta():set_string("color", vd.data.combined_module_color)
        end
        if vd.data.combined_module_description then
            drop:get_meta():set_string("description", vd.data.combined_module_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:combined_module",
    recipe = {
        {"ts_vehicles_common:composite_material", "ts_vehicles_cars:payload_tank", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "default:mese_block", "ts_vehicles_common:composite_material"},
        {"ts_vehicles_common:composite_material", "techage:chest_ta4", "ts_vehicles_common:composite_material"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:warning_board", {
    description = "Truck Warning Board",
    inventory_image = "ts_vehicles_cars_warning_board_inv.png",
    groups = { rear_board = 1 },
    get_formspec = function(self, player)
        local vd = VD(self._id)
        vd.data.warning_board = vd.data.warning_board or {}
        local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,-.75;Configure the Warning Board]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."label[0,0;Choose Slot:]"
        fs = fs.."button[0,.25;1.5,.75;slot1;Slot 1]"
        fs = fs.."button[1.5,.25;1.5,.75;slot2;Slot 2]"
        fs = fs.."button[3,.25;1.5,.75;slot3;Slot 3]"
        fs = fs.."button[4.5,.25;1.5,.75;slot4;Slot 4]"
        fs = fs.."button[6,.25;1.5,.75;slot5;Slot 5]"
        fs = fs.."button[7.5,.25;1.5,.75;off;Off]"
        if current_data then
            fs = fs.."style_type[textarea;font=mono]"
            fs = fs.."textarea[0,1.5;5,5.5;symbol;Matrix Image:;"..minetest.formspec_escape(current_data.symbol or "").."]"
            fs = fs.."style_type[textarea;font=normal]"
            fs = fs.."textarea[0,7.5;5,1.5;text;Warning Message:;"..minetest.formspec_escape(current_data.text or "").."]"
            fs = fs.."button[0,9.25;1.5,1;set;Set]"
        end
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        local vd = VD(self._id)
        vd.data.warning_board = vd.data.warning_board or {}
        if fields.text and fields.symbol and fields.set then
            local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
            if current_data then
                current_data.symbol = fields.symbol
                current_data.text = fields.text
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
        {"dye:red", "ts_vehicles_cars:amber_light", "dye:red"},
        {"dye:white", "ta4_addons:matrix_screen", "dye:white"},
        {"ts_vehicles_common:composite_material", "techage:ta4_leds", "ts_vehicles_common:composite_material"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:panels_text", {
    description = "Text on truck side panels",
    inventory_image = "ts_vehicles_cars_text_inv.png",
    inventory_overlay = "ts_vehicles_cars_panel_text_inv_overlay.png",
    groups = { panel_accessory = 1 },
    colorable = true,
    default_color = "#000",
    get_formspec = function(self, player)
        local vd = VD(self._id)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the panels]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."textarea[0,1;3,1;text;;"..minetest.formspec_escape(vd.data.panels_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            local vd = VD(self._id)
            vd.data.panels_text = fields.text
            vd.tmp.base_textures_set = false
        end
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.panels_text = "Placeholder Text"
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            vd.data.panels_text_color = color
            vd.data.panels_text_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.panels_text = nil
        if vd.data.panels_text_color then
            drop:get_meta():set_string("color", vd.data.panels_text_color)
        end
        if vd.data.panels_text_description then
            drop:get_meta():set_string("description", vd.data.panels_text_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:panels_text",
    recipe = {
        {"", "ts_vehicles_cars:chassis_text", ""},
        {"default:wood", "default:wood", "default:wood"},
    },
})


ts_vehicles.register_part("ts_vehicles_cars:tarp_text", {
    description = "Text on tarp",
    inventory_image = "ts_vehicles_cars_text_inv.png",
    inventory_overlay = "ts_vehicles_cars_tarp_text_inv_overlay.png",
    groups = { tarp_accessory = 1 },
    colorable = true,
    default_color = "#000",
    get_formspec = function(self, player)
        local vd = VD(self._id)
        local fs = ""
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[0,.25;Set text for the tarp]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."textarea[0,1;3,1;text;;"..minetest.formspec_escape(vd.data.tarp_text or "").."]"
        fs = fs.."button[3,1;1.5,1;set;Set]"
        return fs
    end,
    on_receive_fields = function(self, player, fields)
        local vd = VD(self._id)
        if fields.text and (fields.set or fields.key_enter_field == "text") then
            vd.data.tarp_text = fields.text
            vd.tmp.base_textures_set = false
        end
    end,
    after_part_add = function(self, item)
        local vd = VD(self._id)
        vd.data.tarp_text = "Placeholder Text"
        local color = item:get_meta():get("color") or item:get_definition().color
        if color then
            vd.data.tarp_text_color = color
            vd.data.tarp_text_description = item:get_description()
        end
    end,
    after_part_remove = function(self, drop)
        local vd = VD(self._id)
        vd.data.tarp_text = nil
        if vd.data.tarp_text_color then
            drop:get_meta():set_string("color", vd.data.tarp_text_color)
        end
        if vd.data.tarp_text_description then
            drop:get_meta():set_string("description", vd.data.tarp_text_description)
        end
    end,
})

minetest.register_craft({
    output = "ts_vehicles_cars:tarp_text",
    recipe = {
        {"ts_vehicles_cars:chassis_text"},
        {"techage:canister_epoxy"},
    },
    replacements = {
        {"techage:canister_epoxy", "techage:ta3_canister_empty"}
    }
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_undercarriage", {
    get_textures = function(self)
        return {
            undercarriage = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:tire", {
    get_textures = function(self)
        return {
            tires = "ts_vehicles_ct.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:base_plate", {
    get_textures = function(self)
        return {
            base_plate = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_cabin_rear_panel", {
    get_textures = function(self)
        return {
            rear_panel = "ts_vehicles_cbp.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_cabin", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.cabin_color then
            color = vd.data.cabin_color
        end
        return {
            cabin = "ts_vehicles_ctc.png^[multiply:"..color.."^ts_vehicles_ctc_.png",
        }
    end,
    get_fallback_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.cabin_color then
            color = vd.data.cabin_color
        end
        return {
            interior = "ts_vehicles_cti.png^[multiply:"..color
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_platform", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.platform_color then
            color = vd.data.platform_color
        end
        return {
            platform_top = "default_wood.png",
            platform = "ts_vehicles_ctp.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:truck_panels", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.panel_color then
            color = vd.data.panel_color
        end
        return {
            framework = "ts_vehicles_ctfp.png^[multiply:"..color,
            body = "ts_vehicles_ctsp.png^[multiply:"..color,
            body_inside = "ts_vehicles_ctsp.png^[multiply:"..color,
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:tarp", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.tarp_color then
            color = vd.data.tarp_color
        end
        return {
            framework = "(ts_vehicles_ctft.png^[multiply:"..color..")",
            body = "(ts_vehicles_ctt.png^[multiply:"..color..")",
            body_inside = "(ts_vehicles_ctt.png^[multiply:"..color..")",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:payload_tank", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.tank_color then
            color = vd.data.tank_color
        end
        return {
            tank = "ts_vehicles_ctpt.png^[multiply:"..color,
        }
    end,
    get_overlay_textures = function(self)
        return {
            platform = "ts_vehicles_ctpt_.png"
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:combined_module", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.combined_module_color then
            color = vd.data.combined_module_color
        end
        return {
            body = "ts_vehicles_ctcm.png^[multiply:"..color,
            framework = "ts_vehicles_ctfcm.png^[multiply:"..color,
        }
    end,
    get_overlay_textures = function(self)
        return {
            platform = "ts_vehicles_ctpt_.png",
            body = "ts_vehicles_ctcm_.png",
        }
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:warning_board", {
    get_textures = function(self)
        return {
            rear_board = "ts_vehicles_ctwb.png"
        }
    end,
    get_overlay_textures = function(self)
        return {
            framework = "ts_vehicles_ctfw.png"
        }
    end,
    get_light_textures = function(self)
        local vd = VD(self._id)
        local result = {}
        if vd.lights.special then
            result.rear_board_1 = "ts_vehicles_ctwb_.png^[transformFX"
            result.rear_board_2 = "ts_vehicles_ctwb_.png"
        end
        local texture = "[combine:304x304"
        vd.data.warning_board = vd.data.warning_board or {}
        local current_data = vd.data.warning_board[vd.data.warning_board.current_slot]
        if ts_vehicles.writing and current_data then
            local text = font_api.get_font("metro"):render(current_data.text or "", 192, 64, {
                lines = 4,
                halign = "center",
                valign = "center",
                color= "#c80",
            }).."^[resize:288x96"
            texture = texture..":8,144="..E(text)
        end
        if minetest.get_modpath("ta4_addons") and ta4_addons.base64_to_texture and current_data then
            local symbol = ta4_addons.base64_to_texture(current_data.symbol or "")
            texture = texture..":88,8="..E(symbol)
        end
        result.rear_board = texture
        return result
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_chassis_pillars_a", {
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

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:windows", {
    get_textures = function(self)
        return {
            glass = "ts_vehicles_ctw.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_roof", {
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

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:car_interior", {
    get_textures = function(self)
        local vd = VD(self._id)
        local color = "#fff"
        if vd.data.interior_color then
            color = vd.data.interior_color
        end
        return {
            interior = "ts_vehicles_cti.png^[multiply:"..color.."^ts_vehicles_cti_.png",
        }
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:seat", {
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

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:direction_indicator", {
    get_overlay_textures = function(self)
        return {
            cabin = "(ts_vehicles_ctdf.png)",
            platform = "(ts_vehicles_ctdb.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        local tmp = {}
        if vd.lights.left or vd.lights.warn then
            tmp[#tmp+1] = "(ts_vehicles_ctdl_.png)"
        end
        if vd.lights.right or vd.lights.warn then
            tmp[#tmp+1] = "(ts_vehicles_ctdr_.png)"
        end
        if #tmp > 0 then
            return {
                chassis_1 = table.concat(tmp, "^")
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_front", {
    get_overlay_textures = function(self)
        return {
            cabin = "(ts_vehicles_ctfl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.lights.front then
            return {
                chassis = "(ts_vehicles_ctfl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_back", {
    get_overlay_textures = function(self)
        return {
            platform = "(ts_vehicles_ctbl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.lights.stop then
            return {
                chassis = "(ts_vehicles_ctbl_.png)",
            }
        end
    end
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:lights_reversing", {
    get_overlay_textures = function(self)
        return {
            platform = "(ts_vehicles_ctrl.png)",
        }
    end,

    get_light_overlay_textures = function(self)
        local vd = VD(self._id)
        if vd.v < 0 then
            return {
                chassis = "(ts_vehicles_ctrl_.png)",
            }
        end
    end
})

for _,def in ipairs(ts_vehicles_cars.lightbars) do
    ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:"..def.id.."_light", {
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
        get_overlay_textures = function(self)
            return {
                platform = def.off:gsub("%.png", "_tp.png")
            }
        end,
        get_light_overlay_textures = function(self)
            local vd = VD(self._id)
            if vd.lights.special then
                return {
                    chassis_1 = "("..def.on1:gsub("%.png", "_tp.png")..")^ts_vehicles_ctsl_.png",
                    chassis_2 = "("..def.on2:gsub("%.png", "_tp.png")..")"
                }
            end
        end,
    })
end

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:license_plate", {
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
                cabin = "ts_vehicles_ctlpf.png^[combine:384x384:152,228=("..E(text)..")",
                platform = "ts_vehicles_ctlpb.png^[combine:448x448:184,316=("..E(text)..")"
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:chassis_text", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(vd.data.chassis_text or "", 152, 32, {
                lines = 2,
                halign = "center",
                valign = "center",
                color = vd.data.chassis_text_color or "#000",
            })
            return {
                cabin = "[combine:384x384:0,52=("..E(text).."):232,52=("..E(text)..")",
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:panels_text", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(vd.data.panels_text or "", 212, 32, {
                lines = 2,
                halign = "center",
                valign = "center",
                color = vd.data.panels_text_color or "#000",
            })
            local large_text = text.."^[resize:424x64"
            return {
                body = "[combine:800x800:0,488=("..E(large_text).."):0,736=("..E(large_text).."):542,752=("..E(text)..")",
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:tarp_text", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        if ts_vehicles.writing then
            local text = font_api.get_font("metro"):render(vd.data.tarp_text or "", 212, 48, {
                lines = 3,
                halign = "center",
                valign = "center",
                color = vd.data.tarp_text_color or "#000",
            })
            local large_text = text.."^[resize:424x96"
            return {
                body = "[combine:800x800:0,312=("..E(large_text).."):0,560=("..E(large_text).."):542,576=("..E(text)..")",
            }
        end
    end,
})

ts_vehicles.register_compatibility("ts_vehicles_cars:truck", "ts_vehicles_cars:chassis_stripe", {
    get_overlay_textures = function(self)
        local vd = VD(self._id)
        local color = vd.data.chassis_stripe_color or "#fff"
        return {
            cabin = "(ts_vehicles_cts.png^[multiply:"..color..")",
        }
    end,
})

ts_vehicles_common.register_engine_compatibility("ts_vehicles_cars:truck")
ts_vehicles_common.register_tank_compatibility("ts_vehicles_cars:truck")
ts_vehicles_common.register_aux_tank_compatibility("ts_vehicles_cars:truck")