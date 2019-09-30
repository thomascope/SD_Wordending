%%
%% Display source reconstructions and bar charts for each group and condition

cfg.plots = [1:2];
cfg.symmetricity = 'symmetrical';
% cfg.normalise = 1;
% cfg.threshold = [5 40];
cfg.inflate = 10;

addpath([pwd '/ojwoodford-export_fig-216b30e'])

cfg.normalise = 0;

cfg.threshold = [2.71 6]; %p=0.01

for i = 1:8
jp_spm8_surfacerender2_version_tc(['/imaging/tc02/SD_Wordending/preprocess/VBM_stats/factorial_single_subject/patient_' num2str(i) '/thresh.nii'],'jet',cfg)
savepath = ['./VBM/botfron_subject_' num2str(i)];
eval(['export_fig ' savepath '.png -transparent -m2.5'])
%close all
end

%Now NB: Set breakpoint on line 276: v = spm_mesh_project_jp(rend, dat);  
% to ensure that the viewpoint and axis size are
%appropriate for another view:
%
ax = axes('position', [.05 .1 .45 .6], 'visible', 'off');
myview = [0 -90]; % bottom
Then
ax = axes('position', [.47 .1 .45 .6], 'visible', 'off');
myview = [0 90]; % top
%jp_spm8_surfacerender2_version_tc(['/imaging/tc02/SD_Wordending/preprocess/VBM_stats/factorial_full_group_vbm_TIVnormalised_agecovaried_unsmoothedmask/Thresholded_VBM.nii'],'jet',cfg)
%savepath = ['./VBM/cluster_thresholded_topbot_VBM'];
%eval(['export_fig ' savepath '.png -transparent -m2.5'])
%close all
    
