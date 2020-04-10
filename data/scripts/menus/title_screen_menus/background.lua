local title_screen = {}

local background_sprite = sol.sprite.create("menus/title_screen/background")
local sea_sparkle = sol.sprite.create("menus/title_screen/sea_sparkle")
local sky = sol.surface.create("menus/title_screen/sky.png")
local seagull = sol.sprite.create("menus/title_screen/seagull")
local black_fill = sol.surface.create()
local title_surface = sol.surface.create("menus/title_card.png")
local leaf_surface = sol.surface.create()

local leaves = {}
local clouds = {}


local function create_cloud()
  local speed
  local j = #clouds + 1
  if j % 2 == 0 then
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_" .. math.floor(math.random(1,8)))
    speed = 16
  else
    clouds[j] = sol.sprite.create("menus/title_screen/cloud_" .. math.floor(math.random(1,8)))
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

  title_surface:fade_in()
  sol.timer.start(self, 100, function()
    sol.audio.play_music("title_screen_piano_only")
  end)
  black_fill:fill_color({0,0,0, 255})
  black_fill:fade_out(40)
  sol.timer.start(title_screen, 0, function()
    create_cloud()
    return math.random(8000, 9000)
  end)


  sol.timer.start(title_screen, math.random(1000, 2000), function()
    local i = #leaves + 1
    leaves[i] = sol.sprite.create("entities/leaf_blowing")
    leaves[i]:set_xy(math.random(-100, 50), 0)
    local m3 = sol.movement.create("straight")
    m3:set_angle(math.random(5.3, 6))
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
  seagull:draw(dst_surface, 340, 42)
  leaf_surface:draw(dst_surface)
  for i=1 , #leaves do
    leaves[i]:draw(dst_surface)
  end
  title_surface:draw(dst_surface, 6, 24)


  black_fill:draw(dst_surface)
end

return title_screen
