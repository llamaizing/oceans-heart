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

--  sea_fog:get_sprite():set_blend_mode("add")
--  sea_fog:get_sprite():set_opacity(25)

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