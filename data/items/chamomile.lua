local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_chamomile")
  item:set_amount_savegame_variable("amount_chamomile")
end

function item:on_obtaining(variant, savegame_variable)
  self:add_amount(1)
end