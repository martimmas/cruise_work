%% Filtering outliers
std_threshold            = 0.0025;
threshold_halocline_grad = 0.1;
min_depth_threshold      = 200;
stn_salt = stn;

% an outlier has a standard deviation above <std_threshold> and is not in
% the halocline, considered where |grad(conductivity)| > <threshold_halocline>
i_outliers1 = (stdc1 > std_threshold | abs(ctdgradc1) > threshold_halocline_grad);% & botpress < min_depth_threshold;
i_outliers2 = (stdc2 > std_threshold | abs(ctdgradc2) > threshold_halocline_grad);% & botpress < min_depth_threshold;

ctdc1_filtered     = ctdc1;
ctdc2_filtered     = ctdc2;
ctds1_filtered     = ctds1;
ctds2_filtered     = ctds2;
condoff1_filtered  = condoff1;
condoff2_filtered  = condoff2;
stdc1_filtered     = stdc1;
stdc2_filtered     = stdc2;
botpress_filtered1 = botpress;
botpress_filtered2 = botpress;
botc_filtered1     = botc;
botc_filtered2     = botc;
condoff1_filtered(i_outliers1)  = NaN;
condoff2_filtered(i_outliers2)  = NaN;
stdc1_filtered(i_outliers1)     = NaN;
stdc2_filtered(i_outliers2)     = NaN;
botpress_filtered1(i_outliers1) = NaN;
botpress_filtered2(i_outliers2) = NaN;
botc_filtered1(i_outliers1)     = NaN;
botc_filtered2(i_outliers2)     = NaN;
ctdc1_filtered(i_outliers1)     = NaN;
ctdc2_filtered(i_outliers2)     = NaN;
ctds1_filtered(i_outliers1)     = NaN;
ctds2_filtered(i_outliers2)     = NaN;

% RMSE of the raw data (for reference)
rmse1_pre = rmse(ctdc1,botc,[1,2],'omitnan');
rmse2_pre = rmse(ctdc2,botc,[1,2],'omitnan');

% RMSE of the filtered data (discarding what we should not be considering anyways)
rmse1_filt = rmse(ctdc1(~i_outliers1),botc(~i_outliers1),[1,2],'omitnan');
rmse2_filt = rmse(ctdc2(~i_outliers2),botc(~i_outliers2),[1,2],'omitnan');


%% Determining the offsets
offset_cond1 = botc_filtered1 - ctdc1_filtered;
offset_cond2 = botc_filtered1 - ctdc2_filtered;

% Look for the offset that yields the smallest RMSE
% depth_intervals = 0:10:800;
% offsets_by_depth = NaN([length(depth_intervals),2]);
% for k=1:length(depth_intervals)-1
%     i_depths1 = find(botpress_filtered1 >= depth_intervals(k) & botpress_filtered1 < depth_intervals(k+1));
%     ctdc1_filtered_depth = ctdc1_filtered(i_depths1);
%     botc1_filtered_depth = botc_filtered1(i_depths1);
%     rmse_best_estimate = 999;
%     for offset_estimate=-0.05:0.0001:0.05
%         rmse1_estimate = rmse(ctdc1_filtered_depth+offset_estimate,botc1_filtered_depth,'omitnan');
%         if rmse1_estimate < rmse_best_estimate 
%             offsets_by_depth(k,1) = offset_estimate; 
%             rmse_best_estimate = rmse1_estimate;
%         end
%     end
%     i_depths2 = find(botpress_filtered2 >= depth_intervals(k) & botpress_filtered2 < depth_intervals(k+1));
%     ctdc2_filtered_depth = ctdc2_filtered(i_depths2);
%     botc2_filtered_depth = botc_filtered2(i_depths2);
%     rmse_best_estimate = 999;
%     for offset_estimate=-0.05:0.0001:0.05
%         rmse2_estimate = rmse(ctdc2_filtered_depth+offset_estimate,botc2_filtered_depth,'omitnan');
%         if rmse2_estimate < rmse_best_estimate 
%             offsets_by_depth(k,2) = offset_estimate; 
%             rmse_best_estimate = rmse2_estimate;
%         end
%     end
% end
% figure; scatter(offsets_by_depth,-depth_intervals) % sanity check plot
%% Applying the offset

% applying single value for all
offset1_cond = median(offset_cond1(:),'omitnan');
offset2_cond = median(offset_cond2(:),'omitnan');
ctdc1_corrected = ctdc1_filtered+offset1_cond;
ctdc2_corrected = ctdc2_filtered+offset2_cond;
%% Assessing the fit

correl1_filt = corrcoef(botc_filtered1(~isnan(botc_filtered1)),ctdc1_filtered(~isnan(botc_filtered1)));
correl2_filt = corrcoef(botc_filtered2(~isnan(botc_filtered2)),ctdc2_filtered(~isnan(botc_filtered2)));

correl1_corr = corrcoef(botc_filtered1(~isnan(ctdc1_corrected)),ctdc1_corrected(~isnan(ctdc1_corrected)));
correl2_corr = corrcoef(botc_filtered2(~isnan(ctdc2_corrected)),ctdc2_corrected(~isnan(ctdc2_corrected)));
