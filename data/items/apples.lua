local item = ...
local game = item:get_game()

function item:on_created()
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
end

function item:on_started()
  item:set_savegame_variable("possession_apples")       --variable
  item:set_amount_savegame_variable("amount_apples")    --amount variable
  item:set_max_amount(game:get_value("max_apple_capacity") or 50)
  item:set_assignable(false)
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end

--obtained
function item:on_obtaining(variant, savegame_variable)
  item:set_brandish_when_picked(false)
  local amounts = {1, 3, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end

  self:add_amount(amount)
end

--used
function item:on_using()
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(4)              --health amount!
    self:remove_amount(1)
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end