--[[ world_map.lua
	version 1.0.0
	26 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages the world map, utilizing features common to the map pause menu and
	fast travel menus. It maintains a list of savegame variable names associated with each
	individual map/landmass. It generates a complete set of individual landmass sprites by
	parsing the map file at maps/dev/world_map.dat and reading the position of each custom
	entity used. It also facilitates external manipulation of which landmasses are visible
	to the player through the game.world_map table.
	
	Each map landmass has an associated savegame variable to track its visibility and will
	be revealed when the player visits any map associated with a given landmass. There are
	separate savegame variables to track visibility of map text annotations.
	
	    ------------- Possible savegame variable values:
	  S |   |   | R | * Visible means the landmass will appear in the map menu (not
	  a | V | V | e |   necessarily revealed yet)
	  v | i | i | v | * Visited means the player has entered at least one map on the
	  e | s | s | e |   landmass
	    | i | i | a | * Revealed is the fade-in animation that occurs the first time a new
	  V | b | t | l |   landmass is viewed in the map menu
	  a | l | e | e |
	  l | e | d | d |
	----+-----------+
	|nil| 0 | 0 | 0 | --> map landmass not visible
	| 0 | 1 | 0 | 0 | --> map landmass visible, will be revealed next time map is opened
	| 1 | 1 | 0 | 1 | --> map landmass visible and has been revealed
	| 2 | 1 | 1 | 0 | --> map landmass has been visited, will be revealed next time map is opened
	| 3 | 1 | 1 | 1 | --> map landmass has been visited and revealed
	----+-----------+

	Usage:
	local world_map = require"scripts/world_map"
	world_map:get_visible(id); world_map:set_visible(id, boolean)
	world_map:get_visited(id); world_map:set_visited(id, boolean)
	world_map:get_revealed(id); world_map:set_revealed(id, boolean)
]]

--constants
local WORLD_MAP_ID = "maps/dev/world_map.dat" --map id that contains world map info
local MAP_LIST = {
	--key (string) map_id, value (table, array)
		--index 1 (string) entity names for world_map landmasses; prefix with 'world_map_landmass_' for savegame variable name
		--index 2 (string, optional) entity names name for world_map text; prefix with 'world_map_text_' for savegame variable name
	['new_limestone/new_limestone_island'] = {'limestone_island', 'limestone'},
	['new_limestone/new_limestone_island'] = {'limestone_island', 'limestone'},
	['new_limestone/limestone_present'] = {'limestone_island', 'limestone'},
	['new_limestone/bracken_beach'] = {'limestone_island'},
	['ballast_harbor/ballast_trail'] = {'ballast_island'},
	['ballast_harbor/ballast_harbor'] = {'ballast_island', 'ballast_harbor'},
	['goatshead_island/crabhook_village'] = {'crabhook', 'crabhook'},
	['goatshead_island/goat_hill'] = {'goatshead_island'},
	['goatshead_island/riverbank'] = {'goatshead_island'},
	['goatshead_island/goatshead_harbor'] = {'goatshead_island', 'goatshead'},
	['stonefell_crossroads/sycamore_ferry'] = {'goatshead_island'},
	['stonefell_crossroads/fort_crow'] = {'crow_island', 'fort_crow'},
	['stonefell_crossroads/crow_road'] = {'crow_island'},
	['stonefell_crossroads/crow_arena'] = {'crow_arena'},
	['stonefell_crossroads/lotus_shoal'] = {'lotus_shoal', 'lotus_shoal'},
	['stonefell_crossroads/spruce_head'] = {'spruce_head', 'spruce_head'},
	['stonefell_crossroads/forest_of_tides'] = {'zephyr_bay'},
	['stonefell_crossroads/zephyr_bay'] = {'zephyr_bay'},
	['stonefell_crossroads/stonefell_crossroads'] = {'stonefell_crossroads'},
	['oakhaven/sunken_palace'] = {'sunken_palace'},
	['oakhaven/sunken_lighthouse'] = {'sunken_palace'},
	['oakhaven/gull_rock'] = {'gull_rock'},
	['oakhaven/west_oak'] = {'oakhaven'},
	['oakhaven/marblecliff'] = {'oakhaven'},
	['oakhaven/marble_summit'] = {'oakhaven', 'marblecliff'},
	['oakhaven/ivystump'] = {'oakhaven', 'ivystump'},
	['oakhaven/ivystump_port'] = {'oakhaven'},
	['oakhaven/port'] = {'oakhaven', 'oakport'},
	['oakhaven/oakhaven'] = {'oakhaven', 'oakhaven'},
	['oakhaven/eastoak'] = {'oakhaven'},
	['oakhaven/veilwood'] = {'oakhaven'},
	['oakhaven/lobb_trail'] = {'lobb_trail'},
	['Yarrowmouth/puzzlewood'] = {'yarrowmouth_island'},
	['Yarrowmouth/yarrowmouth_village'] = {'yarrowmouth_island', 'yarrowmouth'},
	['Yarrowmouth/juniper_grove'] = {'yarrowmouth_island'},
	['Yarrowmouth/tern_marsh'] = {'tern_marsh'},
	['Yarrowmouth/kingsdown'] = {'kingsdown_isle', 'kingsdown_isle'},
	['snapmast_reef/snapmast_landing'] = {'snapmast_landing', 'snapmast_reef'},
	['snapmast_reef/drowned_village'] = {'snapmast_reef'},
	['snapmast_reef/smoldering_rock'] = {'snapmast_reef'},
	['snapmast_reef/snapmast_lighthouse'] = {'snapmast_reef'},
	['isle_of_storms/isle_of_storms_landing'] = {'isle_of_storms', 'isle_of_storms'},
}

--construct from MAP_LIST data
local LANDMASS_SPRITES = {} --(table, array) add prefix "world_map_landmass_" or "world_map_roads_" to values to get corresponding savegame variable name
local TEXT_SPRITES = {} --(table, array) add prefix "world_map_" to values to get corresponding savegame variable name
for _,info in pairs(MAP_LIST) do
	local landmass_entity = info[1]
	if landmass_entity and not LANDMASS_SPRITES[landmass_entity] then
		table.insert(LANDMASS_SPRITES, landmass_entity)
		LANDMASS_SPRITES[landmass_entity] = true --prevent adding duplicate entries
	end

	local text_entity = info[2]
	if text_entity and not TEXT_SPRITES[text_entity] then
		table.insert(TEXT_SPRITES, text_entity)
		TEXT_SPRITES[text_entity] = true --prevent adding duplicate entries
	end
end

local world_map = {}
local sprite_info --(table, combo) info for all sprites in draw order, also lookup using entitiy_id as key

--// Call one time when script is loaded to lookup sprites and positions from maps/dev/world_map.dat
local function read_world_map()
	sprite_info = {}
	local all_sprites = {} --(table, array) sprite info in order listed in world_map.dat
	
	local env = setmetatable({}, {__index = function() return function() end end}) --do nothing for undefined env functions

	function env.custom_entity(properties)
		local entity_id = properties.name
		if not entity_id then return end --ignore any custom entities without an id
		assert(type(entity_id)=="string", "World Map Error: bad value for custom_entity property 'name' (string expected, got "..type(entity_id)..")")

		local sprite_id = properties.sprite
		if not sprite_id then return end --ignore any custom entities without a sprite
		assert(type(sprite_id)=="string", "World Map Error: bad value for custom_entity property 'sprite' (string expected, got "..type(sprite_id)..")")
		assert(sol.main.resource_exists("sprite", sprite_id), "World Map Error: sprite not found: "..sprite_id)

		local x = tonumber(properties.x)
		assert(x, "World Map Error: bad value for custom_entity property 'x' (number expected)")
		local y = tonumber(properties.y)
		assert(y, "World Map Error: bad value for custom_entity property 'y' (number expected)")
		local layer = tonumber(properties.layer)
		assert(layer, "World Map Error: bad value for custom_entity property 'layer' (number expected)")
		
		local info = {sprite_id=sprite_id, x=x, y=y, layer=layer, entity_id=entity_id}
		table.insert(all_sprites, info)
		sprite_info[entity_id] = info --lookup using entity_id
		
		--[[
		--generate corresponding sprite
		local sprite = sol.sprite.create(sprite_id)
		sprite:set_xy(x, y)
		sprite.layer = layer

		all_sprites[entity_id] = sprite
		]]
	end

	local chunk, err = sol.main.load_file(WORLD_MAP_ID)
	setfenv(chunk, env)
	chunk()

	--reorder sprite info in draw order: layer 1 = landmasses, 2 = roads, 3 = text
	for layer=1,3 do
		for _,info in ipairs(all_sprites) do
			if info.layer == layer then table.insert(sprite_info, info) end
		end
	end
end

function world_map:create_sprites()
	--update visibility status
	for _,var_name in ipairs(LANDMASS_SPRITES) do
		local landmass_val = game:get_value("world_map_landmass_"..var_name)
		local is_landmass_visible = not not landmass_val
	end
	
	for _,info in ipairs(sprite_info) do
		
	end
end

--// Returns boolean whether landmass will be visible in map menu
function world_map:get_visible(save_var_id)
	local game = sol.main.get_game()
	return not not game:get_value(save_var_id)
end

--// Makes landmass that the player has not yet visited visible next time map menu is opened
	--boolean (boolean, optional) - true makes landmass visible, false makes landmass not visible, default: true
function world_map:set_visible(save_var_id, boolean)
	local game = sol.main.get_game()
	if boolean or boolean==nil then
		if not game:get_value(save_var_id) then game:set_value(save_var_id, 0) end
	else game:set_value(save_var_id, false) end
end

--// Returns boolean whether player has set foot on the landmass
function world_map:get_visited(save_var_id)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	return val >= 2
end

--// Marks landmass as visited by player, will be visible next time map menu is opened (if not already)
	--boolean (boolean, optional) - true marks landmass as visited, false marks not visited, default: true
function world_map:set_visited(save_var_id, boolean)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	if boolean or boolean==nil then
		if val < 2 then game:set_value(save_var_id, val+2) end
	elseif val >= 2 then game:set_value(save_var_id, val-2) end
end

--// Returns boolean whether reveal animation has played for given landmass
function world_map:get_revealed(save_var_id)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	return val % 2 == 1
end

--// Marks landmass as revealed when viewed in map menu for the first time
	--boolean (boolean, optional) - true marks landmass as revealed, false marks not revealed, default: true
function world_map:set_revealed(save_var_id, boolean)
	local game = sol.main.get_game()
	local val = game:get_value(save_var_id) or 0
	if val % 2 == 0 then
		if boolean or boolean==nil then game:set_value(save_var_id, val+1) end
	elseif not boolean then game:set_value(save_var_id, val-1) end
end

--// Reveal or hide full map
function world_map:show_all(boolean)
	--TODO
end

function world_map:get_sprites(do_reveal)
	local game = sol.main.get_game()
	assert(game, "Error: cannot start map menu because no game is currently running")
	
	--keep track of landmass at player's current location
	local map = game:get_map()
	local map_id = map and map:get_id()
	local current_landmass = MAP_LIST[map_id] and MAP_LIST[map_id][1]
	local current_id --entity_id of player's current location, may be false/nil
	
	
	--## update visibility status for all landmasses & map text
	
	for _,var_name in ipairs(LANDMASS_SPRITES) do
		local landmass_val = game:get_value("world_map_landmass_"..var_name)
		local is_landmass_visible = not not landmass_val
		local is_landmass_visited = (landmass_val or 0) >= 2
		local is_landmass_revealed = (landmass_val or 0) % 2 == 1
		
		local landmass_info = sprite_info["landmass_"..var_name]
		if landmass_info then
			landmass_info.visible = is_landmass_visible
			landmass_info.visited = is_landmass_visited
			landmass_info.revealed = is_landmass_revealed
			
			if current_landmass==var_name then current_id = landmass_info.entity_id end
			
			--so won't be revealed again next time map is opened
			if is_landmass_visible and not is_landmass_revealed and do_reveal then
				self:set_revealed("world_map_landmass_"..var_name)
			end
		end
		
		local roads_info = sprite_info["roads_"..var_name] 
		if roads_info then
			roads_info.visible = is_landmass_visible
			roads_info.visited = is_landmass_visited
			roads_info.revealed = is_landmass_revealed
			--note: roads are always visible if corresponding landmass is visible
		end
	end
	
	for _,var_name in ipairs(TEXT_SPRITES) do
		local text_val = game:get_value("world_map_text_"..var_name)
		local is_text_visible = not not text_val
		local is_text_visited = (text_val or 0) >= 2
		local is_text_revealed = (text_val or 0) % 2 == 1
		
		local text_info = sprite_info["text_"..var_name]
		if text_info then
			text_info.visible = is_text_visible
			text_info.visited = is_text_visited
			text_info.revealed = is_text_revealed
			
			--so won't be revealed again next time map is opened
			if is_text_visible and not is_text_revealed and do_reveal then
				self:set_revealed("world_map_text_"..var_name)
			end
		end
	end
	
	
	--## create sprites for visible landmasses & map text
	
	local sprite_list = {} --(table, array) list of visible sprites in draw order
	local to_reveal = {} --(table, array) list of sprites to be revealed
	local unvisited = {} --(table, array) list of unvisited sprites
	
	for _,info in ipairs(sprite_info or {}) do
		if info.visible then
			local sprite = sol.sprite.create(info.sprite_id)
			sprite:set_xy(info.x, info.y)
			sprite.revealed = info.revealed
			sprite.visited = info.visited
			sprite.entity_id = info.entity_id
			
			if info.entity_id == current_id then sprite_list.current = sprite end
			
			table.insert(sprite_list, sprite)
			if not info.revealed then table.insert(to_reveal, sprite) end
			if not info.visited then table.insert(unvisited, sprite) end
		end
	end
	
	return sprite_list, to_reveal, unvisited
end

--// Update savegame values whenever the player enters an overworld map
local map_meta = sol.main.get_metatable"map"
map_meta:register_event("on_started", function(self)
	local map = self
	local game = map:get_game()
	local map_id = map:get_id()

	local map_info = MAP_LIST[map_id] or {}
	local landmass_save_var = map_info[1]
	local text_save_var = map_info[2]
	
	if landmass_save_var then
		landmass_save_var = "world_map_landmass_"..landmass_save_var
		world_map:set_visited(landmass_save_var)
	end
	
	if text_save_var then
		text_save_var = "world_map_text_"..text_save_var
		world_map:set_visited(text_save_var)
	end
end)

read_world_map() --perform one time only when this script is loaded

return world_map

--[[ Copyright 2019 Llamazing
	[] 
	[] This program is free software: you can redistribute it and/or modify it under the
	[] terms of the GNU General Public License as published by the Free Software Foundation,
	[] either version 3 of the License, or (at your option) any later version.
	[] 
	[] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	[] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
	[] PURPOSE.	See the GNU General Public License for more details.
	[] 
	[] You should have received a copy of the GNU General Public License along with this
	[] program.	If not, see <http://www.gnu.org/licenses/>.
	]]
