local behavior = {}

local normal_functions = require("enemies/lib/normal_functions")

function behavior:create(enemy, properties)

  local game = enemy:get_game()
  local map = enemy:get_map()
  local hero = map:get_hero()
  local going_hero = false
  local can_attack = true

  --initialize universal enemy stuff:
  normal_functions:set(enemy, properties)
  --this is pretty notmal too, but needs check_hero()
  function enemy:on_obstacle_reached(movement)
    if not going_hero then
      self:go_random()
      self:check_hero()
    end
  end


  --RESTART
  function enemy:on_restarted()
    going_hero = false
    self:go_random()
    self:check_hero()
  end

local n = 1
  --Check hero
  function enemy:check_hero()
    local near_hero = self:is_near_hero()
    --set our movement toward the hero or not accordingly
    if near_hero and not going_hero then
      going_hero = true
      self:go_hero()
print("go hero!"..n) n=n+1
    elseif not near_hero and going_hero then
      going_hero = false
      self:go_random()
print("go random!"..n) n=n+1
    end
    --and also decide if we should attack or something
    self:check_to_attack()
    sol.timer.start(self, 150, function()
      self:check_hero()
    end)
  end


  --Check to Attack
  function enemy:check_to_attack()
    --check if hero is aligned, if necessary
    local aligned = true
    if properties.must_be_aligned_to_attack then
      if not ((math.abs(hero_x - x) < 16 or math.abs(hero_y - y) < 16)) then aligned = false end
    end
    if aligned and can_attack and self:get_distance(hero) <= properties.melee_distance then
      self:attack()
      can_attack = false
      sol.timer.start(map, properties.attack_frequency, function() can_attack = true end)        
    end
  end


  --Attack!
  function enemy:attack()
    local direction = self:get_sprite():get_direction()
    local x, y, layer = self:get_position()
    local dx = {[0] = -16, [1] = 0, [2] = 16, [3] = 0}
    local dy = {[0] = 0, [1] = -16, [2] = 0, [3] = 16}
    dx, dy = dx[direction], dy[direction]
    map:create_enemy{
      x = x+dx, y = y+dy, layer = layer,
      direction = direction,
      breed = "misc/nitrodendron_bomb"}
  end


end

return behavior