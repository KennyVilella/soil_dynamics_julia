"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                       Starting implementation of utility functions                       #
#                                                                                          #
#==========================================================================================#
"""
    _init_sparse_array!(
        sparse_array::Vector{SparseMatrixCSC{T,I}},
        grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function reinitializes `sparse_array`.
`sparse_array` is expected to be either `body` or `body_soil`.

# Note
- This function is intended for internal use only.

# Inputs
- `sparse_array::Vector{SparseMatrixCSC{Float64,Int64}}`: Either `body` or `body_soil`.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _init_sparse_array!(out.body, grid)
"""
function _init_sparse_array!(
    sparse_array::Vector{SparseMatrixCSC{T,I}},
    grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    for ii in 1:length(sparse_array)
        droptol!(sparse_array[ii], 2*grid.half_length_z+1)
    end
end

"""
    _locate_all_non_zeros(
        sparse_array::Vector{SparseMatrixCSC{T,I}}
    ) where {I<:Int64,T<:Float64}

This function returns the indices of all non-zero values in `sparse_array`.
`sparse_array` is expected to be either `body` or `body_soil`.

# Note
- This function is intended for internal use only.
- The first index in the returned vector corresponds to the bucket layer, while the second
  and third indices are the indices in the X and Y direction, respectively.

# Inputs
- `sparse_array::Vector{SparseMatrixCSC{Float64,Int64}}`: Either `body` or `body_soil`.

# Outputs
- `Vector{Vector{Int64}}`:: Collection of cells indices where `sparse_array` is non-zero.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    body_soil_pos = _locate_all_non_zeros(out.body_soil)
"""
function _locate_all_non_zeros(
    sparse_array::Vector{SparseMatrixCSC{T,I}}
) where {I<:Int64,T<:Float64}

    # Locating all XY positions where sparse_array is nonzero
    non_zeros_1 = _locate_non_zeros(sparse_array[1])
    non_zeros_2 = _locate_non_zeros(sparse_array[2])
    non_zeros_3 = _locate_non_zeros(sparse_array[3])
    non_zeros_4 = _locate_non_zeros(sparse_array[4])

    # Aggregating by bucket layer
    non_zeros_1 = cat(non_zeros_1, non_zeros_2, dims=1)
    non_zeros_3 = cat(non_zeros_3, non_zeros_4, dims=1)

    # Removing duplicates
    unique!(non_zeros_1)
    unique!(non_zeros_3)

    # Compiling all positions
    non_zeros_pos = [[1; cell] for cell in non_zeros_1]
    append!(non_zeros_pos, [[3; cell] for cell in non_zeros_3])

    return non_zeros_pos
end

"""
    _locate_non_zeros(
        sparse_matrix::SparseMatrixCSC{T,I}
    ) where {I<:Int64,T<:Float64}

This function returns the indices of all non-zero values in a sparse Matrix.

# Note
- This function is intended for internal use only.
- This implementation is faster than a simple loop.

# Inputs
- `sparse_matrix::SparseMatrixCSC{Float64,Int64}`: Input Matrix for which non-zero values
                                                   should be located.

# Outputs
- `Vector{Vector{Int64}}`:: Collection of cells indices where the value of the input Matrix
                            is non-zero.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    non_zeros = _locate_non_zeros(out.body[1])
"""
function _locate_non_zeros(
    sparse_matrix::SparseMatrixCSC{T,I}
) where {I<:Int64,T<:Float64}

    # Intializing
    non_zeros = Vector{Vector{Int64}}()

    # Locating all XY position where the SparseMatrix is nonzero
    for col in 1:size(sparse_matrix, 2)
        for r in nzrange(sparse_matrix, col)
            push!(non_zeros, [rowvals(sparse_matrix)[r], col])
        end
    end

    return non_zeros
end

"""
    calc_normal(a::Vector{T}, b::Vector{T}, c::Vector{T}) where {T<:Float64}

This function calculates the unit normal vector of a plane formed by three points using
the right-hand rule.

# Note
- The input order of the points is important as it determines the sign of the unit normal
  vector based on the right-hand rule.

# Inputs
- `a::Vector{Float64}`: Cartesian coordinates of the first point of the plane. [m]
- `b::Vector{Float64}`: Cartesian coordinates of the second point of the plane. [m]
- `c::Vector{Float64}`: Cartesian coordinates of the third point of the plane. [m]

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
