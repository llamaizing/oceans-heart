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

  if game:get_value("bear_catacombs_miniboss_beat") then miniboss_wall:set_enabled(false) end
  if game:get_value("bear_catacombs_bear_mouth_door_opened") then bear_mouth_door:set_enabled(false) end
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

function b3_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("b3_door")
end

function e4_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("e4_door")
end

function c1_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("c1_door")
end

function bear_mouth_switch:on_activated()
  map:focus_on(map:get_camera(), bear_mouth_door, function()
    map:create_poof(bear_mouth_door:get_position())
    bear_mouth_door:set_enabled(false)
    game:set_value("bear_catacombs_bear_mouth_door_opened", true)
  end)
end


-------Miniboss--------
function miniboss_sensor:on_activated()
  miniboss_wall:set_enabled(false)
end

function miniboss:on_dead()
  for enemy in map:get_entities("mini_turret") do
    enemy:remove_life(100)
  end
  game:set_value("bear_catacombs_miniboss_beat", true)
  map:open_doors("d4_door")
end