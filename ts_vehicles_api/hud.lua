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
        for _,fuel in pairs({"gasoline", "hydrogen", "electricity"}) do
            local capacity = ts_vehicles.helpers.get_total_value(entity, fuel.."_capacity")
            if (capacity > 0) then
                text = text .. (" | %s: %.1f%%"):format(fuel:sub(1,1):upper()..fuel:sub(2), (vd.data[fuel] or 0) * 100 / capacity)
            end
        end
        player:hud_change(id, "text", text)
    end
end

ts_vehicles.hud.create = function(player)
    local playername = player:get_player_name()
    hud_elements[playername] = player:hud_add({
        hud_elem_type = "text",
        position = {x=.5, y=.7},
        offset = {x=0, y=0},
        name = "",
        alignment = {x=0,y=0},
        scale = {x = 100, y = 1000},
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