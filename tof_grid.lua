local DEPTH_APARATUS_URL = "http://192.168.1.100:8888"
start_x = 200 + 20
start_y = 200 + 10
end_x = 1800 - 10
end_y = 1900 - 10
step_size = 10
local KEY = "LAST_COUNT"
local count = json.decode(env(KEY) or "0")

function round(a) return math.floor(a + 0.5) end

function get_tof()
    local params = {method = "GET", url = DEPTH_APARATUS_URL}
    local data, error = http(params)
    if error then
        os.exit()
    else
        return round(json.decode(data.body))
    end
end

function work(x, y)
    move_absolute(x, y, 0)
    local p = get_position()
    local real_x = round(p.x)
    local real_y = round(p.y)
    local real_z = get_tof()
    local body = "" .. real_x .. " " .. real_y .. " " .. real_z .. "\n"
    response, error = http({
        url = tof_address,
        method = "POST",
        headers = {},
        body = body
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
                    env(KEY, "" .. count)
                end
            end
        end
    end
end

env(KEY, "" .. 0)
