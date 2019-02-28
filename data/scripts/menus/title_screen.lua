local title_screen = {}

local background_sprite = sol.sprite.create("menus/title_screen/background")
local sea_sparkle = sol.sprite.create("menus/title_screen/sea_sparkle")
local cloud_1 = sol.sprite.create("menus/title_screen/cloud_1")
local cloud_2 = sol.sprite.create("menus/title_screen/cloud_2")
local sky = sol.surface.create("menus/title_screen/sky.png")
local seagull = sol.sprite.create("menus/title_screen/seagull")
local cursor_sprite = sol.sprite.create("menus/cursor")
local selection_surface = sol.surface.create(144, 72)
local black_fill = sol.surface.create()
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


local function create_cloud()
  local speed
  local j = #clouds + 1
  if j % 2 == 0 then
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_1")
    speed = 16
  else
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_2")
    speed = 12
  end

  if j % 2 == 0 then
    clouds[j].y = 75
  else
    clouds[j].y = 5
  end
  local m1 = sol.movement.create("straight")
  m1:set_angle(0)
  m1:set_speed(speed)
  m1:set_max_distance(700)
  m1:start(clouds[j], function() table.remove(clouds, 1) end)

end


function title_screen:on_started()
  black_fill:fill_color({0,0,0, 255})
  black_fill:fade_out(40)
  cursor_index = 0
  sol.timer.start(title_screen, 0, function()
    create_cloud()
    return math.random(8000, 9000)
  end)

  text_surface:set_text("  Continue")
  text_surface:draw(selection_surface, 0, 0)  
  text_surface2:set_text("  New Game")
  text_surface2:draw(selection_surface, 0, 16)


  sol.timer.start(title_screen, math.random(1000, 2000), function()
    local i = #leaves + 1
    leaves[i] = sol.sprite.create("entities/leaf_blowing")
    leaves[i]:set_xy(math.random(-120, 30), 0)
    local m3 = sol.movement.create("straight")
    m3:set_angle(math.random(5.3, 5.9))
    m3:set_speed(25)
    m3:set_max_distance(700)
    m3:start(leaves[i], function() table.remove(leaves, 1) end)
    return math.random(2400, 3500)
  end)

  sol.timer.start(title_screen, math.random(2000, 3000), function()
    local pose = math.random()*100
    if pose < 35 then
      seagull:set_animation("looking")
      sol.timer.start(title_screen, 1999, function() seagull:set_animation("stopped") end)
    elseif pose >= 35 then
      seagull:set_animation("shuffling")
      sol.timer.start(title_screen, math.random(600, 1100), function() seagull:set_animation("stopped") end)
    end
    return math.random(2000, 3000)
  end)
end


function title_screen:on_draw(dst_surface)
  sky:draw(dst_surface)
  for i=1 , #clouds do
    clouds[i]:draw(dst_surface, -140, clouds[i].y)
  end
  background_sprite:draw(dst_surface)
  sea_sparkle:draw(dst_surface)
  seagull:draw(dst_surface, 300, 42)
  selection_surface:draw(dst_surface, 245, 190)
  leaf_surface:draw(dst_surface)
  for i=1 , #leaves do
    leaves[i]:draw(dst_surface)
  end
  if cursor_index == 0 then
    cursor_sprite:draw(dst_surface, 245, 194)
  elseif cursor_index == 1 then
    cursor_sprite:draw(dst_surface, 245, 210)
  end

  black_fill:draw(dst_surface)
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