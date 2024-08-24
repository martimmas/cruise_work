addpath(genpath('/Users/mmeb1/scripts_import/matlab'))
addpath(genpath('/Volumes/leg/work/scientific_work_areas/ctd'))
% Remember to set up paths in CTDvarn.m!
clearvars; close all
i_cast=86; % TODO: 84-86 SAVE FIGURES FROM INTERMEDIATE STEPS! NO 83?! Cast 85 has a very noisy TS profile
ctdreadGEN(i_cast)
editctdGEN(i_cast)
run batch_ctdGEN % wraps deriveGEN, onehzctdGEN, splitcastGEN, fallrateGEN, and gridctdGEN
ctdplotGEN(aa)

for i=84:86
    close all;
    ctdplotGEN(i)
end
close all;
% casts 76 to 78 might need to be reprocessed


% (done up to 063)
run batch_botGEN % creates bottle file and then reads sbe35; encapsulates makebotGEN, sb35readGEN, readsalGEN, addsalGEN, salcalGEN, mergebotGEN

run plot_calibration % checks the T, C, and oxygen sensor comparisons

% temperature and conductivity: median along depth of the offset that
% minimises RMSE between CTD sensors and SBE35 and bottle salinity,
% respectively. The median was chosen as to not overcorrect values far from
% the sharp gradient regions of the water column, which tend to deviate the
% most between quantities

% temp1   -= 9e-4; temp2   -= 2.1e-3;
% cond1   += 9e-4; cond2   += 7.3e-3;
% oxygen1 -= 10;   oxygen2 += 2;       (based on Povl's estimate). Note that there is a significant drift for both sensors, especially for sensor 1!
% add offsets to cruise-specific switch in salcalappGEN.m

run batch_calGEN % batch (re)processes the CTD data with the callibrations