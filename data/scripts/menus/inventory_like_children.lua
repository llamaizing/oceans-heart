local inventory = {}

local items_list = {
    "bow",
    "bow_fire",
    "bow_fire",
    "bombs_counter_2",
    "boomerang",
    "berry"
}

--constants:
local GRID_GAP = 2
local GRID_ORIGIN_X = 8
local GRID_ORIGIN_Y = 8
local COLUMNS = 7
local ROWS = 4


--ON STARTED
function inventory:on_started()
    --create a cursor
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")
    --create the background
    self.background = sol.sprite.create("menus/inventory/inventory_background")
    self.background:set_opacity(255)

    --make a table to hold all the item sprites
    local sprites = {}
    
    --iterate though all the items in the list
    for k=1, #items_list do
        if items_list[k] ~= "" then
            local item = self.game:get_item(items_list[k])
            local variant = item:get_variant()
    
            --if you have the item in your possession
            if variant > 0 then
                --make the appropriate sprite and put it in the sprites table
                self.sprites[k] = sol.sprite.create("entities/items")
                self.sprites[k]:set_animation(items_list[k])
                self.sprites[k]:set_direction(variant - 1)
            end
    end

    --initialize the cursor
    local index = self.game:get_value("inventory_last_item_index") or 0
    local row = math.floor(index / COLUMNS) --actually, divided by #of columns
    local column = index % COLUMNS --actually, modulo #of columns, too
    self:set_cursor_position(row, column)
end


--ON FINISHED
function inventory:on_finished()
    --I think the main thing here to to check if we're in the middle of
    --assigning an item, and if so, finish doing so before we quit the menu
end


function inventory:set_cursor_position(row, column)
    self.cursor_row = row
    self.cursor_column = column
    local index = row * COLUMNS + column
    self.game:set_value("inventory_last_item_index", index)
end

function inventory:get_selected_index()
    return self.cursor_row * COLUMNS + self.cursor_column
end

function inventory:is_item_selected()
    local item_name = items_list[self:get_selected_index() + 1]
    return self.game:get_item(item_name):get_variant() > 0
end

--handle keyboard/controller input
function inventory:on_command_pressed(command)
    local handled = false

    if command == "item_1" then
        if self:is_item_selected() then
            self:assign_item(1)
            handled = true
        end
    elseif command == "item_2" then
        if self:is_item_selected() then
            self:assign_item(2)
            handled = true
        end
    elseif command == "left" then
        self:set_cursor_position(self.cursor_row, self.cursor_column - 1)
        handled = true
    elseif command == "right" then
        self:set_cursor_position(self.cursor_row, self.cursor_column + 1)
        handled = true
    elseif command == "up" then
        self:set_cursor_position(self.cursor_row -1, self.cursor_column)
        handled = true
    elseif command == "down" then
        self:set_cursor_position(self.cursor_row +1, self.cursor_column)
        handled = true
    end
end