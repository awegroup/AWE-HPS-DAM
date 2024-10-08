function plotAWEperf(Kite, Pcurve, vw, P_e, P_m, P_m_avg, t_cyc) 


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

figure('Name','AWE instantaneous reeling power','units', 'normalized', 'outerposition', [0.05 0.5 0.4 0.35]);


    hold on
    yline(0,'-k','LineWidth',0.5);
    plot(t_cyc,P_e,'LineWidth',1, 'color', 'k')

    yline(100,'--','LineWidth',1.5, 'color', '#40376E');
    text(t_cyc(7),100,'  P_{e, avg}','FontSize',10);
    
    plot([t_cyc(3) t_cyc(7)],[P_e(3) P_e(3)],'LineWidth',1.5, 'LineStyle',"--" ,'color', '#1F936C')
    plot(t_cyc(3),P_e(3),'.','MarkerSize',20,'color', '#1F936C')
    text(t_cyc(7),P_e(3),'  P_{e, o, peak}','FontSize',10);

    plot([t_cyc(5) t_cyc(7)],[P_e(5) P_e(5)],'LineWidth',1.5, 'LineStyle',"--" , 'color', '#DF7355')
    plot(t_cyc(5),P_e(5),'.','MarkerSize',20,'color', '#DF7355')
    text(t_cyc(7),P_e(5),'  P_{e, i, peak}','FontSize',10);

    title('Reeling power over one cycle at rated wind speed','FontSize',12,'FontWeight', 'Bold')
    xlim([0 t_cyc(7)])
    ylim([1.25*min(P_e) 1.1*max(P_e)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
hold off

E_o = (P_e(3)*(t_cyc(3)-t_cyc(2)) + 0.5*(P_e(2)-P_e(2))*(t_cyc(3)-t_cyc(2)) - t_cyc(3)*100)/3600;
E_i = (0.5*P_e(5)*(t_cyc(6)-t_cyc(4)) + (t_cyc(7)-t_cyc(4))*100)/3600;


figure('Name','AWE instantaneous reeling energy','units', 'normalized', 'outerposition', [0.5 0.5 0.4 0.5]);

    hold on
    plot(t_cyc,P_e,'LineWidth',1, 'LineStyle', '-', 'color', '#0D3B66')
    plot(t_cyc,P_m,'LineWidth',1.5, 'LineStyle', ':', 'color', '#8E4162')
    yline(100,'-.','LineWidth',1, 'color', '#40376E');
    yline(P_m_avg,'LineWidth',1.5, 'LineStyle', ':', 'color', '#40376E');
    
    shade(t_cyc(1:4),P_e(1:4),t_cyc(1:4),100*ones(1,length(P_m(1:4))),'FillType',[1 2],'FillColor',[31 147 108]/255);
    text(t_cyc(3)-45,P_e(3)-15,['E_{e, o} -  E_{e, avg} =  ' num2str(round(E_o,2)) '  kWh'],'FontSize',10);
    
    shade(t_cyc(3:7),P_e(3:7),t_cyc(3:7),100*ones(1,length(P_m(3:7))),'FillType',[2 1],'FillColor',[223 115 85]/255);
    text(t_cyc(4)+2,P_e(4)+60,' E_{e, i} +  E_{e, avg}','FontSize',10);
    text(t_cyc(4)+2,P_e(4)+40,'         = ','FontSize',10);
    text(t_cyc(4)+2,P_e(4)+25,['    ' num2str(round(E_i,2)) ' kWh'],'FontSize',10);

    plot(t_cyc,P_e,'LineWidth',1, 'LineStyle', '-', 'color', '#0D3B66')
    plot(t_cyc,P_m,'LineWidth',1.5, 'LineStyle', ':', 'color', '#8E4162')
    yline(100,'-.','LineWidth',1, 'color', '#40376E');
    yline(P_m_avg,'LineWidth',1.5, 'LineStyle', ':', 'color', '#40376E');

    title('Reeling mechanical and electrical power at 15 m/s','FontSize',12,'FontWeight', 'Bold')
    xlim([0 t_cyc(7)])
    ylim([1.1*min(P_e) 1.1*max(P_m)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
    legend('P_{e}', 'P_{m}','P_{e, avg}', 'P_{m, avg}','Location','southwest','Orientation','horizontal','NumColumns',2)
legend('boxoff')
hold off
hold off

E_m_o = (P_m(3)*(t_cyc(3)-t_cyc(2)) + 0.5*(P_m(2)-P_m(2))*(t_cyc(3)-t_cyc(2)) - t_cyc(3)*P_m_avg)/3600;
E_m_i = (0.5*abs(P_m(5))*(t_cyc(6)-t_cyc(4)) + (t_cyc(7)-t_cyc(4))*P_m_avg)/3600;

figure('Name','AWE instantaneous reeling mechanical energy','units', 'normalized', 'outerposition', [0.5 0.5 0.4 0.5]);

    hold on
    plot(t_cyc,P_e,'LineWidth',1, 'LineStyle', '-', 'color', '#0D3B66')
    plot(t_cyc,P_m,'LineWidth',1.5, 'LineStyle', ':', 'color', '#8E4162')
    yline(100,'-.','LineWidth',1, 'color', '#40376E');
    yline(P_m_avg,'LineWidth',1.5, 'LineStyle', ':', 'color', '#40376E');
    
    shade(t_cyc(1:4),P_m(1:4),t_cyc(1:4),P_m_avg*ones(1,length(P_m(1:4))),'FillType',[1 2],'FillColor',[31 147 108]/255);
    text(t_cyc(3)-40,P_m(3)-20,['E_{m, o} -  E_{m, avg} =  ' num2str(round(E_m_o,2)) '  kWh'],'FontSize',10);
    
    shade(t_cyc(3:7),P_m(3:7),t_cyc(3:7),P_m_avg*ones(1,length(P_m(3:7))),'FillType',[2 1],'FillColor',[223 115 85]/255);
    text(t_cyc(4)+1,P_m(4)+60,' E_{m, i} +  E_{m, avg}','FontSize',10);
    text(t_cyc(4)+2,P_e(4)+50,'         = ','FontSize',10);
    text(t_cyc(4)+2,P_e(4)+30,['    ' num2str(round(E_m_i,2)) ' kWh'],'FontSize',10);

    plot(t_cyc,P_e,'LineWidth',1, 'LineStyle', '-', 'color', '#0D3B66')
    plot(t_cyc,P_m,'LineWidth',1.5, 'LineStyle', ':', 'color', '#8E4162')
    yline(100,'-.','LineWidth',1, 'color', '#40376E');
    yline(P_m_avg,'LineWidth',1.5, 'LineStyle', ':', 'color', '#40376E');

    title('Reeling energy over one cycle at rated wind speed','FontSize',12,'FontWeight', 'Bold')
    xlim([0 t_cyc(7)])
    ylim([1.1*min(P_e) 1.1*max(P_m)])
    ylabel('Power [kW]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Time withing cycle (s)','FontSize',10,'FontWeight', 'Bold')
    legend('P_{e}', 'P_{m}','P_{e, avg}', 'P_{m, avg}','Location','southwest','Orientation','horizontal','NumColumns',2)
legend('boxoff')
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