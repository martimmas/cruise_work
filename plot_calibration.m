%% Running the respective offset routines
clearvars

dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
folder_figs = '/Volumes/leg/work/scientific_work_areas/ctd/summary_plots/calibration';
load ([dir_out,'/salts/salcals12.all.mat'])
run check_offsets_calibration_salt

load ([dir_out,'/SBE35/tempcals.all.mat'])
run check_offsets_calibration_temp

% TODO: calculate dissolved oxygen saturation
% check how it varies with depth

%% Plotting the different offset corrections

figure('Position',[200 200 1200 800]); 
ht = tiledlayout('flow');
ht.TileIndexing = "rowmajor";

% Temperature calibration
if exist('ctdt1_corrected','var')
    nexttile; hold on; box on;
    h1 = scatter(stn_temp(1),offset_temp1(1),40,'blue','filled','^','MarkerFaceAlpha',0.5);
    h2 = scatter(stn_temp(1),offset_temp2(1),40,'red','filled','^','MarkerFaceAlpha',0.5);
    scatter(stn_temp,offset_temp1,40,'blue','filled','^','MarkerFaceAlpha',0.5);
    scatter(stn_temp,offset_temp2,40,'red','filled','^','MarkerFaceAlpha',0.5);
    hline(0,'--k')
    xlabel('Station')
    ylabel('Temperature offsets (^oC)')
    legend([h1 h2],{'Sensor 1','Sensor 2'},'Location','Northeast','FontSize',14)
    set(gca,'fontsize',14)

    nexttile; hold on; box on;
    scatter(ctdt1_filtered-sb35temp1,botp_filtered1,40,"blue",'o');
    scatter(ctdt2_filtered-sb35temp2,botp_filtered2,40,"red",'o');
    scatter(ctdt1_corrected-sb35temp1,botp_filtered1,40,"blue",'filled','o','MarkerFaceAlpha',0.5);
    scatter(ctdt2_corrected-sb35temp2,botp_filtered2,40,"red",'filled','o','MarkerFaceAlpha',0.5);
    vline(0,'--k')
    text(0.02,0.10,sprintf('Sensor1 offset: %.4f deg.C',offset1_temp),'Units','normalized','fontsize',14);
    text(0.02,0.03,sprintf('Sensor2 offset: %.4f deg.C',offset2_temp),'Units','normalized','fontsize',14);
    ylabel('Pressure (dbar)')
    xlabel('Temperature offsets (^oC)');
    xlim([-0.1 0.1])
    set(gca,'ydir','reverse','fontsize',14)
end

% Conductivity calibration
if exist('ctdc1_corrected','var')
    nexttile; hold on; box on;
    scatter(stn_salt,offset_cond1,40,'blue','filled','^','MarkerFaceAlpha',0.5);
    scatter(stn_salt,offset_cond2,40,'red','filled','^','MarkerFaceAlpha',0.5);
    hline(0,'--k')
    xlabel('Station')
    ylabel('Conductivity offsets (mS/cm)')
    set(gca,'fontsize',14)

    nexttile; hold on; box on;
    scatter(botc_filtered1-ctdc1_filtered,botpress_filtered1,40,"blue",'o');
    scatter(botc_filtered2-ctdc2_filtered,botpress_filtered2,40,"red",'o');
    scatter(botc_filtered1-ctdc1_corrected,botpress_filtered1,40,"blue",'filled','o','MarkerFaceAlpha',0.5);
    scatter(botc_filtered2-ctdc2_corrected,botpress_filtered2,40,"red",'filled','o','MarkerFaceAlpha',0.5);
    vline(0,'--k')
    text(0.02,0.10,sprintf('Sensor1 offset: %.4f',offset1_cond),'Units','normalized','fontsize',14);
    text(0.02,0.03,sprintf('Sensor2 offset: %.4f',offset2_cond),'Units','normalized','fontsize',14);
    ylabel('Pressure (dbar)')
    xlabel('Conductivity offsets (mS/cm)');
    xlim([-0.1 0.1])
    set(gca,'ydir','reverse','fontsize',14)
end

% exportgraphics(gcf,sprintf("%s/calibration_temp_cond.png",folder_figs),'Resolution',150)
%% Oxygen calibration
run get_oxygen_calibration

% exportgraphics(gcf,sprintf("%s/drift_oxygen.png",folder_figs),'Resolution',150)