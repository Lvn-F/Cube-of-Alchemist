function createCollisionClasses()
    world:addCollisionClass('Ignore', {ignores = {'Ignore'}})
    world:addCollisionClass('Map', {ignores = {'Ignore'}})
    world:addCollisionClass('MapPassable', {ignores = {'Ignore'}})
    world:addCollisionClass('Player', {ignores = { 'Ignore'}})
    world:addCollisionClass('Enemy', {ignores = {'Player'}})
    world:addCollisionClass('Projectile', {ignores = { 'Player', 'MapPassable', 'Ignore'}})
end