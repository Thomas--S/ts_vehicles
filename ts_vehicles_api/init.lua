ts_vehicles = {}
ts_vehicles.priv = minetest.settings:get("ts_vehicles.priv") or "ban"
ts_vehicles.mod_storage = minetest.get_mod_storage()

ts_vehicles.writing = minetest.global_exists("font_api")

local modpath = minetest.get_modpath("ts_vehicles_api")

local vehicle_data = {}
local unload_jobs = {}

function ts_vehicles.create()
    local id = ts_vehicles.mod_storage:get_int("next_number") or 1
    ts_vehicles.mod_storage:set_int("next_number", id + 1)

    vehicle_data[id] = {
        tmp = {},
        owners = nil,
        passengers_closed = true,
        v = 0,
        lights = {
            left = false,
            right = false,
            warn = false,
            front = false,
            back = false,
            stop = false,
            special = false,
        },
        data = {},
        parts = {},
        storage = {},
        connected_to = nil,
        last_seen_pos = nil,
        name = nil,
        dtime = math.random(),
        even_step = false,
        step_ctr = 0,
        driver = nil,
        passengers = {},
        last_light_time = nil,
    }

    return id
end

function ts_vehicles.load(id)
    if vehicle_data[id] then
        return
    end
    local result = minetest.deserialize(ts_vehicles.mod_storage:get_string(id))
    if not result then
        return
    end
    vehicle_data[id] = {
        tmp = {},
        owners = result.owners,
        passengers_closed = result.passengers_closed,
        v = result.v,
        lights = result.lights,
        data = result.data,
        parts = result.parts,
        storage = result.storage,
        connected_to = result.connected_to,
        last_seen_pos = result.last_seen_pos,
        name = result.name,
        dtime = math.random(),
        even_step = false,
        step_ctr = 0,
        driver = nil,
        passengers = {},
        last_light_time = nil,
    }
end


function ts_vehicles.load_legacy(staticdata)
    local data = minetest.deserialize(staticdata)
    vehicle_data[data._id] = {
        tmp = {},
        owners = data._owners,
        passengers_closed = data._passengers_closed,
        v = data._v,
        lights = data._lights,
        data = data._data,
        parts = data._parts,
        storage = data._storage,
        connected_to = data._connected_to,
        last_seen_pos = nil,
        name = nil,
        dtime = math.random(),
        even_step = false,
        step_ctr = 0,
        driver = nil,
        passengers = {},
        last_light_time = nil,
    }
    return data._id
end

function ts_vehicles.get(id)
    if not id then
        return
    end
    if not vehicle_data[id] then
        ts_vehicles.load(id)
    end
    if unload_jobs[id] then
        unload_jobs[id]:cancel()
    end
    unload_jobs[id] = minetest.after(10, function()
        ts_vehicles.store(id)
        vehicle_data[id] = nil
    end)
    return vehicle_data[id]
end

function ts_vehicles.store(id)
    local data = ts_vehicles.get(id)
    if data then
        ts_vehicles.mod_storage:set_string(id, minetest.serialize({
            id = id,
            owners = data.owners,
            passengers_closed = data.passengers_closed,
            v = data.v,
            lights = data.lights,
            data = data.data,
            parts = data.parts,
            storage = data.storage,
            connected_to = data.connected_to,
            last_seen_pos = data.last_seen_pos,
            name = data.name,
        }))
    end
end

function ts_vehicles.delete(id)
    ts_vehicles.helpers.remove_all_owner_mappings(id)
    if unload_jobs[id] then
        unload_jobs[id]:cancel()
        unload_jobs[id] = nil
    end
    ts_vehicles.mod_storage:set_string(id, "")
    vehicle_data[id] = nil
end

function ts_vehicles.store_all()
    local num_vehicles = #vehicle_data
    local start = minetest.get_us_time()
    for id,_ in pairs(vehicle_data) do
        ts_vehicles.store(id)
    end
    local finish = minetest.get_us_time()
    print("[ts_vehicles] Storing the data of "..num_vehicles.." vehicles in "..(finish-start).."µs.")
end

-- Store all active data every 60 seconds
local function store_all()
    ts_vehicles.store_all()
    minetest.after(60, store_all)
end
minetest.after(60, store_all)

minetest.register_on_shutdown(function()
    ts_vehicles.store_all()
end)

ts_vehicles.swap_vehicle_data = function(id1, id2)
    local data1 = ts_vehicles.get(id1)
    local data2 = ts_vehicles.get(id2)
    if not (data1 and data2) then
        return false
    end
    ts_vehicles.helpers.remove_all_owner_mappings(id1)
    ts_vehicles.helpers.remove_all_owner_mappings(id2)
    data1.tmp = {}
    data2.tmp = {}
    vehicle_data[id1] = data2
    vehicle_data[id2] = data1
    ts_vehicles.store(id1)
    ts_vehicles.store(id2)
    ts_vehicles.helpers.add_all_owner_mappings(id1)
    ts_vehicles.helpers.add_all_owner_mappings(id2)
    return true
end


dofile(modpath.."/helpers.lua")
dofile(modpath.."/hose.lua")
dofile(modpath.."/storage.lua")
dofile(modpath.."/posture.lua")
dofile(modpath.."/light.lua")
dofile(modpath.."/formspec.lua")
dofile(modpath.."/passengers.lua")
dofile(modpath.."/hud.lua")
dofile(modpath.."/handlers.lua")
dofile(modpath.."/textures.lua")
dofile(modpath.."/movement.lua")
dofile(modpath.."/registration.lua")

if not math.round then
    function math.round(x)
        if x >= 0 then
            return math.floor(x + .5)
        end
        return math.ceil(x - .5)
    end
end

minetest.register_chatcommand("swap_vehicle_data", {
    params = "<vehicle 1 id> <vehicle 2 id>",
    description = "Swaps the vehicle data of two vehicles (specified by ID). Make sure to only swap the data for vehicles of the same type.",
    privs = {[ts_vehicles.priv] = true},
    func = function(name, param)
        local id1, id2 = string.match(param or "", "^(%d+) (%d+)")
        if not (id1 and id2) then
            minetest.chat_send_player(name, "Invalid parameters.")
            return
        end
        id1 = tonumber(id1)
        id2 = tonumber(id2)

        if not ts_vehicles.swap_vehicle_data(id1, id2) then
            minetest.chat_send_player(name, "Vehicle data does not exist.")
        end
    end
})

minetest.after(1, function()
    if not ts_vehicles.mod_storage:contains("migration:owner_mapping_and_name") then
        for k,_ in pairs((ts_vehicles.mod_storage:to_table() or {}).fields) do
            local id = tonumber(k)
            if id and ts_vehicles.mod_storage:contains(id) then -- Numeric key, i.e. vehicle ID
                ts_vehicles.helpers.add_all_owner_mappings(id)

                -- Try to add vd.name where possible
                local vd = ts_vehicles.get(id)
                if vd then
                    local base_name_match
                    local conflict = false
                    for _,part in ipairs(vd.parts or {}) do
                        local number_of_matches = 0
                        local part_base_name_match
                        for base_name,_ in pairs(ts_vehicles.registered_vehicle_bases) do
                            if ts_vehicles.registered_compatibilities[base_name][part] then
                                number_of_matches = number_of_matches + 1
                                part_base_name_match = base_name
                            end
                        end
                        if number_of_matches == 1 and part_base_name_match ~= nil and not conflict then
                            if base_name_match == nil then
                                base_name_match = part_base_name_match
                            elseif base_name_match ~= part_base_name_match then
                                 conflict = true
                            end
                        end
                    end
                    if not conflict and base_name_match ~= nil then
                        vd.name = base_name_match
                    end
                end
            end
        end
        ts_vehicles.mod_storage:set_string("migration:owner_mapping_and_name", "done")
    end
end)