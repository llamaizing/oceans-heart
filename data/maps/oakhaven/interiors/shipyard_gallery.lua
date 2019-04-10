-- Lua script of map oakhaven/interiors/shipyard_gallery.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


function map:on_started()


end

for enemy in map:get_entities("bomb_pirate") do
  function enemy:on_dead()
    if not map:has_entities("bomb_pirate") then
      map:focus_on(map:get_camera(), door, function()
        game:set_value("quest_bomb_arrows", 3)
        map:open_doors("door")
      end)
    end
  end
end
