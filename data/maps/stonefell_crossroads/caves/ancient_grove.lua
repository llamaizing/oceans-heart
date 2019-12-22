local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("ancient_groves_activated") and game:get_value("ancient_groves_activated") >= 3 then
    glow:set_enabled(true)
    revenant:set_enabled(true)
  end
end)

function revenant:on_dead()
  sol.audio.play_sound"secret"
  map:focus_on(map:get_camera(), rune_door, function()
    map:open_doors"rune_door"
  end)
end
