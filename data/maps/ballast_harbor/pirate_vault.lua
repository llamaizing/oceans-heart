-- Lua script of map ballast_harbor/pirate_vault.
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
  map:set_doors_open("boss_door")
  if game:has_item("charts") then dummy_boss:set_enabled(false) end

  if game:get_value("seen_pirate_vault_cutscene") then
    black_screen:set_enabled(false)
    gavrillo:set_enabled(false)
    blackbeard:set_enabled(false)
    brutus:set_enabled(false)
  else
    map:intro_cutscene_1()
  end
end)

--intro cutscene--
function map:intro_cutscene_1()
  hero:freeze()
  blackbeard:get_sprite():set_animation("stopped")
  brutus:get_sprite():set_animation("stopped")
  gavrillo:get_sprite():set_animation("stopped")
  game:set_value("seen_pirate_vault_cutscene", true)
  game:start_dialog("_ballast_harbor.npcs.pirate_vault.intro.1", function()
    hero:freeze()
    black_screen:set_enabled(false)
    game:start_dialog("_ballast_harbor.npcs.pirate_vault.intro.2", function()
      map:intro_cutscene_2()
    end)
  end)
end

function map:intro_cutscene_2()
  local m = sol.movement.create("path")
  m:set_path{0,0,0,0,6}
  m:start(blackbeard, function()
    sol.timer.start(map, 500, function()
      sol.audio.play_sound("running")
      fake_sword:set_enabled(false)
      sol.timer.start(map, 1000, function()
        sol.audio.play_sound("sword4")
        sol.audio.play_sound("sword1")
        blackbeard:get_sprite():set_animation("attack", function()
          blackbeard:get_sprite():set_animation("stopped")
          sol.timer.start(map, 2000, function()
            fake_sword:set_enabled(true)
            sol.audio.play_sound("bomb")
            sol.audio.play_sound("sword_tapping")
            sol.timer.start(map, 1500, function() map:intro_cutscene_3() end)
          end)
        end)        
      end)
    end)
  end)
end

function map:intro_cutscene_3()
  game:start_dialog("_ballast_harbor.npcs.pirate_vault.intro.3", function()
    local m = sol.movement.create("path")
    m:set_path{0,0,0,2,2}
    m:start(gavrillo, function()
      game:start_dialog("_ballast_harbor.npcs.pirate_vault.intro.4", function()
        m:set_path{6,6,6,6,6,6,6,6,6,6,6,6,6,6}
        m:set_speed(70)
        m:start(gavrillo, function()
          gavrillo:set_enabled(false)
          game:start_dialog("_ballast_harbor.npcs.pirate_vault.intro.5", function()
            m:set_path{4,4,4,4,4,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6}
            m:start(blackbeard, function()
              blackbeard:set_enabled(false)
              m:set_path{0,0,6,6,6,0,0,0,0,0,6,6,6,6,6,6}
              m:start(brutus, function()
                hero:unfreeze()
                brutus:set_enabled(false)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

-----------------------SWITCHES----------------------------

function front_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("front_door")
end

function hub_room_door_switch:on_activated()
  sol.audio.play_sound("switch_2")
  map:get_camera():shake({count = 8, amplitude = 4, speed = 80})
  game:start_dialog("_ballast_harbor.observations.pirate_vault.door_opened")
  map:open_doors("hub_room_door")
end

function d4_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("room_d4_door")
end

function d1_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("d1_door")
end

function room_b2_door_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_b2")
end

function door_b4_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_b4")
end

for switch in map:get_entities("room_c8_switch") do
  local switches_activated = 0
  function switch:on_activated()
    sol.audio.play_sound("switch")
    for switch in map:get_entities("room_c8_switch") do
      if switch:is_activated() then switches_activated = switches_activated + 1 end
    end
    if switches_activated == 3 then
      map:focus_on(map:get_camera(), door_c8, function() map:open_doors("door_c8") end)
    end
  end
end

function door_c6_switch:on_activated()
  sol.audio.play_sound("switch")
  map:open_doors("door_c6")
end




--------Enemies----------------

for enemy in map:get_entities("a5_enemy") do
  function enemy:on_dead()
    if not map:has_entities("a5_enemy") then
      sol.audio.play_sound("secret")
      map:create_poof(a5_chest:get_position())
      a5_chest:set_enabled(true)
    end
  end
end

for enemy in map:get_entities("c1_enemy") do
  function enemy:on_dead()
    if not map:has_entities("c1_enemy") then
      map:open_doors("c1_door")
    end
  end
end



-----Boss------------
function boss_sensor:on_activated()
  if not game:has_item("charts") then
    map:close_doors("boss_door")
    game:start_dialog("_ballast_harbor.npcs.charging_pirate.1", function()
      dummy_boss:set_enabled(false)
      boss:set_enabled(true)
      boss_sensor:set_enabled(false)
    end)
  end
end


function boss:on_dead()
  map:create_pickable({
    x = 1456, y = 1328, layer = 0, name = "health_upgrade"
  })
  map:open_doors("boss_door")
end


------End treasure chest--------
function warp_to_start_sensor:on_activated()
  if game:has_item("charts") then
    hero:teleport("ballast_harbor/ballast_harbor", "from_pirate_building_upstairs")
  end
end


