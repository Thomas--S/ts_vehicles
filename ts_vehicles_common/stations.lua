-- Vehicle Data
local VD = ts_vehicles.get

local Pipe = techage.LiquidPipe
local liquid = networks.liquid

-- Consumer Related Data
local CRD = function(pos) return (minetest.registered_nodes[techage.get_node_lvm(pos).name] or {}).consumer end

local function update_fs(pos)
    minetest.get_meta(pos):set_string("formspec", ts_vehicles.hose.get_formspec(pos))
end

minetest.register_node("ts_vehicles_common:gasoline_station", {
    description = "Gasoline Station",
    tiles = {
        -- up, down, right, left, back, front
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^techage_gaspipe_hole.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^(ts_vehicles_common_station.png^[multiply:#eefc52)",
    },
    drawtype = "normal",
    after_place_node = function(pos)
        Pipe:after_place_node(pos)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        Pipe:after_dig_node(pos)
        techage.del_mem(pos)
    end,
    on_construct = function(pos)
        update_fs(pos)
    end,
    on_rightclick = function(pos)
        update_fs(pos)
    end,
    paramtype = "light",
    paramtype2 = "facedir",
    on_rotate = screwdriver.disallow,
    groups = { cracky = 2 },
    is_ground_content = false,
    sounds = default.node_sound_metal_defaults(),
    _station = {
        hose_offset = vector.new(.25, .25, -0.55),
        title = "Gasoline Station",
        help_text = "Select a vehicle to fuel.",
        color = "#eefc52",
        type = "gasoline",
        maxlength = 3,
    },
    on_receive_fields = ts_vehicles.hose.station_receive_fields
})

liquid.register_nodes({ "ts_vehicles_common:gasoline_station" }, Pipe, "tank", { "D" }, {
    capa = 1000000,
    peek = function(...) return nil end,
    put = function(pos, indir, name, amount)
        if name ~= "techage:gasoline" then
            return amount
        end
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return amount
        end
        local entity = object:get_luaentity()
        local vd = VD(entity._id)
        local max = ts_vehicles.helpers.get_total_value(entity._id, "gasoline_capacity")
        local to_be_added = math.max(math.min(amount, max - (vd.data.gasoline or 0)), 0)
        vd.data.gasoline = (vd.data.gasoline or 0) + to_be_added
        return amount - to_be_added
    end,
    take = function(...) return 0 end,
    untake = function(pos, outdir, name, amount, player_name)
        return amount
    end,
})

minetest.register_craft({
    output = "ts_vehicles_common:gasoline_station",
    recipe = {
        { "ts_vehicles_common:composite_material", "basic_materials:ic", "" },
        { "techage:ta3_pipeS", "basic_materials:concrete_block", "techage:ta3_barrel_empty" },
        { "", "techage:ta3_pipeS", "" },
    },
})

minetest.register_node("ts_vehicles_common:hydrogen_station", {
    description = "Hydrogen Station",
    tiles = {
        -- up, down, right, left, back, front
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^techage_gaspipe_hole.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^(ts_vehicles_common_station.png^[multiply:#00528a)",
    },
    drawtype = "normal",
    after_place_node = function(pos)
        Pipe:after_place_node(pos)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        Pipe:after_dig_node(pos)
        techage.del_mem(pos)
    end,
    on_construct = function(pos)
        update_fs(pos)
    end,
    on_rightclick = function(pos)
        update_fs(pos)
    end,
    paramtype = "light",
    paramtype2 = "facedir",
    on_rotate = screwdriver.disallow,
    groups = { cracky = 2 },
    is_ground_content = false,
    sounds = default.node_sound_metal_defaults(),
    _station = {
        hose_offset = vector.new(.25, .25, -0.55),
        title = "Hydrogen Station",
        help_text = "Select a vehicle to fuel.",
        color = "#00528a",
        type = "hydrogen",
        maxlength = 3,
    },
    on_receive_fields = ts_vehicles.hose.station_receive_fields
})

liquid.register_nodes({ "ts_vehicles_common:hydrogen_station" }, Pipe, "tank", { "D" }, {
    capa = 1000000,
    peek = function(...) return nil end,
    put = function(pos, indir, name, amount)
        if name ~= "techage:hydrogen" then
            return amount
        end
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return amount
        end
        local entity = object:get_luaentity()
        local vd = VD(entity._id)
        local max = ts_vehicles.helpers.get_total_value(entity._id, "hydrogen_capacity")
        local to_be_added = math.max(math.min(amount, max - (vd.data.hydrogen or 0)), 0)
        vd.data.hydrogen = (vd.data.hydrogen or 0) + to_be_added
        return amount - to_be_added
    end,
    take = function(...) return 0 end,
    untake = function(pos, outdir, name, amount, player_name)
        return amount
    end,
})

minetest.register_craft({
    output = "ts_vehicles_common:hydrogen_station",
    recipe = {
        { "ts_vehicles_common:composite_material", "basic_materials:ic", "" },
        { "techage:ta3_pipeS", "basic_materials:concrete_block", "techage:ta3_cylinder_large" },
        { "", "techage:ta3_pipeS", "" },
    },
})

local electricity_tiles = {
    -- up, down, right, left, back, front
    "basic_materials_concrete_block.png",
    "basic_materials_concrete_block.png^techage_appl_hole_electric.png",
    "basic_materials_concrete_block.png",
    "basic_materials_concrete_block.png",
    "basic_materials_concrete_block.png",
    "basic_materials_concrete_block.png^(ts_vehicles_common_station.png^[multiply:@@40c20e)",
}

local _, _, node_name_ta4 = techage.register_consumer("electricity_station", "Charging Station", { act = electricity_tiles, pas = electricity_tiles }, {
    drawtype = "normal",
    paramtype = "light",
    cycle_time = 1,
    standby_ticks = 3,
    formspec = function(self, pos, nvm)
        return ts_vehicles.hose.get_formspec(pos)
    end,
    tubing = {
        on_recv_message = function(pos, src, topic, payload)
            return CRD(pos).State:on_receive_message(pos, topic, payload)
        end,
    },
    on_rightclick = function(pos, node, clicker)
        techage.set_activeformspec(pos, clicker)
        update_fs(pos)
    end,
    node_timer = function(pos, elapsed)
        local crd = CRD(pos)
        local nvm = techage.get_nvm(pos)
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if object then
            local entity = object:get_luaentity()
            local vd = VD(entity._id)
            local max = ts_vehicles.helpers.get_total_value(entity._id, "electricity_capacity")
            local to_be_added = math.max(math.min(10, max - (vd.data.electricity or 0)), 0)
            vd.data.electricity = (vd.data.electricity or 0) + to_be_added
            crd.State:keep_running(pos, nvm, 1)
        else
            crd.State:idle(pos, nvm)
        end
        if techage.is_activeformspec(pos) then
            update_fs(pos)
        end
    end,
    on_receive_fields = function(pos, formname, fields, player)
        ts_vehicles.hose.station_receive_fields(pos, formname, fields, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return
        end
        local nvm = techage.get_nvm(pos)
        CRD(pos).State:state_button_event(pos, nvm, fields)
    end,
    groups = { cracky = 2 },
    sounds = default.node_sound_metal_defaults(),
    power_consumption = { 0, 10, 10, 10 },
    power_sides = { D = 1 },
    _station = {
        hose_offset = vector.new(.25, .25, -0.55),
        title = "Electricity Station",
        help_text = "Select a vehicle to charge.",
        color = "#40c20e",
        type = "electricity",
        maxlength = 3,
        custom_fs_appendix = function(pos)
            local state = CRD(pos).State
            local nvm = techage.get_nvm(pos)
            local fs = "image_button[10.5,0.5;1,1;" .. state:get_state_button_image(nvm) .. ";state_button;]"
            fs = fs .. "tooltip[10.5,0.5;1,1;" .. state:get_state_tooltip(nvm) .. "]"
            return fs
        end,
    },
}, { false, false, false, true }, "ts_vehicles_common:ta")

minetest.register_craft({
    output = node_name_ta4,
    recipe = {
        { "ts_vehicles_common:composite_material", "basic_materials:ic", "" },
        { "techage:electric_cableS", "basic_materials:concrete_block", "basic_materials:copper_wire" },
        { "", "techage:electric_cableS", "" },
    },
})

minetest.register_node("ts_vehicles_common:tank_terminal", {
    description = "Tank Terminal",
    tiles = {
        -- up, down, right, left, back, front
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^techage_gaspipe_hole.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png",
        "basic_materials_concrete_block.png^techage_gaspipe_hole.png",
        "basic_materials_concrete_block.png^(ts_vehicles_common_station.png^[multiply:#ccc)",
    },
    drawtype = "normal",
    after_place_node = function(pos)
        Pipe:after_place_node(pos)
    end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        Pipe:after_dig_node(pos)
        techage.del_mem(pos)
    end,
    on_construct = function(pos)
        update_fs(pos)
    end,
    on_rightclick = function(pos)
        update_fs(pos)
    end,
    paramtype = "light",
    paramtype2 = "facedir",
    on_rotate = screwdriver.disallow,
    groups = { cracky = 2 },
    is_ground_content = false,
    sounds = default.node_sound_metal_defaults(),
    _station = {
        hose_offset = vector.new(.25, .25, -0.55),
        title = "Tank Terminal",
        help_text = "Select a vehicle to connect to.",
        color = "#ccc",
        type = "payload_tank",
        maxlength = 3,
    },
    on_receive_fields = ts_vehicles.hose.station_receive_fields
})

liquid.register_nodes({ "ts_vehicles_common:tank_terminal" }, Pipe, "tank", { "B", "D" }, {
    capa = 1000000,
    peek = function(pos, indir)
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return nil
        end
        local entity = object:get_luaentity()
        return ts_vehicles.helpers.get_payload_tank_content_name(entity._id)
    end,
    put = function(pos, indir, name, amount)
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return amount
        end
        local entity = object:get_luaentity()
        local id = entity._id
        local vd = VD(id)
        local tank_content_name = ts_vehicles.helpers.get_payload_tank_content_name(id)
        if tank_content_name ~= nil and name ~= tank_content_name then
            return amount
        end
        local max = ts_vehicles.helpers.get_total_value(entity._id, "payload_tank_capacity")
        local to_be_added = math.max(math.min(amount, max - (vd.data.payload_tank_amount or 0)), 0)
        vd.data.payload_tank_amount = (vd.data.payload_tank_amount or 0) + to_be_added
        vd.data.payload_tank_name = name
        return amount - to_be_added
    end,
    take = function(pos, indir, name, amount)
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return 0
        end
        local entity = object:get_luaentity()
        local id = entity._id
        local vd = VD(id)
        local tank_content_name = ts_vehicles.helpers.get_payload_tank_content_name(id)

        if not name or tank_content_name == name then
            name = tank_content_name
            local src_amount = vd.data.payload_tank_amount or 0
            if src_amount > amount then
                vd.data.payload_tank_amount = vd.data.payload_tank_amount - amount
                return amount, name
            else
                vd.data.payload_tank_amount = 0
                vd.data.payload_tank_name = nil
                return src_amount, tank_content_name
            end
        end
        return 0
    end,
    untake = function(pos, outdir, name, amount, player_name)
        local object = ts_vehicles.hose.get_connected_vehicle(pos)
        if not object then
            return amount
        end
        local entity = object:get_luaentity()
        local id = entity._id
        local vd = VD(id)
        local tank_content_name = ts_vehicles.helpers.get_payload_tank_content_name(id)
        if tank_content_name ~= nil and name ~= tank_content_name then
            return amount
        end
        local max = ts_vehicles.helpers.get_total_value(entity._id, "payload_tank_capacity")
        local to_be_added = math.max(math.min(amount, max - (vd.data.payload_tank_amount or 0)), 0)
        vd.data.payload_tank_amount = (vd.data.payload_tank_amount or 0) + to_be_added
        vd.data.payload_tank_name = name
        return amount - to_be_added
    end,
})

minetest.register_craft({
    output = "ts_vehicles_common:tank_terminal",
    recipe = {
        { "ts_vehicles_common:composite_material", "basic_materials:ic", "" },
        { "techage:ta3_pipeS", "basic_materials:concrete_block", "default:mese_crystal" },
        { "", "techage:ta3_pipeS", "" },
    },
})