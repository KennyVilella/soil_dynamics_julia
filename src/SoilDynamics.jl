module SoilDynamics

import LinearAlgebra: cross, norm
import ReferenceFrameRotations: vect, Quaternion

# types.jl
export GridParam, BucketParam

# bucket.jl
export _calc_bucket_pos
export _calc_rectangle_pos, _calc_triangle_pos, _calc_line_pos
export _decompose_vector_rectangle, _decompose_vector_triangle

# utils.jl
export calc_normal

# Files
include("types.jl")
include("bucket.jl")
include("utils.jl")

end
