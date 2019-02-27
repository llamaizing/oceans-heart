-- Lua script of map oakhaven/marble_summit.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  if game:get_value("quest_manna_oaks") == 0 then manna_oak_twig:set_enabled(true) end
  if game:get_value("quest_manna_oaks") >= 7 then manna_tree_door:set_enabled(false) end
  if game:get_value("quest_manna_oaks") >= 9 then manna_oak_leaves:set_enabled(true) end
end)

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end
