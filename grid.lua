start_x = 200 + 20
start_y = 200 + 10
end_x = 1800 - 10
end_y = 1900 - 10
step_size = 10
local count = json.decode(env("LAST_COUNT") or "0")

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
local i = 0
for y = start_y, end_y, step_size do
    for x = start_x, end_x, step_size do
        i = i + 1
        if read_status("informational_settings", "locked") then
            send_message("error", "Halting execution", "toast")
            return
        else
            if i > count then
                collectgarbage()
                error = work(x, y)
                if not error then
                    count = count + 1
                    env("LAST_COUNT", "" .. count)
                end
            end
        end
    end
end

env("LAST_COUNT", "" .. 0)
