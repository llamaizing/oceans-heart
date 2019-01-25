local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(8)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_traversable(false)
  enemy:set_attacking_collision_mode("touching") --so it can still hurt the hero without being traversable
  enemy:set_invincible()

--particle effect
  sol.timer.start(map, math.random(150,225), function()
      local x, y, layer = enemy:get_position()
      local particle = map:create_custom_entity{
      name = "enemy_particle_effect",
      direction = enemy:get_sprite():get_direction(),
      layer = layer,
      x = math.random(x-16, x+16),
      y = math.random(y-16, y+8),
      width = 8,
      height = 8,
      sprite = "entities/pollution_ash",
      model = "dash_moth"
      }
      particle:set_drawn_in_y_order(true)
      if enemy:exists() and enemy:is_enabled() then return true end
  end)

end