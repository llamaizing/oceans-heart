local item = ...
local game = item:get_game()

function item:on_created()
  self:set_can_disappear(true)
end

function item:on_started()
  item:set_savegame_variable("possession_berries")
  item:set_amount_savegame_variable("amount_berries")
  item:set_max_amount(50)
  item:set_assignable(false)
  item:set_brandish_when_picked(not game:has_item(item:get_name()))
end

--obtained
function item:on_obtaining(variant, savegame_variable)
  item:set_brandish_when_picked(false)
  local amounts = {1, 3, 5, 20}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'berries'")
  end

  self:add_amount(amount)
end

--used
function item:on_using()
  if self:get_amount() > 0 and game:get_life() < game:get_max_life() then
    game:add_life(1)
    self:remove_amount(1)
--    sol.audio.play_sound("heart")
  else sol.audio.play_sound("no")
  end
  item:set_finished()
end