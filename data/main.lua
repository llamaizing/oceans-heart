-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
local title_screen = require"scripts/menus/title_screen"

local game_manager = require("scripts/game_manager")

-- This function is called when Solarus starts.
function sol.main:on_started()
  --preload the sounds for faster access
  sol.audio.preload_sounds()
  --set the language
  sol.language.set_language("en")

  --Set the window title.
  sol.video.set_window_title("Ocean's Heart")

  --Title Screen:
  sol.menu.start(self, title_screen)

--  local game = game_manager:create"save1.dat"
--  sol.main:start_savegame(game)

end



-- Event called when the player pressed a keyboard key.
function sol.main:on_key_pressed(key, modifiers)


  local handled = false
  if key == "f5" then
    -- F5: change the video mode.
    sol.video.switch_mode()
    handled = true
  elseif key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    local is_fullscreen = sol.video.is_fullscreen()
    sol.video.set_fullscreen(not is_fullscreen)
    sol.video.set_cursor_visible(is_fullscreen) -- hide mouse on fullscreen
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
--    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.video.is_fullscreen() then
    -- Escape fullscreen
    sol.video.set_fullscreen(false)
    sol.video.set_cursor_visible(true)
    handled = true
  end

  return handled
end

--Starts a game.
function sol.main:start_savegame(game)

  sol.main.game = game
  game:start()
end
