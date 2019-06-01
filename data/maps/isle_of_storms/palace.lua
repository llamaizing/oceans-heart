local map = ...
local game = map:get_game()
local camera = map:get_camera()

local map_width, map_height = map:get_size()
local particles = {}
local MAX_PARTICLES = 125
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

  map:set_doors_open("boss_door")

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

function f6_switch:on_activated()
  map:focus_on(map:get_camera(), f6_door, function() map:open_doors("f6_door") end)
end

for switch in map:get_entities("f5_switch") do
  function switch:on_activated()
    local all_on = true
    for s in map:get_entities("f5_switch") do
      if not s:is_activated() then all_on = false end
    end
    if all_on then map:open_doors("f5_door") end
  end
end

function d3_switch_1:on_activated()
  map:focus_on(map:get_camera(), d3_door_1, function()
    map:open_doors("d3_door_1")
  end)
end

function d3_switch_2:on_activated()
  map:focus_on(map:get_camera(), d3_door_2, function()
    map:open_doors("d3_door_2")
  end)
end

function d3_switch_3:on_activated()
  map:focus_on(map:get_camera(), d3_door_3, function()
    map:open_doors("d3_door_3")
  end)
end



--------------SENSORS---------------------------
function boss_sensor:on_activated()
  boss_sensor:set_enabled(false)
  if true then --replace with defeat seaking savegame variable later
    map:close_doors("boss_door")
    sol.audio.stop_music()
    sol.timer.start(map, 1500, function()
      sea_king_boss:set_enabled(true)
      map:create_poof(sea_king_boss:get_position())
      sol.audio.play_sound("fire_burst_3")
      sol.audio.play_sound("monster_scream")
      sol.audio.play_music("oceans_heart")
    end)
  end
end

function squid_mage_unblocker_1:on_activated()
  unlock_squid_mage_1:set_enabled(false)
end

function squid_mage_unblocker_2:on_activated()
  unlock_squid_mage_2:set_enabled(false)
end

function squid_mage_unblocker_3:on_activated()
  unlock_squid_mage_3:set_enabled(false)
end





--------------ENEMIES-------------------------
function b_15_enemy:on_dead()
  map:open_doors("b15_door")
end

function d_15_enemy:on_dead()
  map:open_doors("d15_door")
end


for enemy in map:get_entities("f12_enemy") do
function enemy:on_dead()
  if not map:has_entities("f12_enemy") then
    map:focus_on(map:get_camera(), f12_door, function()
      map:open_doors("f12_door")
    end)
  end
end
end







--------------BOSS---------------------------
sea_king_boss:register_event("on_dead", function()
  map:open_doors("boss_door")
--start falling rocks
  map:building_collapse()
end)


function map:building_collapse()
  local i = 1

  --targeted rocks
  sol.timer.start(map, 1000, function()
      local x, y, l = hero:get_position()
      map:create_falling_rock(x, y, l)
      if i < math.random(3, 6) then
        i = i + 1
        return math.random(1000, 2500)
      else
        i = 1
        return math.random(4000, 5000)
      end
  end)
  --general rocks
  sol.timer.start(map, 200, function()
    local x, y, l = hero:get_position()
    x = x + math.random(-200, 200)
    y = y + math.random(-100, 100)
    map:create_falling_rock(x, y, l)
    return math.random(200, 1000)
  end)

end

function map:create_falling_rock(x, y, l)
  map:create_enemy{
    direction = 0, layer = l, x = x + math.random(-16, 16), y = y + math.random(-16, 16),
    breed = "misc/falling_rock"
  }
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
fog2:set_xy(-500,-150)
local fog3 = sol.surface.create("fog/water_squiggles.png")
fog3:set_blend_mode("blend")
fog3:set_opacity(30)
fog3:set_xy(-400,-270)
  function move_fog(fog, angle, distance)
    local m = sol.movement.create("straight")
    m:set_angle(angle)
    m:set_speed(20)
    m:set_max_distance(distance)
    m:start(fog, function() move_fog(fog, angle + math.pi, distance) end)
  end
move_fog(fog, 3, 180)
move_fog(fog2, .3, 270)
move_fog(fog3, -2.2, 220)

function map:on_draw(dst_surface)
    for i=1, #particles do
      map:draw_visual(particles[i], map_width/2, map_height/2)
    end

  white_surface:draw(dst_surface)
  fog:draw(map:get_camera():get_surface())
  fog2:draw(map:get_camera():get_surface())
  fog3:draw(map:get_camera():get_surface())
end

