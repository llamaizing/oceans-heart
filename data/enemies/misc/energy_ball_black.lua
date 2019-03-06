local enemy = ...
local bounces = 0
local FUSE_LENGTH = 1500
local NUM_CHILDREN

function enemy:on_created()
  local map = enemy:get_map()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_dying_sprite_id("enemies/enemy_killed_projectile")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")
  NUM_CHILDREN = 6

  --particle effect
  sol.timer.start(map, math.random(40,150), function()
      local x, y, layer = enemy:get_position()
      local particle = map:create_custom_entity{
      name = "enemy_particle_effect",
      direction = enemy:get_sprite():get_direction(),
      layer = layer,
      x = math.random(x-24, x+24),
      y = math.random(y-8, y+64),
      width = 8,
      height = 8,
      sprite = "entities/pollution_ash",
      model = "dash_moth"
      }
      particle:set_drawn_in_y_order(true)
      if enemy:exists() and enemy:is_enabled() then return true end
  end)

end

function enemy:set_num_children(amount)
  NUM_CHILDREN = amount
end

function enemy:go(direction)
  local movement = sol.movement.create("straight")
  movement:set_speed(100)
  movement:set_angle(direction)
  movement:set_smooth(false)
  movement:start(enemy)

  sol.timer.start(enemy, FUSE_LENGTH, function() enemy:split() end)

  function movement:on_obstacle_reached()
    enemy:split()
  end
end

--Split into smaller energy balls
function enemy:split()
  local x, y, layer = enemy:get_position()
  for i=1, NUM_CHILDREN do
        local child = enemy:get_map():create_enemy({
        name = "energy_ball_small",
        x = x, y = y, layer = layer, direction = 0,
        breed = "misc/energy_ball_small_black"
      })
      child:go((2*math.pi / NUM_CHILDREN) * i)
  end
  enemy:remove()
end


-- Destroy the fireball when the hero is touched.
function enemy:on_attacking_hero(hero, enemy_sprite)
  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
  enemy:split()
end

-- Change the direction of the movement when hit with the sword.
function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" then
    enemy:go(enemy:get_movement():get_angle()+math.pi)
    sol.audio.play_sound("enemy_hurt")
  end
end