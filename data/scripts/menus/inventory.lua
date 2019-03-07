local multi_events = require"scripts/multi_events"

local inventory = {x=0, y=0}
multi_events:enable(inventory)

local game --the current game, must be manually updated using pause_menu:set_game()


--All items that could ever show up in the inventory:
local all_equipment_items = {
    {item = "barrier", name = "Barrier Charm", use_immediately = false,},
    {item = "boomerang", name = "Boomerang", use_immediately = false,},
    {item = "spear", name = "Spear", use_immediately = false,},
    {item = "ball_and_chain", name = "Flail", use_immediately = false,},
    {item = "hookshot", name = "Hookshot", use_immediately = false,},
    {item = "tornado_dash", name = "Tornado Dash", use_immediately = false,},
    {item = "gust", name = "Zephyrine's Tempest", use_immediately = false,},
    {item = "crystal_spark", name = "Ophira's Ember", use_immediately = false,},
    {item = "leaf_tornado", name = "Amalenchier's Wrath", use_immediately = false,},
    {item = "thunder_charm", name = "Seabird's Tear", use_immediately = false,},
    {item = "bombs_counter_2", name = "Bombs", use_immediately = false,},
    {item = "bow", name = "Bow", use_immediately = false,},
    {item = "bow_fire", name = "Flame Arrows", use_immediately = false,},
    {item = "bow_bombs", name = "Bomb Arrows", use_immediately = false,},
    {item = "bow_warp", name = "Warpbolt Charm", use_immediately = false,},
    {item = "potion_magic_restoration", name = "Magic Restoring Potion", use_immediately = true,},
    {item = "berries", name = "Berries", use_immediately = true,},
    {item = "apples", name = "Apples", use_immediately = true,},
    {item = "bread", name = "Burroak Bread", use_immediately = true,},
    {item = "elixer", name = "Elixer Vitae", use_immediately = true,},
}

--constants:
local GRID_ORIGIN_X = 10
local GRID_ORIGIN_Y = 72
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 4
local COLUMNS = 5
local MAX_INDEX = ROWS*COLUMNS --when every slot is full of an item, this should equal #all_equipment_items

local cursor_index

--// Call whenever starting new game
function inventory:set_game(current_game) game = current_game end

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

function inventory:on_started()
	assert(game, "The current game must be set using 'inventory:set_game(game)'")
end


function inventory:initialize(game)
    --set the cursor index, or which item the cursor is over
    --remember, the cursor index is 0 based but the all_equipment_items table starts at 1
    --since the cursor index is zero based, so are rows and columns.
    --So if ROWS is set to 4, that means you have rows 0, 1, 2, and 3. I'm writing this here because I'm gonna forget.
    cursor_index = game:get_value("inventory_cursor_index") or 0
    --initialize cursor's row and column
    self.cursor_column = 0
    self.cursor_row = 0
    --update cursor's row and column
    self:update_cursor_position(cursor_index)
    --initialize background (basically just the frame)
    self.menu_background = sol.surface.create("menus/inventory/inventory_background.png")
    --initialize the cursor
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")
    --set the description panel text
    self.description_panel = sol.text_surface.create{
        horizontal_alignment = "center",
        vertical_alignment = "top"
    }
    --make some tables to store the item sprites and their numbers for amounts
    self.equipment_sprites = {}
    self.counters = {}

    --create the item sprites:
    for i=1, #all_equipment_items do
        if all_equipment_items[i].item ~= "" then
            local item = game:get_item(all_equipment_items[i].item)
            local variant = item:get_variant()
            if variant > 0 then
                --initialize the sprite
                self.equipment_sprites[i] = sol.sprite.create("entities/items")
                self.equipment_sprites[i]:set_animation(all_equipment_items[i].item)
                self.equipment_sprites[i]:set_direction(variant - 1)

                --if the item has an amount, make a counter in the counters table
                if item:has_amount() then
                    local amount = item:get_amount()
                    self.counters[i] = sol.text_surface.create{
                        horizontal_alignment = "center",
                        vertical_alignment = "top",
                        text = item:get_amount(),
                        font = "white_digits"
                    }
                end
            end
        end
    end
    --get assigned item sprites
    self:initialize_assigned_item_sprites(game)

end

--get sprites for assigned items
function inventory:initialize_assigned_item_sprites(game)
    if game:get_item_assigned(1) then
        self.assigned_item_sprite_1 = sol.sprite.create("entities/items")
        self.assigned_item_sprite_1:set_animation(game:get_item_assigned(1):get_name())
        self.assigned_item_sprite_1:set_direction(game:get_item_assigned(1):get_variant()-1)
    end
    if game:get_item_assigned(2) then
        self.assigned_item_sprite_2 = sol.sprite.create("entities/items")
        self.assigned_item_sprite_2:set_animation(game:get_item_assigned(2):get_name())
        self.assigned_item_sprite_2:set_direction(game:get_item_assigned(2):get_variant()-1)
    end
end


function inventory:on_started()
    self:update_description_panel()
end



function inventory:update_cursor_position(new_index)
    local game = sol.main.game
    if(new_index <= MAX_INDEX and new_index >= 0) then cursor_index = new_index end
    local new_column = (cursor_index % COLUMNS)
    self.cursor_column = new_column
    local new_row = math.floor(cursor_index / COLUMNS)
    if new_row < ROWS then self.cursor_row = new_row end
    game:set_value("inventory_cursor_index", cursor_index)
    self:update_description_panel()
--    print("column: " .. self.cursor_column .. " row: " .. self.cursor_row)
end

function inventory:update_description_panel()
    --update description panel
    if self:get_item_at_current_index() and self.description_panel then
        self.description_panel:set_text(all_equipment_items[cursor_index + 1].name)
    elseif self.description_panel then
        self.description_panel:set_text("")
    end
end


function inventory:on_command_pressed(command)
    local game = sol.main.game
    local handled = false
    
    if command == "right" then
        if self.cursor_column == COLUMNS - 1 then return false end
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + 1)
        handled = true
    elseif command == "left" then
        if self.cursor_column == 0 then return false end
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index -1)
        handled = true
    elseif command == "up" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index - COLUMNS)
        handled = true
    elseif command == "down" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + COLUMNS)
        handled = true
        
    elseif command == "item_1" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(1, item)
            sol.audio.play_sound("ok")
        else sol.audio.play_sound("no")
        end
        self:initialize_assigned_item_sprites(game)
        handled = true
    elseif command == "item_2" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(2, item)
            sol.audio.play_sound("ok")
        else sol.audio.play_sound("no")
        end
        self:initialize_assigned_item_sprites(game)
        handled = true
    elseif command == "action" then
        --        sol.menu.start(game, quest_log)
        handled = true
    end
    return handled
end

function inventory:get_item_at_current_index()
    local game = sol.main.game
    local item = game:get_item(all_equipment_items[cursor_index + 1].item)
    if item:get_variant() > 0 then
        return item
    else return nil
    end
end

function inventory:on_draw(dst_surface)
    --draw the elements
    self.menu_background:draw(dst_surface, self.x, self.y)
    self.cursor_sprite:draw(dst_surface, (self.cursor_column * 32 + GRID_ORIGIN_X + 32) + self.x,  (self.cursor_row * 32 + GRID_ORIGIN_Y) + self.y)
    self.description_panel:draw(dst_surface, ((COLUMNS * 32) / 2 + GRID_ORIGIN_X + 16) + self.x, (ROWS *32 + GRID_ORIGIN_Y - 8)+self.y)
    --draw assigned items: (or, if you can see what items you have assigned elsewhere, maybe don't!)
--    if self.assigned_item_sprite_1 then self.assigned_item_sprite_1:draw(dst_surface, GRID_ORIGIN_X + 32, GRID_ORIGIN_Y-32) end
--    if self.assigned_item_sprite_2 then self.assigned_item_sprite_2:draw(dst_surface, GRID_ORIGIN_X + 32 + 32, GRID_ORIGIN_Y-32) end

    --draw inventory items
    for i=1, #all_equipment_items do
        if self.equipment_sprites[i] then
            --draw the item's sprite from the sprites table
            local x = ((i-1)%COLUMNS) * 32 + GRID_ORIGIN_EQUIP_X + 32
            local y = math.floor((i-1) / COLUMNS) * 32 + GRID_ORIGIN_EQUIP_Y
            self.equipment_sprites[i]:draw(dst_surface, x + self.x, y + self.y)
            if self.counters[i] then
                --draw the item's counter
                self.counters[i]:draw(dst_surface, x+8 + self.x, y+4 + self.y )
            end
        end
    end
end

return inventory