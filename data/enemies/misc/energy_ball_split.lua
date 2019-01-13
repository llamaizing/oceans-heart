local enemy = ...
local bounces = 0
local FUSE_LENGTH = 1500
local NUM_CHILDREN

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/misc/energy_ball")
  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:set_origin(4, 4)
  enemy:set_obstacle_behavior("flying")
  enemy:set_can_hurt_hero_running(true)
  enemy:set_invincible()
  enemy:set_attack_consequence("sword", "custom")
  NUM_CHILDREN = 6
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
        breed = "misc/energy_ball_small"
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