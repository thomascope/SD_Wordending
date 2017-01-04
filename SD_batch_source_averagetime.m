function SD_batch_source_averagetime(val)

if val == 4 || val == 10 || val == 14 %there is no 4th inverse at the minute!
    return
end

%% Average source images across time-windows
%es_batch_init;
SD_subjects_and_parameters
pathstem = '/imaging/tc02/SD_Wordending/preprocess/final_ICA/';

%%

%TEC's groups:
% 1 = MSPgroup with prior locations based on Sohoglu, 2 = MSPgroup without prior for symmetry, 3 = MSPgroup (planar only), 5 = LORgroup 35-950ms (all modalities), 6 = LORgroup
% 35-950ms (MEGPLANAR only), 7 = LORgroup 35-950ms (EEG only), 8 = LORgroup 35-950ms (BOTH MEG only)

time_windows = [90 130; 180 240; 270 420; 450 700; 750 900];
          
imagetype = {
    ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t90_130_f1_40*'];
    ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t180_240_f1_40*'];
    ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t270_420_f1_40*'];
    ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t450_700_f1_40*'];
    ['fmcfbdeMrun_play_raw_ssst_' num2str(val) '_t750_900_f1_40*'];
    };
imagetype_split = {
    ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t90_130_f1_40*'];
    ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t180_240_f1_40*'];
    ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t270_420_f1_40*'];
    ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t450_700_f1_40*'];
    ['fmcfbdeMrun_play_1_raw_ssst_' num2str(val) '_t750_900_f1_40*'];
    };
    
%outputstem = '/imaging/es03/P3E1/sourceimages2_averagetime/'; 
outputstem = ['/imaging/tc02/SD_Wordending/preprocess/final_ICA/source/reconstruction_' num2str(val) '/']; 

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
cnt = 0;

cnt = cnt + 1;
contrasts{cnt}.name = 'Sum all onsets(All)';
contrasts{cnt}.c =  kron([1 1],[1, 1, 1, 0, 0, 0]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Sum all onsets(All)';
contrasts{cnt}.c =  kron([-1 1],[1, 1, 1, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Sum all onsets(All)';
contrasts{cnt}.c =  kron([1 -1],[1, 1, 1, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Sum all offsets(All)';
contrasts{cnt}.c =  kron([1 1],[0, 0, 0, 1, 1, 1]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Sum all offsets(All)';
contrasts{cnt}.c =  kron([-1 1],[0, 0, 0, 1, 1, 1]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Sum all offsets(All)';
contrasts{cnt}.c =  kron([1 -1],[0, 0, 0, 1, 1, 1]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Onset_D-S(All)';
contrasts{cnt}.c =  kron([1 1],[-1, 0.5, 0.5, 0, 0, 0]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Onset_D-S(All)';
contrasts{cnt}.c =  kron([-1 1],[-1, 0.5, 0.5, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Onset_D-S(All)';
contrasts{cnt}.c =  kron([1 -1],[-1, 0.5, 0.5, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_D-S(All)';
contrasts{cnt}.c =  kron([1 1],[0, 0, 0, -1, 0.5, 0.5]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_D-S(All)';
contrasts{cnt}.c =  kron([-1 1],[0, 0, 0, -1, 0.5, 0.5]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_D-S(All)';
contrasts{cnt}.c =  kron([1 -1],[0, 0, 0, -1, 0.5, 0.5]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Onset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([1 1],[0, 1, -1, 0, 0, 0]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Onset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([-1 1],[0, 1, -1, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Onset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([1 -1],[0, 1, -1, 0, 0, 0]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Offset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([1 1],[0, 0, 0, 0, 1, -1]);
contrasts{cnt}.type = 'F';

cnt = cnt + 1;
contrasts{cnt}.name = 'Pattop Group x Offset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([-1 1],[0, 0, 0, 0, 1, -1]);
contrasts{cnt}.type = 'T';

cnt = cnt + 1;
contrasts{cnt}.name = 'Contop Group x Offset_Dd-Dt(All)';
contrasts{cnt}.c =  kron([1 -1],[0, 0, 0, 0, 1, -1]);
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
