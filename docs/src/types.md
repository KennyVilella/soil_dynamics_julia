# Documentation for types.jl

## Introductory remarks
The simulator relies on `structs` to organize and manage the various parameters and properties.
These `structs` are designed to provide a clear and efficient way of passing input arguments to the simulator's public functions.

To ensure the integrity and validity of the input parameters, the `structs` are constructed using inner constructors that perform appropriate checks.
This guarantees that the simulator operates under the assumption of correct and consistent input data.
If incorrect parameters are provided, the user will be alerted through appropriate warnings or error messages.

In Julia, the default behavior for `float`, `bool`, and `int` fields in `structs` is immutability.
While immutability is desirable in some cases, it may not always align with the intended behavior of the simulator.
To address this, the approach taken here is to use `Vectors` containing a single element when mutability is required.
By using `Vectors`, `Matrices`, or `Arrays`, the mutability of the corresponding fields in the `structs` can be ensured, while maintaining performance efficiency.

The current implementation includes four distinct types of `structs`:
- `GridParam`: Aggregates all the properties related to the simulation grid.
- `BucketParam`: Aggregates all the properties associated with the bucket.
- `SimParam`: Aggregates the general parameters and settings for the simulation.
- `SimOut`: Aggregates and manages the output data generated during the simulation.

These `structs` play a crucial role in organizing and encapsulating the various aspects of the simulator, providing a convenient and structured way to work with the simulation inputs and outputs.

## API
```@autodocs
Modules = [SoilDynamics]
Pages   = ["types.jl"]
```
