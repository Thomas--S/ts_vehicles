-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.player_currently_editing_entity = {}
ts_vehicles.player_currently_editing_part = {}

local E = minetest.formspec_escape
local items_per_page = 12

-- "Encode" colons
local ec = function(val)
    return val:gsub(":", "___")
end

-- "Decode" colons
local dc = function(val)
    return val:gsub("___", ":")
end

local function create_card(self, player, part, i)
    local index = tostring(i)
    local description = part:get_short_description()
    local fs = ts_vehicles.helpers.part_get_property("get_formspec", part:get_name(), self.name, function(...) return nil end)(self, player, part)
    local f = "box[0,0;2.375,3;#fff]"
    f = f .. "item_image[.6875,.125;1,1;" .. part:to_string() .. "]"
    f = f .. "style[label_" .. index .. ";textcolor=black;content_offset=0,0]"
    f = f .. "tooltip[.125,.125;2.125,1.625;" .. description .. "]"
    if #description > 17 then
        description = description:sub(1, 15) .. "..."
    end
    f = f .. "image_button[0,1.25;2.375,.5;ts_vehicles_api_blank.png;label_" .. index .. ";"
    f = f .. E(description) .. ";false;false;]"
    if fs then
        f = f .. "image_button[.125,1.875;1,1;ts_vehicles_api_menu.png;configure_part_" .. index .. ";]"
    end
    f = f .. "image_button[" .. (fs and "1.25" or ".6875") .. ",1.875;1,1;ts_vehicles_api_remove.png;remove_part_" .. index .. ";]"
    return f
end

ts_vehicles.show_formspec = function(self, player, open_part)
    if not player or not minetest.is_player(player) then
        return
    end
    local player_name = player:get_player_name()
    local id = self._id
    local vd = VD(id)

    local part_idx = ts_vehicles.helpers.index_of(vd.parts, open_part)
    if part_idx then
        ts_vehicles.player_currently_editing_part[player_name] = part_idx
    end

    local part_stack = vd.parts[ts_vehicles.player_currently_editing_part[player_name]]
    local part_name = part_stack and part_stack:get_name() or ""

    ts_vehicles.player_currently_editing_entity[player_name] = id
    local part_fs = ts_vehicles.helpers.part_get_property(
        "get_formspec",
        part_name,
        self.name,
        function(...) return nil end
    )(self, player, part_stack)
    local storage_capacity = ts_vehicles.helpers.get_total_value(id, "storage_capacity")
    local payload_tank_capacity = ts_vehicles.helpers.get_total_value(id, "payload_tank_capacity")
    local gasoline_capacity = ts_vehicles.helpers.get_total_value(id, "gasoline_capacity")
    local hydrogen_capacity = ts_vehicles.helpers.get_total_value(id, "hydrogen_capacity")
    local electricity_capacity = ts_vehicles.helpers.get_total_value(id, "electricity_capacity")
    local description = ts_vehicles.registered_vehicle_bases[self.name].description
    local fs = "formspec_version[2]"
    fs = fs .. "size[17,14]"
    fs = fs .. "box[0,0;17,2;#fffc]"
    fs = fs .. "style_type[label;font_size=*2]"
    fs = fs .. "style_type[label;font=bold]"
    fs = fs .. "label[.5,.5;" .. minetest.colorize("#000", E(description)) .. "]"
    fs = fs .. "style_type[label;font_size=*1]"
    fs = fs .. "style_type[label;font=normal]"
    fs = fs .. "label[.5,1;" .. minetest.colorize("#000", "ID: " .. E(id)) .. "]"
    fs = fs .. "label[.5,1.5;" .. minetest.colorize("#000", "Total Distance: " .. E(math.round(vd.data.total_distance or 0) / 1000) .. "km") .. "]"
    local obj_properties = self.object:get_properties()
    local texture_string = ts_vehicles.helpers.create_texture_for_fs_mesh(obj_properties.textures)
    fs = fs .. "model[15,0;2,2;vehicle_preview;" .. E(obj_properties.mesh) .. ";" .. texture_string .. ";-15,150;false;true;0,0]"

    if not part_fs then
        ts_vehicles.player_currently_editing_part[player_name] = nil
    end

    if part_fs then
        fs = fs .. "button[14.5,2.25;2,.75;back;Back]"
        fs = fs .. "container[.5,3.5]"
        fs = fs .. part_fs
        fs = fs .. "container_end[]"
    elseif vd.tmp.fs_storage then
        fs = fs .. "container[0,2.25]"
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[.5,.5;Storage]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        fs = fs .. "label[.5,1;Left click the vehicle with an item in order to add it to the storage quickly.]"
        fs = fs .. "button[15,.25;1.5,.75;close_storage;Close]"

        fs = fs .. "container[0,1.625]"
        fs = fs .. "style_type[box;colors=#fff0,#ffffff8c,#ffffff8c,#fff0]"
        fs = fs .. "box[0,.2;.5,.05;]"
        fs = fs .. "style_type[box;colors=#ffffff8c,#fff0,#fff0,#ffffff8c]"
        fs = fs .. "box[16.5,.2;.5,.05;]"
        fs = fs .. "style_type[box;colors=]"
        fs = fs .. "box[.5,.2;16,.05;#fff]"
        fs = fs .. "label[1.125,0;Item]"
        fs = fs .. "label[9,0;Quantity]"

        local y = .625
        local page = vd.tmp.fs_storage_page or 1
        for idx = (page - 1) * items_per_page + 1, page * items_per_page do
            local item = vd.storage[idx]
            if item then
                if idx % 2 == 0 then
                    fs = fs .. "style_type[box;colors=#fff0,#fff2,#fff2,#fff0]"
                    fs = fs .. "box[0," .. (y - .3125) .. ";.5,.625;]"
                    fs = fs .. "style_type[box;colors=#fff2,#fff0,#fff0,#fff2]"
                    fs = fs .. "box[16.5," .. (y - .3125) .. ";.5,.625;]"
                    fs = fs .. "style_type[box;colors=]"
                    fs = fs .. "box[.5," .. (y - .3125) .. ";16,.625;#fff2]"
                end
                local itemstack = ItemStack(item.itemstring)
                local new_meta = {}
                for _, key in ipairs({ "description", "short_description", "color", "palette_index" }) do
                    if itemstack:get_meta():contains(key) then
                        new_meta[key] = itemstack:get_meta():get_string(key)
                    end
                end
                itemstack:get_meta():from_table({ fields = new_meta })
                local itemstring = itemstack:to_string()

                fs = fs .. "item_image[.5," .. (y - .25) .. ";.5,.5;" .. itemstring .. "]"
                fs = fs .. "label[1.125," .. y .. ";" .. E(itemstack:get_short_description()) .. "]"
                fs = fs .. "label[9," .. y .. ";" .. tostring(item.count) .. "]"
                fs = fs .. "button[11," .. (y - .25) .. ";1.5,.5;storage_take_one_" .. idx .. ";Take 1]"
                fs = fs .. "button[12.625," .. (y - .25) .. ";1.5,.5;storage_take_ten_" .. idx .. ";Take 10]"
                fs = fs .. "button[14.25," .. (y - .25) .. ";2.25,.5;storage_take_all_" .. idx .. ";Take Stack]"
                y = y + .625
            end
        end

        fs = fs .. "container_end[]"

        fs = fs .. "container_end[]"
        fs = fs .. "container[0,12.75]"

        fs = fs .. "label[.5,.375;Storage: " .. ts_vehicles.storage.get_total_count(id) .. " / " .. storage_capacity .. "]"

        fs = fs .. "box[7,0;3,.75;#fff]"
        fs = fs .. "style[storage_page;textcolor=black;content_offset=0,0]"
        fs = fs .. "image_button[7,0;3,.75;ts_vehicles_api_blank.png;storage_page;Page " .. page .. " of "
        fs = fs .. math.ceil(#vd.storage / items_per_page) .. ";false;false;]"
        fs = fs .. "button[5.5,0;1.5,.75;storage_prev_page;< Prev]"
        fs = fs .. "button[10,0;1.5,.75;storage_next_page;Next >]"

        fs = fs .. "button[14,0;2.5,.75;storage_add_current;Add current item]"

        fs = fs .. "container_end[]"
    else
        fs = fs .. "container[0,2.25]"
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[.5,.5;Parts of the vehicle]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        fs = fs .. "label[.5,1;To add new parts to the vehicle, right click the vehicle while wielding the part to be added.]"

        fs = fs .. "container[0,1.5]"
        local start_idx = vd.tmp.fs_parts_idx or math.max(1, #vd.parts - 5)
        if start_idx ~= 1 then
            fs = fs .. "image_button[0,1;1,1;prev_icon.png;parts_prev;;false;false;]"
        end
        if #vd.parts > 6 and start_idx < #vd.parts - 5 then
            fs = fs .. "image_button[16,1;1,1;next_icon.png;parts_next;;false;false;]"
        end
        fs = fs .. "container[1.0625,0]"
        for i = start_idx, start_idx + 5 do
            local part = vd.parts[i]
            if part then
                fs = fs .. "container[" .. tostring((i - start_idx) * 2.5) .. ",0]"
                fs = fs .. create_card(self, player, part, i)
                fs = fs .. "container_end[]"
            end
        end
        fs = fs .. "container_end[]"
        fs = fs .. "container_end[]"
        fs = fs .. "container_end[]"

        fs = fs .. "container[0,7]"
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[.5,.5;Owners]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        fs = fs .. "checkbox[.5,1;passengers_closed;Only allow owners as passengers;" .. tostring(vd.passengers_closed) .. "]"

        fs = fs .. "container[.5,1.5]"
        fs = fs .. "box[0,0;16,1.5;#fff]"
        local x = .125
        local y = .125
        for _, owner in ipairs(vd.owners) do
            fs = fs .. "button[" .. x .. "," .. y .. ";2,.5625;;" .. E(owner) .. "]"
            fs = fs .. "button[" .. (x + 2) .. "," .. y .. ";.5,.5625;remove_owner_" .. E(owner) .. ";x]"
            x = x + 2.65 -- Use 1/8+(1/5*1/8)=0.15 as gap between the buttons so that there is a nice 1/8 padding at the end.
            if x > 13.375 then
                x = .125
                y = y + .6875
            end
        end
        fs = fs .. "style[add_owner;textcolor=#000]"
        fs = fs .. "field_close_on_enter[add_owner;false]"
        fs = fs .. "field[" .. x .. "," .. y .. ";2,.5625;add_owner;;]"
        fs = fs .. "button[" .. (x + 2) .. "," .. y .. ";.5,.5625;add_owner_submit;+]"
        fs = fs .. "container_end[]"
        fs = fs .. "container_end[]"

        fs = fs .. "container[0,10.25]"
        fs = fs .. "style_type[label;font_size=*2]"
        fs = fs .. "style_type[label;font=bold]"
        fs = fs .. "label[.5,.5;Information]"
        fs = fs .. "style_type[label;font_size=*1]"
        fs = fs .. "style_type[label;font=normal]"
        y = 1.25
        fs = fs .. "style[show_void;bgcolor=red]"
        fs = fs .. "button[9.5," .. (y - .25) .. ";6,.5;show_void;Show buttons to empty tanks (Danger!)]"
        if storage_capacity > 0 then
            fs = fs .. "item_image[.5," .. (y - .25) .. ";.5,.5;default:chest]"
            fs = fs .. "label[1.125," .. y .. ";Storage: " .. ts_vehicles.storage.get_total_count(id) .. " / " .. storage_capacity .. "]"
            fs = fs .. "button[5," .. (y - .25) .. ";4,.5;open_storage;Open Storage]"
            y = y + .625
        end
        if payload_tank_capacity > 0 then
            local itemname = ts_vehicles.helpers.get_payload_tank_content_name(id)
            local desc = (minetest.registered_items[itemname] or {}).description or "empty"
            fs = fs .. "item_image[.5," .. (y - .25) .. ";.5,.5;" .. (itemname or "techage:oiltank") .. "]"
            local amount = math.round((vd.data.payload_tank_amount or 0) * 100) / 100
            fs = fs .. "label[1.125," .. y .. ";Payload Tank (" .. desc .. "): " .. E(amount) .. " / " .. payload_tank_capacity .. "]"
            if vd.tmp.show_void then
                fs = fs .. "button[9.5," .. (y - .25) .. ";4,.5;void_payload_tank;Void payload tank contents]"
            end
            y = y + .625
        end
        if gasoline_capacity > 0 then
            fs = fs .. "item_image[.5," .. (y - .25) .. ";.5,.5;techage:gasoline]"
            fs = fs .. "label[1.125," .. y .. ";Fuel (Gasoline): " .. E(math.round((vd.data.gasoline or 0) * 100) / 100) .. " / " .. gasoline_capacity .. "]"
            if vd.tmp.show_void then
                fs = fs .. "button[9.5," .. (y - .25) .. ";4,.5;void_gasoline_tank;Void gasoline tank contents]"
            end
            y = y + .625
        end
        if hydrogen_capacity > 0 then
            fs = fs .. "item_image[.5," .. (y - .25) .. ";.5,.5;techage:hydrogen]"
            fs = fs .. "label[1.125," .. y .. ";Fuel (Hydrogen): " .. E(math.round((vd.data.hydrogen or 0) * 100) / 100) .. " / " .. hydrogen_capacity .. "]"
            if vd.tmp.show_void then
                fs = fs .. "button[9.5," .. (y - .25) .. ";4,.5;void_hydrogen_tank;Void hydrogen tank contents]"
            end
            y = y + .625
        end
        if electricity_capacity > 0 then
            fs = fs .. "image[.5," .. (y - .25) .. ";.5,.5;techage_battery_inventory.png]"
            fs = fs .. "label[1.125," .. y .. ";Battery: " .. E(math.round((vd.data.electricity or 0) * 100) / 100) .. " / " .. electricity_capacity .. "]"
            if vd.tmp.show_void then
                fs = fs .. "button[9.5," .. (y - .25) .. ";4,.5;void_battery;Void battery charge]"
            end
            y = y + .625
        end
        fs = fs .. "container_end[]"
    end

    minetest.show_formspec(player_name, "ts_vehicles_api:configuration", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ts_vehicles_api:configuration" then
        return
    end
    local player_name = player:get_player_name()
    local id = ts_vehicles.player_currently_editing_entity[player_name]
    local entity
    for _, luaentity in pairs(minetest.luaentities) do
        if luaentity and luaentity.name and ts_vehicles.registered_vehicle_bases[luaentity.name] and luaentity._id == id then
            entity = luaentity
        end
    end
    local vd = VD(id)
    if not vd or not entity or fields.quit or not ts_vehicles.helpers.is_owner(id, player_name) or vector.distance(entity.object:get_pos(), player:get_pos()) > 20 then
        if vd then
            vd.tmp.show_void = false
        end
        ts_vehicles.player_currently_editing_entity[player_name] = nil
        ts_vehicles.player_currently_editing_part[player_name] = nil
        return
    end

    if ts_vehicles.player_currently_editing_part[player_name] ~= nil then
        if fields.back then
            ts_vehicles.player_currently_editing_part[player_name] = nil
        else
            local part_stack = vd.parts[ts_vehicles.player_currently_editing_part[player_name]]
            local part_name = part_stack and part_stack:get_name() or ""
            ts_vehicles.helpers.part_get_property(
                "on_receive_fields",
                part_name,
                entity.name,
                function(...) return nil end
            )(entity, player, fields, part_stack)
        end
        ts_vehicles.show_formspec(entity, player)
        return
    end

    if fields.parts_prev then
        vd.tmp.fs_parts_idx = math.max(1, ((vd.tmp.fs_parts_idx or math.max(1, #vd.parts - 5)) - 1))
    elseif fields.parts_next then
        vd.tmp.fs_parts_idx = math.min(#vd.parts, ((vd.tmp.fs_parts_idx or math.max(1, #vd.parts - 5)) + 1))
    elseif fields.add_owner and fields.add_owner ~= "" and (fields.add_owner_submit or fields.key_enter_field == "add_owner") then
        ts_vehicles.helpers.add_owner(id, fields.add_owner)
    elseif fields.open_storage then
        vd.tmp.fs_storage = true
    elseif fields.close_storage then
        vd.tmp.fs_storage = false
    elseif fields.storage_add_current then
        ts_vehicles.storage.add_by_player(entity, player)
    elseif fields.storage_prev_page then
        vd.tmp.fs_storage_page = math.max(1, ((vd.tmp.fs_storage_page or 1) - 1))
    elseif fields.storage_next_page then
        vd.tmp.fs_storage_page = math.min(math.ceil(#vd.storage / items_per_page), ((vd.tmp.fs_storage_page or 1) + 1))
    elseif fields.passengers_closed then
        vd.passengers_closed = fields.passengers_closed == "true"
    elseif fields.show_void then
        vd.tmp.show_void = not vd.tmp.show_void
    elseif fields.void_payload_tank then
        vd.data.payload_tank_amount = 0
    elseif fields.void_gasoline_tank then
        vd.data.gasoline = 0
    elseif fields.void_hydrogen_tank then
        vd.data.hydrogen = 0
    elseif fields.void_battery then
        vd.data.electricity = 0
    else
        for k, _ in pairs(fields) do
            if ts_vehicles.helpers.starts_with(k, "remove_owner_") then
                local owner_to_remove = k:sub(14) -- len("remove_owner_") = 13
                if owner_to_remove == player_name then
                    minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicles] You can't remove yourself as owner."))
                else
                    ts_vehicles.helpers.remove_owner(id, owner_to_remove)
                end
            elseif ts_vehicles.helpers.starts_with(k, "remove_part_") then
                local index_to_remove = tonumber(k:sub(13)) -- len("remove_part_") = 12
                local got_removed, reason = ts_vehicles.remove_part(entity, index_to_remove, player)
                if not got_removed then
                    minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] Can't remove part: " .. reason))
                end
            elseif ts_vehicles.helpers.starts_with(k, "storage_take_") then
                local idx = tonumber(k:sub(18)) -- len("storage_take_all_") = 17
                local num
                if k:sub(14, 16) == "one" then
                    num = 1
                elseif k:sub(14, 16) == "ten" then
                    num = 10
                end
                ts_vehicles.storage.take_by_player(entity, player, idx, num)
            elseif ts_vehicles.helpers.starts_with(k, "configure_part_") then
                local index = tonumber(k:sub(16)) -- len("configure_part_") = 15
                ts_vehicles.player_currently_editing_part[player_name] = index
            end
        end
    end
    if not fields.show_void then
        vd.tmp.show_void = false
    end
    ts_vehicles.show_formspec(entity, player)
end)

local player_overview_page = {}
local player_current_overview = {}
local RESTORE_RADIUS = 10

local get_vehicles_inside_radius = function(pos)
    local entities = {}
    for _, object in ipairs(minetest.get_objects_inside_radius(pos, RESTORE_RADIUS + 4)) do
        local entity = object:get_luaentity()
        if entity and ts_vehicles.registered_vehicle_bases[entity.name] then
            entities[entity._id] = entity
        end
    end
    return entities
end

local show_overview_formspec = function(editor)
    local owner = player_current_overview[editor] or editor
    local ids = minetest.deserialize(ts_vehicles.mod_storage:get_string("owner:" .. owner)) or {}
    local player = minetest.get_player_by_name(editor)
    if not player then
        return
    end
    local pos = player:get_pos()
    table.sort(ids)
    local entities = get_vehicles_inside_radius(pos)

    local fs = {
        "formspec_version[2]",
        "size[12,11]",
    }
    table.insert(fs, "label[.5,.5;ID]")
    table.insert(fs, "label[1.5,.5;Type]")
    table.insert(fs, "label[3,.5;Last Position]")
    table.insert(fs, "label[6.5,.5;Status]")
    table.insert(fs, "box[0,.95;12,.05;#fff]")
    local y = 1.5
    local vehicles_per_page = 8
    player_overview_page[editor] = math.min(math.ceil(#ids / vehicles_per_page), player_overview_page[editor])
    local page = player_overview_page[editor] or 1
    if #ids > 0 then
        for idx = (page - 1) * vehicles_per_page + 1, math.min(page * vehicles_per_page, #ids) do
            local id = ids[idx]
            local vd = VD(id)
            local def = ts_vehicles.registered_vehicle_bases[vd.name]
            if idx % 2 == 0 then
                table.insert(fs, "style_type[box;colors=#fff0,#fff2,#fff2,#fff0]box[0," .. (y - .5) .. ";.5,1;]")
                table.insert(fs, "style_type[box;colors=#fff2,#fff0,#fff0,#fff2]box[11.5," .. (y - .5) .. ";.5,1;]")
                table.insert(fs, "style_type[box;colors=]box[.5," .. (y - .5) .. ";11,1;#fff2]")
            end
            table.insert(fs, "label[.5," .. y .. ";" .. id .. "]")
            table.insert(fs, "label[1.5," .. y .. ";" .. ((def or {}).description or "unknown") .. "]")
            table.insert(fs, "label[3," .. y .. ";" .. (vd.last_seen_pos and vector.to_string(vector.round(vd.last_seen_pos)) or "unknown") .. "]")
            if def then
                local texture = ts_vehicles.helpers.create_texture_for_fs_mesh(ts_vehicles.build_textures(def.name, def.textures, vd.parts, id))
                table.insert(fs, "model[5," .. (y - .5) .. ";1,1;vehicle_preview;" .. E(def.mesh) .. ";" .. texture .. ";-15,150;false;true;0,0]")
            end
            if vd.last_seen_pos and math.round(vector.distance(pos, vd.last_seen_pos)) < RESTORE_RADIUS then
                if entities[id] then
                    table.insert(fs, "label[6.5," .. y .. ";" .. minetest.colorize("#0c0", "Vehicle status OK") .. "]")
                else
                    table.insert(fs, "label[6.5," .. y .. ";" .. minetest.colorize("#c00", "Vehicle not found") .. "]")
                    if vd.name then
                        table.insert(fs, "button[9," .. (y - .375) .. ";2,.75;restore_" .. id .. ";Restore Vehicle]")
                    end
                end
            else
                table.insert(fs, "label[6.5," .. y .. ";" .. minetest.colorize("#ccc", "Vehicle status unknown") .. "]")
            end
            y = y + 1
        end
    end

    table.insert(fs, "box[4.5,9.125;3,.75;#fff]")
    table.insert(fs, "style[vehicles_page;textcolor=black;content_offset=0,0]")
    table.insert(fs, "image_button[4.5,9.125;3,.75;ts_vehicles_api_blank.png;vehicles_page;Page " .. page .. " of ")
    table.insert(fs, math.ceil(#ids / vehicles_per_page) .. ";false;false;]")
    table.insert(fs, "button[3,9.125;1.5,.75;vehicles_prev_page;< Prev]")
    table.insert(fs, "button[7.5,9.125;1.5,.75;vehicles_next_page;Next >]")

    table.insert(fs, "textarea[.5,10;11,.875;;;Move near the last known location to see the vehicle status.\nDisappeared vehicles can be restored while being near their last recorded position.]")

    minetest.show_formspec(editor, "ts_vehicles_api:vehicles_overview", table.concat(fs))
end

minetest.register_chatcommand("vehicles", {
    params = "",
    description = "Shows a management interface for all your vehicles.",
    privs = { interact = true },
    func = function(name, param)
        if param ~= "" and not minetest.check_player_privs(name, ts_vehicles.priv) then
            minetest.chat_send_player(name, "You need the " .. ts_vehicles.priv .. " privilege to show other players' vehicles.")
            return
        end

        player_overview_page[name] = 1
        player_current_overview[name] = param ~= "" and param or name

        show_overview_formspec(name)
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ts_vehicles_api:vehicles_overview" or fields.quit then
        return
    end
    local player_name = player:get_player_name()
    if fields.vehicles_prev_page then
        player_overview_page[player_name] = math.max(1, ((player_overview_page[player_name] or 1) - 1))
    elseif fields.vehicles_next_page then
        player_overview_page[player_name] = (player_overview_page[player_name] or 1) + 1
    else
        for k, _ in pairs(fields) do
            if ts_vehicles.helpers.starts_with(k, "restore_") then
                local id_old = tonumber(k:sub(9)) -- len("restore_") = 8
                local vd = VD(id_old)
                local player_pos = player:get_pos()
                if vd and vd.last_seen_pos and vd.name and vector.distance(player_pos, vd.last_seen_pos) < RESTORE_RADIUS
                    and (ts_vehicles.helpers.is_owner(id_old, player_name) or minetest.check_player_privs(player_name, ts_vehicles.priv))
                then
                    local entities = get_vehicles_inside_radius(player_pos)
                    if not entities[id_old] then
                        -- Create new vehicle
                        local object = minetest.add_entity(vd.last_seen_pos, vd.name)
                        if object then
                            object:set_yaw(player:get_look_horizontal())
                            local luaentity = object:get_luaentity()
                            local id_new = luaentity._id

                            ts_vehicles.swap_vehicle_data(id_old, id_new)
                            ts_vehicles.delete(id_old)
                        end

                        minetest.close_formspec(player_name, "ts_vehicles_api:vehicles_overview")
                    end
                end
                return
            end
        end
    end
    show_overview_formspec(player_name)
end)