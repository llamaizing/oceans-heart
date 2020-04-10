local menu = {}
local parent_menu
local game_manager = require("scripts/game_manager")

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
local text_surface3 = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local confirming = false
local cursor_index
local MAX_CURSOR_INDEX = 2


function menu:on_started()
  cursor_index = 0

  text_surface:set_text_key("menu.title.continue")
  text_surface:draw(selection_surface, 12, 0)
  text_surface2:set_text_key("menu.title.new_game")
  text_surface2:draw(selection_surface, 12, 16)
  text_surface3:set_text_key("menu.title.quit")
  text_surface3:draw(selection_surface, 12, 32)

end

function menu:set_parent_menu(dad)
  parent_menu = dad
end

function menu:on_draw(dst_surface)
  selection_surface:draw(dst_surface, 344, 190)
  cursor_sprite:draw(dst_surface, 347, 194 + cursor_index * 16)
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
    --Continue
    if cursor_index == 0 and not confirming then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("save1.dat")
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --New Game?
    elseif cursor_index == 1 and not confirming then
      sol.audio.play_sound("danger")
      confirming = true
      MAX_CURSOR_INDEX = 1
      selection_surface:clear()
      text_surface:set_text_key("menu.title.confirm")
      text_surface:draw(selection_surface, 12, 0)
      text_surface2:set_text_key("menu.title.cancel")
      text_surface2:draw(selection_surface, 12, 16)

    --New Game state, confirm new game
    elseif cursor_index == 0 and confirming then
      sol.audio.play_sound("elixer_upgrade")
      local game = game_manager:create("save1.dat", true)
      sol.main:start_savegame(game)
      sol.menu.stop(parent_menu)

    --New Game state, cancel new game
    elseif cursor_index == 1 and confirming then
      sol.audio.play_sound("no")
      confirming = false
      MAX_CURSOR_INDEX = 2
      selection_surface:clear()
      text_surface:set_text_key("menu.title.continue")
      text_surface:draw(selection_surface, 12, 0)
      text_surface2:set_text_key("menu.title.new_game")
      text_surface2:draw(selection_surface, 12, 16)
      text_surface3:set_text_key("menu.title.quit")
      text_surface3:draw(selection_surface, 12, 32)

    elseif  cursor_index == 2 then
      sol.main.exit()

    end --end cursor index cases

  end

end



return menu