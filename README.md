# AWE-Battery-HPS

A techno-economic model simulating the energy and economic performance of an airborne wind energy and batteries hybrid power system. The model is formulated as project lifetime simulations based on consecutive yearly performance where the AWE power and battery storage of a system is simulated for given market and wind conditions.\

1. It requires integration with AWE performance and cost models, the performance model used is located at https://github.com/awegroup/AWE-Power and the cost model at https://github.com/awegroup/AWE-Eco.
2. The model accounts for the effects of battery degradation and can be used for multiple storage technologies.


## Dependencies

The model is built and tested in MATLAB R2021b (without additional add-ons). Try installing this version if your version of MATLAB does not execute the code successfully.


## Installation and execution 

Please Clone or Download the repository to start using the model.


## Overview of the Repository

The Repository consists following folders:

1. `src`: Contains the source code of the model and scripts used to generate plots used in the associated MSc thesis report.
2. `inputFiles`: Contains some pre-defined input files as well as wind speed and day-ahead market data sets.
3. `lib`: Contains external functions required to run the model.
4. `outputFiles`: Contains the simulated results generated after running the main script.



## Pre-defined Example Simulation

A pre-defined input file named `inputFile_100kW_AWEHPS.yml` is stored in the folder `inputFiles`. This input file simulates a system with rated electrical power of 100 kW.

1. Execute `main_AWE_HPS.m` to simulate the AWE HPS using the pre-generated outputs of awe-Power and awe-Eco contained in the 'inputFile_100kW_AWEHPS'.
2. Navigate to the 'Plots' section of the script to uncomment any subsections of plots and execute the script again to visualize relevant outputs. These sections correspond to chapters in the MSc thesis report.


## To Run with User-defined Inputs

1. A data structure named 'inputs' needs to be created with all necessary inputs as defined in `inputFile_100kW_AWEHPS.yml` apart from the user inputs this structure contains AWE performance parameters that are required to run the simulations.
2. A folder within the 'inputfiles' folder called 'Inputs AWE-power-Eco' contains all necessary inputs to the AWE performance and cost model used. These inputs can be adjusted to other specifications.
3. Executing the script `main_AWE_HPS.m` with the new input sheet generates the simulated results. Within the script, in the section 'System inputs' make sure to change the name of the inputfile to the user-generated file.

### Generated Output Files

The following .mat files get generated as output and stored in the folder 'outputFiles.

1. `Scen1` contains the results of the first AWE-UC scenario.
2. `Scen2` contains the results of the second AWE-Batteries scenario.
3. `Scen3` contains the results of the third Battery arbitrage scenario.
3. `Scen4` contains the results of the fourth AWe-Battery arbitrage scenario.

## Licence
This project is licensed under the MIT License. Please see the below WAIVER in association with the license.

## Acknowledgement
The project was supported by Roland Schmehl and Rishikesh Joshi, the author of the AWE-Power and AWE-Eco repositories.

Copyright (c) 2024 Bart Zweers