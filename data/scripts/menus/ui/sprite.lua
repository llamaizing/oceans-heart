--[[ sprite.lua
	version 1.0a1
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates an ui subcomponent created from a sprite entity that is drawn onto
	a destination surface. It is possible for the sprite have multiple frames and animate.
]]

local util = require"scripts/menus/ui/util"

local control = {}

--// Creates a new image control
	--properties (table) - table containing properties defining image behavior
		--sprite (string) - id of the sprite to use
		--animation (string) - id of the animation for the sprite
	--returns the newly created image object (table)
function control.create(properties)
	local new_control = {}
	
	assert(type(properties)=="table", "Bad argument #1 to 'create' (table expected)")
	
	local sprite_id = properties.sprite
	assert(type(sprite_id)=="string", "Bad property sprite_id to 'create' (string expected)")
	local sprite = sol.sprite.create(sprite_id)
	assert(sprite, "Error in 'create', sprite cannot be found: "..sprite_id)
	
	local animation_id = properties.animation
	assert(not animation_id or type(animation_id)=="string", "Bad property animation_id to 'create' (string expected)")
	if animation_id then sprite:set_animation(animation_id) end
	
	local is_enabled = true --enabled by default
	local is_visible = true --visible by default
	
	--// Returns the width and height (number) of the image in pixels
	function new_control:get_size() return sprite:get_size() end
	
	--// Returns the path (string) of the source image file
	function new_control:get_sprite_id() return sprite_id end
	
	--// Get/set whether the sprite is enabled, which uses a different animation when disabled
		--value (boolean) - if true then the sprite is enabled
	function new_control:get_enabled() return is_enabled end
	function new_control:set_enabled(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_enabled' (boolean expected)")
		is_enabled = value
		sprite:set_animation(value and "enabled" or "disabled")
	end
	
	--// Get/set whether the image is visible (newly created images are visible by default)
		--value (boolean) - if true then the image is visible
	function new_control:get_visible() return is_visible end
	function new_control:set_visible(value)
		assert(type(value)=="boolean", "Bad argument #1 to 'set_visible' (boolean expected)")
		is_visible = value
	end
	
	--// Get/set the blend mode of the surface used by the sprite
	function new_control:get_blend_mode() return sprite:get_blend_mode() end
	function new_control:set_blend_mode(value) sprite:set_blend_mode(value) end
	
	--// Start a fade in or fade out of the surface used by the sprite
	function new_control:fade_in(delay, callback) return sprite:fade_in(delay, callback) end
	function new_control:fade_out(delay, callback) return sprite:fade_out(delay, callback) end
	
	--// Get/set the offset of the surface used by the sprite
	function new_control:get_xy() return sprite:get_xy() end
	function new_control:set_xy(x, y) return sprite:set_xy(x, y) end
	
	--// Get/stop the current movement of the surface used by the frame
	function new_control:get_movement() return sprite:get_movement() end
	function new_control:start_movement(movement, callback) movement:start(sprite, callback) end
	function new_control:stop_movement() return sprite:stop_movement() end
	
	--// Draws the image on the specified destination surface
		--dst_surface (sol.surface) - surface on which to draw the image
		--x (number, optional) - x coordinate of where to draw the image
		--y (number, optional) - y coordinate of where to draw the image
	function new_control:draw(dst_surface, x, y)
		if is_visible then sprite:draw(dst_surface, x, y) end
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
