--[[ group.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw multiple components onto a surface
	using specified x & y coordinates for each. A manual refresh is needed whenever any of
	those components are updated.
]]

--local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new group object
	--properties (table) - table containing properties defining group behavior
		--subcomponents (table, array) - array of each subcomponent (type of table or userdata) to be drawn
			--each entry is a table containing the subcomponent, x coordinate, and y coordinate as the first 3 values
	--width (number) - width of the entire draw region in pixels
	--height (number) - height of the entire draw region in pixels
	--returns the newly created array object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local width = width
	local width_num = tonumber(width)
	assert(width_num or not width, "Bad property width to 'create' (number or nil expected)")
	if width_num then
		width = math.floor(width_num)
		assert(width>0, "Bad property width to 'create' (number must be positive)")
		width_num = nil --no longer needed
	end
	
	local height = height
	local height_num = tonumber(height)
	assert(height_num or not height, "Bad property height to 'create' (number or nil expected)")
	if height_num then
		height = math.floor(height)
		assert(height>0, "Bad property height to 'create' (number must be positive)")
		height_num = nil --no longer needed
	end
	
	local surface = width and sol.surface.create(width, height) or sol.surface.create()
	local is_visible = true --visible by default
	
	local subcomponents = {}
	function new_control:set_subcomponents(list)
		assert(type(list)=="table", "Bad argument #1 to 'set_subcomponents' (table expected)")
		subcomponents = {} --clear previous subcomponents
		
		for i,entry in ipairs(list) do
			assert(type(entry)=="table", "Bad argument #1 to 'set_subcomponents' (table expected)")
			
			local subcomponent = entry[1]
			assert(type(subcomponent)=="table" or type(subcomponent)=="userdata",
				"Bad argument #1, index "..i..", 1 to 'set_subcomponents' (table or userdata expected)"
			)
			assert(subcomponent.draw, "Bad argument #1 to 'set_subcomponents' (no draw function found for item at index "..i..")")
			
			local x = math.max(math.floor(tonumber(entry[2])), 0) or 0
			local y = math.max(math.floor(tonumber(entry[3])), 0) or 0
			
			table.insert(subcomponents, {subcomponent=subcomponent, x=x, y=y})
		end
		assert(#subcomponents>0, "Bad argument #1 to 'set_subcomponents' (must include at least one subcomponent)")
	end
	
	if type(properties)=="table" and #properties>0 then
		new_control:set_subcomponents(properties)
	end
	
	--// Returns the width and height (number) of the frame in pixels
	function new_control:get_size() return width, height end
	
	--// Get/set whether the group should be drawn
		--value (boolean) - group will be drawn if true
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad arguement #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Get/set the opacity of the frame
		--value (number, integer) - The opacity value from 0 (transparent) to 255 (opaque)
	function new_control:get_opacity() return surface:get_opacity() end
	function new_control:set_opacity(value) return surface:set_opacity(value) end
	
	--// Get/set the blend mode of the surface used by the frame
	function new_control:get_blend_mode() return surface:get_blend_mode() end
	function new_control:set_blend_mode(value) surface:set_blend_mode(value) end
	
	--// Start a fade in or fade out of the surface used by the text control
	function new_control:fade_in(delay, callback) return surface:fade_in(delay, callback) end
	function new_control:fade_out(delay, callback) return surface:fade_out(delay, callback) end
	
	--// Get/set the offset of the surface used by the frame
	function new_control:get_xy() return surface:get_xy() end
	function new_control:set_xy(x, y) return surface:set_xy(x, y) end
	
	--// Get/stop the current movement of the surface used by the frame
	function new_control:get_movement() return surface:get_movement() end
	function new_control:start_movement(movement, callback) movement:start(surface, callback) end
	function new_control:stop_movement() return surface:stop_movement() end
	
	function new_control:get_count() return #subcomponents end
	function new_control:get_subcomponent(i) return subcomponents[i].subcomponent end
	
	--// Draws the group on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the group object
		--x (number, optional) - x coordinate of where to draw the group object
		--y (number, optional) - y coordinate of where to draw the group object
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			surface:clear()
			for _,entry in ipairs(subcomponents) do
				entry.subcomponent:draw(surface, entry.x, entry.y)
			end
			surface:draw(dst_surface, x, y)
		end
	end
	
	return new_control
end

return control

--[[ Copyright 2016-2018 Llamazing
  [[ 
  [[ This program is free software: you can redistribute it and/or modify it under the
  [[ terms of the GNU General Public License as published by the Free Software Foundation,
  [[ either version 3 of the License, or (at your option) any later version.
  [[ 
  [[ It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  [[ without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  [[ PURPOSE.  See the GNU General Public License for more details.
  [[ 
  [[ You should have received a copy of the GNU General Public License along with this
  [[ program.  If not, see <http://www.gnu.org/licenses/>.
  ]]
