ts_vehicles_cars.lightbars = {
    {
        id = "blue",
        name = "Blue",
        off = "ts_vehicles_cars_blue_light_off.png",
        on1 = "ts_vehicles_cars_blue_light_on.png^[transformFX",
        on2 = "ts_vehicles_cars_blue_light_on.png",
        restricted = true,
        recipe = {"blue", "blue"},
    },
    {
        id = "amber",
        name = "Amber",
        off = "ts_vehicles_cars_amber_light_off.png",
        on1 = "ts_vehicles_cars_amber_light_on.png^[transformFX",
        on2 = "ts_vehicles_cars_amber_light_on.png",
        recipe = {"orange", "orange"},
    },
    {
        id = "red",
        name = "Red",
        off = "ts_vehicles_cars_red_light_off.png",
        on1 = "ts_vehicles_cars_red_light_on.png^[transformFX",
        on2 = "ts_vehicles_cars_red_light_on.png",
        recipe = {"red", "red"},
    },
    {
        id = "red_and_blue",
        name = "Red and Blue",
        off = "ts_vehicles_cars_red_and_blue_light_off.png",
        on1 = "ts_vehicles_cars_red_and_blue_light_on1.png",
        on2 = "ts_vehicles_cars_red_and_blue_light_on2.png",
        restricted = true,
        recipe = {"blue", "red"},
    }
}

for _,def in ipairs(ts_vehicles_cars.lightbars) do
    ts_vehicles.register_part("ts_vehicles_cars:"..def.id.."_light", {
        description = def.name.." Light",
        inventory_image = def.on1.."^[mask:ts_vehicles_cars_roof_attachment_inv_mask.png",
        groups = { roof_attachment = 1, },
        get_formspec = function(self, player)
            local fs = ""
            fs = fs.."style_type[label;font_size=*2]"
            fs = fs.."style_type[label;font=bold]"
            fs = fs.."label[0,.25;Set text for the information matrix on the light bar]"
            fs = fs.."style_type[label;font_size=*1]"
            fs = fs.."style_type[label;font=normal]"
            fs = fs.."field[0,1;3,1;text;;"..minetest.formspec_escape(self._data.roof_top_text or "").."]"
            fs = fs.."button[3,1;1.5,1;set;Set]"
            return fs
        end,
        on_receive_fields = function(self, player, fields)
            if fields.text and (fields.set or fields.key_enter_field == "text") then
                self._data.roof_top_text = fields.text
            end
        end,
        after_part_remove = function(self, drop)
            self._data.roof_top_text = nil
        end,
    })

    minetest.register_craft({
        output = "ts_vehicles_cars:"..def.id.."_light",
        recipe = {
            {"dye:"..def.recipe[1], "default:glass", "dye:"..def.recipe[2]},
            {"techage:simplelamp_off", "default:mese", "techage:simplelamp_off"},
            {"ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material", "ts_vehicles_common:composite_material"},
        },
    })

    if def.restricted then
        ts_vehicles_common.register_restricted_item("ts_vehicles_cars:"..def.id.."_light")
    end
end
