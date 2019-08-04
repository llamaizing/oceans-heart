local multi_events = require"scripts/multi_events"

local status_screen = {x=0,y=0}
multi_events:enable(status_screen)

local background_image = sol.surface.create("menus/status_background.png")

local stats_box = sol.surface.create(144, 48)

local text_surface = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})



--// Gets/sets the x,y position of the menu in pixels
function status_screen:get_xy() return self.x, self.y end
function status_screen:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")
	
	self.x = math.floor(x)
	self.y = math.floor(y)
end


function status_screen:on_started()
  local game = sol.main.get_game()
  assert(game, "Error: cannot start status menu because no game is currently running")
  --set stats
  stats_box:clear()

  local sword_dmg = game:get_value("sword_damage") or 0
  text_surface:set_text(sword_dmg)
  text_surface:draw(stats_box, 4, 0)

  local bow_dmg = game:get_value("bow_damage") or 0
  text_surface:set_text(bow_dmg)
  text_surface:draw(stats_box, 52, 0)

  local def = game:get_value("defense") or 0
  text_surface:set_text(def)
  text_surface:draw(stats_box, 104, 0)


end


function status_screen:on_draw(dst)
  background_image:draw(dst, self.x, self.y)
  stats_box:draw(dst, 210 + self.x, 162 + self.y)
end

return status_screen