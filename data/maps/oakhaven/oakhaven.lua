-- Lua script of map oakhaven/oakhaven.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


--intro cutscene
function remember_sensor:on_activated()
  if game:get_value("hazel_is_here") ~= true then
    game:start_dialog("_generic_dialogs.hey")
    hero:freeze()
    hero:walk("2222210")
    sol.timer.start(map, 800, function()
      hero:unfreeze()
      game:start_dialog("_oakhaven.npcs.port.cervio.1", function()
        game:set_value("quest_hazel", 1) --quest log
        game:set_value("quest_log_a", "a9")
        game:set_value("hazel_is_here", true)
      end)
    end)
  end
end