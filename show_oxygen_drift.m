clearvars
folder_ctd   = '/Volumes/leg/work/scientific_work_areas/ctd/BASproc';
cruise       = 'SD041';


%% loads up casts

ctds=load_uea_ctds(folder_ctd,cruise,1);
ctds=renameCTDfields(ctds,{'oxygen1_umol_kg','oxygen1'},{'oxygen2_umol_kg','oxygen2'},...
                          {'fluor_ug_l','fluor'},{'BeamTrans','trans'});

%% Plots
figure;
ht = tiledlayout('horizontal');
for i_cast=1:length(ctds)
    o2_sat1 = gsw_O2sol(ctds(i_cast).salin1,ctds(i_cast).potemp1,ctds(i_cast).depth,ctds(i_cast).lon,ctds(i_cast).lat);
    o2_sat2 = gsw_O2sol(ctds(i_cast).salin2,ctds(i_cast).potemp2,ctds(i_cast).depth,ctds(i_cast).lon,ctds(i_cast).lat);

    o2_pct_sat1 = ctds(i_cast).oxygen1./o2_sat1 * 100;
    o2_pct_sat2 = ctds(i_cast).oxygen2./o2_sat2 * 100;
    time_cast = ctds(i_cast).date; %datetime(ctds(i_cast).date,'convertfrom','juliandate');

    nexttile(1); hold on; box on;
    scatter(o2_pct_sat1,ctds(i_cast).depth,40,ones(size(ctds(i_cast).depth)).*ctds(i_cast).date,'filled','Marker','o');
    xlabel('O2 % saturation sensor 1');
    set(gca,'ydir','reverse','fontsize',14)
    nexttile(2); hold on; box on;
    scatter(o2_pct_sat2,ctds(i_cast).depth,40,ones(size(ctds(i_cast).depth)).*ctds(i_cast).date,'filled','Marker','^');
    xlabel('O2 % saturation sensor 2');
    set(gca,'ydir','reverse','fontsize',14)
    nexttile(3); hold on; box on;
    scatter(o2_pct_sat1-o2_pct_sat2,ctds(i_cast).depth,40,ones(size(ctds(i_cast).depth)).*time_cast,'Marker','o');
    xlabel('O2 % saturation difference');
    set(gca,'ydir','reverse','fontsize',14)
end
ylabel(ht,'Pressure (dbar)')

hcb = colorbar;
colormap(cmocean('thermal'));
% xlim([0 0.1])


