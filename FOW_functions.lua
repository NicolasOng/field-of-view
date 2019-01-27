require 'convex_hull_algorithm'
--Circles are given a set amount of fow points, depending on the quality.
--The following functions assume that the fow point is infinitely high, so the player cannot see over any objects
--They also assume the ground is a flat surface, so the player can't see any hills behind the object.

--Casting points: points on an object which define its dimensions. Kept in an object's .casting_points table, which are relative to the object's origins.
--FoW points: points whose convex hull defines the FoW.

find_y_given_x_on_line = function(x, line_end1, line_end2) --TESTED (WHAT IF LINE IS VERTICAL???)
  --(int, coordinate, coordinate) -> int
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local y_int = line_end1.y - (slope * line_end1.x)
  local y = (slope * x) + y_int
  return y
end
--
find_x_given_y_on_line = function(y, line_end1, line_end2) --TESTED (WHAT IF LINE IS HORIZONTAL????)
  --(int, coordinate, coordinate) -> int
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local y_int = line_end1.y - (slope * line_end1.x)
  -- y = sx + yint
  -- y - yint = sx
  --(y - yint)/s = x
  local x = (y - y_int) / slope
  return x
end
--
coord_is_left_of_line = function(coord, line_end1, line_end2)
  --(coordinate, coordinate, coordinate) -> bool
  --this function determines if a coord is to the left of a line.
  --returns true if the coord is to the left of a line.
  --if the coord is on the line or the line has a slope of 0, returns false.
  --REQ: the point above and below functions from convexhullalgo.lua
  --REQ: the two points defining the line are different
  local is_left = false
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local point_above = coord_is_above_line(coord, line_end1, line_end2)
  local point_below = coord_is_below_line(coord, line_end1, line_end2)
  --if the given point is above the line,
  if (point_above) then
    --and the slope is greater than 0,
    if (slope > 0) then
      --then the point is to the left of the line.
      is_left = true
    --if the given point is above the line and the slope is less than 0,
    elseif (slope < 0) then
      --then the point is to the right of the line.
      is_left = false
    end
  --if the point is below the line,
  elseif (point_below) then
    --and the slope is greater than 0,
    if (slope > 0) then
      --then the point is to the right of the line.
      is_left = false
    --if the given point is below the line and the slope is less than 0,
    elseif (slope < 0) then
      --then the point is to the left of the line.
      is_left = true
    end
  end
  --if the slope is infinite (the line is vertical),
  if (math.abs(slope) == math.huge) then
    --then compare the x-vals of a point on the line, and the given point
    --if the coord is to the left of the vertical line,
    if (coord.x < line_end2.x) then
      --return true
      is_left = true
    end
  end
  return is_left
end
--
coord_is_right_of_line = function(coord, line_end1, line_end2)
  --(coordinate, coordinate, coordinate) -> bool
  --this function determines if a coord is to the right of a line.
  --returns true if the coord is to the right of a line.
  --if the coord is on the line or the line has a slope of 0, returns false.
  --REQ: the point above and below functions from convexhullalgo.lua
  --REQ: the two points defining the line are different
  local is_right = false
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local point_above = coord_is_above_line(coord, line_end1, line_end2)
  local point_below = coord_is_below_line(coord, line_end1, line_end2)
  --if the given point is above the line,
  if (point_above) then
    --and the slope is greater than 0,
    if (slope > 0) then
      --then the point is to the left of the line.
      is_right = false
    --if the given point is above the line and the slope is less than 0,
    elseif (slope < 0) then
      --then the point is to the right of the line.
      is_right = true
    end
  --if the point is below the line,
  elseif (point_below) then
    --and the slope is greater than 0,
    if (slope > 0) then
      --then the point is to the right of the line.
      is_right = true
    --if the given point is below the line and the slope is less than 0,
    elseif (slope < 0) then
      --then the point is to the left of the line.
      is_right = false
    end
  end
  --if the slope is infinite (the line is vertical)
  if (math.abs(slope) == math.huge) then
    --then compare the x-vals of a point on the line, and the given point
    --if the coord is to the left of the vertical line,
    if (coord.x > line_end2.x) then
      --return true
      is_right = true
    end
  end
  return is_right
end
--
which_quarter_casting_point_is_in = function(casting_coord, player_coord, world_map_dim) --TESTED
  --(coordinate, coordinate, coordinate, dimensions) -> string
  --this function determines which quarter the given casting coord is in.
  --quarters are defined by lines connecting the player and the corners.
  --needs the 'coord_is_above_line' function from 'convex_hull_algorithm.lua'
  --also assumes that the coordinate of the VP points to it's NW corner.
  
  local quarter = nil
  --determine the angles the corners are relative to the player.
  local NW_angle = find_angle_between_two_pts({x = 0, y = 0}, player_coord)
  local NE_angle = find_angle_between_two_pts({x = world_map_dim.width, y = 0}, player_coord)
  local SE_angle = find_angle_between_two_pts({x = world_map_dim.width, y = world_map_dim.height}, player_coord)
  local SW_angle = find_angle_between_two_pts({x = 0, y = world_map_dim.height}, player_coord)
  local casting_angle = find_angle_between_two_pts(casting_coord, player_coord)
  --using the information above, find the quarter the casting coord is in.
  if ((casting_angle <= NE_angle) and (casting_angle > NW_angle)) then -- [PERHAPS REMOVE THE 'OR EQUAL TO' PARTS]
    quarter = 'N'
  elseif ((casting_angle <= SW_angle) and (casting_angle > SE_angle)) then
    quarter = 'S'
  elseif ((casting_angle <= NW_angle) or (casting_angle > SW_angle)) then
    quarter = 'W'
  elseif (((casting_angle > NE_angle) and (casting_angle <= 0)) or ((casting_angle <= SE_angle) and (casting_angle >= 0))) then
    quarter = 'E'
  end
  return quarter
end
--
find_a_FoW_point = function(player_coord, casting_coord, world_map_dim)
  --(coordinate, coordinate, coordinate, dimensions) --> coordinate
  --this function creates a FoW point given a the player's coords, a casting point, and the world map's dimensions.
  --the FoW point end at the end of the wolrd map.
  --the world map's top left corner is 0, 0, and bottom right is it's dimensions.
  --needs the 'coord_is_above_line' function from 'convex_hull_algorithm.lua'
  
  --create the coordinate to return
  local fow_coord = {}
  --check which quarter of the viewport the casting coord is in.
  --this determines which border of the viewport we use as the x/y-val for the FoW point.
  local quarter = which_quarter_casting_point_is_in(casting_coord, player_coord, world_map_dim)
  --knowing the quarter, find the FoW point.
  if (quarter == 'N') then
    fow_coord.y = 0
    fow_coord.x = find_x_given_y_on_line(fow_coord.y, player_coord, casting_coord)
    if (fow_coord.x ~= fow_coord.x) then
      fow_coord.x = player_coord.x
    end
  elseif (quarter == 'S') then
    fow_coord.y = world_map_dim.height
    fow_coord.x = find_x_given_y_on_line(fow_coord.y, player_coord, casting_coord)
    if (fow_coord.x ~= fow_coord.x) then
      fow_coord.x = player_coord.x
    end
  elseif (quarter == 'W') then
    fow_coord.x = 0
    fow_coord.y = find_y_given_x_on_line(fow_coord.x, player_coord, casting_coord)
    if (fow_coord.y ~= fow_coord.y) then
      fow_coord.y = player_coord.y
    end
  elseif (quarter == 'E') then
    fow_coord.x = world_map_dim.width
    fow_coord.y = find_y_given_x_on_line(fow_coord.x, player_coord, casting_coord)
    if (fow_coord.y ~= fow_coord.y) then
      fow_coord.y = player_coord.y
    end
  end
  return fow_coord
end
--
deepCopy = function(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == 'table' then
            v = deepCopy(v)
        end
        copy[k] = v
    end
    return copy
end
--
inside_convex_polygon = function(point, polygon)
  --(coordinate, table of coordinates) -> bool
  --this function takes in a point and a table of coordinates defining a polygon, and determines if the point is within the polygon.
  --if the point is within the polygon, returns true.
  --else, false.
  --REQ: the convex hull algo function and the coord_is_in_table
  local inside_poly = false
  local poly = deepCopy(polygon)
  --insert the point into the polygon table.
  table.insert(poly, point)
  --run the new table through the convex hull algo.
  poly = find_the_convex_hull_of(poly)
  --if the point is not in the table anymore, the point was inside the polygon
  if (not coord_is_in_table(point, poly)) then
    inside_poly = true
  end
  return inside_poly
end
--
determine_viewport_corner_fow_points = function(player_coord, casting_points, world_map_dim)
  --(table of coordinates, coordinate, dimension) -> table of coordinates
  --determines which corners of the viewports are part of the set of fow points for the given casting points.
  local corners = {}
  local NW = {x = 0, y = 0}
  local NE = {x = world_map_dim.width, y = 0}
  local SE = {x = world_map_dim.width, y = world_map_dim.height}
  local SW = {x = 0, y = world_map_dim.height}
  local N_pts = {}
  local E_pts = {}
  local S_pts = {}
  local W_pts = {}
  local casting_point_in = {north = false, south = false, west = false, east = false}
  --go thru all the casting points. Mark each quadrant with a casting point with true.
  for _, point in pairs(casting_points) do
    --find the quarter the casting point is in
    local quarter = which_quarter_casting_point_is_in(point, player_coord, world_map_dim)
    if (quarter == 'N') then
      casting_point_in.north = true
      table.insert(N_pts, point)
    elseif (quarter == 'S') then
      casting_point_in.south = true
      table.insert(S_pts, point)
    elseif (quarter == 'W') then
      casting_point_in.west = true
      table.insert(W_pts, point)
    elseif (quarter == 'E') then
      casting_point_in.east = true
      table.insert(E_pts, point)
    end
  end
  --[delete this line maybe]
  min_x, max_x, min_y, max_y = max_min_coords(casting_points)
  --now we know which quarters casting points are located in. Determine which corners are relavent using this information.
  --if there's a casting point in the north and east quadrant,
  if (casting_point_in.north and casting_point_in.west) then
    print('there\'s a casting point in the N and W quadrants')
    --put the north east corner in the table.
    table.insert(corners, NW)
  end
  --and so on.
  if (casting_point_in.north and casting_point_in.east) then
    print('there\'s a casting point in the N and E quadrants')
    table.insert(corners, NE)
  end
  if (casting_point_in.south and casting_point_in.west) then
    print('there\'s a casting point in the S and W quadrants')
    table.insert(corners, SW)
  end
  if(casting_point_in.south and casting_point_in.east) then
    print('there\'s a casting point in the S and E quadrants')
    table.insert(corners, SE)
  end
  --if the player is in a polygon, all corners should be added
  if (inside_convex_polygon(player_coord, casting_points)) then
    print('the source is in the polygon')
    table.insert(corners, NW)
    table.insert(corners, NE)
    table.insert(corners, SE)
    table.insert(corners, SW)
  --if there is a casting point in the east and west quadrants, and the player is not in the polygon,
  elseif(casting_point_in.east and casting_point_in.west) then
  print('there\'s a casting point in the E and W quadrants')
    --determine if the player is above or below the casting points.
    --if below, then put the NE and NW corners in the table, and so on.
    if (coord_is_above_line(player_coord, E_pts[1], W_pts[1])) then
      print('the source is below the casting points') --a greater y in LOVE2D is lower, so a point with a greater y than the line is "below" it
      table.insert(corners, NW)
      table.insert(corners, NE)
    elseif (coord_is_below_line(player_coord, E_pts[1], W_pts[1])) then
      print('the source is above the casting points')
      table.insert(corners, SW)
      table.insert(corners, SE)
    end
  --if there is a casting point in the north and south quadrants, the player is not in the polygon, and there aren't casting pts in both the E and W quads.
  elseif(casting_point_in.north and casting_point_in.south) then
  print('there\'s a casting point in the N and S quadrants')
  print('is the coord to the right of the line:')
  print(coord_is_right_of_line(player_coord, S_pts[1], N_pts[1]))
  print('is the coord to the left of the line:')
  print(coord_is_left_of_line(player_coord, S_pts[1], N_pts[1]))
    if (coord_is_right_of_line(player_coord, S_pts[1], N_pts[1])) then
      print('the source is to the right of the casting points')
      table.insert(corners, NW)
      table.insert(corners, SW)
    elseif (coord_is_left_of_line(player_coord, S_pts[1], N_pts[1])) then
      print('the source is to the left of the casting points')
      table.insert(corners, NE)
      table.insert(corners, SE)
    end
  end
  return corners
end
--
find_all_possible_FoW_points = function(player_coord, casting_points, world_map_dimensions)
  --(coordinate, table of coordinates, coordinate, dimensions) -> table of coordinates
  --this function finds all the FoW points for the specified object.
  all_FoW_points_list = {}
  --find the fow point for each casting point,
  for _, casting_point in pairs(casting_points) do
    --and add them to the table.
    table.insert(all_FoW_points_list, find_a_FoW_point(player_coord, casting_point, world_map_dimensions))
  end
  for _, casting_point in pairs(casting_points) do
    --add the casting point.
    table.insert(all_FoW_points_list, casting_point)
  end  
  --and add the corners of the viewport which are part of the fow points
  for _, corner in pairs(determine_viewport_corner_fow_points(player_coord, casting_points, world_map_dimensions)) do
    table.insert(all_FoW_points_list, corner)
  end
  return all_FoW_points_list
end
--
find_relavent_fow_points = function(player_coord, casting_points, world_map_dimensions)
  --(coordinate, table of coordinates, coordinate, dimensions) -> table of coordinates
  --this function finds all the relavent fow points for a given set of casting points.
  --needs various functions from 'convex_hull_algorithm.lua'
  return find_the_convex_hull_of(find_all_possible_FoW_points(player_coord, casting_points, world_map_dimensions))
end
--
find_center_point_of_polygon = function(fow_point_list)
  --finds a point at the center of a given polygon.
  local min_x, max_x, min_y, max_y = max_min_coords(fow_point_list)
  return {x = ((min_x.x + max_x.x)/2), y = ((min_y.y + max_y.y)/2)}
end
--
find_angle_between_two_pts = function(pt, center_pt)
  --returns a coordinate, but it has a .angle variable added to it.
  local y = pt.y - center_pt.y
  local x = pt.x - center_pt.x
  local angle = math.atan2(y, x)
  return angle
end
--
organize_fow_points = function(fow_point_list)
  --takes in a table of FoW Points and organizes them so that the defined polygon is correct.
  --first, find the coord with the greatest y-val,
  --then find the one with the greatest x-val,
  --then add to the list the coord with the greatest y-val, and all the ones with an x-val greater than it's own in order, as long as the y-vals of those coordinates are greater than the coord with the greatest x-val.
  --repeat a similar process with the three other quarters of the convex hull.
  --result should be the finalized set of fow points, ready to become a polygon.
  local organized_table = {}
  local pts_and_angles = {}
  local just_angles = {}
  local center_pt = find_center_point_of_polygon(fow_point_list)
  --create a table with all the pt's angles,
  --and a table with all the coordinates, but with their angle as their keys.
  for _, pt in pairs(fow_point_list) do
    local angle = find_angle_between_two_pts(pt, center_pt)
    if (angle == angle) then
      pts_and_angles[angle] = pt
      table.insert(just_angles, angle)
    end
  end
  --sort the table with just the angles
  table.sort(just_angles)
  --go through the table with just the angles.
  for _, angle in pairs(just_angles) do
    --and add the pt associated with that angle to a sorted table
    table.insert(organized_table, pts_and_angles[angle])
  end
  return organized_table
end
-- 
collapse_coordinate_table = function(coord_table)
  --WARNING: if there are less than 3 given points, it's not enough to build a polygon, and LOVE2D will crash
  local collapsed = {}
  for _, coord in pairs(coord_table) do
    table.insert(collapsed, coord.x)
    table.insert(collapsed, coord.y)
  end
  return collapsed
end