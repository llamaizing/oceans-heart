local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_potion_magic_restoration")
  item:set_amount_savegame_variable("amount_potion_magic_restoration")
  item:set_max_amount(99)
  item:set_assignable(false)
end

function item:on_obtained()
  self:add_amount(1)
end


function item:on_using()
  if self:get_amount() > 0 and game:get_magic() < game:get_max_magic() then
    game:set_magic(game:get_max_magic())
    self:remove_amount(1)
    sol.audio.play_sound("uncorking_and_drinking_1")
    sol.audio.play_sound("magic_regen")
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end