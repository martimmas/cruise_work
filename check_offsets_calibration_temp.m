%% Filtering outliers
std_threshold            = 0.0025;
threshold_thermocline_grad = 0.1;
min_depth_threshold      = 200;

% an outlier has a standard deviation above <std_threshold> and is not in
% the halocline, considered where |grad(conductivity)| > <threshold_halocline>
i_outliers1 = abs(ctdgradt1) > threshold_thermocline_grad;% & botpress < min_depth_threshold;
i_outliers2 = abs(ctdgradt2) > threshold_thermocline_grad;% & botpress < min_depth_threshold;

botp_filtered1 = botp(~i_outliers1);
botp_filtered2 = botp(~i_outliers2);
sb35temp1      = sb35temp(~i_outliers1);
sb35temp2      = sb35temp(~i_outliers2);
ctdt1_filtered = ctdt1(~i_outliers1);
ctdt2_filtered = ctdt2(~i_outliers2);

%% Determining the offsets
% RMSE of the raw data (for reference)
rmse1_pre = rmse(ctdt1,sb35temp,[1,2],'omitnan');
rmse2_pre = rmse(ctdt2,sb35temp,[1,2],'omitnan');

% RMSE of the filtered data (discarding what we should not be considering anyways)
rmse1_filt = rmse(ctdt1(~i_outliers1),sb35temp(~i_outliers1),[1,2],'omitnan');
rmse2_filt = rmse(ctdt2(~i_outliers2),sb35temp(~i_outliers2),[1,2],'omitnan');

% Look for the offset that yields the smallest RMSE
depth_intervals = 0:10:800;
offsets_by_depth = NaN([length(depth_intervals),2]);
for k=1:length(depth_intervals)-1
    i_depths1 = find(botp_filtered1 >= depth_intervals(k) & botp_filtered1 < depth_intervals(k+1));
    ctdt1_filtered_depth = ctdt1_filtered(i_depths1);
    sb35temp1_filtered_depth = sb35temp1(i_depths1);
    rmse_best_estimate = 999;
    for offset_estimate=-0.05:0.0001:0.05
        rmse1_estimate = rmse(ctdt1_filtered_depth+offset_estimate,sb35temp1_filtered_depth,'omitnan');
        if rmse1_estimate < rmse_best_estimate 
            offsets_by_depth(k,1) = offset_estimate; 
            rmse_best_estimate = rmse1_estimate;
        end
    end
    i_depths2 = find(botp_filtered2 >= depth_intervals(k) & botp_filtered2 < depth_intervals(k+1));
    ctdt2_filtered_depth = ctdt2_filtered(i_depths2);
    sb35temp2_filtered_depth = sb35temp2(i_depths2);
    rmse_best_estimate = 999;
    for offset_estimate=-0.05:0.0001:0.05
        rmse2_estimate = rmse(ctdt2_filtered_depth+offset_estimate,sb35temp2_filtered_depth,'omitnan');
        if rmse2_estimate < rmse_best_estimate 
            offsets_by_depth(k,2) = offset_estimate; 
            rmse_best_estimate = rmse2_estimate;
        end
    end
end
% figure; scatter(offsets_by_depth,-depth_intervals) % sanity check plot
%% Applying the offset
ctdt1_corrected = ctdt1_filtered;
ctdt2_corrected = ctdt2_filtered;

% applying by depth
% for k_bot=1:length(botpress_filtered1)    
%     [~,k_depth] = min(abs(botpress_filtered1(k_bot)-depth_intervals)); % finds closest offset depth to the bottle depth
%     ctdt1_corrected(k_bot) = ctdt1_corrected(k_bot)+offsets_by_depth(k_depth,1);
% end
% for k_bot=1:length(botpress_filtered2)    
%     [~,k_depth] = min(abs(botpress_filtered2(k_bot)-depth_intervals)); % finds closest offset depth to the bottle depth   
%     ctdt2_corrected(k_bot) = ctdt2_corrected(k_bot)+offsets_by_depth(k_depth,2);
% end

% applying single value for all
offset1_temp = median(offsets_by_depth(:,1),'omitnan');
offset2_temp = median(offsets_by_depth(:,2),'omitnan');
ctdt1_corrected = ctdt1_corrected+offset1_temp;
ctdt2_corrected = ctdt2_corrected+offset2_temp;
%% Assessing the fit

correl1_filt = corrcoef(sb35temp1(~isnan(sb35temp1)),ctdt1_filtered(~isnan(sb35temp1)));
correl2_filt = corrcoef(sb35temp2(~isnan(sb35temp2)),ctdt2_filtered(~isnan(sb35temp2)));

correl1_corr = corrcoef(sb35temp1(~isnan(ctdt1_corrected)),ctdt1_corrected(~isnan(ctdt1_corrected)));
correl2_corr = corrcoef(sb35temp2(~isnan(ctdt2_corrected)),ctdt2_corrected(~isnan(ctdt2_corrected)));
