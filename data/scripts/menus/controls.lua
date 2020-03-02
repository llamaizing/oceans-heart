local controls_menu = {}

local bg = sol.surface.create("menus/controls_background.png")

local move = sol.text_surface.create()
local switch_subscreen = sol.text_surface.create()
local item1 = sol.text_surface.create()
local item2 = sol.text_surface.create()
local action = sol.text_surface.create()
local sword = sol.text_surface.create()
local pause = sol.text_surface.create()

move:set_text"(Arrow Keys) Move"
switch_subscreen:set_text"(F/G) Scroll Menus"
item1:set_text"(X) Use Item 1"
item2:set_text"(V) Use Item 2"
action:set_text"(C) Use Sword"
sword:set_text"(Space) Interact"
pause:set_text"(D) Pause"

function controls_menu:on_started()
  local OFFSET = -23
  local YSET = 8
  move:draw(bg,96 + OFFSET,32 + YSET)
  switch_subscreen:draw(bg,280 + OFFSET,48 + YSET)
  item1:draw(bg,328 + OFFSET,80 + YSET)
  item2:draw(bg,336 + OFFSET,96 + YSET)
  action:draw(bg,344 + OFFSET,112 + YSET)
  sword:draw(bg,304 + OFFSET,128 + YSET)
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