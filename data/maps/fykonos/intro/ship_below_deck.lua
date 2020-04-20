local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  game:get_dialog_box():set_style("empty")
  game:start_dialog("_fykonos.observations.tutorial.sword")
  game:get_dialog_box():set_style("box")
  sol.timer.start(map, 0, function()
    sol.audio.play_sound"ship_creak_lowpass"
    return 60000
  end)

  if game:get_value"fykonos_ship_attacked" then
    cabin_door:remove()
    max:remove()
  end

  sol.timer.start(map, 5000, function()
    sol.audio.play_sound"thunk1"
    sol.audio.play_sound"switch_2"
    sol.audio.play_sound"hand_cannon"
    sol.timer.start(map, 500, function()
      sol.audio.play_sound"stairs_down_end"
      sol.timer.start(map, 500, function()
        map:theres_been_an_attack()
      end)
    end)
  end)

end)


function map:theres_been_an_attack()
  max:set_enabled(true)
  map:open_doors"cabin_door"
  sol.timer.start(map, 400, function()
    game:start_dialog("_fykonos.npcs.max.been_attack", function()
      max:set_enabled(false)
      sol.audio.play_sound"stairs_up_end"
      game:set_value"fykonos_ship_attacked"
    end)
  end)
end
