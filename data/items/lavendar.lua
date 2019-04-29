local item = ...
local game = item:get_game()

function item:on_started()
  item:set_savegame_variable("possession_lavendar")
  item:set_amount_savegame_variable("amount_lavendar")
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end

function item:on_obtaining(variant, savegame_variable)
  if game:has_item(item:get_name()) then item:set_brandish_when_picked(false) end
  local amounts = {1, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item")
  end
  self:add_amount(amount)

end