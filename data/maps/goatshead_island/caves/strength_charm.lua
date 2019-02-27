-- Lua script of map goatshead_island/caves/strength_charm.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end


function spirit:on_interaction()
  if game:get_value("have_oak_charm_obtained") ~= true then
    game:start_dialog("_goatshead.npcs.spirits.1", function()
      map:create_pickable({
        layer=0,
        x = 160, y = 120,
        treasure_name = "oak_charm",
        treasure_savegame_variable = "oak_charm_obtained"
      })
      game:set_value("have_oak_charm_obtained", true)
    end)
    if game:get_value("quest_phantom_squid_contracts") == 2 then game:set_value("quest_phantom_squid_contracts", 3) end

  else
    game:start_dialog("_goatshead.npcs.spirits.2")
  end
end