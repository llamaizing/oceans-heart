-- Lua script of map goatshead_island/interiors/alchemist.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
if game:has_item("bombs_counter_2") ~= true then bomb_sale:set_enabled(false) end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


--brew_elixer
function pot:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.witch_pot", function(answer)
    if answer == 3 then
      if game:has_item("kingscrown") == true
      and game:has_item("ghost_orchid") == true and game:has_item("mandrake_white") == true and game:get_money() >= 25 then
        map:create_pickable({
          layer = 0, x = 200, y = 152,
          treasure_name = "elixer",
        })
        game:remove_money(25)
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end

--brew_elixer 2
function pot_2:on_interaction()
  game:start_dialog("_goatshead.npcs.crabhook.witch_pot", function(answer)
    if answer == 3 then
      if game:has_item("dandelion_seeds") == true and game:has_item("kingscrown") == true
      and game:has_item("ghost_orchid") == true and game:has_item("mandrake_white") == true and game:get_money() >= 25 then
        map:create_pickable({
          layer = 0, x = 200, y = 152,
          treasure_name = "elixer",
        })
        game:remove_money(25)
      else
        game:start_dialog("_game.insufficient_items")
      end
    end
  end)
end

--buy elixer
function elixer_sale:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.elixer", function(answer)
    if answer == 1 then
      if game:get_money() >= 100 then
        map:create_pickable({
          layer = 0, x = 232, y = 104,
          treasure_name = "elixer",
        })
        game:remove_money(100)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

--buy bait
function bait_sale:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.bait", function(answer)
    if answer == 1 then
      if game:get_money() >= 5 then
        map:create_pickable({
          layer = 0, x = 232, y = 104,
          treasure_name = "bait",
        })
        game:remove_money(5)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end

--buy bombs
function bomb_sale:on_interaction()
  game:start_dialog("_goatshead.npcs.alchemist.bombs", function(answer)
    if answer == 1 then
      if game:get_money() >= 50 then
        map:create_pickable({
          layer = 0, x = 232, y = 104,
          treasure_name = "bomb", treasure_variant = 3,
        })
        game:remove_money(50)
      else
        game:start_dialog("_game.insufficient_funds")
      end
    end
  end)
end