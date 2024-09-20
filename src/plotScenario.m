function plotScenario(hrs,inputs, Scen1, Scen, E_stor_max, N)


figure('Name','AWE + Battery arbitrage excess energy','units', 'normalized', 'outerposition', [0.05 0.05 0.45 0.45]);

  % Energy capacity  

    hold on
    bar(1:length(Scen1.E_res),(Scen1.E_res+Scen.SoC), 'FaceColor', '#564D80')
    bar(1:length(Scen1.E_res),(Scen1.E_res+0.1*E_stor_max), 'FaceColor', '#DE8F6E')
    bar(1:length(Scen1.E_res),ones(1,length(Scen1.E_res))*0.1*E_stor_max, 'FaceColor', '#FFFFFF')
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    yline(0.9*E_stor_max,'-','90 %','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    yline(0.1*E_stor_max,'-','10 %','LabelVerticalAlignment','bottom' ,'LabelHorizontalAlignment','left' );
    ylim([0 1.2*0.9*E_stor_max])
    xlim([hrs hrs+24*14])
    title('Energy use of battery capacity','FontSize',10,'FontWeight', 'Bold')
    legend('E_{batt}', 'E_{res}','Location','northeast','FontSize',8,'NumColumns',2);
    legend('boxoff')
    ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
    grid on
hold off

figure('Name','AWE + Battery arbitrage excess power','units', 'normalized', 'outerposition', [0.05 0.5 0.45 0.45]);

     % Excess Power 
    hold on
    bar(1:length(Scen.P),0.98*Scen1.P_sm+ abs(Scen.P), 'FaceColor', '#DE8F6E')
    bar(1:length(Scen.P),0.98*Scen1.P_sm, 'FaceColor', '#564D80')
    yline(E_stor_max,'-','1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    ylim([0 1.2*E_stor_max])
    xlim([hrs hrs+24*14])
    title('Power use of battery power limit','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    legend('P_{arb}', 'P_{sm}','Location','northeast','FontSize',8,'NumColumns',2);
    legend('boxoff')
    set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
hold off

figure('Name','AWE + Battery arbitrage DAM price','units', 'normalized', 'outerposition', [0.5 0.5 0.45 0.45]);

    plot(1:length(inputs.DAM),inputs.DAM,'LineWidth',1, 'Color', '#C59FC9')
    hold on
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    ylim([15 75])
    xlim([hrs hrs+24*14])
    xticks((hrs+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('DAM price','FontSize',10,'FontWeight', 'Bold')
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
hold off


figure('Name','Scanario 4 replacement shares','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);

ax = gca();
bar(ax,[  sum(Scen1.E_sm)/(E_stor_max) 0 ;...
      sum(Scen1.E_sm)/(E_stor_max) Scen.f_repl*N-sum(Scen1.E_sm)/(E_stor_max)],'Stacked')
ax.Colormap = (1/255)*[119, 133, 172; 154, 198, 197;56,163,165];
title('Battery replacement cycle per application type','FontSize',10,'FontWeight', 'Bold')
ylim([0 1200])
ylabel('Full load cycles','FontSize',10,'FontWeight', 'Bold')
xticklabels({'AWE + Battery','AWE + Battery arbitrage'})
legend({'Power Smoothing', 'Arbitrage'},'Location','southoutside','Orientation','horizontal','NumColumns',2)
legend('boxoff')

end