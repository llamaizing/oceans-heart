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
end


function enemy:on_restarted()

end
