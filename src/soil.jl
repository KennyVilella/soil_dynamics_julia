"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#            Starting implementation of functions related to the soil movement             #
#                                                                                          #
#==========================================================================================#
"""
    _update_body_soil!(
        out::SimOut{I,T},
        pos::Vector{T},
        ori::Quaternion{T},
        grid::GridParam{I,T},
        bucket::BucketParam{T},
        tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function moves the soil resting on the bucket following its movement. To do so, the
movement applied to the base of the soil column is calculated and the soil is moved to this
new location. It is however difficult to track accurately each bucket wall. This is
currently done by looking at the height difference between the previous and new soil
locations, if this height difference is lower than `cell_size_xy`, it is assumed to be the
same bucket wall. Some errors may however be present and further testing is required.
If no bucket wall is present, the soil is moved down to the terrain.

#  Note
- This function is intended for internal use only.
- This function is a work in progress. Some optimization and improvements may be needed.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `pos::Vector{Float64}`: Cartesian coordinates of the bucket origin. [m]
- `ori::Quaternion{Float64}`: Orientation of the bucket. [Quaternion]
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `bucket::BucketParam{Float64}`: Struct that stores information related to the
                                  bucket object.

# Outputs
- None

# Example

    pos = [0.5, 0.3, 0.4]
    ori = angle_to_quat(0.0, -pi / 2, 0.0, :ZYX)
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    o = [0.0, 0.0, 0.0]
    j = [0.0, 0.0, 0.0]
    b = [0.0, 0.0, -0.5]
    t = [1.0, 0.0, -0.5]
    bucket = BucketParam(o, j, b, t, 0.5)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _update_body_soil!(out, pos, ori, grid, bucket)
"""
function _update_body_soil!(
    out::SimOut{I,T},
    pos::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T},
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Copying previous body_soil locations
    old_body_soil = deepcopy(out.body_soil)

    # Locating body_soil
    body_soil_pos = _locate_all_non_zeros(out, out.body_soil)

    # Resetting body_soil
    _init_body_soil!(out, grid)

    # Iterating over all XY positions where body_soil is present
    for cell in body_soil_pos
        # Processing cell information
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]

        # Converting indices to position
        cell_pos = [grid.vect_x[ii], grid.vect_y[jj], old_body_soil[ind][ii, jj]]

        # Inversing rotation
        inv_ori = inv_rotation(Quaternion(bucket.ori))

        # Calculating reference position of cell in bucket frame
        cell_local_pos = vect(inv_ori \ (cell_pos - bucket.pos) * inv_ori)

        # Calculating new cell position
        new_cell_pos = pos + vect(ori \ cell_local_pos * ori)

        # Calculating new cell indices
        ii_n = round(Int64, new_cell_pos[1] / grid.cell_size_xy + grid.half_length_x + 1)
        jj_n = round(Int64, new_cell_pos[2] / grid.cell_size_xy + grid.half_length_y + 1)

        if (
            (!iszero(out.body[1][ii_n, jj_n]) || !iszero(out.body[2][ii_n, jj_n])) &&
            (abs(new_cell_pos[3] - out.body[2][ii_n, jj_n]) - tol < grid.cell_size_xy)
        )
            ### Bucket is present ###
            # Moving body_soil to new location
            out.body_soil[2][ii_n, jj_n] += (
                (out.body[2][ii_n, jj_n] - out.body_soil[1][ii_n, jj_n]) +
                (old_body_soil[ind+1][ii, jj] - old_body_soil[ind][ii, jj])
            )
            out.body_soil[1][ii_n, jj_n] = out.body[2][ii_n, jj_n]
        elseif (
            (!iszero(out.body[3][ii_n, jj_n]) || !iszero(out.body[4][ii_n, jj_n])) &&
            (abs(new_cell_pos[3] - out.body[4][ii_n, jj_n]) - tol < grid.cell_size_xy)
        )
            ### Bucket is present ###
            # Moving body_soil to new location
            out.body_soil[4][ii_n, jj_n] += (
                (out.body[4][ii_n, jj_n] - out.body_soil[3][ii_n, jj_n]) +
                (old_body_soil[ind+1][ii, jj] - old_body_soil[ind][ii, jj])
            )
            out.body_soil[3][ii_n, jj_n] = out.body[4][ii_n, jj_n]
        else
            ### Bucket is not present ###
            # Moving body_soil to terrain
            # This may be problematic because another bucket wall may interfere,
            # but it seems to be a very edge case
            out.terrain[ii_n, jj_n] += (
                old_body_soil[ind+1][ii, jj] - old_body_soil[ind][ii, jj]
            )
        end
    end

    # Updating new bucket position
    bucket.pos[:] .= pos[:]
    bucket.ori[:] .= ori[:]
end

"""
    _init_body_soil!(
        out::SimOut{I,T},
        grid::GridParam{I,T}
    ) where {I<:Int64,T<:Float64}

This function reinitializes `body_soil`.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _init_body_soil!(out, grid)
"""
function _init_body_soil!(
    out::SimOut{I,T},
    grid::GridParam{I,T}
) where {I<:Int64,T<:Float64}

    for ii in 1:length(out.body_soil)
        droptol!(out.body_soil[ii], 2*grid.half_length_z+1)
    end
end

"""
    _body_to_terrain!(
        out::SimOut{I,T}, ii::I, jj::I, ind::I, ii_n::I, jj_n::I, grid::GridParam{I,T},
        delta_h::T=1e8, tol::T=1e-8
    ) where {I<:Int64,T<:Float64}

This function moves soil from `body_soil` at position (`ii`, `jj`) to the `terrain` at
position (`ii_n`, `jj_n`).
It is assumed that the required amount of soil is present on the bucket at the specifed
location, and that there is no bucket walls interfering with the avalanching soil.

# Note
- This function is intended for internal use only.
- By default, all available soil is moved to the terrain.

# Inputs
- `out::SimOut{Int64,Float64}`: Struct that stores simulation outputs.
- `ii::Int64`: Index of the avalanching soil position in the X direction.
- `jj::Int64`: Index of the avalanching soil position in the Y direction.
- `ind::Int64`: Index of the avalanching soil layer.
- `ii_n::Int64`: Index of the new soil position in the X direction.
- `jj_n::Int64`: Index of the new soil position in the Y direction.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid
    out.body_soil[1][11, 10] = 0.2
    out.body_soil[2][11, 10] = 0.4

    _body_to_terrain!(out, 11, 10, 1, 5, 7, grid)
"""
function _body_to_terrain!(
    out::SimOut{I,T},
    ii::I,
    jj::I,
    ind::I,
    ii_n::I,
    jj_n::I,
    grid::GridParam{I,T},
    delta_h::T=1e8,
    tol::T=1e-8
) where {I<:Int64,T<:Float64}

    # Calculating amount of soil present in body_soil
    h_soil = out.body_soil[ind+1][ii, jj] - out.body_soil[ind][ii, jj]

    if (delta_h + tol < h_soil)
        ### Soil is partially avalanching ###
        # Adding soil to terrain
        out.terrain[ii_n, jj_n] += delta_h

        # Updating body_soil
        out.body_soil[ind+1][ii, jj] -= delta_h
    elseif ((delta_h == 1e8) || (delta_h ≈ h_soil))
        ### All soil should avalanche ###
        # Adding soil to terrain
        out.terrain[ii_n, jj_n] += h_soil

        # Resetting body_soil
        out.body_soil[ind][ii, jj] = 0.0
        out.body_soil[ind+1][ii, jj] = 0.0
    else
        ### More soil than present should avalanche ###
        throw(ErrorException(
            "An amount of soil larger than what is present has been requested to be moved
            to the terrain"
        ))
    end
end
