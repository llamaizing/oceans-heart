local multi_events = require"scripts/multi_events"

local inventory = {x=0, y=0}
multi_events:enable(inventory)

--All items that could ever show up in the shop:
local all_items = {
    {item = "berries", name = "Berries", price = 5, variant = 3,
      availability_variable = "available_in_shop_berries",
      description = "Berries (5 pack) - each heals half a heart"},
    {item = "apples", name = "Apples", price = 12, variant = 2,
      availability_variable = "available_in_shop_apples",
      description = "Apples (set of 3) - each heals two hearts"},
    {item = "bread", name = "Burroak Bread", price = 45, variant = 2,
      availability_variable = "available_in_shop_bread",
      description = "Burroak Bread (5 loaves)- each heals five hearts"},
    {item = "elixer", name = "Elixer Vitae", price = 70, variant = 1,
      availability_variable = "available_in_shop_elixer",
      description = "Elixer - Recover all health, or revive you after KO"},
    {item = "potion_magic_restoration", name = "Magic Restoring Portion", price = 50, variant = 1,
      availability_variable = "available_in_shop_magic_restoring_potion",
      description = "Magic Potion - Restores your magic power"},
    {item = "unattainable_collectable", name="",price=0,variant=1,availability_variable="nil",description=""},
    {item = "arrow", name = "Arrows", price = 10, variant = 3,
      availability_variable = "available_in_shop_arrows",
      description = "Arrows (qty: 5)"},
    {item = "bomb", name = "Bombs", price = 30, variant = 3,
      availability_variable = "available_in_shop_bombs",
      description = "Bombs (qty: 5)"},
    {item = "berries", name = "Berries", price = 20, variant = 4,
      availability_variable = "available_in_shop_berries",
      description = "Berries (20 pack) - each heals half a heart"},
    {item = "apples", name = "Apples", price = 40, variant = 4,
      availability_variable = "available_in_shop_apples",
      description = "Apples (set of 10) - each heals two hearts"},
    {item = "bread", name = "Burroak Bread", price = 90, variant = 3,
      availability_variable = "available_in_shop_bread",
      description = "Burroak Bread (10 loaves)- each heals five hearts"},
    {item = "potion_stoneskin", name = "Stoneskin Potion", price = 80, variant = 1,
      availability_variable = "available_in_shop_stoneskin_potion",
      description = "Stoneskin Potion - Take half damage for 4 minutes",},
    {item = "potion_burlyblade", name = "Burlyblade Potion", price = 80, variant = 1,
      availability_variable = "available_in_shop_burlyblade_potion",
      description = "Burlyblade Potion - deal 1.5 damage for 4 minutes",},
    {item = "unattainable_collectable", name="",price=0,variant=1,availability_variable="nil",description=""},
    {item = "arrow", name = "Arrows", price = 40, variant = 5,
      availability_variable = "available_in_shop_arrows",
      description = "Arrows (qty: 20)"},
    {item = "bomb", name = "Bombs", price = 60, variant = 4,
      availability_variable = "available_in_shop_bombs",
      description = "Bombs (qty: 10)"},
}

--constants:
local GRID_ORIGIN_X = 48
local GRID_ORIGIN_Y = 121
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 2
local COLUMNS = 8
local MAX_INDEX = ROWS*COLUMNS - 1 --when every slot is full of an item, this should equal #all_items

local cursor_index

--// Gets/sets the x,y position of the menu in pixels
function inventory:get_xy() return self.x, self.y end
function inventory:set_xy(x, y)
	x = tonumber(x)
	assert(x, "Bad argument #2 to 'set_xy' (number expected)")
	y = tonumber(y)
	assert(y, "Bad argument #3 to 'set_xy' (number expected)")

	self.x = math.floor(x)
	self.y = math.floor(y)
end


function inventory:initialize(game, item_array)
    --first, we don't need the hero walking around with the menu open, so
    game:get_hero():freeze()
    --if you provide an array of items, use that instead of that standard one
    if item_array then all_items = item_array end
    --set the cursor index, or which item the cursor is over
    --remember, the cursor index is 0 based but the all_items table starts at 1
    --since the cursor index is zero based, so are rows and columns.
    --So if ROWS is set to 4, that means you have rows 0, 1, 2, and 3. I'm writing this here because I'm gonna forget.
    cursor_index = 0
    --initialize cursor's row and column
    self.cursor_column = 0
    self.cursor_row = 0
    --update cursor's row and column
    self:update_cursor_position(cursor_index)
    --initialize background (basically just the frame)
    self.menu_dark_overlay = sol.surface.create("menus/dark_overlay.png")
    self.menu_background = sol.surface.create("menus/shop_background.png")
    --initialize the cursor
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")
    --set the description panel text
    self.description_panel = sol.text_surface.create{
        horizontal_alignment = "left",
        vertical_alignment = "top",
    }
    self.price_panel = sol.text_surface.create{
      horizontal_alignment = "left",
      vertical_alignment = "top",
    }
    --make some tables to store the item sprites and their numbers for amounts
    self.item_sprites = {}
    self.prices = {}

    --create the item sprites:
    for i=1, #all_items do
        if all_items[i].item ~= "" then
            local item = game:get_item(all_items[i].item)
            local variant = all_items[i].variant
                  --initialize the sprite if you can purchase this item
            if game:get_value(all_items[i].availability_variable) then
                self.item_sprites[i] = sol.sprite.create("entities/items")
                self.item_sprites[i]:set_animation(all_items[i].item)
                self.item_sprites[i]:set_direction(variant - 1)
                self.prices[i] = sol.text_surface.create{
                    horizontal_alignment = "center",
                    vertical_alignment = "top",
                    text = tostring(all_items[i].price),
                    font = "white_digits"
                }
            end
        end
    end

end


function inventory:on_started()
  assert(sol.main.get_game(), "Error: cannot start shop menu because no game is currently running")
  sol.main.get_game():set_suspended(true)
  self:update_description_panel()
  self.menu_background:fade_in(5)
  self.menu_dark_overlay:fade_in(5)
end

function inventory:on_finished()
  sol.main.get_game():set_suspended(false)
  sol.main.get_game():get_hero():unfreeze()
  self.menu_background:fade_out(5)
  self.menu_dark_overlay:fade_out(5)
end



function inventory:update_cursor_position(new_index)
    local game = sol.main.get_game()
    if(new_index <= MAX_INDEX and new_index >= 0) then cursor_index = new_index
    elseif new_index > MAX_INDEX then cursor_index = 0
    elseif new_index < 0 then cursor_index = MAX_INDEX end
    local new_column = (cursor_index % COLUMNS)
    local new_row = math.floor(cursor_index / COLUMNS)

    if new_column < 0 then self.cursor_column = COLUMNS - 1
    elseif new_column > COLUMNS then self.cursor_column = 0
    else self.cursor_column = new_column end

    if new_row < 0 then self.cursor_row = ROWS - 1
    elseif new_row > ROWS then self.cursor_row = 0
    else self.cursor_row = new_row end

    self:update_description_panel()
end

function inventory:update_description_panel()
    --update description panel
    local game = sol.main.get_game()
    if self:get_item_at_current_index() and self.description_panel
    and game:get_value(all_items[cursor_index+1].availability_variable) then
        self.description_panel:set_text(all_items[cursor_index + 1].description)
        self.price_panel:set_text("Price: " .. all_items[cursor_index + 1].price .. " crowns")
    elseif self.description_panel then
        self.description_panel:set_text("")
        self.price_panel:set_text(" ")
    end
end


function inventory:on_command_pressed(command)
    local game = sol.main.get_game()
    local handled = false

    if command == "right" then
        sol.audio.play_sound("cursor")
        if self.cursor_column == COLUMNS - 1 then self:update_cursor_position(cursor_index - COLUMNS + 1)
        else self:update_cursor_position(cursor_index + 1) end
        handled = true
    elseif command == "left" then
        sol.audio.play_sound("cursor")
        if self.cursor_column == 0 then self:update_cursor_position(cursor_index + COLUMNS - 1)
        else self:update_cursor_position(cursor_index - 1) end
        handled = true
    elseif command == "up" then
        sol.audio.play_sound("cursor")
        if self.cursor_row == 0 then self:update_cursor_position(cursor_index + (COLUMNS * (ROWS - 1)))
        else self:update_cursor_position(cursor_index - COLUMNS) end
        handled = true
    elseif command == "down" then
        sol.audio.play_sound("cursor")
        if self.cursor_row == ROWS -1  then self:update_cursor_position(cursor_index - (COLUMNS * (ROWS - 1)))
        else self:update_cursor_position(cursor_index + COLUMNS) end
        handled = true

    elseif command == "action" then
        --the item here is all_items[cursor_index + 1]
        if game:get_value(all_items[cursor_index + 1].availability_variable) then
          game:start_dialog("_shop.purchase_confirm", function(answer)
            if answer == 2 then
              local current_item = all_items[cursor_index + 1]
              local current_amount
              local max_amount
              if current_item.name == "Arrows" then
                current_amount = game:get_item("bow"):get_amount()
                max_amount = game:get_item("bow"):get_max_amount()
              else
                current_amount = game:get_item(current_item.item):get_amount()
                max_amount = game:get_item(current_item.item):get_max_amount()
              end
              if current_amount == max_amount then
                --you don't have room for more
                game:start_dialog("_shop.no_room")
              elseif game:get_money() >= current_item.price then
                game:get_hero():start_treasure(current_item.item, current_item.variant)
                game:get_hero():freeze()
                game:remove_money(current_item.price)
              end
            else
              --decided not to buy
            end
          end)
        end
        handled = true

    elseif command == "pause" then
      handled = true

    elseif command == "attack" then
      handled = true
      game:get_hero():unfreeze()
      sol.menu.stop(self)
    end
    return handled
end

function inventory:get_item_at_current_index()
    local game = sol.main.get_game()
    local item_entry = all_items[cursor_index + 1]
    local item
    if item_entry then item = game:get_item(item_entry.item) end
    return item
end

function inventory:on_draw(dst_surface)
    --draw the elements
    self.menu_dark_overlay:draw(dst_surface)
    self.menu_background:draw(dst_surface, self.x, self.y)
    self.cursor_sprite:draw(dst_surface, (self.cursor_column * 32 + GRID_ORIGIN_X + 48) + self.x,  (self.cursor_row * 32 + GRID_ORIGIN_Y) + self.y)
    self.description_panel:draw(dst_surface, (GRID_ORIGIN_X) + 8 + self.x, (ROWS *32 + GRID_ORIGIN_Y - 8)+self.y)
    self.price_panel:draw(dst_surface, (GRID_ORIGIN_X) + 8 + self.x, (ROWS *32 + GRID_ORIGIN_Y + 8)+self.y)

    --draw inventory items
    for i=1, #all_items do
        if self.item_sprites[i] then
            --draw the item's sprite from the sprites table
            local x = ((i-1)%COLUMNS) * 32 + GRID_ORIGIN_EQUIP_X + 48
            local y = math.floor((i-1) / COLUMNS) * 32 + GRID_ORIGIN_EQUIP_Y
            self.item_sprites[i]:draw(dst_surface, x + self.x, y + self.y)
            --draw the item's counter
--            self.prices[i]:draw(dst_surface, x+8 + self.x, y+4 + self.y )
        end
    end
end

return inventory
