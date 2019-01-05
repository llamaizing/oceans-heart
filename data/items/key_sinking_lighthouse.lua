local item = ...
local game = item:get_game()

-- Event called when the game is initialized.

function item:on_created()
  item:set_savegame_variable("possession_key_sinking_lighthouse")
  item:set_amount_savegame_variable("amount_key_sinking_lighthouse")
end

function item:on_obtained()
  game:set_value("quest_seaglint_ruins_lighthouse", 0)
  self:add_amount(1)
end