%% Example script to test AWE-Power and AWE-Eco coupling
clc; clearvars;

% Add the source code folders of AWE-Power and AWE-Eco to path
addpath(genpath('C:\Users\bartz\TU Delft\Sustainable Energy Technology\Thesis\Msc Thesis hybrid power using AWE\HPP model\Git\AWE-Power/src'));
addpath(genpath('C:\Users\bartz\TU Delft\Sustainable Energy Technology\Thesis\Msc Thesis hybrid power using AWE\HPP model\Git\AWE-Power/lib'));
addpath(genpath('C:\Users\bartz\Documents\GitHub\AWE-Eco'));

% Add inputFiles to path
addpath(genpath([pwd '/inputFiles']));

% Run AWE-Power
% Load defined input file
inputs = loadInputs('inputFile_100kW_baseCase.yml');


% Run AWE-Power
[inputs, outputs, optimDetails, processedOutputs] = main_awePower(inputs);

% Plot results
plotResults(inputs);

% Run AWE-Eco
% Import inputs
inp = eco_system_inputs_awePower(inputs, processedOutputs);

% Run EcoModel by parsing the inputs
[inp,par,eco] = eco_main(inp);