--[[ line2path.lua
	version 0.1a1
	22 Dec 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script converts a line path in a png image to a path movement path. The line path
	must contain exactly one pixel matching the start color. Then an unbroken, single line
	of pixels matching the path color leads to a pixel matching the stop color.
	
	The path is converted to a table containing a sequence of integers that corresponds to
	the direction of the movement for each pixel along the path. 0 is east, 1 NE, 2 north,
	3 NW, 4 west, 5 SW, 6 south, 7 SE.
	
	Usage:
	local line2path = require"scripts/line2path"
	line2path(file_path_to_png)
]]

return function(file_path)
	assert(type(file_path)=="string", "Bad argument #1 to 'line2path' (string expected)")
	
	--constants
	local IMG_PATH = "path_img"
	local START_COLOR = {0, 255, 0, 255} --pixel color at the beginning of the path
	local STOP_COLOR = {255, 0, 0, 255} --pixels' color along the path
	local PATH_COLOR = {0, 0, 255, 255} --pixel color at the end of the path
	local BYTES = {
		[string.char(unpack(START_COLOR))] = "start",
		[string.char(unpack(STOP_COLOR))] = "stop",
		[string.char(unpack(PATH_COLOR))] = "path",
	}
	
	local surface = sol.surface.create(file_path)
	local width, height = surface:get_size()
	local pixels = surface:get_pixels()
	local length = pixels:len()
	
	
	--## Convert pixels string bytes to table
	
	local data = {} --index = (row - 1)*(col - 1)
	local index = 0
	local start_count = 0
	local start_index
	
	for i=1,length,4 do
		local pixel_bytes = pixels:sub(i,i+3) --grabs next 4 bytes
		local marker = BYTES[pixel_bytes]
		if marker then --ignore all colors except the ones interested in
			data[index] = marker
			if marker=="start" then
				start_index = index
				start_count = start_count + 1
			end
		end
		index = index + 1
	end
	
	assert(start_count<2, string.format("Error in line2path: more than one start marker (img: %s)", file_path))
	assert(start_count>0, string.format("Error in line2path: no start marker found (img: %s)", file_path))
	
	
	--## Trace line path
	
	local seen_list = {} --list of indicies already checked
	local path = {
		x = math.floor(start_index / width) + 1,
		y = (start_index % width) + 1,
	}
	
	--// seeks and returns index of next pixel along path given current index
		--index (number, non-negative integer) - the current pixel along the path
		--return #1 (number, non-negative integer or false) - the next index along the path
			--false when the end of the path has been found
		--return #2 (number, non-negative integer) - direction to the next pixel
			--0 east, 1 NE, 2 north, 3 NW, 4 west, 5 SW, 6 south, 7 SE
			--no return if the first return is false
	local function find_next(index)
		if data[index] == "stop" then return false end --stop pixel found, end of path
		seen_list[index] = true --mark current pixel as checked
		
		local col = index % width
		local is_left = col==0
		local is_right = col==width-1
		local is_top = index<width
		local is_bottom = index>=width*(height-1)
		local tmp_index
		local next_index
		local next_dir --0 east, 1 NE, 2 north, 3 NW, 4 west, 5 SW, 6 south, 7 SE
		local next_count = 0
		
		
		--## Check non-diagonals first
		
		--check pixel above
		if not is_top then --pixel above doesn't exist if on top row
			tmp_index = index - width
			if not seen_list[tmp_index] and data[tmp_index] then --pixel above is either path or stop color
				next_index = tmp_index
				next_dir = 2
				next_count = next_count + 1
			end
		end
		
		--check pixel to right
		if not is_right then --pixel to right doesn't exist in right-most column
			tmp_index = index + 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to right is either path or stop color
				next_index = tmp_index
				next_dir = 0
				next_count = next_count + 1
			end
		end
		
		--check pixel below
		if not is_bottom then --pixel below doesn't exist if on bottom row
			tmp_index = index + width
			if not seen_list[tmp_index] and data[tmp_index] then --pixel below is either path or stop color
				next_index = tmp_index
				next_dir = 6
				next_count = next_count + 1
			end
		end
		
		--check pixel to left
		if not is_right then --pixel to left doesn't exist in left-most column
			tmp_index = index - 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to left is either path or stop color
				next_index = tmp_index
				next_dir = 4
				next_count = next_count + 1
			end
		end
		
		assert(next_count<2, string.format("Error in line2path: branching path found (img: %s)", file_path))
		if next_count==1 then return next_index, next_dir end --next pixel along path found
		
		
		--## Next pixel not found, now check diagonal pixels
		
		--check upper-left pixel
		if not is_top or not is_left then --pixel to upper-left doesn't exist if in top-left corner
			tmp_index = index - width - 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to upper-left is either path or stop color
				next_index = tmp_index
				next_dir = 3
				next_count = next_count + 1
			end
		end
		
		--check upper-right pixel
		if not is_top or not is_right then --pixel to upper-right doesn't exist if in top-right corner
			tmp_index = index - width + 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to upper-right is either path or stop color
				next_index = tmp_index
				next_dir = 1
				next_count = next_count + 1
			end
		end
		
		--check lower-right pixel
		if not is_bottom or not is_right then --pixel to lower-right doesn't exist if in bottom-right corner
			tmp_index = index + width + 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to lower-right is either path or stop color
				next_index = tmp_index
				next_dir = 7
				next_count = next_count + 1
			end
		end
		
		--check lower-left pixel
		if not is_bottom or not is_right then --pixel to lower-left doesn't exist if in bottom-left corner
			tmp_index = index + width - 1
			if not seen_list[tmp_index] and data[tmp_index] then --pixel to lower-left is either path or stop color
				next_index = tmp_index
				next_dir = 5
				next_count = next_count + 1
			end
		end
		
		assert(next_count<2, string.format("Error in line2path: branching path found (img: %s)", file_path))
		assert(next_count>0, string.format("Error in line2path: path does not end with stop marker (img: %s)", file_path))
		
		return next_index, next_dir
	end
	
	index = start_index
	local direction
	while index do
		index, direction = find_next(index)
		path[#path+1] = direction --may be nil
	end
	
	return path
end

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
