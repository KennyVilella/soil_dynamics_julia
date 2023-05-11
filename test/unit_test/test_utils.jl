"""
Copyright, 2023,  Vilella Kenny.
"""
#==========================================================================================#
#                                                                                          #
#                                Setting dummy properties                                  #
#                                                                                          #
#==========================================================================================#


#==========================================================================================#
#                                                                                          #
#                                         Testing                                          #
#                                                                                          #
#==========================================================================================#
@testset "calc_normal" begin
    # Setting dummy coordinates forming a triangle in the XY plane
    a = [0.0, 0.0, 0.0]
    b = [2.3, 0.0, 0.0]
    c = [2.3, 2.45, 0.0]

    # Testing that the unit normal vector follows the Z direction
    @test calc_normal(a, b, c) == [0.0, 0.0, 1.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [0.0, 0.0, -1.0]

    # Setting dummy coordinates forming a triangle in the XZ plane
    a = [1.0, 0.0, -1.3]
    b = [0.3, 0.0, 4.2]
    c = [2.3, 0.0, 3.0]

    # Testing that the unit normal vector follows the Y direction
    @test calc_normal(a, b, c) == [0.0, 1.0, 0.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [0.0, -1.0, 0.0]

    # Setting dummy coordinates forming a triangle in the YZ plane
    a = [0.0, -4.7, 1.3]
    b = [0.0, 7.2, -0.6]
    c = [0.0, -1.0, 54.3]

    # Testing that the unit normal vector follows the X direction
    @test calc_normal(a, b, c) == [1.0, 0.0, 0.0]

    # Testing the opposite direction
    @test calc_normal(a, c, b) == [-1.0, 0.0, 0.0]

    # Setting dummy coordinates following a 45 degrees inclined plane
    a = [1.0, 0.0, 0.0]
    b = [0.0, 1.0, 0.0]
    c = [0.0, 0.0, 1.0]

    # Testing that the unit normal vector follows the inclined plane
    @test calc_normal(a, b, c) ≈ [sqrt(1/3), sqrt(1/3), sqrt(1/3)]

    # Testing the opposite direction
    @test calc_normal(a, c, b) ≈ -[sqrt(1/3), sqrt(1/3), sqrt(1/3)]
end
