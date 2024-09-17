function plotAWEperf(Kite, Pcurve, vw, P_e) 


figure('Name','Powercurve AWE system','units', 'normalized', 'outerposition', [0.05 0.05 0.4 0.5]);


Pcurve(22:25) = zeros(1,4);

plot(1:length(Pcurve),Pcurve/1e3,'LineWidth',1.5, 'color', '#0D3B66')
    hold on
plot(1:length(Pcurve),Pcurve/1e3,'.','MarkerSize',15, 'color', '#0D3B66')
    title('AWE Power curve 100 kW system','FontSize',10,'FontWeight', 'Bold')
    xlim([0 25])
    ylim([0 1.4*max(Pcurve)/1e3])
    ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
    xlabel('Wind speed at 100 m (m/s)','FontSize',8,'FontWeight', 'Bold')
grid on
hold off

figure('Name','AWE power output timeseries','units', 'normalized', 'outerposition', [0.5 0.05 0.4 0.5]);

bar(1:length(Kite),Kite, 'FaceColor', '#355070')
    box off
    set(gca,'xtick',round(linspace(365,8760-365,12)),'xticklabel',...
        {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
        'Aug','Sep','Oct','Nov','Dec'})
    title('AWE power output hourly over full year ','FontSize',10,'FontWeight', 'Bold')
    xlim([0 length(vw)])
    ylim([0 1.1*max(Kite)])
    ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
    xtickangle(45)
hold off

figure('Name','AWE instantaneous relling power','units', 'normalized', 'outerposition', [0.05 0.5 0.4 0.5]);


    hold on
    yline(0,'-k','LineWidth',0.5);
    plot([0 1 43 45 51 65 66.7],P_e,'LineWidth',1, 'color', 'k')

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
    ylim([1.3*min(P_e) 1.3*max(P_e)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
hold off



figure('Name','AWE instantaneous relling energy','units', 'normalized', 'outerposition', [0.5 0.5 0.4 0.5]);

    hold on
    
    
    area([0 1 43] ,P_e(1:3), 'FaceColor', '#1F936C')
    area([43 43.5424] ,[137.209 100], 'FaceColor', '#1F936C')
    area([0.1 43.5424] ,[100 100], 'FaceColor', '#FFFFFF')
    text(43,120,'  \leftarrow  E_{e, o} -  E_{e, avg}','FontSize',10);

    area([45 51 65 66.7] ,P_e(4:7), 'FaceColor', '#DF7355')
    area([45 51 65] ,[100 100 100], 'FaceColor', '#DF7355')
    area([43.5424 45] ,[100 100], 'FaceColor', '#DF7355')
    area([43.5424 45] ,[100 0], 'FaceColor', '#FFFFFF')
    text(43,40,'  E_{e, i} +  E_{e, avg} \rightarrow','FontSize',10,'HorizontalAlignment','right');
    yline(0,'-k','LineWidth',0.5);


    yline(100,'--','LineWidth',2.5, 'color', '#40376E');
    text(66.7,100,'  P_{e, avg}','FontSize',10);

    title('Reeling energy over one cycle at rated wind speed','FontSize',12,'FontWeight', 'Bold')
    xlim([0 66.7])
    ylim([1.3*min(P_e) 1.3*max(P_e)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
hold off

figure('Name','Kite power sorted','units', 'normalized', 'outerposition', [0.5 0.5 0.2 0.2])

Sort = sort(Kite);

plot(1:length(Sort),Sort,'LineWidth',1.5, 'color', '#0D3B66')
    xlim([0 length(Sort)])
    ylim([0 1.4*max(Sort)])
    xlabel('Hours of year','FontSize',8,'FontWeight', 'Bold')
    ylabel('Power [kW]','FontSize',8,'FontWeight', 'Bold')
    title('AWE power output sorted in ascending order','FontSize',10,'FontWeight', 'Bold')
    xticks(365+730*(0:1:12))
    xticklabels({'365','1095','1825','2555','3285','4015','4745','5475','6205','6935','7665','8395'})


end