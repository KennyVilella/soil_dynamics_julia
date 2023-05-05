"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                          Starting implementation of new types                            #
#                                                                                          #
#==========================================================================================#
"""
    GridParam{I<:Int64,T<:Float64}

Store all parameters related to the simulation grid.

Convention:
- The simulation grid is centred at 0, that is, if the extent of the grid is 10.0,
  then the grid would extend from -5.0 to 5.0, this applies to all direction.
- The grid is composed of regular 3D cells

                H-----------G
               /           /|
              /     O     / |
             /           /  |
            E-----------F   C
            |           |  /
            |           | /
            |           |/ 
            A-----------B

- The cells have the same size in both lateral direction
            AB = BC = CD = DA = EF = FG = GH = HE.
  while their height can potentially be lower
            AE = BF = CG = DH <= AB.
- The center of each cell (O) is considered to be at the center of the top surface.
- The considered reference frame follows the right-hand rule,
  with the Z direction pointing upward.

# Fields

- `half_length_x::Int64`: Number of grid elements in the positive (or negative) X direction.
- `half_length_y::Int64`: Number of grid elements in the positive (or negative) Y direction.
- `half_length_z::Float64`: Number of grid elements in the positive (or negative) Z
                            direction. Note that it is a Float.
- `cell_size_xy::Float64`: Size of the cells in the X and Y direction. [m]
- `cell_size_z::Float64`: Height of the cells in the Z direction. [m]
- `cell_area::Float64`: Surface area of the cells in the horizontal plane. [m^2]
- `cell_volume::Float64`: Volume of the cells. [m^3]

# Inner constructor

    GridParam(
        grid_size_x::T, grid_size_y::T, grid_size_z::T, cell_size_xy::T,
        cell_size_z::T=cell_size_xy
    ) where {T<:Float64}

Create a new instance of GridParam using the grid size in [m].
The actual size of the grid would be:
- [-grid_size_x, grid_size_x] in the X direction.
- [-grid_size_y, grid_size_y] in the Y direction.
- [-grid_size_z, grid_size_z] in the Z direction.

Requirements:
- All inputs should be greater than zero.
- cell_size_xy should be lower than or equal to grid_size_x and grid_size_y.
- cell_size_z should be lower than or equal to grid_size_z.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)

This would create a grid of size [-4, 4] in the X direction, [-4, 4] in the Y direction,
[-3, 3] in the Z direction, and with cells of size 0.05 x 0.05 x 0.01 in the XYZ direction.
"""
struct GridParam{I<:Int64,T<:Float64}
    half_length_x::I
    half_length_y::I
    half_length_z::T
    cell_size_xy::T
    cell_size_z::T
    cell_area::T
    cell_volume::T
    function GridParam(
        grid_size_x::T,
        grid_size_y::T,
        grid_size_z::T,
        cell_size_xy::T,
        cell_size_z::T=cell_size_xy
    ) where {T<:Float64}

        if ((cell_size_z < 0.0) || (cell_size_z ≈ 0.0))
                throw(DomainError(cell_size_z , "cell_size_z should be greater than zero"))
        end
        if ((cell_size_xy < 0.0) || ((cell_size_xy ≈ 0.0)))
            throw(DomainError(cell_size_xy, "cell_size_xy should be greater than zero"))
        end
        if ((grid_size_x < 0.0) || (grid_size_x ≈ 0.0))
            throw(DomainError(grid_size_x, "grid_size_x should be greater than zero"))
        end
        if ((grid_size_y < 0.0) || (grid_size_y ≈ 0.0))
            throw(DomainError(grid_size_y, "grid_size_y should be greater than zero"))
        end
        if ((grid_size_z < 0.0) || (grid_size_z ≈ 0.0))
            throw(DomainError(grid_size_z, "grid_size_z should be greater than zero"))
        end
        if (cell_size_z > cell_size_xy)
            throw(ErrorException(
                "cell_size_z should be lower than or equal to cell_size_xy"
            ))
        end
        if (grid_size_x < cell_size_xy)
                throw(ErrorException(
                    "cell_size_xy should be lower than or equal to grid_size_x"
                ))
        end
        if (grid_size_y < cell_size_xy)
            throw(ErrorException(
                "cell_size_xy should be lower than or equal to grid_size_y"
            ))
        end
        if (grid_size_z < cell_size_z)
            throw(ErrorException(
                "cell_size_z should be lower than or equal to grid_size_z"
            ))
        end

        half_length_x = round(Int64, grid_size_x / cell_size_xy)
        half_length_y = round(Int64, grid_size_y / cell_size_xy)
        half_length_z = round(grid_size_z / cell_size_z)

        cell_area = cell_size_xy * cell_size_xy
        cell_volume = cell_area * cell_size_z

        new{Int64,T}(
            half_length_x, half_length_y, half_length_z, cell_size_xy, cell_size_z,
            cell_area, cell_volume,
        )
    end
end
