local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_tacklebox")
end

function item:on_variant_changed(variant)
  game:set_value("talked_to_wally", 2)
end