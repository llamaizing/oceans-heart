-- Lua script of map Yarrowmouth/caves/deuling_arborgeist_cave.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

for enemy in map:get_entities("arborgeist") do
  function enemy:on_dead()
    if map:has_entities"arborgeist" then
      map:open_doors"halfway_door"
    end
  end
end

map:register_event("on_started", function()
  sol.timer.start(map, 500, function()
    if not map:has_entities"arborgeist" then
      map:open_doors("wholeway_door")
    else
      return true
    end
  end)
end)
