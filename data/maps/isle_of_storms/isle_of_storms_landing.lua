-- Lua script of map isle_of_storms/landing.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()
local hero = game:get_hero()

local white_surface = sol.surface.create()
  white_surface:fill_color({255,255,255})
  white_surface:set_opacity(0)

-- Event called at initialization time, as soon as this map is loaded.
map:register_event("on_started", function()
  require("scripts/fx/sound_atmosphere_manager"):start_atmosphere(map, "rain")
  local world = map:get_world()
  game:set_world_rain_mode(world, "storm")
  local rain_manager = require("scripts/weather/rain_manager")
  rain_manager:set_storm_speed(300)
  rain_manager:set_lightning_delay(2000, 7500)
  rain_manager:set_darkness(120, 190)

  map:set_doors_open("boss_door")
  for cannon in map:get_entities("blackbeard_ship_cannon") do
    cannon.shooting_disabled = true
    cannon.projectile_breed = "misc/bomb_4_direction"
  end

  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") < 1 then
    game:set_value("quest_isle_of_storms", 1)
  end
  if game:get_value("sea_king_defeated") then
    rune_sensor:set_enabled(false)
    for e in map:get_entities("broken_ship") do e:set_enabled(true) end
  end
  brutus:get_sprite():set_animation("stopped")
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") >= 2 then
    brutus:set_enabled(false)
    brutus_sensor:set_enabled(false)
  end
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") >= 4 then
    map:set_doors_open("preboss_door")
  end

end)

function map:on_draw(dst)
  white_surface:draw(dst)
end

function morus:on_interaction()
  game:start_dialog("_oakhaven.npcs.morus.ferry_2", function(answer)
    if answer == 1 then
      hero:teleport("oakhaven/port", "morus_landing")
    elseif answer == 2 then
      hero:teleport("snapmast_reef/snapmast_landing", "ferry_landing")
    elseif answer == 3 then
      game:start_dialog("_oakhaven.npcs.morus.ferry_already")
    end
  end)
end


----------------Sensors--------------------------------------
function brutus_sensor:on_activated()
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") < 2 then
    hero:freeze()
    local m=sol.movement.create("path")
    m:set_path{6,6,6,6,6,6}
    m:start(brutus, function()
      game:start_dialog("_palace_of_storms.cutscenes.brutus.1")
      game:set_value("quest_isle_of_storms", 2)
      hero:unfreeze()
    end)
  end
end

function blackbeard_sensor:on_activated()
  if game:get_value("quest_isle_of_storms") and game:get_value("quest_isle_of_storms") == 3 then
    hero:freeze()
    map:focus_on(map:get_camera(), blackbeard_npc, function() hero:freeze() end)
    blackbeard_npc:set_enabled(true)
    blackbeard_npc:get_sprite():set_animation("holding_oceans_heart")
    map:create_poof(blackbeard_npc:get_position())
    sol.timer.start(map, 1200, function()
      hero:freeze()
      blackbeard_npc:get_sprite():set_animation("stopped")
      game:start_dialog("_palace_of_storms.cutscenes.blackbeard.1", function()
        mallow:set_enabled(true)
        local m = sol.movement.create("path")
        m:set_path{2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
        m:set_speed(80)
        m:start(mallow, function()
          game:start_dialog("_palace_of_storms.cutscenes.blackbeard.2", function()
            sol.timer.start(map, 500, function()
              map:create_poof(blackbeard_npc:get_position())
              blackbeard_npc:set_enabled(false)
              sol.timer.start(500, function()
                mallow:get_sprite():set_animation("collapsed")
                hero:walk("666666666666")
                sol.timer.start(map, 1000, function()
                  game:start_dialog("_palace_of_storms.cutscenes.mallow.5", function()
                    game:set_value("quest_isle_of_storms", 4)
                    map:open_doors("preboss_door")
                    hero:unfreeze()
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end
end

---Teleport Down
function rune_sensor:on_activated()
  hero:freeze()
  hero:set_direction(3)
  sol.audio.play_sound("sea_spirit")
  sol.audio.play_sound("charge_1")
  sol.audio.play_sound("warp")
  rune:set_enabled(true)
  white_surface:fade_in(150, function()
    hero:teleport("isle_of_storms/palace", "portal_to_surface")
  end)
end


--------BOSS------------
function boss_sensor:on_activated()
  map:close_doors("boss_door")
  hero:freeze()
  hero:set_animation"walking"
  local m=sol.movement.create"path" m:set_path{2,2,2,2,2,2,2,2,2,2} m:set_speed(80)
  m:start(hero, function()
    game:start_dialog("_palace_of_storms.cutscenes.blackbeard.3", function()
      hero:unfreeze()
      dummybeard:set_enabled(false)
      blackbeard_boss:set_enabled(true)
    end)
  end)
end

function blackbeard_boss:on_dead()

end