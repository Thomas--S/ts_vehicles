ts_vehicles.check_requirement_tree = function(requirement_tree, parts)

end

ts_vehicles.is_car_ready = function(self)
    local requirement_tree = {
        requires = {
            tires = {},
            base_plate = {
                requires = {"tires"}
            }
        },
    }


    local needed_parts = {
        ["tires"] = false,
        ["engine"] = false,
        ["tank"] = false,
    }
    local parts = self.parts

end