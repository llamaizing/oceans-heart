local item = ...
local game = item:get_game()

function item:on_created()

  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

function item:on_obtaining(variant, savegame_variable)
  if not game:has_item("bombs_counter_2") then
    game:get_item("bombs_counter_2"):set_variant(1)
  end
  -- Obtaining bombs increases the bombs counter.
  local amounts = {1, 3, 5, 10, 20}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'bomb'")
  end
  self:get_game():get_item("bombs_counter_2"):add_amount(amount)

end