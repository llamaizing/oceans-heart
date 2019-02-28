local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local direction

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/normal_enemies/blade_trap")
  enemy:set_life(1)
  enemy:set_damage(2)
  if enemy:get_property("damage") then enemy:set_damage(enemy:get_property("damage")) end
  enemy:set_invincible(true)
  direction = 0
  if enemy:get_property("direction") and enemy:get_property("direction") == "vertical" then direction = math.pi/2 end
end

local function go()
  local m = sol.movement.create("straight")
  m:set_max_distance(0) --infinite max distance
  m:set_angle(direction)
  m:set_smooth(false)
  --Speed
  if not enemy:get_property("speed") then
    m:set_speed(130)
  else
    m:set_speed(enemy:get_property("speed"))
  end
  m:start(enemy)

  function m:on_obstacle_reached()
--    sol.audio.play_sound("sword_tapping")
    direction = direction + math.pi
    go()    
  end
end

function enemy:on_restarted()
  go()
end