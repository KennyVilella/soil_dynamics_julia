"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#
grid_size_x = 4.0
grid_size_y = 4.0
grid_size_z = 3.0
cell_size_xy = 0.05
cell_size_z = 0.01
grid = GridParam(grid_size_x, grid_size_y, grid_size_z, cell_size_xy, cell_size_z)


#==========================================================================================#
#                                                                                          #
#                                       Benchmarking                                       #
#                                                                                          #
#==========================================================================================#
# Setting benchmarking properties
BenchmarkTools.DEFAULT_PARAMETERS.gcsample = true
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 60
BenchmarkTools.DEFAULT_PARAMETERS.samples = 100

# Benchmarking for _calc_rectangle_pos function
a = [0.0, 0.0, 0.0]
b = [1.0, 0.0, 0.0]
c = [1.0, 0.5, 0.0]
d = [0.0, 0.5, 0.0]
delta = 0.01
println("_calc_rectangle_pos")
display(
    @benchmark rect_pos = _calc_rectangle_pos(a, b, c, d, delta, grid)
)
println("")

# Benchmarking for _decompose_vector_rectangle function
a_ind = [80.0, 80.0, 80.0]
ab_ind = [20.0, 3.0, 0.0]
ad_ind = [5.0, 19.0, 0.0]
area_min_x = 75
area_min_y = 75
area_length_x = 25
area_length_y = 25
println("_decompose_vector_rectangle")
display(
    @benchmark c_ab, c_ad, in_rectangle, n_cell = _decompose_vector_rectangle(
            ab_ind, ad_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
        )
)
println("")

# Benchmarking for _calc_triangle_pos function
a = [0.0, 0.0, 0.0]
b = [1.0, 0.0, 0.0]
c = [1.0, 0.5, 0.0]
delta = 0.01
println("_calc_triangle_pos")
display(
    @benchmark tri_pos = _calc_triangle_pos(a, b, c, delta, grid)
)
println("")

# Benchmarking for _decompose_vector_triangle function
a_ind = [80.0, 80.0, 80.0]
ab_ind = [20.0, 3.0, 0.0]
ac_ind = [5.0, 19.0, 0.0]
area_min_x = 75
area_min_y = 75
area_length_x = 25
area_length_y = 25
println("_decompose_vector_triangle")
display(
    @benchmark c_ab, c_ac, in_triangle, n_cell = _decompose_vector_triangle(
            ab_ind, ac_ind, a_ind, area_min_x, area_min_y, area_length_x, area_length_y
        )
)
println("")

# Benchmarking for _calc_line_pos function
a = [0.34, 0.56, 0.0]
b = [0.74, 0.97, 0.0]
delta = 0.01
println("_calc_line_pos")
display(
    @benchmark line_pos = _calc_line_pos(a, b, delta, grid)
)
println("")
