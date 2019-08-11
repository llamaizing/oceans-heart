-- Lua script of map goatshead_island/interiors/inn.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()


function map:on_started()
  self:get_camera():letterbox()
end


function jude:on_interaction()
  game:start_dialog("_goatshead.npcs.inn.1", function()
      require("scripts/shops/inn"):start()
  end)
end

function found_your_way_inn_sensor:on_activated()
  if game:get_value("quest_ballast_harbor_lost_inn_key") == 0 then
    game:set_value("quest_ballast_harbor_lost_inn_key", 1)
  end
end