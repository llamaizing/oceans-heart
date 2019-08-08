local multi_events = require"scripts/multi_events"

map_screen = {x=0, y=0}
multi_events:enable(map_screen)

local map_id
local map_img = sol.surface.create()
local map_bg = sol.surface.create("menus/maps/background.png")
local MAP_LIST = {
  new_limestone = "limestone",
  goatshead_island = "goatshead",
  Yarrowmouth = "yarrowmouth",
  ballast_harbor = "yarrowmouth",
  oakhaven = "oakhaven",
  error = "test"
}

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

  local map_prefix = map_id:match"^([^/]+)/"
--  if map_prefix == nil then map_prefix = "error" end --this is a nice catch, but won't print any errors : /
  local map_menu_name = MAP_LIST[map_prefix]
  assert(map_menu_name or map_menu_name == "test", "Error: unmapped island ("..map_prefix..")")
  map_img = sol.surface.create("menus/maps/"..map_menu_name..".png")
end

function map_screen:on_draw(dst_surface)
  map_bg:draw(dst_surface, self.x, self.y)
  map_img:draw(dst_surface, self.x, self.y)  
end

return map_screen
