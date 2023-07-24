# Introduction
This soil dynamics simulator is a fast first-order model designed to simulate soil displacement caused by the movement of an excavator bucket.
While excavator buckets have complex shapes to efficiently dig soil, here, for the sake of performance, the bucket is approximated as a simple triangular prism, which is a good representation for its overall shape.
A detailed description of the model used for the bucket is available on the [bucket](bucket.md) page of this documentation.

In this simulator, the movement of soil is modelled using a cellular automata approach on a regular 3D grid.
The simulation grid is composed of rectangular cells with equal length in the X and Y directions, and a height that is less than or equal to the cell's length (more details is available on the [Grid](grid.md) page of this documentation).
The fundamental idea of cellular automata is to decompose a simulation grid into cells that can have different states.
In this case, the state corresponds to soil, bucket or empty.
These cells can be moved at every step of the simulation depending on a set of rules.

At the start of each step, the bucket cells are assigned following the location of the bucket, and only soil cells are allowed to move.
There are two types of movement for soil cells: movement of intersecting soil cells and soil relaxation.
- Intersecting cells refer to cells where both soil and bucket are present due to the bucket movement.
  The soil in these intersecting cells have to be moved in response to the bucket movement.
  The movement of intersecting soil cells follows a complex set of rules that is described in the [intersecting_cells](intersecting_cells.md) page of this documentation.
- Soil relaxation refers to the natural movement of soil.
  Here, it is assumed that soil with a slope greater than the repose angle is unstable and should avalanche to reach a configuration where the slope is equal to the repose angle.
  However, implementing this simple model becomes challenging due to the interaction between soil and the bucket.
  The set of rules applied for soil relaxation is described in the [relax](relax.md) page of this documentation.

Please note that the terrain must be updated every time the bucket moves by more than one cell.
This ensures that the simulator keeps track of how the soil should be moved accurately.

In addition to the core functionalities, the structs used in this simulator are described in the [types](types.md) page of this documentation.
These `structs` provide a safe way of passing input arguments to the simulator's public functions, simplifying and accelerating the implementation.
Utilities functions are described in the [utils](utils.md) page of this documentation.
In particular, the functions used to check the outputs of the simulator or to write the outputs into csv files are described.
