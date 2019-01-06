-- Lua script of item menu_berry.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()

-- Event called when the game is initialized.
function item:on_started()
  item:set_savegame_variable("possession_menu_berry")
  item:set_assignable(true)
end

-- Event called when the hero is using this item.
function item:on_using()
  game:add_life(2)
  sol.audio.play_sound("heart")
  print("used menu berry")
  item:set_finished()
end

function item:on_obtained()
  game:set_item_assigned(1, item)
end