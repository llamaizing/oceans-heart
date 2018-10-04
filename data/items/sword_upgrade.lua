local item = ...
local game = item:get_game()

function item:on_created()

  self:set_can_disappear(false)
  self:set_brandish_when_picked(true)
end

function item:on_obtaining(variant, savegame_variable)

local sword_damage =   game:get_value("sword_damage")
game:set_value("sword_damage", sword_damage + 1)
end
