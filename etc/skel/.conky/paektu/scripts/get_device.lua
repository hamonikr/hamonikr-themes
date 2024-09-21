-- ~/.conky/paektu/scripts/get_device.lua
function conky_get_device()
    local handle = io.popen("~/.conky/paektu/scripts/ssid -i")
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "")  -- Remove any whitespace
end