local item = ...
local game = item:get_game()

function item:on_created()
  self:set_can_disappear(true)
  self:set_brandish_when_picked(true)
end

function item:on_started()
  item:set_savegame_variable("possession_bread")       --variable
  item:set_amount_savegame_variable("amount_bread")    --amount variable
  item:set_max_amount(999)
  item:set_assignable(true)
end

--obtained
function item:on_obtaining(variant, savegame_variable)
  local amounts = {1, 5, 10}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end

  self:add_amount(amount)
end

--used
function item:on_using()
  if self:get_amount() > 0 then
    game:add_life(10)              --health amount!
    self:remove_amount(1)
  end
  item:set_finished()
end