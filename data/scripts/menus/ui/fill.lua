--[[ fill.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw a solid fill color region that may
	use opacity onto a destination surface. The width and height of the region to be drawn
	is fixed.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new fill control
	--properties (table) - table containing properties defining fill behavior
		--color (string or table) - color of the fill
			--see make_RGB_color() in scripts/menus/ui/util.lua for more info
	--width (number or nil) - width of the fill region in pixels
		--nil - uses the entire width of the destination surface
	--height (number or nil) - height of the fill region in pixels
		--nil - uses the entire height of the destination surface
	--returns the newly created fill object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local width = width
	local width_num = tonumber(width)
	assert(width_num or not width, "Bad argument #2 to 'create' (number or nil expected)")
	if width_num then
		width = math.floor(width_num)
		assert(width>0, "Bad argument #2 to 'create' (number must be positive)")
	end
	width_num = nil --no longer needed
	
	local height = height
	local height_num = tonumber(height)
	assert(height_num, "Bad argument #3 to 'create' (number or nil expected)")
	if height_num then
		height = math.floor(height_num)
		assert(height>0, "Bad argument #3 to 'create' (number must be positive)")
	end
	height_num = nil --no longer needed
	
	local color, err = util.make_RGB_color(properties.color)
	assert(color, "Bad property color to 'create'"..tostring(err or ''))
	
	local is_visible = true --visible by default
	
	--// Returns the width and height (number) of the fill region in pixels
		--a value of nil indicates to use the entire width/height, respectively
	function new_control:get_size() return width, height end
	
	--// Get/set the color of the fill region as 3 RGB or 4 RGBA values, 0 to 255
	function new_control:get_color() return util.make_RGB_color(color) end --returns a copy of color table
	function new_control:set_color(value)
		local value, err = util.make_RGB_color(value)
		assert(value, "Bad argument #1 to 'set_color'"..tostring(err or ''))
		
		color = value
	end
	
	--// Get/set whether the fill is visible (visible by default)
		--value (boolean) - if true then the fill is visible
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Draws the fill on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the fill
		--x (number, optional) - x coordinate of where to draw the fill
		--y (number, optional) - y coordinate of where to draw the fill
	function new_control:draw(dst_surface, x, y)
		if is_visible then dst_surface:fill_color(color, x, y, width, height) end
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
