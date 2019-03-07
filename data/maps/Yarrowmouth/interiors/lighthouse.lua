-- Lua script of map Yarrowmouth/interiors/lighthouse.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  self:get_camera():letterbox()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function stella:on_interaction()
  --lighthouse isn't lit yet
  if not game:get_value("yarrowmouth_lighthouse_activated") then
    game:start_dialog("_yarrowmouth.npcs.stella.1", function()
      map:open_doors("upstairs_door")
      if not game:get_value("quest_lighthouses") then
        game:set_value("quest_lighthouses", 0)
        game:set_value("lighthouses_quest_num_lit", game:get_value("lighthouses_quest_num_lit") + 1 or 1)
      end
    end)

  --or, if the lighthouse has already been lit
  else
    --still lighting lighthouses:
    if game:get_value("quest_lighthouses") == 0 then
      game:start_dialog("_yarrowmouth.npcs.stella.2")

    elseif game:get_value("quest_lighthouses") < 3 then
      game:start_dialog("_yarrowmouth.npcs.stella.3")

    else
      game:start_dialog("_yarrowmouth.npcs.stella.4")
    end
  end
end

function lighthouse_switch:on_activated()
  if not game:get_value("yarrowmouth_lighthouse_activated") then
    game:set_value("yarrowmouth_lighthouse_activated", true)
    sol.audio.play_sound("switch_2")
    for entity in map:get_entities("torch") do
      entity:set_enabled(true)
    end
    game:start_dialog("_goatshead.observations.lighthouse_lit")
    game:set_value("lighthouses_quest_num_lit", game:get_value("lighthouses_quest_num_lit") + 1)
    if game:get_value("lighthouses_quest_num_lit") >= 4 then
      game:set_value("quest_lighthouses", 1)
    end
  end

end