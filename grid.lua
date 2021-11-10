start_x = 200
start_y = 200
end_x = 1800
end_y = 2000
step_size = 100

function round(a) return math.floor(a + 0.5) end

function work(x, y)
    move_absolute(x, y, 0)
    write_pin(7, "digital", 1)
    -- Raw binary data to directly upload to the server:
    local data = take_photo_raw()
    local p = get_position()
    local real_x = round(p.x)
    local real_y = round(p.y)
    local real_z = round(soil_height(real_x, real_y))
    local path = "" .. real_x .. "." .. real_y .. "." .. real_z .. ".jpg"
    response, error = http({
        -- `server_address` is set dynamically via NodeJS
        -- See `index.mjs` (towards the bottom)
        url = server_address,
        method = "POST",
        -- IMORTANT: The `file_path` HTTP header is used by
        -- the server in `index.mjs` to set a file name on
        -- the server.
        headers = {file_path = path},
        body = data
    })
    return error
end

for y = start_y, end_y, step_size do
    for x = start_x, end_x, step_size do
        if read_status("informational_settings", "locked") then
            send_message("error", "Halting execution", "toast")
            return
        else
            error = work(x, y)
            if error then return end
        end
    end
end
