%% HPPModel
% An Economic Model for Hybrid Power Plants using Airborne Wind Energy
% Systems participating in the Day-Ahead Market

% Authors
% - Bart Zweers, 
%   Delft University of Technology


clc; clearvars; clear global  

% addpath(genpath('C:\Users\bartz\TU Delft\Sustainable Energy Technology\Thesis\Msc Thesis hybrid power using AWE\HPP model\Git\AWE-Power/src'));
% addpath(genpath('C:\Users\bartz\TU Delft\Sustainable Energy Technology\Thesis\Msc Thesis hybrid power using AWE\HPP model\Git\AWE-Power/lib'));
% addpath(genpath('C:\Users\bartz\Documents\GitHub\AWE-Eco'));


% % Add the source code folders of AWE-Power and AWE-Eco to path
% addpath(genpath('C:\Users\bartz\TU Delft\Sustainable Energy Technology\Thesis\Msc Thesis hybrid power using AWE\HPP model\Git\AWE-Power/src'));
% addpath(genpath('C:\Users\bartz\Documents\GitHub\AWE-Eco'));
% 
% % Add inputFiles to path
% addpath(genpath([pwd '/inputFiles']));
% 
% % Run AWE-Power
% % Load defined input file
% %inputFile_example_SE;
% inputFile_100kW_awePower;
% % inputFile_1MW_awePower;
% 
% % Get results
% [outputs, optimDetails, processedOutputs] = main_awePower(inputs);
% 
% % Plot results
% % plotResults_awePower(inputs);
% 
% % Run AWE-Eco
% % Import inputs
% inp = eco_system_inputs_awePower(inputs, processedOutputs);
% 
% % Run EcoModel by parsing the inputs
% [inp,par,eco] = eco_main(inp);

%% System inputs
Cost.Subsidy = 110;                          % Subsidized electricity price [EUR/MWh] 110 from german AWE

Battery.Size        = 140e3;               % Wh
Battery.Type        = 1;                   % E/P or C rate
Cost.BatteryPrice   = 0.5*[0.194 0.198 0.223 0.242];        % [0.25C 0.5C 1C 2C] [EUR/Wh] source: https://www.nrel.gov/docs/fy21osti/78694.pdf



%% Load inputs

inputs.DAM  = readtable('DAM_NL_2019.csv');
inputs.DAMp = inputs.DAM{:,"Var2"};                         %DAM price hourly in 2019 NL bidding zone
inputs.DAMp(8761) = [];
                                          


inputs.u              = ncread('NL_Wind.nc','u100');                        
inputs.v              = ncread('NL_Wind.nc','v100');                         
inputs.vw = sqrt(inputs.u(1,1,:).^2+inputs.v(1,1,:).^2);    % The wind speed is a combination of the u and v component of the downloaded data
inputs.vw = reshape(inputs.vw,[],1);                        % Reshaping of the 1x1xN matrix to make it a vector

inputs.DAMavg_winter = 0.5* (mean(inputs.DAMp(1:2190), "omitnan") + mean(inputs.DAMp(6571:8760), "omitnan"));
inputs.DAMavg_summer = mean(inputs.DAMp(2190:6570), "omitnan");

inputs.Vwavg_winter = 0.5* (mean(inputs.vw(1:2190)) + mean(inputs.vw(6571:8760)));
inputs.Vwavg_summer = mean(inputs.vw(2190:6570));

%% Wind 

% inputs.kite_Pcurve = processedOutputs.P_e_avg;

% inputs.kite_Pcurve = [0	0	0	0	23928.0786858097	40782.2484684097	63234.1853813851	88411.6777416588	99999.9999822212	100000.000000336	99999.9999999685	99999.9999951410	99999.9999961658	99999.9999999519	100000.000000000	100000.000000000	100000.000000000	100000.000000000	100000.000022809	100000.000002251]';
inputs.kite_Pcurve = [0	0	0 0 6823.05494180757	20750.8552913604	40035.5511607199	63415.6188669052	85700.7504181529	99999.9999634139	99999.9999993995	100000.000000000	99999.9999612856	99999.9999939655	99999.9999993012	99999.9999999965	100000.000000000	100000.000000000	100000.000000000	100000	100000.000000000]';

Kite.Power  = zeros(length(inputs.vw),1);                    % [W]
for i = 1:length(inputs.vw)
  for vw = 1:length(inputs.kite_Pcurve)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1
          Kite.Power(i) = inputs.kite_Pcurve(vw); 
      
      end
  end
end

Kite.CF = sum(Kite.Power)/(100e3*8760);

%% Storage

inputs.Li_p   = 0.182;    % [EUR/Wh] source: https://www.nrel.gov/docs/fy21osti/79236.pdf
inputs.Li_N = 1e4;          % [cycles]
inputs.Li_n = 10;         % Lifetime in years
inputs.ultracap_p = 6e4;    % [EUR/Wh]
inputs.ultracap_N = 1e6;    % [cycles]

% inputs.storageExchange = [0 0 0 0 108.039159313504	200.506068419865	329.917636884245	547.329686739828	609.546548475505	610.294848564850	611.680253023387	615.626123220090	615.462737064486	615.751877538799	617.185258454487	618.688207529163	620.269719798495	621.937042723459	623.697366188138	625.975247123629]/1e3;
inputs.storageExchange = [0	0	0 0 39.2114406427936	93.0947366719285	207.022440717841	412.999777754543	702.156555319391	810.070535420744	805.462031428633	808.180879889064	809.929699115073	813.114155193377	816.935309245319	821.167178788006	825.732017996912	830.577439826927	835.618275680234	840.916791101337	847.169221886612]/1e3;
% inputs.tCycle = [0	0	0	0	77.3554205106980	74.8369298463746	72.6676832706646	74.1704185876828	66.6928585762757	66.3576800140128	66.3292347556844	66.3323981105417	66.3947538186755	66.4478976760508	66.4305270459919	66.3912204881843	66.3442805951220	66.2929104622193	66.2375211047565	66.1691260112408];
inputs.tCycle = [0	0	0 0 199.110877845002	87.6714004467267	85.5139407777646	87.3579932218051	93.3237218054094	80.8992375788376	79.9581035213846	79.4595074569484	79.1889899452987	79.0790839654564	79.0738117712405	79.1297853113387	79.2192139488680	79.3068747121754	79.3241622327488	79.2940943437130	79.9040793712790];
% inputs.P_e_inst = [0 1.358231366870376e+02 1.235386302075073e+02 0 -10.135314791951744 -2.238176293112461e-09 0];       %Reeling power [kW]
inputs.P_e_inst = [0,137.381331953625,137.209204335937,0,-39.7295922699621,7.03564325810917e-14,0];

Battery.Preq = round(max(abs(inputs.P_e_inst-max(inputs.kite_Pcurve/1e3))),0)*1e3;                         %1C charge limit battery power [W]


%% AWE Smoothing storage 



Battery.Smoothing = ones(8760,1);       % set-up

for i = 1:length(inputs.vw)                         % Smoothing intermediate storage needed per hour [Wh]
  for vw = 1:length(inputs.storageExchange)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1

          Battery.Smoothing(i) = inputs.storageExchange(vw)*1e3;            % smoothing capacity [Wh]
          Battery.Psm(i) = Kite.Power(i);                                   % smoothing power capacity [kW]
          Battery.DoD(i) =  Battery.Smoothing(i)/(inputs.tCycle(vw)/3600);  % smoothing depth of discharge per hour [Wh]
      
      end
  end
end

Battery.DoD(isnan(Battery.DoD))=0;

%% Scenario 1 AWE + Ultracap

AWEultracap.f_repl = sum(Battery.DoD/1e3)/(1.1*(max(inputs.storageExchange)))/inputs.ultracap_N;  % frequency of replacement ultracap system [/year]
AWEultracap.KiteE = sum(Kite.Power/1e6);                   % sold kite power [MWh]
AWEultracap.R = sum((inputs.DAMp + Cost.Subsidy) .* (Kite.Power/1e6),"omitnan");

AWEbat.frepl = max( 1/inputs.Li_n,sum(Battery.DoD)/(Battery.Preq*inputs.Li_N));






%% AWE-Batt arbitrage 

Battery.Minimum     = 0.1*Battery.Size;
Battery.Maximum     = 0.9*Battery.Size;
Battery.Eff         = 0.9;                  %Round trip efficiency

AWEarb.w = 5;
AWEarb.var = 0.17;


AWEarb.Batt       = ones(8760,1);       % set-up
AWEarb.Kite2Batt = ones(8760,1);
AWEarb.Batt(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery


for i = 1:length(inputs.DAMp)-AWEarb.w           % Battery Charge [W] roundtrip efficiency taken into account at discharge

    if      inputs.DAMp(i) < (1-AWEarb.var)*mean(inputs.DAMp(i:i+AWEarb.w)) 

            AWEarb.Batt(i+1) = AWEarb.Batt(i) + min((Battery.Type*Battery.Size - Battery.Psm(i)), Battery.Maximum - AWEarb.Batt(i) - Battery.Smoothing(i)) ;
    
    elseif  inputs.DAMp(i) >= (1+AWEarb.var)*mean(inputs.DAMp(i:i+AWEarb.w))
            
            AWEarb.Batt(i+1) = AWEarb.Batt(i) - min((Battery.Type*Battery.Size - Battery.Psm(i)), AWEarb.Batt(i) - Battery.Smoothing(i) - Battery.Minimum) ;
            
    else 
            AWEarb.Batt(i+1) = AWEarb.Batt(i);
         
    end
end


AWEarb.C = (diff(AWEarb.Batt)*Battery.Eff)/1e3;         % Battery charge[+]/discharge[-] [kW]  
AWEarb.C(8760) = 0;

AWEarb.f_repl = max( 1/inputs.Li_n,(sum(abs(AWEarb.C)*1e3) + sum(Battery.DoD))/(Battery.Size*inputs.Li_N));  % frequency of replacement Battery system [/year]

AWEarb.battE = sum(abs(min(AWEarb.C,0)))/1e3;      % discharged energy by battery [MWh]
AWEarb.KiteE = sum(Kite.Power/1e6);                % sold kite power [MWh]
AWEarb.E = AWEarb.battE + AWEarb.KiteE;


AWEarb.Rbatt = sum((inputs.DAMp + Cost.Subsidy).*abs(min(AWEarb.C/1e3,0)) - (inputs.DAMp + Cost.Subsidy).*max(AWEarb.C/1e3,0),"omitnan");
AWEarb.Rkite = sum((inputs.DAMp + Cost.Subsidy) .* (Kite.Power/1e6),"omitnan");
AWEarb.R = AWEarb.Rbatt + AWEarb.Rkite;



%% BESS arbitrage rolling window

BESS.Size = 140e3;
BESS.w = 5;
BESS.var = 0.14;

BESS.DAM = inputs.DAMp;
BESS.DAM(8761)= inputs.DAMp(8760);
BESS.Minimum     = 0.1*BESS.Size;
BESS.Maximum     = 0.9*BESS.Size;

BESS.Batt       = ones(8761,1);    % set-up
BESS.Batt(1,1)  = 0.5*BESS.Size;   % [Wh] Initial charge of the battery

for i = 1:8736           % Battery Charge [W] roundtrip efficiency taken into account at discharge

    if      inputs.DAMp(i) < (1-BESS.var)*mean(inputs.DAMp(i:i+BESS.w)) 

            BESS.Batt(i+1) = BESS.Batt(i) + min((Battery.Type*BESS.Size), BESS.Maximum - BESS.Batt(i) ) ;
    
    elseif  inputs.DAMp(i) >= (1+BESS.var)*mean(inputs.DAMp(i:i+BESS.w))
            
            BESS.Batt(i+1) = BESS.Batt(i) - min((Battery.Type*BESS.Size), BESS.Batt(i) - BESS.Minimum) ;
    else 
            BESS.Batt(i+1) = BESS.Batt(i);
         
    end
end

BESS.C = (diff(BESS.Batt)*Battery.Eff)/1e3;         % Battery charge[+]/discharge[-] [kW]  
BESS.C(8761)=0;

%  BESS.f_repl = max( 1/inputs.Li_n, (sum(abs(BESS.C)*1e3))/(BESS.Size*inputs.Li_N));  % frequency of replacement Battery system [/year]
BESS.f_repl = (sum(abs(BESS.C)*1e3))/(BESS.Size*inputs.Li_N);  % frequency of replacement Battery system [/year]

BESS.R = sum((BESS.DAM + Cost.Subsidy).*abs(min(BESS.C/1e3,0)) - (BESS.DAM + Cost.Subsidy).*max(BESS.C/1e3,0),'omitnan');     % System revenue [EUR]
BESS.E = sum(abs(min(BESS.C/1e3,0)));                                                           % discharged energy by battery [MWh]







%% Economic metrics

  inputs.business.N_y     = 25; % project years
  inputs.business.r_d     = 0.08; % cost of debt
  inputs.business.r_e     = 0.12; % cost of equity
  inputs.business.TaxRate = 0.25; % Tax rate (25%)
  inputs.business.DtoE    = 70/30; % Debt-Equity-ratio 

Cost.r = inputs.business.DtoE/(1+ inputs.business.DtoE)*inputs.business.r_d*(1-inputs.business.TaxRate) + 1/(1+inputs.business.DtoE)*inputs.business.r_e; 



Cost.Kite.ICC = 350e3;      %Capital cost kite system without intermediate storage, 439 from AWE-Eco, 150 from Sweder
Cost.Kite.OMC = 10e3;    %Operational cost kite system without intermediate storage, 12.2 from AWE-eco, 40 from Sweder

AWEultracap.CAPEX = inputs.ultracap_p*1.1*(max(inputs.storageExchange)) + Cost.Kite.ICC ;       % Capital expenditures ultracap component [EUR]
AWEultracap.OPEX = AWEultracap.f_repl*inputs.ultracap_p + Cost.Kite.OMC;                       % Operational expenditures ultracap component [EUR]

AWEbat.CAPEX           = Battery.Preq* Cost.BatteryPrice(Battery.Type) + Cost.Kite.ICC;
AWEbat.OPEX            = AWEbat.frepl * Battery.Preq* Cost.BatteryPrice(Battery.Type) + Cost.Kite.OMC;                     

AWEarb.CAPEX = Battery.Size * Cost.BatteryPrice(Battery.Type) + Cost.Kite.ICC;                     % Capital expenditures ultracap component [EUR]
AWEarb.OPEX = AWEarb.f_repl*Battery.Size*Cost.BatteryPrice(Battery.Type) + Cost.Kite.OMC;                       % Operational expenditures ultracap component [EUR]

BESS.CAPEX             = BESS.Size * Cost.BatteryPrice(Battery.Type);
BESS.OPEX              = BESS.f_repl*(BESS.Size * Cost.BatteryPrice(Battery.Type));


[AWEultracap.LCoE, AWEultracap.LRoE, AWEultracap.LPoE, AWEultracap.NPV1] = EcoMetrics(Cost.r,AWEultracap.R,AWEultracap.KiteE,AWEultracap.CAPEX,AWEultracap.OPEX, inputs.business.N_y);
AWEultracap.NPV = NPV(Cost.r,AWEultracap.R,AWEultracap.CAPEX,AWEultracap.OPEX,inputs.business.N_y);
[AWEultracap.IRR,~] = fsolve(@(r) NPV2(r,AWEultracap.R,AWEultracap.KiteE,AWEultracap.CAPEX,AWEultracap.OPEX,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));

[AWEbat.LCoE, AWEbat.LRoE, AWEbat.LPoE, AWEbat.NPV1] = EcoMetrics(Cost.r,AWEultracap.R,AWEultracap.KiteE,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y);
AWEbat.NPV = NPV(Cost.r,AWEultracap.R,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y);
[AWEbat.IRR,~] = fsolve(@(r) NPV2(r,AWEultracap.R,AWEultracap.KiteE,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));

[AWEarb.LCoE, AWEarb.LRoE, AWEarb.LPoE, AWEarb.NPV1] = EcoMetrics(Cost.r,AWEarb.R,AWEarb.E,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y);
AWEarb.NPV = NPV(Cost.r,AWEarb.R,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y);
[AWEarb.IRR,~] = fsolve(@(r) NPV2(r,AWEarb.R,AWEarb.E,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[AWEarb.LF, AWEarb.VoSA] = StorageMetrics(AWEarb.Rbatt,AWEarb.C,Battery.Size,Battery.Type);

[BESS.LCoS, BESS.LRoS, BESS.LPoS, BESS.NPV1] = EcoMetrics(Cost.r,BESS.R,BESS.E,BESS.CAPEX,BESS.OPEX, inputs.business.N_y);
BESS.NPV = NPV(Cost.r,BESS.R,BESS.CAPEX,BESS.OPEX, inputs.business.N_y);
[BESS.IRR,~] = fsolve(@(r) NPV2(r,BESS.R,BESS.E,BESS.CAPEX,BESS.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[BESS.LF, BESS.VoSA] = StorageMetrics(BESS.R,BESS.C,BESS.Size,Battery.Type);




% inputs.BatLCoE  = 0;
% inputs.kiteLCoE = 100;
% inputs.BatLCoS = 41;

% Cost.Battery.CAPEX     = Battery.Size * Cost.BatteryPrice(Battery.Type);
% Cost.Battery.OPEX      = Battery.f_repl*(Battery.Size * Cost.BatteryPrice(Battery.Type));
% Kite_LCoE_num = ones(25,1);
% Kite_LCoE_den = ones(25,1);
% Battery_LCoE_num = ones(25,1);
% AWEultracap_LCoE_num = ones(25,1);
% Ultracap_NPV_num = ones(25,1);
% Kite_LRoE_num = ones(25,1);
% Kite_Bat_LRoE_num = ones(25,1);
% BESS_LCoS_num = ones(25,1);
% BESS_LCoS_den = ones(25,1);
% BESS_LRoS_num = ones(25,1);
% BESS_LRoS_den = ones(25,1);
% BESS_NPV_num = ones(25,1);
% AWEarb_LRoE_num = ones(25,1);
% AWEbat_LCoE_num = ones(25,1);
% AWEarb_LCoE_num = ones(25,1);
% AWEarb_LCoE_den = ones(25,1);
% 
%   for t = 1:inputs.business.N_y
%       Kite_LCoE_num(t)    = Cost.Kite.OMC/(1+Cost.r)^t;                              % numerator LCoE [EUR]
%       Kite_LCoE_den(t)     = AWEultracap.KiteE/(1+Cost.r)^t;
%       AWEarb_LCoE_den(t)  = (AWEarb.E)/(1+Cost.r)^t;
%       AWEbat_LCoE_num(t)  = AWEbat.OPEX/(1+Cost.r)^t;                          % denominator LCoE [MWh]
%       AWEarb_LCoE_num(t)  = AWEarb.OPEX/(1+Cost.r)^t;                          % denominator LCoE [MWh]
% %       Battery_LCoE_num(t)  = Cost.Battery.OPEX/(1+Cost.r)^t;
%       AWEultracap_LCoE_num(t)  = AWEultracap.OPEX/(1+Cost.r)^t;
%       Kite_LRoE_num(t) = sum((inputs.DAMp + Cost.Subsidy) .* (Kite.Power/1e6),"omitnan")/(1+Cost.r)^t;
% %       Kite_Bat_LRoE_num(t) = sum((inputs.DAMp + Cost.Subsidy).*abs(min(Battery.Charge,0)) + (inputs.DAMp + Cost.Subsidy).*(Kite.Power/1e3 - max(Battery.Charge,0)),"omitnan")/(1+Cost.r)^t;
%       BESS_LCoS_num(t) = BESS.OPEX/(1+Cost.r)^t;
%       BESS_LCoS_den(t) = sum(abs(min(BESS.C,0))/1e3)/(1+Cost.r)^t;
%       BESS_LRoS_num(t) = sum((BESS.DAM + Cost.Subsidy).*abs(min(BESS.C/1e3,0)) - (BESS.DAM + Cost.Subsidy).*max(BESS.C/1e3,0),"omitnan")/(1+Cost.r)^t;
%       BESS_NPV_num(t) = (sum((BESS.DAM + Cost.Subsidy).*abs(min(BESS.C/1e3,0)) - (BESS.DAM + Cost.Subsidy).*max(BESS.C/1e3,0),"omitnan")-BESS.OPEX)/(1+Cost.r)^t;
%       AWEarb_LRoE_num(t) = (AWEarb.R)/(1+Cost.r)^t;
%   end

% Kite.LCoE = (Cost.Kite.ICC + sum(Kite_LCoE_num))/sum(Kite_LCoE_den);
% Battery.LCoE = (Cost.Battery.CAPEX + sum(Battery_LCoE_num)) /sum(Kite_LCoE_den);



% Kite.LRoE = sum(Kite_LRoE_num)/sum(Kite_LCoE_den);
% Kite.Bat.LRoE = sum(Kite_Bat_LRoE_num)/sum(Kite_LCoE_den);
% 
% BESS.LCoS = (BESS.CAPEX + sum(BESS_LCoS_num)) /sum(BESS_LCoS_den);
% BESS.LRoS = sum(BESS_LRoS_num)/sum(BESS_LCoS_den);
% BESS.LPoS = BESS.LRoS - BESS.LCoS;
% BESS.NPV = NPV(Cost.r,BESS.R,BESS.CAPEX,BESS.OPEX,inputs.business.N_y);
% [BESS.IRR,~] = fsolve(@(r) NPV(r,BESS.R,BESS.CAPEX,BESS.OPEX,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
% BESS.ROI = BESS.NPV/BESS.CAPEX;
% 
% AWEultracap.LCoE = (AWEultracap.CAPEX + sum(AWEultracap_LCoE_num))/sum(Kite_LCoE_den);
% AWEultracap.LPoE = sum(Kite_LRoE_num)/sum(Kite_LCoE_den) - AWEultracap.LCoE;
% AWEultracap.NPV = sum(Kite_LRoE_num)- sum(AWEultracap_LCoE_num) - AWEultracap.CAPEX;
% AWEultracap.ROI = AWEultracap.NPV/(AWEultracap.CAPEX);
% AWEultracap.NPV2 = NPV(Cost.r,AWEarb.Rkite,AWEultracap.CAPEX +Cost.Kite.ICC,AWEultracap.OPEX+Cost.Kite.OMC,inputs.business.N_y);
% [AWEultracap.IRR,~] = fsolve(@(r) NPV(r,AWEarb.Rkite,AWEultracap.CAPEX +Cost.Kite.ICC,AWEultracap.OPEX+Cost.Kite.OMC,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
% 
% AWEbat.LCoE = (AWEbat.CAPEX + sum(Kite_LCoE_num))/sum(Kite_LCoE_den);
% AWEbat.LPoE = sum(Kite_LRoE_num)/sum(Kite_LCoE_den) - AWEbat.LCoE;
% AWEbat.NPV = sum(Kite_LRoE_num)- sum(AWEbat_LCoE_num)  - AWEbat.CAPEX;
% AWEbat.ROI = AWEbat.NPV/(AWEbat.CAPEX);
% AWEbat.NPV2 = NPV(Cost.r,AWEarb.Rkite,AWEbat.CAPEX,AWEbat.OPEX,inputs.business.N_y);
% [AWEbat.IRR,~] = fsolve(@(r) NPV(r,AWEarb.Rkite,AWEbat.CAPEX,AWEbat.OPEX,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
% 
% AWEarb.LCoE = (AWEarb.CAPEX + sum(AWEarb_LCoE_num))/sum(AWEarb_LCoE_den);
% AWEarb.LPoE = sum(AWEarb_LRoE_num)/sum(AWEarb_LCoE_den) - AWEarb.LCoE;
% AWEarb.NPV = sum(AWEarb_LRoE_num) - sum(AWEarb_LCoE_num(t)) - AWEarb.CAPEX;
% AWEarb.ROI = AWEarb.NPV/(AWEarb.CAPEX);
% AWEarb.NPV2 = NPV(Cost.r,AWEarb.Rkite + AWEarb.Rbatt,AWEarb.CAPEX +Cost.Kite.ICC,AWEarb.OPEX+Cost.Kite.OMC,inputs.business.N_y);
% [AWEarb.IRR,~] = fsolve(@(r) NPV(r,AWEarb.Rkite + AWEarb.Rbatt,AWEarb.CAPEX,AWEarb.OPEX,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));

%% BESS operation threshold system


% Battery.SoC       = ones(8760,1);       % set-up
% Battery.SoC(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery
% 
% for i = 1:length(inputs.DAMp)           % Battery SoC [Wh] roundtrip efficiency taken into account at discharge
% 
% %     if      inputs.DAMp(i) < inputs.BatLCoS &&...
% %             Battery.SoC(i)+Kite.Power(i) < Battery.Maximum - Battery.Smoothing(i)
% % 
% %             Battery.SoC(i+1) = Battery.SoC(i)+ min(Battery.Type*Battery.Size, Battery.Maximum - Battery.SoC(i) );
% 
%     if  inputs.DAMp(i) < inputs.kiteLCoE &&...
%             Battery.SoC(i)+Kite.Power(i) < Battery.Maximum - Battery.Smoothing(i)
% 
%             Battery.SoC(i+1) = Battery.SoC(i)+Kite.Power(i);
%     
%     elseif  inputs.DAMp(i) >= inputs.kiteLCoE + inputs.BatLCoE &&...
%             Battery.SoC(i) > Battery.Minimum + Battery.Smoothing(i)
%             
%             Battery.SoC(i+1) = Battery.SoC(i) - 0.5*min(Battery.Type*Battery.Size, Battery.SoC(i) - (Battery.Minimum + Battery.Smoothing(i))) ;   
%     else 
%             Battery.SoC(i+1) = Battery.SoC(i);
%          
%     end
% end

%% BESS operation AWE store to Batt


% AWEarb.w = 5;
% AWEarb.var = 0.14;
% 
% 
% AWEarb.Batt       = ones(8760,1);       % set-up
% AWEarb.Kite2Batt = ones(8760,1);
% AWEarb.Batt(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery
% 
% 
% for i = 1:length(inputs.DAMp)-AWEarb.w           % Battery Charge [W] roundtrip efficiency taken into account at discharge
% 
%     if      inputs.DAMp(i) < (1-AWEarb.var)*mean(inputs.DAMp(i:i+AWEarb.w)) 
% 
%             AWEarb.Batt(i+1) = AWEarb.Batt(i) + min((Battery.Type*Battery.Size - Battery.Psm(i)), Battery.Maximum - AWEarb.Batt(i) - Battery.Smoothing(i)) ;
%     
%     elseif  inputs.DAMp(i) >= (1+AWEarb.var)*mean(inputs.DAMp(i:i+AWEarb.w))
%             
%             AWEarb.Batt(i+1) = AWEarb.Batt(i) - min((Battery.Type*Battery.Size - Battery.Psm(i)), AWEarb.Batt(i) - Battery.Smoothing(i) - Battery.Minimum) ;
%             
%     else 
%             AWEarb.Batt(i+1) = AWEarb.Batt(i);
%          
%     end
% end
% 
% 
% AWEarb.C = (diff(AWEarb.Batt)*Battery.Eff)/1e3;         % Battery charge[+]/discharge[-] [kW]  
% AWEarb.C(8760) = 0;
% 
% AWEarb.f_repl = max( 1/inputs.Li_n,(sum(abs(AWEarb.C)*1e3) + sum(Battery.DoD))/(Battery.Size*inputs.Li_N));  % frequency of replacement Battery system [/year]
% 
% AWEarb.E = sum(abs(min(AWEarb.C,0)))/1e3;          %discharged energy by battery [MWh]
% AWEarb.KiteE = sum(Kite.Power/1e6);                % sold kite power [MWh]

%% BESS operation AWE store based on LCoE

% Battery.SoC       = ones(8760,1);       % set-up
% Battery.SoC(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery
% 
% for i = 1:length(inputs.DAMp)           % Battery SoC [Wh] roundtrip efficiency taken into account at discharge
% 
% 
%     if  inputs.DAMp(i) < inputs.kiteLCoE &&...
%             Battery.SoC(i)+Kite.Power(i) < Battery.Maximum - Battery.Smoothing(i)
% 
%             Battery.SoC(i+1) = Battery.SoC(i)+Kite.Power(i);
%     
%     elseif  inputs.DAMp(i) >= inputs.kiteLCoE + inputs.BatLCoE &&...
%             Battery.SoC(i) > Battery.Minimum + Battery.Smoothing(i)
%             
%             Battery.SoC(i+1) = Battery.SoC(i) - 0.5*min(Battery.Type*Battery.Size, Battery.SoC(i) - (Battery.Minimum + Battery.Smoothing(i))) ;   
%     else 
%             Battery.SoC(i+1) = Battery.SoC(i);
%          
%     end
% end
% 
% 
% 
% Battery.Charge = diff(Battery.SoC)*Battery.Eff/1e3;     % Battery charge [+]/discharge [-] [kW]
% 
% Battery.f_repl = ((sum(abs(Battery.Charge)*1e3) + sum(Battery.DoD/1e3))/Battery.Size)/inputs.Li_N;  % frequency of replacement Battery system [/year]
% AWEbat.BatE = sum(abs(min(Battery.Charge,0)))/1e3;         % sold Battery power [MWh]
% AWEbat.E = sum(Kite.Power/1e6/1e3;             % sold kite power [MWh]

%% BESS arbitrage yearly mean

% Battery.SoC2       = ones(8760,1);       % set-up
% Battery.SoC2(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery
% 
% for i = 1:length(inputs.DAMp)           % Battery SoC [Wh] roundtrip efficiency taken into account at discharge
% 
%     if      inputs.DAMp(i) < inputs.BatLCoS &&...
%             Battery.SoC2(i) < Battery.Maximum
% 
%             Battery.SoC2(i+1) = Battery.SoC2(i) + min((Battery.Type*Battery.Size), Battery.Maximum - Battery.SoC2(i) ) ;
%     
%     elseif  inputs.DAMp(i) >= inputs.BatLCoS &&...
%             Battery.SoC2(i) > Battery.Minimum
%             
%             Battery.SoC2(i+1) = Battery.SoC2(i) - min((Battery.Type*Battery.Size), Battery.SoC2(i) - Battery.Minimum) ;
%     else 
%             Battery.SoC2(i+1) = Battery.SoC2(i);
%          
%     end
% end
% 
% Battery.Charge2 = diff(Battery.SoC2)*Battery.Eff/1e3;         % Battery charge[+]/discharge[-] [kW]
% Battery.f_repl2 = (sum(abs(Battery.Charge2)*1e3))/(Battery.Size*inputs.Li_N);  % frequency of replacement Battery system [/year]
% 
% BESS.revenue = sum(inputs.DAMp.*abs(min(Battery.Charge2,0)) - inputs.DAMp.*max(Battery.Charge2,0),'omitnan');
% BESS.dischE = sum(abs(min(Battery.Charge2,0)))/1e3;          %discharged energy by battery [MWh]

%% Revenue and Profit

% Grid.Battery = abs(min(Battery.Charge,0));                                  % Battery capacity bid to DAM (kWh)
% Revenue.Battery = inputs.DAMp.* Grid.Battery/1e3;
% Grid.Kite = Kite.Power/1e3 - max(Battery.Charge,0);                         % Kite Energy bid to DAM (kWh)
% Revenue.Kite = inputs.DAMp.*Grid.Kite/1e3;
% 
% 
% Revenue.Total.Battery = inputs.business.N_y * sum(Revenue.Battery + Revenue.Kite,"omitnan");
% Cost.Total.Battery = (Cost.Battery.CAPEX+Cost.Kite.ICC) + inputs.business.N_y * (Cost.Kite.OMC+Cost.Battery.OPEX);
% Revenue.Total.ProfitBattery = Revenue.Total.Battery - Cost.Total.Battery;

% BESS.DP = (BESS.R-BESS.OPEX)/365e3;                                   %Profit per day [EUR]


%% Plots


%% Inputs data

% figure('units', 'normalized', 'outerposition', [0 0.5 0.45 0.4]) %Location analysis
% 
% subplot(1,2,1)                   % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.5, 'color', '#87B6A7')
%     hold on
% %     yline(mean(inputs.DAMp, "omitnan"),'-');
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Day-Ahead market price','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.DAMp)])
%     ylim([0 1.1*max(inputs.DAMp)])
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off
% 
% subplot(1,2,2)                   % Wind speed 2019
% 
% plot(1:length(inputs.vw),inputs.vw,'LineWidth',0.5, 'color', '#7284A8')
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Wind speed at 100m ','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.vw)])
%     ylim([0 1.1*max(inputs.vw)])
%     ylabel('Wind speed at 100 m [m/s]','FontSize',10,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off

%% AWE power
% 
% figure()  % Powercurve 100 kW AWE
% 
% plot(1:length(inputs.kite_Pcurve),inputs.kite_Pcurve/1e3,'LineWidth',1, 'color', '#50B2C0')
%     hold on
%     title('Power curve 100 kW AWE system','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 20])
%     ylim([0 1.1*max(inputs.kite_Pcurve)/1e3])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     legend('P_{e, avg}','Location','northeast','FontSize',8,'NumColumns',1);
%     xlabel('Wind speed at 100 m (m/s)','FontSize',8,'FontWeight', 'Bold')
%     legend('boxoff')
% hold off
% 
% 
% 
% figure()  % Reeling power 100 kW AWE
% 
% plot([0 1 43 45 51 65 66.7],inputs.P_e_inst,'LineWidth',1, 'color', '#50B2C0')
%     hold on
%     yline(100,'-','Rated Power');
%     title('Reeling power at 10 m/s','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 70])
%     ylim([1.3*min(inputs.P_e_inst) 1.3*max(inputs.P_e_inst)])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     legend('P_{e, avg}','Location','northeast','FontSize',8,'NumColumns',1);
%     xlabel('Time withing cycle (s)','FontSize',8,'FontWeight', 'Bold')
%     legend('boxoff')
% hold off

%% Scenario 1 AWE ultracap

figure('Name','Scenario 1 AWE+ultracap','units', 'normalized', 'outerposition', [0 0.6 0.5 0.5])

  subplot(2,1,1);

  hold on
  str_2_print = sprintf(['AWE + Ultracapacitor\n\n' ...
      'LCoE = %.0f EUR/MWh\n' ...
      'LPoE = %.1f EUR/MWh\n' ...
      'IRR = %.3f percent\n' ...
      'Produced energy = %.0f MWh\n' ...
      ], ...
      AWEultracap.LCoE, AWEultracap.LPoE, AWEultracap.IRR*1e2, AWEultracap.KiteE);  

  text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
  axis off

  subplot(2,1,2);

    yyaxis left                       % DAM  2019

    plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#F7E0E0')
    title('Kite power in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(inputs.DAMp(4380:4716))])
    ylim([20 60])
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')


    yyaxis right                    % Produced Kite power

    plot(1:length(Kite.Power(4380:4716)/1e3),Kite.Power(4380:4716)/1e3,'LineWidth',0.25, 'color', '#577399')
    ylim([0.9*min(Kite.Power(4380:4716)/1e3) 1.2*max(Kite.Power(4380:4716)/1e3)])
    xlim([0 length(Kite.Power(4380:4716)/1e3)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    hold off

    %% Scenario 2 AWE Battery

figure('Name','Scanario 2 AWE-Batt','units', 'normalized', 'outerposition', [0.5 0.6 0.5 0.5])

  subplot(2,1,1);

  hold on
  str_2_print = sprintf(['AWE + Battery\n\n' ...
      'LCoE = %.0f EUR/MWh\n' ...
      'LPoE = %.1f EUR/MWh\n' ...
      'IRR = %.3f percent\n' ...
      'Produced energy = %.0f MWh\n' ...
      ], ...
      AWEbat.LCoE, AWEbat.LPoE, AWEbat.IRR*1e2, AWEultracap.KiteE);  

  text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
  axis off

  subplot(2,1,2);

    yyaxis left                       % DAM  2019

    plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#F7E0E0')
    title('Kite power in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(inputs.DAMp(4380:4716))])
    ylim([20 60])
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')


    yyaxis right                    % Produced Kite power

    plot(1:length(Kite.Power(4380:4716)/1e3),Kite.Power(4380:4716)/1e3,'LineWidth',0.25, 'color', '#577399')
    ylim([0.9*min(Kite.Power(4380:4716)/1e3) 1.2*max(Kite.Power(4380:4716)/1e3)])
    xlim([0 length(Kite.Power(4380:4716)/1e3)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    hold off

    %% Scenario 3 AWE Battery seperate arbitrage

figure('Name','Scenario 3 AWE+Batt arbitrage','units', 'normalized', 'outerposition', [0 0.05 0.5 0.6])

  subplot(2,1,1);

  hold on
  str_2_print = sprintf(['AWE + Battery seperate arbitrage\n\n' ...
      'LCoE = %.0f EUR/MWh\n' ...
      'LPoE = %.1f EUR/MWh\n' ...
      'IRR = %.3f percent\n' ...
      'Sold kite energy = %.0f MWh\n' ...
      'Sold battery energy = %.0f MWh\n' ...
      'Value of Arbitrage = %.0f kEUR/MW/year\n' ...
      ], ...
      AWEarb.LCoE, AWEarb.LPoE, AWEarb.IRR*1e2, AWEultracap.KiteE, AWEarb.battE,AWEarb.VoSA);  

  text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
  axis off

  subplot(2,1,2);

    yyaxis left                       % DAM  2019

    plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#F7E0E0')
    title('Power flows in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(inputs.DAMp(4380:4716))])
    ylim([20 60])
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')


    yyaxis right                    % Power2Grid flows

    area(1:length(Kite.Power(4380:4716)/1e3),Kite.Power(4380:4716)/1e3, 'FaceColor', '#577399')
    hold on
    area(1:length(abs(min(AWEarb.C(4380:4716),0))),abs(min(AWEarb.C(4380:4716),0)), 'FaceColor', '#DE8F6E')
    area(1:length(abs(max(AWEarb.C(4380:4716),0))),abs(max(AWEarb.C(4380:4716),0)), 'FaceColor', '#88AB75')
    ylim([0 2*max(Kite.Power(4380:4716)/1e3)])
    xlim([0 length(Kite.Power(4380:4716)/1e3)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
    legend('Market price','Kite Power to Grid', 'Battery Power to Grid','Battery Power from Grid','Location','northeastoutside','FontSize',8,'NumColumns',1);
    legend('boxoff')
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    hold off
%% Scenario 4 Battery DAM standalone

figure('Name','Scenario 4 Batt arbitrage','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])

  subplot(2,1,1);
  hold on
  str_2_print = sprintf(['Battery storage DAM arbitrage \n\n' ... ...
      'Battery size = %.0f kWh\n' ...
      'LCoS = %.0f EUR/MWh\n' ...
      'LPoS = %.0f EUR/MWh\n' ...
      'IRR = %.3f percent\n' ...
      'Discharged energy = %.0f MWh\n' ...
      'Value of Arbitrage = %.0f kEUR/MW/year\n' ...
      ], ...
      BESS.Size/1e3, BESS.LCoS,BESS.LPoS, BESS.IRR*1e2, BESS.E, BESS.VoSA);  
  text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
  axis off

  subplot(2,1,2);

    yyaxis left                       % DAM  2019

    plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#F7E0E0')
    title('Battery use in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(inputs.DAMp(4380:4716))])
    ylim([20 60])
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')


    yyaxis right                    % Battery charge/discharge power

    plot(1:length(BESS.C(4380:4716)),BESS.C(4380:4716),'LineWidth',0.25, 'color', '#2A3C24')
    yline(BESS.Size/1e3,'-','1 C');
    yline(BESS.Size/2e3,'-','0.5 C');
    yline(-BESS.Size/1e3,'-','-1 C');
    yline(-BESS.Size/2e3,'-','-0.5 C');
    ylim([1.2*min(BESS.C(4380:4716)) 1.2*max(BESS.C(4380:4716))])
    xlim([0 length(BESS.C(4380:4716))])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';
    hold off

% figure(2)  
% 
%     yyaxis left                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#F7E0E0')
%     title('Battery SoC in two summer weeks','FontSize',8,'FontWeight', 'Bold')
%     xlim([0 length(inputs.DAMp(4380:4716))])
%     ylim([20 60])
%     ylabel('Price [EUR/MWh]','FontSize',8,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',8,'FontWeight', 'Bold')
% 
% 
%     yyaxis right                    % Battery SoC
% 
%     plot(1:length(BESS.Batt(4380:4716)),100*(BESS.Batt(4380:4716)/BESS.Size),'LineWidth',0.25, 'color', '#2A3C24')
%     ylim([-10 110])
%     xlim([0 length(BESS.Batt(4380:4716))])
%     ylabel('Battery State of Charge [%]','FontSize',8,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',8,'FontWeight', 'Bold')
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';


%%% Battery strategy

% figure('units', 'normalized', 'outerposition', [0 0.1 0.45 0.4]) % BESS charge
% 
% subplot(1,2,1)                   % SoC  
% 
%     plot(1:length(Battery.SoC),100*(Battery.SoC/Battery.Size),'LineWidth',0.25, 'color', '#C94277')
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Battery State of Charge','FontSize',12,'FontWeight', 'Bold')
%     ylim([0 100])
%     xlim([0 length(Battery.SoC)])
%     ylabel('Battery State of Charge [%]','FontSize',12,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off
% 
% subplot(1,2,2)                    % Battery charge/discharge power
% 
%     plot(1:length(Battery.Charge),Battery.Charge,'LineWidth',0.25, 'color', '#50B2C0')
% %     plot(1:length(Battery.Smoothing),Battery.Smoothing,'LineWidth',0.25, 'color', '#FAAA8D')
%     yline(Battery.Size/1e3,'-','1 C');
%     yline(Battery.Size/2e3,'-','0.5 C');
%     yline(-Battery.Size/1e3,'-','-1 C');
%     yline(-Battery.Size/2e3,'-','-0.5 C');
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('AWE Battery Charge/Discharge ','FontSize',12,'FontWeight', 'Bold')
%     ylim(1.1*[min(Battery.Charge) max(Battery.Charge)])
%     xlim([0 length(Battery.SoC)])
%     ylabel('Battery Charge/Discharge [kW]','FontSize',12,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off

%% Performance comparison

% figure('units', 'normalized', 'outerposition', [0.5 0.4 0.5 0.6])
% 
%   subplot(2,3,1);
%   hold on
%   str_2_print = sprintf(['AWE + Ultracapacitor\n\n' ...
%       'Cf = %.2f\n' ...
%       'LCoE = %.0f EUR/MWh\n' ...
%       'LPoE = %.0f EUR/MWh\n' ...
%       ], ...
%       Kite.CF, Kite.LCoE + Ultracap.LCoE, Ultracap.LPoE);  
%   text(0.1, 0.9, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
%   subplot(2,3,2);
%   hold on
%   str_2_print = sprintf(['AWE + Battery\n\n' ... ...
%       'Battery size = %.0f kWh\n' ...
%       'LCoE = %.0f EUR/MWh\n' ...
%       'LPoE = %.0f EUR/MWh\n' ...
%       ], ...
%       Battery.Size/1e3, Kite.LCoE+Battery.LCoE, Kite.Bat.LPoE);  
%   text(0.1, 0.9, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
%   subplot(2,3,3);
%   hold on
%   str_2_print = sprintf(['Battery\n\n' ... ...
%       'Battery size = %.0f kWh\n' ...
%       'LCoS = %.0f EUR/MWh\n' ...
%       'LPoS = %.0f EUR/MWh\n' ...
%       ], ...
%       Battery.Size/1e3, BESS.LCoS, BESS.LPoS);  
%   text(0.1, 0.9, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
% 
% 
% 
% subplot(2,3,4)
% 
%     plot(1:length(Kite.Power(4380:4716)),Kite.Power(4380:4716)/1e3,'LineWidth',0.5, 'color', '#50B2C0')
%     title('Power flows in two summer weeks','FontSize',8,'FontWeight', 'Bold')
%     xlim([0 length(Kite.Power(4380:4716))])
%     ylim([0 1.1*max(Kite.Power(4380:4716)/1e3)])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     legend('Kite Power','Location','northeast','FontSize',8,'NumColumns',1);
%     xlabel('Hours in Week','FontSize',8,'FontWeight', 'Bold')
%     legend('boxoff')
% hold off
% 
% subplot(2,3,5)
% 
%     plot(1:length(Grid.Kite(4380:4716)),Grid.Kite(4380:4716),'LineWidth',0.5, 'color', '#50B2C0')
%     hold on
%     plot(1:length(Grid.Battery(4380:4716)),Grid.Battery(4380:4716),'LineWidth',0.5, 'color', '#C94277')
%     title('Power flows in two summer weeks','FontSize',8,'FontWeight', 'Bold')
%     xlim([0 length(Kite.Power(4380:4716))])
%     ylim([0 1.1*max(Kite.Power(4380:4716)/1e3)])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     legend('Kite Power to grid', 'Battery Power to Grid','Location','northeast','FontSize',8,'NumColumns',1);
%     xlabel('Hours in Week','FontSize',8,'FontWeight', 'Bold')
%     legend('boxoff')
% hold off
% 
% subplot(2,3,6)
% 
%     plot(1:length(Battery.SoC2(4380:4716)),Battery.Charge2(4380:4716),'LineWidth',0.5, 'color', '#C94277')
%     hold on 
%     box off
%     title('Power flows in two summer weeks','FontSize',8,'FontWeight', 'Bold')
%     ylim([min(Battery.Charge2) max(Battery.Charge2)])
%     xlim([0 length(Battery.SoC2(4380:4716))])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',8,'FontWeight', 'Bold')
%     legend('Battery power', 'Battery Power to Grid','Location','northeast','FontSize',8,'NumColumns',1);
%     legend('boxoff')
% hold off


% figure('units', 'normalized', 'outerposition', [0.5 0.1 0.25 0.3])
% 
%     plot(1.1*1.4612, -544, ".",'MarkerSize',15, 'color', "b")
%     hold on
%     text(1.1*1.4612+10,-544, "Ultracapacitor",'FontSize',10)
%     plot(183, -450, ".",'MarkerSize',15, 'color', "r")
%     text(183+10.4612+10,-450, "Li-ion 183 kWh",'FontSize',10)
%     box off
%     title('DAM Profit per scenario','FontSize',12,'FontWeight', 'Bold')
%     xlim([-10 500])
%     ylim([-600 -400])
%     ylabel('Revenue [EUR]','FontSize',12,'FontWeight', 'Bold')
%     xlabel('Storage size [kWh]','FontSize',12,'FontWeight', 'Bold')
% hold off
% 
% figure('units', 'normalized', 'outerposition', [0 0.1 0.45 0.4])
% 
% subplot(1,2,1)                   % SoC week 
% 
%     plot(1:length(Battery.SoC(1:168)),100*(Battery.SoC(1:168)/Battery.Size),'LineWidth',0.25, 'color', '#C94277')
%     hold on 
%     box off
%     title('Battery State of Charge 1st week','FontSize',12,'FontWeight', 'Bold')
%     ylim([0 100])
%     xlim([0 length(Battery.SoC(1:168))])
%     ylabel('Battery State of Charge [%]','FontSize',12,'FontWeight', 'Bold')
%     xlabel('hr','FontSize',12,'FontWeight', 'Bold')
% hold off
% 
% subplot(1,2,2)                   % SoC week 
% 
%     plot(1:length(Battery.SoC(169:336)),100*(Battery.SoC(169:336)/Battery.Size),'LineWidth',0.25, 'color', '#C94277')
%     hold on 
%     box off
%     title('Battery State of Charge 2nd week','FontSize',12,'FontWeight', 'Bold')
%     ylim([0 100])
%     xlim([0 length(Battery.SoC(169:336))])
%     ylabel('Battery State of Charge [%]','FontSize',12,'FontWeight', 'Bold')
%     xlabel('hr','FontSize',12,'FontWeight', 'Bold')
% hold off


%% BESS standalone


% figure('units', 'normalized', 'outerposition', [0 0.1 0.45 0.4])
% 
% subplot(1,2,1)                   % SoC Batt exclusive 
% 
%     plot(1:length(Battery.SoC2),100*(Battery.SoC2/Battery.Size),'LineWidth',0.25, 'color', '#C94277')
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Battery State of Charge standalone','FontSize',12,'FontWeight', 'Bold')
%     ylim([0 100])
%     xlim([0 length(Battery.SoC2)])
%     ylabel('Battery State of Charge [%]','FontSize',12,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off
% 
% subplot(1,2,2)                    % Battery charge/discharge power
% 
%     plot(1:length(Battery.Charge2),Battery.Charge2,'LineWidth',0.25, 'color', '#50B2C0')
% %     plot(1:length(Battery.Smoothing),Battery.Smoothing,'LineWidth',0.25, 'color', '#FAAA8D')
%     yline(Battery.Size/1e3,'-','1 C');
%     yline(Battery.Size/2e3,'-','0.5 C');
%     yline(-Battery.Size/1e3,'-','-1 C');
%     yline(-Battery.Size/2e3,'-','-0.5 C');
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Battery Charge/Discharge','FontSize',12,'FontWeight', 'Bold')
%     ylim(1.1*[min(Battery.Charge2) max(Battery.Charge2)])
%     xlim([0 length(Battery.SoC2)])
%     ylabel('Battery standalone Charge/Discharge [kW]','FontSize',12,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off




% figure('units', 'normalized', 'outerposition', [0 0.1 0.45 0.4])

% subplot(2,1,1)                 % DAM price week 
% 
%     plot(1:length(inputs.DAMp(4025:4193)),inputs.DAMp(4025:4193),'LineWidth',0.25, 'color', '#50B2C0')
%     hold on 
%     box off
%     title('Power flows summer week','FontSize',12,'FontWeight', 'Bold')
%     ylim([min(inputs.DAMp) max(inputs.DAMp)])
%     xlim([0 length(Battery.SoC2(4025:4193))])
%     ylabel('Market price [EUR]','FontSize',12,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',8,'FontWeight', 'Bold')
% hold off
% 
% subplot(2,1,2)                 % SoC week 
% 
%     plot(1:length(Battery.SoC2(4025:4193)),Battery.Charge2(4025:4193),'LineWidth',0.25, 'color', '#C94277')
%     hold on 
%     box off
%     title('Power flows summer week','FontSize',12,'FontWeight', 'Bold')
%     ylim([min(Battery.Charge2) max(Battery.Charge2)])
%     xlim([0 length(Battery.SoC2(4025:4193))])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',8,'FontWeight', 'Bold')
% hold off



