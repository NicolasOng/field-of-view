function love.load()
  require 'FOW_functions'
  require 'convex_hull_algorithm'
  arial = love.graphics.newFont('/arial.ttf')
  viewport_coord = {x = 0, y = 0}
  love.window.setMode(1280, 720, {resizable=true})
  vp_width, vp_height = 1280, 720
  --create the rectangle wall
  the_rectangle = {coord = {x = 100, y = 500}, dim = {height = 25, width = 250}, casting_points = {{x = 100, y = 500}, {x = 350, y = 500}, {x = 350, y = 525}, {x = 100, y = 525}}}
  --create triangle
  the_triangle = {casting_points = {{x = 600, y = 350}, {x = 700, y = 350}, {x = 625, y = 450}}}
  --create house 800, 300 -> 1200, 650
  wall1 = {casting_points = {{x = 800, y = 300}, {x = 1200, y = 300}, {x = 1200, y = 325}, {x = 800, y = 325}}}
  wall2 = {casting_points = {{x = 800, y = 300}, {x = 800, y = 650}, {x = 825, y = 650}, {x = 825, y = 300}}}
  wall3 = {casting_points = {{x = 1200, y = 300}, {x = 1175, y = 300}, {x = 1175, y = 650}, {x = 1200, y = 650}}}
  wall4 = {casting_points = {{x = 800, y = 650}, {x = 1000, y = 650}, {x = 1000, y = 625}, {x = 800, y = 625}}}
  wall5 = {casting_points = {{x = 1200, y = 650}, {x = 1200, y = 625}, {x = 1100, y = 625}, {x = 1100, y = 650}}}
  --create an object to dissapear behind FoW
  the_ellipse = {coord = {x = 700, y = 100}, dim = {height = 50, width = 50}}
  --create the mouse pos
  mouse_coord = {x = 0, y = 0}
end
function love.update(dt)
  mouse_x, mouse_y = love.mouse.getPosition()
  mouse_coord = {x = mouse_x, y = mouse_y}
  vp_width, vp_height = love.graphics.getDimensions()
  world_map_dimensions = {width = vp_width, height = vp_height}
  --get the points to define the polyfow:
  polyfow1 = find_relavent_fow_points(mouse_coord, the_rectangle.casting_points, world_map_dimensions)
  polyfow1 = organize_fow_points(polyfow1)
  --make the table readable for the stencil function (no table within tables)
  polyfow1 = collapse_coordinate_table(polyfow1)
  --create a stencil function which will define the area to add the FoW to.
  thePolyfowStencil = function()
    if (#polyfow1 > 5) then
      love.graphics.polygon('fill', polyfow1)
    end
  end
  --for the triangle
  polyfow2 = find_relavent_fow_points(mouse_coord, the_triangle.casting_points, world_map_dimensions)
  polyfow2 = organize_fow_points(polyfow2)
  polyfow2 = collapse_coordinate_table(polyfow2)
  thePolyfow2Stencil = function()
    if (#polyfow2 > 5) then
      love.graphics.polygon('fill', polyfow2)
    end
  end
  --for the house
  ----wall 1
  polyfowWall1 = find_relavent_fow_points(mouse_coord, wall1.casting_points, world_map_dimensions)
  polyfowWall1 = organize_fow_points(polyfowWall1)
  polyfowWall1 = collapse_coordinate_table(polyfowWall1)
  thePolyfowWall1Stencil = function()
    if (#polyfowWall1 > 5) then
      love.graphics.polygon('fill', polyfowWall1)
    end
  end
  ----wall 2
  polyfowWall2 = find_relavent_fow_points(mouse_coord, wall2.casting_points, world_map_dimensions)
  polyfowWall2 = organize_fow_points(polyfowWall2)
  polyfowWall2 = collapse_coordinate_table(polyfowWall2)
  thePolyfowWall2Stencil = function()
    if (#polyfowWall2 > 5) then
      love.graphics.polygon('fill', polyfowWall2)
    end
  end
  ----wall 3
  polyfowWall3 = find_relavent_fow_points(mouse_coord, wall3.casting_points, world_map_dimensions)
  polyfowWall3 = organize_fow_points(polyfowWall3)
  polyfowWall3 = collapse_coordinate_table(polyfowWall3)
  thePolyfowWall3Stencil = function()
    if (#polyfowWall3 > 5) then
      love.graphics.polygon('fill', polyfowWall3)
    end
  end
  ----wall 4
  polyfowWall4 = find_relavent_fow_points(mouse_coord, wall4.casting_points, world_map_dimensions)
  polyfowWall4 = organize_fow_points(polyfowWall4)
  polyfowWall4 = collapse_coordinate_table(polyfowWall4)
  thePolyfowWall4Stencil = function()
    if (#polyfowWall4 > 5) then
      love.graphics.polygon('fill', polyfowWall4)
    end
  end
  ----wall 5
  polyfowWall5 = find_relavent_fow_points(mouse_coord, wall5.casting_points, world_map_dimensions)
  polyfowWall5 = organize_fow_points(polyfowWall5)
  polyfowWall5 = collapse_coordinate_table(polyfowWall5)
  thePolyfowWall5Stencil = function()
    if (#polyfowWall5 > 5) then
      love.graphics.polygon('fill', polyfowWall5)
    end
  end
end
function love.draw()
  --fill in the background with white
  love.graphics.setBackgroundColor(256, 256, 256)
  --draw the ellipse
  love.graphics.setColor(256, 0, 0)
  love.graphics.ellipse('fill', the_ellipse.coord.x, the_ellipse.coord.y, the_ellipse.dim.width, the_ellipse.dim.height)
  --create the stencil
  love.graphics.stencil(thePolyfowStencil, "replace", 1)
  --turn on stencil mode
  love.graphics.setStencilTest("greater", 0)
  --draw the fow
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  --end the stencil mode
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfow2Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfowWall1Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfowWall2Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfowWall3Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfowWall4Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  love.graphics.stencil(thePolyfowWall5Stencil, "replace", 1)
  love.graphics.setStencilTest("greater", 0)
  love.graphics.setColor(0,0,256)
  love.graphics.rectangle('fill', 0, 0, vp_width, vp_height)
  love.graphics.setStencilTest()
  --
  --drawing the shapes
  --rectangle
  love.graphics.setColor(0, 256, 0)
  love.graphics.rectangle('fill', the_rectangle.coord.x, the_rectangle.coord.y, the_rectangle.dim.width, the_rectangle.dim.height)
  --triangle
  love.graphics.polygon('fill', collapse_coordinate_table(the_triangle.casting_points))
  --walls
  love.graphics.polygon('fill', collapse_coordinate_table(wall1.casting_points))
  love.graphics.polygon('fill', collapse_coordinate_table(wall2.casting_points))
  love.graphics.polygon('fill', collapse_coordinate_table(wall3.casting_points))
  love.graphics.polygon('fill', collapse_coordinate_table(wall4.casting_points))
  love.graphics.polygon('fill', collapse_coordinate_table(wall5.casting_points))
  --draw the mouse position
  love.graphics.rectangle('fill', mouse_coord.x, mouse_coord.y, 10, 10)
  --draw the mouse coords
  text_mouse = love.graphics.newText(arial, tostring(mouse_coord.x) .. ", " .. tostring(mouse_coord.y))
  love.graphics.draw(text_mouse, 1, 1)
end