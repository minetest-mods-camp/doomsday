-- LUALOCALS < ---------------------------------------------------------
local math, tonumber
    = math, tonumber
local math_floor
    = math.floor
-- LUALOCALS > ---------------------------------------------------------

local stamp = tonumber("$Format:%at$")
if not stamp then return end
stamp = math_floor((stamp - 1540612800) / 60)
stamp = ("00000000" .. stamp):sub(-8)

-- luacheck: push
-- luacheck: globals config readtext readbinary

readtext = readtext or function() end
readbinary = readbinary or function() end

return {
	pkg = "doomsday",
	dev_state = "MAINTENANCE_ONLY",
	version = stamp .. "-$Format:%h$",
	short_description = "The pinnacle of explosives mods",
	long_description = readtext('README.md'),
	screenshots = {
		readbinary('.cdb-screen-nodecore.jpg'),
		readbinary('.cdb-screen-mtg.jpg')
	}
}

-- luacheck: pop
