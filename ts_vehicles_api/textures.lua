local get_overlays = function(name, overlays_by_part)
    local result = ""
    for _, overlays in ipairs(overlays_by_part) do
        if overlays[name] ~= nil then
            result = result .. "^" .. overlays[name]
        end
    end
    return result
end

local get_texture_by_name = function(name, textures_by_part, fallback_textures_by_part, overlay_textures_by_part)
    local overlays = get_overlays(name, overlay_textures_by_part)
    for _, textures in ipairs(textures_by_part) do
        if textures[name] ~= nil then
            return textures[name] .. overlays
        end
    end
    for _, fallback_textures in ipairs(fallback_textures_by_part) do
        if fallback_textures[name] ~= nil then
            return fallback_textures[name] .. overlays
        end
    end
    return overlays == "" and "ts_vehicles_api_blank.png" or overlays:sub(2)
end

ts_vehicles.build_textures = function(base_vehicle, texture_names, parts, id)
    local textures = {}
    local fallbacks = {}
    local overlays = {}
    local result = {}
    local vehicle_def = ts_vehicles.registered_vehicle_bases[base_vehicle]
    local vehicle_compatibilities = ts_vehicles.registered_compatibilities[base_vehicle]
    textures[#textures + 1] = ts_vehicles.helpers.call(vehicle_def.get_textures, id)
    fallbacks[#fallbacks + 1] = ts_vehicles.helpers.call(vehicle_def.get_fallback_textures, id)
    overlays[#overlays + 1] = ts_vehicles.helpers.call(vehicle_def.get_overlay_textures, id)
    for _, part in ipairs(parts) do
        local def = vehicle_compatibilities[part:get_name()] or {}
        textures[#textures + 1] = ts_vehicles.helpers.call(def.get_textures, id, part)
        fallbacks[#fallbacks + 1] = ts_vehicles.helpers.call(def.get_fallback_textures, id, part)
        overlays[#overlays + 1] = ts_vehicles.helpers.call(def.get_overlay_textures, id, part)
    end
    for i, texture_name in ipairs(texture_names) do
        result[i] = get_texture_by_name(texture_name, textures, fallbacks, overlays)
    end
    return result
end

ts_vehicles.build_light_textures = function(base_vehicle, texture_names, parts, id)
    local textures = {}
    local fallbacks = {}
    local overlays = {}
    local result = {}
    local vehicle_def = ts_vehicles.registered_vehicle_bases[base_vehicle]
    local vehicle_compatibilities = ts_vehicles.registered_compatibilities[base_vehicle]
    textures[#textures + 1] = ts_vehicles.helpers.call(vehicle_def.get_light_textures, id)
    fallbacks[#fallbacks + 1] = ts_vehicles.helpers.call(vehicle_def.get_light_fallback_textures, id)
    overlays[#overlays + 1] = ts_vehicles.helpers.call(vehicle_def.get_light_overlay_textures, id)
    for _, part in ipairs(parts) do
        local def = vehicle_compatibilities[part:get_name()] or {}
        textures[#textures + 1] = ts_vehicles.helpers.call(def.get_light_textures, id, part)
        fallbacks[#fallbacks + 1] = ts_vehicles.helpers.call(def.get_light_fallback_textures, id, part)
        overlays[#overlays + 1] = ts_vehicles.helpers.call(def.get_light_overlay_textures, id, part)
    end
    for i, texture_name in ipairs(texture_names) do
        result[i] = get_texture_by_name(texture_name, textures, fallbacks, overlays)
    end
    return result
end

ts_vehicles.apply_textures = function(self, textures)
    self.object:set_properties({
        textures = textures
    })
end

ts_vehicles.apply_light_textures = function(self, textures)
    local light_entity = ts_vehicles.get_light_entity(self)
    if light_entity then
        light_entity:set_properties({
            textures = textures
        })
    end
end