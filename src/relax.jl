"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#           Starting implementation of functions related to the soil relaxation            #
#                                                                                          #
#==========================================================================================#
"""
    _relax_terrain!(
        out::SimOut{B,I,T}, grid::GridParam{I,T}, sim::SimParam{I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves the soil in `terrain` towards a state closer to equilibrium.
The soil stability is determined by the `repose_angle`. If the slope formed by two
neighboring soil columns exceeds the `repose_angle`, it is considered unstable, and the soil
from the higher column should avalanche to the neighboring column to reach an equilibrium
state.

By convention, this function only checks the stability of the soil in the four adjacent
cells:
                     ↑
                   ← O →
                     ↓

The diagonal directions are not checked for simplicity and performance reasons.

This function only moves the soil when the following conditions are met:

(1) The soil column in the neighboring cell is low enough.
(2) Either:
        (a) The bucket is not on the soil, meaning there is space between the `terrain` and
            the bucket, or there is no bucket.
        (b) The bucket is on the `terrain`, but the combination of the bucket and bucket
            soil is not high enough to prevent soil avalanche.

In case (2a), the soil will avalanche on the `terrain`, while in case (2b), the soil will
avalanche on the bucket.

# Note
- This function is intended for internal use only.
- This function is a work in progress.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `sim::SimParam{Int64,Float64}`: Struct that stores information related to the
                                  simulation.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example
    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    sim = SimParam(0.85, 3)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _relax_terrain!(out, grid, sim)
"""
function _relax_terrain!(
    out::SimOut{B,I,T},
    grid::GridParam{I,T},
    sim::SimParam{I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Assuming that the terrain is at equilibrium
    out.equilibrium[1] = true

    # Calculating the maximum slope allowed by the repose angle
    slope_max = tan(sim.repose_angle)
    # Calculating the maximum height different allowed by the repose angle
    dh_max = grid.cell_size_xy * slope_max
    dh_max = grid.cell_size_z * round(dh_max / grid.cell_size_z)

    # Locating cells requiring relaxation
    unstable_cells = _locate_unstable_terrain_cell(out, dh_max, tol)

    if isempty(unstable_cells)
        ### Terrain is already at equilibrium ###
        return nothing
    end

    # Randomizing unstable cells to reduce asymmetry
    shuffle!(unstable_cells)

    # Iterating over all unstable cells
    for cell in unstable_cells
        ii = cell[1]
        jj = cell[2]

        # Storing all possible directions for relaxation
        directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]

        # Randomizing direction to avoid asymmetry
        shuffle!(directions)

        # Iterating over the possible directions
        for xy in directions
            ii_c = ii + xy[1]
            jj_c = jj + xy[2]

            # Calculating minimum height allowed surrounding the considered soil cell
            h_min = out.terrain[ii, jj] - dh_max

            # Checking if the cell requires relaxation
            status = _check_unstable_terrain_cell(out, ii_c, jj_c, h_min, tol)

            if (status == 0)
                ### Soil cell already at equilibrium ###
                continue
            else
                ### Soil cell requires relaxation ###
                out.equilibrium[1] = false
            end

            # Relaxing the soil cell
            _relax_unstable_cell!(
                out, status, dh_max, ii, jj, ii_c, jj_c, grid,  tol
            )
        end
    end
end

"""
    _locate_unstable_terrain_cell(
        out::SimOut{B,I,T}, dh_max::T, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function locates all the cells in `terrain `that have a height difference larger than
`dh_max` with at least one neighboring cell. Such height difference may indicate that the
soil column is unstable. However, it is important to note that this condition is not
necessarily indicative of an actual soil instability, as a bucket or the soil resting on it
could be supporting the soil column.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `dh_max::Float64`: Maximum height difference allowed between two neighboring cells. [m]
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `unstable_cells::Vector{Vector{Int64}}`: Collection of cells indices that are possibly
                                           unstable.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    unstable_cells = _locate_unstable_terrain_cell(out, 0.1)
"""
function _locate_unstable_terrain_cell(
    out::SimOut{B,I,T},
    dh_max::T,
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Initializing
    unstable_cells = Vector{Vector{Int64}}()

    # Iterating over the terrain
    for ii in 2:size(out.terrain, 1) - 1
        for jj in 2:size(out.terrain, 2) - 1
            # Calculating the minimum height allowed surrounding the considered soil cell
            h_min = out.terrain[ii, jj] - dh_max

            if (
                (out.terrain[ii - 1, jj] + tol < h_min) ||
                (out.terrain[ii + 1, jj] + tol < h_min) ||
                (out.terrain[ii, jj - 1] + tol < h_min) ||
                (out.terrain[ii, jj + 1] + tol < h_min)
            )
                ### Soil cell is requiring relaxation ###
                push!(unstable_cells, [ii, jj])
            end
        end
    end

    return unstable_cells
end

"""
    _check_unstable_terrain_cell(
        out::SimOut{B,I,T}, ii_c::I, jj_c::I, h_min::T, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function checks the stability of a soil column in `terrain` compared to one of its
neighbor (`ii_c`, `jj_c`). In case of instability, the function returns a three-digit
number (`status`) that provides information on how the soil should avalanche.
The interpretation of the three-digit number is described below.

The first digit indicates the potential presence of the bucket:
- 1 when the first bucket layer is present.
- 2 when the second bucket layer is present.
- 3 when the two bucket layers are present.
- 4 when no bucket layer is present.

The second digit indicates the layer at the top where the soil should avalanche:
- 0 when it is the `terrain` (no bucket is present).
- 1 when it is the second bucket soil layer.
- 2 when it is the second bucket layer.
- 3 when it is the first bucket soil layer.
- 4 when it is the first bucket layer.

The third digit indicates whether the soil should avalanche below or above the bucket:
- 0 when there is no bucket.
- 1 when the soil should avalanche below the bucket.
- 2 when the soil should avalanche on the top of the bucket.

The combination of these three digits provides a comprehensive description of how the soil
should avalanche in different scenarios.

# Note
- This function is intended for internal use only.
- Not all combinations for `status` are possible. Some combinations, such as `401`, `231`
  and `220`, are impossible.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `ii_c::Int64`: Index of the neighboring cell in the X direction.
- `jj_c::Int64`: Index of the neighboring cell in the Y direction.
- `h_min::Float64`: Minimum allowed height for a stable configuration. [m]
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `status::Int64`: Three-digit number indicating how the soil should avalanche.
                   `0` is returned if the soil column is stable.

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    status = _check_unstable_terrain_cell(out, 10, 15, -0.1)
"""
function _check_unstable_terrain_cell(
    out::SimOut{B,I,T},
    ii_c::I,
    jj_c::I,
    h_min::T,
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    if (out.terrain[ii_c, jj_c] + tol < h_min)
        ### Adjacent terrain is low enough ###
        bucket_presence_1 = (
            (out.body[1][ii_c, jj_c] != 0.0) || (out.body[2][ii_c, jj_c] != 0.0)
        )
        bucket_presence_3 = (
            (out.body[3][ii_c, jj_c] != 0.0) || (out.body[4][ii_c, jj_c] != 0.0)
        )
        if (bucket_presence_1 || bucket_presence_3)
            ### Bucket is present ###
            # Calculating extension of bucket and soil
            if (!bucket_presence_1)
                ### Only the second bucket layer is present ###
                status = 200
                bucket_bot = out.body[3][ii_c, jj_c]
                if (
                    (out.body_soil[3][ii_c, jj_c] != 0.0) ||
                    (out.body_soil[4][ii_c, jj_c] != 0.0)
                )
                    ### Bucket soil is present ###
                    status += 10
                    column_top = out.body_soil[4][ii_c, jj_c]
                else
                    ### Bucket soil is not present ###
                    status += 20
                    column_top = out.body[4][ii_c, jj_c]
                end
            elseif (!bucket_presence_3)
                status = 100
                ### Only the first bucket layer is present ###
                bucket_bot = out.body[1][ii_c, jj_c]
                if (
                    (out.body_soil[1][ii_c, jj_c] != 0.0) ||
                    (out.body_soil[2][ii_c, jj_c] != 0.0)
                )
                    ### Bucket soil is present ###
                    status += 30
                    column_top = out.body_soil[2][ii_c, jj_c]
                else
                    ### Bucket soil is not present ###
                    status += 40
                    column_top = out.body[2][ii_c, jj_c]
                end
            else
                ### Two bucket layers are present ###
                status = 300
                bucket_bot, min_ind = findmin(
                    [out.body[1][ii_c, jj_c], out.body[3][ii_c, jj_c]]
                )
                if (min_ind == 1)
                    ### First bucket layer is lower ###
                    if (
                        (out.body_soil[3][ii_c, jj_c] != 0.0) ||
                        (out.body_soil[4][ii_c, jj_c] != 0.0)
                    )
                        ### Bucket soil is present ###
                        status += 10
                        column_top = out.body_soil[4][ii_c, jj_c]
                    else
                        ### Bucket soil is not present ###
                        status += 20
                        column_top = out.body[4][ii_c, jj_c]
                    end
                else
                    ### Second bucket layer is lower ###
                    if (
                        (out.body_soil[1][ii_c, jj_c] != 0.0) ||
                        (out.body_soil[2][ii_c, jj_c] != 0.0)
                    )
                        ### Bucket soil is present ###
                        status += 30
                        column_top = out.body_soil[2][ii_c, jj_c]
                    else
                        ### Bucket soil is not present ###
                        status += 40
                        column_top = out.body[2][ii_c, jj_c]
                    end
                end
            end

            if (out.terrain[ii_c, jj_c] + tol < bucket_bot)
                ### Space under the bucket ###
                return status + 1
            end

            if (column_top + tol < h_min)
                ### Column is low enough ###
                return status + 2
            end
        else
            ### No bucket ###
            return 400
        end
    end

    return 0
end

"""
    _relax_unstable_cell!(
        out::SimOut{B,I,T}, status::I, dh_max::T, ii::I, jj::I, ii_c::I, jj_c::I,
        grid::GridParam{I,T}, tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves the soil from the `terrain` at (`ii`, `jj`) to the soil column in
(`ii_c`, `jj_c`). The precise movement depends on the `status` number as explained in the
`_check_unstable_terrain_cell` function.

The soil is moved such that the slope formed by the two neighboring soil columns is equal to
the `repose_angle`. When the bucket is preventing this configuration, the soil avalanche
below the bucket to fill the space under it.

# Note
- This function is intended for internal use only.
- It is assumed that the given `status` is accurate, so no extra checks are present.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `status::Int64`: Three-digit number indicating how the soil should avalanche.
- `dh_max::Float64`: Maximum height difference allowed between two neighboring cells. [m]
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `ii_c::Int64`: Index of the neighboring cell in the X direction.
- `jj_c::Int64`: Index of the neighboring cell in the Y direction.
- `grid::GridParam{Int64,Float64}`: Struct that stores information related to the
                                    simulation grid.
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    _relax_unstable_cell!(out, 131, 0.1, 10, 15, 10, 14, grid)
"""
function _relax_unstable_cell!(
    out::SimOut{B,I,T},
    status::I,
    dh_max::T,
    ii::I,
    jj::I,
    ii_c::I,
    jj_c::I,
    grid::GridParam{I,T},
    tol::T=1e-8
) where {B<:Bool,I<:Int64,T<:Float64}

    # Converting status into a string for convenience
    st = string(status)

    # Calculating new height values
    h_new = 0.5 * (dh_max + out.terrain[ii, jj] + out.terrain[ii_c, jj_c])
    h_new = grid.cell_size_z * floor((h_new + tol) / grid.cell_size_z)
    h_new_c = out.terrain[ii, jj] + out.terrain[ii_c, jj_c] - h_new

    if (status == 400)
        ### No Bucket ###
        # Updating terrain
        out.terrain[ii, jj] = h_new
        out.terrain[ii_c, jj_c] = h_new_c
    elseif (st[3] == '1')
        ### Space under the bucket ###
        if (st[1] == '1')
            ### Under the first bucket layer ###
            bucket_bot = out.body[1][ii_c, jj_c]
        elseif (st[1] == '2')
            ### Under the second bucket layer ###
            bucket_bot = out.body[3][ii_c, jj_c]
        elseif (st[1] == '3')
            ### Two bucket layers present ###
            bucket_bot = min(out.body[1][ii_c, jj_c], out.body[3][ii_c, jj_c])
        end

        if (h_new_c < bucket_bot)
            ### Full avalanche ###
            out.terrain[ii, jj] = h_new
            out.terrain[ii_c, jj_c] = h_new_c
        else
            ### Partial avalanche ###
            out.terrain[ii, jj] = out.terrain[ii, jj] + out.terrain[ii_c, jj_c] - bucket_bot
            out.terrain[ii_c, jj_c] = bucket_bot
        end
    elseif (st[3] == '2')
        ### Soil should avalanche on the bucket ###
        if (st[2] == '1')
            ### Soil avalanche on the second bucket soil layer ###
            h_new = 0.5 * (dh_max + out.terrain[ii, jj] + out.body_soil[4][ii_c, jj_c])
            h_new = grid.cell_size_z * floor((h_new + tol) / grid.cell_size_z)
            h_new_c = out.terrain[ii, jj] + out.body_soil[4][ii_c, jj_c] - h_new

            # Updating terrain
            out.terrain[ii, jj] = h_new
            out.body_soil[4][ii_c, jj_c] = h_new_c
        elseif (st[2] == '2')
            ### Soil avalanche on the second bucket layer ###
            h_new = 0.5 * (dh_max + out.terrain[ii, jj] + out.body[4][ii_c, jj_c])
            h_new = grid.cell_size_z * floor((h_new + tol) / grid.cell_size_z)
            h_new_c = out.terrain[ii, jj] + out.body[4][ii_c, jj_c] - h_new

            # Updating terrain
            out.terrain[ii, jj] = h_new
            out.body_soil[3][ii_c, jj_c] = out.body[4][ii_c, jj_c]
            out.body_soil[4][ii_c, jj_c] = h_new_c
        elseif (st[2] == '3')
            ### Soil avalanche on the first bucket soil layer ###
            h_new = 0.5 * (dh_max + out.terrain[ii, jj] + out.body_soil[2][ii_c, jj_c])
            h_new = grid.cell_size_z * floor((h_new + tol) / grid.cell_size_z)
            h_new_c = out.terrain[ii, jj] + out.body_soil[2][ii_c, jj_c] - h_new

            # Updating terrain
            out.terrain[ii, jj] = h_new
            out.body_soil[2][ii_c, jj_c] = h_new_c
        elseif (st[2] == '4')
            ### Soil avalanche on the first bucket layer ###
            h_new = 0.5 * (dh_max + out.terrain[ii, jj] + out.body[2][ii_c, jj_c])
            h_new = grid.cell_size_z * floor((h_new + tol) / grid.cell_size_z)
            h_new_c = out.terrain[ii, jj] + out.body[2][ii_c, jj_c] - h_new

            # Updating terrain
            out.terrain[ii, jj] = h_new
            out.body_soil[1][ii_c, jj_c] = out.body[2][ii_c, jj_c]
            out.body_soil[2][ii_c, jj_c] = h_new_c
        end
    end
end
