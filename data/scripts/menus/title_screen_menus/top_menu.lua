local title_screen = {}
local current_submenu

function title_screen:on_started()
  sol.menu.start(title_screen, require"scripts/menus/title_screen_menus/background", false)
  local cont_new_etc = require"scripts/menus/title_screen_menus/new_continue_etc"
  sol.menu.start(title_screen, cont_new_etc)
  cont_new_etc:set_parent_menu(title_screen)
  current_submenu = cont_new_etc
end

function title_screen:set_current_submenu(new_menu)
  current_submenu = new_menu
end


---KEYBOARD---------------------------------------------------------------

function title_screen:on_key_pressed(command)
  if command == "down" then
    current_submenu:process_input("down")
  elseif command == "up" then
    current_submenu:process_input("up")
  elseif command == "space" then
    current_submenu:process_input("space")
  elseif command == "return" then
    current_submenu:process_input("space")
  end

end


----JOYPAD---------------------------------------------------------------------
function title_screen:on_joypad_button_pressed(command)
  if command == 0 then
    current_submenu:process_input("space")
  end
end

function title_screen:on_joypad_hat_moved(hat,command)
  if command == 6 then
    current_submenu:process_input("down")
  elseif command == 2 then
    current_submenu:process_input("up")
  end
end

function title_screen:on_joypad_axis_moved(axis,state)
  if axis == 1 and state == 1 then
    current_submenu:process_input("down")
  elseif axis == 1 and state == -1 then
    current_submenu:process_input("up")
  end
end

return title_screen
