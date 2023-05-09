module SoilDynamics

import LinearAlgebra: norm

# types.jl
export GridParam

# bucket.jl
export _calc_rectangle_pos, _calc_line_pos
export _decompose_vector_rectangle

# Files
include("types.jl")
include("bucket.jl")

end
