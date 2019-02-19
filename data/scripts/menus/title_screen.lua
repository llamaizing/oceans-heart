local title_screen = {}

local background_sprite = sol.sprite.create("menus/title_screen/background")
local sea_sparkle = sol.sprite.create("menus/title_screen/sea_sparkle")
local cloud_1 = sol.sprite.create("menus/title_screen/cloud_1")
local cloud_2 = sol.sprite.create("menus/title_screen/cloud_2")
local sky = sol.surface.create("menus/title_screen/sky.png")
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
local leaf_surface = sol.surface.create()

local leaves = {}
local clouds = {}

local cursor_index
local MAX_CURSOR_INDEX = 1


local function create_cloud(j)
  local speed
  if j % 2 == 0 then
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_1")
    speed = 16
  else
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_2")
    speed = 12
  end
  local m1 = sol.movement.create("straight")
  m1:set_angle(0)
  m1:set_speed(speed)
  m1:set_max_distance(400)
  m1:start(clouds[j])

end


function title_screen:on_started()
  cursor_index = 0
  create_cloud(1)
  local j = 2
  sol.timer.start(title_screen, math.random(8000, 9000), function()
    create_cloud(j)
    j = j+ 1
    return true
  end)

  text_surface:set_text("  Continue")
  text_surface:draw(selection_surface, 0, 0)  
  text_surface2:set_text("  New Game")
  text_surface2:draw(selection_surface, 0, 16)

  local i = 1
  sol.timer.start(title_screen, math.random(2800, 3500), function()
    leaves[i] = sol.sprite.create("entities/leaf_blowing")
    leaves[i]:set_xy(math.random(0, 120), 0)
    local m3 = sol.movement.create("straight")
    m3:set_angle(math.random(5.3, 5.9))
    m3:set_speed(25)
    m3:start(leaves[i])
    i = i + 1
    return true
  end)
end


function title_screen:on_draw(dst_surface)
  sky:draw(dst_surface)
  for i=1 , #clouds do
    local y
    if i % 2 == 0 then
      y = 75
    else
      y = 5
    end
    clouds[i]:draw(dst_surface, -140, y)
  end
  background_sprite:draw(dst_surface)
  sea_sparkle:draw(dst_surface)
  selection_surface:draw(dst_surface, 250, 200)
  leaf_surface:draw(dst_surface)
  for i=1 , #leaves do
    leaves[i]:draw(dst_surface)
  end
  if cursor_index == 0 then
    cursor_sprite:draw(dst_surface, 250, 204)
  elseif cursor_index == 1 then
    cursor_sprite:draw(dst_surface, 250, 220)
  end
end


function title_screen:on_command_pressed(command)
  if command == "down" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index + 1
      if cursor_index > MAX_CURSOR_INDEX then cursor_index = 0 end
  elseif command == "up" then
      sol.audio.play_sound("cursor")
      cursor_index = cursor_index - 1
      if cursor_index <0 then cursor_index = MAX_CURSOR_INDEX end
  end

end

return title_screen