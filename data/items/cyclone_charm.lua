local item = ...
local game = item:get_game()
local MAGIC_COST = 1

-- Event called when the game is initialized.
function item:on_started()
  item:set_savegame_variable("possession_cyclone_charm")
  item:set_assignable(true)
end

-- Event called when the hero is using this item.
--[[
function item:on_using()
  local hero = game:get_hero()
  if game:get_magic() < MAGIC_COST then sol.audio.play_sound("no")
  else
    game:remove_magic(MAGIC_COST)
    game:set_ability("sword_knowledge", 1)
    hero:start_attack_loading(0)
  item:set_finished()
end
--]]
--
function item:on_using()
  item:set_finished()
end
--]]
