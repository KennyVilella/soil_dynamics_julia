"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                       Starting implementation of utility functions                       #
#                                                                                          #
#==========================================================================================#
"""
    calc_normal(a::Vector{T}, b::Vector{T}, c::Vector{T}) where {T<:Float64}

This function calculates the unit normal vector of a plane formed by three points using
the right-hand rule.

Note:
- The input order of the points is important as it determines the sign of the unit normal
  vector based on the right-hand rule.

# Inputs
- `a::Vector{T}`: Cartesian coordinates of the first point of the plane. [m]
- `b::Vector{T}`: Cartesian coordinates of the second point of the plane. [m]
- `c::Vector{T}`: Cartesian coordinates of the third point of the plane. [m]

# Outputs
- `Vector{T}`: Unit normal vector of the provided plane. [m]

# Example

    a = [0.0, 0.0, 0.0]
    b = [1.0, 0.5, 0.23]
    c = [0.1, 0.2, -0.5]

    unit_normal = calc_normal(a, b, c)
"""
function calc_normal(
    a::Vector{T},
    b::Vector{T},
    c::Vector{T}
) where {T<:Float64}

    return cross(b - a, c - a) / norm(cross(b - a, c - a))
end

