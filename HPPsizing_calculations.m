%%%% Hybrid Power Plant AWE battery sizing

  
% function [LCoE] = HPPsizing_calculations(System_batterysize)



%%% Wind %%%
t= 1:70;
t_e = [0,1.810000000000000,44.330000000000000,46.140000000000000,50.050000000000000,65.710000000000000,69.619999999999990];
P_e = 1e+03*[0,2.428970964577018e+02,2.290939273456894e+02,0,-25.349195951730202,-0.100058932577477,0];
P_e_avg = 149999.999284048*ones(70,1);

Cyclepower  = zeros(70,1);                    % [W]
for i = 1:70
    if  i <= t_e(2)
        Cyclepower(i) = P_e(2);
    elseif t_e(2) <= i && i <= t_e(3)
        Cyclepower(i) = P_e(3);
    elseif t_e(3) <= i && i <= t_e(4)
        Cyclepower(i) = P_e(4);
    elseif t_e(4) <= i && i <= t_e(5)
        Cyclepower(i) = P_e(5);
    elseif t_e(5) <= i && i <= t_e(6)
        Cyclepower(i) = P_e(6);
    else
        Cyclepower(i) = 0;
    end
end


%%% Storage %%%
Lition.BatteryPrice   = 0.182;    % [EUR/Wh] source: https://www.nrel.gov/docs/fy21osti/79236.pdf
Lition.Lifetimecycles = 10^4;
Lition.susPower  = 10;             %W/Wh

Natron.Lifetimecycles = 10^5;
Natron.susPower  = 40;             %W/Wh


%%% SoC %%%

Battery.Mismatch    = Cyclepower - P_e_avg;


Battery.Size        = 10^5;                % Wh
Battery.Minimum     = 0.1*Battery.Size;
Battery.Maximum     = Battery.Size;

Battery.StateofCharge       = ones(70,1);           % Vector set-up
Battery.StateofCharge(1,1)  = 0.5*Battery.Size;     % [Wh] Initial charge of the battery, doesn't matter
for i = 1:70
    if Battery.StateofCharge(i)+Battery.Mismatch(i) <= Battery.Size 
        if Battery.Mismatch(i) > 0 
            Battery.StateofCharge(i+1) = Battery.StateofCharge(i)+Battery.Mismatch(i);
        else 
            Battery.StateofCharge(i+1) = Battery.StateofCharge(i)+Battery.Mismatch(i)/0.9;    % Addition of the roundtrip efficiency of 90%
        end
    else
        if Battery.Mismatch(i) > 0
            Battery.StateofCharge(i+1) = Battery.Size;
        else 
            Battery.StateofCharge(i+1) = Battery.Size+Battery.Mismatch(i)/0.9;
        end       
    end
end

%%% Plots %%%

    figure(1)                   % Cycle power

    plot(t, Cyclepower,'LineWidth',1.5, 'color', '#4EA5D9')
    yline(P_e_avg,"--")
%     plot(t, Battery.Mismatch,'LineWidth',1.5, 'color', '#000000')
    hold on
    legend('P_{e}','P_{e, avg}', 'P_{bat}','Location','northeast','FontSize',14,'NumColumns',1); 
    title('Cyclepower at rated wind speed of 16 {m/s}','FontSize',14,'FontWeight', 'Bold')
    xlim([0 71])
    ylim([min(Cyclepower)*1.1 max(Cyclepower)*1.1])
    xlabel('Cycle time [{s}]');
    ylabel('Power [kW]','FontSize',12,'FontWeight', 'Bold')
    legend('boxoff')
hold off


