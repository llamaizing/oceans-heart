local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local particles = {}
local MAX_PARTICLES = 2
local PARTICLE_SPEED = 15

-- Event called when the enemy is initialized.
function enemy:on_created()
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(1)
  enemy:set_damage(8)
  enemy:set_pushed_back_when_hurt(false)
  enemy:set_traversable(false)
  enemy:set_attacking_collision_mode("touching") --so it can still hurt the hero without being traversable
  enemy:set_invincible()

--particle effect creation
  local i = 1
  sol.timer.start(map, math.random(100,250), function()
    particles[i] = sol.sprite.create("entities/pollution_ash")
    particles[i]:set_xy(math.random(-16, 16), math.random(-16, 8))
    local m = sol.movement.create("random")
    m:set_speed(PARTICLE_SPEED)
    m:start(particles[i])
    i = i + 1
    if i > MAX_PARTICLES then i = 0 end
    if enemy:exists() and enemy:is_enabled() then return true end
  end)
end

--particle effect draw
function enemy:on_post_draw()
    local x, y, layer = enemy:get_position()
    for i=1, #particles do
      map:draw_visual(particles[i], x, y)
    end
end