-- Lua script of map oakhaven/interiors/wall_jail.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map is loaded.
function map:on_started()
  if game:get_value("quest_mayors_dog") and game:get_value("quest_mayors_dog") >= 11 then
    litton:set_enabled(true)
  end

  if game:get_value("quest_oakhaven_musicians") and game:get_value("quest_oakhaven_musicians") >= 3 then
    trumpet_player:set_enabled(true)
  end

  if game:get_value("quest_briarwood_mushrooms") and game:get_value("quest_briarwood_mushrooms") >= 3 then
    michael:set_enabled(true)
  end

  if game:get_value("quest_pirate_fort") and game:get_value("quest_pirate_fort") >= 6 then
    jazari:set_enabled(true)
  end

end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end


