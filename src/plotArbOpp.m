function plotArbOpp(inputs, Scen1,Scen2, Scen3, Scen4) 

% Battery

figure('Name','Arbitrage operational strategy','units', 'normalized', 'outerposition', [0.05 0.05 0.45 0.45]);

  % Arbitrage model

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
    xlabel('time (hrs)','FontSize',10,'FontWeight', 'Bold')

hold off

figure('Name','Storage arbitrage window operation','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])

  subplot(2,1,1);
                      % DAM  2019

    plot(1:length(inputs.DAM),inputs.DAM,'LineWidth',1.5, 'color', '#DFB4BE')
    title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
    xlim([5898 5898+24])
    ylim([20 60])
    set(gca,'TickLength',[0 0],'XTick',[]);
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
    legend('DAM price','Location','northeast','FontSize',8,'NumColumns',1);
    legend('boxoff')


    subplot(2,1,2);                   % Battery charge/discharge power

    bar(1:length(Scen3.P),abs(min(Scen3.P,0)), 'FaceColor', '#DE8F6E')
    hold on
    bar(1:length(Scen3.P),abs(max(Scen3.P,0)), 'FaceColor', '#88AB75')
%     yline(BESS.Size/1e3,'-','1 C');
%     yline(BESS.Size/2e3,'-','0.5 C');
%     yline(-BESS.Size/1e3,'-','-1 C');
%     yline(-BESS.Size/2e3,'-','-0.5 C');
    ylim([0 1.6*max(Scen3.P)])
    xlim([5898 5898+24])
    xticks((5898)+(2:2:24))
    xticklabels({'1hr','2hrs','3hrs','4hrs','5hrs','6hrs','7hrs','8hrs','9hrs','10hrs','11hrs','12hrs'})
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time ','FontSize',10,'FontWeight', 'Bold')
%     title('Battery arbitrage charging behavior in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    legend('Discharge to Grid', 'Charge from Grid','Location','north','FontSize',8,'NumColumns',2);
    legend('boxoff')
    hold off

figure('Name','Storage arbitrage behavior','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])

  subplot(2,1,1);
                      % DAM  2019

    plot(1:length(inputs.DAM),inputs.DAM,'LineWidth',1, 'color', '#DFB4BE')
    title('Battery arbitrage charging behavior','FontSize',10,'FontWeight', 'Bold')
    xlim([5898 5898+2*24])
    ylim([20 60])
    set(gca,'TickLength',[0 0],'XTick',[]);
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
%     xlabel('Hours in Week','FontSize',10,'FontWeight', 'Bold')
    legend('DAM price','Location','northeast','FontSize',8,'NumColumns',1);
    legend('boxoff')


    subplot(2,1,2);                   % Battery charge/discharge power

    bar(1:length(Scen3.P),abs(min(Scen3.P,0)), 'FaceColor', '#DE8F6E')
    hold on
    bar(1:length(Scen3.P),abs(max(Scen3.P,0)), 'FaceColor', '#88AB75')
%     yline(BESS.Size/1e3,'-','1 C');
%     yline(BESS.Size/2e3,'-','0.5 C');
%     yline(-BESS.Size/1e3,'-','-1 C');
%     yline(-BESS.Size/2e3,'-','-0.5 C');
    ylim([0 1.6*max(Scen3.P)])
    xlim([5898 5898+2*24])
    xticks((5898)+(10:8:2*24))
    xticklabels({'w','2w','3w','4w','5w','6w','7w','8w','9w','10w','11w','12w'})
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Arbitrage window within one day','FontSize',10,'FontWeight', 'Bold')
%     title('Battery arbitrage charging behavior in two summer weeks','FontSize',10,'FontWeight', 'Bold')
    legend('Discharge to Grid', 'Charge from Grid','Location','north','FontSize',8,'NumColumns',2);
    legend('boxoff')
    hold off


   figure('Name','Storage arbitrage combined smoothing','units', 'normalized', 'outerposition', [0.5 0.05 0.5 0.6])
  

    subplot(2,1,1);
 
                      % DAM  2019

    plot(1:length(inputs.DAM),inputs.DAM,'LineWidth',0.2, 'color', '#DFB4BE')
    title('Bidding operation AWE smoothing and arbitrage over one week','FontSize',10,'FontWeight', 'Bold')
    xlim([2600 2600+24*7])
    ylim([0 70])
    set(gca,'TickLength',[0 0],'XTick',[]);
    ylabel('Price [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    legend('DAM price','Location','northeast','FontSize',8,'NumColumns',1);
    legend('boxoff')


                      % SoC
    plot(1:length(inputs.DAM),(Scen4.SoC/Scen2.E_batt_req)*100,'LineWidth',1.5, 'color', '#DFB4BE')
    title('Bidding operation AWE smoothing and arbitrage over one week','FontSize',10,'FontWeight', 'Bold')
    xlim([2600 2600+24*7])
    ylim([0 100])
    set(gca,'TickLength',[0 0],'XTick',[]);
    ylabel('SoC [%]','FontSize',10,'FontWeight', 'Bold')
%     legend('State of Charge','Location','northeastoutside','FontSize',8,'NumColumns',1);
%     legend('boxoff')


   subplot(2,1,2);                   % Battery power types
 
    hold on
    bar(1:length(Scen4.P),0.98*Scen1.P_sm+ abs(max(Scen4.P,0)), 'FaceColor', '#88AB75')
    bar(1:length(Scen4.P),0.98*Scen1.P_sm+ abs(min(Scen4.P,0)), 'FaceColor', '#DE8F6E')
    bar(1:length(Scen1.P),0.98*Scen1.P_sm, 'FaceColor', '#564D80')
    yline(Scen2.E_batt_req,'-','    1 C','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    ylim([0 1.4*Scen2.E_batt_req])
    xlim([2600 2600+24*7])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    legend('Charged from grid','Discharged to grid', 'Smoothing Power','Location','north','FontSize',8,'NumColumns',3);
    legend('boxoff')
    xticks((2600)+(12:24:24*7))
    xticklabels({'M','T','W','T','F','S','S'})
hold off

end