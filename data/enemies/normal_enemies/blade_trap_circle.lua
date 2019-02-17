local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local startx, starty, startl

function enemy:on_created()

  sprite = enemy:create_sprite("enemies/normal_enemies/blade_trap")
  enemy:set_life(1)
  enemy:set_obstacle_behavior("flying")
  startx, starty, startl = enemy:get_position()
  if enemy:get_property("damage") then
    enemy:set_damage(enemy:get_property("damage"))
  else
    enemy:set_damage(2)
    if enemy:get_property("damage") then enemy:set_damage(enemy:get_property("damage")) end
  end
  enemy:set_invincible(true)
end


function enemy:on_restarted()
  local m = sol.movement.create("circle")
  m:set_max_rotations(0) --infinite rotations

  --Center
  m:set_center(startx, starty)

  --Radius
  if not enemy:get_property("radius") then
    m:set_radius(64)
  else
    m:set_radius(enemy:get_property("radius"))
  end
  --Speed
  if not enemy:get_property("speed") then
    m:set_angular_speed(5)
  else
    m:set_angular_speed(enemy:get_property("speed"))
  end
  --Clockwise
  if enemy:get_property("clockwise") then
    m:set_clockwise(true)
  end


  m:start(enemy)
end
