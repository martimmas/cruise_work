%% Running the respective offset routines
clearvars

dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
load ([dir_out,'/salts/salcals12.all.mat'])
run check_offsets_calibration_salt

load ([dir_out,'/SBE35/tempcals.all.mat'])
run check_offsets_calibration_temp

% TODO: calculate dissolved oxygen saturation
% check how it varies with depth

%% Plotting the different offset corrections

figure('Position',[200 200 900 600]); 
ht = tiledlayout('horizontal');

% Temperature calibration
if exist('ctdt1_corrected','var')
    nexttile; hold on; box on; grid on
    scatter(ctdt1_filtered-sb35temp1,botp_filtered1,40,"blue",'o');
    scatter(ctdt2_filtered-sb35temp2,botp_filtered2,40,"red",'o');
    scatter(ctdt1_corrected-sb35temp1,botp_filtered1,40,"blue",'filled','o','MarkerFaceAlpha',0.5);
    scatter(ctdt2_corrected-sb35temp2,botp_filtered2,40,"red",'filled','o','MarkerFaceAlpha',0.5);
    text(0.02,0.05,sprintf('Mean sensor1 offset: %.4f deg.C',offset1_temp),'Units','normalized','fontsize',14);
    text(0.02,0.02,sprintf('Mean sensor2 offset: %.4f deg.C',offset2_temp),'Units','normalized','fontsize',14);
    ylabel('Pressure (dbar)')
    xlabel('Temperature offsets (^oC)');
    xlim([-0.1 0.1])
    set(gca,'ydir','reverse','fontsize',14)
end

% Conductivity calibration
if exist('ctdc1_corrected','var')
    nexttile; hold on; box on; grid on
    scatter(ctdc1_filtered-botc_filtered1,botpress_filtered1,40,"blue",'o');
    scatter(ctdc2_filtered-botc_filtered2,botpress_filtered2,40,"red",'o');
    scatter(ctdc1_corrected-botc_filtered1,botpress_filtered1,40,"blue",'filled','o','MarkerFaceAlpha',0.5);
    scatter(ctdc2_corrected-botc_filtered2,botpress_filtered2,40,"red",'filled','o','MarkerFaceAlpha',0.5);
    text(0.02,0.05,sprintf('Mean sensor1 offset: %.4f',offset1),'Units','normalized','fontsize',14);
    text(0.02,0.02,sprintf('Mean sensor2 offset: %.4f',offset2),'Units','normalized','fontsize',14);
    ylabel('Pressure (dbar)')
    xlabel('Conductivity offsets');
    xlim([-0.1 0.1])
    set(gca,'ydir','reverse','fontsize',14)
end


%% Oxygen calibration
run get_oxygen_calibration

% nexttile; hold on; box on; grid on
% scatter(botc_filtered1,ctdc1_filtered,40,"blue",'o','MarkerFaceAlpha',0.5);
% scatter(botc_filtered2,ctdc2_filtered,40,"red",'o','MarkerFaceAlpha',0.5);
% scatter(botc_filtered1,ctdc1_corrected,40,"blue",'filled','o','MarkerFaceAlpha',0.5);
% scatter(botc_filtered2,ctdc2_corrected,40,"red",'filled','o','MarkerFaceAlpha',0.5);
% plot(xlim,ylim,':k','linewidth',0.5)
% text(0.02,0.05,sprintf('Sensor1 r: %.4f (filt.), %.4f (corr.)',correl1_filt(2,1),correl1_corr(2,1)),'Units','normalized','fontsize',14);
% text(0.02,0.02,sprintf('Sensor2 r: %.4f (filt.), %.4f (corr.)',correl2_filt(2,1),correl2_corr(2,1)),'Units','normalized','fontsize',14);
% xlabel('Salinometer')
% ylabel('Sensor')

% set(gca,'ydir','reverse','fontsize',14)

% title(ht,['Filtering by \sigma_{cond} < ',num2str(std_threshold)])
