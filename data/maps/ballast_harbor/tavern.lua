-- Lua script of map ballast_harbor/tavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function map:on_started()
  map:get_camera():letterbox()
  local lighting_effects = require"scripts/fx/lighting_effects"
  lighting_effects:initialize()
  lighting_effects:set_darkness_level(1)
  sol.menu.start(map, lighting_effects)
end

function barkeeper:on_interaction()
  game:start_dialog("_ballast_harbor.npcs.tavern.5", function()
    require("scripts/shops/inn"):start()
  end)
end

function lost_pirate:on_interaction()
  if not map:has_entity("dropped_key") and game:has_item("key_juneberry_inn") ~= true then
    game:start_dialog("_ballast_harbor.npcs.tavern.lost_pirate_1", function()
      map:create_pickable({
        name = "dropped_key",
        x = 448, y = 192, layer = 0, 
        treasure_name = "key_juneberry_inn", treasure_savegame_variable = "found_tipsy_pirate_inn_key",
      })
      game:set_value("quest_ballast_harbor_lost_inn_key", 0)
    end)


  else
    game:start_dialog("_ballast_harbor.npcs.tavern.lost_pirate_2")
  end
end