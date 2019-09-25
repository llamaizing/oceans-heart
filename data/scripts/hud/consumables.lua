--[[consumables.lua
	version 0.1a1
	24 Sep 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This hud script displays a brief popup displaying an item icon and amount whenever the
	player obtains a consumable item. Multiple popups will be stacked when the player gets
	multiple items in quick succession.
]]

require("scripts/multi_events")

local hud_submenu = {}

local MAX_COUNT = 5 --max number of panels to show at one time
local Y_OFFSET = 28 --vertical offset for each panel in pixels
local IMG_ID = "menus/panel.png"

	--properties (table, key/value)
		--x
		--y
		--duration
function hud_submenu:new(game, properties)
	local menu = {}
	
	local panels = {} --circular buffer
	local queue = {} --additional panels exceeding max, show when new slots free up
	local img = sol.surface.create(IMG_ID)
	
	--TODO validation
	local dst_x = properties.x
	local dst_y = properties.y
	local duration = properties.duration
	local is_enabled = true
	
	--[[local function remove_panel()
		local new_panel = table.remove(queue)
		panels[panel_index] = new_panel --may be nil
		if not new_panel then panel_count = panel_count - 1 end
		
		panel_index = panel_index + 1
		if panel_index > MAX_COUNT then panel_index = panel_index - MAX_COUNT end
		
		--TODO vertical slide translation of panels
	end]]
	
	local remove_panel
	remove_panel = function(name)
		--remove the panel corresponding to this timer
		for i,panel_i in ipairs(panels) do --find the index corresponding the the panel to remove
			if name == panel_i.name then
				table.remove(panels, i)
				panels[name] = nil
				break
			end
		end
		
		--move a panel from queue to active list if new slot is available
		if #panels < MAX_COUNT then
			local new_panel = table.remove(queue)
			if new_panel then
				local new_name = new_panel.name
				queue[new_name] = nil
				table.insert(panels, new_panel)
				panels[new_name] = new_panel
				
				new_panel.timer = sol.timer.start(menu, duration, function() remove_panel(new_name) end)
			end
		end
	end
	
	function menu:get_dst() return dst_x, dst_y end
	function menu:set_dst(x,y)
		x = tonumber(x)
		y = tonumber(y)
		assert(type(x)=="number", "Bad argument #2 to 'set_dst' (number expected)")
		assert(type(y)=="number", "Bad argument #3 to 'set_dst' (number expected)")
		x = math.floor(x)
		y = math.floor(y)
		
		dst_x = x
		dst_y = y
	end
	
	function menu:get_enabled() return is_enabled end
	function menu:set_enabled(enabled)
		assert(type(enabled)=="boolean", "Bad argument #2 to 'set_enabled' (boolean expected)")
		is_enabled = enabled
	end
	
	--// Create a new surface to be displayed for the given item and variant
	function menu:add_item(item, variant)
		local name = item:get_name()
		local amount = item:get_amount()
		local max_amount = item:get_max_amount()
		
		--create item icon sprite
		local sprite = sol.sprite.create"entities/items"
		sprite:set_animation(name)
		local direction = variant - 1
		sprite:set_direction(direction)
		
		--create amount text surface
		local font = "white_digits"
		if amount >= max_amount then font = "green_digits" end
		local text_surface = sol.text_surface.create{
			horizontal_alignment = "right",
			vertical_alignment = "top",
			text = amount,
			font = font,
		}
		
		local panel = {
			name = name,
			variant = variant,
			amount = amount,
			max_amount = max_amount,
			sprite = sprite,
			text_surface = text_surface,
			x=0, y=0,
		}
		
		if panels[name] then --already is a panel for this item, extend its timer instead
			--abort existing timer
			local timer = panels[name].timer
			if timer then timer:stop() end
			
			--update panel info
			for i,panel_i in ipairs(panels) do
				if panels[name] == panel_i then
					panels[i] = panel
					panels[name] = panel
				end
			end
			
			panel.timer = sol.timer.start(self, duration, function() remove_panel(name) end)
		elseif queue[name] then	--already is a panel for this item in queue
			--update panel info
			for i,panel_i in ipairs(queue) do
				if queue[name] == panel_i then
					queue[i] = panel
					queue[name] = panel
					break
				end
			end
		elseif #panels < MAX_COUNT then --display new panel if not full
			table.insert(panels, panel) --add new panel
			panels[name] = panel
			
			--TODO horizontal slide translation of newly added panel
			
			--create timer to remove panel
			panel.timer = sol.timer.start(self, duration, function() remove_panel(name) end)
		else --add panel to queue to be displayed later
			table.insert(queue, panel)
			queue[name] = panel
		end
	end
	
	function menu:on_started()
		panels = {}
		queue = {}
	end
	
	function menu:on_paused() is_enabled = false end
	function menu:on_unpaused() is_enabled = true end
	
	function menu:on_draw(dst_surface)
		if not is_enabled then return end
		
		local width, height = dst_surface:get_size()
		local x = dst_x + (dst_x < 0 and width or 0)
		local y = dst_y + (dst_y < 0 and height or 0)
		
		local offset = 0
		for _,panel in ipairs(panels) do
			img:draw(dst_surface, x+panel.x, y+offset+panel.y)
			local origin_x, origin_y = panel.sprite:get_origin()
			panel.sprite:draw(dst_surface, x+4+panel.x+origin_x, y+offset+4+panel.y+origin_y)
			panel.text_surface:draw(dst_surface, x+44+panel.x, y+offset+8+panel.y)
			offset = offset + Y_OFFSET
		end
	end
	
	return menu
end

return hud_submenu

--[[ Copyright 2019 Llamazing
  [] 
  [] This program is free software: you can redistribute it and/or modify it under the
  [] terms of the GNU General Public License as published by the Free Software Foundation,
  [] either version 3 of the License, or (at your option) any later version.
  [] 
  [] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [] PURPOSE.  See the GNU General Public License for more details.
  [] 
  [] You should have received a copy of the GNU General Public License along with this
  [] program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
