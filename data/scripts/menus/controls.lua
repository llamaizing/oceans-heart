local controls_menu = {}

local bg = sol.surface.create("menus/controls_background.png")

local move = sol.text_surface.create()
local switch_subscreen = sol.text_surface.create()
local item1 = sol.text_surface.create()
local item2 = sol.text_surface.create()
local action = sol.text_surface.create()
local sword = sol.text_surface.create()
local pause = sol.text_surface.create()

move:set_text"Move"
switch_subscreen:set_text"Scroll Pause Screen"
item1:set_text"Use Item 1"
item2:set_text"Use Item 2"
action:set_text"Use Sword"
sword:set_text"Interact/Roll"
pause:set_text"Pause"

function controls_menu:on_started()
  local OFFSET = -23
  local YSET = 8
  move:draw(bg,96 + OFFSET,32 + YSET)
  switch_subscreen:draw(bg,312 + OFFSET,48 + YSET)
  item1:draw(bg,328 + OFFSET,80 + YSET)
  item2:draw(bg,336 + OFFSET,96 + YSET)
  action:draw(bg,344 + OFFSET,112 + YSET)
  sword:draw(bg,336 + OFFSET,128 + YSET)
  pause:draw(bg,192 + OFFSET,192 + YSET)
end

function controls_menu:on_draw(dst)
  bg:draw(dst)
end

function controls_menu:on_command_pressed(cmd)
  sol.menu.stop(controls_menu)
  handled = true
  return handled
end

return controls_menu