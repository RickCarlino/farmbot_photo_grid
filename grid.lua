start_x = 400
start_y = 400
end_x = 500
end_y = 500
step_size = 10

function work(x, y)
    move_absolute(x, y, 0)
    data = take_photo_raw()
    response, error = http({
        -- `server_address` is set dynamically via NodeJS
        url = server_address,
        method = "POST",
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
