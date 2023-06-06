# Soil dynamics simulator

[![Build status](https://github.com/KennyVilella/soil_dynamics_julia/workflows/CI/badge.svg)](https://github.com/KennyVilella/soil_dynamics_julia/actions)
[![](https://img.shields.io/badge/docs-main-blue.svg)][docs-main]


<code><b> Note:
This is still a work in progress and the first fully working version has not yet been released.</b> </code>

This soil dynamics simulator is a fast first-order model designed to simulate soil displacement caused by the movement of an excavator bucket.
It employs a cellular automata approach to model the behavior of the soil.
The bucket geometry is assumed to be a simple triangular prism, and the simulator operates on a grid composed of rectangular cells with equal length in the X and Y directions, and a height that is less than or equal to the cell's length.
A crucial requirement of the simulator is that the terrain must be updated every time the bucket moves by more than one cell.

The primary objective of the simulator is to provide terrain updates in less than 1 ms, making it suitable for real-time applications.

## To-do list

There are several important features that are yet to be implemented.
These include, in order of priority:

- Bucket soil relaxation: Implement the relaxation of soil on the bucket.
- Code optimization: Enhance the overall performance and efficiency of the codebase.
- Documentation: Provide comprehensive and user-friendly documentation for the simulator.
- Integration testing: Conduct thorough integration tests to ensure the functionality of the simulator.
- Multiple digging buckets: Add support for simulating the behavior of multiple digging buckets simultaneously.
- Force calculation: Incorporate force calculation methods for better integration with rigid body engines.
- Heterogeneous soil properties: Extend the simulator to handle soil properties that vary across the terrain.

## Running the simulator

An example script for using the simulator can be found in the `test/example` folder.
The `soil_evolution.jl` file contains the implementation, while `test_soil_evolution.jl` can be used to execute the script.
To run the simulator, please use the following command in the Julia REPL from the repository root
```
 import Pkg; Pkg.activate("."); Pkg.instantiate(); include("test/example/test_soil_evolution.jl")
```

To run the unit tests, execute the following command from the repository root
```
import Pkg; Pkg.activate("."); Pkg.instantiate(); include("test/runtests.jl")
```

Furthermore, a script is available to run a benchmark test for all functions of the simulator.
This can be done by executing the following command from the repository root
```
import Pkg; Pkg.activate("."); Pkg.instantiate(); include("test/run_benchmarks.jl")
```
Please note that running all the benchmark tests may take from 10 min to 30 min.

## Visualizing results

The example script provides options to write the results into CSV files.
The following options can be enabled to write the results at each time-step:
- `writing_bucket_files`: Write the bucket corners.
- `writing_soil_files`: Write the terrain and the soil resting on the bucket.

[ParaView][] can be used to visualize the results.
To do so, follow these steps
- Import the CSV files.
- Right click on the data -> Add filter -> Table to points (make sure to adjust the XYZ columns accordingly).
- Right click on the TableToPoints data -> Add filter -> Delaunay 2D (or use Delaunay 3D for the bucket).
- Customize the visualization by adjusting colors, opacity, and other parameters to enhance the visualization.

[docs-main]: https://kennyvilella.github.io/soil_dynamics_julia/
[ParaView]: https://www.paraview.org
