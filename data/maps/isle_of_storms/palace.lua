local map = ...
local game = map:get_game()
local camera = map:get_camera()

local map_width, map_height = map:get_size()
local particles = {}
local MAX_PARTICLES = 100
local PARTICLE_SPEED = 11

local white_surface


map:register_event("on_started", function()

--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(10,25), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(map_width/-2, map_width/2), math.random(map_height/-2, map_height/2))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
--    m:set_ignore_suspend(false)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    return true
  end)

end)


map:register_event("on_opening_transition_finished", function()
--  white_surface:fade_out(100)
--  fog2:fade_in(100)
end)




---------------SWITCHES-----------------
function switch_c6:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(camera, switch_door_c6_4, function() map:open_doors("switch_door_c6") end)
end

function switch_d6:on_activated()
  sol.audio.play_sound("switch")
  map:focus_on(camera, switch_door_d6_5, function() map:open_doors("switch_door_d6") end)
end





---------------FOG--------------
white_surface = sol.surface.create()
  white_surface:fill_color({255,255,255})
  white_surface:set_opacity(0)
local camera_surface = map:get_camera():get_surface()

local fog = sol.surface.create("fog/big_water_light.png")
fog:set_blend_mode("blend")
fog:set_opacity(25)
local fog2 = sol.surface.create("fog/big_water_dark.png")
fog2:set_blend_mode("multiply")
fog2:set_opacity(25)
fog2:set_xy(-500,-200)
local fog3 = sol.surface.create("fog/water_squiggles.png")
fog3:set_blend_mode("blend")
fog3:set_opacity(30)
fog3:set_xy(-400,-240)
  function move_fog(fog, angle, distance)
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(20)
    m:set_max_distance(distance)
    m:start(fog, function() move_fog(fog, angle + math.pi, distance) end)
  end
move_fog(fog, 3, 200)
move_fog(fog2, .3, 350)
move_fog(fog3, -2.2, 250)

function map:on_draw(dst_surface)
    for i=1, #particles do
      map:draw_visual(particles[i], map_width/2, map_height/2)
    end

  white_surface:draw(dst_surface)
  fog:draw(map:get_camera():get_surface())
  fog2:draw(map:get_camera():get_surface())
  fog3:draw(map:get_camera():get_surface())
end

