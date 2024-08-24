%% Filtering outliers
std_threshold            = 0.0025;
threshold_halocline_grad = 0.1;
min_depth_threshold      = 200;

% an outlier has a standard deviation above <std_threshold> and is not in
% the halocline, considered where |grad(conductivity)| > <threshold_halocline>
i_outliers1 = (stdc1 > std_threshold | abs(ctdgradc1) > threshold_halocline_grad);% & botpress < min_depth_threshold;
i_outliers2 = (stdc2 > std_threshold | abs(ctdgradc2) > threshold_halocline_grad);% & botpress < min_depth_threshold;

condoff1_filtered  = condoff1(~i_outliers1);
condoff2_filtered  = condoff2(~i_outliers2);
stdc1_filtered     = stdc1(~i_outliers1);
stdc2_filtered     = stdc2(~i_outliers2);
botpress_filtered1 = botpress(~i_outliers1);
botpress_filtered2 = botpress(~i_outliers2);
botc_filtered1     = botc(~i_outliers1);
botc_filtered2     = botc(~i_outliers2);
ctdc1_filtered     = ctdc1(~i_outliers1);
ctdc2_filtered     = ctdc2(~i_outliers2);
ctds1_filtered     = ctds1(~i_outliers1);
ctds2_filtered     = ctds2(~i_outliers2);

%% Determining the offsets
% RMSE of the raw data (for reference)
rmse1_pre = rmse(ctdc1,botc,[1,2],'omitnan');
rmse2_pre = rmse(ctdc2,botc,[1,2],'omitnan');

% RMSE of the filtered data (discarding what we should not be considering anyways)
rmse1_filt = rmse(ctdc1(~i_outliers1),botc(~i_outliers1),[1,2],'omitnan');
rmse2_filt = rmse(ctdc2(~i_outliers2),botc(~i_outliers2),[1,2],'omitnan');

% Look for the offset that yields the smallest RMSE
depth_intervals = 0:10:800;
offsets_by_depth = NaN([length(depth_intervals),2]);
for k=1:length(depth_intervals)-1
    i_depths1 = find(botpress_filtered1 >= depth_intervals(k) & botpress_filtered1 < depth_intervals(k+1));
    ctdc1_filtered_depth = ctdc1_filtered(i_depths1);
    botc1_filtered_depth = botc_filtered1(i_depths1);
    rmse_best_estimate = 999;
    for offset_estimate=-0.05:0.0001:0.05
        rmse1_estimate = rmse(ctdc1_filtered_depth+offset_estimate,botc1_filtered_depth,'omitnan');
        if rmse1_estimate < rmse_best_estimate 
            offsets_by_depth(k,1) = offset_estimate; 
            rmse_best_estimate = rmse1_estimate;
        end
    end
    i_depths2 = find(botpress_filtered2 >= depth_intervals(k) & botpress_filtered2 < depth_intervals(k+1));
    ctdc2_filtered_depth = ctdc2_filtered(i_depths2);
    botc2_filtered_depth = botc_filtered2(i_depths2);
    rmse_best_estimate = 999;
    for offset_estimate=-0.05:0.0001:0.05
        rmse2_estimate = rmse(ctdc2_filtered_depth+offset_estimate,botc2_filtered_depth,'omitnan');
        if rmse2_estimate < rmse_best_estimate 
            offsets_by_depth(k,2) = offset_estimate; 
            rmse_best_estimate = rmse2_estimate;
        end
    end
end
% figure; scatter(offsets_by_depth,-depth_intervals) % sanity check plot
%% Applying the offset
ctdc1_corrected = ctdc1_filtered;
ctdc2_corrected = ctdc2_filtered;

% applying by depth
% for k_bot=1:length(botpress_filtered1)    
%     [~,k_depth] = min(abs(botpress_filtered1(k_bot)-depth_intervals)); % finds closest offset depth to the bottle depth
%     ctdc1_corrected(k_bot) = ctdc1_corrected(k_bot)+offsets_by_depth(k_depth,1);
% end
% for k_bot=1:length(botpress_filtered2)    
%     [~,k_depth] = min(abs(botpress_filtered2(k_bot)-depth_intervals)); % finds closest offset depth to the bottle depth   
%     ctdc2_corrected(k_bot) = ctdc2_corrected(k_bot)+offsets_by_depth(k_depth,2);
% end

% applying single value for all
offset1 = median(offsets_by_depth(:,1),'omitnan');
offset2 = median(offsets_by_depth(:,2),'omitnan');
ctdc1_corrected = ctdc1_corrected+offset1;
ctdc2_corrected = ctdc2_corrected+offset2;
%% Assessing the fit

correl1_filt = corrcoef(botc_filtered1(~isnan(botc_filtered1)),ctdc1_filtered(~isnan(botc_filtered1)));
correl2_filt = corrcoef(botc_filtered2(~isnan(botc_filtered2)),ctdc2_filtered(~isnan(botc_filtered2)));

correl1_corr = corrcoef(botc_filtered1(~isnan(ctdc1_corrected)),ctdc1_corrected(~isnan(ctdc1_corrected)));
correl2_corr = corrcoef(botc_filtered2(~isnan(ctdc2_corrected)),ctdc2_corrected(~isnan(ctdc2_corrected)));
