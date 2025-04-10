#!/bin/bash

### Builds the job index
# Create a sequential range
array_values=`seq 60`

for i in $array_values
do 
# This submits the single job to the resource manager
sbatch simulation.slurm $i

done