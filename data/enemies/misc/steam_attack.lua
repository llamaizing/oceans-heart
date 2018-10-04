local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("fire", 1)
  enemy:set_attack_consequence("explosion", 1)
  enemy:set_can_attack(false)
  sprite:set_animation("burrowing")


end


-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  sprite:set_animation("burrowing")
--  sol.audio.play_sound("enemy_awake")
  sol.audio.play_sound("boiling")
  function sprite:on_animation_finished()
    enemy:set_can_attack(true)
    sprite:set_animation("growing")
    function sprite:on_animation_finished()
      enemy:remove()
    end
  end

end
