"""
Copyright, 2024,  Vilella Kenny.
"""

using SoilDynamics
#==========================================================================================#
#                                                                                          #
#            Starting implementation of utility functions used for unit testing            #
#                                                                                          #
#==========================================================================================#
"""
    set_height(
        out::SimOut{B,I,T}, ii::I, jj::I, terrain::T, body_1::T, body_2::T,
        body_soil_1::T, body_soil_2::T, body_3::T, body_4::T, body_soil_3::T, body_soil_4::T
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function set the height of the different layers at a given (`ii`, `jj`) position.
`NaN` should be provided if no layer is present.

# Note
- This function is intended for unit testing only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `terrain::Float64`: Height of the terrain. [m]
- `body_1::Float64`: Minimum height of the first body layer. [m]
- `body_2::Float64`: Maximum height of the first body layer. [m]
- `body_soil_1::Float64`: Minimum height of the first body soil layer. [m]
- `body_soil_2::Float64`: Maximum height of the first body soil layer. [m]
- `body_3::Float64`: Minimum height of the second body layer. [m]
- `body_4::Float64`: Maximum height of the second body layer. [m]
- `body_soil_3::Float64`: Minimum height of the second body soil layer. [m]
- `body_soil_4::Float64`: Maximum height of the second body soil layer. [m]

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    set_height(out, 10, 15, 0.5, NaN, NaN, 0.2, 0.3, 0.5, 0.6, NaN, NaN)
"""
function set_height(
    out::SimOut{B,I,T},
    ii::I,
    jj::I,
    terrain::T,
    body_1::T,
    body_2::T,
    body_soil_1::T,
    body_soil_2::T,
    body_3::T,
    body_4::T,
    body_soil_3::T,
    body_soil_4::T
) where {B<:Bool,I<:Int64,T<:Float64}

    # Setting terrain
    if (!isnan(terrain))
        out.terrain[ii, jj] = terrain
    end

    # Setting body
    if (!isnan(body_1))
        out.body[1][ii, jj] = body_1
    end
    if (!isnan(body_2))
        out.body[2][ii, jj] = body_2
    end
    if (!isnan(body_3))
        out.body[3][ii, jj] = body_3
    end
    if (!isnan(body_4))
        out.body[4][ii, jj] = body_4
    end

    # Setting body_soil
    if (!isnan(body_soil_1))
        out.body_soil[1][ii, jj] = body_soil_1
    end
    if (!isnan(body_soil_2))
        out.body_soil[2][ii, jj] = body_soil_2
    end
    if (!isnan(body_soil_3))
        out.body_soil[3][ii, jj] = body_soil_3
    end
    if (!isnan(body_soil_4))
        out.body_soil[4][ii, jj] = body_soil_4
    end
end

"""
    check_height(
        out::SimOut{B,I,T}, ii::I, jj::I, terrain::T, body_soil_1::T, body_soil_2::T,
        body_soil_3::T, body_soil_4::T
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function checks the height of the different layers at a given (`ii`, `jj`) position
against the provided values. `NaN` should be provided if checking is not needed.

# Note
- This function is intended for unit testing only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `terrain::Float64`: Height of the terrain. [m]
- `body_soil_1::Float64`: Minimum height of the first body soil layer. [m]
- `body_soil_2::Float64`: Maximum height of the first body soil layer. [m]
- `body_soil_3::Float64`: Minimum height of the second body soil layer. [m]
- `body_soil_4::Float64`: Maximum height of the second body soil layer. [m]

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    check_height(out, 10, 15, 0.5, NaN, NaN, 0.2, 0.3)
"""
function check_height(
    out::SimOut{B,I,T},
    ii::I,
    jj::I,
    terrain::T,
    body_soil_1::T,
    body_soil_2::T,
    body_soil_3::T,
    body_soil_4::T
) where {B<:Bool,I<:Int64,T<:Float64}

    # Checking terrain
    if (!isnan(terrain))
        @test (abs(out.terrain[ii, jj] - terrain) < 1e-8)
    end

    # Checking body_soil
    if (!isnan(body_soil_1))
        @test (abs(out.body_soil[1][ii, jj] - body_soil_1) < 1e-8)
    end
    if (!isnan(body_soil_2))
        @test (abs(out.body_soil[2][ii, jj] - body_soil_2) < 1e-8)
    end
    if (!isnan(body_soil_3))
        @test (abs(out.body_soil[3][ii, jj] - body_soil_3) < 1e-8)
    end
    if (!isnan(body_soil_4))
        @test (abs(out.body_soil[4][ii, jj] - body_soil_4) < 1e-8)
    end
end

"""
    reset_value_and_test(
        out::SimOut{B,I,T}, terrain_pos::Vector{Vector{I}}, body_pos::Vector{Vector{I}},
        body_soil_pos::Vector{Vector{I}}
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function resets the requested outputs and checks that all `terrain`, `body` and
`body_soil` is properly reset. This can be used to catch potential unexpected modifications
of the outputs.

# Note
- This function is intended for unit testing only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `terrain_pos::Vector{Vector{Int64}}`: Collection of terrain cells that should be reset.
- `body_pos::Vector{Vector{Int64}}`: Collection of body cells that should be reset.
- `body_soil_pos::Vector{Vector{Int64}}`: Collection of body soil cells that should be reset.

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

    reset_value_and_test((out, [[10, 15], [5, 7]], [[]], [[1, 15, 10], [3, 15, 10]])
"""
function reset_value_and_test(
    out::SimOut{B,I,T},
    terrain_pos::Vector{Vector{I}},
    body_pos::Vector{Vector{I}},
    body_soil_pos::Vector{Vector{I}}
) where {B<:Bool,I<:Int64,T<:Float64}

    # Resetting requested terrain
    for cell in terrain_pos
        ii = cell[1]
        jj = cell[2]
        out.terrain[ii, jj] = 0.0
    end

    # Resetting requested body
    for cell in body_pos
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]
        out.body[ind][ii, jj] = 0.0
        out.body[ind+1][ii, jj] = 0.0
    end
    dropzeros!(out.body[1])
    dropzeros!(out.body[2])
    dropzeros!(out.body[3])
    dropzeros!(out.body[4])

    # Resetting requested body_soil
    for cell in body_soil_pos
        ind = cell[1]
        ii = cell[2]
        jj = cell[3]
        out.body_soil[ind][ii, jj] = 0.0
        out.body_soil[ind+1][ii, jj] = 0.0
    end
    dropzeros!(out.body_soil[1])
    dropzeros!(out.body_soil[2])
    dropzeros!(out.body_soil[3])
    dropzeros!(out.body_soil[4])

    # Checking that everything is properly reset
    for ii in 1:size(out.terrain, 1)
        for jj in 1:size(out.terrain, 2)
            @test (out.terrain[ii, jj] == 0.0)
        end
    end
    @test isempty(nonzeros(out.body[1]))
    @test isempty(nonzeros(out.body[2]))
    @test isempty(nonzeros(out.body[3]))
    @test isempty(nonzeros(out.body[4]))
    @test isempty(nonzeros(out.body_soil[1]))
    @test isempty(nonzeros(out.body_soil[2]))
    @test isempty(nonzeros(out.body_soil[3]))
    @test isempty(nonzeros(out.body_soil[4]))

    # Resetting body_soil_pos
    empty!(out.body_soil_pos)
end

"""
    push_body_soil_pos(
        out::SimOut{B,I,T}, ind::I, ii::I, jj::I, pos::Vecot{T}, h_soil::T
    ) where {B<:Bool,I<:Int64,T<:Float64}

This function pushes a new `BodySoil` struct into `body_soil_pos`.

# Note
- This function is intended for unit testing only.

# Inputs
- `out::SimOut{Bool,Int64,Float64}`: Struct that stores simulation outputs.
- `ind::Int64`: Index of the soil layer.
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `pos::Vector{Float64}`: Cartesian coordinates of the body soil in the
                          reference bucket frame. [m]
- `h_soil::Float64`: Height of the soil column. [m]

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)

     push_body_soil_pos(out, 1, 10, 15, [0.1, 0.15, 0.0], 0.3)
"""
function push_body_soil_pos(
    out::SimOut{B,I,T},
    ind::I,
    ii::I,
    jj::I,
    pos::Vector{T},
    h_soil::T
) where {B<:Bool,I<:Int64,T<:Float64}

    push!(out.body_soil_pos, BodySoil(ind, ii, jj, pos[1], pos[2], pos[3], h_soil))
end

"""
    check_body_soil_pos(
        body_soil_pos::BodySoil{I,T}, ind::I, ii::I, jj::I, pos::Vecot{T}, h_soil::T
    ) where {I<:Int64,T<:Float64}

This function checks the values of an inputted `BodySoil` struct against provided values.

# Note
- This function is intended for unit testing only.

# Inputs
- `body_soil_pos::BodySoil{Int64,Float64}`: `BodySoil` struct to be checked.
- `ind::Int64`: Index of the soil layer.
- `ii::Int64`: Index of the considered cell in the X direction.
- `jj::Int64`: Index of the considered cell in the Y direction.
- `pos::Vector{Float64}`: Cartesian coordinates of the body soil in the
                          reference bucket frame. [m]
- `h_soil::Float64`: Height of the soil column. [m]

# Outputs
- None

# Example

    grid = GridParam(4.0, 4.0, 3.0, 0.05, 0.01)
    terrain = zeros(2 * grid.half_length_x + 1, 2 * grid.half_length_y + 1)
    out = SimOut(terrain, grid)
    push!(out.body_soil_pos, BodySoil(1, 10, 11, 0.1, 0.0, 0.2, 0.5))

    check_body_soil_pos(out.body_soil_pos[1], 1, 10, 11, [0.1, 0.0, 0.2], 0.5)
"""
function check_body_soil_pos(
    body_soil_pos::BodySoil{I,T},
    ind::I,
    ii::I,
    jj::I,
    pos::Vector{T},
    h_soil::T
) where {I<:Int64,T<:Float64}

    # Checking the body soil position
    @test (body_soil_pos.ind[1] == ind)
    @test (body_soil_pos.ii[1] == ii)
    @test (body_soil_pos.jj[1] == jj)
    @test (body_soil_pos.x_b[1] ≈ pos[1])
    @test (body_soil_pos.y_b[1] ≈ pos[2])
    @test (body_soil_pos.z_b[1] ≈ pos[3])
    @test (body_soil_pos.h_soil[1] ≈ h_soil)
end
