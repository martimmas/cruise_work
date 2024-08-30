%% General settings
clearvars;
fsize=14;
padding_lat=0.05*3;
padding_lon=0.2*6;

%% Adds paths
addpath(genpath('/Volumes/leg/work/scientific_work_areas/ctd/ctd-data-processing/'))
folder_ctd   = '/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
folder_ladcp = '/Volumes/leg/work/scientific_work_areas/ladcp/LDEO_output/SD041_%.3d_ladcp.mat';
folder_figs  = '/Volumes/leg/work/scientific_work_areas/ctd/summary_plots/transects';
cruise       = 'SD041';

% section_name = 'kang_outer_sill';      stations = 9:15;
% section_name = 'kang_mouth';           stations = 17:25;
% section_name = 'kang_west';            stations = [62 63 59 66 67 58 9];
% section_name = 'kang_east';            stations = [26 82 81 15];
section_name = 'kang_trough_all'; stations = [60 16 12 7 57 8 85 86 87 88 90 89 3];
% section_name = 'kang_trough';      stations = [60 57 85 86 87 88 90 89];
% section_name = 'ryberg_across_inner';  stations = 29:33;
% section_name = 'ryberg_across_mid';    stations = 37:41;
% section_name = 'ryberg_along';         stations = [28 27 31 35 36 39 34 42];
% section_name = 'kivioq_along';         stations = 43:46;
% section_name = 'kivioq_across';        stations = [47 46 48 49];
% section_name = 'choco_across';         stations = [50 53 51 52];
% section_name = 'choco_along';          stations = [50 54:56];
% section_name = 'mooring_trough';       stations = [79 71 73 72 78 76 77];

%% Customisables for each panel
desired_vars = {'potemp1','salin1','oxygen','ladcp_u','ladcp_v'};
cmap_var = {'thermal','haline','oxy','balance','balance'};
label_var = {'Temperature (^oC)','Salinity','Oxygen (\mumol l^{-1})','Zonal velocity (m s^{-1} )','Meridional velocity (m s^{-1})'};
clim_var = {[-2.5, 10],[28.5,35.5],[245 360],[-0.5 0.5],[-0.5,0.5]};

%% loads up casts

ctds=load_uea_ctds(folder_ctd,cruise,0,1,0);
ctds=renameCTDfields(ctds,{'oxygen_umol_kg','oxygen'},{'fluor_ug_l','fluor'},{'BeamTrans','trans'});

%% calculate bottom depth

for i_station=1:length(ctds)
    temp_alt=ctds(i_station).alt;
    temp_alt(temp_alt>90)=nan;
    if length(temp_alt)<35 || sum(double(~isnan(temp_alt(end-35:end))))<5
        ctds(i_station).botdepth=nan;
        continue;
    end
    ctds(i_station).botdepth=median(sw_dpth(ctds(i_station).press(end-35:end),...
                             ctds(i_station).lat)+temp_alt(end-35:end),'omitnan');
end

%% Append LADCP

ctds=append_ladcp(ctds,folder_ladcp);

%% Creates section

lons   = NaN(size(stations));
lats   = NaN(size(lons));
depths = cell(size(lons));
casts  = cell(size(lons));
bed    = NaN(size(lons));
section = cell([length(desired_vars)+1,length(stations)]);


for i_section=1:length(stations)
    i_cast = find([ctds.station] == stations(i_section));

    % basic coordinates
    lons(i_section)   = ctds(i_cast).lon;
    lats(i_section)   = ctds(i_cast).lat;
    depths{i_section} = ctds(i_cast).press;
    bed(i_section)    = ctds(i_cast).botdepth;


    for i_var=1:length(desired_vars)
        section{i_var,i_section} = ctds(i_cast).(desired_vars{i_var});
    end
    section{i_var+1,i_section} = sqrt(ctds(i_cast).ladcp_u.^2+ctds(i_cast).ladcp_v.^2);
end
distances = [0; cumsum(m_lldist(lons,lats))];

%% Plotting

figure('Position',[30 30 1500 800])
hold on;
ht = tiledlayout('flow');
for i_var=1:length(desired_vars)
    nexttile; box on;
    [h_trans,~,~] = transect(distances,depths,section(i_var,:),...
                               'color',rgb('gray'),'bed',bed,'bedcolor',rgb('brown'));
    % [C,h] = transectc(distances,depths,section(end,:),...
    %       'w','ShowText','on');%,'LabelSpacing',1000);
    xlim(minmax(distances))
    ylim([0,max(bed)])
    colormap(gca,cmocean(cmap_var{i_var}));
    hcb = colorbar;
    ylabel(hcb,label_var{i_var});
    clim(clim_var{i_var})
    for i_station=1:length(stations)
        text(distances(i_station),-15,num2str(stations(i_station)),'fontsize',fsize-4,'HorizontalAlignment','center')
    end

    % ylabel(hcb,'Salinity');
    % clim([30,35])
    set(gca,'fontsize',fsize)
end
% title(ht,section_name,'fontsize',fsize)
xlabel(ht,'Transect distance (km)','fontsize',fsize)
ylabel(ht,'Pressure (dbar)','fontsize',fsize)

nexttile; hold on; box on
% plot_overview_stations(gca,folder_ctd,cruise)
hproj= m_proj('mercator','lon',minmax(lons)+[-padding_lon padding_lon],'lat',minmax(lats)+[-padding_lat padding_lat]);
% m_gshhs_i('color','k','linewidth',1.5);
m_usercoast('greenland_coast.mat','color','k','linewidth',1.5);
m_gebco2022_contour([-1000 -500],'k--');
m_grid;
xlabel('Longitude')
ylabel('Latitude')
set(gca,'FontSize',fsize)
axis equal
m_scatter(lons,lats,40,'o','k','filled');
for i_station=1:length(stations)
    m_text(lons(i_station),lats(i_station), num2str(stations(i_station)), 'Vert','top', 'Horiz','right', 'FontSize',fsize-4)
end

exportgraphics(gcf,sprintf("%s/transect_stations_%s.png",folder_figs,section_name),'Resolution',300)