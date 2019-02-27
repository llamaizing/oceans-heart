local item = ...

function item:on_created()

  self:set_shadow("small")
  self:set_can_disappear(true)
  self:set_brandish_when_picked(false)
  self:set_sound_when_picked("picked_rupee")
end

function item:on_obtaining(variant, savegame_variable)

  local amounts = {5, 10, 20, 50, 100, 200, 500}
  local amount = amounts[variant]
  if amount == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee'")
  end
  self:get_game():add_money(amount)
end

--[[
1 = 1
2 = 10
3 = 20
4 = 50
5 = 100
6 = 200
7 = 500
--]]