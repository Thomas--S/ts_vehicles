ts_vehicles.handle_rightclick = function(self, player, def)
    local player_name = player:get_player_name()
    local wielded_item = player:get_wielded_item()
    local item_name = wielded_item:get_name()
    local control = player:get_player_control()
    local refill_tanks = {
        "techage:ta3_barrel_gasoline", "techage:ta3_canister_gasoline",
        "techage:cylinder_small_hydrogen", "techage:cylinder_large_hydrogen",
        "techage:ta3_akku"
    }
    if control.sneak then
        ts_vehicles.show_formspec(self, player, def)
    elseif ts_vehicles.registered_parts[item_name] and ts_vehicles.registered_compatibilities[self.name][item_name] then
        if ts_vehicles.helpers.contains(self._owners, player_name) then
            local got_added, reason = ts_vehicles.add_part(self, wielded_item, player)
            if not got_added then
                minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] Can't add part: "..reason))
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    elseif ts_vehicles.helpers.contains(refill_tanks, item_name) then
        if ts_vehicles.helpers.contains(self._owners, player_name) then
            if item_name == "techage:ta3_barrel_gasoline" or item_name == "techage:ta3_canister_gasoline" then
                local amount = item_name == "techage:ta3_barrel_gasoline" and 10 or 1
                local free = ts_vehicles.helpers.get_total_value(self, "gasoline_capacity") - (self._data.gasoline or 0)
                if amount <= free then
                    self._data.gasoline = (self._data.gasoline or 0) + amount
                    player:set_wielded_item(item_name == "techage:ta3_barrel_gasoline" and "techage:ta3_barrel_empty" or "techage:ta3_canister_empty")
                end
            elseif item_name == "techage:cylinder_large_hydrogen" or item_name == "techage:cylinder_small_hydrogen" then
                local amount = item_name == "techage:cylinder_large_hydrogen" and 6 or 1
                local free = ts_vehicles.helpers.get_total_value(self, "hydrogen_capacity") - (self._data.hydrogen or 0)
                if amount <= free then
                    self._data.hydrogen = (self._data.hydrogen or 0) + amount
                    player:set_wielded_item(item_name == "techage:cylinder_large_hydrogen" and "techage:ta3_cylinder_large" or "techage:ta3_cylinder_small")
                end
            elseif item_name == "techage:ta3_akku" then
                local meta = wielded_item:get_meta()
                local count = wielded_item:get_count()
                local free = ts_vehicles.helpers.get_total_value(self, "electricity_capacity") - (self._data.electricity or 0)
                local capa = meta:get_int("capa") * count
                local amount = math.min(free, capa)
                self._data.electricity = (self._data.electricity or 0) + amount
                local new_capa = math.floor(((capa - amount) / count) / 5) * 5
                meta:set_int("capa", new_capa)
                meta:set_string("description", techage.S("TA3 Accu Box").." ("..new_capa.." %)")
                player:set_wielded_item(wielded_item)
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    elseif self._driver == nil then
        if ts_vehicles.helpers.contains(self._owners, player_name) then
            local is_driveable, reason = def.is_driveable(self)
            if is_driveable then
                local pos = self.object:get_pos()
                self._driver = player_name
                ts_vehicles.sit(pos, player, def.driver_pos)
                player:set_attach(self.object, nil, def.driver_pos, {x=0,y=0,z=0})
                player:set_look_horizontal(self.object:get_yaw() % (math.pi * 2))
                ts_vehicles.hud.create(player)
            else
                minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] "..reason))
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    elseif self._driver == player_name then
        ts_vehicles.up(player)
        self._driver = nil
        player:set_detach()
        ts_vehicles.hud.remove(player)
    elseif ts_vehicles.passengers.is_passenger(self, player) then
        ts_vehicles.passengers.up(self, player)
    elseif ts_vehicles.passengers.get_num_free_seats(self, def) > 0 then
        if not self._passengers_closed or ts_vehicles.helpers.contains(self._owners, player_name) then
            local is_driveable, reason = def.is_driveable(self)
            if is_driveable then
                ts_vehicles.passengers.sit(self, player, def)
            else
                minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] "..reason))
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    end
end

ts_vehicles.handle_leftclick = function(self, player, def)
    local player_name = player:get_player_name()
    if ts_vehicles.helpers.contains(self._owners, player_name) then
        if #self._parts == 0 then
            local inv = player:get_inventory()
            local leftover = inv:add_item("main", self.name)
            if leftover:get_count() > 0 then
                minetest.add_item(player:get_pos(), self.name)
            end
            self.object:remove()
        else
            ts_vehicles.storage.add_by_player(self, player)
        end
    else
        minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
    end
end

ts_vehicles.handle_timing = function(self, dtime)
    local is_full_second = false
    self._dtime = self._dtime + dtime
    if self._last_light_time ~= nil then
        self._last_light_time = self._last_light_time + dtime
        if self._last_light_time > 0.5 then
            self._last_light_time = nil
        end
    end
    if self._dtime > 1 then
        is_full_second = true
        self._even_step = not self._even_step
        self._dtime = 0
    end
    return is_full_second
end

ts_vehicles.handle_turn = function(self, driver, control, dtime)
    local vehicle = self.object
    local yaw = vehicle:get_yaw() % (math.pi * 2)
    if control then
        if control.left then
            local delta = dtime * math.log(math.abs(self._v) + 1) * ts_vehicles.helpers.sign(self._v) / 2
            yaw = yaw + delta
            ts_vehicles.helpers.turn_player(driver, delta)
            ts_vehicles.passengers.turn(self, delta)
            vehicle:set_yaw(yaw)
        end
        if control.right then
            local delta = dtime * math.log(math.abs(self._v) + 1) * ts_vehicles.helpers.sign(self._v) / 2
            yaw = yaw - delta
            ts_vehicles.helpers.turn_player(driver, -delta)
            ts_vehicles.passengers.turn(self, delta)
            vehicle:set_yaw(yaw)
        end
    end
    return yaw
end

ts_vehicles.handle_car_light_controls = function(self, control, get_horn)
    if control then
        if not control.sneak then
            self._last_light_time = nil
        elseif self._last_light_time == nil then
            if control.up and control.down then
                self._lights.special = not self._lights.special
                self._last_light_time = 0
            elseif control.aux1 and get_horn then
                minetest.sound_play(get_horn(self), {
                    object = self.object,
                    gain = 1.0,
                    max_hear_distance = 1,
                })
            elseif control.left and control.right then
                self._lights.warn = not self._lights.warn
                self._last_light_time = 0
            elseif control.up then
                self._lights.front = not self._lights.front
                self._last_light_time = 0
            elseif control.left then
                self._lights.left = not self._lights.left
                self._lights.right = false
                self._last_light_time = 0
            elseif control.right then
                self._lights.right = not self._lights.right
                self._lights.left = false
                self._last_light_time = 0
            end
        end
        local stop_lights = false
        if control.jump then
            stop_lights = true
        elseif control.up then
            stop_lights = self._v < 0 and true or stop_lights
        elseif control.down then
            stop_lights = self._v > 0 and true or stop_lights
        end
        self._lights.stop = stop_lights
    end
    self._lights.back = self._v < 0
end

ts_vehicles.car_on_step = function(self, dtime, moveresult, def, is_full_second)
    local vehicle = self.object
    local player = self._driver and minetest.get_player_by_name(self._driver) or nil
    local control = player and player:get_player_control() or nil

    if player and is_full_second then
        ts_vehicles.hud.car_update(player, self)
    end

    local velocity = vehicle:get_velocity()
    if velocity.y < -20 then
        ts_vehicles.disperse(self)
        return
    end
    local new_velocity = ts_vehicles.get_car_velocity(self, dtime, control, moveresult, is_full_second)
    self._data.total_distance = (self._data.total_distance or 0) + dtime * self._v
    self._v = new_velocity
    local yaw = ts_vehicles.handle_turn(self, player, control, dtime)
    local dir = minetest.yaw_to_dir(yaw)
    vehicle:set_velocity({x = dir.x * new_velocity, y = velocity.y, z = dir.z * new_velocity})

    ts_vehicles.handle_car_light_controls(self, control, def.get_horn)
    ts_vehicles.apply_textures(self, ts_vehicles.build_textures(def.name, def.textures, self._parts, self))
    ts_vehicles.car_light_beam(self)

    local tire_pos, car_length = ts_vehicles.helpers.get_rotated_collisionbox_corners(self)
    local max_depth = def.stepheight * car_length * 1.5

    local front_downwards_space = math.min(ts_vehicles.helpers.downwards_space(tire_pos[1], max_depth), ts_vehicles.helpers.downwards_space(tire_pos[2], max_depth))
    local back_downwards_space = math.min(ts_vehicles.helpers.downwards_space(tire_pos[3], max_depth), ts_vehicles.helpers.downwards_space(tire_pos[4], max_depth))
    local delta_y = front_downwards_space - back_downwards_space

    ts_vehicles.helpers.pitch_vehicle(self, delta_y, car_length, def)
end

ts_vehicles.remove_part = function(self, part_name, player)
    local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name]
    local can_remove, reason, drop = true, "", part_name
    if vehicle_def.can_remove_part then
        can_remove, reason = vehicle_def.can_remove_part(self, part_name)
    end
    if not can_remove then
        return false, reason
    end
    drop = vehicle_def.get_part_drop(self, part_name)
    if drop == nil then
        return false, "Cannot remove part!"
    end
    ts_vehicles.helpers.part_get_property("after_part_remove", part_name, self.name, function(...) end)(self, drop)
    local inv = player:get_inventory()
    local leftover = inv:add_item("main", drop)
    if leftover:get_count() > 0 then
        minetest.add_item(player:get_pos(), leftover)
    end
    table.remove(self._parts, ts_vehicles.helpers.index_of(self._parts, part_name))
    return true
end

ts_vehicles.add_part = function(self, item, player)
    local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name]
    local can_add, reason, leftover = true, "", ItemStack(item)
    local part_name = item:get_name()
    if vehicle_def.can_add_part then
        can_add, reason, leftover = vehicle_def.can_add_part(self, ItemStack(item))
    else
        leftover:take_item()
    end

    if not can_add then
        return false, reason
    end
    player:set_wielded_item(leftover)
    table.insert(self._parts, part_name)
    ts_vehicles.helpers.part_get_property("after_part_add", part_name, self.name, function(...) end)(self, ItemStack(item))
    return true
end

ts_vehicles.ensure_is_driveable = function(self)
    local def = ts_vehicles.registered_vehicle_bases[self.name]
    local is_driveable, reason = def.is_driveable(self)
    if not is_driveable then
        if self._driver then
            local player = minetest.get_player_by_name(self._driver)
            if player then
                minetest.chat_send_player(self._driver, minetest.colorize("#f00", "[Vehicle] "..reason))
                ts_vehicles.up(player)
                self._driver = nil
                player:set_detach()
            end
        end
        ts_vehicles.passengers.throw_all_out(self, reason)
    end
end

ts_vehicles.ensure_attachments = function(self)
    local children = self.object:get_children()
    local attached_players = {}
    for _,child in ipairs(children) do
        if child.get_player_name and child:get_player_name() and child:get_player_name() ~= "" then
            attached_players[child:get_player_name()] = true
        end
    end
    if self._driver and not attached_players[self._driver] then
        local player = minetest.get_player_by_name(self._driver)
        if player then
            ts_vehicles.up(player)
            player:set_detach()
        end
        self._driver = nil
    end
    for _,passenger in ipairs(ts_vehicles.passengers.get_passenger_list(self)) do
        if passenger and not attached_players[passenger] then
            ts_vehicles.passengers.up_by_name(self, passenger)
        end
    end
end

ts_vehicles.disperse = function(entity)
    local pos = entity.object:get_pos()

    for _,part_name in ipairs(entity._parts) do
        local vehicle_def = ts_vehicles.registered_vehicle_bases[entity.name]
        local drop = vehicle_def.get_part_drop(entity, part_name)
        if drop ~= nil then
            ts_vehicles.helpers.part_get_property("after_part_remove", part_name, entity.name, function(...) end)(entity, drop)
            minetest.add_item(pos, drop)
        end
    end

    while #entity._storage > 0 do
        local stack = ts_vehicles.storage.take(entity, 1)
        minetest.add_item(pos, stack)
    end

    if entity._driver then
        local player = minetest.get_player_by_name(entity._driver)
        if player then
            minetest.chat_send_player(entity._driver, minetest.colorize("#f00", "[Vehicle] The vehicle got destroyed"))
            ts_vehicles.up(player)
            entity._driver = nil
            player:set_detach()
            ts_vehicles.hud.remove(player)
        end
    end
    ts_vehicles.passengers.throw_all_out(entity, "[Vehicle] The vehicle got destroyed")

    entity.object:remove()
end