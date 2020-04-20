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

map:register_event("on_opening_transition_finished", function()
  for i=1, (2+1) do
    local spawn_point = map:get_entity("spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    map:create_enemy{x=x,y=y,layer=z,direction=0 breed="normal_enemies/ghost"}
  end
end)
