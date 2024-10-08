
% main_AWE_HPS calculates the economic performance of a grid-connected HPS with ground-gen fixed-wing AWE power and power smoothing storage

  % This function performs energy yield, storage performance, arbitrage revenue and storage degradation
  % to compute the economic output of a fixed-wing airborne wind energy system 
  % over one year of operation at a certain DAM and wind environment.

%   Author
%   Bart Zweers, 
%   Delft University of Technology

%   clc; 
clearvars;

addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\src'));
addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\inputFiles'));
addpath(genpath('C:\Users\bartz\Documents\GitHub\MSc_Bart_Zweers\lib'));



%% System inputs

inputs = loadInputs('inputFile_AWEHPS.yml');

%% Scenario parameters


[inputs.DAM, inputs.vw, inputs.vol] = Param(readtable('DAM_NL_2019.csv'), ncread('NL_Wind.nc','u100'),ncread('NL_Wind.nc','v100'));

Scen3.w = 4;
Scen3.var = 0.17;

Scen4.w = 4;
Scen4.var = 0.17;

%% AWE performance


% AWE kite power hourly [kW]

[Scen1.P, Scen1.Cf, Scen1.AEP] = AWEperf(inputs.vw, inputs.Pcurve', 4, 10);


% AWE power smoothing timeseries [kW]

[Scen1.P_sm, Scen1.E_sm, Scen1.E_res, Scen2.E_batt_req, Scen1.E_UC_req] = AWEsm(inputs.vw, Scen1.P, inputs.StorageExchange/1e3, inputs.tCycle, inputs.Peinst, inputs.Pcurve');


%% Scenario 1 AWE + UC

% AWE+UC energy and profit performance

[Scen1.R_arb, Scen1.R_kite, Scen1.f_repl, Scen1.CapEx, Scen1.OpEx] = Scenperf(Scen1.P, zeros(8760,1), inputs.DAM, inputs.subsidy, Scen1.E_sm,...
                                                                               inputs.N_UC_years, inputs.N_UC_cycles, inputs.UC_price, Scen1.E_UC_req, inputs.ICC, inputs.OMC);

% AWE + UC economic metrics


[Scen1.LCoE, Scen1.LRoE, Scen1.LPoE, Scen1.Payb] = EcoMetrics(inputs.r,Scen1.R_kite,Scen1.AEP,Scen1.CapEx,Scen1.OpEx, inputs.Ny);
Scen1.NPV = NPV(inputs.r,Scen1.R_kite,Scen1.CapEx,Scen1.OpEx, inputs.Ny);
[Scen1.IRR,~] = fsolve(@(r) NPV(r,Scen1.R_kite,Scen1.CapEx,Scen1.OpEx, inputs.Ny),0,optimoptions('fsolve','Display','none'));



%% Scenario 2 AWE + Batt

% AWE + Batt energy and profit performance

[Scen2.R_arb, Scen2.R_kite, Scen2.f_repl, Scen2.CapEx, Scen2.OpEx] = Scenperf(Scen1.P, zeros(8760,1), inputs.DAM, inputs.subsidy, Scen1.E_sm, ...
                                                                                inputs.N_li_years, inputs.N_li_cycles, inputs.batt_price, Scen2.E_batt_req, inputs.ICC, inputs.OMC);


% AWE + Batt economic metrics


[Scen2.LCoE, Scen2.LRoE, Scen2.LPoE, Scen2.Payb] = EcoMetrics(inputs.r,Scen2.R_kite,Scen1.AEP,Scen2.CapEx,Scen2.OpEx, inputs.Ny);
Scen2.NPV = NPV(inputs.r,Scen2.R_kite,Scen2.CapEx,Scen2.OpEx, inputs.Ny);
[Scen2.IRR,~] = fsolve(@(r) NPV(r,Scen2.R_kite,Scen2.CapEx,Scen2.OpEx, inputs.Ny),0,optimoptions('fsolve','Display','none'));


%% Scenario 3 Batt arbitrage


% Batt arbitrage bidding dispatch

[Scen3.SoC,Scen3.P] = Dispatcher(Scen3.w, Scen3.var, inputs.DAM, zeros(8760,1), zeros(8760,1), inputs.batt_min*Scen2.E_batt_req, inputs.batt_max*Scen2.E_batt_req,...
                                    Scen2.E_batt_req, inputs.batt_type, inputs.batt_eff); 


% Batt arbitrage energy and profit performance

[Scen3.R_arb, Scen3.R_kite, Scen3.f_repl, Scen3.CapEx, Scen3.OpEx] = Scenperf(zeros(8760,1), Scen3.P, inputs.DAM, inputs.subsidy, zeros(8760,1), ...
                                                                                inputs.N_li_years, inputs.N_li_cycles, inputs.batt_price, Scen2.E_batt_req, 0, 0);

% Batt arbitrage economic metrics


Scen3.arb_E = sum(abs(min(Scen3.P,0)))/1e3;

[Scen3.LCoE, Scen3.LRoE, Scen3.LPoE, Scen3.Payb] = EcoMetrics(inputs.r,Scen3.R_arb,Scen3.arb_E,Scen3.CapEx,Scen3.OpEx, inputs.Ny);
Scen3.NPV = NPV(inputs.r,Scen3.R_arb,Scen3.CapEx,Scen3.OpEx, inputs.Ny);
[Scen3.IRR,~] = fsolve(@(r) NPV(r,Scen3.R_arb,Scen3.CapEx,Scen3.OpEx, inputs.Ny),0,optimoptions('fsolve','Display','none'));
[Scen3.LF, Scen3.VoSA] = StorageMetrics(Scen3.R_arb,Scen3.P,Scen2.E_batt_req,inputs.batt_type);


%% Scenario 4 AWE + Batt arbitrage

% AWE + Batt arbitrage bidding dispatch

[Scen4.SoC,Scen4.P] = Dispatcher(Scen4.w, Scen4.var, inputs.DAM, Scen1.P_sm, Scen1.E_res, inputs.batt_min*Scen2.E_batt_req, inputs.batt_max*Scen2.E_batt_req,...
                                    Scen2.E_batt_req, inputs.batt_type, inputs.batt_eff); 

% AWE + Batt arbitrage energy and profit performance

[Scen4.R_arb, Scen4.R_kite, Scen4.f_repl, Scen4.CapEx, Scen4.OpEx] = Scenperf(Scen1.P, Scen4.P, inputs.DAM, inputs.subsidy, Scen1.E_sm, ...
                                                                                inputs.N_li_years, inputs.N_li_cycles, inputs.batt_price, Scen2.E_batt_req, inputs.ICC, inputs.OMC);


% AWE + Batt arbitrage economic metrics

Scen4.R = Scen4.R_arb + Scen4.R_kite;
Scen4.arb_E = sum(abs(min(Scen4.P,0)))/1e3;
Scen4.E_dis = Scen1.AEP + Scen4.arb_E;

[Scen4.LCoE, Scen4.LRoE, Scen4.LPoE, Scen4.Payb] = EcoMetrics(inputs.r,Scen4.R,Scen4.E_dis,Scen4.CapEx,Scen4.OpEx, inputs.Ny);
Scen4.NPV = NPV(inputs.r,Scen4.R,Scen4.CapEx,Scen4.OpEx, inputs.Ny);
[Scen4.IRR,~] = fsolve(@(r) NPV(r,Scen4.R,Scen4.CapEx,Scen4.OpEx, inputs.Ny),0,optimoptions('fsolve','Display','none'));
[Scen4.LF, Scen4.VoSA] = StorageMetrics(Scen4.R_arb,Scen4.P,Scen2.E_batt_req,inputs.batt_type);



%% Display

Scen4.f_cycles = (sum(abs(Scen4.P)) + sum(Scen1.E_sm))/(Scen2.E_batt_req*inputs.N_li_cycles);
Scen2.f_cycles = sum(Scen1.E_sm)/(Scen2.E_batt_req*inputs.N_li_cycles);
Scen4.arbprof = Scen4.R_arb - inputs.batt_price*Scen2.E_batt_req*(Scen4.f_cycles-Scen2.f_cycles);

% disp('---------------------------------------------------------')
% disp(['window = ',num2str(round(Scen4.w,2)),' hrs'])
% disp(['variance = ',num2str(round(Scen4.var,4)),' EUR/MWh'])
% disp(['Scenario 4 E_{dis} = ',num2str(round(Scen4.arb_E,4)),' MWh'])
% disp(['Scenario 4 IRR = ',num2str(round(Scen4.IRR*1e2,4)),' %'])
% disp(['Scenario 4 Arbitrage profit = ',num2str(round(Scen4.arbprof,4)),' EUR'])

Scen1.t_cyc = [0,1.05000000000000,59,60.0500000000000,64.0500000000000,75.0700000000000,79.0700000000000];
Scen1.P_e = [0,137.795628013230,131.353472847588,0,-24.6278969333646,-0.0354535056597164,0];
Scen1.P_m = [0,199.746972005509,191.796732567887,0,-19.1015675261193,-0.0274979846727906,0];
Scen1.P_m_avg = 148250.920152283/1e3;

%% Save output

  if not(isfolder('outputFiles'))
    mkdir 'outputFiles';
  end
  % Change names to associate with specific scenario context
  save(['outputFiles/AWE-HPS_' 'Scenario1' '.mat'], 'Scen1');
  save(['outputFiles/AWE-HPS_' 'Scenario2' '.mat'], 'Scen2');
  save(['outputFiles/AWE-HPS_' 'Scenario3' '.mat'], 'Scen3');
  save(['outputFiles/AWE-HPS_' 'Scenario4' '.mat'], 'Scen4');

%% Plots 

% Scenario parameters
%%%%%%%%%%%%%%%%%%%%%

% plotScenParam(inputs.DAM, inputs.vw) 

% AWE performance
%%%%%%%%%%%%%%%%%


% plotAWEperf(Scen1.P, inputs.Pcurve', inputs.vw, inputs.Perated, inputs.Pmrated, inputs.Pmavg, inputs.tCycRated)


% Storage performance
%%%%%%%%%%%%%%%%%%%%%

% plotStorperf( Scen1, Scen2, Scen4)

% Arbitrage operation
%%%%%%%%%%%%%%%%%%%%%

% plotArbOpp(inputs, Scen1,Scen2, Scen3, Scen4)

% Plots Scenario 1
%%%%%%%%%%%%%%%%%%
% Scen1.SoC = zeros(8760,1);
% plotScenario(5950, inputs, Scen1, Scen1, Scen1.E_UC_req, inputs.N_UC_cycles)

% Plots Scenario 2
%%%%%%%%%%%%%%%%%%

% plotScenario(5950, inputs, Scen1, Scen2, Scen2.E_batt_req, inputs.N_li_cycles)

% Plots Scenario 3
%%%%%%%%%%%%%%%%%%
% Scen3.E_res = zeros(8760,1);
% Scen3.E_sm = zeros(8760,1);
% Scen3.P_sm = zeros(8760,1);
% plotScenario(5950, inputs, Scen3, Scen3, Scen2.E_batt_req, inputs.N_li_cycles)

% Plots Scenario 4
%%%%%%%%%%%%%%%%%%

% plotScenario(5950, inputs, Scen1, Scen4, Scen2.E_batt_req, inputs.N_li_cycles)

% Discussion
%%%%%%%%%%%%

% plotDiscuss(inputs, Scen1, Scen2, Scen3, Scen4) 




