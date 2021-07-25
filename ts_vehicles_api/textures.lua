local get_overlays = function(name, overlays_by_part)
    local result = ""
    for _,overlays in ipairs(overlays_by_part) do
        if overlays[name] ~= nil then
            result = result.."^"..overlays[name]
        end
    end
    return result
end

local get_texture_by_name = function(name, textures_by_part, fallback_textures_by_part, overlay_textures_by_part)
    local overlays = get_overlays(name, overlay_textures_by_part)
    for _,textures in ipairs(textures_by_part) do
        if textures[name] ~= nil then
            return textures[name]..overlays
        end
    end
    for _,fallback_textures in ipairs(fallback_textures_by_part) do
        if fallback_textures[name] ~= nil then
            return fallback_textures[name]..overlays
        end
    end
    return overlays == "" and "ts_vehicles_api_blank.png" or overlays:sub(2)
end

ts_vehicles.build_textures = function(base_vehicle, texture_names, parts, ...)
    local base_textures = {}
    local light_textures = {}
    local base_fallbacks = {}
    local light_fallbacks = {}
    local base_overlays = {}
    local light_overlays = {}
    local result = {
        base = {},
        light = {},
    }
    local vehicle_def = ts_vehicles.registered_vehicle_bases[base_vehicle]
    local vehicle_compatibilities = ts_vehicles.registered_compatibilities[base_vehicle]
    base_textures[#base_textures+1] = ts_vehicles.helpers.call(vehicle_def.get_textures, ...)
    light_textures[#light_textures+1] = ts_vehicles.helpers.call(vehicle_def.get_light_textures, ...)
    base_fallbacks[#base_fallbacks+1] = ts_vehicles.helpers.call(vehicle_def.get_fallback_textures, ...)
    light_fallbacks[#light_fallbacks+1] = ts_vehicles.helpers.call(vehicle_def.get_light_fallback_textures, ...)
    base_overlays[#base_overlays+1] = ts_vehicles.helpers.call(vehicle_def.get_overlay_textures, ...)
    light_overlays[#light_overlays+1] = ts_vehicles.helpers.call(vehicle_def.get_light_overlay_textures, ...)
    for _,part in ipairs(parts) do
        local def = vehicle_compatibilities[part] or {}
        base_textures[#base_textures+1] = ts_vehicles.helpers.call(def.get_textures, ...)
        light_textures[#light_textures+1] = ts_vehicles.helpers.call(def.get_light_textures, ...)
        base_fallbacks[#base_fallbacks+1] = ts_vehicles.helpers.call(def.get_fallback_textures, ...)
        light_fallbacks[#light_fallbacks+1] = ts_vehicles.helpers.call(def.get_light_fallback_textures, ...)
        base_overlays[#base_overlays+1] = ts_vehicles.helpers.call(def.get_overlay_textures, ...)
        light_overlays[#light_overlays+1] = ts_vehicles.helpers.call(def.get_light_overlay_textures, ...)
    end
    for i,texture_name in ipairs(texture_names) do
        result.base[i] = get_texture_by_name(texture_name, base_textures, base_fallbacks, base_overlays)
        result.light[i] = get_texture_by_name(texture_name, light_textures, light_fallbacks, light_overlays)
    end
    return result
end

ts_vehicles.apply_textures = function(self, textures)
    self.object:set_properties({
        textures = textures.base
    })
    local light_entity = ts_vehicles.get_light_entity(self)
    if light_entity then
        light_entity:set_properties({
            textures = textures.light
        })
    end
end