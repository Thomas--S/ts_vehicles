-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.passengers = {}

ts_vehicles.passengers.get_passenger_list = function(self)
    local passengers = {}
    for _, passenger in pairs(VD(self._id).passengers) do
        passengers[#passengers + 1] = passenger
    end
    return passengers
end

ts_vehicles.passengers.get_num_free_seats = function(self, def)
    return #def.passenger_pos - #ts_vehicles.passengers.get_passenger_list(self)
end

ts_vehicles.passengers.is_passenger = function(self, player)
    for _, passenger in pairs(ts_vehicles.passengers.get_passenger_list(self)) do
        if passenger == player:get_player_name() then
            return true
        end
    end
    return false
end

ts_vehicles.passengers.get_next_empty_seat = function(self, def)
    for idx, seat in ipairs(def.passenger_pos) do
        if VD(self._id).passengers[idx] == nil then
            return idx, seat
        end
    end
end

ts_vehicles.passengers.get_seat_by_player = function(self, name)
    for idx, passenger in pairs(VD(self._id).passengers) do
        if passenger == name then
            return idx
        end
    end
end

ts_vehicles.passengers.sit = function(self, player, def)
    local pos = self.object:get_pos()
    local seat_idx, seat_pos = ts_vehicles.passengers.get_next_empty_seat(self, def)
    VD(self._id).passengers[seat_idx] = player:get_player_name()
    ts_vehicles.sit(pos, player)
    ts_vehicles.helpers.attach_player(player, self.object, seat_pos)
    player:set_look_horizontal(self.object:get_yaw() % (math.pi * 2))
end

ts_vehicles.passengers.up = function(self, player)
    ts_vehicles.up(player)
    local seat_idx = ts_vehicles.passengers.get_seat_by_player(self, player:get_player_name())
    if seat_idx then
        VD(self._id).passengers[seat_idx] = nil
    end
    player:set_detach()
end

ts_vehicles.passengers.up_by_name = function(self, player_name)
    local seat_idx = ts_vehicles.passengers.get_seat_by_player(self, player_name)
    if seat_idx then
        VD(self._id).passengers[seat_idx] = nil
    end
    local player = minetest.get_player_by_name(player_name)
    if player then
        ts_vehicles.up(player)
        player:set_detach()
    end
end

ts_vehicles.passengers.turn = function(self, delta)
    for _, passenger in ipairs(ts_vehicles.passengers.get_passenger_list(self)) do
        local player = minetest.get_player_by_name(passenger)
        if player then
            ts_vehicles.helpers.turn_player(player, delta)
        end
    end
end
