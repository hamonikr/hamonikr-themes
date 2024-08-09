require 'cairo'

settings_table = {}

function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr, t, pt)
    local w, h = conky_window.width, conky_window.height

    local xc, yc, ring_r, ring_w, sa, ea = pt['x'], pt['y'], pt['radius'], pt['thickness'], pt['start_angle'], pt['end_angle']
    local bgc, bga, fgc, fga = pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

    local angle_0 = sa * (2 * math.pi / 360) - math.pi / 2
    local angle_f = ea * (2 * math.pi / 360) - math.pi / 2
    local t_arc = t * (angle_f - angle_0)

    -- Draw background ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)

    -- Draw indicator ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
    cairo_stroke(cr)
end

function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

function read_temp_sensor(sensor_path)
    local file = io.open(sensor_path, "r")
    if file then
        local temp = file:read("*n") / 1000  -- 온도를 읽고 나누기 1000
        file:close()
        return temp
    else
        return nil
    end
end

function detect_temp_sensors()
    local hwmon_dir = "/sys/class/hwmon/"

    for dir in io.popen('ls ' .. hwmon_dir):lines() do
        local name_file = hwmon_dir .. dir .. "/name"
        if file_exists(name_file) then
            local name = io.open(name_file, "r"):read("*l")
            io.close(io.open(name_file, "r"))
            local temp_path = hwmon_dir .. dir .. "/temp1_input"
            if file_exists(temp_path) then
                return {
                    name = 'hwmon',
                    arg = dir .. ' temp 1',
                    path = temp_path,
                    max = 100,
                    bg_colour = 0xFFFFFF,
                    bg_alpha = 0.2,
                    fg_colour = 0xFF1493,
                    fg_alpha = 1,
                    x = 259.5,
                    y = 210.5,
                    radius = 25,
                    thickness = 7,
                    start_angle = 0,
                    end_angle = 360
                }
            end
        end
    end
    return nil
end

function conky_get_battery()
    local battery_file = "/sys/class/power_supply/BAT0/uevent"
    if file_exists(battery_file) then
        local battery = conky_parse("${battery_percent BAT0}")
        local value = tonumber(battery)
        if value == nil then
            value = 100
        end
        return value
    else
        return 100
    end
end

function conky_get_temp_sensor()
    local sensor = detect_temp_sensors()
    if sensor and sensor.path then
        local temp = read_temp_sensor(sensor.path)
        if temp ~= nil then
            return math.floor(temp)
        end
    end
    return 0
end

function conky_ring_stats()
    if #settings_table == 0 then
        settings_table = {
            {
                name = 'cpu',
                arg = 'cpu0',
                max = 100,
                bg_colour = 0xffffff,
                bg_alpha = 0.2,
                fg_colour = 0x5105DB,
                fg_alpha = 1,
                x = 49.5,
                y = 210.5,
                radius = 25,
                thickness = 7,
                start_angle = 0,
                end_angle = 360,
            },
            {
                name = 'memperc',
                arg = '',
                max = 100,
                bg_colour = 0xFFFFFFF,
                bg_alpha = 0.2,
                fg_colour = 0x8B0AC3,
                fg_alpha = 1,
                x = 119.7,
                y = 210.5,
                radius = 25,
                thickness = 7,
                start_angle = 0,
                end_angle = 360
            },
            {
                name = 'battery_percent',
                arg = 'BAT0',
                max = 100,
                bg_colour = 0xFFFFFF,
                bg_alpha = 0.2,
                fg_colour = 0xC20EAC,
                fg_alpha = 1,
                x = 190,
                y = 210.5,
                radius = 25,
                thickness = 7,
                start_angle = 0,
                end_angle = 360
            }
        }

        local sensor = detect_temp_sensors()
        if sensor then
            table.insert(settings_table, sensor)
        end
    end

    local function setup_rings(cr, pt)
        local value = 0

        if pt['name'] == 'battery_percent' then
            value = conky_get_battery()
        elseif pt['name'] == 'hwmon' then
            value = read_temp_sensor(pt['path'])
        else
            local str = string.format('${%s %s}', pt['name'], pt['arg'])
            str = conky_parse(str)
            value = tonumber(str)
            if value == nil then
                value = 0
            end
        end

        local pct = value / pt['max']
        draw_ring(cr, pct, pt)
    end

    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

    local cr = cairo_create(cs)

    local updates = conky_parse('${updates}')
    local update_num = tonumber(updates)

    if update_num > 5 then
        for i in pairs(settings_table) do
            setup_rings(cr, settings_table[i])
        end
    end
    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end
