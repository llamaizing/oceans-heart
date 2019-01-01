-- Lua script of map Yarrowmouth/interiors/meadery_safehouse.
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


function letter:on_interaction()
  game:start_dialog("_yarrowmouth.observations.safehouse_letter", function()
    if game:get_value("rohit_dialog_counter") >= 2 and game:get_value("rohit_dialog_counter") < 4 then
      game:set_value("rohit_dialog_counter", 4)
      game:set_value("suspect_michael", true)
      game:set_value("quest_briarwood_mushrooms", 2)
    end
  end)
  if game:get_value("puzzlewood_footprints_visible") == true then game:set_value("puzzlewood_footprints_visible", false) end
end