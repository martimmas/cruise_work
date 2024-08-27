%% General settings
clearvars; 
fsize=14;
cmocean_cmap = 'thermal';
date_update = datetime("today","Format","MMdd");

%% General cruise and file path variables
dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
dir_figs=[dir_out,'/../summary_plots/profiles'];

cruise='SD041';
% n_stations_to_plot=6;
order_station_ids = 3:90;

%% Finding what to plot

% Finds all processed CTD files
% matfiles = dir(fullfile(dir_out,[cruise,'_ctd_*.2db.mat']));  % uncalibrated files
matfiles = dir(fullfile(dir_out,[cruise,'_ctd_*_cal.2db.mat'])); % calibrated files
cast_numbers = cell(size(matfiles));

% will plot the latest cast, going backwards <n_stations_to_plot> casts
all_casts = NaN(size(matfiles));
for i=1:length(matfiles)
    split_cast_name = strsplit(matfiles(i).name,'.');
    cast_id = strsplit(split_cast_name{1},'_');
    all_casts(i) = int32(str2double(cast_id{end}));
end
cast_end=max(all_casts);
if exist('n_stations_to_plot','var')
    cast_start=cast_end-n_stations_to_plot+1;    
elseif ~exist('order_station_ids','var')
    cast_start=min(cell2mat(cast_numbers));
end
% otherwise, will take it from <order_station_ids>
if exist('cast_start','var')
    stations=cast_start:1:cast_end;
else
    stations=order_station_ids;
end

%% Starts plotting
figure('Position',[30 30 600 500])
box on; hold on
max_temp = -999;

for i=1:length(stations)
    i_station = stations(i);

    % Reads file
    cast_num=sprintf('%03d',i_station);
    infile=fullfile(dir_out,[cruise,'_ctd_',cast_num,'.2db.mat']);
    try
        load(infile,'-mat');
    catch ME
        fprintf('loading cast %d failed: %s. Skipping...\n',i_station,ME.message)
        continue
    end

    % we shouldnt need to know exactly which one is higher between both
    % sensors for this one
    [max_t_cast,i_max_temp] = max(potemp1(press>50)); % we do not want any surface waters, because that will significantly change the slope
    if max_t_cast > max_temp
        max_temp = max_t_cast;
        salt_at_max_temp = salin1(i_max_temp);
    end

    % Plots theta-S diagram
    set(gca,'fontsize',fsize)
    xlabel('Salinity')
    ylabel('Potential temperature \theta (^oC)')
    scatter(salin1,potemp1,20,ones(size(salin1)).*i_station,'filled','Marker','o','MarkerEdgeColor','none','MarkerFaceAlpha',0.5);

    % adds sigma curves, freezing temp at surface line, and approx. Gade line
    if i_station==stations(end)
        potemp_bnds = get(gca,'ylim');
        potemp_dens = potemp_bnds(1):0.1:potemp_bnds(2);
        salin_bnds = get(gca,'xlim');
        salin_dens = salin_bnds(1):0.01:salin_bnds(2);
        
        [thetai,si,dens] = get_sigma_curves(potemp_dens,salin_dens);
        [c,h]=contour(si,thetai,dens,'--k','ShowText',true,'LabelFormat',"%0.0f");
        tfreeze1 = -0.0549 .* salin_dens -3.6628e-04;
        plot(salin_dens,tfreeze1,'--k','linewidth',1.5) % freezing temperature at surface
        plot([0 salt_at_max_temp],[-90 max_temp],':k','linewidth',1.5) % approx. Gade line
        ylim(potemp_bnds)
        xlim(salin_bnds)
        hc = colorbar;
        ylabel(hc,'Station No.','fontsize',fsize)
        colormap(cmocean(cmocean_cmap))
    end
end

% exportgraphics(gcf,sprintf("%s/ts_summary_stations.png",dir_figs),'Resolution',300)