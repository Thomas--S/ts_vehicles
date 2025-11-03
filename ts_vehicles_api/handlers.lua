-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.handle_rightclick = function(self, player, def)
    local player_name = player:get_player_name()
    local wielded_item = player:get_wielded_item()
    local item_name = wielded_item:get_name()
    local control = player:get_player_control()
    local vd = VD(self._id)
    local refill_tanks = {
        "techage:ta3_barrel_gasoline", "techage:ta3_canister_gasoline",
        "techage:cylinder_small_hydrogen", "techage:cylinder_large_hydrogen",
        "techage:ta3_akku"
    }
    if control.sneak then
        ts_vehicles.show_formspec(self, player, def)
    elseif ts_vehicles.registered_parts[item_name] and ts_vehicles.registered_compatibilities[self.name][item_name] then
        if ts_vehicles.helpers.is_owner(self._id, player_name) then
            local got_added, reason = ts_vehicles.add_part(self, wielded_item, player)
            if not got_added then
                minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] Can't add part: " .. reason))
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    elseif item_name == "ts_vehicles_common:universal_key" and minetest.check_player_privs(player_name, ts_vehicles.priv) then
        ts_vehicles.helpers.add_owner(self._id, player_name)
    elseif ts_vehicles.helpers.contains(refill_tanks, item_name) then
        if ts_vehicles.helpers.is_owner(self._id, player_name) then
            if item_name == "techage:ta3_barrel_gasoline" or item_name == "techage:ta3_canister_gasoline" then
                local amount = item_name == "techage:ta3_barrel_gasoline" and 10 or 1
                local free = ts_vehicles.helpers.get_total_value(self._id, "gasoline_capacity") - (vd.data.gasoline or 0)
                if amount <= free then
                    vd.data.gasoline = (vd.data.gasoline or 0) + amount
                    player:set_wielded_item(item_name == "techage:ta3_barrel_gasoline" and "techage:ta3_barrel_empty" or "techage:ta3_canister_empty")
                end
            elseif item_name == "techage:cylinder_large_hydrogen" or item_name == "techage:cylinder_small_hydrogen" then
                local amount = item_name == "techage:cylinder_large_hydrogen" and 6 or 1
                local free = ts_vehicles.helpers.get_total_value(self._id, "hydrogen_capacity") - (vd.data.hydrogen or 0)
                if amount <= free then
                    vd.data.hydrogen = (vd.data.hydrogen or 0) + amount
                    player:set_wielded_item(item_name == "techage:cylinder_large_hydrogen" and "techage:ta3_cylinder_large" or "techage:ta3_cylinder_small")
                end
            elseif item_name == "techage:ta3_akku" then
                local meta = wielded_item:get_meta()
                local count = wielded_item:get_count()
                local free = ts_vehicles.helpers.get_total_value(self._id, "electricity_capacity") - (vd.data.electricity or 0)
                local capa = meta:get_int("capa") * count
                local amount = math.min(free, capa)
                vd.data.electricity = (vd.data.electricity or 0) + amount
                local new_capa = math.floor(((capa - amount) / count) / 5) * 5
                meta:set_int("capa", new_capa)
                meta:set_string("description", techage.S("TA3 Accu Box") .. " (" .. new_capa .. " %)")
                player:set_wielded_item(wielded_item)
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    elseif ts_vehicles.passengers.is_passenger(self, player) then
        ts_vehicles.passengers.up(self, player)
    elseif vd.driver == nil and ts_vehicles.helpers.is_owner(self._id, player_name) then
        local is_driveable, reason = def.is_driveable(self)
        if is_driveable then
            local pos = self.object:get_pos()
            vd.driver = player_name
            ts_vehicles.sit(pos, player)
            ts_vehicles.helpers.attach_player(player, self.object, def.driver_pos)
            player:set_look_horizontal(self.object:get_yaw() % (math.pi * 2))
            ts_vehicles.hud.create(player)
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] " .. reason))
        end
    elseif vd.driver == player_name then
        ts_vehicles.up(player)
        vd.driver = nil
        player:set_detach()
        ts_vehicles.hud.remove(player)
    elseif ts_vehicles.passengers.get_num_free_seats(self, def) > 0 then
        if not vd.passengers_closed or ts_vehicles.helpers.is_owner(self._id, player_name) then
            local is_driveable, reason = def.is_driveable(self)
            if is_driveable then
                ts_vehicles.passengers.sit(self, player, def)
            else
                minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] " .. reason))
            end
        else
            minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
        end
    end
end

ts_vehicles.handle_leftclick = function(self, player, def)
    local player_name = player:get_player_name()
    local vd = VD(self._id)
    if ts_vehicles.helpers.is_owner(self._id, player_name) then
        if #vd.parts == 0 then
            local inv = player:get_inventory()
            local leftover = inv:add_item("main", self.name)
            if leftover:get_count() > 0 then
                minetest.add_item(player:get_pos(), self.name)
            end
            ts_vehicles.delete(self._id)
            self.object:remove()
        else
            ts_vehicles.storage.add_by_player(self, player)
        end
    else
        minetest.chat_send_player(player_name, minetest.colorize("#f00", "[Vehicle] You don't have access to this vehicle."))
    end
end

ts_vehicles.handle_timing = function(vd, dtime)
    local is_full_second = false
    vd.dtime = vd.dtime + dtime
    if vd.last_light_time ~= nil then
        vd.last_light_time = vd.last_light_time + dtime
        if vd.last_light_time > 0.5 then
            vd.last_light_time = nil
        end
    end
    if vd.dtime > 1 then
        is_full_second = true
        vd.even_step = not vd.even_step
        vd.dtime = 0
    end
    return is_full_second
end

ts_vehicles.handle_turn = function(self, driver, control, dtime, delta)
    local vehicle = self.object
    local rotation = vehicle:get_rotation()
    local yaw = rotation.y % (math.pi * 2)
    if control and (control.left or control.right) then
        local vd = VD(self._id)
        if (vd.data.turn_snap or 0) > 0 then
            vd.data.turn_snap = (vd.data.turn_snap or 0) - dtime
        else
            if delta == nil then
                delta = dtime * math.log(math.abs(vd.v) + 1) * ts_vehicles.helpers.sign(vd.v) / 2
            end
            if control.right then delta = -delta end
            local snap_delta = (yaw + (math.pi / 8)) % (math.pi / 4) - math.pi / 8
            if math.abs(snap_delta) < math.abs(delta * .9) and math.abs(snap_delta) > 0.001 then
                delta = -snap_delta
                vd.data.turn_snap = .4
            end
            yaw = yaw + delta
            ts_vehicles.helpers.turn_player(driver, delta)
            ts_vehicles.passengers.turn(self, delta)
            vehicle:set_rotation({ x = rotation.x, y = yaw, z = rotation.z })
        end
    end
    return yaw
end

ts_vehicles.handle_car_light_controls = function(self, control)
    local vd = VD(self._id)
    if control then
        if not control.sneak then
            vd.last_light_time = nil
        elseif vd.last_light_time == nil then
            if control.aux1 then
                vd.lights.special = not vd.lights.special
                vd.tmp.light_textures_set = false
                vd.last_light_time = 0
            elseif control.down then
                vd.lights.warn = not vd.lights.warn
                vd.tmp.light_textures_set = false
                vd.last_light_time = 0
            elseif control.up then
                vd.lights.front = not vd.lights.front
                vd.tmp.light_textures_set = false
                vd.last_light_time = 0
            elseif control.left then
                vd.lights.left = not vd.lights.left
                vd.tmp.light_textures_set = false
                vd.lights.right = false
                vd.last_light_time = 0
            elseif control.right then
                vd.lights.right = not vd.lights.right
                vd.tmp.light_textures_set = false
                vd.lights.left = false
                vd.last_light_time = 0
            end
        end
        local stop_lights = false
        if control.jump then
            stop_lights = true
        elseif control.up then
            stop_lights = vd.v < 0 and true or stop_lights
        elseif control.down then
            stop_lights = vd.v > 0 and true or stop_lights
        end
        if vd.lights.stop ~= stop_lights then
            vd.lights.stop = stop_lights
            vd.tmp.light_textures_set = false
        end
    elseif vd.lights.stop then
        vd.lights.stop = false
        vd.tmp.light_textures_set = false
    end
    local back = vd.v < 0
    if vd.lights.back ~= back then
        vd.lights.back = back
        vd.tmp.light_textures_set = false
    end
end

ts_vehicles.car_on_step = function(self, dtime, moveresult, def, is_full_second)
    local vehicle = self.object
    local vd = VD(self._id)
    local player = vd.driver and minetest.get_player_by_name(vd.driver) or nil
    local control = player and player:get_player_control() or nil

    if player and is_full_second then
        ts_vehicles.hud.car_update(player, self)
    end

    local velocity = vehicle:get_velocity()
    local new_velocity = player and ts_vehicles.get_car_velocity(self, dtime, control, moveresult, def, is_full_second) or 0
    vd.data.total_distance = (vd.data.total_distance or 0) + dtime * vd.v
    vd.v = new_velocity
    local yaw = ts_vehicles.handle_turn(self, player, control, dtime)
    local dir = minetest.yaw_to_dir(yaw)
    vehicle:set_velocity({ x = dir.x * new_velocity, y = velocity.y, z = dir.z * new_velocity })

    ts_vehicles.handle_car_light_controls(self, control)
    if not vd.tmp.base_textures_set then
        ts_vehicles.apply_textures(self, ts_vehicles.build_textures(def.name, def.textures, vd.parts, self._id))
        vd.tmp.base_textures_set = true
    end
    if not vd.tmp.light_textures_set then
        ts_vehicles.apply_light_textures(self, ts_vehicles.build_light_textures(def.name, def.lighting_textures, vd.parts, self._id))
        vd.tmp.light_textures_set = true
    end

    if is_full_second then
        ts_vehicles.car_light_beam(self)
        local tire_pos, car_length = ts_vehicles.helpers.get_rotated_collisionbox_corners(self)
        local max_depth = def.stepheight * car_length * 1.5
        local front_downwards_space = math.max(ts_vehicles.helpers.downwards_space(tire_pos[1], max_depth), ts_vehicles.helpers.downwards_space(tire_pos[2], max_depth))
        local back_downwards_space = math.max(ts_vehicles.helpers.downwards_space(tire_pos[3], max_depth), ts_vehicles.helpers.downwards_space(tire_pos[4], max_depth))
        local delta_y = front_downwards_space - back_downwards_space
        ts_vehicles.helpers.pitch_vehicle(self, delta_y, car_length, def)
    end
    if vehicle:get_velocity().y < -20 then
        ts_vehicles.throw_all_out(self, "The vehicle is falling too fast.")
    end
end

ts_vehicles.helicopter_on_step = function(self, dtime, moveresult, def, is_full_second)
    local vehicle = self.object
    local vd = VD(self._id)
    local player = vd.driver and minetest.get_player_by_name(vd.driver) or nil
    local control = player and player:get_player_control() or nil
    if not vd.tmp.animation_set then
        self.object:set_animation({ x = 0, y = 60 }, 0, 0)
        vd.tmp.animation_set = true
    end

    if is_full_second then
        vd.data.time_to_state_change = math.max((vd.data.time_to_state_change or 0) - 1, 0)
        if vd.data.time_to_state_change == 0 then
            if vd.data.state == "starting" then
                vd.data.state = "started"
                vd.tmp.light_textures_set = false
            end
            if vd.data.state == "stopping" then
                vd.data.state = "stopped"
                vd.tmp.light_textures_set = false
            end
        end
        if vd.data.state == "started" then
            self.object:set_animation_frame_speed(60)
        elseif vd.data.state == "starting" then
            self.object:set_animation_frame_speed(6 * (10 - (vd.data.time_to_state_change or 0)))
        elseif vd.data.state == "stopping" then
            self.object:set_animation_frame_speed(6 * (vd.data.time_to_state_change or 0))
        else
            self.object:set_animation_frame_speed(0)
        end

        if vd.data.state == "started" and player then
            self.object:set_acceleration({ x = 0, y = 0, z = 0 })
        else
            self.object:set_acceleration({ x = 0, y = -ts_vehicles.GRAVITATION, z = 0 })
        end
    end

    local fuel_consumption = 0
    if vd.data.state == "starting" then
        fuel_consumption = 1
    elseif vd.data.state == "started" then
        fuel_consumption = .1
    end
    if fuel_consumption > 0 then
        local gasoline_consumption = ts_vehicles.helpers.get_total_value(self._id, "gasoline_consumption") * dtime
        local hydrogen_consumption = ts_vehicles.helpers.get_total_value(self._id, "hydrogen_consumption") * dtime
        local electricity_consumption = ts_vehicles.helpers.get_total_value(self._id, "electricity_consumption") * dtime

        vd.data.gasoline = math.max(0, (vd.data.gasoline or 0) - fuel_consumption * gasoline_consumption)
        vd.data.hydrogen = math.max(0, (vd.data.hydrogen or 0) - fuel_consumption * hydrogen_consumption)
        vd.data.electricity = math.max(0, (vd.data.electricity or 0) - fuel_consumption * electricity_consumption)
    end

    if player and is_full_second then
        ts_vehicles.hud.helicopter_update(player, self)
    end

    local velocity = vehicle:get_velocity()
    local new_velocity = player and vd.data.state == "started" and
        ts_vehicles.get_helicopter_velocity(self, dtime, control, moveresult, def, is_full_second) or
        { horizontal = 0, vertical = ts_vehicles.helpers.clamp(velocity.y, -10, 10) }
    vd.data.total_distance = (vd.data.total_distance or 0) + dtime * vd.v
    vd.v = new_velocity.horizontal
    local turn_delta = vd.data.state == "started" and dtime * math.log(math.abs(vd.v) + 2) / 2 or 0
    local yaw = ts_vehicles.handle_turn(self, player, control, dtime, turn_delta)
    local dir = minetest.yaw_to_dir(yaw)
    vehicle:set_velocity({
        x = dir.x * new_velocity.horizontal,
        y = new_velocity.vertical,
        z = dir.z * new_velocity.horizontal
    })

    if is_full_second then
        if vd.lights.sl and not ts_vehicles.helpers.any_has_group(vd.parts, "search_light") then
            vd.lights.sl = false
            vd.tmp.light_textures_set = false
        end
        local fuel_ratio = ts_vehicles.get_fuel_ratio(self._id)
        if fuel_ratio == 0 then
            if vd.data.state == "started" or vd.data.state == "starting" then
                vd.data.time_to_state_change = 10 - (vd.data.time_to_state_change or 0)
                vd.data.state = "stopping"
                vd.lights.nav = false
                vd.lights.acl = false
                vd.lights.ll = false
                vd.lights.sl = false
                vd.tmp.light_textures_set = false
            end
            if vd.lights.fuel ~= "off" then
                vd.lights.fuel = "off"
                vd.tmp.light_textures_set = false
            end
        elseif fuel_ratio <= .15 then
            if vd.lights.fuel ~= "warn" then
                vd.lights.fuel = "warn"
                vd.tmp.light_textures_set = false
            end
        else
            if vd.lights.fuel ~= "on" then
                vd.lights.fuel = "on"
                vd.tmp.light_textures_set = false
            end
        end
    end

    if not vd.tmp.base_textures_set then
        ts_vehicles.apply_textures(self, ts_vehicles.build_textures(def.name, def.textures, vd.parts, self._id))
        vd.tmp.base_textures_set = true
    end
    if not vd.tmp.light_textures_set then
        ts_vehicles.apply_light_textures(self,
            ts_vehicles.build_light_textures(def.name, def.lighting_textures, vd.parts, self._id))
        vd.tmp.light_textures_set = true
    end

    if is_full_second then
        ts_vehicles.helicopter_light_beam(self)
        if moveresult and moveresult.touching_ground then
            local tire_pos, car_length = ts_vehicles.helpers.get_rotated_collisionbox_corners(self)
            local max_depth = def.stepheight * car_length * 1.5
            local front_downwards_space = math.max(ts_vehicles.helpers.downwards_space(tire_pos[1], max_depth),
                ts_vehicles.helpers.downwards_space(tire_pos[2], max_depth))
            local back_downwards_space = math.max(ts_vehicles.helpers.downwards_space(tire_pos[3], max_depth),
                ts_vehicles.helpers.downwards_space(tire_pos[4], max_depth))
            local delta_y = front_downwards_space - back_downwards_space
            ts_vehicles.helpers.pitch_vehicle(self, delta_y, car_length, def)
        elseif moveresult then
            ts_vehicles.helpers.pitch_vehicle(self, -new_velocity.horizontal / 70, 3, def)
        end
        -- Do nothing if there is no moveresult (e.g. because the vehicle is moved via techage move controller).
    end
    if vehicle:get_velocity().y < -20 then
        ts_vehicles.throw_all_out(self, "The vehicle is falling too fast.")
    end
end

ts_vehicles.remove_part = function(self, index, player)
    local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name]
    local vd = VD(self._id)

    local part = vd.parts[index]
    if not part then
        return false, "Part does not exist"
    end

    local parts_copy = table.copy(vd.parts)
    table.remove(parts_copy, ts_vehicles.helpers.index_of(parts_copy, part))
    local is_structure_sound, reason = vehicle_def.is_structure_sound(self, parts_copy)
    if not is_structure_sound then
        return false, reason
    end

    ts_vehicles.helpers.part_get_property("after_part_remove", part:get_name(), self.name, function(...) end)(self, part, player)
    local inv = player:get_inventory()
    local leftover = inv:add_item("main", part)
    if leftover:get_count() > 0 then
        minetest.add_item(player:get_pos(), leftover)
    end
    table.remove(vd.parts, ts_vehicles.helpers.index_of(vd.parts, part))
    vd.tmp.base_textures_set = false
    vd.tmp.light_textures_set = false
    return true
end

ts_vehicles.add_part = function(self, item, player)
    local vehicle_def = ts_vehicles.registered_vehicle_bases[self.name]
    local vd = VD(self._id)
    local quantity = ts_vehicles.helpers.part_get_property("quantity", item:get_name(), self.name, 1)

    local parts_copy = table.copy(VD(self._id).parts)
    local item_copy = ItemStack(item)
    item_copy:set_count(quantity)
    table.insert(parts_copy, item_copy)
    local is_structure_sound, reason = vehicle_def.is_structure_sound(self, parts_copy)
    if not is_structure_sound then
        return false, reason
    end

    if item:get_count() < quantity then
        return false, "Not enough items; " .. tonumber(quantity) .. " are required."
    end

    local leftover = ItemStack(item)
    local part_to_add = leftover:take_item(quantity)

    player:set_wielded_item(leftover)
    table.insert(vd.parts, part_to_add)
    ts_vehicles.helpers.part_get_property("after_part_add", part_to_add:get_name(), self.name, function(...) end)(self,
        part_to_add, player)
    vd.tmp.base_textures_set = false
    vd.tmp.light_textures_set = false
    return true
end

ts_vehicles.ensure_is_driveable = function(self)
    local vd = VD(self._id)
    local def = ts_vehicles.registered_vehicle_bases[self.name]
    local is_driveable, reason = def.is_driveable(self)
    if not is_driveable then
        ts_vehicles.throw_all_out(self, reason)
    end
end

ts_vehicles.ensure_attachments = function(self)
    local attached_players = {}
    local children = self.object:get_children()
    for _, child in ipairs(children) do
        if child.get_player_name and child:get_player_name() and child:get_player_name() ~= "" then
            attached_players[child:get_player_name()] = true
        end
        local grandchildren = child:get_children()
        for _, grandchild in ipairs(grandchildren) do
            if grandchild.get_player_name and grandchild:get_player_name() and grandchild:get_player_name() ~= "" then
                attached_players[grandchild:get_player_name()] = true
            end

        end
    end
    local vd = VD(self._id)
    if vd.driver and not attached_players[vd.driver] then
        local player = minetest.get_player_by_name(vd.driver)
        if player then
            ts_vehicles.up(player)
            player:set_detach()
            ts_vehicles.hud.remove(player)
        end
        vd.driver = nil
    end
    for _, passenger in ipairs(ts_vehicles.passengers.get_passenger_list(self)) do
        if passenger and not attached_players[passenger] then
            ts_vehicles.passengers.up_by_name(self, passenger)
        end
    end
end

ts_vehicles.throw_all_out = function(self, reason)
    local vd = VD(self._id)

    if vd.driver then
        local player = minetest.get_player_by_name(vd.driver)
        if player then
            minetest.chat_send_player(vd.driver, minetest.colorize("#f00", "[Vehicle] " .. reason))
            ts_vehicles.up(player)
            vd.driver = nil
            player:set_detach()
            ts_vehicles.hud.remove(player)
        end
    end

    for _, passenger in ipairs(ts_vehicles.passengers.get_passenger_list(self)) do
        local player = minetest.get_player_by_name(passenger)
        if player then
            minetest.chat_send_player(passenger, minetest.colorize("#f00", "[Vehicle] " .. reason))
            ts_vehicles.passengers.up(self, player)
        end
    end
end
