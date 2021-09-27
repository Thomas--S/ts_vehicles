local player_currently_editing_entity = {}
local player_currently_editing_part = {}

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

local function create_card(self, player, part)
    local description = ts_vehicles.helpers.part_get_property("description", part, self.name, part)
    local fs = ts_vehicles.helpers.part_get_property("get_formspec", part, self.name, function(...) return nil end)(self, player)
    local f = "box[0,0;2.375,3;#fff]"
    f = f.."item_image[.6875,.125;1,1;"..part.."]"
    f = f.."style[label_"..ec(part)..";textcolor=black;content_offset=0,0]"
    f = f.."tooltip[.125,.125;2.125,1.625;"..description.."]"
    if #description > 17 then
        description = description:sub(1,15).."..."
    end
    f = f.."image_button[0,1.25;2.375,.5;ts_vehicles_api_blank.png;label_"..ec(part)..";"
    f = f..E(description)..";false;false;]"
    if fs then
        f = f.."image_button[.125,1.875;1,1;ts_vehicles_api_menu.png;configure_part_"..ec(part)..";]"
    end
    f = f.."image_button["..(fs and "1.25" or ".6875")..",1.875;1,1;ts_vehicles_api_remove.png;remove_part_"..ec(part)..";]"
    return f
end

ts_vehicles.show_formspec = function(self, player)
    local player_name = player:get_player_name()
    player_currently_editing_entity[player_name] = self._id
    local part_fs = ts_vehicles.helpers.part_get_property(
            "get_formspec",
            player_currently_editing_part[player_name],
            self.name,
            function(...) return nil end
    )(self, player)
    local storage_capacity = ts_vehicles.helpers.get_total_value(self, "storage_capacity")
    local payload_tank_capacity = ts_vehicles.helpers.get_total_value(self, "payload_tank_capacity")
    local gasoline_capacity = ts_vehicles.helpers.get_total_value(self, "gasoline_capacity")
    local hydrogen_capacity = ts_vehicles.helpers.get_total_value(self, "hydrogen_capacity")
    local electricity_capacity = ts_vehicles.helpers.get_total_value(self, "electricity_capacity")
    local description = ts_vehicles.registered_vehicle_bases[self.name].description
    local fs = "formspec_version[2]"
    fs = fs.."size[17,14]"
    fs = fs.."box[0,0;17,2;#fffc]"
    fs = fs.."style_type[label;font_size=*2]"
    fs = fs.."style_type[label;font=bold]"
    fs = fs.."label[.5,.5;"..minetest.colorize("#000", E(description)).."]"
    fs = fs.."style_type[label;font_size=*1]"
    fs = fs.."style_type[label;font=normal]"
    fs = fs.."label[.5,1;"..minetest.colorize("#000", "ID: "..E(self._id)).."]"
    fs = fs.."label[.5,1.5;"..minetest.colorize("#000", "Total Distance: "..E(math.round(self._data.total_distance or 0)/1000).."km").."]"
    local obj_properties = self.object:get_properties()
    local texture_string = ts_vehicles.helpers.create_texture_for_fs_mesh(obj_properties.textures)
    fs = fs.."model[15,0;2,2;vehicle_preview;"..E(obj_properties.mesh)..";"..texture_string..";-15,150;false;true;0,0]"

    if part_fs then
        fs = fs.."button[14.5,2.25;2,.75;back;Back]"
        fs = fs.."container[.5,3.5]"
        fs = fs..part_fs
        fs = fs.."container_end[]"
    elseif self._tmp.fs_storage then
        fs = fs.."container[0,2.25]"
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[.5,.5;Storage]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."label[.5,1;Left click the vehicle with an item in order to add it to the storage quickly.]"
        fs = fs.."button[15,.25;1.5,.75;close_storage;Close]"

        fs = fs.."container[0,1.625]"
        fs = fs.."style_type[box;colors=#fff0,#ffffff8c,#ffffff8c,#fff0]"
        fs = fs.."box[0,.2;.5,.05;]"
        fs = fs.."style_type[box;colors=#ffffff8c,#fff0,#fff0,#ffffff8c]"
        fs = fs.."box[16.5,.2;.5,.05;]"
        fs = fs.."style_type[box;colors=]"
        fs = fs.."box[.5,.2;16,.05;#fff]"
        fs = fs.."label[1.125,0;Item]"
        fs = fs.."label[9,0;Quantity]"

        local y = .625
        local page = self._tmp.fs_storage_page or 1
        for idx = (page - 1) * items_per_page + 1, page * items_per_page do
            local item = self._storage[idx]
            if item then
                if idx % 2 == 0 then
                    fs = fs.."style_type[box;colors=#fff0,#fff2,#fff2,#fff0]"
                    fs = fs.."box[0,"..(y-.3125)..";.5,.625;]"
                    fs = fs.."style_type[box;colors=#fff2,#fff0,#fff0,#fff2]"
                    fs = fs.."box[16.5,"..(y-.3125)..";.5,.625;]"
                    fs = fs.."style_type[box;colors=]"
                    fs = fs.."box[.5,"..(y-.3125)..";16,.625;#fff2]"
                end
                local itemstack = ItemStack(item.itemstring)
                local new_meta = {}
                for _, key in ipairs({"description", "short_description", "color", "palette_index"}) do
                    if itemstack:get_meta():contains(key) then
                        new_meta[key] = itemstack:get_meta():get_string(key)
                    end
                end
                itemstack:get_meta():from_table(new_meta)
                local itemstring = itemstack:to_string()

                fs = fs.."item_image[.5,"..(y-.25)..";.5,.5;"..itemstring.."]"
                fs = fs.."label[1.125,"..y..";"..E(itemstack:get_description()).."]"
                fs = fs.."label[9,"..y..";"..tostring(item.count).."]"
                fs = fs.."button[11,"..(y-.25)..";1.5,.5;storage_take_one_"..idx..";Take 1]"
                fs = fs.."button[12.625,"..(y-.25)..";1.5,.5;storage_take_ten_"..idx..";Take 10]"
                fs = fs.."button[14.25,"..(y-.25)..";2.25,.5;storage_take_all_"..idx..";Take Stack]"
                y = y + .625
            end
        end

        fs = fs.."container_end[]"

        fs = fs.."container_end[]"
        fs = fs.."container[0,12.75]"

        fs = fs.."label[.5,.375;Storage: "..ts_vehicles.storage.get_total_count(self).." / "..storage_capacity.."]"

        fs = fs.."box[7,0;3,.75;#fff]"
        fs = fs.."style[storage_page;textcolor=black;content_offset=0,0]"
        fs = fs.."image_button[7,0;3,.75;ts_vehicles_api_blank.png;storage_page;Page "..page.." of "
        fs = fs..math.ceil(#self._storage/items_per_page)..";false;false;]"
        fs = fs.."button[5.5,0;1.5,.75;storage_prev_page;< Prev]"
        fs = fs.."button[10,0;1.5,.75;storage_next_page;Next >]"

        fs = fs.."button[14,0;2.5,.75;storage_add_current;Add current item]"

        fs = fs.."container_end[]"
    else
        fs = fs.."container[0,2.25]"
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[.5,.5;Parts of the vehicle]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."label[.5,1;To add new parts to the vehicle, right click the vehicle while wielding the part to be added.]"

        fs = fs.."container[0,1.5]"
        local start_idx = self._tmp.fs_parts_idx or math.max(1, #self._parts - 5)
        if start_idx ~= 1 then
            fs = fs.."image_button[0,1;1,1;prev_icon.png;parts_prev;;false;false;]"
        end
        if #self._parts > 6 and start_idx < #self._parts - 5 then
            fs = fs.."image_button[16,1;1,1;next_icon.png;parts_next;;false;false;]"
        end
        fs = fs.."container[1.0625,0]"
        for i = start_idx, start_idx+5 do
            local part = self._parts[i]
            if part then
                fs = fs.."container["..tostring((i-start_idx)*2.5)..",0]"
                fs = fs..create_card(self, player, part)
                fs = fs.."container_end[]"
            end
        end
        fs = fs.."container_end[]"
        fs = fs.."container_end[]"
        fs = fs.."container_end[]"


        fs = fs.."container[0,7]"
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[.5,.5;Owners]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        fs = fs.."checkbox[.5,1;passengers_closed;Only allow owners as passengers;"..tostring(self._passengers_closed).."]"

        fs = fs.."container[.5,1.5]"
        fs = fs.."box[0,0;16,1.5;#fff]"
        local x = .125
        local y = .125
        for _,owner in ipairs(self._owners) do
            fs = fs.."button["..x..","..y..";2,.5625;;"..E(owner).."]"
            fs = fs.."button["..(x+2)..","..y..";.5,.5625;remove_owner_"..E(owner)..";x]"
            x = x + 2.65 -- Use 1/8+(1/5*1/8)=0.15 as gap between the buttons so that there is a nice 1/8 padding at the end.
            if x > 13.375 then
                x = .125
                y = y + .6875
            end
        end
        fs = fs.."style[add_owner;textcolor=#000]"
        fs = fs.."field_close_on_enter[add_owner;false]"
        fs = fs.."field["..x..","..y..";2,.5625;add_owner;;]"
        fs = fs.."button["..(x+2)..","..y..";.5,.5625;add_owner_submit;+]"
        fs = fs.."container_end[]"
        fs = fs.."container_end[]"

        fs = fs.."container[0,10.25]"
        fs = fs.."style_type[label;font_size=*2]"
        fs = fs.."style_type[label;font=bold]"
        fs = fs.."label[.5,.5;Information]"
        fs = fs.."style_type[label;font_size=*1]"
        fs = fs.."style_type[label;font=normal]"
        y = 1.25
        fs = fs.."style[show_void;bgcolor=red]"
        fs = fs.."button[9.5,"..(y-.25)..";6,.5;show_void;Show buttons to empty tanks (Danger!)]"
        if storage_capacity > 0 then
            fs = fs.."item_image[.5,"..(y-.25)..";.5,.5;default:chest]"
            fs = fs.."label[1.125,"..y..";Storage: "..ts_vehicles.storage.get_total_count(self).." / "..storage_capacity.."]"
            fs = fs.."button[5,"..(y-.25)..";4,.5;open_storage;Open Storage]"
            y = y + .625
        end
        if payload_tank_capacity > 0 then
            local itemname = ts_vehicles.helpers.get_payload_tank_content_name(self)
            local desc = (minetest.registered_items[itemname] or {}).description or "empty"
            fs = fs.."item_image[.5,"..(y-.25)..";.5,.5;"..(itemname or "techage:oiltank").."]"
            local amount = math.round((self._data.payload_tank_amount or 0)*100)/100
            fs = fs.."label[1.125,"..y..";Payload Tank ("..desc.."): "..E(amount).." / "..payload_tank_capacity.."]"
            if self._tmp.show_void then
                fs = fs.."button[9.5,"..(y-.25)..";4,.5;void_payload_tank;Void payload tank contents]"
            end
            y = y + .625
        end
        if gasoline_capacity > 0 then
            fs = fs.."item_image[.5,"..(y-.25)..";.5,.5;techage:gasoline]"
            fs = fs.."label[1.125,"..y..";Fuel (Gasoline): "..E(math.round((self._data.gasoline or 0)*100)/100).." / "..gasoline_capacity.."]"
            if self._tmp.show_void then
                fs = fs.."button[9.5,"..(y-.25)..";4,.5;void_gasoline_tank;Void gasoline tank contents]"
            end
            y = y + .625
        end
        if hydrogen_capacity > 0 then
            fs = fs.."item_image[.5,"..(y-.25)..";.5,.5;techage:hydrogen]"
            fs = fs.."label[1.125,"..y..";Fuel (Hydrogen): "..E(math.round((self._data.hydrogen or 0)*100)/100).." / "..hydrogen_capacity.."]"
            if self._tmp.show_void then
                fs = fs.."button[9.5,"..(y-.25)..";4,.5;void_hydrogen_tank;Void hydrogen tank contents]"
            end
            y = y + .625
        end
        if electricity_capacity > 0 then
            fs = fs.."image[.5,"..(y-.25)..";.5,.5;techage_battery_inventory.png]"
            fs = fs.."label[1.125,"..y..";Battery: "..E(math.round((self._data.electricity or 0)*100)/100).." / ".. electricity_capacity .."]"
            if self._tmp.show_void then
                fs = fs.."button[9.5,"..(y-.25)..";4,.5;void_battery;Void battery charge]"
            end
            y = y + .625
        end
        fs = fs.."container_end[]"
    end

    minetest.show_formspec(player_name, "ts_vehicles_api:configuration", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "ts_vehicles_api:configuration" then
        return
    end
    local player_name = player:get_player_name()
    local id = player_currently_editing_entity[player_name]
    local entity
    for _,luaentity in pairs(minetest.luaentities) do
        if luaentity and luaentity.name and ts_vehicles.registered_vehicle_bases[luaentity.name] and luaentity._id == id then
            entity = luaentity
        end
    end
    if not entity or fields.quit or not ts_vehicles.helpers.contains(entity._owners, player_name) then
        if entity then
            entity._tmp.show_void = false
        end
        player_currently_editing_entity[player_name] = nil
        player_currently_editing_part[player_name] = nil
        return
    end

    if player_currently_editing_part[player_name] then
        if fields.back then
            player_currently_editing_part[player_name] = nil
        else
            ts_vehicles.helpers.part_get_property(
                "on_receive_fields",
                player_currently_editing_part[player_name],
                entity.name,
                function(...) return nil end
            )(entity, player, fields)
            entity._tmp.textures_set = false -- TODO
        end
        ts_vehicles.show_formspec(entity, player)
        return
    end

    if fields.parts_prev then
        entity._tmp.fs_parts_idx = math.max(1, ((entity._tmp.fs_parts_idx or math.max(1, #entity._parts - 5)) - 1))
    elseif fields.parts_next then
        entity._tmp.fs_parts_idx = math.min(#entity._parts, ((entity._tmp.fs_parts_idx or math.max(1, #entity._parts - 5)) + 1))
    elseif fields.add_owner and fields.add_owner ~= "" and (fields.add_owner_submit or fields.key_enter_field == "add_owner")
            and not ts_vehicles.helpers.contains(entity._owners, fields.add_owner)
    then
        table.insert(entity._owners, fields.add_owner)
    elseif fields.open_storage then
        entity._tmp.fs_storage = true
    elseif fields.close_storage then
        entity._tmp.fs_storage = false
    elseif fields.storage_add_current then
        ts_vehicles.storage.add_by_player(entity, player)
    elseif fields.storage_prev_page then
        entity._tmp.fs_storage_page = math.max(1, ((entity._tmp.fs_storage_page or 1) - 1))
    elseif fields.storage_next_page then
        entity._tmp.fs_storage_page = math.min(math.ceil(#entity._storage/items_per_page), ((entity._tmp.fs_storage_page or 1) + 1))
    elseif fields.passengers_closed then
        entity._passengers_closed = fields.passengers_closed == "true"
    elseif fields.show_void then
        entity._tmp.show_void = not entity._tmp.show_void
    elseif fields.void_payload_tank then
        entity._data.payload_tank_amount = 0
    elseif fields.void_gasoline_tank then
        entity._data.gasoline = 0
    elseif fields.void_hydrogen_tank then
        entity._data.hydrogen = 0
    elseif fields.void_battery then
        entity._data.electricity = 0
    else
        for k,v in pairs(fields) do
            if ts_vehicles.helpers.starts_with(k, "remove_owner_") then
                local owner_to_remove = k:sub(14) -- len("remove_owner_") = 13
                if owner_to_remove == player_name then
                    minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicles] You can't remove yourself as owner."))
                else
                    table.remove(entity._owners, ts_vehicles.helpers.index_of(entity._owners, owner_to_remove))
                end
            elseif ts_vehicles.helpers.starts_with(k, "remove_part_") then
                local part_to_remove = dc(k:sub(13)) -- len("remove_part_") = 12
                local got_removed, reason = ts_vehicles.remove_part(entity, part_to_remove, player)
                if not got_removed then
                    minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] Can't remove part: "..reason))
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
                local part = dc(k:sub(16)) -- len("configure_part_") = 15
                player_currently_editing_part[player_name] = part
            end
        end
    end
    if not fields.show_void then
        entity._tmp.show_void = false
    end
    ts_vehicles.show_formspec(entity, player)
end)