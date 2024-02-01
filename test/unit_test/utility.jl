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
