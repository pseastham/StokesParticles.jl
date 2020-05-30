"""
  isInside(polygon, n, p)

Returns true if the point p lies inside the polygon with n vertices
"""
function is_inside(polygon::Vector{Point2D{T}}, n::Int, p::Point2D{T}; extreme = Point2D(100000.0, p[2])) where T<:Real
  # There must be at least 3 vertices in polygon
  if (n < 3) return false end

  # Count intersections of the above line with sides of polygon
  count = 0
  for i=1:n
    next = mod(i,n)+1
    # Check if the line segment from 'p' to 'extreme' intersects
    # with the line segment from 'polygon[i]' to 'polygon[next]'
    if (do_intersect(polygon[i], polygon[next], p, extreme))
      # If the point 'p' is colinear with line segment 'i-next',
      # then check if it lies on segment. If it lies, return true,
      # otherwise false
      if (get_orientation(polygon[i], p, polygon[next]) == 0)
         return on_segment(polygon[i], p, polygon[next])
      end
      count += 1
    end
  end

  # Return true if count is odd, false otherwise
  if isodd(count)
    return true
  else
    return false
  end
end

"""
do_intersect(p1,q1,p2,q2) -> bool

Checks whether two lines, defined by (p1,q1) and (p2,q2) where pi,qi are 2-arrays.

Algorithm explained in https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/.

Note we have NOT implemented the special case for overlapping line segments, as that will never be the case in finite element applications
"""
function do_intersect(p1::Point2D{T},q1::Point2D{T},p2::Point2D{T},q2::Point2D{T}) where T<:Real
  # Find the four orientations needed for general case
  o1 = get_orientation(p1, q1, p2)
  o2 = get_orientation(p1, q1, q2)
  o3 = get_orientation(p2, q2, p1)
  o4 = get_orientation(p2, q2, q1)

  # General case
  if (o1 != o2 && o3 != o4)
    return true
  else
    return false
  end
end
function do_intersect(p1,q1,p2,q2)
  # Find the four orientations needed for general case
  o1 = get_orientation(p1, q1, p2)
  o2 = get_orientation(p1, q1, q2)
  o3 = get_orientation(p2, q2, p1)
  o4 = get_orientation(p2, q2, q1)

  # General case
  if (o1 != o2 && o3 != o4)
    return true
  else
    return false
  end
end

"""
  orientation(p,q,r) -> Int

Computes orientation of 3 (ordered) points p,q,r. where each is a 2-array
2 -> counterclockwise (CCW)
1 -> clockwise        (CW)
0 -> collinear

Algorithm is explained in https://www.geeksforgeeks.org/orientation-3-ordered-points/
"""
function get_orientation(p::Point2D{T},q::Point2D{T},r::Point2D{T}) where T<:Real
  val = (q.y-p.y)*(r.x-q.x) - (q.x-p.x)*(r.y-q.y);

  if (val == 0) return 0 end  # colinear

  return (val > 0) ? 1 : 2 # clock- or counterclock-wise
end

"""
  onSegment(p,q,r)

Checks whether the point `q` is on the line segment from `p` to `r`.
Returns a bool.
"""
function on_segment(p::Point2D{T},q::Point2D{T},r::Point2D{T}) where T<:Real
  if -eps() < (distance(p, q) + distance(q, r) - distance(p, r)) < eps()
    return true
  else
    return false
  end
end

function distance(a::Point2D{T},b::Point2D{T}) where T<:Real
  return sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

#    NearestPoint!(point,node,wall)
#
#Compute nearest point to particle on LineWall, CircleWall, and ArcWall 
function get_nearest_point!(point::Point2D{T},node::Particle2D{T},wall::LineWall) where T<:Real
  px=node.pos.x; py=node.pos.y

  Ax=wall.nodes[1].x; Ay=wall.nodes[1].y
  Bx=wall.nodes[2].x; By=wall.nodes[2].y

  bx=px-Ax; by=py-Ay
  ax=Bx-Ax; ay=By-Ay

  ℓ2 = ax^2+ay^2

  dotprod = ax*bx + ay*by

  point.x = dotprod*ax/ℓ2 + Ax
  point.y = dotprod*ay/ℓ2 + Ay

  nothing
end
function get_nearest_point!(point::Point2D{T},node::Particle2D{T},wall::CircleWall) where T<:Real
  px=node.pos.x; py=node.pos.y
  cx=wall.center.x; cy=wall.center.y
  r = wall.radius
  θ = atan(py-cy,px-cx)

  point.x = cx + r*cos(θ)
  point.y = cy + r*sin(θ)

  nothing
end
function get_nearest_point!(point::Point2D{T},node::Particle2D{T},wall::ArcWall) where T<:Real
  px= node.pos.x; py=node.pos.y
  cx= wall.nodes[2].x; cy=wall.nodes[2].y
  r = sqrt((cx-wall.nodes[1].x)^2 + (cy-wall.nodes[1].y)^2)
  θ = atan(py-cy,px-cx)

  point.x = cx + r*cos(θ)
  point.y = cy + r*sin(θ)

  nothing
end
function get_nearest_point(node::Particle2D{T},wall::W) where {T<:Real,W<:AbstractWall}
  point = Point2D(0.0,0.0)
  get_nearest_point!(point,node,wall)
  return point
end

# function to determine whether quadrature node (sx,sy) is within line
function is_in_line(wall::LineWall{T},point::Point2D{T}) where T<:Real
  return on_segment(wall.nodes[1],point,wall.nodes[2])
end
function is_in_line(wall::CircleWall{T},point::Point2D{T}) where T<:Real
  cx = wall.center.x; cy=wall.center.y
  val = abs(wall.radius - sqrt((cx-point.x)^2 + (cy-point.y)^2))
  TOL = 1e-12
  return (val < TOL ? true : false)
end
function is_in_line(wall::ArcWall{T},point::Point2D{T}) where T<:Real
  cx = wall.nodes[2].x; cy=wall.nodes[2].y
  radius = sqrt((cx-wall.nodes[1].x)^2 + (cy-wall.nodes[1].y)^2)
  val = abs(radius - sqrt((cx-point.x)^2 + (cy-point.y)^2))

  θ1 = atan(wall.nodes[1].y-cy,wall.nodes[1].x-cx) - pi/24
  θ2 = atan(wall.nodes[3].y-cy,wall.nodes[3].x-cx) + pi/24
  θs = atan(point.y-cy,point.x-cx)

  TOL = 1e-12
  isOn = false
  if val < TOL
      if θ1 > θ2
          if θs > θ1 || θs < θ2
              isOn = true
          end
      else
          if θs > θ1 && θs < θ2
              return true
          end
      end
  end

  return isOn
end

# determines whether or not point is inside a rectangle
# also includes being on bottom or left boundary
function is_inside_rect(rect::Vector{T},point::P)  where {T<:Real,P<:AbstractPoint}
  x0=rect[1]; x1=rect[2]; y0=rect[3]; y1=rect[4]

  if point.x<=x1 && point.x>=x0 && point.y<=y1 && point.y>=y0
    return true
  else
    return false
  end
end