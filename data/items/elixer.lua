local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_elixer")
  item:set_amount_savegame_variable("amount_elixer")
  item:set_max_amount(99)
  item:set_assignable(false)
end

function item:on_obtained()
  self:add_amount(1)
end


function item:on_using()
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(game:get_value("elixer_restoration_level") * 2)
    self:remove_amount(1)
    sol.audio.play_sound("uncorking_and_drinking_1")
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end