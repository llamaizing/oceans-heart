local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local wait = 2000

function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_damage(10)
  enemy:set_attack_consequence("sword", "protected")
  enemy:set_attack_consequence("arrow", "protected")
  enemy:set_attack_consequence("fire", "protected")
  enemy:extend()

end


function enemy:on_restarted()

end

function enemy:extend()
  sol.timer.start(wait, function()
    if enemy:get_distance(hero) < 200 then sol.audio.play_sound("click_low") end
    sprite:set_animation("extending", function() sprite:set_animation("extended") enemy:retract() end)
  end) -- end of timer
end

function enemy:retract()
  sol.timer.start(wait, function()
    if enemy:get_distance(hero) < 200 then sol.audio.play_sound("click_low") end
    sprite:set_animation("retracting", function() sprite:set_animation("walking") enemy:extend() end)
  end) -- end of timer
end