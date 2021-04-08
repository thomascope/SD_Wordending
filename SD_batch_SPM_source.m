function SD_batch_SPM_source(val)

addpath('/group/language/data/thomascope/SD_Wordending')
SD_subjects_and_parameters;

hasallpostmerge_conditions = logical([1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     0     0     1     1     1     1]);
subjectstoinclude = subjects(hasallpostmerge_conditions);

subjectstoexclude = subjects(~hasallpostmerge_conditions);

rmpath(genpath('/imaging/local/software/spm_cbu_svn/releases/spm12_latest/'))
addpath /imaging/local/software/spm_cbu_svn/releases/spm12_fil_r6906
spm eeg

postmerge_conditions_despaced = postmerge_conditions;
for i = 1:length(postmerge_conditions_despaced)
    postmerge_conditions_despaced{i}(postmerge_conditions_despaced{i}==' ') = '';
end
conditions = postmerge_conditions_despaced;

if val == 4 || val == 10 || val == 14 %there is no 4th inverse at the minute!
    return
end

%% Average source images across time-windows
%es_batch_init;

pathstem = '/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/';

for i = subjectstoexclude %Exclude every mention of this subject ;)
    group(~cellfun('isempty',regexpi(subjects,i))) = [];
    dates(~cellfun('isempty',regexpi(subjects,i))) = [];
    badeeg(~cellfun('isempty',regexpi(subjects,i))) = [];
    badchannels(~cellfun('isempty',regexpi(subjects,i)),:) = [];
    blocksin(~cellfun('isempty',regexpi(subjects,i))) = [];
    blocksout(~cellfun('isempty',regexpi(subjects,i))) = [];
    subjects(~cellfun('isempty',regexpi(subjects,i))) = [];
end

%%

%TEC's groups:
% 1 = MSPgroup with prior locations based on Sohoglu, 2 = MSPgroup without prior for symmetry, 3 = MSPgroup (planar only), 5 = LORgroup 35-950ms (all modalities), 6 = LORgroup
% 35-950ms (MEGPLANAR only), 7 = LORgroup 35-950ms (EEG only), 8 = LORgroup 35-950ms (BOTH MEG only)

time_windows = [-100 600; -100 900; 50,70; 140 180; 240 280];
imagetype = {
        ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t-100_600_f1_40*'];
        ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t-100_900_f1_40*'];
        ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t50_70_f1_40*'];
        ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t140_180_f1_40*'];
        ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t240_280_f1_40*'];
        };

imagetype_split = {
        ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t-100_600_f1_40*'];
        ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t-100_900_f1_40*'];
        ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t50_70_f1_40*'];
        ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t140_180_f1_40*'];
        ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t240_280_f1_40*'];
        };
%outputstem = '/imaging/es03/P3E1/sourceimages2_averagetime/'; 
outputstem = ['/imaging/mlr/users/tc02/SD_Wordending/preprocess/2018/stats_source_2/reconstruction_' num2str(val) '/']; 

for s=1:length(subjects)
    
    currentstem = [pathstem subjects{s} '/Source/'];
    
    if ~exist([outputstem subjects{s} '/'])
        mkdir([outputstem subjects{s} '/']);
    end
    
    for con=1:length(conditions)
        
        for im=1:length(imagetype)
            
            if ~exist([outputstem subjects{s} '/' num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/'])
                mkdir([outputstem subjects{s} '/' num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/']);
            end
            
            file = dir([currentstem imagetype{im} '_' num2str(con) '.nii']);
            if size(file,1) == 0
                file = dir([currentstem imagetype_split{im} '_' num2str(con) '.nii']);
            end
            Vi = spm_vol([currentstem file.name]);
            img_data = spm_read_vols(Vi);
            img_data_all(:,:,:,im) = img_data;
            
            %Save each timewindow individually
            Vo = Vi(1);
            Vo.fname = [outputstem subjects{s} '/' num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/' conditions{con} '.nii'];
            spm_write_vol(Vo,img_data);
            
        end
        
        img_data_avg = mean(img_data_all,4);
        Vo = Vi(1);
        Vo.fname = [outputstem subjects{s} '/' conditions{con} '.nii'];
        spm_write_vol(Vo,img_data_avg);
        
    end
    
end

%% Estimate SPM model

% inputstem = '/imaging/es03/P3E1/sourceimages2_averagetime/';
% outputstem = '/imaging/es03/P3E1/stats2_source_averagetime/';
inputstem = outputstem;
outputstem = [inputstem 'stats/'];
%mskname = [];
mskname = '/imaging/local/spm/spm8/apriori/grey.nii'; % set to [] if not needed

% Contrasts
clear contrasts
% Contrasts (don't specify if not needed)
cnt = 0;

%% Contrasts (Combined SPM for patients/controls)
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Sum all standard onsets(All)';
% contrasts{cnt}.c =  kron([1 1],[1, 0, 0, 0, 0, 0]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Pattop Group x Sum all standard onsets';
% contrasts{cnt}.c =  kron([-1 1],[1, 0, 0, 0, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Contop Group x Sum all standard onsets';
% contrasts{cnt}.c =  kron([1 -1],[1, 0, 0, 0, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Sum all standard ofsets(All)';
% contrasts{cnt}.c =  kron([1 1],[0, 0, 0, 1, 0, 0]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Pattop Group x Sum all standard offsets';
% contrasts{cnt}.c =  kron([-1 1],[0, 0, 0, 1, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Contop Group x Sum all standard offsets';
% contrasts{cnt}.c =  kron([1 -1],[0, 0, 0, 1, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Onset_D-S(All)';
% contrasts{cnt}.c =  kron([1 1],[ -1, 0.5, 0.5, 0, 0, 0]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Onset_D-S(Controls)';
% contrasts{cnt}.c =  kron([1 0],[ -1, 0.5, 0.5, 0, 0, 0]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Onset_D-S(Patients)';
% contrasts{cnt}.c =  kron([0 1],[ -1, 0.5, 0.5, 0, 0, 0]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Pattop Group x Onset_D-S';
% contrasts{cnt}.c =  kron([-1 1],[ -1, 0.5, 0.5, 0, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Contop Group x Onset_D-S';
% contrasts{cnt}.c =  kron([1 -1],[ -1, 0.5, 0.5, 0, 0, 0]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_D-S(All)';
% contrasts{cnt}.c =  kron([1 1],[ 0, 0, 0, -1, 0.5, 0.5]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_D-S(Controls)';
% contrasts{cnt}.c =  kron([1 0],[ 0, 0, 0, -1, 0.5, 0.5]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_D-S(Patients)';
% contrasts{cnt}.c =  kron([0 1],[ 0, 0, 0, -1, 0.5, 0.5]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Pattop Group x Offset_D-S';
% contrasts{cnt}.c =  kron([-1 1],[ 0, 0, 0, -1, 0.5, 0.5]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Contop Group x Offset_D-S';
% contrasts{cnt}.c =  kron([1 -1],[ 0, 0, 0, -1, 0.5, 0.5]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_Dd-Dt(All)';
% contrasts{cnt}.c =  kron([1 1],[ 0, 0, 0, 0, 1, -1]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_Dd-Dt(Controls)';
% contrasts{cnt}.c =  kron([1 0],[ 0, 0, 0, 0, 1, -1]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Offset_Dd-Dt(Patients)';
% contrasts{cnt}.c =  kron([0 1],[ 0, 0, 0, 0, 1, -1]);
% contrasts{cnt}.type = 'F';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Pattop Group x Offset_Dd-Dt';
% contrasts{cnt}.c =  kron([-1 1],[ 0, 0, 0, 0, 1, -1]);
% contrasts{cnt}.type = 'T';
% 
% cnt = cnt + 1;
% contrasts{cnt}.name = 'Contop Group x Offset_Dd-Dt';
% contrasts{cnt}.c =  kron([1 -1],[ 0, 0, 0, 0, 1, -1]);
% contrasts{cnt}.type = 'T';


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
contrasts{cnt}.name = 'Word-Nonwd(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Word-Nonwd(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Word-Nonwd(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Word-Nonwd';
contrasts{cnt}.c =  kron([-1 1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Word-Nonwd';
contrasts{cnt}.c =  kron([1 -1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
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
contrasts{cnt}.name = 'Play-Tray(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Tray(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Tray(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[1,-1,0]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Play-Qway(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[1,0,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Tray-Qway(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[0,1,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Word-Nonwd(All)';
contrasts{cnt}.c =  kron([1 1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Word-Nonwd(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Word-Nonwd(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([1, 0, 0, 0, 0, 0],[0.5,0.5,-1]));
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

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(Controls)';
contrasts{cnt}.c =  kron([1 0],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(Patients)';
contrasts{cnt}.c =  kron([0 1],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]));
contrasts{cnt}.type = 'T';


outputfullpath = outputstem;
if ~exist(outputfullpath)
    mkdir(outputfullpath);
end

% Define groups
controls2average = {};
patients2average = {};
for s=1:size(subjects,2) % for multiple subjects
    
    fprintf([ '\n\nCurrent subject = ' subjects{s} '...\n\n' ]);
    
    if group(s) == 1
        fprintf([ '\nIdentified as a control. \n' ]);
        controls2average{end+1} = subjects{s};
        
    elseif group(s) == 2
        fprintf([ '\nIdentified as a patient. \n' ]);
        patients2average{end+1} = subjects{s};
    end
    
end
  
files = {};
for s=1:length(controls2average) % specify file locations for batch_spm_anova_vES
    
    for con=1:length(conditions)
        
        files{1}{s}{con} = [inputstem controls2average{s} '/' conditions{con} '.nii'];
        
    end
    
end
for s=1:length(patients2average) % specify file locations for batch_spm_anova_vES
    
    for con=1:length(conditions)
        
        files{2}{s}{con} = [inputstem patients2average{s} '/' conditions{con} '.nii'];
        
    end
    
end
files{1} = files{1}(~cellfun(@isempty,files{1}));
files{2} = files{2}(~cellfun(@isempty,files{2}));

% set up input structure for batch_spm_anova_vES
S.imgfiles = files;
S.maskimg = mskname;
S.outdir = outputfullpath;
S.contrasts = contrasts;
S.uUFp = 1; % for M/EEG only

batch_spm_anova_version_es(S); % estimate model and compute contrasts

for im = 1:length(time_windows)
    outputfullpath = [outputstem num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/'];
    if ~exist(outputfullpath)
        mkdir(outputfullpath);
    end
    
    
    files = {};
    for s=1:length(controls2average) % specify file locations for batch_spm_anova_vES
        
        for con=1:length(conditions)
            
            files{1}{s}{con} = [inputstem controls2average{s} '/' num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/' conditions{con} '.nii'];
            
        end
        
    end
    for s=1:length(patients2average) % specify file locations for batch_spm_anova_vES
        
        for con=1:length(conditions)
            
            files{2}{s}{con} = [inputstem patients2average{s} '/' num2str(time_windows(im,1)) '_' num2str(time_windows(im,2)) '/' conditions{con} '.nii'];
            
        end
        
    end
    
    files{1} = files{1}(~cellfun(@isempty,files{1}));
    files{2} = files{2}(~cellfun(@isempty,files{2}));
    
    % set up input structure for batch_spm_anova_vES
    S.imgfiles = files;
    S.maskimg = mskname;
    S.outdir = outputfullpath;
    S.contrasts = contrasts;
    S.uUFp = 1; % for M/EEG only
    
    batch_spm_anova_version_es(S); % estimate model and compute contrasts

end

% %% Make conjunctions of pairs of t-contrasts (unthresholded)
% % This is equivalent to selecting a 'conjunction null' in the GUI
%  
% names = {'M>MM_AND_M>N.img'; % output name of first conjunction
%          'MM>M_AND_N>M.img'; % output name of second conjunction etc.
%         };         
% contrasts = {'spmT_0013.img' 'spmT_0015.img'; % first pair of contrasts to conjoin
%           'spmT_0014.img' 'spmT_0016.img'; % second pair etc.  
%          };
%          
%  for con=1:size(contrasts,1)
%          
%      Vi1 = spm_vol([outputstem '/' contrasts{con,1}]);
%      Vi2 = spm_vol([outputstem '/' contrasts{con,2}]);
%      
%      img_data1 = spm_read_vols(Vi1);
%      img_data2 = spm_read_vols(Vi2);
%      img_data1(img_data1<0) = 0; % remove negative values since this is a one-sided t-test
%      img_data2(img_data2<0) = 0;
%      
%      img_data_conj = min(img_data1,img_data2); % conjoin
%      
%      Vo = Vi1(1);
%      Vo.fname = [outputstem '/' names{con}];
%      spm_write_vol(Vo,img_data_conj);
%          
%  end
%          
