-- Lua script of map goatshead_island/poplar_coast.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("talked_to_ilex_1") == true then gate:set_enabled(false) end
  bait_monster:set_enabled(false)

end)



function bait_vase:on_lifting()
--  hero:freeze()
  sol.timer.start(1200, function()
    hero:unfreeze()
    if map:has_entity("bait_monster") == true then bait_monster:set_enabled(true) end
    sol.audio.play_sound("monster_roar_1")
  end)
end

function bait_monster:on_dead()
  if game:get_value("danley_convo_counter") == nil then
    game:set_value("danley_convo_counter", "special")
  else
    game:set_value("danley_convo_counter", 2)
    game:set_value("quest_crabhook_shoal_monster", 3) --quest log
    game:start_dialog("_game.quest_log_update")
  end
end