--Initialize map behavior specific to this quest.

require"scripts/multi_events"

local map_meta = sol.main.get_metatable"map"


map_meta:register_event("on_started", function(self)
	local map = self
  local hero = map:get_hero()

  for stairs in map:get_entities("^invisible_stairs") do
    stairs:set_visible(false)
  end

  for sensor in map:get_entities("^layer_up_sensor") do
    function sensor:on_activated()
      hero:set_layer(hero:get_layer() + 1)
    end
  end

  for sensor in map:get_entities("^layer_down_sensor") do
    function sensor:on_activated()
      hero:set_layer(hero:get_layer() - 1)
    end
  end


end)


return true
