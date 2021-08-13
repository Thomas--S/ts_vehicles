ts_vehicles.registered_vehicle_bases = {}
ts_vehicles.registered_parts = {}
ts_vehicles.registered_compatibilities = {}

local function dye_to_color(name)
    if not unifieddyes or not unifieddyes.get_color_from_dye_name then
        return "#ffffff"
    end
    if name == "dye:brown" then
        return "#b43500"
    elseif name == "dye:pink" then
        return "#ff5050"
    end
    return "#"..unifieddyes.get_color_from_dye_name(name)
end

ts_vehicles.register_vehicle_base = function(name, def)
    def.name = name
    local scale_factor = def.scale_factor or 1
    for i = 1,6 do
        def.collisionbox[i] = def.collisionbox[i] * scale_factor
        def.selectionbox[i] = def.selectionbox[i] * scale_factor
    end
    def.gasoline_hose_offset = vector.multiply(def.gasoline_hose_offset, scale_factor)
    def.hydrogen_hose_offset = vector.multiply(def.hydrogen_hose_offset, scale_factor)
    def.electricity_hose_offset = vector.multiply(def.electricity_hose_offset, scale_factor)

    ts_vehicles.registered_vehicle_bases[name] = def
    ts_vehicles.registered_compatibilities[name] = {}
    minetest.register_craftitem(":"..name, {
        inventory_image = def.inventory_image,
        description = def.item_description,
        on_place = function(itemstack, player, pointed_thing)
            if pointed_thing and pointed_thing.above then
                if not player:is_player() then
                    return false
                end

                local object = minetest.add_entity(pointed_thing.above, name)
                local player_name = player:get_player_name()
                if object then
                    object:set_yaw(player:get_look_horizontal())
                    local luaentity = object:get_luaentity()
                    luaentity._owners = { player_name }
                    luaentity._parts = table.copy(def.initial_parts)
                    itemstack:take_item()
                end
            end
            return itemstack
        end
    })
    minetest.register_entity(":"..name, {
        initial_properties = {
            collisionbox = def.collisionbox,
            selectionbox = def.selectionbox,
            visual = "mesh",
            mesh = def.mesh,
            visual_size = { x = scale_factor, y = scale_factor, z = scale_factor },
            physical = true,
            collide_with_objects = true,
            stepheight = def.stepheight or 0.55,
        },
        on_rightclick = function(self, player)
            ts_vehicles.handle_rightclick(self, player, def)
        end,
        on_punch = function(self, player, time_from_last_punch, tool_capabilities, dir, damage)
            ts_vehicles.handle_leftclick(self, player, def)
        end,
        on_activate = function(self, staticdata, dtime_s)
            self.object:set_armor_groups({immortal=1})
            local data = minetest.deserialize(staticdata)
            if data then
                self._id = data._id or ts_vehicles.create_id()
                self._owners = data._owners
                self._passengers_closed = data._passengers_closed
                self._v = data._v
                self._lights = data._lights
                self._data = data._data
                self._parts = data._parts
                self._storage = data._storage
                self._connected_to = data._connected_to
            else
                self._id = ts_vehicles.create_id()
                self._data = {}
                self._lights = {
                    left = false,
                    right = false,
                    warn = false,
                    front = false,
                    back = false,
                    stop = false,
                    special = false,
                }
                self._v = 0
                self._passengers_closed = true
                self._owners = nil
                self._storage = {}
                self._parts = {}
            end
            self._dtime = math.random()
            self._tmp = {}
            self._even_step = false
            self._step_ctr = 0
            self._driver = nil
            -- Passengers are stored as a table; indexed by the seat position as given in the vehicle definition.
            self._passengers = {}
            self._last_light_time = nil,
            self.object:set_acceleration({ x = 0, y = -ts_vehicles.GRAVITATION, z = 0 })
            ts_vehicles.ensure_light_attached(self)
        end,
        get_staticdata = function(self)
            local data = {
                _id = self._id,
                _owners = self._owners,
                _passengers_closed = self._passengers_closed,
                _v = self._v,
                _lights = self._lights,
                _data = self._data,
                _parts = self._parts,
                _storage = self._storage,
                _connected_to = self._connected_to
            }
            return minetest.serialize(data)
        end,
        on_step = function(self, dtime, moveresult)
            self._step_ctr = self._step_ctr + 1
            local is_full_second = ts_vehicles.handle_timing(self, dtime)
            if is_full_second then
                ts_vehicles.ensure_light_attached(self)
                ts_vehicles.ensure_is_driveable(self)
                if not ts_vehicles.hose.is_entity_connected(self) then
                    self._connected_to = nil
                end
                ts_vehicles.ensure_attachments(self)
            end
            def.on_step(self, dtime, moveresult, def, is_full_second)
            if self._connected_to ~= nil and vector.length(self.object:get_velocity()) > 0.01 then
                ts_vehicles.hose.disconnect(self)
            end
        end
    })
    minetest.register_entity(":"..name.."_lighting", {
        initial_properties = {
            collisionbox = { 0, 0, 0, 0, 0, 0 },
            selectionbox = { 0, 0, 0, 0, 0, 0 },
            visual = "mesh",
            -- Scale the light entity up a tiny little bit to ensure that the lights are always visible.
            visual_size = { x = 1.001, y = 1.001, z = 1.001 },
            mesh = def.mesh,
            physical = false,
            glow = 12,
            static_save = false,
        },
        _light_entity_for = name,
        on_activate = function(self)
            self.object:set_armor_groups({immortal=1})
        end,
        on_step = function(self)
            if self.object:get_attach() == nil then
                self.object:remove()
            end
        end
    })
end


ts_vehicles.register_part = function(name, def)
    ts_vehicles.registered_parts[name] = def
    minetest.register_craftitem(":"..name, {
        description = def.description,
        inventory_image = def.inventory_image,
        _ts_vehicles = {
            colorable = def.colorable,
        },
        color = def.default_color,
    })
    if def.colorable then
        minetest.register_craft({
            output = name,
            type = "shapeless",
            recipe = { name, "group:dye" }
        })
    end
end

ts_vehicles.register_compatibility = function(base_name, part_name, def)
    ts_vehicles.registered_compatibilities[base_name][part_name] = def
end


local craft_function = function(itemstack, player, old_craft_grid, craft_inv)
    local item, dye
    for _,stack in ipairs(old_craft_grid) do
        local def = stack:get_definition()
        if def._ts_vehicles and def._ts_vehicles.colorable then
            if item then
                return nil
            else
                item = stack
            end
        elseif def.groups and def.groups.dye then
            if dye then
                return nil
            else
                dye = stack
            end
        elseif stack:get_name() ~= "" then
            return nil
        end
    end
    if not item or not dye then
        return nil
    end

    local meta = itemstack:get_meta()
    meta:set_string("color", dye_to_color(dye:get_name()))
    meta:set_string("description", item:get_definition().description.." ("..dye:get_description():gsub(" Dye", "")..")")
    return itemstack
end

minetest.register_on_craft(craft_function)
minetest.register_craft_predict(craft_function)
