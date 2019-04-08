-- Lua script of map Yarrowmouth/bear_catacombs/bear_catacombs.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = map:get_hero()

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()

  -- You can initialize the movement and sprites of various
  -- map entities here.
end)

--Arrow Pressure Switches
for switch in map:get_entities("arrow_trap_pressure_switch") do
  function switch:on_activated()
    sol.audio.play_sound("switch")
    local x, y, layer = hero:get_position()
    for shooter in map:get_entities("arrow_trap_slot") do
      shx, shy, shl = shooter:get_position()
      if math.abs(shx - x) <= 16 or math.abs(shy - y) <= 16 and layer == shl and shooter:is_in_same_region(hero) then
        local direction = shooter:get_direction4_to(hero)
        shooter:shoot(direction)
      end
    end
  end
end



--------Switches-----------
function a5_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("a5_door")
end

function d7_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("d7_door")
end
