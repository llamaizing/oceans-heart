--[[ frame.lua
	version 1.0a1
	16 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates an ui subcomponent created from an image that has borders and will
	be scaled to any size by repeating the edge sections appropriately.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new frame control
	--properties (table) - table containing properties defining frame behavior
		--image (string) - file path of the image to use
		--region_width (number) - width in pixels of the source image to use
		--region_height (number) - height in pixels of the source image to use
		--region_x (number) - x coordinate of the source image region to use
		--region_y (number) - y coordinate of the source image region to use
		--borders (number or table) - defines edge boundaries of the frame in pixels
			--(number) - all 4 borders are this number of pixels
			--(table, 2 entries) - left/right border and top/bottom border in pixels
			--(table, 4 entries) - right, top, left, and bottom border in pixels
		--is_hollow (boolean, optional) - if true then middle region of frame will not be drawn
			--default: false, the middle region will be drawn
		--is_top_edge (boolean, optional) - if false then don't draw the top edge between the top corners
			--default: true, the top edge will be drawn
			--note: to not draw the entire top edge including corners then a value of 0 for the top border can be used instead
		--is_TL_corner (boolean, optional) - if false then the top left corner will not be drawn
			--default: true, the top left corner will be drawn
		--is_TR_corner (boolean, optional) - if false then the top right corner will not be drawn
			--default: true, the top right corner will be drawn
		--is_BL_corner (boolean, optional) - if false then the bottom left corner will not be drawn
			--default: true, the bottom left corner will be drawn
		--is_BR_corner (boolean, optional) - if false then the bottom right corner will not be drawn
			--default: true, the bottom right corner will be drawn
	--width (number) - width of the frame in pixels
	--height (number) - height of the frame in pixels
	--returns the newly created frame object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local region_width = tonumber(properties.region_width)
	assert(region_width, "Bad property region_width to 'create' (number expected)")
	region_width = math.floor(region_width)
	assert(region_width>0, "Bad property region_width to 'create' (number must be positive)")
	
	local region_height = tonumber(properties.region_height)
	assert(region_height, "Bad property region_height to 'create' (number expected)")
	region_height = math.floor(region_height)
	assert(region_height>0, "Bad property region_height to 'create' (number must be positive)")
	
	local region_x = tonumber(properties.region_x)
	assert(region_x, "Bad property region_x to 'create' (number expected)")
	region_x = math.floor(region_x)
	assert(region_x>=0, "Bad property region_x to 'create' (number must not be negative)")
	
	local region_y = tonumber(properties.region_y)
	assert(region_y, "Bad property region_y to 'create' (number expected)")
	region_y = math.floor(region_y)
	assert(region_y>=0, "Bad property region_y to 'create' (number must not be negative)")
	
	local borders = util.make_margins_4(properties.borders)
	assert(borders[1]<=region_width, "Bad property borders to 'create' (right border exceeds region_width)")
	assert(borders[2]<=region_height, "Bad property borders to 'create' (top border exceeds region_height)")
	assert(borders[3]<=region_width, "Bad property borders to 'create' (left border exceeds region_width)")
	assert(borders[4]<=region_height, "Bad property borders to 'create' (bottom border exceeds region_height)")
	
	local path = properties.image
	assert(type(path)=="string", "Bad property image to 'create' (string expected)")
	local raw_image = util.get_image(path)
	assert(raw_image, "Error in 'create', image cannot be loaded: "..path)
	
	--create fill objects
	local fills = {}
	function new_control:set_fills(list)
		assert(type(list)=="table", "Bad argument #1 to 'set_fills' (table expected)")
		
		local ui = require"scripts/menus/ui/ui"
		
		for i,entry in ipairs(list) do
			assert(type(entry.layer)=="string", "Bad property ["..i.."].layer to 'set_fills' (string expected)")
			local component = ui.create_preset(entry.layer, entry.width, entry.height)
			table.insert(fills, {component, entry.x, entry.y})
		end
		
		self:refresh()
	end
	
	local is_visible = true --only draw if true
	local is_hollow = not not properties.is_hollow --default value of false
	local is_top_edge = properties.is_top_edge ~= false --default value of true
	local is_TL_corner = properties.is_TL_corner ~= false --default value of true
	local is_TR_corner = properties.is_TR_corner ~= false --default value of true
	local is_BL_corner = properties.is_BL_corner ~= false --default value of true
	local is_BR_corner = properties.is_BR_corner ~= false --default value of true
	
	local width = tonumber(width)
	assert(width, "Bad argument #2 to 'create' (number expected)")
	width = math.floor(width)
	assert(width>0, "Bad argument #2 to 'create' (number must be positive)")
	
	local height = tonumber(height)
	assert(height, "Bad argument #2 to 'create' (number expected)")
	height = math.floor(height)
	assert(height>0, "Bad argument #2 to 'create' (number must be positive)")
	
	local surface = sol.surface.create(width, height)
	
	--// Returns the path (string) of the source image file
	function new_control:get_image_path() return path end
	
	--// Get/set whether the top edge of the frame should be drawn (top corners still drawn regardless)
		--value (boolean) - if true then top edge of frame is drawn
	function new_control:get_is_top_edge() return is_top_edge end
	function new_control:set_is_top_edge(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_is_top_edge' (boolean expected)")
		local needs_refresh = is_top_edge ~= value
		
		is_top_edge = value
		if needs_refresh then self:refresh() end --redraws surface
		
		return is_top_edge
	end
	
	--// Returns the width and height (number) of the frame in pixels
	function new_control:get_size() return width, height end
	
	--// Get/set whether the frame should be drawn
		--value (boolean) - frame will be drawn if true
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
	
	--// Start a fade in or fade out of the surface used by the frame
	function new_control:fade_in(delay, callback) return surface:fade_in(delay, callback) end
	function new_control:fade_out(delay, callback) return surface:fade_out(delay, callback) end
	
	--// Get/set the offset of the surface used by the frame
	function new_control:get_xy() return surface:get_xy() end
	function new_control:set_xy(x, y) return surface:set_xy(x, y) end
	
	--// Get/stop the current movement of the surface used by the frame
	function new_control:get_movement() return surface:get_movement() end
	function new_control:start_movement(movement, callback) movement:start(surface, callback) end
	function new_control:stop_movement() return surface:stop_movement() end
	
	
	
	--// Regenerates the surface containing the frame image scaled to correct width/height
		--This function is called automatically whenever a refresh is necessary and should not need to be called manually
	function new_control:refresh()
		surface:clear()
		
		--draw fills
		
		for _,entry in ipairs(fills) do
			local fill = entry[1]
			local x, y = entry[2], entry[3]
			
			fill:draw(surface, x, y)
		end
		
		--draw frame
		
		local region_mid_x = math.max(region_width - borders[1] - borders[3], 0)
		local region_mid_y = math.max(region_height - borders[2] - borders[4], 0)
		
		if width<=region_width and height<=region_height then --no need to tile
			raw_image:draw_region(
				region_x, region_y,
				region_width, region_height,
				surface
			)
		else
			local x,y = borders[3], borders[2] --current position on surface
			
			--draw top and bottom edge (non-corner) across
			while x < width - borders[1] do
				if is_top_edge and borders[2]>0 then
					--draw top edge
					raw_image:draw_region(
						region_x + borders[3],
						region_y,
						math.min(region_mid_x, width - borders[1] - x), --last segment may be narrower
						borders[2],
						surface,
						x,
						0
					)
				end
				
				if borders[4]>0 then
					--draw_bottom_edge
					raw_image:draw_region(
						region_x + borders[3],
						region_y + region_height - borders[4],
						math.min(region_mid_x, width - borders[1] - x), --last segment may be narrower
						borders[4],
						surface,
						x,
						height - borders[4]
					)
				end
				
				x = x + region_mid_x --move right and repeat middle segment
			end
			
			--draw left and right edges (non-corner) and middle segment down
			while y < height - borders[4] do
				if borders[3]>0 then
					--draw left edge for this row
					raw_image:draw_region(
						region_x,
						region_y + borders[2],
						borders[3],
						math.min(region_mid_y, height - borders[4] - y), --last row may be shorter
						surface,
						0,
						y
					)
				end
				
				x = borders[3] --beginning of middle segment
				
				if not is_hollow and region_mid_x>0 and region_mid_y>0 then
					--draw middle region across for this row
					while x < width - borders[1] do
						raw_image:draw_region(
							region_x + borders[3],
							region_y + borders[2],
							math.min(region_mid_x, width - borders[1] - x), --last segment may be narrower
							math.min(region_mid_y, height - borders[4] - y), --last row may be shorter
							surface,
							x,
							y
						)
						x = x + region_mid_x --move right and repeat middle segment
					end
				end
				
				if borders[1]>0 then
					--draw right edge for this row
					raw_image:draw_region(
						region_x + region_width - borders[1],
						region_y + borders[2],
						borders[1],
						math.min(region_mid_y, height - borders[4] - y), --last row may be shorter
						surface,
						width - borders[1],
						y
					)
				end
				
				y = y + region_mid_y --move down 1 row and repeat
			end
			
			--// draw four corners
			
			if is_TL_corner and borders[2]>0 and borders[3]>0 then
				--Upper-left corner
				raw_image:draw_region(
					region_x,
					region_y,
					borders[3],
					borders[2],
					surface
				)
			end
			
			if is_TR_corner and borders[1]>0 and borders[2]>0 then
				--Upper-right corner
				raw_image:draw_region(
					region_x + region_width - borders[1],
					region_y,
					borders[1],
					borders[2],
					surface,
					width - borders[1],
					0
				)
			end
			
			if is_BL_corner and borders[3]>0 and borders[4]>0 then
				--Lower-left corner
				raw_image:draw_region(
					region_x,
					region_y + region_height - borders[4],
					borders[3],
					borders[4],
					surface,
					0,
					height - borders[4]
				)
			end
			
			if is_BR_corner and borders[1]>0 and borders[4]>0 then
				--Lower-right corner
				raw_image:draw_region(
					region_x + region_width - borders[1],
					region_y + region_height - borders[4],
					borders[1],
					borders[4],
					surface,
					width - borders[1],
					height - borders[4]
				)
			end
		end
	end
	
	--// Draws the frame on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the frame
		--x (number, optional) - x coordinate of where to draw the frame
		--y (number, optional) - y coordinate of where to draw the frame
	function new_control:draw(dst_surface, x, y)
		if is_visible then surface:draw(dst_surface, x, y) end
	end
	
	new_control:refresh()
	
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
