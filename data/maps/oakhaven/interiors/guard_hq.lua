-- Lua script of map oakhaven/interiors/guard_hq.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()

end

function guard_captain:on_interaction()
  if game:get_value("quest_mayors_dog") == nil then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.1_ask", function(answer)
      if answer == 2 then
        game:start_dialog("_oakhaven.npcs.guards.hq.captain.2_quest", function()
          game:set_value("quest_mayors_dog", 0)
        end)
      end
    end)

  elseif game:get_value("quest_mayors_dog") < 11 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.3")

  elseif game:get_value("quest_mayors_dog") == 11 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.4", function()
      game:add_money(200)
      game:set_value("quest_mayors_dog", 12)
    end)

  elseif game:get_value("quest_mayors_dog") == 12 then
    game:start_dialog("_oakhaven.npcs.guards.hq.captain.5")

  end
end