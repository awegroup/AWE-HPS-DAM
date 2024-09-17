function plotScenParam(DAM, vw) 


figure('Name','DAM hourly timeseries','units', 'normalized', 'outerposition', [0.05 0.3 0.4 0.5]);


    plot(1:length(DAM), DAM,'LineWidth',0.25, 'color', '#87B6A7')
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Market clearing price NL DAM bidding zone over 2019','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(DAM)])
    ylim([-10 125])
    ylabel('Price [EUR/MWh]','FontSize',8,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure('Name','Wind speed hourly timeseries','units', 'normalized', 'outerposition', [0.5 0.3 0.4 0.5]);

plot(1:length(vw),vw,'LineWidth',1, 'color', '#7284A8')
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('Wind speed at 100m at Haringvliet over 2019','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(vw)])
    ylim([0 1.1*max(vw)])
    ylabel('Wind speed at 100 m [m/s]','FontSize',8,'FontWeight', 'Bold')
    xtickangle(45)
hold off


end