local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
map:register_event("on_started", function()
  if game:get_value("yarrow_village_pirate_guard_left") == true then pirate_guard:set_enabled(false) end

  if game:get_value("nina_dialog_counter") ~= 2 then nina:set_enabled(false) end

end)

function pirate_guard:on_interaction()
  if game:get_value("going_to_meet_carlov_pirates") == true then
    game:start_dialog("_yarrowmouth.npcs.guard_pirate.2")
    local m = sol.movement.create("path")
    m:set_path{2,2,2}
    m:set_speed(40)
    m:set_speed(20)
    m:set_ignore_obstacles(true)
    m:start(pirate_guard, function()
--      sol.timer.start(map, 1000, function() pirate_guard:set_enabled(false) end)
      pirate_guard:set_enabled(false)
      game:set_value("yarrow_village_pirate_guard_left", true)
    end)

  else --if you haven't already talked to Nina
    game:start_dialog("_yarrowmouth.npcs.guard_pirate.1")
  end
end


function nina:on_interaction()
  if game:get_value("nina_dialog_counter") == 2 then
    game:start_dialog("_yarrowmouth.npcs.nina.marsh1", function()
      game:set_value("nina_dialog_counter", 3)
      game:set_value("quest_yarrow_parley", 3) --quest log
    end)

  elseif game:get_value("nina_dialog_counter") == 3 then
    game:start_dialog("_yarrowmouth.npcs.nina.6")
  end

end
