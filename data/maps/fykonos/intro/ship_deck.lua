local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")

  sol.timer.start(map, 0, function()
    sol.audio.play_sound"ship_creak"
    return 60000
  end)

end)

