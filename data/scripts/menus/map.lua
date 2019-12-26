--[[
    -------------
  S | V | V | R |
  a | i | i | v |
  v | s | s | e |
  e | i | i | a |
  V | b | t | l |
  a | l | e | e |
  l | e | d | d |
----+-----------+
|nil| 0 | 0 | 0 | --map landmass not visible
| 0 | 1 | 0 | 0 | --map landmass visible, will be revealed next time map is opened
| 1 | 1 | 0 | 1 | --map landmass visible and has been revealed
| 2 | 1 | 1 | 0 | --map landmass has been visited, will be revealed next time map is opened
| 3 | 1 | 1 | 1 | --map landmass has been visited and revealed
----+-----------+
]]

local multi_events = require"scripts/multi_events"

--constants
local WORLD_MAP_ID = "maps/dev/world_map.dat" --map id that contains world map info
local REVEAL_DELAY = 1000 --delay time (in msec) before revealing new landmasses
local FADE_IN_DELAY = 100 --delay time (in msec) between fade in frames when revealing a landmass
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
  if landmass_entity then table.insert(LANDMASS_SPRITES, landmass_entity) end

  local text_entity = info[2]
  if text_entity then table.insert(TEXT_SPRITES, text_entity) end
end

map_screen = {x=0, y=0}
multi_events:enable(map_screen)

local map_id
local all_sprites = {} --(table, key/value) lookup world map sprite (value) by entity id (key)
local sprite_draw_list = {} --(table, array) list of sprites in draw order
local map_img = sol.surface.create()
local map_bg = sol.surface.create("menus/maps/overworld_blank.png")

--call one time when script is loaded to lookup sprites and positions from maps/dev/world_map.dat
local function read_world_map()
  world_map_entities = {}
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

    --generate corresponding sprite
    local sprite = sol.sprite.create(sprite_id)
    sprite:set_xy(x, y)
    sprite.layer = layer

    all_sprites[entity_id] = sprite
  end

  local chunk, err = sol.main.load_file(WORLD_MAP_ID)
  setfenv(chunk, env)
  chunk()

  --create list of sprites in draw order: layer 1 = landmasses, 2 = roads, 3 = text
  for layer=1,3 do
    for _,sprite in pairs(all_sprites) do
      if sprite.layer == layer then table.insert(sprite_draw_list, sprite) end
    end
  end
end

--TODO may want external access to these get/set functions

--returns boolean whether landmass will be visible in map menu
local function get_visible(save_var_id)
  local game = sol.main.get_game()
  return not not game:get_value(save_var_id)
end

--makes landmass that the player has not yet visited visible next time map menu is opened
local function set_visible(save_var_id)
  local game = sol.main.get_game()
  if not game:get_value(save_var_id) then game:set_value(save_var_id, 0) end
end

--returns boolean whether player has set foot on the landmass
local function get_visited(save_var_id)
  local game = sol.main.get_game()
  local val = game:get_value(save_var_id) or 0
  return val >= 2
end

--marks landmass as visited by player, will be visible next time map menu is opened (if not already)
local function set_visited(save_var_id)
  local game = sol.main.get_game()
  local val = game:get_value(save_var_id) or 0
  if val < 2 then game:set_value(save_var_id, val+2) end
end

--returns boolean whether reveal animation has played for given landmass
local function get_revealed(save_var_id)
  local game = sol.main.get_game()
  local val = game:get_value(save_var_id) or 0
  return val % 2 == 1
end

--marks landmass as revealed when viewed in map menu for the first time
local function set_revealed(save_var_id)
  local game = sol.main.get_game()
  local val = game:get_value(save_var_id)
  if val and val % 2 == 0 then game:set_value(save_var_id, val+1) end
end

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
    set_visited(landmass_save_var)
  end
  
  if text_save_var then
    text_save_var = "world_map_text_"..text_save_var
    set_visited(text_save_var)
  end
end)

--// Gets/sets the x,y position of the menu in pixels
function map_screen:get_xy() return self.x, self.y end
function map_screen:set_xy(x, y)
  x = tonumber(x)
  assert(x, "Bad argument #2 to 'set_xy' (number expected)")
  y = tonumber(y)
  assert(y, "Bad argument #3 to 'set_xy' (number expected)")

  self.x = math.floor(x)
  self.y = math.floor(y)
end

--set visibility of individual landmass sprites each time the menu is opened
function map_screen:on_started()
  local game = sol.main.get_game()
  assert(game, "Error: cannot start map menu because no game is currently running")

  local map = game:get_map()
  assert(map, "Error: cannot start map menu because no map is currently active")
  map_id = map:get_id()

  local to_reveal = {} --(table, array) list of sprites to be revealed

  for _,var_name in ipairs(LANDMASS_SPRITES) do
    local landmass_val = game:get_value("world_map_landmass_"..var_name)
    local is_landmass_visible = not not landmass_val

    local landmass_sprite = all_sprites["landmass_"..var_name]
    local roads_sprite = all_sprites["roads_"..var_name]

    if landmass_sprite then
      landmass_sprite.enabled = is_landmass_visible
      if (landmass_val or 0) % 2 == 0 then --check if not revealed
        landmass_sprite:set_opacity(0) --hide until fade-in starts
        table.insert(to_reveal, landmass_sprite)
        --sol.timer.start(self, REVEAL_DELAY, function() landmass_sprite:fade_in(80) end)
        if roads_sprite then
          roads_sprite:set_opacity(0) --hide until fade-in starts
          table.insert(to_reveal, roads_sprite)
        end
        set_revealed("world_map_landmass_"..var_name) --so won't be revealed again next time map is opened
      end
    end

    if roads_sprite then roads_sprite.enabled = is_landmass_visible end --note: roads are always visible if corresponding landmass is visible
  end

  for _,var_name in ipairs(TEXT_SPRITES) do
    local text_val = game:get_value("world_map_text_"..var_name)
    local is_text_visible = not not text_val

    local text_sprite = all_sprites["text_"..var_name]
    if text_sprite then
      text_sprite.enabled = is_text_visible
      if (text_val or 0) % 2 == 0 then --check if not revealed
        text_sprite:set_opacity(0) --hide until fade-in starts
        table.insert(to_reveal, text_sprite)
        set_revealed("world_map_text_"..var_name) --so won't be revealed again next time map is opened
      end
    end
  end

  --begin reveal animation
  if #to_reveal>0 then
    sol.timer.start(self, REVEAL_DELAY, function()
      --TODO play reveal map sound
      for _,sprite in ipairs(to_reveal) do
        sprite:fade_in(FADE_IN_DELAY)
      end
    end)
  end
end

function map_screen:on_draw(dst_surface)
  map_bg:draw(dst_surface, self.x, self.y)
  for _,sprite in ipairs(sprite_draw_list) do
    if sprite.enabled then sprite:draw(dst_surface, self.x, self.y) end
  end
end

world_map_entities = read_world_map() --perform one time only when this script is loaded

return map_screen
