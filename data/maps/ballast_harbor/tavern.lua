-- Lua script of map ballast_harbor/tavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  self:get_camera():letterbox()
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.

function lost_pirate:on_interaction()
  if game:has_item("key_juneberry_inn") ~= true then
    game:start_dialog("_ballast_harbor.npcs.tavern.lost_pirate_1", function()
      map:create_pickable({
        x = 448, y = 192, layer = 0, 
        treasure_name = "key_juneberry_inn", treasure_savegame_variable = "found_tipsy_pirate_inn_key",
      })
      game:set_value("quest_ballast_harbor_lost_inn_key", 0)
    end)


  else
    game:start_dialog("_ballast_harbor.npcs.tavern.lost_pirate_2")
  end
end