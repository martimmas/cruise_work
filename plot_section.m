clearvars; close all

%% General plot variables
fsize=14;
padding=1;
m_proj('mercator');
%% General cruise and file path variables
dir_out='/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
dir_figs=[dir_out,'/plots'];
cruise     = 'SD041';
cast_start =  17;
cast_end   = 25;

% Finds all processed CTD files
stations=cast_start:1:cast_end;
temp_section=NaN([length(stations),3000]);
salt_section=NaN(size(temp_section));
oxyg_section=NaN(size(temp_section));
coords_section=NaN([length(stations),2]);

for i_station=cast_start:cast_end

    % Reads file
    i_section = i_station-cast_start+1;
    cast_num=sprintf('%03d',i_station);
    infile=fullfile(dir_out,[cruise,'_ctd_',cast_num,'.2db.mat']);
    load(infile,'-mat');
    coords_section(i_section,1)=lat;
    coords_section(i_section,2)=lon;
    temp_section(i_section,:)=potemp1;
    salt_section(i_section,:)=salin1;
    oxyg_section(i_section,:)=oxygen1_umol_kg;
end
[x_section,y_section]=m_ll2xy(coords_section(:,2),coords_section(:,1));
dst_section = sqrt(x_section.^2+y_section.^2); % we want it in km
ints = [0; cumsum(dst_section)];
xplot_section = (ints(1:end-1)+ints(2:end))/2;



%% Plotting

[xplot,yplot] = meshgrid(xplot_section,press);
figure('Position',[30 30 1200 900])
ht = tiledlayout('flow');
title(ht,sprintf('Transect stations %03d to %03d',cast_start,cast_end),'fontsize',fsize+4)
% temperature
nexttile; box on; hold on;
hp = pcolor(xplot_section,yplot,temp_section');
set(hp,'EdgeColor','none')
ylabel('Pressure (dbar)')
xlabel('Distance (km)')
hcb_temp = colorbar();
hcb_temp.Label.String='Potential temperature \theta (^oC)';
set(gca,'ydir','reverse','fontsize',fsize)
xlim(minmax(xplot_section)+ [-dst_section(1) + dst_section(end)])
colormap(gca,cmocean('thermal'))

% salinity
nexttile; box on; hold on;
hp = pcolor(xplot_section,yplot,salt_section');
set(hp,'EdgeColor','none')
ylabel('Pressure (dbar)')
xlabel('Distance (km)')
hcb_salt = colorbar();
hcb_salt.Label.String='Salinity';
set(gca,'ydir','reverse','fontsize',fsize)
xlim(minmax(xplot_section)+ [-dst_section(1) + dst_section(end)])
colormap(gca,cmocean('haline'))

% oxygen
nexttile; box on; hold on;
hp = pcolor(xplot_section,yplot,salt_section');
set(hp,'EdgeColor','none')
ylabel('Pressure (dbar)')
xlabel('Distance (km)')
hcb_salt = colorbar();
hcb_salt.Label.String='Oxygen (\mu mol kg^{-1})';
set(gca,'ydir','reverse','fontsize',fsize)
xlim(minmax(xplot_section)+ [-dst_section(1) + dst_section(end)])
colormap(gca,cmocean('oxy'))

% map
% Plotting the base map
nexttile; box on; hold on
hproj= m_proj('mercator','lon',minmax(coords_section(:,2))+[-padding padding],'lat',minmax(coords_section(:,1))+[-padding padding]);
m_gshhs_i('color','k','linewidth',1.5);
m_gebco2022_contour([-1000 -500],'k--');
m_grid;
xlabel('Longitude')
ylabel('Latitude')
set(gca,'FontSize',fsize)
axis equal
m_scatter(coords_section(:,2),coords_section(:,1),40,'o','k','filled');

% exportgraphics(gcf,sprintf("%s/transect_%03d-%03d.png",dir_figs,cast_start,cast_end),'Resolution',300)