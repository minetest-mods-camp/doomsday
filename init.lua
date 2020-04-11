-- LUALOCALS < ---------------------------------------------------------
local math, minetest, os, pairs, setmetatable, string, tonumber
    = math, minetest, os, pairs, setmetatable, string, tonumber
local math_abs, math_ceil, os_date, string_format
    = math.abs, math.ceil, os.date, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()
local modstore = minetest.get_mod_storage()

local countdown = tonumber(minetest.settings:get(modname .. "_countdown")) or 10

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
		.. " at %s on %s, and doomed us all.",
		data.pname or "UNKNOWN",
		data.pos and minetest.pos_to_string(data.pos) or "UNKNOWN",
		data.date)
end

minetest.register_on_prejoinplayer(deadworld)

local odds = {["default:mese"] = true}
for i = 1, 8 do odds["nc_lux:cobble" .. i] = true end
local evens = {
	["default:diamond_block"] = true,
	["nc_lode:block_tempered"] = true,
	["nc_lode:block_annealed"] = true
}

local function recipecheck(pos)
	for dx = -2, 2 do
		for dy = -2, 2 do
			for dz = -2, 2 do
				local t = math_abs(dx) + math_abs(dy) + math_abs(dz)
				if t < 3 then
					local nn = minetest.get_node({
							x = pos.x + dx,
							y = pos.y + dy,
							z = pos.z + dz
						}).name
					if nn == "ignore" then return end
					if not (t == 2 and evens or odds)[nn] then return false end
				end
			end
		end
	end
	return true
end

minetest.register_on_placenode(function(pos, newnode, placer)
		if data.pos then return end
		if not (odds[newnode.name] or evens[newnode.name]) then return end
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
						data.deadline = minetest.get_gametime() + countdown
					end
				end
			end
		end
	end)

local hud_whiteout = {}
local hud_waypoint = {}

minetest.register_on_leaveplayer(function(player)
		local pname = player:get_player_name()
		hud_whiteout[pname] = nil
		hud_waypoint[pname] = nil
	end)

local function destroyworld(pos)
	data.date = os_date()
	data.pos = pos
	local msg = deadworld()
	for _, p in pairs(minetest.get_connected_players()) do
		minetest.kick_player(p:get_player_name(), msg)
	end
end

local function interval()
	minetest.after(1, interval)

	if not data.deadline then return end
	local timeleft = data.deadline - minetest.get_gametime()

	local alpha = math_ceil(timeleft / countdown * 255)
	if alpha > 255 then alpha = 255 end
	local txr = "[combine:1x1^[noalpha^[colorize:#ffffff:255^[opacity:" .. alpha

	for _, p in pairs(minetest.get_connected_players()) do
		local pname = p:get_player_name()
	end
end
minetest.after(0, interval)
