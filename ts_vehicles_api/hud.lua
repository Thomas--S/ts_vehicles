-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.hud = {}

local hud_elements = {}

ts_vehicles.hud.car_update = function(player, entity)
    local playername = player:get_player_name()
    local id = hud_elements[playername]
    if id then
        local vd = VD(entity._id)
        local text = ("Velocity: %.1fkm/h"):format(vd.v * 3.6)
        for _, fuel in pairs({ "gasoline", "hydrogen", "electricity" }) do
            local capacity = ts_vehicles.helpers.get_total_value(entity._id, fuel .. "_capacity")
            if (capacity > 0) then
                text = text ..
                    (" | %s: %.1f%%"):format(fuel:sub(1, 1):upper() .. fuel:sub(2), (vd.data[fuel] or 0) * 100 / capacity)
            end
        end
        player:hud_change(id, "text", text)
    end
end

ts_vehicles.hud.helicopter_update = function(player, entity)
    local playername = player:get_player_name()
    local id = hud_elements[playername]
    if id then
        local vd = VD(entity._id)
        local yawDeg = (-math.deg(entity.object:get_yaw())) % 360
        local dirName = "N"
        if yawDeg > 22.5 and yawDeg <= 67.5 then
            dirName = "NE"
        elseif yawDeg > 67.5 and yawDeg <= 112.5 then
            dirName = "E"
        elseif yawDeg > 112.5 and yawDeg <= 157.5 then
            dirName = "SE"
        elseif yawDeg > 157.5 and yawDeg <= 202.5 then
            dirName = "S"
        elseif yawDeg > 202.5 and yawDeg <= 247.5 then
            dirName = "SW"
        elseif yawDeg > 247.5 and yawDeg <= 292.5 then
            dirName = "W"
        elseif yawDeg > 292.5 and yawDeg <= 337.5 then
            dirName = "NW"
        end

        local text = ("Ground speed: %.1fkm/h"):format(vd.v * 3.6)
        for _, fuel in pairs({ "gasoline", "hydrogen", "electricity" }) do
            local capacity = ts_vehicles.helpers.get_total_value(entity._id, fuel .. "_capacity")
            if (capacity > 0) then
                text = text ..
                    (" | %s: %.1f%%"):format(fuel:sub(1, 1):upper() .. fuel:sub(2), (vd.data[fuel] or 0) * 100 / capacity)
            end
        end
        text = text .. (" | Altitude (AMSL): %dm"):format(entity.object:get_pos().y)
        text = text .. (" | Heading: %d° (%s)"):format(yawDeg, dirName)
        player:hud_change(id, "text", text)
    end
end

ts_vehicles.hud.create = function(player)
    local playername = player:get_player_name()
    hud_elements[playername] = player:hud_add({
        hud_elem_type = "text",
        position = { x = .5, y = .7 },
        offset = { x = 0, y = 0 },
        name = "",
        alignment = { x = 0, y = 0 },
        scale = { x = 100, y = 1000 },
        text = "",
        number = 0xffffff,
    })
end

ts_vehicles.hud.remove = function(player)
    local playername = player:get_player_name()
    local id = hud_elements[playername]
    if id then
        player:hud_remove(id)
    end
    hud_elements[playername] = nil
end
