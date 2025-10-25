-- Vehicle Data
local VD = ts_vehicles.get

local text_registered = false
ts_vehicles_common.register_text = function()
    if text_registered then
        return
    end
    text_registered = true
    ts_vehicles.register_part("ts_vehicles_common:text", {
        description = "Vehicle Text",
        inventory_image = "ts_vehicles_common_text.png",
        groups = { wrapping = 1, },
        colorable = true,
        default_color = "#000",
        get_formspec = function(self, player, part)
            if part:get_meta():get_int("set") ~= 0 then
                return nil
            end
            local vd = VD(self._id)
            local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name] or {}
            local fs = "style_type[label;font_size=*2]"
            fs = fs .. "style_type[label;font=bold]"
            fs = fs .. "label[0,-1;Set texts]"
            fs = fs .. "style_type[label;font_size=*1]"
            fs = fs .. "style_type[label;font=normal]"
            fs = fs .. "label[0,-.5;Cannot be changed once saved.]"
            local y = .5
            for text_id, text_def in pairs(vehicle_def.texts or {}) do
                if not text_def.requires or ts_vehicles.helpers.any_has_group(vd.parts, text_def.requires) then
                    fs = fs .. "label[0," .. y .. ";" .. text_def.name .. " Text (max. " .. text_def.lines .. " lines)]"
                    fs = fs .. "textarea[4," .. (y - .5) .. ";3,1;" .. text_id .. "_text;;]"
                    y = y + 1.5
                end
            end
            fs = fs .. "button[7," .. y .. ";3,1;set;Save]"
            return fs
        end,
        on_receive_fields = function(self, player, fields, part)
            local vd = VD(self._id)
            local texts = (ts_vehicles.registered_vehicle_bases[self.name] or {})["texts"] or {}
            local meta = part:get_meta()
            if meta:get_int("set") == 0 and (fields.set or texts[fields.key_enter_field:gsub("_text$", "")]) then
                meta:set_int("set", 1)
                for text_id, text_def in pairs(texts) do
                    if not text_def.requires or ts_vehicles.helpers.any_has_group(vd.parts, text_def.requires) then
                        meta:set_string(text_id, fields[text_id .. "_text"] or "")
                    end
                end
                vd.tmp.base_textures_set = false
            end
        end,
        after_part_add = function(self, item, player)
            ts_vehicles.show_formspec(self, player, item)
        end,
        after_part_remove = function(self, drop)
            drop:set_count(0)
        end,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:text",
        recipe = {
            { "", "dye:black", "" },
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
        },
    })
end

local wrapping_registered = false
ts_vehicles_common.register_wrapping = function()
    if wrapping_registered then
        return
    end
    wrapping_registered = true
    ts_vehicles.register_part("ts_vehicles_common:wrapping", {
        description = "Vehicle Wrapping",
        inventory_image = "ts_vehicles_common_wrapping.png",
        groups = { wrapping = 1, },
        colorable = true,
        get_formspec = function(self, player, part)
            local meta = part:get_meta()
            local show_fs = false
            local vd = VD(self._id)
            local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name] or {}
            local fs = "style_type[label;font_size=*2]"
            fs = fs .. "style_type[label;font=bold]"
            fs = fs .. "label[0,-1;Set Wrappings]"
            fs = fs .. "style_type[label;font_size=*1]"
            fs = fs .. "style_type[label;font=normal]"
            fs = fs .. "label[0,-.5;Cannot be changed once set.]"
            local y = .5
            for wrapping_id, wrapping_def in pairs(vehicle_def.wrappings or {}) do
                fs = fs .. "label[0," .. y .. ";" .. wrapping_def.name .. "]"
                if wrapping_def.requires and not ts_vehicles.helpers.any_has_group(vd.parts, wrapping_def.requires) then
                    fs = fs .. "label[1.5," .. y .. ";Base Part is missing.]"
                elseif meta:get_string(wrapping_id) ~= "" then
                    fs = fs .. "label[1.5," .. y .. ";Wrapping is already applied.]"
                else
                    show_fs = true
                    local x = 1.5
                    for idx, wrapping_name in ipairs(wrapping_def.values) do
                        fs = fs .. "button[" .. x .. "," .. (y - .5) .. ";2,1;set_wrapping_" .. wrapping_id .. "_" .. idx .. ";" .. wrapping_name .. "]"
                        x = x + 2.5
                    end
                end
                y = y + 1.5
            end
            return show_fs and fs or nil
        end,
        on_receive_fields = function(self, player, fields, part)
            local vd = VD(self._id)
            local wrappings = (ts_vehicles.registered_vehicle_bases[self.name] or {})["wrappings"] or {}
            local meta = part:get_meta()
            for wrapping_id, wrapping_def in pairs(wrappings) do
                for idx, wrapping_name in ipairs(wrapping_def.values) do
                    if fields["set_wrapping_" .. wrapping_id .. "_" .. idx] and meta:get_string(wrapping_id) == "" then
                        meta:set_string(wrapping_id, wrapping_name)
                        vd.tmp.base_textures_set = false
                    end
                end
            end
        end,
        after_part_add = function(self, item, player)
            ts_vehicles.show_formspec(self, player, item)
        end,
        after_part_remove = function(self, drop)
            drop:set_count(0)
        end,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:wrapping",
        recipe = {
            { "dye:white", "dye:white", "dye:white" },
            { "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" },
        },
    })
end

ts_vehicles_common.is_wrapping_structure_sound = function(self, parts)
    local id = self._id
    local vd = VD(id)
    parts = parts or vd.parts
    local has = function(group) return ts_vehicles.helpers.any_has_group(parts, group) end
    local texts = (ts_vehicles.registered_vehicle_bases[self.name] or {})["texts"] or {}
    local wrappings = (ts_vehicles.registered_vehicle_bases[self.name] or {})["wrappings"] or {}

    for _, part in ipairs(parts) do
        local part_name = part:get_name()
        if part_name == "ts_vehicles_common:text" then
            local meta = part:get_meta()
            for text_id, text_def in pairs(texts) do
                if text_def.requires and meta:get_string(text_id) ~= "" and not has(text_def.requires) then
                    return false, "Wrapping needs its base."
                end
            end
        elseif part_name == "ts_vehicles_common:wrapping" then
            local meta = part:get_meta()
            for wrapping_id, wrapping_def in pairs(wrappings) do
                if wrapping_def.requires and meta:get_string(wrapping_id) ~= "" and not has(wrapping_def.requires) then
                    return false, "Wrapping needs its base."
                end
            end
        end
    end
    return true
end