--[[ path_movement.lua
	version 0.1a1
	26 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script creates a path movement for a sprite. Unlike sol.movement of type path, it
	allows for movements in single pixel increments.	
]]

local LOOP_TYPES = {
	['repeat'] = true,
	['reverse'] = true,
}

local path_movement = {}

--//
	--properties (table, key/value)
		--context
		--path (table, array) --values > 10 are delay in msec
		--speed (number)
		--loop
	-- if object is specified then start immediately, else ignore the rest
		--object
		--x
		--y
		--callback
function path_movement.create(properties)
	local movement = {}
	local object
	local x, y
	local inv_speed --msec / pixel
	local direction
	local timer
	local path = {} --(table, array)
	local index
	local loop = false
	
	function movement:start(object_to_move, callback)
		
	end
	
	function movement:stop()
		
	end
	
	function movement:get_xy()
		if object then
			if object.get_xy then
				return object:get_xy()
			elseif object.x and object.y then
				return object.x, object.y
			end
		end
	end
	
	function movement:set_xy(x, y)
		if object then
			if not object.set_xy then
				object.x = x
				object.y = y
			else object:set_xy(x, y) end
		end
	end
	
	function movement:get_object() return object end
	
	function movement:is_active()
		if timer then
			return timer:get_remaining_time > 0
		else return false
	end
	
	function movement:is_suspended()
		if timer then return timer:is_suspended() end
	end
	
	function movement:set_suspended(boolean)
		if timer then timer:set_suspended() end
	end
	
	function movement:get_direction8() return direction
		return direction or (path and path[1])
	end
	
	function movement:get_path()
		local path_copy = {}
		for i,v in ipairs(path) do path_copy[i] = v end
		return path_copy
	end
	
	function movement:get_path_position()
	end
	
	function movement:set_path(new_path)
		assert(type(new_path)=="table", "Bad argument #2 to 'set_path' (table expected)")
		
		path = {}
		for i,v in ipairs(new_path) do path[i] = v end
	end
	
	function movement:get_path_count() return #path end
	
	function movement:get_speed() return 1/inv_speed/1000 end
	function movement:set_speed(new_speed)
		new_speed = tonumber(new_speed)
		assert(new_speed, "Bad argument #2 to 'set_speed' (number expected)")
		assert(new_speed>0, "Bad argument #2 to 'set_speed', number must be positive")
		
		inv_speed = 1000/new_speed
		
		--TODO adjust movement if active
	end
	
	function movement:get_loop() return loop end
	function movement:set_loop(loop_type)
		if loop_type==true or loop_type==nil then loop_type = "repeat" end
		if loop_type then
			assert(type(loop_type)=="string", "Bad argument #2 to 'set_loop' (boolean or string or nil expected)")
			assert(LOOP_TYPES[loop_type], "Bad argument #2 to 'set_loop', invalid loop type: "..loop_type)
		end
		loop = loop_type
	end
	
	return movement
end


--[[ Copyright 2019 Llamazing
	[] 
	[] This program is free software: you can redistribute it and/or modify it under the
	[] terms of the GNU General Public License as published by the Free Software Foundation,
	[] either version 3 of the License, or (at your option) any later version.
	[] 
	[] It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	[] without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
	[] PURPOSE.	See the GNU General Public License for more details.
	[] 
	[] You should have received a copy of the GNU General Public License along with this
	[] program.	If not, see <http://www.gnu.org/licenses/>.
	]]
