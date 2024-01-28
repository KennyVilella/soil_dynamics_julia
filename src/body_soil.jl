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
    old_body_soil_pos = deepcopy(out.body_soil_pos)

    # Resetting body_soil
    _init_sparse_array!(out.body_soil, grid)
    empty!(out.body_soil_pos)

    # Iterating over all XY positions where body_soil is present
    min_cell_height_diff = grid.cell_size_z + tol
    for cell in old_body_soil_pos
        ind = cell.ind[1]
        ii = cell.ii[1]
        jj = cell.jj[1]
        x_b = cell.x_b[1]
        y_b = cell.y_b[1]
        z_b = cell.z_b[1]
        h_soil = cell.h_soil[1]

        if (h_soil < 0.9 * grid.cell_size_z)
            # No soil to be moved
            # 0.9 has been chosen arbitrarily to account for potential
            # numerical errors, another value could be used
            continue
        end

        # Converting h_soil to a multiple of cell_size_z to deal with
        # accumulating floating errors
        h_soil = grid.cell_size_z * round(h_soil / grid.cell_size_z)

        # Calculating new cell position in global frame
        cell_local_pos = [x_b, y_b, z_b]
        new_cell_pos = pos + Vector{T}(vect(ori \ cell_local_pos * ori))
        old_cell_pos = bucket.pos + Vector{T}(
            vect(Quaternion(bucket.ori) \ cell_local_pos * Quaternion(bucket.ori))
        )

        # Establishing order of exploration
        dx = new_cell_pos[1] - old_cell_pos[1]
        dy = new_cell_pos[2] - old_cell_pos[2]
        sx = Int64(sign(dx))
        sy = Int64(sign(dy))
        if (abs(dx) > abs(dy))
            # Main direction follows X
            directions = [
                [0, 0], [sx, 0], [sx, sy], [0, sy], [sx, -sy],
                [0, -sy], [-sx, sy], [-sx, 0], [-sx, -sy]]
        else
            # Main direction follows Y
            directions = [
                [0, 0], [0, sy], [sx, sy], [sx, 0], [-sx, sy],
                [-sx, 0], [sx, -sy], [0, -sy], [-sx, -sy]];
        end

        # Calculating new cell indices
        ii_n = round(Int64, new_cell_pos[1] / grid.cell_size_xy + grid.half_length_x + 1)
        jj_n = round(Int64, new_cell_pos[2] / grid.cell_size_xy + grid.half_length_y + 1)

        # Initializing some variables
        soil_moved = false
        dist_s = 2 * grid.half_length_z
        ind_s = 0
        ii_s = 0
        jj_s = 0

        # Starting loop over neighbours
        for dir in directions
            # Determining cell to investigate
            ii_t = ii_n + dir[1]
            jj_t = jj_n + dir[2]

            # Detecting presence of body
            body_presence_1 = (
                !iszero(out.body[1][ii_t, jj_t]) || !iszero(out.body[2][ii_t, jj_t])
            )
            body_presence_3 = (
                !iszero(out.body[3][ii_t, jj_t]) || !iszero(out.body[4][ii_t, jj_t])
            )

            if (body_presence_1)
                # First body layer is present
                dist = abs(new_cell_pos[3] - out.body[2][ii_t, jj_t])
                if (dist < min_cell_height_diff)
                    # Moving body_soil to new location, this implementation
                    # works regardless of the presence of body_soil
                    out.body_soil[2][ii_t, jj_t] += (
                        out.body[2][ii_t, jj_t] - out.body_soil[1][ii_t, jj_t] + h_soil
                    )
                    out.body_soil[1][ii_t, jj_t] = out.body[2][ii_t, jj_t]

                    # Adding position to body_soil_pos
                    push!(out.body_soil_pos, BodySoil(1, ii_t, jj_t, x_b, y_b, z_b, h_soil))
                    soil_moved = true
                    break
                elseif (dist < dist_s)
                    # Updating new default location
                    dist_s = dist
                    ii_s = ii_t
                    jj_s = jj_t
                    ind_s = 2
                end
            end
            if (body_presence_3)
                # Second body layer is present
                dist = abs(new_cell_pos[3] - out.body[4][ii_t, jj_t])
                if (dist < min_cell_height_diff)
                    # Moving body_soil to new location, this implementation
                    # works regardless of the presence of body_soil
                    out.body_soil[4][ii_t, jj_t] += (
                        out.body[4][ii_t, jj_t] - out.body_soil[3][ii_t, jj_t] + h_soil
                    )
                    out.body_soil[3][ii_t, jj_t] = out.body[4][ii_t, jj_t]

                    # Adding position to body_soil_pos
                    push!(out.body_soil_pos, BodySoil(3, ii_t, jj_t, x_b, y_b, z_b, h_soil))
                    soil_moved = true
                    break
                elseif (dist < dist_s)
                    # Updating new default location
                    dist_s = dist
                    ii_s = ii_t
                    jj_s = jj_t
                    ind_s = 4
                end
            end
        end

        if (!soil_moved)
            if (abs(dist_s - 2 * grid.half_length_z) > tol)
                # Moving body_soil to closest location, this implementation
                # works regardless of the presence of body_soil
                out.body_soil[ind_s][ii_s, jj_s] += (
                    out.body[ind_s][ii_s, jj_s] - out.body_soil[ind_s-1][ii_s, jj_s] + h_soil
                )
                out.body_soil[ind_s-1][ii_s, jj_s] = out.body[ind_s][ii_s, jj_s]

                # Adding position to body_soil_pos
                push!(out.body_soil_pos, BodySoil(ind_s-1, ii_s, jj_s, x_b, y_b, z_b, h_soil))
            else
                # This should normally not happen, it is only for safety
                # Moving body_soil to terrain
                out.terrain[ii_n, jj_n] += h_soil
                @warn "WARNING\nBody soil could not be updated.\n" *
                    "Soil is moved to the terrain to maintain mass " *
                    "conservation."
            end
        end
    end

    # Updating new bucket position
    bucket.pos[:] .= pos[:]
    bucket.ori[:] .= ori[:]
end
