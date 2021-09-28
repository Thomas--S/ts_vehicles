-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.hose = {}

local E = minetest.formspec_escape


minetest.register_entity("ts_vehicles_api:hose", {
    initial_properties = {
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        selectionbox = { 0, 0, 0, 0, 0, 0 },
        visual = "cube",
        physical = false,
        collide_with_objects = true,
        textures = {
            "ts_vehicles_api_hose.png",
            "ts_vehicles_api_hose.png",
            "ts_vehicles_api_hose.png",
            "ts_vehicles_api_hose.png",
            "ts_vehicles_api_hose.png",
            "ts_vehicles_api_hose.png",
        }
    },
    on_rightclick = function(self, player)
    end,
    on_punch = function(self, player, time_from_last_punch, tool_capabilities, dir, damage)
    end,
    on_activate = function(self, staticdata, dtime_s)
        self.object:set_armor_groups({immortal=1})
        local data = minetest.deserialize(staticdata)
        self._dtime = 0
        if data then
            self._connected_to = data._connected_to
            self._id = data._id
            self.object:set_properties{
                visual_size = data._visual_size,
            }
        end
    end,
    get_staticdata = function(self)
        local data = {
            _connected_to = self._connected_to,
            _id = self._id,
            _visual_size = self.object:get_properties().visual_size,
        }
        return minetest.serialize(data)
    end,
    on_step = function(self, dtime, moveresult)
        self._dtime = self._dtime + dtime
        if self._dtime > 1 then
            if not ts_vehicles.hose.is_entity_connected(self._connected_to, self._id) then
                self.object:remove()
            end
            self._dtime = 0
        end
    end
})

ts_vehicles.hose.is_entity_connected = function(station_pos, id)
    if not station_pos then
        return false
    end
    local meta = minetest.get_meta(station_pos)
    return meta:get_string("ts_vehicles_hose_connection_id") == tostring(id)
end

-- The caller has to ensure that there is a valid station at `station_pos`!
ts_vehicles.hose.get_positions = function(entity, station_pos)
    local node = minetest.get_node(station_pos)
    local node_def = minetest.registered_nodes[node.name]
    local def = node_def._station

    local entity_def = ts_vehicles.registered_vehicle_bases[entity.name]
    if not(def.type and entity_def and entity_def[def.type.."_hose_offset"]) then
        return nil, nil
    end
    local p1 = vector.add(entity.object:get_pos(), vector.rotate(entity_def[def.type.."_hose_offset"], entity.object:get_rotation()))
    local station_rotation = vector.dir_to_rotation(minetest.facedir_to_dir(node.param2))
    local p2 = vector.add(station_pos, vector.rotate(def.hose_offset, station_rotation))
    return p1, p2
end

-- The caller has to ensure that there is a valid station at `station_pos`!
ts_vehicles.hose.connect = function(entity, station_pos)
    VD(entity._id).connected_to = station_pos
    minetest.get_meta(station_pos):set_string("ts_vehicles_hose_connection_id", entity._id)
    local p1, p2 = ts_vehicles.hose.get_positions(entity, station_pos)
    if p1 == nil or p2 == nil then
        return
    end
    local center = vector.divide(vector.add(p1, p2), 2)
    local rotation = vector.dir_to_rotation(vector.direction(p1, p2))
    local length = vector.distance(p1, p2) + .3
    local object = minetest.add_entity(center, "ts_vehicles_api:hose")
    if object then
        object:set_rotation(rotation)
        object:set_properties({
            visual_size = { x = .1, y = .1, z = length}
        })
    end
    local hose_entity = object:get_luaentity()
    hose_entity._connected_to = station_pos
    hose_entity._id = entity._id
end

ts_vehicles.hose.disconnect = function(self)
    local pos = VD(self._id).connected_to
    if not pos then
        return
    end
    local station = minetest.get_node(pos)
    if not (station and minetest.registered_nodes[station.name] and minetest.registered_nodes[station.name]._station) then
        return
    end
    minetest.get_meta(pos):set_string("ts_vehicles_hose_connection_id", nil)
end

ts_vehicles.hose.can_be_placed = function(entity, station_pos, maxlength)
    if not (entity and ts_vehicles.registered_vehicle_bases[entity.name]) then
        return false, "No vehicle."
    end
    if VD(entity._id).connected_to then
        return false, "Vehicle already connected to a station."
    end
    local station_node = minetest.get_node(station_pos)
    if not station_node then
        return false, "No station position."
    end
    local def = minetest.registered_nodes[station_node.name]
    if not (def and def._station) then
        return false, "No registered station."
    end
    local p1, p2 = ts_vehicles.hose.get_positions(entity, station_pos)
    if p1 == nil or p2 == nil then
        return false, "No attachment positions found."
    end
    if ts_vehicles.helpers.get_total_value(entity, def._station.type.."_capacity") <= 0 then
        return false, "No capacity."
    end
    if maxlength and vector.distance(p1, p2) > maxlength then
        return false, "Distance too long."
    end
    if not ts_vehicles.helpers.free_line_of_sight(p1, p2, entity._id) then
        return false, "No free line of sight."
    end
    return true
end

ts_vehicles.hose.get_applicable_vehicles = function(station_pos, maxlength)
    local vehicles = {}
    local objects = minetest.get_objects_inside_radius(station_pos, maxlength + 2)
    for _,object in ipairs(objects) do
        local entity = object:get_luaentity()
        if entity then
            local can_be_connected = ts_vehicles.hose.can_be_placed(entity, station_pos, maxlength)
            if can_be_connected then
                local def = ts_vehicles.registered_vehicle_bases[entity.name]
                local obj_properties = entity.object:get_properties()
                table.insert(vehicles, {
                    id = entity._id,
                    description = def.description,
                    model = obj_properties.mesh,
                    texture = ts_vehicles.helpers.create_texture_for_fs_mesh(obj_properties.textures),
                })
            end
        end
    end
    return vehicles
end

ts_vehicles.hose.get_vehicle_by_id = function(id, station_pos, maxlength)
    local objects = minetest.get_objects_inside_radius(station_pos, maxlength + 2)
    for _,object in ipairs(objects) do
        local entity = object:get_luaentity()
        if entity and ts_vehicles.registered_vehicle_bases[entity.name] then
            local current_id = entity._id
            if current_id == id then
                local can_be_connected, reason = ts_vehicles.hose.can_be_placed(entity, station_pos, maxlength)
                if can_be_connected then
                    return entity, reason
                else
                    return nil, reason
                end
            end
        end
    end
    return nil, "Vehicle not found."
end

ts_vehicles.hose.get_connected_vehicle = function(pos)
    local node = minetest.get_node(pos)
    if not (minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name]._station) then
        return nil
    end
    local connected_id = minetest.get_meta(pos):get_string("ts_vehicles_hose_connection_id")
    if connected_id == "" or connected_id == nil then
        return nil
    end
    local def = minetest.registered_nodes[node.name]._station
    local objects = minetest.get_objects_inside_radius(pos, def.maxlength + 2)
    for _,object in ipairs(objects) do
        local entity = object:get_luaentity()
        if entity and ts_vehicles.registered_vehicle_bases[entity.name] then
            if tostring(entity._id) == connected_id then
                return object
            end
        end
    end
end

ts_vehicles.hose.get_formspec = function(pos)
    local node = minetest.get_node(pos)
    local node_def = minetest.registered_nodes[node.name]
    if not (node_def and node_def._station) then
        return ""
    end
    local meta = minetest.get_meta(pos)
    local def = node_def._station
    local title = def.title or "Station"
    local help_text = def.help_text or ""
    local color = def.color or "#000"
    local fs = "formspec_version[2]"
    fs = fs.."size[12,10]"
    fs = fs.."box[0,0;12,2;"..color.."]"
    fs = fs.."style_type[label;font_size=*2]"
    fs = fs.."style_type[label;font=bold]"
    fs = fs.."label[.5,.5;"..E(title).."]"
    fs = fs.."style_type[label;font_size=*1]"
    fs = fs.."style_type[label;font=normal]"
    fs = fs.."label[.5,1;"..E(help_text).."]"
    fs = fs.."checkbox[.5,1.5;public;Public station (anyone can connect a vehicle);"..tostring(minetest.get_meta(pos):get_string("public")).."]"
    if meta:get_string("ts_vehicles_hose_connection_id") == "" then
        fs = fs.."label[1.75,2.5;ID]"
        fs = fs.."label[3,2.5;Description]"
        fs = fs.."style_type[box;colors=#fff0,#ffffff8c,#ffffff8c,#fff0]"
        fs = fs.."box[0,2.7;.5,.05;]"
        fs = fs.."style_type[box;colors=#ffffff8c,#fff0,#fff0,#ffffff8c]"
        fs = fs.."box[11.5,2.7;.5,.05;]"
        fs = fs.."style_type[box;colors=]"
        fs = fs.."box[.5,2.7;11,.05;#fff]"
        fs = fs.."container[0,3.25]"
        local y = 0
        local vehicles = ts_vehicles.hose.get_applicable_vehicles(pos, def.maxlength)
        for idx,vehicle in ipairs(vehicles) do
            if idx % 2 == 0 then
                fs = fs.."style_type[box;colors=#fff0,#fff2,#fff2,#fff0]"
                fs = fs.."box[0,"..(y-.5)..";.5,1;]"
                fs = fs.."style_type[box;colors=#fff2,#fff0,#fff0,#fff2]"
                fs = fs.."box[11.5,"..(y-.5)..";.5,1;]"
                fs = fs.."style_type[box;colors=]"
                fs = fs.."box[.5,"..(y-.5)..";11,1;#fff2]"
            end
            fs = fs.."model[.5,"..(y-.5)..";1,1;vehicle_preview"..E(vehicle.id)..";"..E(vehicle.model)..";"..vehicle.texture..";-15,150;false;true;0,0]"
            fs = fs.."label[1.75,"..y..";"..E(vehicle.id).."]"
            fs = fs.."label[3,"..y..";"..E(vehicle.description).."]"
            fs = fs.."button[7,"..(y-.375)..";2.5,.75;connect_"..E(vehicle.id)..";Connect]"
            y = y + 1
        end
        fs = fs.."container_end[]"
    else
        fs = fs.."button[4,3;4,1.5;disconnect;Disconnect]"
    end
    if node_def._station.custom_fs_appendix then
        fs = fs..node_def._station.custom_fs_appendix(pos)
    end
    return fs
end

ts_vehicles.hose.station_receive_fields = function(pos, formname, fields, player)
    local player_name = player:get_player_name()
    local meta = minetest.get_meta(pos)
    if fields.quit then
        return
    end
    if fields.public and not minetest.is_protected(pos, player_name) then
        meta:set_string("public", fields.public)
        meta:set_string("formspec", ts_vehicles.hose.get_formspec(pos))
    end
    if fields.disconnect and (meta:get_string("public") == "true" or not minetest.is_protected(pos, player_name)) then
        meta:set_string("ts_vehicles_hose_connection_id", "")
        meta:set_string("formspec", ts_vehicles.hose.get_formspec(pos))
        minetest.after(1.5, function()
            local node = minetest.get_node(pos)
            local node_def = minetest.registered_nodes[node.name]
            if node_def and node_def._station then
                minetest.get_meta(pos):set_string("formspec", ts_vehicles.hose.get_formspec(pos))
            end
        end)
        return
    end
    if meta:get_string("ts_vehicles_hose_connection_id") ~= "" then
        return
    end
    local node = minetest.get_node(pos)
    local node_def = minetest.registered_nodes[node.name]
    if not (node_def and node_def._station) then
        return
    end
    local def = node_def._station
    for k, v in pairs(fields) do
        if ts_vehicles.helpers.starts_with(k, "connect_") then
            if meta:get_string("public") == "true" or not minetest.is_protected(pos, player_name) then
                local entity_id = tonumber(k:sub(9)) -- len("remove_owner_") = 8
                local entity, reason = ts_vehicles.hose.get_vehicle_by_id(entity_id, pos, def.maxlength)
                if not entity then
                    minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] Cannot connect: "..reason))
                    return
                end
                ts_vehicles.hose.connect(entity, pos)
                meta:set_string("formspec", ts_vehicles.hose.get_formspec(pos))
            end
        end
    end
end