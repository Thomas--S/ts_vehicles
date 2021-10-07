-- Vehicle Data
local VD = ts_vehicles.get

ts_vehicles.get_lamps_texture = function(base_texture, defs)
    local base = base_texture
    local light = ""

    for _,def in ipairs(defs) do
        if def.state then -- lamp is on
            light = light.."^("..def.overlay_texture_on..")"
            base = base.."^("..def.overlay_texture_on..")"
        else -- lamp is off
            base = base.."^("..def.overlay_texture_off..")"
        end
    end

    return { base = base, light = light == "" and "ts_vehicles_api_blank.png" or light:sub(2) }
end

ts_vehicles.get_light_entity = function(self)
    for _, child in ipairs(self.object:get_children()) do
        if child.get_luaentity then
            local luaentity = child:get_luaentity()
            if luaentity and luaentity._light_entity_for then
                return child
            end
        end
    end
end

ts_vehicles.ensure_light_attached = function(self)
    if not ts_vehicles.get_light_entity(self) then
        local entity = minetest.add_entity(self.object:get_pos(), self.name.."_lighting")
        if entity then
            entity:set_attach(self.object, nil, {x=0,y=0,z=0}, {x=0,y=0,z=0})
        end
    end
end

ts_vehicles.place_light = function(pos)
    local node_name = minetest.get_node(pos).name
    if node_name == "air" then
        minetest.set_node(pos, {name = "ts_vehicles_api:light"})
    elseif node_name == "ts_vehicles_api:light" then
        minetest.get_node_timer(pos):start(2)
    end
end

ts_vehicles.car_light_beam = function(self)
    local vehicle = self.object
    local vd = VD(self._id)
    if vd.lights.front and ts_vehicles.helpers.any_has_group(vd.parts, "lights_front") then
        local p1 = vehicle:get_pos()
        p1.y = p1.y + 1
        ts_vehicles.place_light(p1)

        local p2 = vector.add(p1, vector.multiply(minetest.yaw_to_dir(vehicle:get_yaw()), 20))
        local collision = minetest.raycast(p1, p2, false, true):next()
        if collision then
            p2 = collision.above
        end
        ts_vehicles.place_light(p2)
    end
end

minetest.register_node("ts_vehicles_api:light", {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    floodable = true,
    drop = "",
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(2)
    end,
    on_timer = function(pos)
        minetest.remove_node(pos)
    end,
    light_source = 14,
    groups = {not_in_creative_inventory=1},
})
