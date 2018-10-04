local item = ...
local game = item:get_game()

function item:on_created()

  item:set_savegame_variable("possession_dandelion_charm")
  item:set_sound_when_brandished(nil)
  item:set_sound_when_picked(nil)
  item:set_shadow(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the charm determines the built-in ability "run".
  --Actually, it allows you to use the dash function programmed in the game_manager script.
--  game:set_ability("run", 1)
end

function item:on_obtaining(variant)

  sol.audio.play_sound("treasure")
end