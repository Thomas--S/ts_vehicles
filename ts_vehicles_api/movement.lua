ts_vehicles.ground_factors = {}

local ground_factors = ts_vehicles.ground_factors

ts_vehicles.get_car_velocity = function(self, dtime, control, moveresult, is_full_second)
    local engine_power = self._data.engine_power or 0
    local max_velocity = engine_power
    local max_backwards_velocity = max_velocity / 2
    local brake_deceleration = engine_power
    local acceleration = engine_power / 4
    local backwards_acceleration = engine_power / 8

    local enough_fuel = true
    local gasoline_consumption = ts_vehicles.helpers.get_total_value(self, "gasoline_consumption") * dtime
    local hydrogen_consumption = ts_vehicles.helpers.get_total_value(self, "hydrogen_consumption") * dtime
    local electricity_consumption = ts_vehicles.helpers.get_total_value(self, "electricity_consumption") * dtime

    if gasoline_consumption > 0 and (self._data.gasoline or 0) <= 0
        or hydrogen_consumption > 0 and (self._data.hydrogen or 0) <= 0
        or electricity_consumption > 0 and (self._data.electricity or 0) <= 0
    then
        enough_fuel = false
    end

    local use_fuel = false

    local vehicle = self.object
    local velocity = vehicle:get_velocity()
    local v = ts_vehicles.helpers.sign(self._v) * vector.length(velocity)
    local new_velocity = v * (self._data.velocity_efficiency or .7) ^ dtime

    if is_full_second and moveresult and moveresult.touching_ground then
        local ground_pos = ts_vehicles.helpers.get_ground_pos_from_moveresult(moveresult)
        if ground_pos then
            local node = minetest.get_node(ground_pos)
            self._data.ground_factor = ground_factors[node.name] or .2
        end
    end

    local ground_factor = self._data.ground_factor or .2

    if control then
        if control.jump then
            local v_reduction = ts_vehicles.helpers.sign(v) * brake_deceleration * dtime
            new_velocity = math.abs(v) > math.abs(v_reduction) and (v - v_reduction) or 0
        elseif control.up then
            if v < 0 then
                new_velocity = v + brake_deceleration * dtime * ground_factor
            elseif enough_fuel then
                new_velocity = v + acceleration * dtime * ground_factor
                use_fuel = true
            end
        elseif control.down then
            if v > 0 then
                new_velocity = v - brake_deceleration * dtime * ground_factor
            elseif enough_fuel then
                new_velocity = v - backwards_acceleration * dtime * ground_factor
                use_fuel = true
            end
        end
    end

    if use_fuel then
        self._data.gasoline = math.max(0, (self._data.gasoline or 0) - gasoline_consumption)
        self._data.hydrogen = math.max(0, (self._data.hydrogen or 0) - hydrogen_consumption)
        self._data.electricity = math.max(0, (self._data.electricity or 0) - electricity_consumption)
    end

    if math.abs(new_velocity) < 0.05 and not (control and (control.up or control.down)) then
        new_velocity = 0
    end
    return ts_vehicles.helpers.clamp(new_velocity, -max_backwards_velocity * ground_factor, max_velocity * ground_factor)
end

minetest.after(.1, function()
    for node_name, def in pairs(minetest.registered_nodes) do
        if def.mod_origin == "autobahn" then
            ground_factors[node_name] = 1
        elseif def.groups.cracky then -- Most likely something stonelike
            ground_factors[node_name] = .85
        elseif node_name:find("gravel") then
            ground_factors[node_name] = .7
        elseif def.groups.wood or def.groups.tree then
            ground_factors[node_name] = .55
        elseif node_name:find("dirt") then
            ground_factors[node_name] = .35
        end
    end
end)