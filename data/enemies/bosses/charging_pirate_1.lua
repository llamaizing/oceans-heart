local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
local going_hero
local angle
local playing_sound
enemy.immobilize_immunity = true

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(30)
  enemy:set_damage(2)
  enemy:set_hurt_style("boss")
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_push_hero_on_sword(true)
  enemy:set_obstacle_behavior("normal")
  enemy:set_size(16,16)
  enemy:set_origin(8, 13)

end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  enemy:get_sprite():set_animation("walking")
  sol.timer.start(enemy, 150, function() enemy:go_hero() end)

end

function enemy:go_hero()
  enemy:set_attack_consequence("sword", "protected")
  enemy:get_sprite():set_animation("walking")
  sol.timer.stop_all(enemy)
  sol.audio.play_sound("running")
  local n = sol.movement.create("target")
  n:set_target(hero)
  n:start(enemy)
  local direction = n:get_direction4()
  enemy:get_sprite():set_direction(direction)
  angle = n:get_angle()
  local m = sol.movement.create("straight")
  m:set_angle(angle)
  m:set_speed(130)
  m:set_smooth(false)
  m:start(enemy)
    
  function m:on_obstacle_reached()
    if not playing_sound and enemy:get_distance(hero) < 208 then
      sol.audio.play_sound("running_obstacle")
    end
    playing_sound = true
    enemy:stunned(1300)
  end
  going_hero = true
end


function enemy:stunned(length)
  enemy:set_attack_consequence("sword", 1)
  going_hero = false
  enemy:stop_movement()
  enemy:get_sprite():set_animation("stunned")
  sol.timer.start(enemy, length, function() playing_sound = false enemy:go_hero() end)
end

--function enemy:on_hurt(attack)
--  sol.timer.start(enemy, 1400, function() enemy:continue_movement() end)
--end

function enemy:continue_movement()
  local m = sol.movement.create("straight")
  m:set_angle(angle)
  m:set_speed(130)
  m:start(enemy)
end

function enemy:hit_by_toss_ball()
  enemy:stunned(1499)
end