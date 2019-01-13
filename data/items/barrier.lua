local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_barrier")
  item:set_assignable(true)
end

function item:on_obtaining()
  game:set_ability("sword", 1)
end

function item:on_using()
  local hero = game:get_hero()
  hero:freeze()
    hero:set_sword_sprite_id("hero/barrier")
    hero:unfreeze()
    hero:start_attack()
    sol.audio.play_sound("cane")
    local sprite = hero:get_sprite()
    local animation = sprite:get_animation()
    function sprite:on_animation_finished()
      hero:set_sword_sprite_id("hero/sword1")
    end
    item:set_finished()
end