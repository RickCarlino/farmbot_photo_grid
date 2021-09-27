start_x = 0
start_y = 0
end_x = 2000
end_y = 2200
step_size = 100

function work(x, y)
    move_absolute(x, y, 0)
    -- Raw binary data to directly upload to the server:
    data = take_photo_raw()
    response, error = http({
        -- `server_address` is set dynamically via NodeJS
        -- See `index.mjs` (towards the bottom)
        url = server_address,
        method = "POST",
        -- IMORTANT: The `file_path` HTTP header is used by
        -- the server in `index.mjs` to set a file name on
        -- the server.
        headers = {file_path = (x .. "." .. y .. ".jpg")},
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
