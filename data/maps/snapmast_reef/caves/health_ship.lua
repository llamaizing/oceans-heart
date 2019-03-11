-- Lua script of map snapmast_reef/caves/health_ship.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

end)


for enemy in map:get_entities("enemy") do
  function enemy:on_dead()
    if not game:get_value("snapmast_health_ship_upgrade") and map:has_entities("enemy") == false then
      map:create_pickable{
        name="health_upgrade",
        x = 256, y = 120, layer = 0, treasure_savegame_variable = "snapmast_health_ship_upgrade"}
    end
  end
end
