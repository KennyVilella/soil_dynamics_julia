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
        out::SimOut{B,I,T}, pos::Vector{T}, ori::Quaternion{T}, grid::GridParam{I,T},
        bucket::BucketParam{T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves the soil resting on the bucket following its movement. To do so, the
movement applied to the base of the soil column is calculated and the soil is moved to this
new location. It is however difficult to track accurately each bucket wall. This is
currently done by looking at the height difference between the previous and new soil
locations, if this height difference is lower than `cell_size_xy`, it is assumed to be the
same bucket wall. Some errors may however be present and further testing is required.
If no bucket wall is present, the soil is moved down to the terrain.

The new positions of the soil resting on the bucket are collected into `out.body_soil_pos`
and duplicates are removed.

#  Note
- This function is intended for internal use only.
- This function is a work in progress. Some optimization and improvements may be needed.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
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
    out::SimOut{B,I,T},
    pos::Vector{T},
    ori::Quaternion{T},
    grid::GridParam{I,T},
    bucket::BucketParam{T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Copying previous body_soil locations
    old_body_soil = deepcopy(out.body_soil)
    old_body_soil_pos = deepcopy(out.body_soil_pos)

    # Resetting body_soil
    _init_sparse_array!(out.body_soil, grid)
    empty!(out.body_soil_pos)

    # Iterating over all XY positions where body_soil is present
    for cell in old_body_soil_pos
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]

        if (iszero(old_body_soil[ind][ii, jj]) && iszero(old_body_soil[ind+1][ii, jj]))
            ### No bucket soil at that position ###
            continue
        end

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

            # Adding position to body_soil_pos
            push!(out.body_soil_pos, [1, ii_n, jj_n])
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

            # Adding position to body_soil_pos
            push!(out.body_soil_pos, [3, ii_n, jj_n])
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

    # Removing duplicates in body_soil_pos
    unique!(out.body_soil_pos)

    # Updating new bucket position
    bucket.pos[:] .= pos[:]
    bucket.ori[:] .= ori[:]
end
