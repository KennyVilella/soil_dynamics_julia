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
        out::SimOut{B,I,T},
        grid::GridParam{I,T},
        sim::SimParam{I,T},
        tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function moves the soil in `terrain` in order to reach a state closer to equilibrium.

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
end

"""
    _locate_unstable_terrain_cell(
        out::SimOut{B,I,T},
        dh_max::T,
        tol::T=1e-8
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function locates all the cells that have a height difference larger than `dh_max` with
at least one neighboring cell, which may indicate that the soil column is unstable.

# Note
- This function is intended for internal use only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `dh_max::Float64`: Maximum height difference allowed between two neighboring cells. [m]
- `tol::Float64`: Small number used to handle numerical approximation errors.

# Outputs
- `unstable_cells::Vector{Vector{Int64}}`: Collection of cells indices that are possibly
                                           unstables.

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
