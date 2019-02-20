--Initialize map behavior specific to this quest.

require"scripts/multi_events"

local map_meta = sol.main.get_metatable"map"


map_meta:register_event("on_started", function(self)
	local map = self
  local hero = map:get_hero()


  --sensors for triggering location title banners
  for sensor in map:get_entities("^map_banner_sensor") do
    function sensor:on_activated()
      sol.menu.start(map, map:get_game().map_banner)
      sensor:set_enabled(false)
    end
    sol.timer.start(map, 1000, function() sensor:set_enabled(false) end)
  end

--  for sensor in map:get_entities("^map_banner_reenabler_sensor") do
--    function sensor:on_activated()
--      for sensor in map:get_entities("^map_banner_sensor") do
--        sensor:set_enabled(true)
--      end
--    end
--  end

  --make invisible stairs invisible
  for stairs in map:get_entities("^invisible_stairs") do
    stairs:set_visible(false)
  end

  --universal layer up sensors move you up a layer
  for sensor in map:get_entities("^layer_up_sensor") do
    function sensor:on_activated()
      hero:set_layer(hero:get_layer() + 1)
    end
  end

  --and down a layer
  for sensor in map:get_entities("^layer_down_sensor") do
    function sensor:on_activated()
      hero:set_layer(hero:get_layer() - 1)
    end
  end

  --generic sensor to save solid ground
  for sensor in map:get_entities("^save_solid_ground_sensor") do
    function sensor:on_activated()
      hero:save_solid_ground()
    end
  end

  --generic sensor to reset solid ground.
  for sensor in map:get_entities("^reset_solid_ground_sensor") do
    function sensor:on_activated()
      hero:reset_solid_ground()
    end
  end


end)


return true
