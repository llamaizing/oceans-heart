map_screen = {}

local map_id
local map_img = sol.surface.create()

function map_screen:get_map(game)
  map_img:clear()
  map_id = game:get_map():get_id()
  if string.find(map_id, "new_limestone/") then
    map_id = "limestone"
  elseif string.find(map_id, "goatshead_island/") then
    map_id = "goatshead"
  elseif string.find(map_id, "Yarrowmouth/") then
    map_id = "yarrowmouth"
  elseif string.find(map_id, "ballast_harbor/") then
    map_id = "yarrowmouth"
  elseif string.find(map_id, "oakhaven/") then
    map_id = "oakhaven"
  else
    print("error - unmapped island")
    map_id = "test"
  end
  map_img = sol.surface.create("menus/maps/"..map_id..".png")
--  print(map_id)
end

function map_screen:on_draw(dst_surface)
  map_img:draw(dst_surface)
end