-- Vehicle Data
local VD = ts_vehicles.get

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
    def.stepheight = def.stepheight or 0.55
    local scale_factor = def.scale_factor or 1
    for i = 1,6 do
        def.collisionbox[i] = def.collisionbox[i] * scale_factor
        def.selectionbox[i] = def.selectionbox[i] * scale_factor
    end
    def.scaled_collisionbox = table.copy(def.collisionbox)
    def.scaled_selectionbox = table.copy(def.selectionbox)
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
                    local vd = VD(luaentity._id)
                    vd.owners = { player_name }
                    vd.parts = table.copy(def.initial_parts)
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
            stepheight = def.stepheight,
        },
        on_rightclick = function(self, player)
            ts_vehicles.handle_rightclick(self, player, def)
        end,
        on_punch = function(self, player, time_from_last_punch, tool_capabilities, dir, damage)
            ts_vehicles.handle_leftclick(self, player, def)
        end,
        on_activate = function(self, staticdata, dtime_s)
            if not staticdata or staticdata == "" then -- object creation
                local id = ts_vehicles.create_id()
                ts_vehicles.load(id)
                self._id = id
            elseif staticdata:sub(1,2) == "2;" then -- storage system version 2 (modstorage)
                local id = tonumber(staticdata:sub(3))
                ts_vehicles.load(id)
                self._id = id
            else -- storage system version 1 (staticdata)
                self._id = ts_vehicles.load_legacy(staticdata)
            end
            local obj = self.object
            obj:set_armor_groups({immortal=1})
            -- Move cars one node up and set gravity one second late in order to avoid sinking cars.
            obj:set_acceleration({ x = 0, y = 0, z = 0 })
            local pos = obj:get_pos()
            pos.y = pos.y + 1
            obj:set_pos(pos)
            ts_vehicles.ensure_light_attached(self)
        end,
        on_deactivate = function(self)
            ts_vehicles.unload(self._id)
        end,
        get_staticdata = function(self)
            return "2;"..self._id
        end,
        on_step = function(self, dtime, moveresult)
            local vd = VD(self._id)
            vd.step_ctr = vd.step_ctr + 1
            local is_full_second = ts_vehicles.handle_timing(vd, dtime)
            if is_full_second then
                if not vd.tmp.gravity_set then
                    self.object:set_acceleration({ x = 0, y = -ts_vehicles.GRAVITATION, z = 0 })
                    vd.tmp.gravity_set = 1
                end
                ts_vehicles.ensure_light_attached(self)
                ts_vehicles.ensure_is_driveable(self)
                if not ts_vehicles.hose.is_entity_connected(vd.connected_to, self._id) then
                    vd.connected_to = nil
                end
                ts_vehicles.ensure_attachments(self)
            end
            def.on_step(self, dtime, moveresult, def, is_full_second)
            if vd.connected_to ~= nil and vector.length(self.object:get_velocity()) > 0.01 then
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
            visual_size = def.lighting_mesh and { x = 10, y = 10, z = 10 },
            mesh = def.lighting_mesh or def.mesh,
            physical = false,
            glow = 12,
            static_save = false,
        },
        _light_entity_for = name,
        on_activate = function(self)
            self.object:set_armor_groups({immortal=1})
            self._animation_delay = math.random()
        end,
        on_step = function(self, dtime)
            if self.object:get_attach() == nil then
                self.object:remove()
            end
            if self._animation_delay then
                self._animation_delay = self._animation_delay - dtime
                if self._animation_delay <= 0 then
                    self.object:set_animation({ x = 0, y = 60 }, math.random()*4+28, 0)
                    self._animation_delay = nil
                end
            end
        end
    })
end


ts_vehicles.register_part = function(name, def)
    ts_vehicles.registered_parts[name] = def
    minetest.register_craftitem(":"..name, {
        description = def.description,
        inventory_image = def.inventory_image,
        inventory_overlay = def.inventory_overlay,
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
