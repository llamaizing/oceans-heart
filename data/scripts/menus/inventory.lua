local inventory = {}

--All items that could ever show up in the inventory:
local all_equipment_items = {
    "bow",
    "bow_fire",
    "bombs_counter_2",
    "boomerang"
}
local all_menu_items = {
    "menu_berry"
}
--constants:
local GRID_ORIGIN_X = 10
local GRID_ORIGIN_Y = 72
local GRID_ORIGIN_EQUIP_X = GRID_ORIGIN_X
local GRID_ORIGIN_EQUIP_Y = GRID_ORIGIN_Y
local GRID_ORIGIN_MENU_ITEM_X = GRID_ORIGIN_X
local GRID_ORIGIN_MENU_ITEM_Y = GRID_ORIGIN_Y + 32
local ROWS = 3
local COLUMNS = 4

local cursor_index


function inventory:initialize(game)
--    local game = sol.main.game
    cursor_index = game:get_value("inventory_cursor_index") or 1
    self.equipment_sprites = {}
    self.menu_sprites = {}

    --create the item sprites:
    for i=1, #all_equipment_items do
        if all_equipment_items[i] ~= "" then
            local item = game:get_item(all_equipment_items[i])
            local variant = item:get_variant()
            if variant > 0 then
                self.equipment_sprites[i] = sol.sprite.create("entities/items")
                self.equipment_sprites[i]:set_animation(all_equipment_items[i])
--                self.equipment_sprites[i]:set_direction(variant - 1)
                self.equipment_sprites[i]:set_direction(0)
            end
        end
    end
    for i=1, #all_menu_items do
        if all_menu_items[i] ~= "" then
            local item = game:get_item(all_menu_items[i])
            local variant = item:get_variant()
            if variant > 0 then
                self.menu_sprites[i] = sol.sprite.create("entities/items")
                self.menu_sprites[i]:set_animation(all_menu_items[i])
                -- self.menu_sprites[i]:set_direction(variant - 1)
                self.menu_sprites[i]:set_direction(0)
            end
        end
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
    self.menu_background:draw(dst_surface)
    self.cursor_sprite:draw(self.menu_background, self.cursor_column * 32 + GRID_ORIGIN_X,  self.cursor_row + GRID_ORIGIN_Y)

    --draw equipment items
    for i=1, #all_equipment_items do
        if self.equipment_sprites[i] then
            self.equipment_sprites[i]:draw(self.menu_background, GRID_ORIGIN_EQUIP_X + (i*32), GRID_ORIGIN_EQUIP_Y)

        end
    end

    --draw menu items
    for i=1, #all_menu_items do
        if self.menu_sprites[i] then
            self.menu_sprites[i]:draw(self.menu_background, GRID_ORIGIN_MENU_ITEM_X + (i*32), GRID_ORIGIN_MENU_ITEM_Y)

        end
    end
end


function inventory:on_command_pressed(command)
    local handled = false

    if command == "right" then
        sol.audio.play_sound("cursor")
        cursor_index = cursor_index + 1
        handled = true
    elseif command == "left" then
        sol.audio.play_sound("cursor")
        cursor_index = cursor_index -1
        handled = true
    end
    return handled
end



return inventory