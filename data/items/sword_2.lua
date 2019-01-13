local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_sword_2_test")
  item:set_assignable(true)
end

function item:on_obtaining()
  game:set_ability("sword", 1)
end

function item:on_using()
  local hero = game:get_hero()
  hero:set_sword_sprite_id("hero/spear")
  hero:unfreeze()
  hero:start_attack()
  sol.timer.start(game, 240, function() hero:set_sword_sprite_id("hero/sword1") end)
  item:set_finished()
end


--  hero:set_sword_sprite_id("hero/sword2")
--  hero:set_sword_sprite_id("hero/sword1")
