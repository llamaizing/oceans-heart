local inventory = {}

--All items that could ever show up in the inventory:
local all_equipment_items = {
    "bow",
    "bow_fire",
    "bombs_counter_2",
    "boomerang",
    "menu_berry"
}
--constants:
local GRID_ORIGIN_X = 10
local GRID_ORIGIN_Y = 72
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local ROWS = 4
local COLUMNS = 4
local MAX_INDEX = 15 --when every slot is full of an item, this should equal #all_equipment_items

local cursor_index


function inventory:initialize(game)
--    local game = sol.main.game
    cursor_index = game:get_value("inventory_cursor_index") or 0
    self.equipment_sprites = {}

    --create the item sprites:
    for i=1, #all_equipment_items do
        if all_equipment_items[i] ~= "" then
            local item = game:get_item(all_equipment_items[i])
            local variant = item:get_variant()
            if variant > 0 then
                self.equipment_sprites[i] = sol.sprite.create("entities/items")
                self.equipment_sprites[i]:set_animation(all_equipment_items[i])
               self.equipment_sprites[i]:set_direction(variant - 1)
                -- self.equipment_sprites[i]:set_direction(0)
            end
        end
    end
    --get assigned item sprites
    self:initialize_assigned_item_sprites(game)
end

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
    self.menu_background = sol.surface.create("menus/inventory/inventory_background.png")
    self.cursor_sprite = sol.sprite.create("menus/inventory/selector")
    self.cursor_column = (cursor_index % ROWS)
    self.cursor_row = (cursor_index / ROWS)
end


function inventory:on_draw(dst_surface)
    --draw the menu background
--    dst_surface:clear()
--    self.menu_background:clear()
    self.menu_background:draw(dst_surface)
    self.cursor_sprite:draw(dst_surface, self.cursor_column * 32 + GRID_ORIGIN_X + 32,  self.cursor_row * 32 + GRID_ORIGIN_Y)
    --draw assigned items:
    if self.assigned_item_sprite_1 then self.assigned_item_sprite_1:draw(dst_surface, GRID_ORIGIN_X + 32, GRID_ORIGIN_Y-32) end
    if self.assigned_item_sprite_2 then self.assigned_item_sprite_2:draw(dst_surface, GRID_ORIGIN_X + 32 + 32, GRID_ORIGIN_Y-32) end

    --draw inventory items
    for i=1, #all_equipment_items do
        if self.equipment_sprites[i] then
            self.equipment_sprites[i]:draw(dst_surface, GRID_ORIGIN_EQUIP_X + (i*32), GRID_ORIGIN_EQUIP_Y)

        end
    end

end

function inventory:update_cursor_position(new_index)
--    if (cursor_index + new_index) <= MAX_INDEX then cursor_index = new_index end
    if(new_index <= MAX_INDEX and new_index >= 0) then cursor_index = new_index end
    local new_column = (cursor_index % ROWS)
    self.cursor_column = new_column
    local new_row = math.floor(cursor_index / ROWS)
    if new_row < ROWS then self.cursor_row = new_row end
    print("index:"..cursor_index.."column:"..self.cursor_column..", row:"..self.cursor_row)
end

function inventory:on_command_pressed(command)
    local game = sol.main.game
    local handled = false

    if command == "right" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + 1)
        handled = true
    elseif command == "left" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index -1)
        handled = true
    elseif command == "up" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index - COLUMNS)
        hendled = true
    elseif command == "down" then
        sol.audio.play_sound("cursor")
        self:update_cursor_position(cursor_index + COLUMNS)
        hendled = true
    elseif command == "item_1" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(1, item)
            sol.audio.play_sound("cane")
        else sol.audio.play_sound("wrong")
        end
        self:initialize_assigned_item_sprites(game)
    elseif command == "item_2" then
        local item = self:get_item_at_current_index()
        if item and item:is_assignable() then
            game:set_item_assigned(2, item)
            sol.audio.play_sound("cane")
        else sol.audio.play_sound("wrong")
        end
        self:initialize_assigned_item_sprites(game)

    elseif command == "action" then
        local item = self:get_item_at_current_index()
        if not item:is_assignable() then
            
        end
    end
    return handled
end

function inventory:get_item_at_current_index()
    local game = sol.main.game
    local item = game:get_item(all_equipment_items[cursor_index + 1])
    if item:get_variant() > 0 then
        return item
    else return nil
    end
end

return inventory