local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  if game:get_value("ancient_grove_marblecliff_activated") then
    glow:set_enabled(true)
    revenant:set_enabled(false)
  end
end)

function revenant:on_dead()
  sol.audio.play_sound"secret"
  glow:set_enabled(true)
  game:set_value("ancient_grove_marblecliff_activated", true)
  local amount = game:get_value("ancient_groves_activated") or 0
  game:set_value("ancient_groves_activated", amount + 1)
end