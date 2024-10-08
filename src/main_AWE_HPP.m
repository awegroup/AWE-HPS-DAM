%%%% HPPModel
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
% Input variables that are relevent to either system initializing or
% sensitivity analysis

Cost.Subsidy = 110;                          % Subsidized electricity price [EUR/MWh] 110 from german AWE

Battery.Size        = 140e3;                % Wh
Battery.Type        = 1;                    % P/E or C rate
Battery.prog      = 1;                      % Battery price prognosis, 1: optimistic, 2: conservative
Cost.BatteryPrice   = [0.130 0.225];        % [EUR/Wh] first element is optimistic and second is conservative for 2030 projections source: https://www.nrel.gov/docs/fy21osti/79236.pdf
Battery.Eff         = 0.90;                  % Round trip efficiency [%]

inputs.Li_N = 1e4;        % [lifetime cycles]
inputs.Li_n = 10;         % [Lifetime years]

inputs.ultracap_p = 6e4;    % [EUR/Wh]
inputs.ultracap_N = 1e6;    % [cycles]

Battery.Minimum     = 0.1*Battery.Size;     % state of charge lower limit strage system [Wh]
Battery.Maximum     = 0.9*Battery.Size;     % state of charge upper limit strage system [Wh]




%% Resource inputs
% Wind and market data used in computing production and revenue

% ENTso-E Day Ahead Market Price bidding zone Netherlands 2019
inputs.DAM  = readtable('DAM_NL_2019.csv');
inputs.DAMp = inputs.DAM{:,"Var2"};                         % DAM price hourly [EUR/MWH]
inputs.DAMp = rmmissing(inputs.DAMp);

% ERA5 wind speeds at 100m 2019 at Haringvliet
inputs.u              = ncread('NL_Wind.nc','u100');                        
inputs.v              = ncread('NL_Wind.nc','v100');                         
inputs.vw = sqrt(inputs.u(1,1,:).^2+inputs.v(1,1,:).^2);    % The wind speed is a combination of the u and v component of the downloaded data
inputs.vw = reshape(inputs.vw,[],1);                        % Reshaping of the 1x1xN matrix to make it a vector

% Key indicators input data
inputs.DAMavg_winter = 0.5* mean(inputs.DAMp(1:2190)) + mean(inputs.DAMp(6571:8760));
inputs.DAMavg_summer = mean(inputs.DAMp(2190:6570));

inputs.Vwavg_winter = 0.5* (mean(inputs.vw(1:2190)) + mean(inputs.vw(6571:8760)));
inputs.Vwavg_summer = mean(inputs.vw(2190:6570));

inputs.vol = std(inputs.DAMp);          




%% AWE performance
% AWE performance computations using output values of the AWE-Power QSM

% inputs.kite_Pcurve = processedOutputs.P_e_avg;
% inputs.kite_Pcurve = [0	0	0	0	23928.0786858097	40782.2484684097	63234.1853813851	88411.6777416588	99999.9999822212	100000.000000336	99999.9999999685	99999.9999951410	99999.9999961658	99999.9999999519	100000.000000000	100000.000000000	100000.000000000	100000.000000000	100000.000022809	100000.000002251]';

inputs.kite_Pcurve = [0	0	0 0 6823.05494180757	20750.8552913604	40035.5511607199	63415.6188669052	85700.7504181529	99999.9999634139	99999.9999993995	100000.000000000	99999.9999612856	99999.9999939655	99999.9999993012	99999.9999999965	100000.000000000	100000.000000000	100000.000000000	100000	100000.000000000]';
% inputs.storageExchange = [0 0 0 0 108.039159313504	200.506068419865	329.917636884245	547.329686739828	609.546548475505	610.294848564850	611.680253023387	615.626123220090	615.462737064486	615.751877538799	617.185258454487	618.688207529163	620.269719798495	621.937042723459	623.697366188138	625.975247123629]/1e3;
inputs.storageExchange = [0	0	0 0 39.2114406427936	93.0947366719285	207.022440717841	412.999777754543	702.156555319391	810.070535420744	805.462031428633	808.180879889064	809.929699115073	813.114155193377	816.935309245319	821.167178788006	825.732017996912	830.577439826927	835.618275680234	840.916791101337	847.169221886612]/1e3;
% inputs.tCycle = [0	0	0	0	77.3554205106980	74.8369298463746	72.6676832706646	74.1704185876828	66.6928585762757	66.3576800140128	66.3292347556844	66.3323981105417	66.3947538186755	66.4478976760508	66.4305270459919	66.3912204881843	66.3442805951220	66.2929104622193	66.2375211047565	66.1691260112408];
inputs.tCycle = [0	0	0 0 199.110877845002	87.6714004467267	85.5139407777646	87.3579932218051	93.3237218054094	80.8992375788376	79.9581035213846	79.4595074569484	79.1889899452987	79.0790839654564	79.0738117712405	79.1297853113387	79.2192139488680	79.3068747121754	79.3241622327488	79.2940943437130	79.9040793712790];
% inputs.P_e_inst = [0 1.358231366870376e+02 1.235386302075073e+02 0 -10.135314791951744 -2.238176293112461e-09 0];       %Reeling power [kW]
inputs.P_e_inst = [0,137.381331953625,137.209204335937,0,-39.7295922699621,7.03564325810917e-14,0];
inputs.Pmi = [0	0	322.189763185042	-2.17062794576475e-09	123.115682108622	2565.37671859016	4339.68848630513	6114.39638457786	5585.59279958082	6109.04953576375	6432.34554190618	6946.16808636999	7537.37643857489	8180.32098809586	8868.95531895921	9603.57790961478	10387.4242674681	11223.3654792779	12138.2026136508]; %W
inputs.ti = [0	0	11.7879399982055	9.79979992755704	11.5450234403218	14.7365958129790	19.0157158771206	19.0158163029256	19.0175434666360	19.0195942145906	19.0211752356336	19.0224483791143	19.0234898353332	19.0243666537505	19.0251178273151	19.0256153900686	19.0255683228229	19.0252316629346	19.0150625316568]; %s


Kite.Pcurvefit     = linspace(0,25,26)';   % Wind speed range for curve fit
                                   
Kite.Pcurvefit1      = fit(Kite.Pcurvefit(4:10),inputs.kite_Pcurve(4:10),'poly5');  % For wind speed between cut-in and rated m/s 
Kite.Coeffs     = coeffvalues(Kite.Pcurvefit1);

Kite.Power1  = zeros(length(inputs.vw),1); 
for i = 1:length(inputs.vw)
  for vw = 1:length(inputs.kite_Pcurve)

    if inputs.vw(i) >= 4 && inputs.vw(i) <= 10

        Kite.Power1(i) = polyval(Kite.Coeffs,inputs.vw(i));

    elseif inputs.vw(i) >10

        Kite.Power1(i) = inputs.kite_Pcurve(10);

    else 

        Kite.Power1(i) = inputs.kite_Pcurve(1);

    end

  end
end

Kite.aboverated = Kite.Power1>1e5;
Kite.Power1(Kite.aboverated) = 1e5; 



Kite.Power  = zeros(length(inputs.vw),1);                    % [W]
for i = 1:length(inputs.vw)
  for vw = 1:length(inputs.kite_Pcurve)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1
          Kite.Power(i) = inputs.kite_Pcurve(vw); 
      
      end
  end
end

Kite.CF = sum(Kite.Power1)/(100e3*8760);
Battery.Preq = round(max(abs(inputs.P_e_inst-max(inputs.kite_Pcurve/1e3))),0)*1e3;                         %1C charge limit battery power [W]
Kite.sort = sort(Kite.Power1/1e3);

%% AWE Smoothing storage 
% Calculations for the smoothing Energy and Power at each timestep of the
% simulation



Battery.Smoothing = ones(8760,1);       % set-up

for i = 1:length(inputs.vw)                         % Smoothing intermediate storage needed per hour [Wh]
  for vw = 1:length(inputs.storageExchange)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1

          Battery.Smoothing(i) = inputs.storageExchange(vw)*1e3;            % smoothing capacity [Wh]
%           Battery.Psm(i) = Kite.Power(i);                                 % smoothing power capacity [kW]
          Battery.DoD(i) =  Battery.Smoothing(i)/(inputs.tCycle(vw)/3600);  % smoothing depth of discharge per hour [Wh]
      
      end
  end
end

Battery.Psm = (Battery.Preq/max(Kite.Power1))*Kite.Power1;


Battery.DoD(isnan(Battery.DoD))=0;

%% Scenario 1 AWE + Ultracap
% calculations of the first scenario, consisting of DAM direct bid AWE
% energy

AWEultracap.cap = (1.1*(max(inputs.storageExchange)));
AWEultracap.f_repl = sum(Battery.DoD/1e3)/AWEultracap.cap/inputs.ultracap_N;  % frequency of replacement ultracap system [/year]
AWEultracap.KiteE = sum(Kite.Power1/1e6);                   % sold kite power [MWh]
AWEultracap.R = sum((inputs.DAMp + Cost.Subsidy) .* (Kite.Power1/1e6),"omitnan");


%% Scenario 2 AWE + Battery
% calculations of the second scenario, consisting of DAM direct bid AWE
% energy with a Battery component replacing the smoothing capacity

AWEbat.frepl = max( 1/inputs.Li_n,sum(Battery.DoD)/(Battery.Preq*inputs.Li_N));

Battery.Excess = ((sum(Battery.DoD)/1e3)/(Battery.Preq*length(Battery.DoD)));






%% Scenario 3: Battery arbitrage SoC operation
% Calculations and simulation of the Battery charge/discharge simulation for stand-alone Battery

BESS.Size = 140e3;
BESS.w = 5;
BESS.var = 0.17;

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
BESS.E = sum(abs(min(BESS.C/1e3,0)));  

[Battarb.Batt,Battarb.C,Battarb.f_repl,Battarb.E,Battarb.R] = BattArb2(BESS.w, BESS.var, inputs.DAMp, zeros(1, length(inputs.DAMp)), zeros(1, length(inputs.DAMp)), BESS.Minimum, BESS.Maximum, BESS.Size, Battery.Type, Battery.Eff, inputs.Li_n, inputs.Li_N, zeros(1, length(inputs.DAMp)));







%% Scenario 4: AWE-Battery arbitrage SoC operation
% Calculations and simulation of the Battery charge/discharge simulation
% for a Battery system also being used for AWE power smoothing


                                                        

AWEarb.w = 4;
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
AWEarb.KiteE = sum(Kite.Power1/1e6);               % sold kite power [MWh]
AWEarb.E = AWEarb.battE + AWEarb.KiteE;


AWEarb.Rbatt = sum((inputs.DAMp + Cost.Subsidy).*abs(min(AWEarb.C/1e3,0)) - (inputs.DAMp + Cost.Subsidy).*max(AWEarb.C/1e3,0),"omitnan");
AWEarb.Rkite = sum((inputs.DAMp + Cost.Subsidy) .* (Kite.Power/1e6),"omitnan");
AWEarb.R = AWEarb.Rbatt + AWEarb.Rkite;

[AWEarbit.Batt,AWEarbit.C,AWEarbit.f_repl,AWEarbit.E,AWEarbit.Rbatt] = BattArb2(AWEarb.w, AWEarb.var, inputs.DAMp, Battery.Psm, Battery.Smoothing, Battery.Minimum, Battery.Maximum, Battery.Size, Battery.Type, Battery.Eff, inputs.Li_n, inputs.Li_N, Battery.DoD);





%% Economic metrics
% Performance metrics calculations of each scenario in order to analyse and
% compare economic viability

  inputs.business.N_y     = 25; % project years
  inputs.business.r_d     = 0.08; % cost of debt
  inputs.business.r_e     = 0.12; % cost of equity
  inputs.business.TaxRate = 0.25; % Tax rate (25%)
  inputs.business.DtoE    = 70/30; % Debt-Equity-ratio 

Cost.r = inputs.business.DtoE/(1+ inputs.business.DtoE)*inputs.business.r_d*(1-inputs.business.TaxRate) + 1/(1+inputs.business.DtoE)*inputs.business.r_e; 



Cost.Kite.ICC = 439e3;      % Capital cost kite system without intermediate storage, 439 from AWE-Eco, 150 from Sweder
Cost.Kite.OMC = 12.2e3;       % Operational cost kite system without intermediate storage, 12.2 from AWE-eco, 40 from Sweder

AWEultracap.CAPEX = inputs.ultracap_p*1.1*(max(inputs.storageExchange)) + Cost.Kite.ICC ;       % Capital expenditures ultracap component [EUR]
AWEultracap.OPEX = AWEultracap.f_repl*1.1*(max(inputs.storageExchange))*inputs.ultracap_p + Cost.Kite.OMC;                       % Operational expenditures ultracap component [EUR]

AWEbat.CAPEX           = Battery.Preq* Cost.BatteryPrice(Battery.prog) + Cost.Kite.ICC;
AWEbat.OPEX            = AWEbat.frepl * Battery.Preq* Cost.BatteryPrice(Battery.prog) + Cost.Kite.OMC;                     

AWEarb.CAPEX = Battery.Size * Cost.BatteryPrice(Battery.prog) + Cost.Kite.ICC;                     % Capital expenditures ultracap component [EUR]
AWEarb.OPEX = AWEarb.f_repl*Battery.Size*Cost.BatteryPrice(Battery.prog) + Cost.Kite.OMC;                       % Operational expenditures ultracap component [EUR]

BESS.CAPEX             = BESS.Size * Cost.BatteryPrice(Battery.prog);
BESS.OPEX              = BESS.f_repl*(BESS.Size * Cost.BatteryPrice(Battery.prog));

AWEarbit.CAPEX = Battery.Size * Cost.BatteryPrice(Battery.prog) + Cost.Kite.ICC;                     % Capital expenditures ultracap component [EUR]
AWEarbit.OPEX = AWEarbit.f_repl*Battery.Size*Cost.BatteryPrice(Battery.prog) + Cost.Kite.OMC;                       % Operational expenditures ultracap component [EUR]


[AWEultracap.LCoE, AWEultracap.LRoE, AWEultracap.LPoE, AWEultracap.NPV1] = EcoMetrics(Cost.r,AWEultracap.R,AWEultracap.KiteE,AWEultracap.CAPEX,AWEultracap.OPEX, inputs.business.N_y);
AWEultracap.NPV = NPV(Cost.r,AWEultracap.R,AWEultracap.CAPEX,AWEultracap.OPEX,inputs.business.N_y);
[AWEultracap.IRR,~] = fsolve(@(r) NPV2(r,AWEultracap.R,AWEultracap.KiteE,AWEultracap.CAPEX,AWEultracap.OPEX,inputs.business.N_y),0,optimoptions('fsolve','Display','none'));

[AWEbat.LCoE, AWEbat.LRoE, AWEbat.LPoE, AWEbat.NPV1] = EcoMetrics(Cost.r,AWEultracap.R,AWEultracap.KiteE,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y);
AWEbat.NPV = NPV(Cost.r,AWEultracap.R,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y);
[AWEbat.IRR,~] = fsolve(@(r) NPV2(r,AWEultracap.R,AWEultracap.KiteE,AWEbat.CAPEX,AWEbat.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));

[AWEarb.LCoE, AWEarb.LRoE, AWEarb.LPoE, AWEarb.NPV1] = EcoMetrics(Cost.r,AWEarb.R,AWEarb.E,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y);
AWEarb.NPV = NPV(Cost.r,AWEarb.R,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y);
[AWEarb.IRR,~] = fsolve(@(r) NPV(r,AWEarb.R,AWEarb.CAPEX,AWEarb.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[AWEarb.LF, AWEarb.VoSA] = StorageMetrics(AWEarb.Rbatt,AWEarb.C,Battery.Size,Battery.Type);

[BESS.LCoS, BESS.LRoS, BESS.LPoS, BESS.NPV1] = EcoMetrics(Cost.r,BESS.R,BESS.E,BESS.CAPEX,BESS.OPEX, inputs.business.N_y);
BESS.NPV = NPV(Cost.r,BESS.R,BESS.CAPEX,BESS.OPEX, inputs.business.N_y);
[BESS.IRR,~] = fsolve(@(r) NPV2(r,BESS.R,BESS.E,BESS.CAPEX,BESS.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[BESS.LF, BESS.VoSA] = StorageMetrics(BESS.R,BESS.C,BESS.Size,Battery.Type);

[Battarb.LCoS, Battarb.LRoS, Battarb.LPoS, Battarb.NPV1] = EcoMetrics(Cost.r,Battarb.R,Battarb.E,BESS.CAPEX,BESS.OPEX, inputs.business.N_y);
[Battarb.IRR,~] = fsolve(@(r) NPV(r,Battarb.R,BESS.CAPEX,BESS.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[Battarb.LF, Battarb.VoSA] = StorageMetrics(Battarb.R,Battarb.C,BESS.Size,Battery.Type);


AWEarbit.R = AWEarbit.Rbatt + AWEarb.Rkite;
AWEarbit.NPV = NPV(Cost.r,AWEarbit.R,AWEarbit.CAPEX,AWEarbit.OPEX, inputs.business.N_y);
[AWEarbit.IRR,~] = fsolve(@(r) NPV(r,AWEarbit.R,AWEarbit.CAPEX,AWEarbit.OPEX, inputs.business.N_y),0,optimoptions('fsolve','Display','none'));
[AWEarbit.LF, AWEarbit.VoSA] = StorageMetrics(AWEarbit.Rbatt,AWEarbit.C,Battery.Size,Battery.Type);


disp('---------------------------------------------------------')
% disp(['Scenario 1 IRR = ',num2str(round(AWEultracap.IRR*1e2,2)),' %'])
% disp(['Scenario 2 IRR = ',num2str(round(AWEbat.IRR*1e2,2)),' %'])
disp(['Scenario 4 Edisch = ',num2str(round(AWEarbit.E,4)),' MWh'])
disp(['Scenario 4 IRR = ',num2str(round(AWEarbit.IRR*1e2,4)),' %'])










%% Inputs data plotting

% figure('units', 'normalized', 'outerposition', [0 0.5 0.45 0.4]) %Location analysis
% 
% subplot(1,2,1)                   % DAM  2019

%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.25, 'color', '#87B6A7')
%     hold on
% %     yline(mean(inputs.DAMp, "omitnan"),'-');
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('DAM market clearing price NL bidding zone','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.DAMp)])
%     ylim([-10 125])
%     ylabel('Price [EUR/MWh]','FontSize',8,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off
% 
% subplot(1,2,2)                   % Wind speed 2019
% 
% plot(1:length(inputs.vw),inputs.vw,'LineWidth',1, 'color', '#7284A8')
%     hold on 
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('Wind speed at 100m at Haringvliet ','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.vw)])
%     ylim([0 1.1*max(inputs.vw)])
%     ylabel('Wind speed at 100 m [m/s]','FontSize',8,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off

%% AWE performance plotting
% 
% figure('units', 'normalized', 'outerposition', [0 0.5 0.45 0.4])

% Powercurve 100 kW AWE
% 
% inputs.kite_Pcurve(22:25) = zeros(1,4);
% 
% plot(1:length(inputs.kite_Pcurve),inputs.kite_Pcurve/1e3,'LineWidth',1.5, 'color', '#0D3B66')
%     hold on
% plot(1:length(inputs.kite_Pcurve),inputs.kite_Pcurve/1e3,'.','MarkerSize',15, 'color', '#0D3B66')
%     title('AWE Power curve 100 kW system','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 25])
%     ylim([0 1.4*max(inputs.kite_Pcurve)/1e3])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
% %     legend('P_{e, avg}','Location','northeast','FontSize',8,'NumColumns',1);
%     xlabel('Wind speed at 100 m (m/s)','FontSize',8,'FontWeight', 'Bold')
% %     legend('boxoff')
% grid on
% hold off

% bar(1:length(Kite.Power),Kite.Power1/1e3, 'FaceColor', '#355070')
%     box off
%     set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
%         {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
%         'Aug','Sep','Oct','Nov','Dec'})
%     title('AWE power output hourly over full year ','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.vw)])
%     ylim([0 1.1*max(Kite.Power1/1e3)])
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     xtickangle(45)
% hold off
% 
figure()  % Reeling power 100 kW AWE

    hold on
    yline(0,'-k','LineWidth',0.5);
    plot([0 1 43 45 51 65 66.7],inputs.P_e_inst,'LineWidth',1, 'color', 'k')

    yline(100,'--','LineWidth',1.5, 'color', '#40376E');
    text(66.7,100,'  P_{e, avg}','FontSize',10);
    
    plot([43 66.7],[137.209 137.209],'LineWidth',1.5, 'LineStyle',"--" ,'color', '#1F936C')
    plot(43,137.209,'.','MarkerSize',20,'color', '#1F936C')
    text(66.7,137.209,'  P_{e, o, peak}','FontSize',10);

    plot([51 66.7],[-39.7296 -39.7296],'LineWidth',1.5, 'LineStyle',"--" , 'color', '#DF7355')
    plot(51,-39.7296,'.','MarkerSize',20,'color', '#DF7355')
    title('Reeling power over one cycle at rated wind speed','FontSize',12,'FontWeight', 'Bold')
    text(66.7,-39.7296,'  P_{e, i, peak}','FontSize',10);

    xlim([0 66.7])
    ylim([1.3*min(inputs.P_e_inst) 1.3*max(inputs.P_e_inst)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     legend('P_{e}','P_{e, avg}','P_{Smoothing, max}','Location','northeast','FontSize',10,'NumColumns',1);
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
%     legend('boxoff')
hold off



figure()  % Reeling energy 100 kW AWE

    hold on
    
    
    area([0 1 43] ,inputs.P_e_inst(1:3), 'FaceColor', '#1F936C')
    area([43 43.5424] ,[137.209 100], 'FaceColor', '#1F936C')
    area([0.1 43.5424] ,[100 100], 'FaceColor', '#FFFFFF')
    text(43,120,'  \leftarrow  E_{e, o} -  E_{e, avg}','FontSize',10);

    area([45 51 65 66.7] ,inputs.P_e_inst(4:7), 'FaceColor', '#DF7355')
    area([45 51 65] ,[100 100 100], 'FaceColor', '#DF7355')
    area([43.5424 45] ,[100 100], 'FaceColor', '#DF7355')
    area([43.5424 45] ,[100 0], 'FaceColor', '#FFFFFF')
    text(43,40,'  E_{e, i} +  E_{e, avg} \rightarrow','FontSize',10,'HorizontalAlignment','right');
    yline(0,'-k','LineWidth',0.5);


    yline(100,'--','LineWidth',2.5, 'color', '#40376E');
    text(66.7,100,'  P_{e, avg}','FontSize',10);

    title('Reeling energy over one cycle at rated wind speed','FontSize',12,'FontWeight', 'Bold')
    xlim([0 66.7])
    ylim([1.3*min(inputs.P_e_inst) 1.3*max(inputs.P_e_inst)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     legend('P_{e}','P_{e, avg}','P_{Smoothing, max}','Location','northeast','FontSize',10,'NumColumns',1);
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
%     legend('boxoff')
hold off

% figure('Name','Kite power sorted','units', 'normalized', 'outerposition', [0 0.5 0.45 0.4])



% plot(1:length(Kite.sort),Kite.sort,'LineWidth',1.5, 'color', '#0D3B66')
%     xlim([0 length(Kite.sort)])
%     ylim([0 1.4*max(Kite.sort)])
%     xlabel('Hours of year','FontSize',8,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
%     title('AWE power output sorted in ascending order','FontSize',10,'FontWeight', 'Bold')
%     xticks(365+730*(0:1:12))
%     xticklabels({'365','1095','1825','2555','3285','4015','4745','5475','6205','6935','7665','8395'})



%% Battery performance plots

% Battery

% figure('Name','Battery performance excess capacity','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);

% subplot(1,2,1);                 % Excess Energy         
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+0.1*Battery.Size)/1e3, 'FaceColor', '#564D80')
%     hold on
%     area(1:length(Battery.Smoothing/1e3),ones(1,length(Battery.Smoothing))*0.1*Battery.Size/1e3, 'FaceColor', '#FFFFFF')
%     yline(0.2*Battery.Size/1e3,'-','20 %','FontSize',10);
%     yline(0.1*Battery.Size/1e3,'-','10 %','LabelVerticalAlignment','bottom','FontSize',10 );
%     ylim([10 1.1*0.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('Smoothing energy reserved capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
% %     legend('Smoothing Energy','Location','northeastoutside','FontSize',8,'NumColumns',1);
% %     legend('boxoff')
% 
%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power))*Kite.Power/1e3, 'FaceColor', '#B2675E')
%     hold on
%     yline(Battery.Size/1e3,'-','1 C');
%     ylim([0 1.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('Smoothing Power reserved capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
% %     legend('Smoothing Energy','Location','northeastoutside','FontSize',8,'NumColumns',1);
% %     legend('boxoff')

% ultracap

% figure('Name','Ultracap performance excess capacity','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% % subplot(1,2,1);                 % Excess Energy         
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+0.1*AWEultracap.cap*1e3)/1e3, 'FaceColor', '#564D80')
%     hold on
%     area(1:length(Battery.Smoothing/1e3),ones(1,length(Battery.Smoothing))*0.1*AWEultracap.cap, 'FaceColor', '#FFFFFF')
%     yline(1.1*AWEultracap.cap,'-','100 %','FontSize',10);
%     yline(0.1*AWEultracap.cap,'-','0 %','LabelVerticalAlignment','bottom','FontSize',10 );
%     ylim([0 1.2*AWEultracap.cap])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('Smoothing energy reserved capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('Smoothing Energy','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')

%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power))*Kite.Power/1e3, 'FaceColor', '#B2675E')
%     hold on
%     yline(AWEultracap.cap*150,'-','150 C');
%     ylim([0 1.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('Smoothing Power reserved capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
% %     legend('Smoothing Energy','Location','northeastoutside','FontSize',8,'NumColumns',1);
% %     legend('boxoff')

% figure('Name','Arbitrage Battery operation','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);



% yyaxis left                       % DAM 
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.2, 'color', '#DFB4BE')
%     xlim([0 length(inputs.DAMp)])
%     ylim([0 80])
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
% 
% yyaxis right                    % Arbitrage operation
% 
%     area(1:length(Battarb.C),max(Battarb.C,0), 'FaceColor', '#DE8F6E')
%     hold on
%     area(1:length(Battarb.C),abs(min(Battarb.C,0)), 'FaceColor', '#88AB75')
%     ylim([0 1.4*abs(max(Battarb.C))])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('DAM price','Battery charge','Battery discharge','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';
%     hold off


%     bar(1:length(Kite.Power/1e3),Kite.Power/1e3, 'FaceColor', '#B3DCE7')
%     hold on
%     bar(1:length(AWEarbit.C),max(AWEarbit.C,0), 'FaceColor', '#DE8F6E')
%     bar(1:length(AWEarbit.C),abs(min(AWEarbit.C,0)), 'FaceColor', '#88AB75')
%     ylim([0 1.3*abs(max(AWEarbit.C))])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('AWE + Battery arbitrage power','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('AWE power','Battery charge','Battery discharge', 'AWE power','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     set(gca,'TickLength',[0 0]);
%     hold off

%% Arbitrage operation plots

figure()  % Arbitrage model

    hold on
    yline(0,'-k','LineWidth',0.5);
    plot((0:10),[25 28 35 56 32 11 21 36 34 29 35],'LineWidth',1, 'color', 'k')

    yline(mean([25 28 35 56 32 11 21 36 34 29 35]),'--','LineWidth',1.5, 'color', '#40376E');
    text(10,mean([25 28 35 56 32 11 21 36 34 29 35]),' \mu_{DAM, w}','FontSize',12);

    yline(1.25*mean([25 28 35 56 32 11 21 36 34 29 35]),'--','LineWidth',1.5, 'color', '#40376E');
    text(6.5,1.33*mean([25 28 35 56 32 11 21 36 34 29 35]),' (1 + \sigma_{DAM}) \mu_{DAM, w}','FontSize',12);

    yline(0.75*mean([25 28 35 56 32 11 21 36 34 29 35]),'--','LineWidth',1.5, 'color', '#40376E');
    text(6.5,0.67*mean([25 28 35 56 32 11 21 36 34 29 35]),' (1 - \sigma_{DAM}) \mu_{DAM, w}','FontSize',12);
    

    plot(3,56,'.','MarkerSize',20,'color', 'r')
    text(3,56,'  \leftarrow E_{t+1} - E_{t} =  - P_{max}','FontSize',14);

    plot(5,11,'.','MarkerSize',20,'color', 'r')
    text(5,11,'  \leftarrow E_{t+1} - E_{t} =  P_{max}','FontSize',14);

    xlim([0 10])
    ylim([5 60])
    ylabel('Price [EUR]','FontSize',10,'FontWeight', 'Bold')
%     legend('P_{e}','P_{e, avg}','P_{Smoothing, max}','Location','northeast','FontSize',10,'NumColumns',1);
    xlabel('Time (hr)','FontSize',10,'FontWeight', 'Bold')
%     legend('boxoff')
hold off

% figure('Name','Storage arbitrage window operation','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])
% 
%   subplot(2,1,1);
%                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'color', '#DFB4BE')
%     title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
%     xlim([5898 5898+24])
%     ylim([20 60])
%     set(gca,'TickLength',[0 0],'XTick',[]);
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('DAM price','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
% 
% 
%     subplot(2,1,2);                   % Battery charge/discharge power
% 
%     bar(1:length(Battarb.C),abs(min(Battarb.C,0)), 'FaceColor', '#DE8F6E')
%     hold on
%     bar(1:length(Battarb.C),abs(max(Battarb.C,0)), 'FaceColor', '#88AB75')
% %     yline(BESS.Size/1e3,'-','1 C');
% %     yline(BESS.Size/2e3,'-','0.5 C');
% %     yline(-BESS.Size/1e3,'-','-1 C');
% %     yline(-BESS.Size/2e3,'-','-0.5 C');
%     ylim([0 1.6*max(Battarb.C)])
%     xlim([5898 5898+24])
%     xticks((5898)+(2:2:24))
%     xticklabels({'1hr','2hrs','3hrs','4hrs','5hrs','6hrs','7hrs','8hrs','9hrs','10hrs','11hrs','12hrs'})
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Time ','FontSize',10,'FontWeight', 'Bold')
% %     title('Battery arbitrage charging behavior in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     legend('Discharge to Grid', 'Charge from Grid','Location','northeastoutside','FontSize',8,'NumColumns',2);
%     legend('boxoff')
%     hold off
% 
% figure('Name','Storage arbitrage behavior','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])
% 
%   subplot(2,1,1);
%                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'color', '#DFB4BE')
%     title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
%     xlim([5898 5898+2*24])
%     ylim([20 60])
%     set(gca,'TickLength',[0 0],'XTick',[]);
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('DAM price','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
% 
% 
%     subplot(2,1,2);                   % Battery charge/discharge power
% 
%     bar(1:length(Battarb.C),abs(min(Battarb.C,0)), 'FaceColor', '#DE8F6E')
%     hold on
%     bar(1:length(Battarb.C),abs(max(Battarb.C,0)), 'FaceColor', '#88AB75')
% %     yline(BESS.Size/1e3,'-','1 C');
% %     yline(BESS.Size/2e3,'-','0.5 C');
% %     yline(-BESS.Size/1e3,'-','-1 C');
% %     yline(-BESS.Size/2e3,'-','-0.5 C');
%     ylim([0 1.6*max(Battarb.C)])
%     xlim([5898 5898+2*24])
%     xticks((5898)+(10:8:2*24))
%     xticklabels({'w','2w','3w','4w','5w','6w','7w','8w','9w','10w','11w','12w'})
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Arbitrage window within one day','FontSize',10,'FontWeight', 'Bold')
% %     title('Battery arbitrage charging behavior in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     legend('Discharge to Grid', 'Charge from Grid','Location','northeastoutside','FontSize',8,'NumColumns',2);
%     legend('boxoff')
%     hold off

% 
%    figure('Name','Storage arbitrage combined smoothing','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])
%   
% 
%     subplot(2,1,1);
 
%                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.2, 'color', '#DFB4BE')
%     title('Bidding operation AWE smoothing and arbitrage over one week','FontSize',10,'FontWeight', 'Bold')
%     xlim([2600 2600+24*7])
%     ylim([0 70])
%     set(gca,'TickLength',[0 0],'XTick',[]);
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     legend('DAM price','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')


%                       % SoC
%     plot(1:length(inputs.DAMp),(AWEarbit.Batt/Battery.Size)*100,'LineWidth',1.5, 'color', '#DFB4BE')
%     title('Bidding operation AWE smoothing and arbitrage over one week','FontSize',10,'FontWeight', 'Bold')
%     xlim([2600 2600+24*7])
%     ylim([0 100])
%     set(gca,'TickLength',[0 0],'XTick',[]);
%     ylabel('SoC [%]','FontSize',10,'FontWeight', 'Bold')
% %     legend('State of Charge','Location','northeastoutside','FontSize',8,'NumColumns',1);
% %     legend('boxoff')
% 
% 
%    subplot(2,1,2);                   % Battery power types
%  
%     hold on
%     bar(1:length(AWEarb.C),0.98*(Battery.Preq/max(Kite.Power1))*Kite.Power1/1e3+ abs(max(AWEarbit.C,0)), 'FaceColor', '#88AB75')
%     bar(1:length(AWEarb.C),0.98*(Battery.Preq/max(Kite.Power1))*Kite.Power1/1e3+ abs(min(AWEarbit.C,0)), 'FaceColor', '#DE8F6E')
%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power1))*Kite.Power1/1e3, 'FaceColor', '#564D80')
%     yline(Battery.Size/1e3,'-','    1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
%     ylim([0 1.4*Battery.Size/1e3])
%     xlim([2600 2600+24*7])
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     legend('Charged from grid','Discharged to grid', 'Smoothing Power','Location','northeastoutside','FontSize',8,'NumColumns',3);
%     legend('boxoff')
%     xticks((2600)+(12:24:24*7))
%     xticklabels({'M','T','W','T','F','S','S'})
% hold off








%% Plots Scenario 1 AWE ultracap

% figure('Name','Scenario 1 AWE+ultracap','units', 'normalized', 'outerposition', [0 0.6 0.5 0.5]);
% 
% %   subplot(2,1,1);
% % 
% %   hold on
% %   str_2_print = sprintf(['AWE + Ultracapacitor\n\n' ...
% %       'LCoE = %.0f EUR/MWh\n' ...
% %       'LPoE = %.1f EUR/MWh\n' ...
% %       'IRR = %.3f percent\n' ...
% %       'Produced energy = %.0f MWh\n' ...
% %       ], ...
% %       AWEultracap.LCoE, AWEultracap.LPoE, AWEultracap.IRR*1e2, AWEultracap.KiteE);  
% % 
% %   text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
% %   axis off
% % 
% %   subplot(2,1,2);
% 
%     yyaxis left                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#DFB4BE')
%     title('AWE produced power over DAM price in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.DAMp(4380:4716))])
%     ylim([20 60])
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
% 
% 
%     yyaxis right                    % Produced Kite power
% 
%     area(1:length(Kite.Power(4380:4716)/1e3),Kite.Power(4380:4716)/1e3, 'FaceColor', '#577399')
%     ylim([0.9*min(Kite.Power(4380:4716)/1e3) 1.2*max(Kite.Power(4380:4716)/1e3)])
%     xlim([0 length(Kite.Power(4380:4716)/1e3)])
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';
%     hold off

% figure('Name','Scanario 1 excess capacity','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);

% subplot(3,1,1);                 % Excess Energy         
%     bar(1:length(Battery.DoD/1e3),Battery.Smoothing/1e3+0.1*AWEultracap.cap, 'FaceColor', '#564D80')
%     hold on
%     area(1:length(Battery.Smoothing/1e3),ones(1,length(Battery.Smoothing))*0.1*AWEultracap.cap, 'FaceColor', '#FFFFFF')
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     yline(AWEultracap.cap*1.1,'-','100 %','LabelVerticalAlignment','bottom' );
%     yline(0.1*AWEultracap.cap,'-','0 %','LabelVerticalAlignment','top' );
%     ylim([0 1.2*AWEultracap.cap])
%     xlim([5950 5950+24*14])
%     title('Smoothing energy use of Ultracapacitor capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[],'YTick',[]);
% hold off

% subplot(3,1,2);             % Excess Power 
%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power))*Kite.Power/1e3, 'FaceColor', '#B2675E')
%     hold on
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     yline(AWEultracap.cap*200,'-','200 C');
%     ylim([0 AWEultracap.cap*220])
%     xlim([5950 5950+24*14])
%     title('Smoothing power use of ultracapacitor power limit','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[],'XTick',[]);
% hold off
% 
% subplot(3,1,3);   % DAM price
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'Color', '#C59FC9')
%     hold on
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     ylim([15 75])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('DAM price','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0]);
% hold off




%% Plots Scenario 2 AWE Battery

% figure('Name','Scanario 2 AWE-Batt','units', 'normalized', 'outerposition', [0.5 0.6 0.5 0.5]);
% 
%   subplot(2,1,1);
% 
%   hold on
%   str_2_print = sprintf(['AWE + Battery\n\n' ...
%       'LCoE = %.0f EUR/MWh\n' ...
%       'LPoE = %.1f EUR/MWh\n' ...
%       'IRR = %.3f percent\n' ...
%       'Produced energy = %.0f MWh\n' ...
%       ], ...
%       AWEbat.LCoE, AWEbat.LPoE, AWEbat.IRR*1e2, AWEultracap.KiteE);  
% 
%   text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
%   subplot(2,1,2);
% 
%     yyaxis left                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp(4380:4716)),inputs.DAMp(4380:4716),'LineWidth',0.2, 'color', '#DFB4BE')
%     title('Kite power in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     xlim([0 length(inputs.DAMp(4380:4716))])
%     ylim([20 60])
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
% 
% 
%     yyaxis right                    % Produced Kite power
% 
%     area(1:length(Kite.Power(4380:4716)/1e3),Kite.Power(4380:4716)/1e3, 'FaceColor', '#577399')
%     ylim([0.9*min(Kite.Power(4380:4716)/1e3) 1.2*max(Kite.Power(4380:4716)/1e3)])
%     xlim([0 length(Kite.Power(4380:4716)/1e3)])
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hour in Week','FontSize',10,'FontWeight', 'Bold')
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';
%     hold off

% figure('Name','Scanario 4 excess capacity','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% subplot(3,1,1);                 % Excess Energy         
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+0.1*Battery.Size)/1e3, 'FaceColor', '#564D80')
%     hold on
%     area(1:length(Battery.Smoothing/1e3),ones(1,length(Battery.Smoothing))*0.1*Battery.Size/1e3, 'FaceColor', '#FFFFFF')
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     yline(0.2*Battery.Size/1e3,'-','20 %');
%     yline(0.1*Battery.Size/1e3,'-','10 %','LabelVerticalAlignment','top' );
%     ylim([10 1.1*0.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     title('Smoothing energy use of battery capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
%     grid on
% hold off
% 
% subplot(3,1,2);             % Excess Power 
%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power))*Kite.Power/1e3, 'FaceColor', '#B2675E')
%     hold on
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     yline(Battery.Size/1e3,'-','1 C');
%     ylim([0 1.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     title('Smoothing power use of battery power limit','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
% hold off
% 
% subplot(3,1,3);   % DAM price
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'Color', '#C59FC9')
%     hold on
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     ylim([15 75])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('DAM price','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0]);
% hold off



%% Plots Scenario 3 Battery arbitrage


figure('Name','Scenario 4 Batt arbitrage','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])
% 
%   subplot(2,1,1);
%   hold on
%   str_2_print = sprintf(['Battery storage DAM arbitrage \n\n' ... ...
%       'Battery size = %.0f kWh\n' ...
%       'LCoS = %.0f EUR/MWh\n' ...
%       'LPoS = %.0f EUR/MWh\n' ...
%       'IRR = %.3f percent\n' ...
%       'Discharged energy = %.0f MWh\n' ...
%       'Value of Arbitrage = %.0f kEUR/MW/year\n' ...
%       ], ...
%       BESS.Size/1e3, BESS.LCoS,BESS.LPoS, BESS.IRR*1e2, BESS.E, BESS.VoSA);  
%   text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
%   subplot(2,1,1);
%                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.2, 'color', '#DFB4BE')
%     title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
%     xlim([5950 5950+24*14])
%     ylim([20 80])
%     set(gca,'TickLength',[0 0],'XTick',[]);
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
% %     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
%     legend('DAM price','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')


%     subplot(2,1,2);                   % Battery charge/discharge power
% 
%     bar(1:length(BESS.C),abs(min(BESS.C,0)), 'FaceColor', '#DE8F6E')
%     hold on
%     bar(1:length(BESS.C),abs(max(BESS.C,0)), 'FaceColor', '#88AB75')
% %     yline(BESS.Size/1e3,'-','1 C');
% %     yline(BESS.Size/2e3,'-','0.5 C');
% %     yline(-BESS.Size/1e3,'-','-1 C');
% %     yline(-BESS.Size/2e3,'-','-0.5 C');
%     ylim([0 1.6*max(BESS.C)])
%     xlim([5950 5950+24])
%     xticks((5950)+(0:4:24))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Arbitrage window within one day','FontSize',10,'FontWeight', 'Bold')
% %     title('Battery arbitrage charging behavior in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     legend('Discharge to Grid', 'Charge from Grid','Location','northeastoutside','FontSize',8,'NumColumns',2);
%     legend('boxoff')
%     hold off

% 
%  figure('Name','Scanario 3 Battery limits','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% subplot(1,2,1);                 % Excess Energy         
%     hold on
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+AWEarb.Batt)/1e3, 'FaceColor', '#DE8F6E')
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+0.1*Battery.Size)/1e3, 'FaceColor', '#564D80')
%     bar(1:length(Battery.DoD/1e3),ones(1,length(Battery.Smoothing))*0.1*Battery.Size/1e3, 'FaceColor', '#FFFFFF')
%     yline(0.9*Battery.Size/1e3,'-','90 %');
%     yline(0.1*Battery.Size/1e3,'-','10 %','LabelVerticalAlignment','bottom' );
%     ylim([0 1.2*0.9*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     title('Smoothing energy capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     legend('Battery Arbitrage Energy','Smoothing Energy' ,'Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
% 
% subplot(1,2,2);             % Excess Power 
%     bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power))*Kite.Power/1e3, 'FaceColor', '#564D80')
%     hold on
%     bar(1:length(AWEarb.C),abs(min(AWEarb.C,0)), 'FaceColor', '#DE8F6E')
%     bar(1:length(AWEarb.C),abs(max(AWEarb.C,0)), 'FaceColor', '#88AB75')
%     yline(Battery.Size/1e3,'-','1 C');
%     ylim([0 1.2*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     title('Smoothing power capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hour in Year','FontSize',10,'FontWeight', 'Bold')
%     legend('Smoothing power', 'Battery discharge power','Battery charge power','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     hold off

figure('Name','Scanario 3 battery limits','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% subplot(3,1,1);                 % Energy capacity  
% 
%     hold on
%     bar(1:length(Battery.DoD/1e3),Battarb.Batt/1e3, 'FaceColor', '#564D80')
%     area(1:length(Battery.DoD/1e3),ones(1,length(Battery.Smoothing))*0.1*Battery.Size/1e3, 'FaceColor', '#FFFFFF')
%     yline(0.9*Battery.Size/1e3,'-','90 %','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
%     yline(0.1*Battery.Size/1e3,'-','10 %','LabelVerticalAlignment','bottom' ,'LabelHorizontalAlignment','left' );
%     ylim([0 1.2*0.9*Battery.Size/1e3])
%     xlim([5688 5688+24*14])
%     title('Energy use of battery capacity','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
% hold off
% 
% subplot(3,1,2);             % Excess Power 
%     hold on
%     bar(1:length(AWEarb.C),max(Battarb.C,0), 'FaceColor', '#DE8F6E')
%     bar(1:length(AWEarb.C),abs(min(Battarb.C,0)), 'FaceColor', '#88AB75')
%     yline(BESS.Size/1e3,'-','1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
%     ylim([0 1.2*Battery.Size/1e3])
%     xlim([5688 5688+24*14])
%     title('Power use of battery power limit','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
%     legend('Battery charge', 'Battery discharge','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
% hold off
% 
% subplot(3,1,3);   % DAM price
    plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'Color', '#C59FC9')
    hold on
    ylim([15 80])
    xlim([5688 5688+24*14])
    xticks((5688+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('DAM price','FontSize',10,'FontWeight', 'Bold')
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
hold off





%% Plots Scenario 4 AWE + Battery arbitrage


figure('Name','Scenario 3 AWE+Batt arbitrage','units', 'normalized', 'outerposition', [0 0.05 0.5 0.6])
% 
%   subplot(2,1,1);
% 
%   hold on
%   str_2_print = sprintf(['AWE + Battery seperate arbitrage\n\n' ...
%       'LCoE = %.0f EUR/MWh\n' ...
%       'LPoE = %.1f EUR/MWh\n' ...
%       'IRR = %.3f percent\n' ...
%       'Sold kite energy = %.0f MWh\n' ...
%       'Sold battery energy = %.0f MWh\n' ...
%       'Value of Arbitrage = %.0f kEUR/MW/year\n' ...
%       ], ...
%       AWEarb.LCoE, AWEarb.LPoE, AWEarb.IRR*1e2, AWEultracap.KiteE, AWEarb.battE,AWEarb.VoSA);  
% 
%   text(0.1, 0.85, str_2_print, 'Interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'cap'); 
%   axis off
% 
%   subplot(2,1,2);
% 
%     yyaxis left                       % DAM  2019
% 
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.2, 'color', '#DFB4BE')
%     title('AWE and Battery power in two summer weeks','FontSize',10,'FontWeight', 'Bold')
%     xlim([4380 4716])
%     ylim([20 80])
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
% 
% 
%     yyaxis right                    % Power2Grid flows
% 
    bar(1:length(Kite.Power),Kite.Power1/1e3, 'FaceColor', '#577399')
    hold on
    bar(1:length(AWEarb.C),abs(min(AWEarbit.C,0)), 'FaceColor', '#DE8F6E')
    bar(1:length(AWEarb.C),abs(max(AWEarbit.C,0)), 'FaceColor', '#88AB75')
    ylim([0 130])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day within week','FontSize',10,'FontWeight', 'Bold')
     title('AWE + Battery arbitrage operation','FontSize',10,'FontWeight', 'Bold')
    legend('Kite Power to Grid', 'Battery Power to Grid','Battery Power from Grid','Location','northeastoutside','FontSize',8,'NumColumns',3);
    legend('boxoff')
    set(gca,'TickLength',[0 0]);
%     ax = gca;
%     ax.YAxis(1).Color = 'k';
%     ax.YAxis(2).Color = 'k';
    hold off




figure('Name','Scanario 4 battery limits','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% subplot(3,1,1);                 % Energy capacity  
% 
%     hold on
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+AWEarb.Batt)/1e3, 'FaceColor', '#564D80')
%     bar(1:length(Battery.DoD/1e3),(Battery.Smoothing+0.1*Battery.Size)/1e3, 'FaceColor', '#DE8F6E')
%     bar(1:length(Battery.DoD/1e3),ones(1,length(Battery.Smoothing))*0.1*Battery.Size/1e3, 'FaceColor', '#FFFFFF')
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     yline(0.9*Battery.Size/1e3,'-','90 %','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
%     yline(0.1*Battery.Size/1e3,'-','10 %','LabelVerticalAlignment','bottom' ,'LabelHorizontalAlignment','left' );
%     ylim([0 1.2*0.9*Battery.Size/1e3])
%     xlim([5950 5950+24*14])
%     title('Energy use of battery capacity','FontSize',10,'FontWeight', 'Bold')
%     legend('Battery Energy', 'Smoothing Energy','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
%     grid on
% hold off
% 
% subplot(3,1,2);             % Excess Power 
    hold on
    bar(1:length(AWEarb.C),0.98*(Battery.Preq/max(Kite.Power1))*Kite.Power1/1e3+ abs(AWEarb.C), 'FaceColor', '#DE8F6E')
    bar(1:length(Kite.Power),0.98*(Battery.Preq/max(Kite.Power1))*Kite.Power1/1e3, 'FaceColor', '#564D80')
    yline(Battery.Size/1e3,'-','1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    ylim([0 1.2*Battery.Size/1e3])
    xlim([5950 5950+24*14])
    title('Power use of battery power limit','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    legend('Battery Power', 'Smoothing Power','Location','northeastoutside','FontSize',8,'NumColumns',1);
    legend('boxoff')
    set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
hold off
% 
% subplot(3,1,3);   % DAM price
%     plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',1, 'Color', '#C59FC9')
%     hold on
%     xline(6018,':','LineWidth',2);
%     xline(6070,':','LineWidth',2);
%     xline(6186,':','LineWidth',2);
%     xline(6215,':','LineWidth',2);
%     ylim([15 75])
%     xlim([5950 5950+24*14])
%     xticks((5950+12)+(0:24:(336-12)))
%     xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
%     title('DAM price','FontSize',10,'FontWeight', 'Bold')
%     ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0]);
% hold off
% 
figure('Name','Scanario 4 replacement shares','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);
% 
% 
% ax = gca();
% pie(ax,[sum(Battery.DoD)/(Battery.Preq*inputs.Li_N) AWEarbit.f_repl-sum(Battery.DoD)/(Battery.Preq*inputs.Li_N)]/AWEarbit.f_repl);
% ax.Colormap = (1/255)*[119, 133, 172; 154, 198, 197;56,163,165];
% 
% legend({'Power Smoothing', 'Arbitrage'},'Location','southoutside','Orientation','horizontal')
% legend('boxoff')

ax = gca();
bar(ax,[  sum(Battery.DoD)/(Battery.Preq) 0 ;...
      sum(Battery.DoD)/(Battery.Preq) AWEarbit.f_repl*inputs.Li_N-sum(Battery.DoD)/(Battery.Preq)],'Stacked')
ax.Colormap = (1/255)*[119, 133, 172; 154, 198, 197;56,163,165];
title('Battery replacement cycle per application type','FontSize',10,'FontWeight', 'Bold')
ylim([0 1200])
ylabel('Full load cycles','FontSize',10,'FontWeight', 'Bold')
xticklabels({'AWE + Battery','AWE + Battery arbitrage'})
legend({'Power Smoothing', 'Arbitrage'},'Location','southoutside','Orientation','horizontal','NumColumns',1)
legend('boxoff')

%% Plots discussion

Disc.LCoE = [150 133 60.43 123];
Disc.E = [343 343 48.65 343+38.7];
Disc.IRR = [7.09 9.69 9.8];
Disc.NPV = [-29 61 -20.2 65.6];
Disc.Capex = [495 457 18.2 457];

% figure('Name','Scenario comparison metrics','units', 'normalized', 'outerposition', [0 0.05 0.5 0.6])
% 
% yyaxis left
%     bar(Disc.LCoE, 'FaceColor', '#B3DCE7');
%     hold on
%     text(1:length(Disc.LCoE),Disc.LCoE,num2str(Disc.LCoE'),'vert','bottom','horiz','center'); 
%     ylim([0 170])
%     xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
%     xtickangle(45)
%     title('LCoE values levelized over energy discharged to grid','FontSize',10,'FontWeight', 'Bold')
%     ylabel('LCoE [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0]);
%     hold off
% 
%         yyaxis right 
%         plot((1:4),Disc.E,'LineWidth',1, 'Color', '#545E75')
%         hold on
%         plot((1:4),Disc.E,'.','MarkerSize',15, 'color', '#0D3B66')
%         ylim([0 550])
%         ylabel('Energy discharged to grid [MWh]','FontSize',10,'FontWeight', 'Bold')
%         ax = gca;
%         ax.YAxis(1).Color = 'k';
%         ax.YAxis(2).Color = 'k';
% 
% figure('Name','Scenario comparison metrics','units', 'normalized', 'outerposition', [0 0.05 0.5 0.6])
% 
% yyaxis left
%     bar(Disc.NPV, 'FaceColor', '#B3DCE7');
%     hold on
%     text(1:length(Disc.NPV),Disc.NPV,num2str(Disc.NPV'),'vert','bottom','horiz','center'); 
%     ylim([-40 80])
%     xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
%     xtickangle(45)
%     title('NPV values and CapEx','FontSize',10,'FontWeight', 'Bold')
%     ylabel('NPV [kEUR]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
%     set(gca,'TickLength',[0 0]);
%     hold off
% 
%         yyaxis right 
%         plot((1:4),Disc.Capex,'LineWidth',1, 'Color', '#545E75')
%         hold on
%         plot((1:4),Disc.Capex,'.','MarkerSize',15, 'color', '#0D3B66')
%         ylim([-400 800])
%         ylabel('CapEx [kEUR]','FontSize',10,'FontWeight', 'Bold')
%         ax = gca;
%         ax.YAxis(1).Color = 'k';
%         ax.YAxis(2).Color = 'k';

 figure('Name','Scenario comparison metrics','units', 'normalized', 'outerposition', [0 0.05 0.5 0.6])

    bar(Disc.IRR, 'FaceColor', '#B3DCE7');
    hold on
    text(1:length(Disc.IRR),Disc.IRR,num2str(Disc.IRR'),'vert','bottom','horiz','center');
    yline(7.8,'-','Discount rate','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    ylim([6 11])
    xticklabels({'AWE + UC','AWE + Batt','AWE + Batt arbitrage'})
    xtickangle(45)
    title('Internal rate of return compared to discount rate assumed','FontSize',10,'FontWeight', 'Bold')
    ylabel('IRR [%]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
    hold off

%% Sensitivity


% Sensitivity.Eff = [0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.9 ];
% Sensitivity.Bsize = [140 160 180 200 220];
% Sensitivity.BIRR = [7.09 9.68 9.76; 7.09 9.54 9.62;7.09 9.4 9.48; 7.09 9.26 9.34;7.09 9.12 9.2; 7.09 8.99 9.06; 7.09 8.85 8.93];
% Sensitivity.EffIRR = [9.7299 9.7332 9.7364 9.7396 9.742 9.7445 9.7469 9.7494 9.7518 9.7543 9.7568];
% Sensitivity.EFFE = [15.5354 15.7296 15.9238 16.1179 16.3121 16.5063 16.7005 16.8947 17.0889 17.2831 17.4773];
% Sensitivity.SizeE =[17.4773 22.7173 27.6479  32.3242 36.7328];
% Sensitivity.SizeIRR = [9.7568 9.6124 9.4628 9.3131 9.1641];


% figure('Name','Sensitivity','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);


% %     scatter(Sensitivity.Bprice,Sensitivity.BIRR(:,1),"filled",'LineWidth',1, 'Color', '#3F826D')
%     hold on
%     scatter(Sensitivity.Bprice,Sensitivity.BIRR(:,2),"filled",'LineWidth',1, 'Color', '#545E75')
%     scatter(Sensitivity.Bprice,Sensitivity.BIRR(:,3),"filled",'LineWidth',1, 'Color', '#C03221')
%     ylim([8.8 9.8 ])
%     xticks((130:15:220))
%     title('Sensitivity scenario 2 and 4 to battery price','FontSize',10,'FontWeight', 'Bold')
%     ylabel('IRR [%]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Battery price [EUR/kWh]','FontSize',10,'FontWeight', 'Bold')
%     legend('AWE + ultracapacitor', 'AWE + Battery', 'AWE + Battery arbitrage','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%     grid on


%     yyaxis left
%     scatter(Sensitivity.Eff,Sensitivity.EffIRR,"filled",'LineWidth',1, 'Color', '#3F826D')
%     hold on
% %     ylim([])
%     xticks((0.80:0.01:0.90))
%     title('Sensitivity scenario 4 to battery round-trip efficiency','FontSize',10,'FontWeight', 'Bold')
%     ylabel('IRR [%]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Battery efficiency [%]','FontSize',10,'FontWeight', 'Bold')
%     legend('IRR', 'E_{discharged}','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     grid on
% 
%     yyaxis right  
%      plot(Sensitivity.Eff,Sensitivity.EFFE,'LineWidth',1, 'Color', '#545E75')
%      ylim([14 20])
%     ylabel('Discharged battery energy [MWh]','FontSize',10,'FontWeight', 'Bold')
%     legend('IRR', 'E_{discharged}','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%      ax = gca;
%      ax.YAxis(1).Color = 'k';
%      ax.YAxis(2).Color = 'k';

%     yyaxis left
%     scatter(Sensitivity.Bsize,Sensitivity.SizeIRR,"filled",'LineWidth',1, 'Color', '#3F826D')
%     hold on
%     ylim([9 10])
%     xticks((140:20:220))
%     title('Sensitivity scenario 4 to battery round-trip efficiency','FontSize',10,'FontWeight', 'Bold')
%     ylabel('IRR [%]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Battery size [kWh]','FontSize',10,'FontWeight', 'Bold')
%     legend('IRR', 'E_{discharged}','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     grid on
% 
%     yyaxis right  
%      plot(Sensitivity.Bsize,Sensitivity.SizeE,'LineWidth',1, 'Color', '#545E75')
%      ylim([14 45])
%     ylabel('Discharged battery energy [MWh]','FontSize',10,'FontWeight', 'Bold')
%     legend('IRR', 'E_{discharged}','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')
%      ax = gca;
%      ax.YAxis(1).Color = 'k';
%      ax.YAxis(2).Color = 'k';



%% Misc


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

% BESS operation threshold system


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

% BESS operation AWE store to Batt


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

% BESS operation AWE store based on LCoE

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

% BESS arbitrage yearly mean

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

% Revenue and Profit

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


% Battery strategy

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

% Performance comparison

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


% BESS standalone


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



