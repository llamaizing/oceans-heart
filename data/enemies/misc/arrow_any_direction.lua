-- Bomb thrown by arborgeist bombers.

local enemy = ...
local map = enemy:get_map()
enemy.immobilize_immunity = true

function enemy:on_created()

  enemy:set_life(1)
  enemy:set_damage(4)
  enemy:create_sprite("enemies/misc/arrow_4")
  enemy:set_size(8, 8)
  enemy:set_origin(4, 4)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  enemy:set_attack_consequence("sword", "custom")
  enemy:set_attack_consequence("arrow", "ignored")
--  enemy:set_layer(enemy:get_layer() + 1)
  enemy:set_layer_independent_collisions()
end

function enemy:on_obstacle_reached()
--[[  local bombx, bomby, bomblayer = enemy:get_position()
  sol.audio.play_sound("explosion")
  map:create_explosion({
    layer = bomblayer,
    x = bombx,
    y = bomby,
  }) --]]
  enemy:remove()
end

function enemy:go(angle)

  local movement = sol.movement.create("straight")
  movement:set_speed(190)
  movement:set_angle(angle)
  movement:set_ignore_obstacles(true)
  movement:set_smooth(false)
  movement:start(enemy)
end


function enemy:on_hurt()
--[[  sol.audio.play_sound("explosion")
  local bombx, bomby, bomblayer = enemy:get_position()
  map:create_explosion({
    layer = bomblayer,
    x = bombx,
    y = bomby,
  }) --]]
  enemy:remove()
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  hero:start_hurt(enemy, enemy_sprite, enemy:get_damage())
--[[  sol.audio.play_sound("explosion")
  local bombx, bomby, bomblayer = enemy:get_position()
  map:create_explosion({
    layer = bomblayer,
    x = bombx,
    y = bomby,
  }) --]]
  enemy:remove()
end
--]]