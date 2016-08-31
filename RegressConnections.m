




Data = csvread('data_MS_withoutlabels.csv');

num_ROI_pairs = 4624;
num_behav = 3; % EDSS, 6MW, T25FW
roi_offset = 1;  % column number for ROI 1
beh_offset = 4630; % column number for first behavioral measure

% Plot age to check
plot(Data(:,4625));
figure

for ii = 1:num_ROI_pairs
    for jj = 1:num_behav
        roi_pred = Data(:,(ii-1)+roi_offset);
        roi_pred_input = [roi_pred ones(size(roi_pred))];
        behav_output = Data(:,(jj-1)+beh_offset);
        [B,BINT,R,RINT,STATS] = regress(behav_output,roi_pred_input);
        
        beta_mat(ii,jj) = B(1);
        Rsq(ii,jj) = STATS(1);
        Pval(ii,jj) = STATS(3);   
    end
end


imagesc(-log10(Pval)>2), axis square    % Looking at things that have pval<0.01


edss_ind = find((-log10(Pval(:,1))>2));
b6mw_ind = find((-log10(Pval(:,2))>2));
b25f_ind = find((-log10(Pval(:,3))>2));


save conn_analysis


