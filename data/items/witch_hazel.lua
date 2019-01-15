local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_witch_hazel")
  item:set_amount_savegame_variable("amount_witch_hazel")
end

function item:on_obtaining(variant, savegame_variable)
  local amounts = {1, 3, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item")
  end
  self:add_amount(amount)

end