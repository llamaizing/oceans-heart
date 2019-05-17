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

local b4_timers = {}

function b4_switch_a:on_activated()
  for platform in map:get_entities("b4_platform_a") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_a:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_b:on_activated()
  for platform in map:get_entities("b4_platform_b") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_b:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_c:on_activated()
  for platform in map:get_entities("b4_platform_c") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
    local timer = sol.timer.start(map, 5000, function()
      platform:set_enabled(false)
      b4_switch_c:set_activated(false)
      map:create_poof(x+16, y+16, l)
    end)
    timer:set_with_sound(true)
    table.insert(b4_timers, timer)
  end
end

function b4_switch_d:on_activated()
  for platform in map:get_entities("b4_platform") do
    platform:set_enabled(true)
    local x, y, l = platform:get_position()
    map:create_poof(x+16, y+16, l)
  end
  for i = 1, #b4_timers do b4_timers[i]:stop() end
end

for switch in map:get_entities("b1_switch") do
  function switch:on_activated()
    local all_switches = true
    for s in map:get_entities("b1_switch") do
      if not s:is_activated() then all_switches = false end
    end
    if all_switches then
      for bridge in map:get_entities("b1_bridge") do bridge:set_enabled(true) end
      map:create_poof(680, 256, 0)
      map:get_camera():shake()
    end
  end
end

function entry_hub_center_switch:on_activated()
  map:focus_on(map:get_camera(), entry_room_central_door, function()
    map:open_doors("entry_room_central_door")
  end)
end

function switch_e_13:on_activated()
  map:open_doors("door_e_13")
end

function switch_e_12:on_activated()
  map:open_doors("door_e_12")
end

function a6_switch:on_activated()
  map:open_doors("door_a6")
end






--------------ENEMIES-------------------------
function b_15_enemy:on_dead()
  map:open_doors("b15_door")
end

function d_15_enemy:on_dead()
  map:open_doors("d15_door")
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

