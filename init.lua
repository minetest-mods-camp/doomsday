-- LUALOCALS < ---------------------------------------------------------
local math, minetest, os, pairs, setmetatable, string
    = math, minetest, os, pairs, setmetatable, string
local math_abs, os_date, string_format
    = math.abs, os.date, string.format
-- LUALOCALS > ---------------------------------------------------------

local modstore = minetest.get_mod_storage()

local data
do
	local raw = modstore:get_string("data")
	raw = raw and minetest.deserialize(raw) or {}
	data = {}
	setmetatable(data, {
			__index = raw,
			__newindex = function(_, k, v)
				raw[k] = v
				modstore:set_string("data", minetest.serialize(raw))
			end
		})
end

local function deadworld()
	if not data.date then return end
	return string_format("\n\nThis world has been destroyed.\n\n"
		.. "Player %q completed construction of a doomsday device"
		.. " at %s on %s, and rendered this world"
		.. " permanently uninhabitable.",
		data.pname or "UNKNOWN",
		data.pos and minetest.pos_to_string(data.pos) or "UNKNOWN",
		data.date)
end

minetest.register_on_prejoinplayer(deadworld)

local shells = {
	{["default:torch"] = true},
	{["default:mese"] = true},
	{
		["default:diamondblock"] = true,
		["nc_lode:block_tempered"] = true,
		["nc_lode:block_annealed"] = true
	}
}
for i = 1, 8 do
	shells[1]["nc_torch:torch_lit_" .. i] = true
	shells[2]["nc_lux:cobble" .. i] = true
end
local anyshell = {}
for _, s in pairs(shells) do for k in pairs(s) do anyshell[k] = true end end

local function recipecheck(pos)
	for dx = -2, 2 do
		for dy = -2, 2 do
			for dz = -2, 2 do
				local t = math_abs(dx) + math_abs(dy) + math_abs(dz)
				local shell = shells[t + 1]
				if shell then
					local nn = minetest.get_node({
							x = pos.x + dx,
							y = pos.y + dy,
							z = pos.z + dz
						}).name
					if nn == "ignore" then return end
					if not shell[nn] then return false end
				end
			end
		end
	end
	return true
end

minetest.register_on_placenode(function(pos, newnode, placer)
		if data.pos then return end
		if not anyshell[newnode.name] then return end
		for dx = -2, 2 do
			for dy = -2, 2 do
				for dz = -2, 2 do
					if recipecheck({
							x = pos.x + dx,
							y = pos.y + dy,
							z = pos.z + dz
						}) then
						data.pname = placer and placer.get_player_name and placer:get_player_name()
						data.pos = pos
						data.date = os_date()
						local msg = deadworld()
						for _, p in pairs(minetest.get_connected_players()) do
							minetest.kick_player(p:get_player_name(), msg)
						end
					end
				end
			end
		end
	end)
