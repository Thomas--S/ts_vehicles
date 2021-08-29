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

ts_vehicles.create_id = function()
    local next_number = ts_vehicles.mod_storage:get_int("next_number") or 0
    ts_vehicles.mod_storage:set_int("next_number", next_number + 1)
    return next_number
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
    parts = parts or self._parts
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
    obj:set_rotation(vector.new(pitch, rotation.y, rotation.z))
end

ts_vehicles.helpers.downwards_space = function(pos, max_depth)
    local collision = minetest.raycast(pos, vector.new(pos.x, pos.y - max_depth, pos.z), false, false):next()
    if collision then
        return collision.intersection_point.y - pos.y
    else
        return max_depth
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