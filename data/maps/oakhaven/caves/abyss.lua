-- Lua script of map oakhaven/caves/abyss.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  if game:get_value("oakhaven_palace_rune_activated") then
    glowing_rune:set_enabled(true)
  end

end)


function coral_boss:on_dead()
  map:open_doors("coral_ore_door")
end

function rune_sensor:on_activated()

end
