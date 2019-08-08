local multi_events = require"scripts/multi_events"

local status_screen = {x=0,y=0}
multi_events:enable(status_screen)

local cursor_index
local MAX_INDEX = 3
local music_level = 0
local sound_level = 0

local background_image = sol.surface.create("menus/status_background.png")
local cursor_sprite = sol.sprite.create("menus/cursor")
local music_sprite = sol.sprite.create("menus/slider")
local sound_sprite = sol.sprite.create("menus/slider")
local stats_box = sol.surface.create(144, 48)
local text_surface = sol.text_surface.create({
        font = "oceansfont",
        vertical_alignment = "top",
        horizontal_alignment = "left",
})

local options_strings = {
  "Save", "Quit", "Music", "Sounds"
}
local button_text_surfaces = {}
for i=1, #options_strings do
  button_text_surfaces[i] = sol.text_surface.create({
      font = "oceansfont",
      vertical_alignment = "top",
      horizontal_alignment = "left",
  })
  button_text_surfaces[i]:set_text(options_strings[i])
end

local stat_variables = {
  "sword_damage", "defense", "bow_damage"
}
local stat_names = {
  "Sword Damage: ", "Armor Level: ", "Bow Damage: "
}
local stat_name_surfaces = {}

for i=1, #stat_names do
  stat_name_surfaces[i] = sol.text_surface.create({
      font = "oceansfont",
      vertical_alignment = "top",
      horizontal_alignment = "left",
  })
  stat_name_surfaces[i]:set_text(stat_names[i])
end

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
  status_screen:update_volume_levels()
  cursor_index = 0
  local game = sol.main.get_game()
  assert(game, "Error: cannot start status menu because no game is currently running")

  for i=1, #stat_variables do
    local label = stat_names[i]
    local number = game:get_value(stat_variables[i])
    stat_name_surfaces[i]:set_text(
      label..number
    )
  end
  if not game:has_item"bow" then
    stat_name_surfaces[3]:set_text("")
  end
end


function status_screen:on_command_pressed(command)
  local handled = false
  if command == "up" then
    sol.audio.play_sound("cursor")
    cursor_index = cursor_index -1
    if cursor_index < 0 then cursor_index = MAX_INDEX end
    handled = true
  elseif command == "down" then
    sol.audio.play_sound("cursor")
    cursor_index = cursor_index + 1
    if cursor_index > MAX_INDEX then cursor_index = 0 end
    handled = true
  elseif command == "action" then
    status_screen:process_selection()
    handled = true
  elseif command == "left" then
    if cursor_index >= 2 then
      status_screen:process_direction("left")
      handled = true
    end
  elseif command == "right" then
    if cursor_index >= 2 then
      status_screen:process_direction("right")
      handled = true
    end
  end
  return handled
end


function status_screen:process_selection()
  local game = sol.main.get_game()
  if cursor_index == 0 then --save
    game:save()
    sol.audio.play_sound("elixer_upgrade")

  elseif cursor_index == 1 then --quit
    sol.main.reset()
  end
end

function status_screen:process_direction(direction)
  local increment = 0
  if direction == "left" then increment = -10
  elseif direction == "right" then increment = 10 end

  if cursor_index == 2 then --music
    sol.audio.set_music_volume(sol.audio.get_music_volume() + increment)

  elseif cursor_index == 3 then --sounds
    sol.audio.set_sound_volume(sol.audio.get_sound_volume() + increment)
  end
  status_screen:update_volume_levels()
end

function status_screen:update_volume_levels()
  music_level = sol.audio.get_music_volume()
  sound_level = sol.audio.get_sound_volume()
end


function status_screen:on_draw(dst)
  background_image:draw(dst, self.x, self.y)
--  stats_box:draw(dst, 210 + self.x, 162 + self.y)
  cursor_sprite:draw(dst,66 + self.x,90 + self.y + cursor_index*32)
  music_sprite:draw(dst, 80 + music_level/2 + self.x, 170 + self.y)
  sound_sprite:draw(dst, 80 + sound_level/2 + self.x, 201 + self.y)
  for i=1, #options_strings do
    button_text_surfaces[i]:draw(dst,74 +self.x,83 +self.y+ (i-1)*32)
  end
  for i=1, #stat_names do
    stat_name_surfaces[i]:draw(dst,210 +self.x, 146 +self.y+ (i-1)*16)
  end

end

return status_screen