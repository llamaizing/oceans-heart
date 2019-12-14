local map = ...
local game = map:get_game()

map:register_event("on_started", function()
  sol.audio.play_music("fire_burning")
  timeskip_warp:set_enabled(false)


--tim movement
  local tim_run = sol.movement.create("path")
  tim_run:set_path{0,0,0,0,0,0,4,4,4,4,4,4}
  tim_run:set_speed(80)
  tim_run:set_loop(true)
  tim_run:set_ignore_obstacles(true)
  tim_run:start(tim)
--juglan movement
  local juglan_movement = sol.movement.create("random")
  juglan_movement:set_speed(25)
  juglan_movement:start(juglan)

end)

function explosion_sensor:on_activated()
  local x,y,l = trigger_barrel:get_position()
  map:create_explosion({
  layer = l, x = x, y = y,})
  explosion_sensor:remove()
print("ahhhhh!")
end

function mallow:on_interaction()
  game:set_value("quest_log_a", "a2")
  game:start_dialog("_new_limestone_island.npcs.mallow.3", function ()
    game:set_value("quest_whisky_for_juglan_phase", 2) --quest log
    timeskip_warp:set_enabled(true)

  end)


end
