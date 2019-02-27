local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_ironwood_charm")
  item:set_sound_when_brandished(nil)
  item:set_sound_when_picked(nil)
  item:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the charm determines the built-in ability "lift".
  game:set_ability("lift", 2)
end

function item:on_obtaining(variant)

  sol.audio.play_sound("treasure")
end