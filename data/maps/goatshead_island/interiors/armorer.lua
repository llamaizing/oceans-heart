-- Lua script of map goatshead_island/interiors/armorer.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function plumbum:on_interaction()
  if game:get_value("plumb_improved_armor") ~= true then
    game:start_dialog("_goatshead.npcs.plumbum.1", function (answer)
      if answer == 3 and game:get_money() >49 then
        game:start_dialog("_goatshead.npcs.plumbum.2")
        game:set_value("defense", game:get_value("defense") + 1)
        game:remove_money(50)
        game:set_value("plumb_improved_armor", true)
      elseif answer == 3 and game:get_money() <50 then
        game:start_dialog("_game.insufficient_funds")
      end
    end)

  else
    game:start_dialog("_goatshead.npcs.plumbum.3")
  
  end
end

function palladio:on_interaction()
  game:start_dialog("_goatshead.npcs.palladio.1", function(answer)
    --sword
    if answer == 2 then
      --have required items
      if game:has_item("sword") == true and game:get_item("coral_ore"):get_amount() >= 1 and game:get_money() >= 50 then
        game:set_value("sword_damage", game:get_value("sword_damage") + 1)
        game:remove_money(50)
        game:get_item("coral_ore"):remove_amount(1)
        game:start_dialog("_goatshead.npcs.palladio.sword_improved")
      else --don't have required items
        game:start_dialog("_game.insufficient_items")
      end

    --bow
    elseif answer == 3 then
      --have required items
      if game:has_item("bow") == true and game:get_item("coral_ore"):get_amount() >= 1 and game:get_money() >= 50 then
        game:set_value("bow_damage", game:get_value("bow_damage") + 1)
        game:remove_money(50)
        game:get_item("coral_ore"):remove_amount(1)
        game:start_dialog("_goatshead.npcs.palladio.bow_improved")
      else --don't have required items
        game:start_dialog("_game.insufficient_items")
      end

    end -- which answer end

  end) --dialog end

end --palladio interaction end