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


--Enemy wave 1
map:register_event("on_opening_transition_finished", function()
  for i=1, (2+1) do
    local spawn_point = map:get_entity("spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    map:create_enemy{x=x,y=y,layer=z,direction=0,
      name = "wave_1_enemy",
      breed="normal_enemies/seaweed_golem_1"}
  end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_1_enemy" then
      map:wave_2()
    else
      return true
    end
  end)
end)


--Enemy wave 2
function map:wave_2()
  game:get_dialog_box():set_style("empty")
  game:start_dialog("_fykonos.observations.tutorial.equip", function()
    game:get_dialog_box():set_style("box")
    sol.audio.play_sound"monster_scream"
    for i=1, 5 do
      local spawn_point = map:get_entity("tentacle_spawn_point_" .. i)
      local x,y,z = spawn_point:get_position()
      map:create_poof(x,y+2,z)
      map:create_enemy{x=x,y=y,layer=z,direction=0,
        name = "wave_2_enemy",
        breed="misc/seamonster_tentacle"}
    end
  end)

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_2_enemy" then
      map:wave_4()
    else
      return true
    end
  end)

end


--Enemy wave 4
--There is no three. The three key is broken.
function map:wave_4()
  sol.audio.play_sound"monster_scream"
  for i=1, 5 do
    local spawn_point = map:get_entity("tentacle_spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    map:create_enemy{x=x,y=y,layer=z,direction=0,
      name = "wave_4_enemy",
      breed="misc/seamonster_tentacle"}
  end

  for i=1, 2 do
    local spawn_point = map:get_entity("spawn_point_" .. i)
    local x,y,z = spawn_point:get_position()
    map:create_poof(x,y+2,z)
    map:create_enemy{x=x,y=y,layer=z,direction=0,
      name = "wave_4_enemy",
      breed="normal_enemies/drowned_spirit"}
  end

  sol.timer.start(map, 100, function()
    if not map:has_entities"wave_4_enemy" then
      map:shipwreck()
    else
      return true
    end
  end)

end


function map:shipwreck()
    sol.audio.play_sound"thunk1"
    sol.audio.play_sound"switch_2"
    sol.audio.play_sound"hand_cannon"

    sol.timer.start(map, 299, function()
      game:start_dialog("_fykonos.observations.shipwreck.enemies_defeated", function()
        game:set_value("fykonos_ship_defended", true)
        tele:set_enabled(true)
      end)
    end)
end

