local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_sword")
  item:set_sound_when_brandished(nil)
  item:set_sound_when_picked(nil)
  item:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  game:set_ability("sword", variant)
end

function item:on_obtaining(variant)

  sol.audio.play_sound("treasure")
end