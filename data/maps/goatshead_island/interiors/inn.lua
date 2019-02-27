-- Lua script of map goatshead_island/interiors/inn.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  go_to_bed:set_enabled(false)

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


function jude:on_interaction()
  game:start_dialog("_goatshead.npcs.inn.1", function(answer)
    if answer == 2 then
      if game:get_money() <30 then game:start_dialog("_game.insufficient_funds") else
        game:remove_money(30)
        game:set_life(game:get_max_life())
        go_to_bed:set_enabled(true)
      end
    end
  end)
end

function found_your_way_inn_sensor:on_activated()
  if game:get_value("quest_ballast_harbor_lost_inn_key") == 0 then
    game:set_value("quest_ballast_harbor_lost_inn_key", 1)
  end
end