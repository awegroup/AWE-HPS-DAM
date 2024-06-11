%% HPPModel
% An Economic Model for Hybrid Power Plants using Airborne Wind Energy
% Systems participating in the Day-Ahead Market

% Authors
% - Bart Zweers, 
%   Delft University of Technology


clc; clearvars; clear global  


%% Run AWE-Power

% addpath(genpath('C:\Users\bartz\Documents\GitHub\AWE-Power'));
% 
% addpath(genpath([pwd '\inputFiles']));
% % 
% % Load defined input sheet
% % inputSheet_MW_scale_EcoModel;
% inputSheet_Example_SE;
% % 
% [inputs, outputs, optimDetails, processedOutputs] = main_awePower(inputs);

%% Load inputs


inputs.DAM  = readtable('DAM_NL_2019.csv');
inputs.DAMp = inputs.DAM{:,"Var2"};                         %DAM price hourly in 2019 NL bidding zone

inputs.u              = ncread('NL_Wind.nc','u100');                        
inputs.v              = ncread('NL_Wind.nc','v100');                         
inputs.vw = sqrt(inputs.u(1,1,:).^2+inputs.v(1,1,:).^2);    % The wind speed is a combination of the u and v component of the downloaded data
inputs.vw = reshape(inputs.vw,[],1);                        % Reshaping of the 1x1xN matrix to make it a vector




%%% Wind %%%


% inputs.kite_Pcurve = processedOutputs.P_e_avg;
inputs.kite_Pcurve = [0 0 0 0 0 8046.66857954873 16932.2728296394 29384.8315403125 46054.5934352223 64370.7405480410 81587.7298520789 97468.2573001563 111918.053488753 124904.911490984 136464.749333433 146710.929309821 149999.999925450 149999.999925450 149999.999925450 149999.999925450 ];
Wind.Fit_ws     = linspace(0,25,26)';
WInd.Fit = fit(Wind.Fit_ws(6:17),inputs.kite_Pcurve(6:17),'poly5');


Kite.Power  = zeros(length(inputs.vw),1);                    % [W]
for i = 1:length(inputs.vw)
  for vw = 1:length(inputs.kite_Pcurve)

      if vw <= inputs.vw(i) && inputs.vw(i) < vw+1
          Kite.Power(i) = inputs.kite_Pcurve(vw); 
      
      end
  end
end








%%% Storage %%%

inputs.Li_p   = 0.182;    % [EUR/Wh] source: https://www.nrel.gov/docs/fy21osti/79236.pdf
inputs.Li_N = 1e4;



% Batterypower = Cyclepower - P_e_avg * ones(length(Cyclepower),1);
% Battery.Preq = max(abs(Batterypower));                                              %maximum required power for smoothing [kW]
% Battery.Ecyc = processedOutputs.P_m_avg(16) * processedOutputs.ti(16) /3.6e6 ;      %[kWh]
% Battery.Size = Battery.Preq;                                                      % Battery capacity size at 1C [kWh]
% Battery.lifetime = (Lition.Lifetimecycles/(Battery.Ecyc / Battery.Size))*(processedOutputs.tCycle(16)/3600);  % Battery lifetime [hrs]
% Battery.f_repl = (25*365*24)/Battery.lifetime;
% Battery.Cost = Battery.Size * Lition.p * Battery.f_repl *1e3;        % cost over project life [€]
% Ultracap.Cost = 11.25 * ultracap.p *1e3;


%%% SoC %%%

% Battery.Mismatch    = P_e - P_e_avg;
% 
% 
% Battery.Size        = 10^5;                % Wh
% Battery.Minimum     = 0.1*Battery.Size;
% Battery.Maximum     = Battery.Size;
% 
% Battery.StateofCharge       = ones(26280,1);    % Vector set-up
% Battery.StateofCharge(1,1)  = 1*Battery.Size;   % [Wh] Initial charge of the battery, doesn't matter
% for i = 1:26280
%     if Battery.StateofCharge(i)+Battery.Mismatch(i) <= Battery.Size 
%         if Battery.Mismatch(i) > 0 
%             Battery.StateofCharge(i+1) = Battery.StateofCharge(i)+Battery.Mismatch(i);
%         else 
%             Battery.StateofCharge(i+1) = Battery.StateofCharge(i)+Battery.Mismatch(i)/0.9;    % Addition of the roundtrip efficiency of 90%
%         end
%     else
%         if Battery.Mismatch(i) > 0
%             Battery.StateofCharge(i+1) = Battery.Size;
%         else 
%             Battery.StateofCharge(i+1) = Battery.Size+Battery.Mismatch(i)/0.9;
%         end       
%     end
% end

%%% Ultracap comparison %%%

% ultracap 11.25 kWh at 675 000 CAPEX

%%% Plots %%%

%     figure
%     hold on
%     grid on
%     box on
%     plot(1:length(Cyclepower),Cyclepower);
%     plot(1:length(Cyclepower),Batterypower);
%     yline(P_e_avg)
%     ylabel('(kW)');
%     %title('Cycle averages');
%     legend('P_{e}','P_{Bat}','location','northeast');
%     xlabel('Time (s)');
%     title('Cycle power at wind speed 16 (m/s)')
%     hold off


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




