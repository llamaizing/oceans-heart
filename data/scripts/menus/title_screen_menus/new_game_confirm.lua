local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")

local selection_options = {
 "yes",
 "no"
}

local cursor_sprite = sol.sprite.create("menus/cursor")
local selection_surface = sol.surface.create(144, 72)
local text_surface = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})
local text_surface2 = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local cursor_index
local MAX_CURSOR_INDEX = 1


function menu:on_started()
  cursor_index = 0

  text_surface:set_text_key("menu.title.confirm")
  text_surface:draw(selection_surface, 12, 0)
  text_surface2:set_text_key("menu.title.cancel")
  text_surface2:draw(selection_surface, 12, 16)

end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  local x = 340
  local y = 185
  selection_surface:draw(dst_surface, x, y)
  cursor_sprite:draw(dst_surface, x + 3, y + 4 + cursor_index * 16)
end


function menu:process_input(command)
  if command == "down" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index + 1
      if cursor_index > MAX_CURSOR_INDEX then cursor_index = 0 end
  elseif command == "up" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index - 1
      if cursor_index <0 then cursor_index = MAX_CURSOR_INDEX end


  elseif command == "space" then
    menu:process_selected_option(selection_options[cursor_index + 1])
  end
end


function menu:process_selected_option(selection)
    --Confirm
    if selection == "yes" then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("save1.dat", true)
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --Cancel
    elseif selection == "no" then
      sol.audio.play_sound("no")
      local new_cont_etc = require"scripts/menus/title_screen_menus/new_continue_etc"
      sol.menu.start(parent_menu, new_cont_etc)
      parent_menu:set_current_submenu(new_cont_etc)
      new_cont_etc:set_parent_menu(parent_menu)
      sol.menu.stop(menu)

    end --end cursor index cases
end


return menu