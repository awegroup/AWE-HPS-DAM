function plotStorperf( Scen1, Scen2, Scen4) 

% Battery

figure('Name','Battery performance excess energy','units', 'normalized', 'outerposition', [0.05 0.05 0.45 0.45]);


                % Excess Energy         
    bar(1:length(Scen1.E_res),(Scen1.E_res+0.1*Scen2.E_batt_req), 'FaceColor', '#B2675E')
    hold on
    area(1:length(Scen1.E_res),ones(1,length(Scen1.E_res))*0.1*Scen2.E_batt_req, 'FaceColor', '#FFFFFF')
    yline(0.2*Scen2.E_batt_req,'-','20 %','FontSize',10);
    yline(0.1*Scen2.E_batt_req,'-','10 %','LabelVerticalAlignment','bottom','FontSize',10 );
    ylim([10 1.1*0.2*Scen2.E_batt_req])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('Battery smoothing energy reserved capacity E_{res}','FontSize',10,'FontWeight', 'Bold')
    ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')

figure('Name','Battery performance excess power','units', 'normalized', 'outerposition', [0.05 0.5 0.45 0.45]);

    bar(1:length(Scen1.P),0.98*Scen1.P_sm, 'FaceColor', '#B2675E')
    hold on
    yline(Scen2.E_batt_req,'-','1 C');
    ylim([0 1.2*Scen2.E_batt_req])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('Battery smoothing power reserved capacity P_{sm}','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')

% UC

figure('Name','UC performance excess energy','units', 'normalized', 'outerposition', [0.5 0.05 0.45 0.45]);

% subplot(1,2,1);                 % Excess Energy         
    bar(1:length(Scen1.E_res),Scen1.E_res+0.1*Scen1.E_UC_req, 'FaceColor', '#564D80')
    hold on
    area(1:length(Scen1.E_res),ones(1,length(Scen1.E_res))*0.1*Scen1.E_UC_req, 'FaceColor', '#FFFFFF')
    yline(1.1*Scen1.E_UC_req,'-','100 %','FontSize',10);
    yline(0.1*Scen1.E_UC_req,'-','0 %','LabelVerticalAlignment','bottom','FontSize',10 );
    ylim([0 1.2*Scen1.E_UC_req])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('UC smoothing energy reserved capacity E_{res}','FontSize',10,'FontWeight', 'Bold')
    ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')

figure('Name','UC performance excess power','units', 'normalized', 'outerposition', [0.5 0.5 0.45 0.45]);

    bar(1:length(Scen1.P_sm),0.98*Scen1.P_sm, 'FaceColor', '#564D80')
    hold on
    yline(Scen1.E_UC_req*150,'-','150 C');
    ylim([0 200*Scen1.E_UC_req])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('UC smoothing Power reserved capacity P_{sm}','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')



figure('Name','Battery power levels during operation','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);


                   % Arbitrage operation

    bar(1:length(Scen1.P),Scen1.P_sm, 'FaceColor', '#B3DCE7')
    hold on
    bar(1:length(Scen4.P),max(Scen4.P,0), 'FaceColor', '#DE8F6E')
    bar(1:length(Scen4.P),abs(min(Scen4.P,0)), 'FaceColor', '#88AB75')
    ylim([0 1.3*abs(max(Scen4.P))])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('Battery power charging levels','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
    legend('P_{sm}','P_{cha}','P_{dis}','Location','northeast','FontSize',8,'NumColumns',3);
    legend('boxoff')
    set(gca,'TickLength',[0 0]);
    hold off




end