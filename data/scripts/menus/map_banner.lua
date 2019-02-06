--[[ map_banner.lua
	version 0.1a1
	2 Feb 2019
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script draws the name of the current map on the the screen along with an optional
	banner (color fill). The displayed map name is a strings.dat entry with a key matching
	the part of the map_id following the last "/" character.
	
	Usage:
	local map_banner = require"scripts/menus/map_banner"
	sol.menu.start(map, map_banner)
--]]

local multi_events = require"scripts/multi_events"
local swipe_fade = require"scripts/fx/swipe_fade"

local menu = {}
multi_events:enable(menu)

--Configuration Settings
local FONT = "oceansfont_medium"
local FONT_SIZE = nil
local Y_POSITION = 64 --number of pixels away from top/bottom edge (whichever is farther away from player)
local X_POSITION = 8 --number of pixels away from left edge if positive, or right edge if negative
local GRADIENT_WIDTH = 48 --number of pixels for gradual transition to fully transparent on banner
	--use 0 for instant transition, use nil/false to have banner span full screen
local BANNER_HEIGHT = 28 --height of banner in pixels, 0 or nil/false for no banner
--local BANNER_COLOR = {0, 173, 188, 150} --blue
local BANNER_COLOR = {60, 50, 0, 100} --yellowish

--variables
local text_x, text_y
local banner_x, banner_Y

local banner_surface
local text_surface = sol.text_surface.create{
	font = FONT,
	font_size = FONT_SIZE,
	horizontal_alignment = X_POSITION >= 0 and "left" or "right",
	vertical_alignment = "middle",
}
text_surface:fade_out(0) --start not visible

local game
function menu:on_started()
	game = sol.main.get_game()
	local map = game:get_map()
	if not map then --don't draw banner if there is not an active map
		sol.menu.stop(self)
		return
	end
	
	local hero = map:get_hero()
	local camera = map:get_camera()
	local map_id = map:get_id()
	local map_name = map_id:match"^.+%/(.*)$" or map_id
	
	--set map name text
	map_name = sol.language.get_string("location."..map_name)
	
	--local map_name = "Ballast Harbor" --TODO
	if not map_name then --don't draw banner if there isn't a string.dat entry for the map name
		sol.menu.stop(self)
		return
	else text_surface:set_text(map_name) end
	
	
	--determine position on screen
	local _, hero_y = hero:get_position()
	local _, camera_y = camera:get_position()
	local camera_width, camera_height = camera:get_size()
	local hero_screen_y = hero_y - camera_y --hero's position on screen
	text_y = hero_screen_y >= camera_height/2 and Y_POSITION or camera_height - Y_POSITION
	text_x = X_POSITION >=0 and X_POSITION or camera_width - X_POSITION
	if BANNER_HEIGHT then banner_y = text_y - BANNER_HEIGHT/2 end
	
	--create banner
	if GRADIENT_WIDTH then --gradually make banner fully transparent at end of banner
		--create surface for banner
		local banner_width,_ = text_surface:get_size()
		local banner_main_width = banner_width + 2*math.abs(X_POSITION) --non-gradient width of banner
		banner_width = banner_main_width + GRADIENT_WIDTH
		banner_surface = sol.surface.create(banner_width, BANNER_HEIGHT) --full screen width
		
		--calculate position of banner gradient
		local x_main_start --x coordinate for start of non-gradient portion of banner
		local x_start, x_stop --x start & stop coordinates in pixels for banner gradient
		local gradient_dir --1 or -1 if banner is on left or right side of screen
		if X_POSITION >= 0 then --banner on left side of screen
			x_main_start = 0
			x_start = banner_main_width
			x_stop = banner_width
			gradient_dir = 1
			banner_x = 0 --banner starts at left edge of screen
			banner_surface:set_xy(-banner_width, 0)
		else
			x_main_start = GRADIENT_WIDTH
			x_start = GRADIENT_WIDTH
			x_stop = 1
			gradient_dir = -1
			banner_x = camera_width - banner_width --position of banner left edge to make right edge flush with right side of screen
			banner_surface:set_xy(banner_width, 0)
		end
		
		--draw banner with gradient
		banner_surface:fill_color(BANNER_COLOR, x_main_start, 0, banner_main_width, BANNER_HEIGHT) --draw non-gradient portion
		for x = x_start,x_stop,gradient_dir do
			local x_alpha = (math.abs(x_stop - x) + 1)/(GRADIENT_WIDTH + 1) --value from 0 to 1 depending on horizontal position
			local gradient_color = {
				BANNER_COLOR[1],
				BANNER_COLOR[2],
				BANNER_COLOR[3],
				math.floor(BANNER_COLOR[4]*x_alpha),
			}
			--draw 1 pixel wide segment with alpha reduced by amount proportional to position
			banner_surface:fill_color(gradient_color, x, 0, 1, BANNER_HEIGHT)
		end
	else --banner width fills entire screen with no gradient
		banner_x = 0 --banner starts at left edge of screen
		
		banner_surface = sol.surface.create(camera_width, BANNER_HEIGHT)
		banner_surface:fill_color(BANNER_COLOR)
		banner_surface:set_xy(X_POSITION>=0 and -camera_width or camera_width, 0) --start with banner offscreen then slide over
	end
	
	--callback function for closing animation
	local function fade_out_cb()
		sol.timer.start(map, 2000, function() --duration to wait before beginning fade-out
			swipe_fade:start_effect(text_surface, map, 1200)
			
			--add short delay before beginning banner fade-out
			sol.timer.start(map, 500, function()
				banner_surface:fade_out(40, function() --1240ms total
					sol.menu.stop(self)
				end)
			end)
		end)
	end
	
	--begin opening animation, wait, then begin closing animation
	if banner_surface then
		local movement = sol.movement.create"target"
		movement:set_speed(256)
		movement:set_target(0, 0)
		movement:start(banner_surface, function()
			text_surface:fade_in(20, fade_out_cb)
		end)
	else text_surface:fade_in(20, fade_out_cb) end
end

function menu:on_finished()
	text_surface:set_shader(nil) --remove shader
	text_surface:fade_out(0)
	banner_surface = nil
end

function menu:on_draw(dst_surface)
	if banner_surface then banner_surface:draw(dst_surface, banner_x, banner_y) end
	text_surface:draw(dst_surface, text_x, text_y)
end

return menu

--[[ Copyright 2019 Llamazing
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