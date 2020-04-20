local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_obstacle_behavior("swimming")
  enemy:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()
  sol.timer.start(enemy, math.random(1000, 4000), function()
    enemy:shoot()
  end)
end

function enemy:shoot()
  sprite:set_animation("wind_up", function()
    sprite:set_animation"stopped"
    local projectile = enemy:create_enemy{breed="misc/energy_ball_small"}
    projectile:go(projectile:get_angle(hero))
  end)
  sol.timer.start(enemy, math.random(4000, 6000), function()
    if enemy:exists() then enemy:shoot() end
  end)
end
