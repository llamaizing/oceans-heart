-- Lua script of map snapmast_reef/caves/elixer_upgrade_tower.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()



function elixer_spirit:on_interaction()
  if game:get_value("spoken_with_snapmast_elixer_spirit") == true then
    game:start_dialog("_yarrowmouth.npcs.elixer_spirit.2")
  else
    game:start_dialog("_yarrowmouth.npcs.elixer_spirit.1", function() sol.audio.play_sound("elixer_upgrade") end)
    game:set_value("elixer_restoration_level", game:get_value("elixer_restoration_level")+6)
    game:set_value("spoken_with_snapmast_elixer_spirit", true)
  end
end