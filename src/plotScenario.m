function plotScenario(Eres, Psm, SoC, Emax, C, DAM, Esm, f_repl, N_cycles)




figure('Name','AWE + Battery arbitrage excess energy','units', 'normalized', 'outerposition', [0.05 0.05 0.45 0.45]);

  % Energy capacity  

    hold on
    bar(1:length(Eres),(Eres+SoC)/1e3, 'FaceColor', '#564D80')
    bar(1:length(Eres),(Eres+0.1*Emax), 'FaceColor', '#DE8F6E')
    bar(1:length(Eres),ones(1,length(Eres))*0.1*Emax, 'FaceColor', '#FFFFFF')
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    yline(0.9*Emax,'-','90 %','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    yline(0.1*Emax,'-','10 %','LabelVerticalAlignment','bottom' ,'LabelHorizontalAlignment','left' );
    ylim([0 1.2*0.9*Emax])
    xlim([5950 5950+24*14])
    title('Energy use of battery capacity','FontSize',10,'FontWeight', 'Bold')
    legend('E_{batt}', 'E_{res}','Location','northeastoutside','FontSize',8,'NumColumns',2);
    legend('boxoff')
    ylabel('Energy [kWh]','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
    grid on
hold off

figure('Name','AWE + Battery arbitrage excess power','units', 'normalized', 'outerposition', [0.05 0.5 0.45 0.45]);

     % Excess Power 
    hold on
    bar(1:length(C),0.98*Psm+ abs(C), 'FaceColor', '#DE8F6E')
    bar(1:length(C),0.98*Psm, 'FaceColor', '#564D80')
    yline(Emax,'-','1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    ylim([0 1.2*Emax])
    xlim([5950 5950+24*14])
    title('Power use of battery power limit','FontSize',10,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    legend('P_{arb}', 'P_{sm}','Location','northeastoutside','FontSize',8,'NumColumns',2);
    legend('boxoff')
    set(gca,'TickLength',[0 0],'XTick',[], 'YTick', []);
hold off

figure('Name','AWE + Battery arbitrage DAM price','units', 'normalized', 'outerposition', [0.5 0.5 0.45 0.45]);

    plot(1:length(DAM),DAM,'LineWidth',1, 'Color', '#C59FC9')
    hold on
    xline(6018,':','LineWidth',2);
    xline(6070,':','LineWidth',2);
    xline(6186,':','LineWidth',2);
    xline(6215,':','LineWidth',2);
    ylim([15 75])
    xlim([5950 5950+24*14])
    xticks((5950+12)+(0:24:(336-12)))
    xticklabels({'M','T','W','T','F','S','S','M','T','W','T','F','S','S'})
    title('DAM price','FontSize',10,'FontWeight', 'Bold')
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Day in Week','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
hold off


figure('Name','Scanario 4 replacement shares','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);

ax = gca();
bar(ax,[  sum(Esm)/(Emax) 0 ;...
      sum(Esm)/(Emax) f_repl*N_cycles-sum(Esm)/(Emax)],'Stacked')
ax.Colormap = (1/255)*[119, 133, 172; 154, 198, 197;56,163,165];
title('Battery replacement cycle per application type','FontSize',10,'FontWeight', 'Bold')
ylim([0 1200])
ylabel('Full load cycles','FontSize',10,'FontWeight', 'Bold')
xticklabels({'AWE + Battery','AWE + Battery arbitrage'})
legend({'Power Smoothing', 'Arbitrage'},'Location','southoutside','Orientation','horizontal','NumColumns',2)
legend('boxoff')

end