local map = ...
local game = map:get_game()

for block in map:get_entities"covering_statue" do
function block:on_moving()
  if not map:get_entities"hole_blocker" then return end
  hole_blocker:remove()
end
end
