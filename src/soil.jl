"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#            Starting implementation of functions related to the soil movement             #
#                                                                                          #
#==========================================================================================#
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
