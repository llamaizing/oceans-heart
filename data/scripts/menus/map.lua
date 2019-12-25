local multi_events = require"scripts/multi_events"

--constants
local WORLD_MAP_ID = "maps/dev/world_map.dat" --map id that contains world map info
local MAP_LIST = {
  --key (string) map_id, value (table, array)
    --index 1 (string) savegame variable name for landmass
    --index 2 (string, optional) savegame variable name for text
  --TODO add other variants of limestone island
  ['new_limestone/new_limestone_island'] = {'world_map_landmass_limestone_island', 'world_map_text_limestone'},
  ['new_limestone/new_limestone_island'] = {'world_map_landmass_limestone_island', 'world_map_text_limestone'},
  ['new_limestone/limestone_present'] = {'world_map_landmass_limestone_island', 'world_map_text_limestone'},
  ['new_limestone/bracken_beach'] = {'world_map_landmass_limestone_island'},
  ['ballast_harbor/ballast_trail'] = {'world_map_landmass_ballast_island'},
  ['ballast_harbor/ballast_harbor'] = {'world_map_landmass_ballast_island', 'world_map_text_ballast_harbor'},
  ['goatshead_island/crabhook_village'] = {'world_map_landmass_crabhook', 'world_map_text_crabhook'},
  ['goatshead_island/goat_hill'] = {'world_map_landmass_goatshead_island'},
  ['goatshead_island/riverbank'] = {'world_map_landmass_goatshead_island'},
  ['goatshead_island/goatshead_harbor'] = {'world_map_landmass_goatshead_island', 'world_map_text_goatshead'},
  ['stonefell_crossroads/sycamore_ferry'] = {'world_map_landmass_goatshead_island'},
  ['stonefell_crossroads/fort_crow'] = {'world_map_landmass_crow_island', 'world_map_text_fort_crow'},
  ['stonefell_crossroads/crow_road'] = {'world_map_landmass_crow_island'},
  ['stonefell_crossroads/crow_arena'] = {'world_map_landmass_crow_arena'},
  ['stonefell_crossroads/lotus_shoal'] = {'world_map_landmass_lotus_shoal', 'world_map_text_lotus_shoal'},
  ['stonefell_crossroads/spruce_head'] = {'world_map_landmass_spruce_head', 'world_map_text_spruce_head'},
  ['stonefell_crossroads/forest_of_tides'] = {'world_map_landmass_zephyr_bay'},
  ['stonefell_crossroads/zephyr_bay'] = {'world_map_landmass_zephyr_bay'},
  ['stonefell_crossroads/stonefell_crossroads'] = {'world_map_landmass_stonefell_crossroads'},
  ['oakhaven/sunken_palace'] = {'world_map_landmass_sunken_palace'},
  ['oakhaven/sunken_lighthouse'] = {'world_map_landmass_sunken_palace'},
  ['oakhaven/gull_rock'] = {'world_map_landmass_gull_rock'},
  ['oakhaven/west_oak'] = {'world_map_landmass_oakhaven'},
  ['oakhaven/marblecliff'] = {'world_map_landmass_oakhaven'},
  ['oakhaven/marble_summit'] = {'world_map_landmass_oakhaven', 'world_map_text_marblecliff'},
  ['oakhaven/ivystump'] = {'world_map_landmass_oakhaven', 'world_map_text_ivystump'},
  ['oakhaven/ivystump_port'] = {'world_map_landmass_oakhaven'},
  ['oakhaven/port'] = {'world_map_landmass_oakhaven', 'world_map_text_oakport'},
  ['oakhaven/oakhaven'] = {'world_map_landmass_oakhaven', 'world_map_text_oakhaven'},
  ['oakhaven/eastoak'] = {'world_map_landmass_oakhaven'},
  ['oakhaven/veilwood'] = {'world_map_landmass_oakhaven'},
  ['oakhaven/lobb_trail'] = {'world_map_landmass_lobb_trail'},
  ['Yarrowmouth/puzzlewood'] = {'world_map_landmass_yarrowmouth_island'},
  ['Yarrowmouth/yarrowmouth_village'] = {'world_map_landmass_yarrowmouth_island', 'world_map_text_yarrowmouth'},
  ['Yarrowmouth/juniper_grove'] = {'world_map_landmass_yarrowmouth_island'},
  ['Yarrowmouth/tern_marsh'] = {'world_map_landmass_tern_marsh'},
  ['Yarrowmouth/kingsdown'] = {'world_map_landmass_kingsdown_isle', 'world_map_text_kingsdown_isle'},
  ['snapmast_reef/snapmast_landing'] = {'world_map_landmass_snapmast_landing', 'world_map_text_snapmast_reef'},
  ['snapmast_reef/drowned_village'] = {'world_map_landmass_snapmast_reef'},
  ['snapmast_reef/smoldering_rock'] = {'world_map_landmass_snapmast_reef'},
  ['snapmast_reef/snapmast_lighthouse'] = {'world_map_landmass_snapmast_reef'},
  ['isle_of_storms/isle_of_storms_landing'] = {'world_map_landmass_isle_of_storms', 'world_map_text_isle_of_storms'},
}
local LANDMASS_SPRITES = { --append "world_map_landmass_" or "world_map_roads_" to front to get corresponding savegame variable name
  "ballast_island",
  "crabhook",
  --"crow_arena", --TODO add landmass for crow_arena
  "crow_island",
  "goatshead_island",
  "gull_rock",
  "isle_of_storms",
  "kingsdown_isle",
  "limestone_island",
  "lobb_trail",
  "lotus_shoal",
  "oakhaven",
  "snapmast_landing",
  "snapmast_reef",
  "spruce_head",
  "stonefell_crossroads",
  "sunken_palace",
  "tern_marsh",
  "yarrowmouth_island",
  "zephyr_bay",
}
local TEXT_SPRITES = { --append "world_map_" to front to get corresponding savegame variable name
  "text_ballast_harbor",
  "text_crabhook",
  "text_fort_crow",
  "text_goatshead",
  --"text_isle_of_storms", --TODO add text for isle of storms
  "text_ivystump",
  "text_kingsdown_isle",
  "text_limestone",
  "text_lotus_shoal",
  "text_marblecliff",
  "text_oakhaven",
  "text_oakport",
  "text_snapmast_reef",
  "text_spruce_head",
  "text_yarrowmouth",
}

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

    local sprite = sol.sprite.create(sprite_id)
    sprite:set_xy(x, y)
    sprite.layer = layer

    all_sprites[entity_id] = sprite
  end

  local chunk, err = sol.main.load_file(WORLD_MAP_ID)
  setfenv(chunk, env)
  chunk()

  for layer=1,3 do
    for _,sprite in pairs(all_sprites) do
      if sprite.layer == layer then table.insert(sprite_draw_list, sprite) end
    end
  end
end

local map_meta = sol.main.get_metatable"map"
map_meta:register_event("on_started", function(self)
  local map = self
  local game = map:get_game()
  local map_id = map:get_id()

  local savegame_variables = MAP_LIST[map_id] or {}
  for _,save_var in ipairs(savegame_variables) do game:set_value(save_var, 1) end
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

  for _,var_name in ipairs(LANDMASS_SPRITES) do
    local is_landmass_visible = not not game:get_value("world_map_landmass_"..var_name)

    local landmass_entity_id = "landmass_"..var_name
    local landmass_sprite = all_sprites[landmass_entity_id]
    if landmass_sprite then landmass_sprite.enabled = is_landmass_visible end

    local roads_entity_id = "roads_"..var_name
    local roads_sprite = all_sprites[roads_entity_id]
    if roads_sprite then roads_sprite.enabled = is_landmass_visible end --note: roads are always visible if corresponding landmass is visible
  end

  for _,text_entity_id in ipairs(TEXT_SPRITES) do
    local is_text_visible = not not game:get_value("world_map_"..text_entity_id)

    local text_sprite = all_sprites[text_entity_id]
    if text_sprite then text_sprite.enabled = is_text_visible end
  end
end

function map_screen:on_draw(dst_surface)
  map_bg:draw(dst_surface, self.x, self.y)
  for _,sprite in ipairs(sprite_draw_list) do
    if sprite.enabled then sprite:draw(dst_surface, self.x, self.y) end
  end
--  map_img:draw(dst_surface, self.x, self.y)  
end

world_map_entities = read_world_map() --perform one time only when this script is loaded

return map_screen
