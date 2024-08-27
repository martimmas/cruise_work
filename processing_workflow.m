addpath(genpath('/Users/mmeb1/scripts_import/matlab'))
addpath(genpath('/Volumes/leg/work/scientific_work_areas/ctd/ctd-data-processing'))
% Remember to set up paths in CTDvarn.m!
clearvars; close all
i_cast=90; % TODO: Casts 85+ have a very noisy TS1 profile, considerable drift in salinity
ctdreadGEN(i_cast)
editctdGEN(i_cast)
run batch_ctdGEN % wraps deriveGEN, onehzctdGEN, splitcastGEN, fallrateGEN, and gridctdGEN
ctdplotGEN(aa)

for i=88:89
    close all;
    ctdplotGEN(i)
end
close all;
% casts 76 to 78 might need to be reprocessed


% done up to 90, BUT: cast 77 is messed up... skipped 83 and 84; 89 and 90 might be corrupt
run batch_botGEN % creates bottle file and then reads sbe35; encapsulates makebotGEN, sb35readGEN, readsalGEN, addsalGEN, salcalGEN, mergebotGEN

run plot_calibration % checks the T, C, and oxygen sensor comparisons

run batch_calGEN % batch (re)processes the CTD data with the callibrations