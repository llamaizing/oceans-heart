local dash_manager = {}

local MAX_MOTHS = 11
local MAGIC_COST = 0
local enough_magic

function dash_manager:dash(game)
    enough_magic = false
    if game:has_item("dandelion_charm") and game:get_magic() >= MAGIC_COST then
        enough_magic = true
        game:remove_magic(MAGIC_COST)
    end
    local hero = game:get_hero()
    local dir = hero:get_direction()
    local dd = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2} --to convert 0-4 direction to radians
    dir = dd[dir]
    local m = sol.movement.create("straight")
    m:set_angle(dir)
    if enough_magic then
        m:set_speed(250)
        m:set_max_distance(96)
    else
        m:set_speed(200)
        m:set_max_distance(64)
    end
    m:set_smooth(true)
    if enough_magic then
        hero:get_sprite():set_animation("dash", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_dashing", true)
        self:generate_moths(game)
    else
        hero:get_sprite():set_animation("roll", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_rolling", true)
    end
    if enough_magic then sol.audio.play_sound("dash")
    else sol.audio.play_sound("roll_2") end
    can_dash = false

    m:start(hero, function()
        hero:unfreeze()
        game:set_value("hero_dashing", false)
        game:set_value("hero_rolling", false)
    end)

    sol.timer.start(hero, 1000, function()
        can_dash = true
    end)

    if enough_magic then hero:set_invincible(true, 300) end

    function m:on_obstacle_reached()
        hero:unfreeze()
        sol.timer.start(hero, 800, function()
        can_dash = true
        end)
    end

    hero:register_event("on_position_changed", function()
        if game:get_value("hero_dashing") or game:get_value("hero_rolling") then
        local ground = hero:get_ground_below()
        if ground == "deep_water" or ground == "hole" or ground == "lava" then
            m:stop()
        end
        end
    end)
end


function dash_manager:generate_moths(game)
    local n = 0
    sol.timer.start(game:get_map(), math.random(20,40), function()
        local x, y, layer = game:get_hero():get_position()
        local moth = game:get_map():create_custom_entity{
        name = "dandelion_burst",
        direction = hero:get_direction(),
        layer = layer,
        x = math.random(x-8, x+8),
        y = math.random(y-8, y+8),
        width = 32,
        height = 32,
        sprite = "entities/dandelion_seed",
        model = "dash_moth"
        }
        moth:set_drawn_in_y_order(true)
        n = n + 1
        if n <= MAX_MOTHS then return true end
--        if game:get_value("hero_dashing") then return true end
    end)
end




function dash_manager:old_dash(game)
    enough_magic = false
    local hero = game:get_hero()
    local dir = hero:get_direction()
    local dd = {[0]=0,[1]=math.pi/2,[2]=math.pi,[3]=3*math.pi/2} --to convert 0-4 direction to radians
    dir = dd[dir]
    local m = sol.movement.create("straight")
    m:set_angle(dir)
    if game:has_item("dandelion_charm") then
        m:set_speed(250)
        m:set_max_distance(96)
    else
        m:set_speed(200)
        m:set_max_distance(64)
    end
    m:set_smooth(true)
    if game:has_item("dandelion_charm") then
        hero:get_sprite():set_animation("dash", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_dashing", true)
        self:generate_moths(game)
    else
        hero:get_sprite():set_animation("roll", function() hero:get_sprite():set_animation("walking") end)
        game:set_value("hero_rolling", true)
    end
    if game:has_item("dandelion_charm") then sol.audio.play_sound("dash")
    else sol.audio.play_sound("roll_2") end
    can_dash = false

    m:start(hero, function()
        hero:unfreeze()
        game:set_value("hero_dashing", false)
        game:set_value("hero_rolling", false)
    end)

    sol.timer.start(hero, 1000, function()
        can_dash = true
    end)

    if game:has_item("dandelion_charm") then hero:set_invincible(true, 300) end

    function m:on_obstacle_reached()
        hero:unfreeze()
        sol.timer.start(hero, 800, function()
        can_dash = true
        end)
    end

    hero:register_event("on_position_changed", function()
        if game:get_value("hero_dashing") or game:get_value("hero_rolling") then
        local ground = hero:get_ground_below()
        if ground == "deep_water" or ground == "hole" or ground == "lava" then
            m:stop()
        end
        end
    end)
end

return dash_manager