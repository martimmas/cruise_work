function hf = plot_overview_stations(ax,dir_out,cruise)

% General plot variables
padding_lat=0.1;
padding_lon=0.5;

if nargin < 2, dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc'; end
if nargin < 3, cruise='SD041'; end

%% Coordinates of coring stations

lons_cores=[-31.693783,-31.616133];
lats_cores=[67.965167,67.953333];
core_stations={'010GC','039GC'};

%% Finds all processed CTD files for their coordinates
matfiles = dir(fullfile(dir_out,[cruise,'_ctd_*.2db.mat']));
stations = NaN(size(matfiles));
for i=3:length(matfiles)
    split_cast_name = strsplit(matfiles(i).name,'.');
    cast_id = strsplit(split_cast_name{1},'_');
    stations(i) = int32(str2double(cast_id{end}));
end
stations = stations(~isnan(stations));

lons = NaN(size(stations));
lats = NaN(size(lons));
for i=1:length(stations)
    i_station = stations(i);

    % Reads files
    cast_num=sprintf('%03d',i_station);
    infile=fullfile(dir_out,[cruise,'_ctd_',cast_num,'.2db.mat']);
    load(infile,'-mat');
    lons(i) = lon;
    lats(i) = lat;
end

%% Plotting

if nargin < 1 || isempty(ax)
    hf = figure('Position',[30 30 1200 700]);
else
    axes(ax);
    hf = gcf;
end
hold on; box on;
hproj= m_proj('mercator','lon',minmax(lons)+[-padding_lon padding_lon],'lat',minmax(lats)+[-padding_lat padding_lat]);
m_gshhs_i('color','k','linewidth',1.5);
m_gebco2022_contour([-1000 -500],'k--');
m_grid;
xlabel('Longitude')
ylabel('Latitude')
axis equal
for i=1:length(stations)
    hs = m_scatter(lons(i),lats(i),40,'o','filled');
    m_text(lons(i),lats(i), num2str(stations(i)), 'Vert','bottom', 'Horiz','left', 'FontSize',10)
end
for i=1:length(core_stations)
    hc = m_scatter(lons_cores(i),lats_cores(i),80,'+');
    m_text(lons_cores(i),lats_cores(i), core_stations{i}, 'Vert','top', 'Horiz','right', 'FontSize',10)
end

end