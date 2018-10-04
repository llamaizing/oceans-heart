-- Lua script of map goatshead_island/interiors/CV_tavern.
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


function danley:on_interaction()
  --first conversation
  if game:get_value("danley_convo_counter") == "special" then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.defeated_first", function() game:add_money(80) end)
    game:set_value("danley_convo_counter", 3)
  elseif game:get_value("danley_convo_counter") == nil then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.1", function(answer)
      if answer == 2 then
        game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.2")
        game:set_value("danley_convo_counter", 1)
        game:set_value("looking_for_crabhook_monster", true)
      end
    end)
  elseif game:get_value("danley_convo_counter") == 1 then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.2")

  elseif game:get_value("danley_convo_counter") == 2 then
    game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.3", function()
      game:add_money(80)
      game:set_value("looking_for_crabhook_monster", nil)
      game:set_value("danley_convo_counter", 3)
    end)

  elseif game:get_value("danley_convo_counter") == 3 then
    if game:get_value("phantom_squid_quest_complete") ~= true then
      game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.4")
    else
      game:start_dialog("_goatshead.npcs.crabhook.tavern.danley.5")
    end
  end
end