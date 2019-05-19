-- Lua script of enemy misc/fire_blast.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(1)
  enemy:set_can_attack(false)
  enemy:set_invincible(true)
end

function enemy:on_restarted()
  if enemy:get_distance(hero) < 400 and enemy:is_in_same_region(hero) then sol.audio.play_sound("fire_burst_2") end
  sprite:set_animation("charging", function()
    enemy:set_can_attack(true)
    sprite:set_animation("burning", function()
      enemy:remove()
    end)
  end)
end
