% function [inputs, outputs] = main_AWE_HPS(inputs)
  % main_AWE_HPS calculates the economic performance of a grid-connected HPS with ground-gen fixed-wing AWE power and power smoothing storage
  %
  % This function performs energy yield, storage performance, arbitrage revenue and storage degradation
  % to compute the economic output of a fixed-wing airborne wind energy system 
  % over one year of operation at a certain DAM and wind environment.
  %
  % Inputs:
  %   inputs - Structure containing necessary input parameters and constants
  %
  % Outputs:
  %   outputs          - Structure containing computed values from the optimization

addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\src'));
addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\inputFiles'));
addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\lib'));


inputs = loadInputs('inputFile_100kW_AWEHPS.yml');
