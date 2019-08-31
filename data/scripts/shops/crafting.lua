local multi_events = require"scripts/multi_events"

local crafting_menu = {x=0, y=0}
multi_events:enable(crafting_menu)

----------------------------------
local cursor_index = 0


--Recipes List--------------------
local unlocked_recipes = {}

local all_recipes = {
  {
    item_name = "elixer",
    ingredients = {"kingscrown", "ghost_orchid", "firethorn_berries"},
    unlock_variable = "is_craftable_elixer"
  },
  {
    item_name = "potion_magic_restoration",
    ingredients = {"witch_hazel", "mandrake", "monster_guts"},
    unlock_variable = "is_craftable_potion_magic_restoration"
  },
  {
    item_name = "potion_stoneskin",
    ingredients = {"mandrake_white", "geode", "monster_bones"},
    unlock_variable = "is_craftable_potion_stoneskin"
  },
  {
    item_name = "potion_burlyblade",
    ingredients = {"kingscrown", "burdock", "monster_guts"},
    unlock_variable = "is_craftable_potion_burlyblade"
  },
  {
    item_name = "potion_fleetseed",
    ingredients = {"ghost_orchid", "lavendar", "monster_guts"},
    unlock_variable = "is_craftable_potion_fleetseed"
  },
  {
    item_name = "ether_bombs_pickable",
    ingredients = {"mandrake", "lavendar", "chamomile"},
    unlock_variable = "is_craftable_ether_bombs"
  },
  {
    item_name = "iron_candle_pickable",
    ingredients = {"monster_bones", "geode", "witch_hazel"},
    unlock_variable = "is_craftable_salt_candles"
  },
  {
    item_name = "homing_eye_pickable",
    ingredients = {"monster_eye", "burdock", "firethorn_berries"},
    unlock_variable = "is_craftable_seeker_eyes"
  },

}



--Surfaces, etc.------------------
local menu_surface = sol.surface.create()
--initialize background (basically just the frame)
local menu_dark_overlay = sol.surface.create("menus/dark_overlay.png")
menu_dark_overlay:draw(menu_surface)
local menu_background = sol.surface.create("menus/crafting_background.png")
menu_background:draw(menu_surface)
--initialize the cursor
local cursor_sprite = sol.sprite.create("menus/cursor")
local recipes_surface = sol.surface.create(208, 192)
local ingredients_surface = sol.surface.create()


-----------------------------------

function crafting_menu:on_started()
  sol.main.get_game():set_suspended(true)
  crafting_menu:update_recipes()
  crafting_menu:update_ingredients()
end

function crafting_menu:on_finished()
  sol.main.get_game():set_suspended(false)
end

function crafting_menu:update_recipes()
  --put all unlocked recipes in unlocked_recipes
  local game = sol.main.get_game()
  for i=1, #all_recipes do
    if game:get_value(all_recipes[i].unlock_variable) then
      table.insert(unlocked_recipes, all_recipes[i])
    end
  end
  --draw unlocked recipes
  for i=1, #unlocked_recipes do
    local recipe_surface = sol.text_surface.create{
      vertical_alignment="top",
      font="oceansfont",
      text_key="item."..unlocked_recipes[i].item_name
    }
    recipe_surface:draw(recipes_surface, 0, 18 * i - 18)
  end
  recipes_surface:draw(menu_surface, 208, 56)
end

function crafting_menu:update_ingredients()
  local game = sol.main.get_game()
  local current_recipe = unlocked_recipes[cursor_index + 1]
  local ingredients = current_recipe.ingredients
  ingredients_surface:clear()
  --where to draw the ingredients
  local locations = {
    {x=96, y=82},
    {x=144, y=114},
    {x=96, y=146},
  }
  for i=1, #ingredients do
    local sprite = sol.sprite.create("entities/items")
    sprite:set_animation(ingredients[i])
    sprite:draw(ingredients_surface, locations[i].x, locations[i].y)
  end
end


-----Command Inputs-------------------
function crafting_menu:on_command_pressed(command)
  local game = sol.main.get_game()
  local handled = false

  if command == "down" then
    handled = true
    cursor_index = cursor_index + 1
    if cursor_index >= #unlocked_recipes then cursor_index = 0 end
    sol.audio.play_sound"cursor"
    crafting_menu:update_ingredients()

  elseif command == "up" then
    handled = true
    cursor_index = cursor_index - 1
    if cursor_index < 0 then cursor_index = #unlocked_recipes - 1 end
    sol.audio.play_sound"cursor"
    crafting_menu:update_ingredients()

  elseif command == "attack" then
    handled = true
    sol.menu.stop(self)
  end

  return handled
end



--From llamazing's pause menu system, in case I ever want to incorporate this into the pause menu
--// Gets/sets the x,y position of the menu in pixels
function crafting_menu:get_xy() return self.x, self.y end
function crafting_menu:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")

	self.x = math.floor(x)
	self.y = math.floor(y)
end



function crafting_menu:on_draw(dst)
  menu_surface:draw(dst)
  ingredients_surface:draw(dst)
  cursor_sprite:draw(dst, 200, 60 + cursor_index * 18)
end


return crafting_menu