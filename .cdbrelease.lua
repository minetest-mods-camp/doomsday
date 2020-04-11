-- LUALOCALS < ---------------------------------------------------------
local dofile, math, tonumber
    = dofile, math, tonumber
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
	user = "Warr1024",
	pkg = "doomsday",
	min = "5.0",
	version = stamp .. "-$Format:%h$",
	path = ".",
	type = "mod",
	title = "Doomsday Device",
	short_desc = "The pinnacle of explosives mods",
	tags = "combat, tools, machines",
	license = "mit",
	desc = readtext('README.md'),
	repo = "https://gitlab.com/sztest/doomsday",
	screenshots = {
		readbinary('.cdb-screen-mtg.jpg'),
		readbinary('.cdb-screen-nodecore.jpg')
	}
}

-- luacheck: pop
