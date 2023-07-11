# Documentation for body_soil.jl

## Introductory remarks
The function in this file has two important purposes:
- Moving the soil resting on the excavator bucket following the bucket's movement.
- Collecting the locations of the bucket soil and storing them in `out.body_soil_pos`.
While these tasks may initially appear straightforward, they are, in fact, quite complex due to the limited information available and the need to handle edge cases where soil from different locations ends up in the same position.

The first task of the function is to determine the new position of the bucket soil following the bucket's movement.
This process involves several steps to accurately calculate the soil's new resting position:
- The algorithm starts by taking the current position of the bucket where the soil is resting and calculates the corresponding position in the reference pose of the bucket.
- Next, the algorithm applies the updated bucket pose to this reference position to determine the new position where the bucket soil should now be resting.
This process is necessary because the orientation of the bucket is given relative to its reference pose.

The second task is to determine the appropriate bucket layer where the soil should be placed.
As it is assumed that the bucket movement between two steps is less than `cell_size_xy`, the soil is moved to the bucket layer that is within a vertical distance of `cell_size_xy` from the newly calculated position.
However, there can be complications, especially when `cell_size_z` is significantly lower than `cell_size_xy`.
In such cases, finding the correct bucket layer with the available information may be challenging.
If no bucket layer satisfies the above condition, the soil is moved to the terrain.

Note that it is crucial that this function is called after `_calc_bucket_pos!` and that the bucket pose has not yet been updated in the `BucketParam` struct.

## API
```@autodocs
Modules = [SoilDynamics]
Pages   = ["body_soil.jl"]
```
