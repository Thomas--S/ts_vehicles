ts_vehicles = {}
ts_vehicles.priv = minetest.settings:get("ts_vehicles.priv") or "ban"
ts_vehicles.mod_storage = minetest.get_mod_storage()

ts_vehicles.writing = minetest.global_exists("font_api")

local modpath = minetest.get_modpath("ts_vehicles_api")
local worldpath = minetest.get_worldpath()
local insecure_environment = minetest.request_insecure_environment()

if not insecure_environment then
    error("Could not access insecure environment.\nAdd 'secure.trusted_mods = ts_vehicles_api' to minetest.conf!")
end

local sqlite3 = insecure_environment.require("lsqlite3")
if not sqlite3 then
    error("Could not find sqlite3. Please use 'luarocks install lsqlite3' to install it.")
end

local marshal = insecure_environment.require("marshal")
if not marshal then
    error("Could not find marshal. Please use 'luarocks install lua-marshal' to install it.")
end

local db = sqlite3.open(worldpath.."/ts_vehicles_data.sqlite")

db:exec([[
    CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY,
        owners BLOB,
        passengers_closed BOOLEAN,
        v DOUBLE,
        lights BLOB,
        data BLOB,
        parts BLOB,
        storage BLOB,
        connected_to BLOB,
        last_seen_pos BLOB,
    );
    CREATE UNIQUE INDEX idx ON vehicles(key);
]])

local vehicle_data = {}
local waiting_for_unload = {}

local load_stmt = db:prepare("SELECT * FROM vehicles WHERE id = :id")
local row = sqlite3.ROW
function ts_vehicles.load(id)
    waiting_for_unload[id] = false
    load_stmt:reset()
    load_stmt:bind_names({id = id})
    if load_stmt:step() == row then
        local col_names = load_stmt:get_names()
        local values = load_stmt:get_values()
        local result = {}
        for k,v in ipairs(col_names) do
            result[v] = values[k]
        end
        vehicle_data[id] = {
            tmp = {},
            owners = marshal.decode(result.owners),
            passengers_closed = result.passengers_closed == 1,
            v = result.v,
            lights = marshal.decode(result.lights),
            data = marshal.decode(result.data),
            parts = marshal.decode(result.parts),
            storage = marshal.decode(result.storage),
            connected_to = marshal.decode(result.connected_to),
            last_seen_pos = result.last_seen_pos and marshal.decode(result.last_seen_pos) or nil,
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

local store_stmt = db:prepare([[
    INSERT OR REPLACE INTO vehicles VALUES
    (:id, :owners, :passengers_closed, :v, :lights, :data, :parts, :storage, :connected_to, :last_seen_pos);
]])
function ts_vehicles.store(id)
    local data = ts_vehicles.get(id)
    if data then
        store_stmt:reset()
        store_stmt:bind_names({
            id = id,
            owners = marshal.encode(data.owners),
            passengers_closed = data.passengers_closed,
            v = data.v,
            lights = marshal.encode(data.lights),
            data = marshal.encode(data.data),
            parts = marshal.encode(data.parts),
            storage = marshal.encode(data.storage),
            connected_to = marshal.encode(data.connected_to),
            last_seen_pos = marshal.encode(data.last_seen_pos),
        })
        store_stmt:step()
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
    for id,_ in pairs(vehicle_data) do
        ts_vehicles.store(id)
    end
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

-- Prevent use of this db instance.
if sqlite3 then sqlite3 = nil end

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