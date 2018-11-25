--[[ text.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/
	
	This script creates an ui subcomponent used to draw a single line of text.
]]

local util = require"scripts/menus/ui/util"

local control = {}

local ALIGNMENT_OFFSETS = {
	left = 0,
	center = 0.5,
	right = 1,
	top = 0,
	middle = 0.5,
	bottom = 1,
}

--// Creates a new text control
	--properties (table) - table containing properties defining text behavior
		--font (string)
		--font_color (string or table) - font color of the text
			--see make_RGB_color() in scripts/menus/ui/util.lua for more info
		--font_size (number)
		--horizontal_alignment (string)
		--vertical_alignment (string)
		--rendering_mode (string)
			--default: "solid"
		--text (string)
		--text_key (string)
	--width (number) - width of the text region in pixels
	--height (number) - height of the text region in pixels
	--returns the newly created text object (table)
function control.create(properties, width, height)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local width = tonumber(width)
	assert(width, "Bad argument #2 to 'create' (number expected)")
	width = math.floor(width)
	assert(width>0, "Bad argument #2 to 'create' (number must be positive)")
	
	local height = tonumber(height)
	assert(height, "Bad argument #2 to 'create' (number expected)")
	height = math.floor(height)
	assert(height>0, "Bad argument #2 to 'create' (number must be positive)")
	
	local font = properties.font
	assert(type(font)=="string", "Bad property font to 'create' (string expected)")
	
	local font_color, err = util.make_RGB_color(properties.font_color, 3) --don't allow alpha values
	assert(font_color, "Bad property font_color to 'create'"..tostring(err or ''))
	
	local font_color_disabled
	if properties.font_color_disabled then
		font_color_disabled, err = util.make_RGB_color(properties.font_color_disabled, 3) --don't allow alpha values
		assert(font_color, "Bad property font_color to 'create'"..tostring(err or ''))
	end
	
	local font_size = properties.font_size
	local font_size_num = tonumber(font_size)
	assert(font_size_num or not font_size, "Bad property font_size to 'create' (number or nil expected)")
	if font_size_num then
		font_size = font_size_num
		assert(font_size>0, "Bad property font_size to 'create' (number must be positive)")
	end
	font_size_num = nil --no longer needed
	
	local horizontal_alignment = properties.horizontal_alignment or "left"
	assert(type(horizontal_alignment)=="string", "Bad property horizontal_alignment to 'create' (string or nil expected)")
	
	local vertical_alignment = properties.vertical_alignment or "top"
	assert(type(vertical_alignment)=="string", "Bad property vertical_alignment to 'create' (string or nil expected)")
	
	local rendering_mode = properties.rendering_mode or "solid"
	assert(type(rendering_mode)=="string", "Bad property rendering_mode to 'create' (string or nil expected)")
	
	local text = properties.text or ""
	assert(type(text)=="string", "Bad property text to 'create' (string or nil expected)")
	
	local is_enabled = true --start off enabled
	local withold_refresh = false --start off disabled
	local is_visible = true --visible by default
	
	local surface = sol.surface.create(width, height)
	local text_surface = sol.text_surface.create{
		horizontal_alignment = "left",
		vertical_alignment = "top",
		font = font,
		rendering_mode = rendering_mode,
		color = font_color,
		font_size = font_size,
		text = text,
		text_key = properties.text_key,
	}
	
	--// Regenerates surface containing the drawn text
		--used internally and won't run while automatic refresh is disabled
	local function refresh()
		if not withold_refresh then
			local text_width,text_height = text_surface:get_size()
			
			surface:clear()
			
			text_surface:draw(
				surface,
				(width - text_width)*ALIGNMENT_OFFSETS[horizontal_alignment],
				(height - text_height)*ALIGNMENT_OFFSETS[vertical_alignment]
			)
		end
	end
	
	--// Get/set the font color of the text as 3 RGB values, 0 to 255
	function new_control:get_font_color() return util.make_RGB_color(color) end --returns a copy of color table
	function new_control:set_font_color(value)
		local value, err = util.make_RGB_color(value, 3)
		assert(value, "Bad argument #1 to 'set_font_color'"..tostring(err or ''))
		
		font_color = value
		if is_enabled or not font_color_disabled then
			self:set_color(font_color)
			refresh()
		end --text won't change color if it is currently disabled
	end
	
	function new_control:get_font() return text_surface:get_font() end
	function new_control:set_font(font_id)
		text_surface:set_font(font_id)
		refresh()
	end
	
	function new_control:get_font_size() return text_surface:get_font_size() end
	function new_control:set_font_size(value)
		text_surface:set_font_size(value)
		refresh()
	end
	
	function new_control:get_text() return text_surface:get_text() end
	function new_control:set_text(new_text)
		text_surface:set_text(new_text)
		refresh()
	end
	function new_control:set_text_key(key)
		text_surface:set_text_key(key)
		refresh()
	end
	
	--// Get/set whether the text is enabled, which uses a different font color when disabled
		--value (boolean) - if true then the text is enabled
	function new_control:get_enabled() return is_enabled end
	function new_control:set_enabled(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_enabled' (boolean expected)")
		
		if is_enabled ~= value then
			is_enabled = value
			
			if font_color_disabled then
				text_surface:set_color(is_enabled and font_color or font_color_disabled)
				refresh()
			end --don't bother changing color if disabled color is not defined
		end
	end
	
	--// Returns the width and height (number) of the text region in pixels
		--a value of nil indicates to use the entire width/height, respectively
	function new_control:get_size() return width, height end
	
	--// Returns the width and height (number) of the current text itself in pixels
	function new_control:get_text_size() return text_surface:get_size() end
	
	--// Get/set the opacity of the surface used by the text control
	function new_control:get_opacity() return surface:get_opacity() end
	function new_control:set_opacity(value) return surface:set_opacity(value) end
	
	--// Get/set the blend mode of the surface used by the text control
	function new_control:get_blend_mode() return surface:get_blend_mode() end
	function new_control:set_blend_mode(value) surface:set_blend_mode(value) end
	
	--// Start a fade in or fade out of the surface used by the text control
	function new_control:fade_in(delay, callback) return surface:fade_in(delay, callback) end
	function new_control:fade_out(delay, callback) return surface:fade_out(delay, callback) end
	
	--// Get/set the offset of the surface used by the text control
	function new_control:get_xy() return surface:get_xy() end
	function new_control:set_xy(x, y) return surface:set_xy(x, y) end
	
	--// Get/stop the current movement of the surface used by the text control
	function new_control:get_movement() return surface:get_movement() end
	function new_control:start_movement(movement, callback) movement:start(surface, callback) end
	function new_control:stop_movement() return surface:stop_movement() end
	
	--// Get/set whether the text control should be drawn
		--value (boolean) - text control will be drawn if true
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad arguement #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Regenerates the surface containing the text
		--This function is used to trigger a manual refresh. Calling it re-enables auto refresh
	function new_control:refresh()
		withold_refresh = false
		refresh()
	end
	
	--// Draws the text on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the text
		--x (number, optional) - x coordinate of where to draw the text
		--y (number, optional) - y coordinate of where to draw the text
	function new_control:draw(dst_surface, x, y)
		if is_visible then surface:draw(dst_surface, x, y) end
	end
	
	--// Calling this function prevents automatic refreshing until the next manual refresh
	function new_control:withold_refresh() withold_refresh = true end
	
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
