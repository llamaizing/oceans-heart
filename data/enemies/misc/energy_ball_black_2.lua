local enemy = ...

function enemy:on_created()
  local map = enemy:get_map()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")

  --particle effect
  sol.timer.start(map, math.random(40,150), function()
      local x, y, layer = enemy:get_position()
      local particle = map:create_custom_entity{
      name = "enemy_particle_effect",
      direction = enemy:get_sprite():get_direction(),
      layer = layer,
      x = math.random(x-8, x+8),
      y = math.random(y-8, y+8),
      width = 8,
      height = 8,
      sprite = "entities/pollution_ash",
      model = "dash_moth"
      }
      particle:set_drawn_in_y_order(true)
      if enemy:exists() and enemy:is_enabled() then return true end
  end)

end


function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:start(enemy)

  function movement:on_obstacle_reached()
    enemy:remove()
  end
end


-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" then
    enemy:go(enemy:get_movement():get_angle()+math.pi)
    sol.audio.play_sound("enemy_hurt")
  end
end