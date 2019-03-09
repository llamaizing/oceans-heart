-- Lua script of map goatshead_island/caves/goat_cavern.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
    map:get_camera():letterbox()
    key_chest:set_enabled(false)
  if game:get_value("goat_caverns_key_spider") ~= nil then
    key_chest:set_enabled(true)
    else
    key_chest:set_enabled(false)
  end
end

function door_switch:on_activated()
  map:open_doors("switch_door")
end

function key_spider:on_dead()
  sol.audio.play_sound("secret")
  key_chest:set_enabled(true)
end