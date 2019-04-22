-- Lua script of map oakhaven/interiors/monastery.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  if game:get_value("marblecliff_monastery_monster_defeated") then
    map:set_doors_open("boss_door")
  end
end)



function hidden_book:on_interaction()
  game:start_dialog("_oakhaven.observations.monastery.hidden_book1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.observations.monastery.hidden_book2")
    end
  end)
end

function hidden_book_2:on_interaction()
  game:start_dialog("_oakhaven.observations.monastery.hidden_book1", function(answer)
    if answer == 2 then
      game:start_dialog("_oakhaven.observations.monastery.hidden_book3")
    end
  end)
end


function boss_sensor:on_activated()
  if not game:get_value("marblecliff_monastery_monster_defeated") then
    boss:set_enabled(true)
    sol.audio.play_sound("monster_scream")
    boss_sensor:set_enabled(false)
  end
end

function boss:on_dead()
  game:set_value("marblecliff_monastery_monster_defeated", true)
  map:open_doors("boss_door")
end
