"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#               Starting implementation of functions related to the bucket                 #
#                                                                                          #
#==========================================================================================#
"""
    _calc_line_pos(
        a::Vector{T}, b::Vector{T}, delta::T, grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function takes two Cartesian coordinates and computes all the cells
that are located on the straight line built from these two coordinates.

For the sake of accuracy, this computation is done by decomposing the inputted line
in small segments with a spatial increment `delta`.

The coordinates of each sub-point (ab_i) can then be calculated using

        ab_i = a + ab * i * delta / norm(ab)

i being the increment number and ab = b - a.
The Cartesian coordinates can then be converted into indices

        ab_i_ind = ab_i / cell_size + grid_half_length + 1

The last step is to convert these floats into integers.
As the center of each cell is considered to be on the center of the top surface,
`round` should be used for getting the cell indices in the X and Y direction,
while `ceil` should be used for the Z direction.

Note:
- This function is mot meant to be used outside this package.
- When the built line follows a cell border, the location of the line becomes ambiguous.
  This ambiguity is assumed to be solved by the caller.

# Inputs
- `a::Vector{T}`: Cartesian coordinates of the first extremity of the line. [m]
- `b::Vector{T}`: Cartesian coordinates of the second extremity of the line. [m]
- `delta::T`: Spatial increment used to decompose the line. [m]
- `grid::GridParam{I,T}`: Struct used to store information related to the simulation grid.

# Outputs
- `line_pos::Vector{Vector{Float64}}`: Collection of cells indices where the line is
                                       located. Result is not sorted and duplicates
                                       should be expected.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    a = [1.0, 0.5, 0.7]
    b = [0.7, 0.8, -0.3]
    line_ab = _calc_line_pos(a, b, 0.01, grid)
"""
function _calc_line_pos(
    a::Vector{T},
    b::Vector{T},
    delta::T,
    grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    # Line vector
    ab = b - a

    # Creating the unit vector
    nn = max(2, round(Int64, norm(ab) / delta) + 1)
    unit_vec = LinRange(0.0, 1.0, nn)

    # Initialization
    line_pos = [Vector{Int64}(undef,3) for _ in 1:nn]

    # Setting constants used for the vectorial decomposition
    c_x = a[1] / grid.cell_size_xy + grid.half_length_x + 1
    c_y = a[2] / grid.cell_size_xy + grid.half_length_y + 1
    c_z = a[3] / grid.cell_size_z + grid.half_length_z + 1
    d_x = ab[1] / grid.cell_size_xy
    d_y = ab[2] / grid.cell_size_xy
    d_z = ab[3] / grid.cell_size_z

    # Determining the cells where the line is located
    for ii in 1:nn
        line_pos[ii][1] = round(Int64, c_x + d_x * unit_vec[ii])
        line_pos[ii][2] = round(Int64, c_y + d_y * unit_vec[ii])
        line_pos[ii][3] = ceil(Int64, c_z + d_z * unit_vec[ii])
    end

    return line_pos
end
