-- Initialize enemy behavior specific to this quest.

require("scripts/meta/hero")


local enemy_meta = sol.main.get_metatable("enemy")


function enemy_meta:set_consequence_for_all_attacks(consequence)
  -- "sword", "thrown_item", "explosion", "arrow", "hookshot", "boomerang" or "fire"
  self:set_attack_consequence("sword", consequence)
  self:set_attack_consequence("thrown_item", consequence)
  self:set_attack_consequence("explosion", consequence)
  self:set_attack_consequence("arrow", consequence)
  self:set_attack_consequence("hookshot", consequence)
  self:set_attack_consequence("boomerang", consequence)
  self:set_attack_consequence("fire", consequence)
end


function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)
  local game = self:get_game()
  local sword_damage = game:get_value("sword_damage")
  local hero_state = hero:get_state()
  if hero_state == "sword spin attack" or hero_state == "running" then
    sword_damage = sword_damage * 2.5
  end
  if game.tilia_damage_multiplier then sword_damage = sword_damage * game.tilia_damage_multiplier end
  self:remove_life(sword_damage)

end




-- Helper function to inflict an explicit reaction from a scripted weapon.
-- TODO this should be in the Solarus API one day
function enemy_meta:receive_attack_consequence(attack, reaction)

  if type(reaction) == "number" then
    self:hurt(reaction)
  elseif reaction == "immobilized" then
    if not self.immobilize_immunity then
      self:immobilize()
    end
  elseif reaction == "protected" then
    sol.audio.play_sound("sword_tapping")
  elseif reaction == "custom" then
    if self.on_custom_attack_received ~= nil then
      self:on_custom_attack_received(attack)
    end
  end

end


function enemy_meta:on_hurt(attack)
    --screen shake
    local game = self:get_game()
    local map = self:get_map()
    local camera = map:get_camera()
    game:set_suspended(true)
    sol.timer.start(game, 120, function()
      game:set_suspended(false)
      map:get_camera():shake({count = 4, amplitude = 5, speed = 100})
     end) --end of timer

  if attack == "explosion" then
    local game = self:get_game()
    local bomb_pain = game:get_value("bomb_damage")
    self:remove_life(bomb_pain)
    self:react_to_bomb()

  end

  if attack == "fire" then
    local game = self:get_game()
    local fire_damage = game:get_value("sword_damage")
    if self.weak_to_fire then fire_damage = fire_damage * 2 end
    self:react_to_fire()
    self:remove_life(fire_damage)
  end

end

--Here's some methods you can redefine for each enemy. This allows for certain weaknesses.
function enemy_meta:react_to_fire()
end

function enemy_meta:react_to_bomb()
end

function enemy_meta:hit_by_toss_ball()
end

function enemy_meta:hit_by_lightning()
end


--Common Methods:
------------------------------------------------------

function enemy_meta:propagate_fire()
  local enemy = self
  if enemy.reacting_to_fire then return end
  enemy.reacting_to_fire = true
  sol.timer.start(enemy, 800, function() enemy.reacting_to_fire = false end)
  local map = enemy:get_map()
  local x,y,z = enemy:get_position()
  local dx = {12,0,-12,0}
  local dy = {0,-12,0,12}
  local NUM_FLAMES = 6
  for i=1, NUM_FLAMES do
    local flame = map:create_fire{
      x=x, y=y, layer=z
    }
    local m = sol.movement.create"straight"
    m:set_angle(2 * math.pi / NUM_FLAMES * i)
    m:set_max_distance(16)
    m:set_speed(110)
    m:start(flame)
  end
end

return true