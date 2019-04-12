local item = ...
local game = item:get_game()

-- Event called when the game is initialized.

function item:on_created()
  item:set_savegame_variable("possession_key_thrush_fort")
  item:set_amount_savegame_variable("amount_key_thrush_fort")
end

function item:on_obtained()
  self:add_amount(1)
  game:set_value("quest_heron_well", 0)
end