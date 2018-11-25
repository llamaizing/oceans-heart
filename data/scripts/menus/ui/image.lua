--[[ image.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates an ui subcomponent created from an image file that is drawn onto a
	destination surface. The image is static with fixed dimensions.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new image control
	--properties (table) - table containing properties defining image behavior
		--image (string) - file path of the image to use
		--region_width (number, optional) - width in pixels of the image to draw
		--region_height (number, optional) - height in pixels of the image to draw
		--region_x (number, optional) - x coordinate of the region (default: 0)
		--region_y (number, optional) - y coordinate of the region (default: 0)
	--returns the newly created image object (table)
function control.create(properties)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local region_width = properties.region_width
	local region_width_num = tonumber(region_width)
	assert(not region_width or region_width_num, "Bad property region_width to 'create' (number or nil expected)")
	region_width = region_width_num
	if region_width then
		region_width = math.floor(region_width)
		assert(region_width>0, "Bad property region_width to 'create' (number must be positive)")
	end
	
	local region_height = properties.region_height
	local region_height_num = tonumber(region_height)
	assert(not region_height or region_height_num, "Bad property region_height to 'create' (number or nil expected)")
	region_height = region_height_num
	if region_height then
		region_height = math.floor(region_height)
		assert(region_height>0, "Bad property region_height to 'create' (number must be positive)")
	end
	
	local region_x = tonumber(properties.region_x or 0)
	assert(region_x, "Bad property region_x to 'create' (number or nil expected)")
	region_x = math.floor(region_x)
	assert(region_x>=0, "Bad property region_x to 'create' (number must not be negative)")
	
	local region_y = tonumber(properties.region_y or 0)
	assert(region_y, "Bad property region_y to 'create' (number or nil expected)")
	region_y = math.floor(region_y)
	assert(region_y>=0, "Bad property region_y to 'create' (number must not be negative)")
	
	local path = properties.image
	assert(type(path)=="string", "Bad property image to 'create' (string expected)")
	local surface = util.get_image(path)
	assert(surface, "Error in 'create', image cannot be loaded: "..path)
	
	local opacity = 255
	local is_visible = true --visible by default
	
	--// Returns the width and height (number) of the image in pixels
	function new_control:get_size() return region_width, region_height end
	
	--// Returns the path (string) of the source image file
	function new_control:get_image_path() return path end
	
	--// Get/set whether the image is visible (newly created images are visible by default)
		--value (boolean) - if true then the image is visible
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	function new_control:get_opacity() return opacity end
	function new_control:set_opacity(value) opacity = tonumber(value) end
	
	--// Draws the image on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the image
		--x (number, optional) - x coordinate of where to draw the image
		--y (number, optional) - y coordinate of where to draw the image
	function new_control:draw(dst_surface, x, y)
		if is_visible then
			surface:set_opacity(opacity)
			
			if region_width_num then
				surface:draw_region(
					region_x, region_y, region_width, region_height, dst_surface, x, y
				)
			else surface:draw(dst_surface, x, y) end
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
