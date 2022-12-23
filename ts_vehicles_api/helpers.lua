-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.GRAVITATION = 9.8

ts_vehicles.helpers = {}

ts_vehicles.helpers.sign = function(value)
    return value >= 0 and 1 or -1
end

ts_vehicles.helpers.clamp = function(value, lower, upper)
    return math.max(math.min(value, upper), lower)
end

ts_vehicles.helpers.turn_player = function(player, delta)
    if player then
        player:set_look_horizontal(player:get_look_horizontal() + delta)
    end
end

ts_vehicles.helpers.call = function(func, ...)
    if func then
        return func(...)
    end
    return nil
end

ts_vehicles.helpers.any_has_group = function(parts, group)
    for _,part in ipairs(parts) do
        local def = ts_vehicles.registered_parts[part]
        if def and def.groups and def.groups[group] then
            return true
        end
    end
end

ts_vehicles.helpers.multiple_have_group = function(parts, group)
    local first = false
    for _,part in ipairs(parts) do
        local def = ts_vehicles.registered_parts[part]
        if def and def.groups and def.groups[group] then
            if first then
                return true
            else
                first = true
            end
        end
    end
end

ts_vehicles.helpers.part_get_property = function(property, part, vehicle, fallback)
    if vehicle
        and ts_vehicles.registered_compatibilities[vehicle]
        and ts_vehicles.registered_compatibilities[vehicle][part]
        and ts_vehicles.registered_compatibilities[vehicle][part][property]
    then
        return ts_vehicles.registered_compatibilities[vehicle][part][property]
    end
    if ts_vehicles.registered_parts[part] and ts_vehicles.registered_parts[part][property] then
        return ts_vehicles.registered_parts[part][property]
    end
    return fallback
end

ts_vehicles.helpers.contains = function(list, value)
    for _,element in ipairs(list or {}) do
        if element == value then
            return true
        end
    end
    return false
end

ts_vehicles.helpers.index_of = function(list, value)
    for idx,element in ipairs(list) do
        if element == value then
            return idx
        end
    end
    return nil
end

ts_vehicles.helpers.starts_with = function(whole_string, start_string)
    return string.sub(whole_string, 1, string.len(start_string)) == start_string
end

ts_vehicles.helpers.get_total_value = function(self, property_name, parts)
    parts = parts or VD(self._id).parts
    local total = 0
    for _,part in ipairs(parts) do
        total = total + ts_vehicles.helpers.part_get_property(property_name, part, self.name, 0)
    end
    return total
end

ts_vehicles.helpers.get_ground_pos_from_moveresult = function(moveresult)
    for _,collision in ipairs(moveresult.collisions or {}) do
        if collision.type == "node" and collision.axis == "y" then
            return collision.node_pos
        end
    end
end

ts_vehicles.helpers.create_texture_for_fs_mesh = function(textures)
    local texture_string = ""
    for _,texture in ipairs(textures) do
        if texture_string ~= "" then
            texture_string = texture_string..","
        end
        texture_string = texture_string..minetest.formspec_escape(texture)
    end
    return texture_string
end

ts_vehicles.helpers.pitch_vehicle = function(self, delta_y, length, def)
    local obj = self.object
    local collisionbox = obj:get_properties().collisionbox
    local selectionbox = obj:get_properties().selectionbox
    local rotation = obj:get_rotation()
    local pitch = math.atan(delta_y/length)
    local box_offset = math.abs(delta_y/2)
    if (math.abs(rotation.x - pitch) > 0.01) then
        obj:set_rotation(vector.new(pitch, rotation.y, rotation.z))
    end
    local box_delta = def.scaled_collisionbox[2] + box_offset - collisionbox[2]
    if (math.abs(box_delta) > 0.01) then
        local pos = obj:get_pos()
        pos.y = pos.y - box_delta
        obj:set_pos(pos)
        obj:set_properties({
            collisionbox = {
                collisionbox[1], def.scaled_collisionbox[2] + box_offset, collisionbox[3],
                collisionbox[4], def.scaled_collisionbox[5] + box_offset, collisionbox[6],
            },
            selectionbox = {
                selectionbox[1], def.scaled_selectionbox[2] + box_offset, selectionbox[3],
                selectionbox[4], def.scaled_selectionbox[5] + box_offset, selectionbox[6],
            }
        })
    end
end

ts_vehicles.helpers.downwards_space = function(pos, max_depth)
    local collision = minetest.raycast(pos, vector.new(pos.x, pos.y - max_depth, pos.z), false, false):next()
    if collision then
        return collision.intersection_point.y - pos.y
    else
        return -max_depth
    end
end

ts_vehicles.helpers.get_rotated_collisionbox_corners = function(self)
    local obj = self.object
    local collisionbox = obj:get_properties().collisionbox
    local rotation = obj:get_rotation()
    local pos = obj:get_pos()
    local yaw_rotation = vector.new(0,rotation.y,0)
    return {
        vector.add(pos, vector.rotate(vector.new(collisionbox[1], collisionbox[2], collisionbox[6]), yaw_rotation)),
        vector.add(pos, vector.rotate(vector.new(collisionbox[4], collisionbox[2], collisionbox[6]), yaw_rotation)),
        vector.add(pos, vector.rotate(vector.new(collisionbox[1], collisionbox[2], collisionbox[3]), yaw_rotation)),
        vector.add(pos, vector.rotate(vector.new(collisionbox[4], collisionbox[2], collisionbox[3]), yaw_rotation)),
    }, collisionbox[6] - collisionbox[3]
end


ts_vehicles.helpers.get_payload_tank_content_name = function(id)
    local vd = VD(id)
    if vd.data.payload_tank_amount == 0 then
        return nil
    end
    if vd.data.payload_tank_name then
        return vd.data.payload_tank_name
    end
    return nil
end

ts_vehicles.helpers.free_line_of_sight = function(p1, p2, ignore_id, ignore_node_pos)
    local raycast = minetest.raycast(p1, p2)
    for pointed_thing in raycast do
        if pointed_thing.type == "object" then
            if pointed_thing.ref:get_properties().physical then
                if pointed_thing.ref.get_luaentity then
                    local entity = pointed_thing.ref:get_luaentity()
                    if not (ignore_id and ts_vehicles.registered_vehicle_bases[entity.name] and entity._id == ignore_id) then
                        return false
                    end
                else
                    return false
                end
            end
        elseif pointed_thing.type == "node" then
            local node = minetest.get_node(pointed_thing.under)
            local def = minetest.registered_nodes[node.name]
            if not (ignore_node_pos and vector.equals(ignore_node_pos, pointed_thing.under) or def and def.walkable == false) then
                return false
            end
        end
    end
    return true
end

ts_vehicles.helpers.add_owner_mapping = function(id, owner)
    local ids = minetest.deserialize(ts_vehicles.mod_storage:get_string("owner:"..owner)) or {}
    if not ts_vehicles.helpers.contains(ids, id) then
        table.insert(ids, id)
    end
    ts_vehicles.mod_storage:set_string("owner:"..owner, minetest.serialize(ids))
end

ts_vehicles.helpers.remove_owner_mapping = function(id, owner)
    local ids = minetest.deserialize(ts_vehicles.mod_storage:get_string("owner:"..owner)) or {}
    table.remove(ids, ts_vehicles.helpers.index_of(ids, id))
    ts_vehicles.mod_storage:set_string("owner:"..owner, minetest.serialize(ids))
end

ts_vehicles.helpers.add_all_owner_mappings = function(id)
    local vd = VD(id)
    for _,owner in ipairs(vd.owners or {}) do
        ts_vehicles.helpers.add_owner_mapping(id, owner)
    end
end

ts_vehicles.helpers.remove_all_owner_mappings = function(id)
    local vd = VD(id)
    for _,owner in ipairs(vd.owners or {}) do
        ts_vehicles.helpers.remove_owner_mapping(id, owner)
    end
end

ts_vehicles.helpers.add_owner = function(id, name)
    local vd = VD(id)
    if not vd then
        return
    end
    if not vd.owners then
        vd.owners = {}
    end
    if not ts_vehicles.helpers.contains(vd.owners, name) then
        table.insert(vd.owners, name)
        ts_vehicles.helpers.add_owner_mapping(id, name)
    end
end

ts_vehicles.helpers.remove_owner = function(id, name)
    local vd = VD(id)
    if vd and vd.owners and ts_vehicles.helpers.contains(vd.owners, name) then
        table.remove(vd.owners, ts_vehicles.helpers.index_of(vd.owners, name))
        ts_vehicles.helpers.remove_owner_mapping(id, name)
    end
end

ts_vehicles.helpers.is_owner = function(id, name)
    local vd = VD(id)
    return vd and vd.owners and ts_vehicles.helpers.contains(vd.owners, name)
end