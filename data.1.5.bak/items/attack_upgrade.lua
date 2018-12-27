local item = ...
local game = item:get_game()

function item:on_created()

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end

--Increase sword and bow damage by 1 each.
function item:on_obtaining(variant, savegame_variable)
  game:set_value("sword_damage", game:get_value("sword_damage") + 1)
  game:set_value("bow_damage", game:get_value("bow_damage") + 1)
--  print(game:get_value("sword_damage")) print(game:get_value("bow_damage"))

end