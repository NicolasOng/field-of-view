--FUNCTIONS TO REMOVE DUPLICATE COORDINATES FROM THE COORDINATE TABLE
print_coord_table = function(coord_table)
  --(coord_table) -> nil
  --prints the given coord table to the console
  --for each coordinate in the coordinate table,
  for _, coord in pairs(coord_table) do
    --print the x-value and the y-value
    print(coord.x, coord.y)
  end
end
--
coords_are_equal = function(coord1, coord2)--DONE/WORKING
  --(coordinate, coordinate) -> bool
  --takes in two coordinates, and returns true if they are equal.
  --returns false otherwise.
  local equal = false
  --if the x-values of the coordinates are equal,
  if (coord1.x == coord2.x) then
    --and the y-values are equal,
    if (coord1.y == coord2.y) then
      --then the two coordinates are equal
      equal = true
    end
  end
  --return the equal status.
  return equal
end
--
coord_is_in_table = function(coord, orig_table)--DONE/WORKING
  --(coordinate, table of coordinates) -> bool
  --finds if the given coord is in the table of coords
  local in_table = false
  --for each coordinate in the given table,
  for _, ocoord in pairs(orig_table) do
    --check if it's equal to the given coordinate.
    if (coords_are_equal(ocoord, coord)) then
      --if so, the given coordinate is in the given table.
      in_table = true
    end
  end
  --return the in table status
  return in_table
end
--
remove_duplicate_coords = function(orig_table)--DONE/WORKING
  --(table of coordinates) -> table of coordinates
  --removes duplicate coordinates from the given table.
  local result_table = {orig_table[1]}
  for _, ocoord in pairs(orig_table) do
    if (not coord_is_in_table(ocoord, result_table)) then
      table.insert(result_table, ocoord)
    end
  end
  return result_table
end
--
--FUNCTIONS FOR THE AKL-TOUSSAINT HEURISTIC
coord_is_above_line = function(coord, line_end1, line_end2)--DONE/WORKING
  --(coordinate, coordinate, coordinate) -> bool
  --this function takes in a coordinate, and two other coordinates defining a line.
  --it returns true if the first coordinate is above the defined line,
  --and false if it is on or below.
  
  local above_line = false
  --find line equation:
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local y_int = line_end1.y - (slope * line_end1.x)
  --line_eq: y = (slope * x) + y_int
  --find the point on the line at the x-value of the given coordinate:
  local alt_y = (slope * coord.x) + y_int
  --compare to the coord's y-val:
  if (coord.y > alt_y) then
    above_line = true
  end
return above_line
end
--
coord_is_below_line = function(coord, line_end1, line_end2)--DONE/WORKING
  --(coordinate, coordinate, coordinate) -> bool
  --this function takes in a coordinate, and two other coordinates defining a line.
  --it returns true if the first coordinate is above the defined line,
  --and false if it is on or below.
  local below_line = false
  --find line equation:
  local slope = (line_end2.y - line_end1.y) / (line_end2.x - line_end1.x)
  local y_int = line_end1.y - (slope * line_end1.x)
  --line_eq: y = (slope * x) + y_int
  --find the point on the line at the x-value of the given coordinate:
  local alt_y = (slope * coord.x) + y_int
  --compare to the coord's y-val:
  if (coord.y < alt_y) then
    below_line = true
  end
  return below_line
end
--
max_min_coords = function(coord_table)--DONE/WORKING
  --(table of coordinates) -> coordinate, coordinate, coordinate, coordinate
  --this function finds the coordinates with the greatest and lowest y and x values
  --from the given table.
  
  --create variables that will eventually house the coordinates with the min/max values
  coord_min_x = coord_table[1]
  coord_max_x = coord_table[1]
  coord_min_y = coord_table[1]
  coord_max_y = coord_table[1]
  --go thru each coordinate in the table
  for _, coord in pairs(coord_table) do
    if (coord.x < coord_min_x.x) then
      coord_min_x = coord
    end
    if (coord.x > coord_max_x.x) then
      coord_max_x = coord
    end
    if (coord.y < coord_min_y.y) then
      coord_min_y = coord
    end
    if (coord.y > coord_max_y.y) then
      coord_max_y = coord
    end
  end
  return coord_min_x, coord_max_x, coord_min_y, coord_max_y
end
--
list_of_relavent_coords = function(coord_table)--DONE/NEEDS UNIT TESTS (also this is the Akl-Toussaint hueristic)
  --(table of coordinates) -> table of coordinates
  --this function returns a list of all the coordinates that can be a part of the convex hull of the given coordinate table.
  
  --find the max and min coords:
  local min_x, max_x, min_y, max_y = max_min_coords(coord_table)
  --create a container to hold coordinates that are outside of the barriers (which define the point's irrelavency):
  --the coordinates in the container are relavent (might be in convex hull).
  local relavent_coords = {min_x, max_x, min_y, max_y}
  --populate the containers by considering each coord's position, relative to the borders.
  --(note for both top and bottom barriers, I break them in two)
  for _, coord in pairs(coord_table) do
    --consider the top barrier first:
    if (coord.x < max_y.x) then
      if (coord_is_above_line(coord, min_x, max_y)) then
        table.insert(relavent_coords, coord)
      end
    else
      if (coord_is_above_line(coord, max_x, max_y)) then
        table.insert(relavent_coords, coord)
      end
    end
    --next, consider the bottom barrier:
    if (coord.x < min_y.x) then
      if (coord_is_below_line(coord, min_x, min_y)) then
        table.insert(relavent_coords, coord)
      end
    else
      if (coord_is_below_line(coord, max_x, min_y)) then
        table.insert(relavent_coords, coord)
      end
    end
  end
  return remove_duplicate_coords(relavent_coords)
end
--
--FUNCTIONS FOR THE QUICKHULL ALGORITHM
distance_between_line_and_point = function(point, line_end1, line_end2)--WORKING/NEEDS MORE TESTING
  numerator = ((line_end2.y - line_end1.y) * point.x) - ((line_end2.x - line_end1.x) * point.y) + (line_end2.x * line_end1.y) - (line_end2.y * line_end1.x)
  denominator = math.sqrt((line_end2.y - line_end1.y)^2 + (line_end2.x - line_end1.x)^2)
  return math.abs(numerator/denominator)
end
--
point_furthest_from_line = function(point_table, line_end1, line_end2)--WORKING/NEEDS MORE TESTING
  --(table of coordinates, coordinate, coordinate) -> coordinate
  --this function returns the coordinate furthest from the line defined by the two endpoints,
  --from the given table of points.
  local greatest_distance = 0
  local furthest_coord = nil
  for _, coord in pairs(point_table) do
    local distance = distance_between_line_and_point(coord, line_end1, line_end2)
    if (distance > greatest_distance) then
      furthest_coord = coord
      greatest_distance = distance
    end
  end
  return furthest_coord
end
--
coord_table_translation = function(coord_table)
  local return_table = {}
  for _, coord in pairs(coord_table) do
    local temp_coord = {}
    temp_coord[1] = coord.x
    temp_coord[2] = coord.y
    table.insert(return_table, temp_coord)
  end
  return return_table
end
--
coord_table_translation2 = function(coord_table)
  local return_table = {}
  for _, coord in pairs(coord_table) do
    local temp_coord = {}
    temp_coord.x = coord[1]
    temp_coord.y = coord[2]
    table.insert(return_table, temp_coord)
  end
  return return_table
end
--
find_the_convex_hull_of = function(points)
  local convex_hull = coord_table_translation(points)
  convex_hull = monotone_chain(convex_hull)
  convex_hull = coord_table_translation2(convex_hull)
  return convex_hull
end
--
monotone_chain = function(points)
    local p = #points

    local cross = function(p, q, r)
        return (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
    end

    table.sort(points, function(a, b)
        return a[1] == b[1] and a[2] > b[2] or a[1] > b[1]
    end)

    local lower = {}
    for i = 1, p do
        while (#lower >= 2 and cross(lower[#lower - 1], lower[#lower], points[i]) <= 0) do
            table.remove(lower, #lower)
        end

        table.insert(lower, points[i])
    end

    local upper = {}
    for i = p, 1, -1 do
        while (#upper >= 2 and cross(upper[#upper - 1], upper[#upper], points[i]) <= 0) do
            table.remove(upper, #upper)
        end

        table.insert(upper, points[i])
    end

    table.remove(upper, #upper)
    table.remove(lower, #lower)
    for _, point in ipairs(lower) do
        table.insert(upper, point)
    end

    return upper
end
