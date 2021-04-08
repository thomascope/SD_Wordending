%% Initialise path and subject definitions

addpath('/group/language/data/thomascope/SD_Wordending')
SD_subjects_and_parameters; 
pathstem = '/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/';

rmpath(genpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/'))
addpath /imaging/local/software/spm_cbu_svn/releases/spm12_fil_r6906
spm eeg

hasallpostmerge_conditions = logical([1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     0     0     1     1     1     1]);
subjectstoinclude = subjects(hasallpostmerge_conditions);

postmerge_conditions_despaced = postmerge_conditions;
for i = 1:length(postmerge_conditions_despaced)
    postmerge_conditions_despaced{i}(postmerge_conditions_despaced{i}==' ') = '';
end
% 
% postmerge_conditions = {'Standard_onset fbdeMrun_play_raw_ssst' 'Standard_onset fbdeMrun_tray_raw_ssst' 'Standard_onset fbdeMrun_qway_raw_ssst' 'Deviant_D_onset fbdeMrun_play_raw_ssst'  'Deviant_D_onset fbdeMrun_tray_raw_ssst' 'Deviant_D_onset fbdeMrun_qway_raw_ssst' 'Deviant_T_onset fbdeMrun_play_raw_ssst'  'Deviant_T_onset fbdeMrun_tray_raw_ssst' 'Deviant_T_onset fbdeMrun_qway_raw_ssst' 'Standard_offset fbdeMrun_play_raw_ssst'  'Standard_offset fbdeMrun_tray_raw_ssst' 'Standard_offset fbdeMrun_qway_raw_ssst' 'Deviant_D_offset fbdeMrun_play_raw_ssst'  'Deviant_D_offset fbdeMrun_tray_raw_ssst' 'Deviant_D_offset fbdeMrun_qway_raw_ssst' 'Deviant_T_offset fbdeMrun_play_raw_ssst'  'Deviant_T_offset fbdeMrun_tray_raw_ssst' 'Deviant_T_offset fbdeMrun_qway_raw_ssst'};
% 
% contrast_labels = {'Sum all postmerge_conditions';'Match-MisMatch'; 'Clear minus Unclear'; 'Gradient difference M-MM'};
% contrast_weights = [1, 1, 1, 1, 1, 1; -1, -1, 1, -1, 1, 1; -1, -1, 0, 0, 1, 1; -1, 1, 0, 0, 1, -1];    
%% Configure

filetype = 'PfmcfbdeMrun_play_raw_ssst';
filetypesplit = 'PfmcfbdeMrun_play_1_raw_ssst';
modality = {'MEGCOMB' 'MEGMAG'};
imagetype = {'sm_'};
p.windows = [-100 600; -100 900; 50,70; 140 180; 240 280];

outputstem = '/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/stats_2018_1';

%mskname = '/imaging/local/spm/spm8/apriori/grey.nii'; % specify in modality loop below if multiple modalities are being estimated. Don't specify if not needed

% Contrasts (don't specify if not needed)
cnt = 0;

%% Contrasts (Combined SPM for patients/controls)

cnt = cnt + 1;
contrasts{cnt}.name = 'Sum all standard onsets(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Sum all standard onsets';
contrasts{cnt}.c =  kron([-1 1],kron([1, 0, 0, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Sum all standard onsets';
contrasts{cnt}.c =  kron([1 -1],kron([1, 0, 0, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Sum all standard ofsets(All)';
contrasts{cnt}.c =  kron([1 1],kron([0, 0, 0, 1, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Sum all standard offsets';
contrasts{cnt}.c =  kron([-1 1],kron([0, 0, 0, 1, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Sum all standard offsets';
contrasts{cnt}.c =  kron([1 -1],kron([0, 0, 0, 1, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Onset_D-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ -1, 0.5, 0.5, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Onset_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ -1, 0.5, 0.5, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Onset_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ -1, 0.5, 0.5, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Onset_D-S';
contrasts{cnt}.c =  kron([-1 1],kron([ -1, 0.5, 0.5, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Onset_D-S';
contrasts{cnt}.c =  kron([1 -1],kron([ -1, 0.5, 0.5, 0, 0, 0],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_D-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_D-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, 0, 1, -1],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Dd-Dt(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, 0, 1, -1],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Dd-Dt(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, 0, 1, -1],[1,1,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Dd-Dt';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, 0, 1, -1],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Dd-Dt';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, 0, 1, -1],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Tray(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Tray(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Tray(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Play-Tray';
contrasts{cnt}.c =  kron([-1 1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Play-Tray';
contrasts{cnt}.c =  kron([1 -1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Play-Qway';
contrasts{cnt}.c =  kron([-1 1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Play-Qway';
contrasts{cnt}.c =  kron([1 -1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Tray-Qway';
contrasts{cnt}.c =  kron([-1 1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Tray-Qway';
contrasts{cnt}.c =  kron([1 -1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Three way interaction (group vs word/nonwd vs ending offset)';
contrasts{cnt}.c =  kron([-1 1],kron([0, 0, 0, -1, 0.5, 0.5],[0.5,0.5,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Three way';
contrasts{cnt}.c =  kron([-1 1],kron([0, 0, 0, -1, 0.5, 0.5],[0.5,0.5,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Three way';
contrasts{cnt}.c =  kron([1 -1],kron([0, 0, 0, -1, 0.5, 0.5],[0.5,0.5,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_D-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Play_D-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Play_D-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_D-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Tray_D-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Tray_D-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_D-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Qway_D-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Qway_D-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0.5, 0.5],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 1, 0],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 1, 0],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 1, 0],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Play_DD-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 1, 0],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Play_DD-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 1, 0],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 1, 0],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 1, 0],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 1, 0],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Tray_DD-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 1, 0],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Tray_DD-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 1, 0],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 1, 0],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 1, 0],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 1, 0],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Qway_DD-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 1, 0],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Qway_DD-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 1, 0],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DT-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0, 1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DT-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0, 1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DT-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0, 1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Play_DT-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0, 1],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Play_DT-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0, 1],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DT-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0, 1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DT-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0, 1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DT-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0, 1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Tray_DT-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0, 1],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Tray_DT-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0, 1],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DT-S(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, -1, 0, 1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DT-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0, 1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DT-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0, 1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Qway_DT-S';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, -1, 0, 1],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Qway_DT-S';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, -1, 0, 1],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-DT(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, 0, 1, -1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-DT(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, 0, 1, -1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Play_DD-DT(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, 0, 1, -1],[1,0,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Play_DD-DT';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, 0, 1, -1],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Play_DD-DT';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, 0, 1, -1],[1,0,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-DT(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, 0, 1, -1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-DT(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, 0, 1, -1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Tray_DD-DT(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, 0, 1, -1],[0,1,0]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Tray_DD-DT';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, 0, 1, -1],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Tray_DD-DT';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, 0, 1, -1],[0,1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-DT(All)';
contrasts{cnt}.c =  kron([1 1],kron([ 0, 0, 0, 0, 1, -1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-DT(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, 0, 1, -1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Qway_DD-DT(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, 0, 1, -1],[0,0,1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Qway_DD-DT';
contrasts{cnt}.c =  kron([-1 1],kron([ 0, 0, 0, 0, 1, -1],[0,0,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Qway_DD-DT';
contrasts{cnt}.c =  kron([1 -1],kron([ 0, 0, 0, 0, 1, -1],[0,0,1]));
contrasts{cnt}.type = 'T';


%% Estimate models


%for img=1:length(imagetype)
img = 1;
for wind = 1:length(p.windows)
    for m=1:length(modality)
    %for m = 3
        files = {};
        % set input files for averaging
        controls2average = {};
        patients2average = {};
        controls2rejecteeg = {};
        patients2rejecteeg= {};
        for s=1:size(subjectstoinclude,2) % for multiple subjects
            
            fprintf([ '\n\nCurrent subject = ' subjectstoinclude{s} '...\n\n' ]);
            
            if group(s) == 1
                fprintf([ '\nIdentified as a control. \n' ]);
                controls2average{end+1} = subjectstoinclude{s};
                try
                    controls2rejecteeg{end+1} = rejecteeg{s};
                catch
                    controls2rejecteeg{end+1} = 0; %If undefined
                end
                               
            elseif group(s) == 2
                fprintf([ '\nIdentified as a patient. \n' ]);
                patients2average{end+1} = subjectstoinclude{s};
                try
                patients2rejecteeg{end+1} = rejecteeg{s};
                catch
                    patients2rejecteeg{end+1} = 0; %If undefined
                end
               
            end
            
        end
        
        for groups = 1:2
            if groups == 1
                
                outputfullpath = [outputstem imagetype{img} '/controls_' num2str(p.windows(wind,1)) '_' num2str(p.windows(wind,2)) '_' modality{m}];
                if ~exist(outputfullpath)
                    mkdir(outputfullpath);
                end
                
                for s=1:length(controls2average) % specify file locations for batch_spm_anova_vES
                    
                    for c=1:length(postmerge_conditions_despaced)
                        if strcmp(modality{m},'EEG')
                            if controls2rejecteeg{s} == 1
                                %files{1}{s}{c} = [];
                            else
                                files{1}{s}{c} = strjoin([pathstem controls2average{s} '/' modality{m} filetype '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                                if exist(files{1}{s}{c},'file')
                                else
                                    files{1}{s}{c} = strjoin([pathstem controls2average{s} '/' modality{m} filetypesplit '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                                end
                            end
                            
                        else
                            files{1}{s}{c} = strjoin([pathstem controls2average{s} '/' modality{m} filetype '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                            if exist(files{1}{s}{c},'file')
                            else
                                files{1}{s}{c} = strjoin([pathstem controls2average{s} '/' modality{m} filetypesplit '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                            end
                        end
                    end
                    
                end
                
                
%                 % set up input structure for batch_spm_anova_vES
%                 S.imgfiles = files{1}{:}{:};
%                 S.outdir = outputfullpath;
%                 S.uUFp = 1; % for M/EEG only
%                 %S.nsph_flag = 0;
%                 %mskname = [pathstem modality{m} '_mask_0_800ms.img'];
%                 if exist('mskname'); S.maskimg = mskname; end;
%                 if exist('contrasts'); S.contrasts = contrasts; end;
%                 if exist('covariates'); S.user_regs = covariates; end;
%                 
%                 % estimate model and compute contrasts
%                 batch_spm_anova_es(S);
                
                
            elseif groups == 2
                
                outputfullpath = [outputstem imagetype{img} '/patients_' num2str(p.windows(wind,1)) '_' num2str(p.windows(wind,2)) '_' modality{m}];
                if ~exist(outputfullpath)
                    mkdir(outputfullpath);
                end
                
                for s=1:length(patients2average) % specify file locations for batch_spm_anova_vES
                    
                    for c=1:length(postmerge_conditions_despaced)
                        
                        if strcmp(modality{m},'EEG')
                            if patients2rejecteeg{s} == 1
                                %files{2}{s}{c} = [];
                            else
                                files{2}{s}{c} = strjoin([pathstem patients2average{s} '/' modality{m} filetype '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                                if exist(files{2}{s}{c},'file')
                                else
                                    files{2}{s}{c} = strjoin([pathstem patients2average{s} '/' modality{m} filetypesplit '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                                end
                            end
                        else
                            files{2}{s}{c} = strjoin([pathstem patients2average{s} '/' modality{m} filetype '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                            if exist(files{2}{s}{c},'file')
                            else
                                files{2}{s}{c} = strjoin([pathstem patients2average{s} '/' modality{m} filetypesplit '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
                            end
                        end
                        
                    end
                    
                end
                
                
%                 % set up input structure for batch_spm_anova_vES
%                 S.imgfiles = files{2}{:}{:};
%                 S.outdir = outputfullpath;
%                 S.uUFp = 1; % for M/EEG only
%                 %S.nsph_flag = 0;
%                 %mskname = [pathstem modality{m} '_mask_0_800ms.img'];
%                 if exist('mskname'); S.maskimg = mskname; end;
%                 if exist('contrasts'); S.contrasts = contrasts; end;
%                 if exist('covariates'); S.user_regs = covariates; end;
%                 
%                 % estimate model and compute contrasts
%                 batch_spm_anova_es(S);

            end
        end
        
        
        
%         outputfullpath = [outputstem imagetype{img} '/' modality{m}];
%         if ~exist(outputfullpath)
%             mkdir(outputfullpath);
%         end
%         
%         for s=1:length(subjectstoinclude) % specify file locations for batch_spm_anova_vES
%             
%             for c=1:length(postmerge_conditions_despaced)
%                 
%                 files{1}{s}{c} = strjoin([pathstem subjectstoinclude{s} '/' modality{m} filetype '/' imagetype 'condition_' postmerge_conditions_despaced{c} '.nii'],'');
%                 
%             end
%             
%         end
            
            
        % set up input structure for batch_spm_anova_vES
        files{1} = files{1}(~cellfun(@isempty,files{1}));
        files{2} = files{2}(~cellfun(@isempty,files{2}));
        S.imgfiles = files;
        outputfullpath = [outputstem imagetype{img} '/combined_' num2str(p.windows(wind,1)) '_' num2str(p.windows(wind,2)) '_' modality{m}];
        S.outdir = outputfullpath;
        S.uUFp = 1; % for M/EEG only
        %S.nsph_flag = 0;
        if strncmp(modality{m},'time_',5)
            %mskname = [pathstem modality{m}(6:end)
            %'_1D_mask_0_800ms.img']; No need for mask - images created
            %with restricted time window
        else            
            mskname = [pathstem modality{m} sprintf(['_mask_%d_%dms.img'],p.windows(wind,1),p.windows(wind,2))];
            %mskname = [pathstem modality{m} '_mask_-100_800ms.img'];
        end
        if exist('mskname'); S.maskimg = mskname; end;
        if exist('contrasts'); S.contrasts = contrasts; end;
        if exist('covariates'); S.user_regs = covariates; end;
        
        % estimate model and compute contrasts
        batch_spm_anova_es(S);
           
    end
end
%end
