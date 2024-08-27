%% General settings
clearvars; 
fsize=14;
padding_lat=0.1;
padding_lon=0.5;
cmocean_cmap = 'thermal';
color_scheme_function = sprintf("cmocean('%s'",cmocean_cmap);
% color_scheme_function = "cbrewer('qual','Set3'";
% color_scheme_function = "lines(";
date_update = datetime("today","Format","MMdd");

%% General cruise and file path variables
dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
% file_waypoints = readtable('/Users/mmeb1/FjordMIX/KangGlac/cruise_work/ctd_station_wps.xlsx');
dir_figs=[dir_out,'/../summary_plots/profiles'];

cruise='SD041';
% n_stations_to_plot=6;
% order_station_ids = [37 38 35 39 40]; % reorder the section
% order_station_ids = [28 31 35 36 37 42]; % transect along fjord
% order_station_ids = [50 53 51 52];
% order_station_ids = 58:63;
order_station_ids = [85 69 61 27 43 52];

%% Finding what to plot

% Gets future WPs from excel sheet (usually in deg, min, sec because it is better for the bridge
if exist('file_waypoints','var')
    sign_lats = ones(size(file_waypoints));
    sign_lons = sign_lats;
    for i_wp=1:height(file_waypoints)
        if strcmp(file_waypoints.lat_ns(i_wp),'S'), sign_lats(i_wp) = -sign_lats(i_wp); end
        if strcmp(file_waypoints.lon_ew(i_wp),'W'), sign_lons(i_wp) = -sign_lons(i_wp); end
    end
    planned_lats = sign_lats.*(file_waypoints.lat_degree + file_waypoints.lat_min/60);% + file_waypoints.lat_sec/3600;
    planned_lons = sign_lons.*(file_waypoints.lon_degree + file_waypoints.lon_min/60);% + file_waypoints.lon_sec/3600;
end

% Finds all processed CTD files
% matfiles = dir(fullfile(dir_out,[cruise,'_ctd_*.2db.mat']));
matfiles = dir(fullfile(dir_out,[cruise,'_ctd_*_cal.2db.mat']));
% [~,order_station_ids] = sort([matfiles.datenum]);
% if exist('order_station_ids','var')
%     matfiles = matfiles(order_station_ids);
% end
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

% a different line colour for each station/cast
eval(sprintf("lcolor=%s,length(stations));",color_scheme_function));

%% Starts plotting
figure('Position',[30 30 1200 700])
ht = tiledlayout('flow');
% title(ht,sprintf("CTD summary: %s",datetime("now","Format","dd-MMM HH:mm")),'fontsize',16)
station_handles = [];
station_names   = {};
lons = NaN(size(stations));
lats = NaN(size(lons));
max_temp = -999;

for i=1:length(stations)
    i_station = stations(i);
    station_color = lcolor(i,:);

    % Reads file
    cast_num=sprintf('%03d',i_station);
    infile=fullfile(dir_out,[cruise,'_ctd_',cast_num,'.2db.mat']);
    try
        load(infile,'-mat');
    catch ME
        fprintf('loading cast %d failed: %s. Skipping...\n',i_station,ME.message)
        continue
    end
    lons(i) = lon;
    lats(i) = lat;

    % we shouldnt need to know exactly which one is higher between both
    % sensors for this one
    [max_t_cast,i_max_temp] = max(potemp1(press>50)); % we do not want any surface waters, because that will significantly change the slope
    if max_t_cast > max_temp
        max_temp = max_t_cast;
        salt_at_max_temp = salin1(i_max_temp);
    end

    % Plots potential temperature
    nexttile(1); box on; hold on; grid on
    set(gca,'ydir','reverse','xaxislocation','top','fontsize',fsize)
    ylabel(gca,'Pressure (dbar)')
    xlabel('Potential temperature \theta (^oC)')
    plot(potemp1,press,'linestyle','-','Color',station_color,'LineWidth',2)
    if exist('potemp2','var')
        plot(potemp2,press,'linestyle',':','Color',station_color,'LineWidth',2)
    end
    
    % Plots salinity
    nexttile(2); box on; hold on; grid on
    set(gca,'ydir','reverse','xaxislocation','top','fontsize',fsize)
    ylabel(gca,'Pressure (dbar)')
    xlabel('Salinity')
    plot(salin1,press,'linestyle','-','Color',station_color,'LineWidth',2)
    if exist('salin2','var')
        plot(salin2,press,'linestyle',':','Color',station_color,'LineWidth',2)
    end
    
    % Plots potential density sigma
    nexttile(3); box on; hold on; grid on
    set(gca,'ydir','reverse','xaxislocation','top','fontsize',fsize)
    ylabel(gca,'Pressure (dbar)')
    xlabel(gca,'Beam Transmitance (%)')
    plot(BeamTrans,press,'linestyle','-','Color',station_color,'LineWidth',2)
    % xlabel('\sigma_0')
    % plot(sig0,press,'linestyle','-','Color',station_color,'LineWidth',2)

    % Plots disolved oxygen
    nexttile(4); box on; hold on; grid on
    set(gca,'ydir','reverse','xaxislocation','top','fontsize',fsize)
    ylabel(gca,'Pressure (dbar)')
    xlabel('Oxygen (\mu mol kg^{-1})')
    % if exist('oxygen2_umol_kg','var')
    %     hp1 = plot(oxygen1_umol_kg,press,'-k','linewidth',1.5);
    %     hp2 = plot(oxygen2_umol_kg,press,':k','linewidth',1.5);
    % end
    plot(oxygen1_umol_kg,press,'linestyle','-','Color',station_color,'LineWidth',2)
    % if exist('oxygen2_umol_kg','var')
    %     plot(oxygen2_umol_kg,press,'linestyle',':','Color',station_color,'LineWidth',2)
    % end
    % Legend indicating sensors if more than 1
    % if exist('hp2','var'), legend(gca,[hp1,hp2],{'sensor 1','sensor 2'},'location','southeast'); end
    
    % Plots theta-S diagram
    nexttile(5); box on; hold on
    set(gca,'fontsize',fsize)
    xlabel('Salinity')
    ylabel('Potential temperature \theta (^oC)')
    scatter(salin1,potemp1,20,'o','MarkerFaceColor',station_color,'MarkerEdgeColor','none');
    scatter(salin2,potemp2,20,'^','MarkerFaceColor',station_color,'MarkerEdgeColor','none')

    % adds sigma curves, freezing temp at surface line, and approx. Gade line
    if i_station==stations(end)
        % ts_temp_bnds = get(gca,'ylim');
        % ts_salt_bnds = get(gca,'xlim');

        nexttile(1);
        potemp_bnds = get(gca,'xlim');
        potemp_dens = potemp_bnds(1):0.1:potemp_bnds(2);
        nexttile(2);
        salin_bnds = get(gca,'xlim');
        salin_dens = salin_bnds(1):0.01:salin_bnds(2);
        nexttile(5);
        [thetai,si,dens] = get_sigma_curves(potemp_dens,salin_dens);
        [c,h]=contour(si,thetai,dens,'--k','ShowText',true,'LabelFormat',"%0.0f");
        tfreeze1 = -0.0549 .* salin_dens -3.6628e-04;
        plot(salin_dens,tfreeze1,'--k','linewidth',1.5) % freezing temperature at surface
        plot([0 salt_at_max_temp],[-90 max_temp],':k','linewidth',1.5) % approx. Gade line
        ylim(potemp_bnds)
        xlim(salin_bnds)
    end
end

% Plotting the base map
nexttile(6); box on; hold on
hproj= m_proj('mercator','lon',minmax(lons)+[-padding_lon padding_lon],'lat',minmax(lats)+[-padding_lat padding_lat]);
m_gshhs_i('color','k','linewidth',1.5);
m_gebco2022_contour([-1000 -500],'k--');
m_grid;
xlabel('Longitude')
ylabel('Latitude')
axis equal

% Adding station coords to the plot
for i=1:length(stations)
    i_station = stations(i);
    hs = m_scatter(lons(i),lats(i),40,'o',...
                   'MarkerFaceColor',lcolor(i,:),'MarkerEdgeColor','none');    
    station_handles = [station_handles hs];
    station_names{end+1} = sprintf('%03d',i_station);
end

% Adding planned WPs to plot
if exist('file_waypoints','var')
    for i_planned=1:length(planned_lats)
        hsp = m_scatter(planned_lons(i_planned),planned_lats(i_planned),...
                       20,'o','MarkerFaceColor',[0 0 0],'MarkerEdgeColor','none');    
    end
    station_handles = [station_handles hsp];
    station_names{end+1} = 'planned';
end

% Adding a legend
hl = legend(station_handles,station_names,'Location','eastoutside');
hl.NumColumns = ceil(length(hl.String)/10);
hl.Title.String='Station No.';
set(gca,'fontsize',fsize)
% exportgraphics(gcf,sprintf("%s/summary_stations_%s.png",dir_figs,date_update),'Resolution',300)