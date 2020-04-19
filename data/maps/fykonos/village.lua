local map = ...
local game = map:get_game()

map:register_event("on_started", function()


  --Bell
  bell:set_layer_independent_collisions(true)
  bell:add_collision_test("sprite", function(bell, entity, bellsprite, entitysprite)
    if not bell.ringing
    and entitysprite:get_animation_set() == "hero/sword1" or entitysprite:get_animation_set() == "hero/spear" then
      sol.audio.play_sound"bell_town"
      bell:get_sprite():set_animation"ringing"
      bell.ringing = true
      sol.timer.start(map, 5800, function()
        bell.ringing = false
        bell:get_sprite():set_animation"stopped"
      end)
    end
  end)

end)



function greeter:on_interaction()
  if not game:get_value"fykonos_talked_with_greeter" then
    game:start_dialog"_fykonos.npcs.village.greeter.1"
  else
    game:start_dialog"_fykonos.npcs.village.greeter.2"
  end
end



function ferry_counter:on_interaction()
  if not game:get_value"fykonos_ferry_open" then
    --ferry closed
    game:start_dialog"_fykonos.npcs.village.ferry.closed"
  else
    --ferry open

  end
end




