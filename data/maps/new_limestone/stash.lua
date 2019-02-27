-- Lua script of map new_limestone/stash.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

function map:on_started()
  if game:get_value("quest_whisky_for_juglan")<1 then
    whisky:set_enabled(false)
  end
end

function whisky:on_interaction()
    game:set_value("quest_whisky_for_juglan_phase", 1) --quest log
    game:start_dialog("_game.quest_log_update")
    whisky:set_enabled(false)

end