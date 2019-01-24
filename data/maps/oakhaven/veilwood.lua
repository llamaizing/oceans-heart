-- Lua script of map oakhaven/veilwood.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  if game:get_value("quest_manna_oaks") == 0 then manna_oak_twig:set_enabled(true) end
  --amalenchier_tombstone

end

function tombstone_npc:on_interaction()
  if game:get_value("quest_manna_oaks") ~= 5 then
    game:start_dialog("plaaaaaaaaceholder")
  else
    game:start_dialog("plaaaaaceholder", function()
      
    end)
  end
end