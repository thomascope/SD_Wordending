% A clumsy hacky script to quickly extract single subject contrasts to address
% reviewer comments

load('/imaging/tc02/SD_Wordending/preprocess/VBM_stats/factorial_full_group_vbm_TIVnormalised_agecovaried_unsmoothedmask/SPM.mat')
this_contrast = 3;
this_contrast_name = 'Controls > SD';
%loc =   [68, 2.125, 224]
%loc = [47, -9, 224]
%loc = [-41  16  -30] % Left temporal pole
loc = [41  16  -30] % Right temporal pole

assert(strcmp(SPM.xCon(this_contrast).name,this_contrast_name),'The contrast numbering isn''t as expected')

design_matrix = SPM.xX.X;
contrast_weighting = SPM.xCon(this_contrast).c;
all_filenames = SPM.xY.P;

all_data = nan(length(contrast_weighting),14); % 14 controls
all_y_data = nan(length(contrast_weighting),14);
for i = 1:length(contrast_weighting)
    if contrast_weighting(i)==0
        continue
    else
        these_files = all_filenames(logical(design_matrix(:,i)));
        for j = 1:length(these_files)
            this_image=spm_read_vols(spm_vol(these_files{j}));
            this_image_hdr=spm_vol(these_files{j});
            this_index=round([(loc(1)-this_image_hdr.mat(1,4))/this_image_hdr.mat(1,1); (loc(2)-this_image_hdr.mat(2,4))/this_image_hdr.mat(2,2);(loc(3)-this_image_hdr.mat(3,4))/this_image_hdr.mat(3,3)]);
            all_data(i,j) = this_image(this_index(1),this_index(2),this_index(3));
        end
        try
            y= spm_get_data(SPM.xY.P, this_index);
            all_y_data(i,1:sum(design_matrix(:,i))) = y(logical(design_matrix(:,i)));
        catch
        end
    end
end

% all_control_betas = zeros(1,14);
% all_patient_betas = zeros(1,9);
% for i = 1:14 % Now iterate through subject
%     these_data = all_data(:,i).*contrast_weighting;
%     these_subjs = these_data(~isnan(these_data));
%     all_control_betas(i) = -sum(these_subjs(1:9))/3;
%     if i<=9
%         all_patient_betas(i) = sum(these_subjs(10:18))/3;
%     end
% end
% 
% figure
% scatter(ones(1,14),all_control_betas)
% hold on
% scatter(2*ones(1,9),all_patient_betas)
% xlim([0 3])


all_control_betas = zeros(1,14);
all_patient_betas = zeros(1,8);
for i = 1:14 % Now iterate through subject
    these_data = all_y_data(:,i).*contrast_weighting;
    these_subjs = these_data(~isnan(these_data));
    if i<=8
        all_patient_betas(i) = -these_subjs(1);
        all_control_betas(i) = these_subjs(2);
    else
        all_control_betas(i) = these_subjs;
    end
end

figure
scatter(ones(1,14),all_control_betas)
hold on
scatter(2*ones(1,8),all_patient_betas)
xlim([0 3])



