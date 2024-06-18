%% HPPModel
% An Economic Model for Hybrid Power Plants using Airborne Wind Energy
% Systems participating in the Day-Ahead Market

% Authors
% - Bart Zweers, 
%   Delft University of Technology


clc; clearvars; clear global  


%% Run AWE-Power

% addpath(genpath('C:\Users\bartz\Documents\GitHub\AWE-Power'));
% % 
% addpath(genpath([pwd '\inputFiles']));
% % % 
% % Load defined input sheet
% % % inputSheet_MW_scale_EcoModel;
% inputSheet_Example_SE;
% % 
% [inputs, outputs, optimDetails, processedOutputs] = main_awePower(inputs);

%% Load inputs


inputs.DAM  = readtable('DAM_NL_2019.csv');
inputs.DAMp = inputs.DAM{:,"Var2"};                         %DAM price hourly in 2019 NL bidding zone
inputs.DAMp(8761) = [];

inputs.u              = ncread('NL_Wind.nc','u100');                        
inputs.v              = ncread('NL_Wind.nc','v100');                         
inputs.vw = sqrt(inputs.u(1,1,:).^2+inputs.v(1,1,:).^2);    % The wind speed is a combination of the u and v component of the downloaded data
inputs.vw = reshape(inputs.vw,[],1);                        % Reshaping of the 1x1xN matrix to make it a vector

%% Wind 

% inputs.kite_Pcurve = processedOutputs.P_e_avg;
inputs.kite_Pcurve = [0 0 0 0 0 8046.66857954873 16932.2728296394 29384.8315403125 46054.5934352223 64370.7405480410 81587.7298520789 97468.2573001563 111918.053488753 124904.911490984 136464.749333433 146710.929309821 149999.999925450 149999.999925450 149999.999925450 149999.999925450 ]';


Kite.Power  = zeros(length(inputs.vw),1);                    % [W]
for i = 1:length(inputs.vw)
  for vw = 1:length(inputs.kite_Pcurve)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1
          Kite.Power(i) = inputs.kite_Pcurve(vw); 
      
      end
  end
end

%% Storage

inputs.BatLCoE  = 20;
inputs.kiteLCoE = 45;

inputs.Li_p   = 0.182;    % [EUR/Wh] source: https://www.nrel.gov/docs/fy21osti/79236.pdf
inputs.Li_N = 1e4;

inputs.storageExchange =  [0 0 0 0 0 0.0262 0.0641 0.1204 0.2001 0.3310 0.4931 0.6741 0.8660 1.0602 1.2380 1.4202 1.4458 1.4506 1.4556 1.4612]; %kWh
inputs.tCycle =            [0 0 0 0 0 66.9837 65.5588 63.2927 60.8813 62.6543 65.9170 68.8238 71.2074 72.9443 73.0063 73.0476 71.7191 71.4678 71.3103 71.2244];
inputs.cycleStorage = (inputs.storageExchange./inputs.tCycle)*3600;      % kWh/hr

inputs.P_e_inst = [0 251.305662934870 233.737759894221 0 -32.8083782343388 -0.0125921644086288 0];
Battery.Preq = max(abs(inputs.P_e_inst-max(inputs.kite_Pcurve/1e3)))*1e3;                         %1C charge limit battery power [W]


%% SoC 


Battery.Size        = 200e3;                % Wh
Battery.Minimum     = 0.1*Battery.Size;
Battery.Maximum     = 0.9*Battery.Size;
Battery.Eff         = 0.9;                  %Round trip efficiency

Battery.Smoothing = ones(8760,1);       % set-up

for i = 1:length(inputs.vw)                         % Smoothing intermediate storage needed per hour [Wh]
  for vw = 1:length(inputs.storageExchange)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1

          Battery.Smoothing(i) = inputs.storageExchange(vw)*1e3;
          Battery.DoD(i) =  Battery.Smoothing(i)/(inputs.tCycle(vw)/3600);
      
      end
  end
end


Battery.SoC       = ones(8760,1);       % set-up
Battery.SoC(1,1)  = 0.5*Battery.Size;   % [Wh] Initial charge of the battery

for i = 1:length(inputs.DAMp)           % Battery SoC [Wh] roundtrip efficiency taken into account at discharge

    if      inputs.DAMp(i) < inputs.kiteLCoE &&...
            Battery.SoC(i)+Kite.Power(i) < Battery.Maximum - Battery.Smoothing(i)

            Battery.SoC(i+1) = Battery.SoC(i)+Kite.Power(i);
    
    elseif  inputs.DAMp(i) >= inputs.kiteLCoE + inputs.BatLCoE &&...
            Battery.SoC(i) > Battery.Minimum + Battery.Smoothing(i)
            
            Battery.SoC(i+1) = Battery.SoC(i) - min(Battery.Size*Battery.Eff, Battery.SoC(i) - (Battery.Minimum + Battery.Smoothing(i))) ;
    else 
            Battery.SoC(i+1) = Battery.SoC(i);
         
    end
end


Battery.Charge = diff(Battery.SoC)/1e3;     % Battery charge [+]/discharge [-] [kW]

Grid.Battery = abs(min(Battery.Charge*1e3,0));
Revenue.Battery = inputs.DAMp.* abs(min(Battery.Charge*1e3,0));
Grid.Kite = Kite.Power - max(Battery.Charge,0);
Revenue.Kite = inputs.DAMp.*(Kite.Power - max(Battery.Charge,0));

Battery.DoD(isnan(Battery.DoD))=0;
Battery.f_repl = ((sum(abs(Battery.Charge)*1e3) + sum(Battery.DoD))/Battery.Size)/inputs.Li_N;  % frequency of replacement Battery system [/year]



%% Cost

Cost.r                  = 0.05;     % Discount rate



%% Plots


figure(1)                   % DAM NL 2019

    plot(1:length(inputs.DAMp),inputs.DAMp,'LineWidth',0.25, 'color', '#87B6A7')
    hold on 
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Day-Ahead price NL bidding zone 2019','FontSize',14,'FontWeight', 'Bold')
    xlim([0 length(inputs.DAMp)])
    ylim(1.1*[min(inputs.DAMp) max(inputs.DAMp)])
    ylabel('Price [EUR/MWh]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure(2)                   % Kite power 2019

    plot(1:length(Kite.Power),Kite.Power/1e3,'LineWidth',0.25, 'color', '#62929E')
    hold on 
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('AWE kite power output','FontSize',14,'FontWeight', 'Bold')
    xlim([0 length(Kite.Power/1e3)])
    ylim(1.1*[min(Kite.Power/1e3) max(Kite.Power/1e3)])
    ylabel('Power [kW]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure(3)                   % Wind speed 2019

    plot(1:length(inputs.vw),inputs.vw,'LineWidth',0.25, 'color', '#478978')
    hold on 
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Wind speed at 100m','FontSize',14,'FontWeight', 'Bold')
    xlim([0 length(inputs.vw)])
    ylim(1.1*[min(inputs.vw) max(inputs.vw)])
    ylabel('Wind speed at 100 m [m/s]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure(4)                   % SoC

    plot(1:length(Battery.SoC),100*(Battery.SoC/Battery.Size),'LineWidth',0.25, 'color', '#C94277')
    hold on 
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Battery State of Charge','FontSize',14,'FontWeight', 'Bold')
    ylim([0 100])
    xlim([0 length(Battery.SoC)])
    ylabel('Battery State of Charge [%]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure(5)                   % Battery charge/discharge power

    plot(1:length(Battery.Charge),Battery.Charge,'LineWidth',0.25, 'color', '#50B2C0')
%     plot(1:length(Battery.Smoothing),Battery.Smoothing,'LineWidth',0.25, 'color', '#FAAA8D')
    yline(Battery.Size/1e3,'-','1 C');
    yline(Battery.Size/2e3,'-','0.5 C');
    hold on 
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Battery Charge/Discharge','FontSize',14,'FontWeight', 'Bold')
    ylim(1.1*[min(Battery.Charge) max(Battery.Charge)])
    xlim([0 length(Battery.SoC)])
    ylabel('Battery Charge/Discharge [kW]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure(6)                   % Grid

    plot(1:length(Revenue.Battery),Revenue.Battery/1e6,'LineWidth',0.25, 'color', '#50B2C0')
    hold on 
    plot(1:length(Revenue.Kite),Revenue.Kite/1e6,'LineWidth',0.25, 'color', '#FAAA8D')
    legend('R_{Battery}','R_{Kite}','Location','northwest','FontSize',14,'NumColumns',2);
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Day Ahead Market Revenue','FontSize',14,'FontWeight', 'Bold')
    xlim([0 length(Grid.Battery)])
    ylabel('Revenue [EUR]','FontSize',12,'FontWeight', 'Bold')
    xtickangle(45)
    legend('boxoff')
hold off





