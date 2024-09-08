-- The following code is from "Get Comfortable [cozy]" (by everamzah; published under WTFPL)
-- Thomas S. modified it, so that it can be used in this mod
ts_vehicles.sit = function(pos, player, offset)
    local name = player:get_player_name()
    if not player_api.player_attached[name] then
        player:move_to(pos)

        local eye_pos = {
            x = offset and offset.x or 0,
            y = offset and (offset.y - 7) or -7,
            z = offset and (offset.z + 2) or 2,
        }

        player:set_eye_offset(eye_pos, {x = 0, y = 0, z = 0})
        player:set_physics_override({speed = 0, jump = 0, gravity = 0})
        player_api.player_attached[name] = true
        minetest.after(0.1, function()
            if player then
                player_api.set_animation(player, "sit" , 30)
            end
        end)
    end
end

ts_vehicles.up = function(player)
    local name = player:get_player_name()
    if player_api.player_attached[name] then
        player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
        player:set_physics_override({speed = 1, jump = 1, gravity = 1})
        player_api.player_attached[name] = false
        player_api.set_animation(player, "stand", 30)
    end
end

if not (minetest.get_modpath("ts_furniture") and ts_furniture.enable_sitting) or not minetest.get_modpath("cozy") then
    minetest.register_globalstep(function(dtime)
        local players = minetest.get_connected_players()
        for i = 1, #players do
            local name = players[i]:get_player_name()
            if default.player_attached[name] and not players[i]:get_attach() and
                    (players[i]:get_player_control().up == true or
                            players[i]:get_player_control().down == true or
                            players[i]:get_player_control().left == true or
                            players[i]:get_player_control().right == true or
                            players[i]:get_player_control().jump == true) then
                players[i]:set_eye_offset({ x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 })
                players[i]:set_physics_override({speed = 1, jump = 1, gravity = 1})
                default.player_attached[name] = false
                default.player_set_animation(players[i], "stand", 30)
            end
        end
    end)
end