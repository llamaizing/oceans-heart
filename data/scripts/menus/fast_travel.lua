local fast_travel_menu = {}

--[[
limestone
spruce_head
ballast_harbor
goatshead
zephyr_bay
oakhaven
ivystump
yarrowmouth
snapmast
kingsdown
--]]

--[[---NOTES:
right now, the way unlocking ports works, you traverse the locations table one by one. If you hit a location you don't have the chart for, you get problems.
--Maybe just build the runes and then later, don't move along the rune table for selection, but move along the locations table, skipping any is_unlocked = false
--]]

local locations = {
  {name = "ivystump", coordinates = {180, 44}, is_unlocked, map_id = "oakhaven/ivystump_port"},
  {name = "yarrowmouth", coordinates = {299, 67}, is_unlocked, map_id = "Yarrowmouth/juniper_grove"},
  {name = "snapmast", coordinates = {330, 52}, is_unlocked, map_id = "snapmast_reef/snapmast_landing"},
  {name = "oakhaven", coordinates = {123, 102}, is_unlocked, map_id = "oakhaven/port"},
  {name = "goatshead", coordinates = {262, 138}, is_unlocked, map_id = "goatshead_island/goatshead_harbor"},
  {name = "isle_of_storms", coordinates = {378, 130}, is_unlocked, map_id = "isle_of_storms/isle_of_storms_landing"},
  {name = "kingsdown", coordinates = {319, 109}, is_unlocked, map_id = "Yarrowmouth/kingsdown"},
  {name = "spruce_head", coordinates = {83, 158}, is_unlocked, map_id = "stonefell_crossroads/spruce_head"},
  {name = "limestone", coordinates = {250, 200}, is_unlocked, map_id = "new_limestone/limestone_present"},
  {name = "zephyr_bay", coordinates = {315, 153}, is_unlocked, map_id = "stonefell_crossroads/zephyr_bay"},
  {name = "ballast_harbor", coordinates = {346, 184}, is_unlocked, map_id = "ballast_harbor/ballast_harbor"},
}
local DEFAULT_PORT = 8

local port_rune = sol.sprite.create("menus/maps/port_rune")
local port_runes = {}
local current_port = 1
local map_surface = sol.surface.create("menus/maps/overworld_map.png")


function fast_travel_menu:greeting()
  local game = sol.main.get_game()
  local location_name = fast_travel_menu:get_current_location_name()
  game:start_dialog("_fast_travel.location_" .. location_name, function()
    -- if you have new charts
    if fast_travel_menu:has_new_charts() then
      fast_travel_menu:unlock_current_map_port()
      game:start_dialog("_fast_travel.ride_question_new_chart", function(answer)
        sol.menu.start(game:get_map(), fast_travel_menu)
      end)
    --if you don't have any new chart
    else
      fast_travel_menu:unlock_current_map_port()
      game:start_dialog("_fast_travel.ride_question", function()
        sol.menu.start(game:get_map(), fast_travel_menu)
      end)
    end
  end)
end


function fast_travel_menu:get_current_location_name()
  local game = sol.main.get_game()
  local location_name
  for i=1, #locations do
    if game:get_map():get_id() == locations[i].map_id then
      location_name = locations[i].name
    end
  end
  return location_name
end


function fast_travel_menu:has_new_charts()
  local new_chart_brought
  local game = sol.main.get_game()
  local known_charts = game:get_value("lily_chart_total") or 0
  local held_charts = 0
  for i=1, #locations do
    if game:has_item("fast_travel_chart_" .. locations[i].name) then held_charts = held_charts + 1 end
  end
  if held_charts > known_charts then new_chart_brought = true end
  game:set_value("lily_chart_total", held_charts)
  return new_chart_brought
end


function fast_travel_menu:unlock_current_map_port()
  local game = sol.main.get_game()
  for i=1, #locations do
    if game:get_map():get_id() == locations[i].map_id then
      local item = game:get_item("fast_travel_chart_" .. locations[i].name)
      item:set_variant(1)
      game:set_value("lily_chart_total", game:get_value("lily_chart_total") + 1)
    end
  end
end


function fast_travel_menu:on_started()
  sol.main.get_game():get_hud():set_enabled(false)
  local game = sol.main.get_game()
  game:get_hero():freeze()
  game:set_suspended(true)
  fast_travel_menu:update_unlocked_locations()
  fast_travel_menu:update_current_port(game:get_value("fast_travel_menu_current_port") or DEFAULT_PORT)
end


function fast_travel_menu:on_finished()
  sol.main.get_game():get_hud():set_enabled(true)
end


function fast_travel_menu:update_unlocked_locations()
  local game = sol.main.get_game()
  for i=1, #locations do
    locations[i].is_unlocked = game:has_item("fast_travel_chart_" .. locations[i].name)
    if locations[i].is_unlocked then
      port_runes[i] = sol.sprite.create("menus/maps/port_rune")
    end
  end
end


function fast_travel_menu:update_current_port(new_port)
    if port_runes[current_port] then port_runes[current_port]:set_animation("stopped") end
    if port_runes[new_port] then port_runes[new_port]:set_animation("active") end
    current_port = new_port
end



--========================non-game logic functions=================================================--
--=================================================================================================--


--next or previous UNLOCKED port------
function fast_travel_menu:calculate_next_port(test_port, step)
  local next_port = test_port + step
  if next_port > #locations then next_port = 1 end
  if next_port <= 0 then next_port = #locations end
  if locations[next_port].is_unlocked then
    fast_travel_menu:update_current_port(next_port)
  else fast_travel_menu:calculate_next_port(next_port, step)
  end
end

function fast_travel_menu:confirm_selection()
  local game = sol.main.get_game()
  game:start_dialog("_game.fast_travel_confirm", function(answer)
    if answer == 2 then
      sol.audio.play_sound"ok"
      game:set_value("fast_travel_menu_current_port", current_port)
      sol.menu.stop(self)
      game:get_hero():unfreeze()
      game:set_suspended(false)
      game:get_hero():teleport(locations[current_port].map_id, "fast_travel_destination")
    end
  end)
end

function fast_travel_menu:on_command_pressed(command)
  local handled = false
  local game = sol.main.get_game()
  local hero = game:get_hero()
  if command == "attack" or command == "pause" then
    sol.menu.stop(self)
    hero:unfreeze()
    game:set_suspended(false)
    handled = true

  elseif command == "left" or command == "up" then
    sol.audio.play_sound("cursor")
    fast_travel_menu:calculate_next_port(current_port, -1)
    handled = true

  elseif command == "right" or command == "down" then
    sol.audio.play_sound("cursor")
    fast_travel_menu:calculate_next_port(current_port, 1)
    handled = true

  elseif command == "action" then
    fast_travel_menu:confirm_selection()
    handled = true
  end
  return handled
end

function fast_travel_menu:on_draw(dst)
  map_surface:draw(dst)
  for i=1, #locations do
    if locations[i].is_unlocked then
      port_runes[i]:draw(dst, locations[i].coordinates[1],locations[i].coordinates[2])
    end
  end
end

return fast_travel_menu