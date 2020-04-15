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






