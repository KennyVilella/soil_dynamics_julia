"""
Copyright, 2023,  Vilella Kenny.
"""
include("soil_evolution.jl")
#==========================================================================================#
#                                                                                          #
#                               Running the example script                                 #
#                                                                                          #
#==========================================================================================#
# Setting parameters
random_trajectory = false
set_RNG = true

# Launching the example script
soil_evolution(random_trajectory, set_RNG)
