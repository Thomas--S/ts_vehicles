ts_vehicles = {}
ts_vehicles.priv = minetest.settings:get("ts_vehicles.priv") or "ban"
ts_vehicles.mod_storage = minetest.get_mod_storage()

ts_vehicles.writing = minetest.global_exists("font_api")

local modpath = minetest.get_modpath("ts_vehicles_api")

local vehicle_data = {}
local waiting_for_unload = {}

function ts_vehicles.load(id)
    waiting_for_unload[id] = false
    local result = minetest.deserialize(ts_vehicles.mod_storage:get_string(id))
    if result then
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
            dtime = math.random(),
            even_step = false,
            step_ctr = 0,
            driver = nil,
            passengers = {},
            last_light_time = nil,
        }
    else
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
            dtime = math.random(),
            even_step = false,
            step_ctr = 0,
            driver = nil,
            passengers = {},
            last_light_time = nil,
        }
    end
end


function ts_vehicles.load_legacy(staticdata)
    local data = minetest.deserialize(staticdata)
    waiting_for_unload[data._id] = false
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
        }))
    end
end

function ts_vehicles.unload(id)
    waiting_for_unload[id] = true
    minetest.after(1, function()
        if waiting_for_unload[id] then
            ts_vehicles.store(id)
            vehicle_data[id] = nil
        end
    end)
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
        local data1 = ts_vehicles.get(id1)
        local data2 = ts_vehicles.get(id2)
        if not data1 and ts_vehicles.mod_storage:contains(id1) then
            ts_vehicles.load(id1)
            data1 = ts_vehicles.get(id1)
        end
        if not data2 and ts_vehicles.mod_storage:contains(id2) then
            ts_vehicles.load(id2)
            data2 = ts_vehicles.get(id2)
        end
        if not (data1 and data2) then
            minetest.chat_send_player(name, "Vehicle data does not exist.")
            return
        end
        data1.tmp.light_textures_set = false
        data1.tmp.base_textures_set = false
        data2.tmp.light_textures_set = false
        data2.tmp.base_textures_set = false
        vehicle_data[id1] = data2
        vehicle_data[id2] = data1
        ts_vehicles.store(id1)
        ts_vehicles.store(id2)
    end
})