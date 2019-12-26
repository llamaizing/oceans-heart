local multi_events = require"scripts/multi_events"
local world_map = require"scripts/world_map"

--constants
local REVEAL_DELAY = 1000 --delay time (in msec) before revealing new landmasses
local FADE_IN_DELAY = 100 --delay time (in msec) between fade in frames when revealing a landmass

local map_screen = {x=0, y=0}
multi_events:enable(map_screen)

local sprite_list --(table, array) list of sprites in draw order (unrevealed landmasses not included)
local map_bg --(sol.surface) blank map with no landmasses

--// Gets/sets the x,y position of the menu in pixels
function map_screen:get_xy() return self.x, self.y end
function map_screen:set_xy(x, y)
  x = tonumber(x)
  assert(x, "Bad argument #2 to 'set_xy' (number expected)")
  y = tonumber(y)
  assert(y, "Bad argument #3 to 'set_xy' (number expected)")

  self.x = math.floor(x)
  self.y = math.floor(y)
end

--retrieve visible landmass sprites from world_map script
function map_screen:on_started()
  map_bg = sol.surface.create("menus/maps/overworld_blank.png")

  local sprites, to_reveal = world_map:get_sprites(true) --reveal new landmasses
  sprite_list = sprites

  --do reveal fade-in animation if any new landmasses
  if #to_reveal > 0 then
    for _,sprite in ipairs(to_reveal) do
      sprite:set_opacity(0) --hide until fade-in starts
    end

    sol.timer.start(self, REVEAL_DELAY, function()
      --TODO play reveal map sound
      for _,sprite in ipairs(to_reveal) do
        sprite:fade_in(FADE_IN_DELAY)
      end
    end)
  end
end

--// Called when pause menu is closed, remove sprites from memory
function map_screen:on_pause_menu_finished()
  map_bg = nil
  sprite_list = nil
end

function map_screen:on_draw(dst_surface)
  map_bg:draw(dst_surface, self.x, self.y)
  for _,sprite in ipairs(sprite_list or {}) do
    sprite:draw(dst_surface, self.x, self.y)
  end
end

return map_screen
