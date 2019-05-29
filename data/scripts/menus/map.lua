local multi_events = require"scripts/multi_events"

map_screen = {x=0, y=0}
multi_events:enable(map_screen)

local map_id
local map_img = sol.surface.create()

--// Gets/sets the x,y position of the menu in pixels
function map_screen:get_xy() return self.x, self.y end
function map_screen:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end

function map_screen:on_started()
  local game = sol.main.get_game()
  assert(game, "Error: cannot start map menu because no game is currently running")
  map_id = game:get_map():get_id()
  if string.find(map_id, "new_limestone/") then
    map_id = "limestone"
  elseif string.find(map_id, "goatshead_island/") then
    map_id = "goatshead"
  elseif string.find(map_id, "Yarrowmouth/") then
    map_id = "yarrowmouth"
  elseif string.find(map_id, "ballast_harbor/") then
    map_id = "yarrowmouth"
  elseif string.find(map_id, "oakhaven/") then
    map_id = "oakhaven"
  else
    print("error - unmapped island. Check scripts/menus/map.lua")
    map_id = "test"
  end
  map_img = sol.surface.create("menus/maps/"..map_id..".png")
end

function map_screen:on_draw(dst_surface)
  map_img:draw(dst_surface, self.x, self.y)
end

return map_screen
