--[[ objectives_manager.lua
	version 1.0a2
	23 Nov 2018
	GNU General Public License Version 3
	author: Llamazing

	   __   __   __   __  _____   _____________  _______
	  / /  / /  /  | /  |/  /  | /__   /_  _/  |/ / ___/
	 / /__/ /__/ & |/ , ,  / & | ,:',:'_/ // /|  / /, /
	/____/____/_/|_/_/|/|_/_/|_|_____/____/_/ |_/____/

	This script manages a list of objectives (i.e. quests) displayed in a quest log, which
	are defined in the scripts/objectives.dat data file. The objectives are accessed using
	game.objectives. The quest log menu script used to display these objectives is located
	at scripts/menus/quest_log.lua.
	
	Local variables used internally by objective object (table):
	* index (number, integer): number to determine sort order (low to high beginning at 1). Added automatically at creation
	* objective_type (string): keyword corresponding to which objective list the objective belongs to ("main" or "side")
	* dialog_id (string): id of dialogs.dat entry to use for the description and title text of this objective
		> description string comes from dialog.text and title string comes from dialog.title
	* location (string): strings.dat key to use for the location string for this objective during all phases
		(table, indexed): strings.dat key to use for the location string for each phase of the objective, where the table index corresponds to the phase
			table values of false indicate to use an empty string for the location name
	* is_done (boolean): true if all phases of objective complete
	* calc_phase (string): The current phase is determined by the value of this save game key
		(table, combo): uses a custom callback to determine the current phase
	* replace_s (table, combo, optional): a custom callback to make substitutions to the description text using strings.dat values
	* s_keys (table, indexed): values to use for $s substitutions given the current state of save game values (must be refreshed when save game values change)
	* replace_v (table, combo, optional): a custom callback to make substitutions to the description text using numeric or save game values
	* v_values (table, indexed): values to use for $v substitutions given the current state of save game values (must be refreshed when save game values change)
	* at_start (boolean, optional): if true then objective is shown in objective list at start of new game regardless of the state of save game values
	* num_phases (number, integer): The number of phases for this objective, determined by @ character count in dialog text
	* current_phase (number): current phase of the objective, false:not in player's log, 0:in log, no tasks complete, 1:first task complete, etc. done when equal to num phases
	
	Special Characters allowed in dialogs.text:
	Line beginning with '@' (ignore whitespace) - place a checkmark on this line when phase complete (one per phase)
	Line beginning with ';' (ignore whitespace) - manually sets which line the transition between phases occurs (max 1 between two @ lines); if omitted uses first blank line
	Line beginning with '?' (ignore whitespace) - hidden objective that is not revealed until task is complete
	Line beginning with '!' (ignore whitespace) - minor objective that is only shown during that phase (hidden before and after)
	Line beginning with '#' (ignore whitespace) - persistent descriptor that is visible every phase (and doesn't get greyed out until all quest objectives finished)
	Line beginning with '#!' (ignore whitespace) - Behaves like '#' in that it is shown from the start but will be hidden after passing that phase
	Line can begin with '@?' or '@!' and has same behavior as '?' and '!' respectively but adds checkmark on that line
	
	Determining which phase(s) description text from a quest will be visible:
	A quest can be comprised of multiple phases (subtasks), where the number of lines that
	begin with '@' in the dialog.dat text determines the number of phases. When the player
	has not received a quest, the phase will be false. Otherwise it is equal to the number
	of subtasks that the player has completed for that quest.
	
	When the player first starts a quest, the description text only reveals the lines that
	correspond up through the first phase, which is determined by the first line beginning
	with '@', including up to the first empty line. Upon completion of the fist task, more
	lines of text will be revealed, up to the first empty line following the next instance
	of a line that begins with '@'. A checkmark will also be placed on the line containing
	the first '@' with the text greyed out signifying that the first task is now complete.
	
	Certain special characters placed at the beginning of a line can influence whether the
	line will be visible or not. Whitespace is ignored when considering whether they occur
	at the beginning of a line or not. Any tab characters are removed from the description
	text, but spaces remain and can be used to indent the text of a line. This also allows
	for special characters at the beginning of a line to be followed by a tab character so
	that their text lines up with lines that begin with a tab but no special characters.
	
	Variable Substitution:
	'$v1' through '$v9' can appear in dialogs.text (multiple instances allowed) and can be
	used for the substitution of a numerical value or savegame variable (no translation is
	needed). For more info see replace_v in scripts/objectives.dat.
	
	'$s1' through '$s9' can appear in dialogs.text (multiple instances allowed) and can be
	used for the substitution of a strings.dat string (where translation is required). For
	more info see replace_s in scripts/objectives.dat.
	
	Note that $s substitutions are performed before $v substitutions, so it is possible to
	have $s make a substitution whose text includes $v, which will again be substituted.
]]
local objectives_manager = {}

--// Creates an objectives manager to create & update list of objectives, accessible through game.objectives
	--game: game datatype for the current game
	--no return value
function objectives_manager.create(game)
	local objectives = {} --contains functions to manage objectives, access using game.objectives
	
	local objectives_list = { --index table, master list of all objectives
		main={completed_count=0}, --main quest list
		side={completed_count=0}, --side quest list
	} 
	local save_val_list = {} --list of save values that when changed will cause the objectives to be refreshed
	local ids = {} --list of dialog_ids as keys and corresponding objective as value -- no duplicate ids allowed
	
	local is_new_task = false --if new task available in quest log then is true
	--set to false using objective_manager:clear_new_tasks() when quest log is opened
	
	--// Cycles through all objectives and updates list of NPCs related to an active objective
	--call this after refreshing an objective, also called after initialization
	local active_npcs = {}
	local function refresh_npcs()
		active_npcs = {}
		for _,sub_list in pairs(objectives_list) do
			for _,objective in ipairs(sub_list) do
				if objective:is_active() and not objective:is_done() then --TODO remove is_active if decide to add icon for NPCs that give quest
					local npc = objective:get_active_npc()
					if npc then active_npcs[npc] = true end
				end
			end
		end
	end
	
	
	--## Load Objectives Data File ##--
	
	--// Loads a data file and creates new objectives for each entry
	--see scripts/objectives.dat for info on the data file format
		--file (string, optional) - file path of the data file to load
			--default: "scripts/objectives.dat"
	function objectives:load_data(file)
		local file = file or "scripts/objectives.dat"
		assert(type(file)=="string", "Bad argument #1 to 'load_data' (string or nil expected)")
		
		--how to parse the data file
		local env = {}
		function env.print(...) print(...) end --DEBUG
		setmetatable(env, { __index = function(_, name)
			if objectives_list[name] then
				return function(properties) objectives:add_objective(properties, name) end
			else return function() end end --ignore anything else
		end})
	
		--load objectives.dat data file and save in objectives_list
		local chunk = sol.main.load_file(file)
		assert(chunk, "Unable to load file: "..file)
		setfenv(chunk, env)
		chunk()
	end
	
	--// Creates new objective from properties table, validating data, then adds to objectives_list
		--properties (table): key/value table describing objective characteristics (see scripts/objectives.dat)
		--objective_type (string): keyword for which objective list to add it to ("main" or "side")
		--returns newly created objective object (table)
	--// List of local variables accessible by new objective object:
		--objective_type (string) - keyword for which objective list it belongs to ("main" or "side")
		--save_vals (table) - key/value table of all savegame variable names (string) that affect this objective
		--dialog_id (string) - id of the dialogs.dat dialog tu use for the title and description text
		--calc_phase (string or table)
			--(table) - contains list of savgame variable names and a callback function to receive their current values
			--(string) - name of savegame variable to use as the value of the current phase
		--location (string or table)
		--npc_ids (table)
		--at_start (boolean)
		--replace_s (table or nil)
		--replace_v (table or nil)
		--checkmarks (table or nil)
		--num_phases (number) - number of phases (lines beginning with @ in desc text) for this objective
		--index (number) the master index of this objective
	--Refreshed whenever savegame variables updated:
		--is_done (boolean) - true when all quest subtasks are complete
		--current_phase (number or nil/false) - current phase of the quest
		--s_keys (table) - table of strings.dat keys for variable substitution of $s1-$s9
		--v_values (table) - table of values for variable substitution of $v1-$v9
		--checkmark_states (table) - table of state values for dynamic checkmarks $@1-$@9
	function objectives:add_objective(properties, objective_type)
		assert(type(properties)=="table", "Bad argument #1 to 'add_objective' (table expected)")
		assert(type(objective_type)=="string", "Bad argument #2 to 'add_objective' (string expected)")
		local objective_type = objective_type --type (string): keyword for which objective list it belongs to ("main" or "side")
		
		local full_list = objectives_list[objective_type] --convenience
		assert(full_list, "Bad argument #2 to 'add_objective', invalid objective type: "..objective_type)
		
		
		--## Create new objective from properties table ##--
		
		local new_objective = {} --key/value table containing objective data
		local save_vals = {} --key/value table of all savegame variable names (string) that affect this objective
		
		--dialog (string): dialogs.dat key for title and description of this objective
		local dialog_id = properties.dialog_id
		assert(type(dialog_id)=="string", "Bad property dialog_id to 'add_objective' (string expected)")
		assert(not ids[dialog_id], "Bad property dialog_id to 'add_objective' (2 objectives cannot have the same id)")
		local dialog = sol.language.get_dialog(dialog_id)
		assert(dialog, "Bad property dialog to 'add_objective', dialogs.dat id not found: "..dialog_id)
		ids[dialog_id] = new_objective
		
		--calc_phase (string): save value key or (table): contains save value keys and callback function (see scripts/objectives.dat)
		local calc_phase = properties.calc_phase
		assert(type(calc_phase)=="string" or type(calc_phase)=="table",
			"Bad property calc_phase to 'add_objective' (string or table expected)"
		)
		
		if type(calc_phase)=="table" then
			assert(type(properties.calc_phase.callback)=="function",
				"Bad property calc_phase to 'add_objective' (function expected for calc_phase table key 'callback')"
			)
			for i,save_key in ipairs(properties.calc_phase) do
				assert(type(save_key)=="string", "Bad property calc_phase to 'add_objective' (string expected for index "..i..")")
				save_vals[save_key] = true
			end
		else save_vals[calc_phase] = true end
		
		--location (table or string, optional): indexed table containing strings.dat values for the location name at each phase, or all phases if string (see scripts/objectives.dat)
		--[[		--table index with value of true repeats the location of the previous phase (true not allowed for index 1)
				--to omit the location, use an empty string for the value --TODO probably better to use false instead
			--(string, optional): passing a string value uses that location name for all phases
			--if omitted then location is not displayed in quest log during all phases]] --TODO Move to objectives.dat
		local location = properties.location or {}
		assert(type(location)=="table" or type(location)=="string",
			"Bad property location to 'add_objective' (table or string or nil expected)"
		)
		
		--verify table entries and substitute values for true
		if loc_type=="table" then
			for _,loc in ipairs(location) do
				assert(not loc or type(loc)=="string", "Bad property location to 'add_objective' (table values must be a string or nil/false)")
				assert(sol.language.get_string(loc), "Bad property location to 'add_objective', invalid string.dat key: "..loc)
			end
		end
		
		--npc_ids (table): list of NPC to add icon above head for each phase of quest
		local npc_ids = properties.npc or {}
		assert(type(npc_ids)=="table", "Bad property npc to 'add_objective' (table or nil expected)")
		for _,npc in ipairs(npc_ids) do
			assert(not npc or type(npc)=="string", "Bad property npc to 'add_objective' (string or nil expected as table values)")
		end
		
		--show_at_start (boolean, optional): set to true to show in quest log at start of new game (default false)
		local at_start = properties.show_at_start or false
		assert(type(at_start)=="boolean", "Bad property show_at_start to 'add_objective' (boolean or nil expected)")
		
		--replace_s (table, optional): table of save val keys and callback function to perform string substitution on desc string
		local replace_s = properties.replace_s
		assert(not replace_s or type(replace_s)=="table", "Bad property replace_s to 'add_objective' (table or nil expected)")
		if replace_s then --is table
			assert(type(replace_s.callback)=="function",
				"Bad property replace_s to 'add_objective' (function expected for replace_s table key 'callback')"
			)
			for i,save_val in ipairs(replace_s) do
				assert(type(save_val)=="string", "Bad property replace_s to 'add_objective' (string expected for index "..i..")")
				save_vals[save_val] = true
			end
		end
		
		--replace_v (table, optional): table of save val keys and callback function to perform value substitution on desc string
		local replace_v = properties.replace_v
		assert(not replace_v or type(replace_v)=="table", "Bad property replace_v to 'add_objective' (table or nil expected)")
		if replace_v then --is table
			assert(not replace_v.callback or type(replace_v.callback)=="function",
				"Bad property replace_v to 'add_objective' (function or nil expected for replace_v table key 'callback')"
			)
			for i,save_val in ipairs(replace_v) do
				assert(type(save_val)=="string", "Bad property replace_v to 'add_objective' (string expected for index "..i..")")
				save_vals[save_val] = true
			end
		end
		
		--checkmarks (table, optional): table of save val keys and callback function to determine state of dynamic checkmarks
		local checkmarks = properties.checkmarks
		assert(not checkmarks or type(checkmarks)=="table", "Bad property checkmarks to 'add_objective' (table or nil expected)")
		if checkmarks then --is table
			assert(type(checkmarks.callback)=="function",
				"Bad property checkmarks to 'add_objective' (function expected for checkmarks table key 'callback')"
			)
			for i,save_val in ipairs(checkmarks) do
				assert(type(save_val)=="string", "Bad property checkmarks to 'add_objective' (string expected for index "..i..")")
				save_vals[save_val] = true
			end
		end
		
		--add save vals to master save_val_list
		for save_val,_ in pairs(save_vals) do
			if not save_val_list[save_val] then save_val_list[save_val] = {} end
			
			table.insert(save_val_list[save_val], new_objective)
		end
		
		--determine number of phases
		local num_phases = 0
		local desc_text = "\n"..dialog.text
		for _ in desc_text:gmatch"[\n\r]%s*(%@)" do --find each line beginning with @ (excluding leading whitespace)
			num_phases = num_phases + 1
		end
		num_phases = math.max(num_phases, 1) --must have at least one phase
		desc_text = nil --don't keep, outdated when language changed
		
		--add new_objective to master list
		local index = #full_list + 1 --assign index to keep track of sort order
		table.insert(full_list, new_objective)
		
		local is_done, current_phase, s_keys, v_values, checkmark_states, active_npc --update on refresh
		dialog = nil --don't keep, outdated when language changed
		
		
		--## Accessor Functions ##--
		
		--// Updates objective based on the current state of save game values
			--objective (table): the objective to be refreshed
			--returns true phase changed, false if no change, and nil if skips refresh because quest was already complete
		function new_objective:refresh()
			local prev_phase = current_phase --save old value before it is updated
			
			if not is_done then --note: value of is_done has not been updated yet, assumes quest won't ever go from done back to not done
				--determine current phase
				if type(calc_phase)=="string" then
					current_phase = tonumber(game:get_value(calc_phase))
				else --is table
					local values = {} --list of values obtained from save game variables
					for i,save_val in ipairs(calc_phase) do
						values[i] = game:get_value(save_val) --may be nil
					end
					
					--add special values to table (as key/value pairs) that can be accessed from callback
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					--current phase not available here because the return of the callback function is what determines it
					
					current_phase = tonumber(calc_phase.callback(values))
				end
				
				--generate substitution string keys
				if replace_s then
					local values = {} --list of values obtained from save game variables
					
					--get values for save game variables and store in indexed table to be passed to callback function
					for i,save_val in ipairs(replace_s) do
						values[i] = game:get_value(save_val) --may be nil
					end
					
					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key() --TODO this should always be a string, currently gives table
				
					s_keys = replace_s.callback(values) --list of strings.dat keys for substitution
					assert(type(s_keys)=="table", "Bad return value from replace_s callback in 'refresh' (table expected)")
				else s_keys = false end --no values to substitute
			
				--generate substitution values
				if replace_v then
					local values = {} --list of values obtained from save game variables
					
					--get values for save game variables and store in indexed table to be passed to callback function
					for i,save_val in ipairs(replace_v) do
						values[i] = game:get_value(save_val) --may be nil
					end
					
					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key()
					
					if replace_v.callback then --use callback function if it exists
						v_values = replace_v.callback(values) --list of numeric values for substitution
						assert(type(v_values)=="table", "Bad return value from replace_v callback in 'refresh' (table expected)")
					else v_values = values end --use game save vals directly
				else v_values = false end --no values to substitute
				
				--generate substitution string keys
				if checkmarks then
					local values = {} --list of values obtained from save game variables
					
					--get values for save game variables and store in indexed table to be passed to callback function
					for i,save_val in ipairs(checkmarks) do
						values[i] = game:get_value(save_val) --may be nil
					end
					
					--add special values to table (as key/value pairs) that can be accessed from callback
					values.phase = current_phase
					values.num_phases = num_phases
					values.location_key = self:get_location_key() --TODO this should always be a string, currently gives table
				
					checkmark_states = checkmarks.callback(values) --list of strings.dat keys for substitution
					assert(type(checkmark_states)=="table", "Bad return value from checkmarks callback in 'refresh' (table expected)")
				else checkmark_states = false end --no values to substitute
				
				if current_phase and current_phase >= num_phases then
					is_done = true
					--increment completed count, must only happen one time max per objective
					full_list.completed_count = full_list.completed_count + 1
				else is_done = false end
			else return end --if objective is already done then nothing to refresh
			
			if current_phase and not is_done then
				active_npc = npc_ids[current_phase + 1]
			else active_npc = false end
			
			return prev_phase~=current_phase
		end
		
		--// Returns a string of the title of the objective localized in the current language
		function new_objective:get_title()
			 return sol.language.get_dialog(dialog_id).title or ""
		end
		
		--// Returns a string localized in current language representing the location of the objective for the current phase
			--phase (number, index, optional) - manually force the phase to be shown (for debugging)
		function new_objective:get_location(phase)
			local location = self:get_location_key(phase) --may be false
			if location then
				return sol.language.get_string(location) or ""
			else return "" end
		end
		
		function new_objective:get_location_key(phase)
			if type(location)=="string" then
				return location
			elseif type(location)=="table" then
				if not current_phase then return false end --quest has not started
				
				local phase = tonumber(phase)
				if phase then
					phase = math.floor(phase)
				else phase = current_phase end
				
				local location_key
				if phase>=num_phases then
					location_key = location[phase] --when done continues to display last location
				else location_key = location[phase + 1] end
				
				if location_key then --value is a string
					return location_key
				else return false end
			else return false end
		end
		
		--// Returns NPC id string for the current phase
			--phase (number, index, optional) - use the specified phase instead of the current phase (for debugging)
		function new_objective:get_npc_id(phase)
			local phase = tonumber(phase)
			if phase then
				phase = math.floor(phase)
			else phase = current_phase end
			
			if not phase then return false end --quest has not started
			--TODO add icon above head of NPC that will give the quest?
			
			if phase>=num_phases then return false end --no npc when quest is done
			return npc_ids[phase + 1] or false
		end
		function new_objective:get_active_npc() return active_npc end
		
		--// Custom iterator to get $s strings.dat keys for current variable substitution values (does not expose internal table)
			--usage: for i,str_key in new_objective:iter_s_keys() do
		function new_objective:iter_s_keys()
			local iter,_,start_val = ipairs(s_keys)
			return function(_,i) return iter(s_keys, i) end, {}, start_val
		end
		
		--// Custom iterator to get $v values for current variable substitution values (does not expose internal table)
			--usage: for i,str_key in new_objective:iter_v_values() do
		function new_objective:iter_v_values()
			local iter,_,start_val = ipairs(v_values)
			return function(_,i) return iter(v_values, i) end, {}, start_val
		end
		
		--// Custom iterator to get $@ states for dynamic checkmarks (does not expose internal table)
			--usage: for i,state in new_objective:iter_checkmarks() do
		function new_objective:iter_checkmarks()
			local iter,_,start_val = ipairs(checkmark_states)
			return function(_,i) return iter(checkmark_states, i) end, {}, start_val
		end
		
		--handling rules based on up to two first special characters of a line
		local SPECIAL_CHARSET = "#%?!@;"
		local SPECIAL_VISIBLE = "#%?!" --These special characters determine whether line is visible in a given phase; include % escape char where applicable
		local IGNORE_CHARSET = "%s@;" --These characters are ignored because they do not affect visibility; include % escape char where applicable
		local SPECIAL_CHAR_VISIBILITY = { --conditions for whether a line is visible based on the first two special characters (order matters!)
			--rank (number): assigned to each line, incrementing based on where @ and blank lines occur
			--phase (number): current phase for a given objective (equal to number of subtasks completed)
			--returns true if the line should be visible for a given phase based on its rank
			['#'] = function(rank, phase) return true end, --visible for every phase
			[''] = function(rank, phase) return phase >= rank end,
			['!'] = function(rank, phase) return phase == rank end,
			['?'] = function(rank, phase) return phase > rank end,
			['#!'] = function(rank, phase) return phase <= rank end,
			['?!'] = function(rank, phase) return false end, --never visible
		} --do not include % escape char
		SPECIAL_CHAR_VISIBILITY['##'] = SPECIAL_CHAR_VISIBILITY['#'] --visibility behavior is the same (coloring is not)
		SPECIAL_CHAR_VISIBILITY['!?'] = SPECIAL_CHAR_VISIBILITY['?!'] --allow reverse order
		SPECIAL_CHAR_VISIBILITY.default = SPECIAL_CHAR_VISIBILITY['']
		
		--// Returns indexed table with entry for each line of description from dialogs.dat
			--phase (number, optional) specifies phase to use when determining which subtasks are complete (for debugging)
				--use nil to use the in-game current phase as determined by current state of savegame_variables
			--subs_s (table, indexed) list of substitutions to make for $s1-$s9 (for debugging)
				--use nil to use the normal substitutions as determined by in-game logic
			--subs_v (table, indexed) list of substitutions to make for $v1-$v9 (for debugging)
				--use nil to use the normal substitutions as determined by in-game logic
		--//Each entry of returned table contains the following key/values:
			--text (string): line of text localized for current language
			--is_active (boolean): false indicates the text should be greyed out because the player has already completed that task
			--is_check (boolean): true indicates that this line begins with @ for a checkmark
				--note the checkmark should only be shown if is_active also is false
			--rank (number): internal use only
			--is_visible (boolean): internal use only (will be true for all)
			--is_persistent (boolean): true if line begins with # (also true for #!)
			--do_not_grey (boolean): internal use only, true if always is_active (unless quest is done, then false)
			--note: lines that are not visible are omitted
		function new_objective:get_description(phase, subs_s, subs_v, subs_check)
			if phase then
				phase = tonumber(phase)
				assert(phase, "Bad argument #1 to 'get_description' (number or nil expected)")
			else phase = current_phase or 0 end --ensure number if equal to false (quest not yet given to player)
			--TODO should lines be visible if player hasn't received quest yet?
			
			assert(not subs_s or type(subs_s)=="table", "Bad argument #2 to 'get_description' (table or nil expected)")
			assert(not subs_v or type(subs_v)=="table", "Bad argument #3 to 'get_description' (table or nil expected)")
			assert(not subs_check or type(subs_check)=="table", "Bad argument #4 to 'get_description' (table or nil expected)")
			
			--use specified substitution valies if provided (for debugging)
			--otherwise use normal substitutions determined based on current state of savegame variables
			subs_s = subs_s or s_keys or {}
			subs_v = subs_v or v_values or {}
			subs_check = subs_check or checkmark_states or {}
			
			local dialog = sol.language.get_dialog(dialog_id) --dialog.text is desc text, dialog.title is title
			--strip out tab characters and standardize all line breaks to '\n'
			local desc_text = dialog.text:gsub("\t", ""):gsub("\r\n", "\n"):gsub("\r","\n")
			
			--perform $s substitutions (text values from strings.dat)
			--note performed first because may substitute for text containing $v needing additional substitution(s)
			for i=1,9 do
				local sub_text = subs_s[i] and sol.language.get_string(subs_s[i]) or "" --get strings.dat text
				desc_text = desc_text:gsub("%$s"..i, tostring(sub_text))
			end
			
			--perform $v substitutions (numerical values or from save game variables)
			for i=1,9 do
				--TODO convert values of true to empty string?
				local sub_text = tostring(subs_v[i] or "")
				desc_text = desc_text:gsub("%$v"..i, sub_text)
			end
			
			local phase_breaks = {} --list of line indicies where phase break occurs
			local look_for_next_break = false --while true, finding a ; or beginning with @ will cause a phase break
			local first_line_break --line where first blank line after line beginning with @ occurs
				--need to remember this retroactively in case no beginning ; found between lines with @
			
			--get description text line by line and find phase breaks (first pass)
			local lines = {} --includes invisible lines
			
			for line in desc_text:gmatch"([^\n]*)\n" do --each line including including empty ones
				local check_index --which dynamic checkmark index the line is associated with (e.g. $@5 is index of 5, as is $5)
				
				local check_position = line:find"%$@%d"
				if check_position then --has dynamic checkmark on this line
					check_index = tonumber(line:match"%$@(%d)")
				else check_index = tonumber(line:match"%$(%d)") end --only look of $1-$9 instances if no dynamic checkmark on the line
				
				--ignore index values of zero
				if check_index==0 then
					check_index = nil
					check_position = nil
				end
				
				--strip out dynamic checkmark characters now that info is saved
				for i=1,9 do line = line:gsub("%$@"..i, " "):gsub("%$"..i, "") end
				
				--create string for current line stripped of comments and leading special characters
				local stripped_text = line:match"^(.-)%-%-//" or line --remove comments
				local search_pattern = "^%s*["..SPECIAL_CHARSET.."]["..SPECIAL_CHARSET
					.."]?["..SPECIAL_CHARSET.."]?(.*)" --only want to remove leading whitespace if there is at least one special char
				stripped_text = stripped_text:match(search_pattern) or stripped_text
				
				local entry = {
					line=line, text=stripped_text,
					check_index=check_index, check_position=check_position,
				}
				table.insert(lines, entry)
				
				entry.is_check = not not line:match"^%s*@" --line begins with @ (has checkmark)
				entry.is_persistent = not not line:match"^%s*[@;]?#" --line beginning with # (always active/visible)
				entry.do_not_grey = not not line:match"^%s*[;]?##" --line must begin with ## in order to not be greyed out
				local is_empty = line:match"^%s*$" --non-nil if line contains entirely whitespace (no special chars or comments either)
				local is_phase_break = line:match"^%s*;" --line begins with ;
				
				if look_for_next_break then --search for first ; or first empty line or @
					if is_empty then
						if not first_line_break then first_line_break = #lines end
						--look_for_next_break = false
					elseif is_phase_break then
						phase_breaks[#lines] = true
						look_for_next_break = false
						first_line_break = nil --ignore first line break because ; overrides
					elseif entry.is_check then --line begins with @
						if first_line_break then --found an empty line between here and last @
							phase_breaks[first_line_break] = true --set break where empty line occurred
						else phase_breaks[#lines] = true end --set break on this line
						
						first_line_break = nil --reset for stretch up to next @
						look_for_next_break = true
					end
				elseif entry.is_check then look_for_next_break = true end --only look for @ now
			end
			
			local visible_lines = {}
			
			--second pass: determine visibility of each line based on its rank and the current phase
			local rank = 0
			for i,entry in ipairs(lines) do
				--determine rank of current line
				if phase_breaks[i] then rank = rank + 1 end
				entry.rank = rank
				
				--determine visibility	"^[%s@;]*([#%?!]*)"
				local special_chars = entry.line:match("^["..IGNORE_CHARSET.."]*(["..SPECIAL_VISIBLE.."]*)")
				if special_chars then special_chars:sub(1,3) end --only care about the first (up to) 3 special chars
				local visibility = SPECIAL_CHAR_VISIBILITY[special_chars] or SPECIAL_CHAR_VISIBILITY.default --lookup function to use
				entry.is_visible = visibility(rank, phase)
				
				if entry.is_visible then --don't bother with the rest if not visible
					if phase<num_phases then --quest not done
						local primary_is_active = entry.do_not_grey or not (phase>rank) --persistent lines never grey
						local primary_is_grey = not entry.do_not_grey and (phase>rank) --persistent lines never grey
						local dynamic_is_active = subs_check[entry.check_index]
						local dynamic_is_grey = subs_check[entry.check_index] or false
						if entry.check_index then
							entry.is_active = primary_is_active and dynamic_is_active or false
							entry.is_grey = primary_is_grey or dynamic_is_grey 
						else entry.is_active = primary_is_active entry.is_grey = primary_is_grey end
						
						if entry.check_position then
							if dynamic_is_grey then
								entry.check_state = "checkmark"
							elseif dynamic_is_active==false then
								entry.check_state = "bullet"
							end --else entry.check_state is implicitly nil
						end --else entry.check_state is implicitly nil
					else entry.is_active = false entry.is_grey = true end --always grey out text if quest is done
					
					table.insert(visible_lines, entry)
				end
			end
			
			return visible_lines
		end
		
		--// Returns number (or false) representing the current phase of the objective
			--false:the player hasn't started the quest
			--0:player has the quest in their log but has not completed any subtasks
			--1+:the player has completed this many subtasks
			--the quest is considered complete when the current phase is equal to the number of phases
		function new_objective:get_current_phase() return current_phase end
		
		--// Returns the number of phases (number) for the objective
		function new_objective:get_num_phases() return num_phases end
		
		--Returns boolean that is true if the player has started the quest but is not yet complete
		function new_objective:is_active()
			return current_phase and current_phase < num_phases
		end
		
		--Returns boolean that is true if the quest is complete (all objectives finished)
		function new_objective:is_done() return is_done end
		
		--Returns index (number, integer) corresponding to sort order
		function new_objective:get_index() return index end
		
		new_objective:refresh()
		
		return new_objective
	end
	
	
	--## Objectives Manager Functions ##--
	
	--// Refreshes only objectives influenced by the specified save game value
		--savegame_value (string, optional): name of save game value that has changed value
			--if nil then refreshes all objectives
		--no return value
	function objectives:refresh(savegame_value)
		local is_update = false --tentative
		
		if savegame_value then
			assert(type(savegame_value)=="string", "Bad argument #1 to 'refresh' (string expected)")
			local value = game:get_value(savegame_value, value)
			
			local to_refresh = save_val_list[savegame_value] or {}
			for _,objective in ipairs(to_refresh) do
				local is_new = objective:refresh()
				is_update = is_new or is_update
			end
		else --else have to refresh ALL objectives
			for _,sub_list in pairs(objectives_list) do
				for _,objective in ipairs(sub_list) do
					is_update = objective:refresh() or is_update
				end
			end
		end
		
		if is_update then --at least one objective advanced the phase
			is_new_task = true
			
			refresh_npcs() --update list of active npcs
			
			if self.on_new_task then self:on_new_task() end --call event if it exists
			--TODO play sound for task updated
		end
	end
	
	--// Custom iterator to get entity names of active npcs (does not expose internal table)
		--usage: for npc_name in objectives:active_npcs() do
	function objectives:active_npcs()
		return function(_, key) return next(active_npcs,key) end, {}
	end
	--// Returns true if the NPC with the specified entity name is active
	function objectives:is_npc_active(name) return active_npcs[name] or false end
	
	--// Returns indexed table of active objectives followed by completed objectives.
	--// The order of the returned list matches the order defined in objectives.dat
		--objective_type (string) keyword corresponding to the objective list to use
	function objectives:get_objectives_list(objective_type)
		assert(type(objective_type)=="string", "Bad argument #1 to 'get_objectives_list' (string expected)")
		local full_list = objectives_list[objective_type] --convenience
		assert(full_list, "Bad argument #1 to 'get_objectives_list', invalid type: "..objective_type)
		
		local sorted_list = {} --list to be returned
		
		--add active objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective.is_active() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end
		
		--add completed objectives to sorted_list
		for _,objective in ipairs(full_list) do
			if objective.is_done() then
				table.insert(sorted_list, objective)
				sorted_list[tostring(objective:get_index())] = #sorted_list --reverse lookup
			end
		end
		
		return sorted_list
	end
	
	--// Returns an objective object matching the specified dialogs.dat id string
		-- id (string) - dialogs.dat id to identify the objective to be returned
		-- (table) - objective object matching the specified id
	function objectives:get_objective(id)
		assert(type(id)=="string", "Bad argument #1 to 'get_objective' (string expected)")
		local objective = ids[id]
		assert(objective, "Bad argument #1 to 'get_objective' (no objective found with id: "..id)
		
		return objective
	end
	
	--// objective_type (string): keyword for which objective list to use ("main" or "side") 
	--// Returns 2 numbers: number of completed quests and total quests from the list corresponding to objective_type
	--TODO need smarter total count calculation once alternate objectives are implemented
	function objectives:get_counts(objective_type)
		assert(type(objective_type)=="string", "Bad argument #1 to 'get_counts' (string expected)")
		local full_list = objectives_list[objective_type] --convenience
		assert(full_list, "Bad argument #1 to 'get_counts', invalid type: "..objective_type)
		
		return full_list.completed_count, #full_list
	end
	
	function objectives:is_new_task() return is_new_task end
	function objectives:clear_new_tasks() is_new_task = false end
	
	--// Hook API game:set_value function to be notified whenever savegame variables are updated
	--refresh objectives whenever a save game value is set
	local game_set_value_old = game.set_value
	function game.set_value(self, savegame_value, value, ...)
		--intermediate function so that game:set_value() is called first, followed by refresh while still capturing all return values
		local function do_refresh(savegame_value, ...)
			objectives:refresh(savegame_value)
			return ...
		end
		
		return do_refresh(savegame_value, game_set_value_old(self, savegame_value, value, ...))
	end
	
	objectives:load_data() --load objectives from objectives.dat
	refresh_npcs() --update list of active npcs
	
	game.objectives = objectives --any script that can access game can access the objectives
end

return objectives_manager

--[[ Copyright 2018 Llamazing
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