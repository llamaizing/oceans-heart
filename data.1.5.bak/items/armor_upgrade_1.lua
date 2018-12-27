local item = ...
local game = item:get_game()

function item:on_created()

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end

--Armor increases defense by 1
function item:on_obtaining(variant, savegame_variable)
  local d = game:get_value("defense")
  game:set_value("defense", d + 1)
--  print(game:get_value("defense"))

end