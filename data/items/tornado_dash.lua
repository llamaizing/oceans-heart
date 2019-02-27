local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()
  item:set_savegame_variable("possession_tornado_dash")
  item:set_assignable(true)
end

-- Event called when the hero is using this item.
function item:on_using()
  local hero = game:get_hero()
--  sol.audio.play_sound("cane")
    hero:start_running()
  item:set_finished()
end

