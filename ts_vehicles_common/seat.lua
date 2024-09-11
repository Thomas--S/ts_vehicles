local seat_registered = false
ts_vehicles_common.register_seat = function()
    if seat_registered then
        return
    end
    seat_registered = true
    ts_vehicles.register_part("ts_vehicles_common:seat", {
        description = "Seat",
        inventory_image = "ts_vehicles_common_seat.png",
        groups = { seats = 1, },
        colorable = true,
    })

    minetest.register_craft({
        output = "ts_vehicles_common:seat",
        recipe = {
            { "", "", "wool:white" },
            { "", "", "wool:white" },
            { "wool:white", "wool:white", "wool:white" },
        },
    })
end