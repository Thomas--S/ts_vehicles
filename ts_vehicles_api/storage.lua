ts_vehicles.storage = {}

ts_vehicles.storage.serialize = function(stack)
    return {
        itemstring = stack:peek_item():to_string(),
        count = stack:get_count(),
    }
end

ts_vehicles.storage.deserialize = function(serialized_item)
    local stack = ItemStack(serialized_item.itemstring)
    stack:set_count(math.min(stack:get_stack_max(), serialized_item.count))
    return stack
end

ts_vehicles.storage.get_total_count = function(self)
    local total = 0
    for _,item in ipairs(self._storage) do
        total = total + item.count
    end
    return total
end

ts_vehicles.storage.get_index = function(self, itemstring)
    for idx,item in ipairs(self._storage) do
        if item.itemstring == itemstring then
            return idx
        end
    end
    return nil
end

ts_vehicles.storage.add = function(self, itemstack)
    local serialized_item = ts_vehicles.storage.serialize(itemstack)
    if serialized_item.count == 0 then
        return true, nil, itemstack
    end
    local free_amount = ts_vehicles.helpers.get_total_value(self, "storage_capacity") - ts_vehicles.storage.get_total_count(self)
    if free_amount <= 0 then
        return false, "Storage full!", itemstack
    end
    serialized_item.count = math.min(serialized_item.count, free_amount)
    itemstack:take_item(serialized_item.count)
    local idx = ts_vehicles.storage.get_index(self, serialized_item.itemstring)
    if idx then
        self._storage[idx].count = self._storage[idx].count + serialized_item.count
    else
        table.insert(self._storage, serialized_item)
    end
    return true, "Item(s) successfully added to the storage of the vehicle.", itemstack
end

ts_vehicles.storage.take = function(self, idx, max)
    local serialized_item = self._storage[idx]
    if not serialized_item then
        return ItemStack()
    end
    local stack = ts_vehicles.storage.deserialize(serialized_item)
    local count_to_take = max == nil and stack:get_count() or math.min(max, stack:get_count())
    stack:set_count(count_to_take)
    local new_count = serialized_item.count - count_to_take
    if new_count > 0 then
        self._storage[idx].count = new_count
    else
        table.remove(self._storage, idx)
    end
    return stack
end

ts_vehicles.storage.add_by_player = function(self, player)
    local player_name = player:get_player_name()
    local itemstack = player:get_wielded_item()
    local got_added, message, leftover = ts_vehicles.storage.add(self, itemstack)
    if message then
        minetest.chat_send_player(player_name, minetest.colorize(got_added and "#080" or "#f00", "[Vehicle] "..message))
    end
    player:set_wielded_item(leftover)
end

ts_vehicles.storage.take_by_player = function(self, player, idx, max)
    local stack = ts_vehicles.storage.take(self, idx, max)
    local inv = player:get_inventory()
    local leftover = inv:add_item("main", stack)
    if leftover:get_count() > 0 then
        minetest.chat_send_player(player:get_player_name(), minetest.colorize("#f00", "[Vehicle] Your inventory is full."))
        local _,_,leftover_after_add = ts_vehicles.storage.add(self, leftover)
        if leftover_after_add:get_count() > 0 then
            minetest.add_item(player:get_pos(), leftover_after_add)
        end
    end
end


local function get_vehicle(pos, param2, id)
    local dir = minetest.facedir_to_dir(param2)
    local center_pos = vector.add(pos, vector.multiply(dir, 3))
    local vehicle, min_distance
    local objects = minetest.get_objects_inside_radius(center_pos, 4)
    for _,object in ipairs(objects) do
        local entity = object:get_luaentity()
        if entity and ts_vehicles.registered_vehicle_bases[entity.name]
            and not (id and id ~= entity._id)
            and ts_vehicles.helpers.get_total_value(entity, "storage_capacity") > 0
            and ts_vehicles.helpers.free_line_of_sight(pos, object:get_pos(), entity._id, pos)
        then
            local distance = vector.distance(pos, object:get_pos())
            if not min_distance or distance < min_distance then
                vehicle = entity
                min_distance = distance
            end
            if id and id == entity._id then
                return entity
            end
        end
    end
    return vehicle
end

if minetest.get_modpath("signs_bot") then
    signs_bot.register_botcommand("add_to_vehicle", {
        mod = "ts_vehicles",
        params = "<num> <slot> <id>",
        num_param = 3,
        description = "Place items in the storage\nof a vehicle",
        check = function(num, slot, id)
            num = tonumber(num) or 1
            if num < 1 or num > 99 then
                return false
            end
            slot = tonumber(slot) or 0
            if slot < 0 or slot > 8 then
                return false
            end
            return true
        end,
        cmnd = function(base_pos, mem, num, slot, id)
            num = tonumber(num) or 1
            slot = tonumber(slot) or 0
            id = id and tonumber(id)
            local owner = minetest.get_meta(base_pos):get_string("owner")
            local param2 = mem.robot_param2
            local pos = mem.robot_pos
            local vehicle = get_vehicle(pos, param2, id)
            if vehicle and ts_vehicles.helpers.contains(vehicle._owners, owner) then
                local itemstack = signs_bot.bot_inv_take_item(base_pos, slot, num)
                local _, _, leftover = ts_vehicles.storage.add(vehicle, itemstack)
                if leftover and leftover:get_count() > 0 then
                    signs_bot.bot_inv_put_item(base_pos, slot, leftover)
                end
            end
            return signs_bot.DONE
        end,
    })

    signs_bot.register_botcommand("take_from_vehicle", {
        mod = "ts_vehicles",
        params = "<num> <slot> <id>",
        num_param = 3,
        description = "Take items from the storage\nof a vehicle",
        check = function(num, slot, id)
            num = tonumber(num) or 1
            if num < 1 or num > 99 then
                return false
            end
            slot = tonumber(slot) or 0
            if slot < 0 or slot > 8 then
                return false
            end
            return true
        end,
        cmnd = function(base_pos, mem, num, slot, id)
            num = tonumber(num) or 1
            slot = tonumber(slot) or 0
            id = id and tonumber(id)
            local owner = minetest.get_meta(base_pos):get_string("owner")
            local param2 = mem.robot_param2
            local pos = mem.robot_pos
            local vehicle = get_vehicle(pos, param2, id)
            if vehicle and ts_vehicles.helpers.contains(vehicle._owners, owner) then
                local idx = ts_vehicles.storage.get_index(vehicle, signs_bot.bot_inv_item_name(base_pos, slot)) or math.random(1, math.max(#vehicle._storage, 1))
                if #vehicle._storage > 0 then
                    local taken = ts_vehicles.storage.take(vehicle, idx, num)
                    local leftover = signs_bot.bot_inv_put_item(base_pos, slot, taken)
                    ts_vehicles.storage.add(vehicle, leftover)
                end
            end
            return signs_bot.DONE
        end,
    })
end