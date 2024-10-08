function plotDiscuss(inputs, Scenario1, Scenario2, Scenario3, Scenario4) 



Disc.LCoE = round([Scenario1.LCoE Scenario2.LCoE Scenario3.LCoE Scenario4.LCoE]);
Disc.E = [Scenario1.AEP Scenario1.AEP Scenario3.arb_E Scenario1.AEP+Scenario4.arb_E];
Disc.IRR = round([Scenario1.IRR Scenario2.IRR Scenario4.IRR]*1e2,2);
Disc.NPV = round([Scenario1.NPV Scenario2.NPV Scenario3.NPV Scenario4.NPV]/1e3);
Disc.CapEx = [Scenario1.CapEx Scenario2.CapEx Scenario3.CapEx Scenario4.CapEx]/1e3;
Disc.NPVcap = round([Scenario1.NPV/Scenario1.CapEx Scenario2.NPV/Scenario2.CapEx Scenario3.NPV/Scenario3.CapEx Scenario4.NPV/Scenario4.CapEx],2);
Disc.reply = [1/inputs.N_UC_years 1/inputs.N_li_years 1/inputs.N_li_years 1/inputs.N_li_years];
Disc.replc=  [sum(Scenario1.E_sm)/(Scenario1.E_UC_req*inputs.N_UC_cycles) sum(Scenario1.E_sm)/(Scenario2.E_batt_req*inputs.N_li_cycles)...
               sum(abs(Scenario3.P))/(Scenario2.E_batt_req*inputs.N_li_cycles) (sum(abs(Scenario4.P)) + sum(Scenario1.E_sm))/(Scenario2.E_batt_req*inputs.N_li_cycles) ];
Disc.Payb = [Scenario1.Payb Scenario2.Payb 25 Scenario4.Payb];


figure('Name','LCoE comparison','units', 'normalized', 'outerposition', [0.05 0.05 0.45 0.45])

yyaxis left
    bar(Disc.LCoE, 'FaceColor', '#B3DCE7');
    hold on
    text(1:length(Disc.LCoE),Disc.LCoE,num2str(Disc.LCoE'),'vert','bottom','horiz','center'); 
    ylim([100 150])
    xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
    xtickangle(45)
    title('LCoE values levelized over energy discharged to grid','FontSize',10,'FontWeight', 'Bold')
    ylabel('LCoE [EUR/MWh]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
    hold off

        yyaxis right 
        plot((1:4),Disc.E,'LineWidth',1, 'Color', '#545E75')
        hold on
        plot((1:4),Disc.E,'.','MarkerSize',15, 'color', '#0D3B66')
        ylim([0 650])
        ylabel('Energy discharged to grid [MWh]','FontSize',10,'FontWeight', 'Bold')
        ax = gca;
        ax.YAxis(1).Color = 'k';
        ax.YAxis(2).Color = 'k';

figure('Name','NPV comparison metrics','units', 'normalized', 'outerposition', [0.05 0.5 0.45 0.45])

yyaxis left
    bar(Disc.NPV, 'FaceColor', '#B3DCE7');
    hold on
    text(1:length(Disc.NPV),Disc.NPV,num2str(Disc.NPV'),'vert','bottom','horiz','center'); 
    ylim([-40 220])
    xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
    xtickangle(45)
    title('NPV values and CapEx','FontSize',10,'FontWeight', 'Bold')
    ylabel('NPV [kEUR]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
    hold off

        yyaxis right 
        plot((1:4),Disc.CapEx,'LineWidth',1, 'Color', '#545E75')
        hold on
        plot((1:4),Disc.CapEx,'.','MarkerSize',15, 'color', '#0D3B66')
        ylim([-400 800])
        ylabel('CapEx [kEUR]','FontSize',10,'FontWeight', 'Bold')
        ax = gca;
        ax.YAxis(1).Color = 'k';
        ax.YAxis(2).Color = 'k';

 figure('Name','IRR comparison','units', 'normalized', 'outerposition', [0.5 0.05 0.45 0.45])

    bar(Disc.IRR, 'FaceColor', '#B3DCE7');
    hold on
    text(1:length(Disc.IRR),Disc.IRR,num2str(Disc.IRR'),'vert','bottom','horiz','center');
    yline(inputs.r,'-','Discount rate','LabelVerticalAlignment','top' ,'LabelHorizontalAlignment','left' );
    ylim([7.5 14])
    xticklabels({'AWE + UC','AWE + Batt','AWE + Batt arbitrage'})
    xtickangle(45)
    title('Internal rate of return compared to discount rate assumed','FontSize',10,'FontWeight', 'Bold')
    ylabel('IRR [%]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
    hold off

    figure('Name','NPV/CapEx comparison','units', 'normalized', 'outerposition', [0.5 0.5 0.45 0.45])

    bar(Disc.NPVcap, 'FaceColor', '#B3DCE7');
    hold on
    text(1:length(Disc.NPVcap),Disc.NPVcap,num2str(Disc.NPVcap'),'vert','bottom','horiz','center');
    ylim([-2 1])
    xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
    xtickangle(45)
    title('NPV/CapEx','FontSize',10,'FontWeight', 'Bold')
    ylabel('NPV/CapEx [-]','FontSize',10,'FontWeight', 'Bold')
    xlabel('Scenario','FontSize',10,'FontWeight', 'Bold')
    set(gca,'TickLength',[0 0]);
    hold off


 figure('Name','Storage replacement','units', 'normalized', 'outerposition', [0.2 0.2 0.5 0.5]);


bar([1.25 3.25 5.25 7.25],Disc.reply,'BarWidth',0.2,'FaceColor', '#355070')
hold on
bar([1.75 3.75 5.75 7.75],Disc.replc,'BarWidth',0.2,'FaceColor', '#B56576')
text([1.25 3.25 5.25 7.25],Disc.reply,num2str(round(Disc.reply,2)'),'vert','bottom','horiz','center');
text([1.75 3.75 5.75 7.75],Disc.replc,num2str(round(Disc.replc,2)'),'vert','bottom','horiz','center');
title('Storage replacement frequency per lifetime type','FontSize',10,'FontWeight', 'Bold')
ylim([0 0.15])
xlim([0.5 8.5])
ylabel('Frequency [1/year]','FontSize',10,'FontWeight', 'Bold')
xticks([1.5 3.5 5.5 7.5])
xticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
legend({'Lifetime years', 'Lifetime cycles'},'Location','southoutside','Orientation','horizontal','NumColumns',2)
legend('boxoff')

figure('Name','Payback year analysis','units', 'normalized', 'outerposition', [0.4 0.4 0.4 0.5]);

hold on
barh([25 25 25 25],'EdgeColor','none','BarWidth',0.2,'FaceColor', '#B2DCEE')
barh(Disc.Payb,'BarWidth',0.2,'FaceColor', '#6F1A07')
text(Disc.Payb(1)+0.65,0.85,num2str(round(Disc.Payb(1),2)'),'vert','bottom','horiz','center','FontSize',10);
text(Disc.Payb(2)+0.65,1.85,num2str(round(Disc.Payb(2),2)'),'vert','bottom','horiz','center','FontSize',10);
text(Disc.Payb(3)+0.65,2.85,num2str(round(1/0,2)'),'vert','bottom','horiz','center','FontSize',10);
text(Disc.Payb(4)+0.65,3.85,num2str(round(Disc.Payb(4),2)'),'vert','bottom','horiz','center');
title('Payback year of investment per scenario','FontSize',10,'FontWeight', 'Bold')
ylim([0 5])
xlim([0 25])
yticks([1 2 3 4])
yticklabels({'AWE + UC','AWE + Batt','Batt arbitrage','AWE + Batt arbitrage'})
xlabel('Years of project lifetime','FontSize',10)








end