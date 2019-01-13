local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

local SPAWN_RANGE = 100

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(10)
  enemy:set_damage(3)
  enemy:set_pushed_back_when_hurt(false)
  sol.timer.start(map, math.random(2500, 4500), function()
      if self:exists() then
        if self:get_distance(hero) <= SPAWN_RANGE then self:launch_bees() end
        return true
      end
  end)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  self:launch_bees()
end

function enemy:launch_bees()
  local x, y, layer = self:get_position()
  map:create_enemy{
    name = "hive_hornet",
    x = x, y=y-16, layer=layer,
    direction = 0,
    breed = "normal_enemies/hornet",
  }
end