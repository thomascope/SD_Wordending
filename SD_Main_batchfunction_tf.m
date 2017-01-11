% This is a MEG/EEG preprocessing pipeline developed by Thomas Cope, based on a
% pipeline developed by Ed Sohoglu
%
% It assumes that you have already maxfiltered your data and created a
% trialDef file for each run containing the trial definitions (place these
% appropriately in each folder). I include an example python script to do
% this (you will need to change the paths etc).
%
% Before running, make sure that you have specified the parameters properly
% in this file, in the subjects_and_parameters script, and set the search terms in SD_Preprocessing_mainfunction
% You will also need to move the bundled es_montage_all, tec_montage_all
% and MEGArtifactTemplateTopographies files to your pathstem folder.
% 
% Prerequisites:
% 
% A version of EEGLAB new enough to have the FileIO toolbox (the stock CBU version does not have this; I use 13_3_2b http://sccn.ucsd.edu/eeglab/downloadtoolbox.html )
% NB: You need to set the path to this in the SD_Preprocessing_mainfunction case 'ICA_artifacts'
% The ADJUST toolbox for EEGLAB: (http://www.unicog.org/pm/pmwiki.php/MEG/RemovingArtifactsWithADJUST )
% 
%
% E-mail any questions to tec31@cam.ac.uk



%% Set up global variables

SD_subjects_and_parameters; 
pathstem = '/imaging/tc02/SD_Wordending/preprocess/2016_tf/';
source_directory = '/imaging/tc02/SD_Wordending/preprocess/2016/';


%% Specify preprocessing parameters

%p.mod = {'MEG'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
%p.mod = {'MEGPLANAR'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
%p.mod = {'EEG'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
p.mod = {'MEGMAG' 'MEGPLANAR'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps) NB: EEG MUST ALWAYS BE LISTED LAST!!
%p.mod = {'Source'};
p.ref_chans = {'EOG061','EOG062'}; %Reference channels in your montage in order horizEOG vertEOG ECG (NB: IF YOURS ARE DIFFERENT TO {'EOG061','EOG062','ECG063'} YOU WILL NEED TO MODIFY THE MONTAGE)

% cell array of experimental conditions (used by 'definetrials','convert+epoch' and 'sort' steps)
p.conditions = conditions;

%p.montage_fname = 'es_montage_MEG.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
%p.montage_fname = 'es_montage_MEGPLANAR.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
%p.montage_fname = 'es_montage_EEG.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
% You need to set up some montages with and without the reference
% channels, and put them in the pathstem folder.
p.montage_fname = 'es_montage_all.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
p.montage_rerefname = 'tec_montage_all.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)

p.fs = 1000; % original sample rate
p.fs_new = 250; % sample rate after downsampling in SPM (currently assumes that maxfilter HASN't downsampled data)

% for trial definitions
p.preEpoch = -500; % pre stimulus time (ms)
p.postEpoch = 1500; % post stimulus time (ms)
p.triggers = [1 2 3]; % trigger values (correspond to p.conditions specified above)
p.minduration = 500; % if using definetrials_jp, minimum duration of a trial (ms)
p.maxduration = 1150; % if using definetrials_jp, maximum duration of a trial (ms)
%p.stimuli_list_fname = 'stimuli_list.txt';

% for robust averaging
p.robust = 1;

% for baseline correction
p.preBase = -100; % pre baseline time (ms)
p.postBase = 0; % post baseline time (ms)

% for combining planar gradiometer data
p.correctPlanar = 0; % whether to baseline correct planar gradiometer data after RMSing (using baseline period specified in preBase and postBase)

% for filtering 
p.filter = 'low'; % type of filter (lowpass or highpass)- never bandpass!
p.freq = 90; % filter cutoff (Hz)
%p.filter = 'high'; % type of filter (lowpass or highpass)- never bandpass!
%p.freq = 0.5; % filter cutoff (Hz)
%p.filter = 'stop';
%p.freq = [48 52];

% for computing contrasts of grand averaged MEEG data
p.contrast_labels = contrast_labels;
p.contrast_weights = contrast_weights;

% for image smoothing
p.xSmooth = 10; % smooth for x dimension (mm)
p.ySmooth = 10; % smooth for y dimension (mm)
p.zSmooth = 10; % smooth for z (time) dimension (ms)

% for making image mask
p.preImageMask = -100; % pre image time (ms)
p.postImageMask = 950; % post image time (ms)

% time windows over which to average for 'first-level' contrasts (ms)
p.windows = [50,70;140 180;240 280];

% set groups to input
p.group = group;

% set time frequency decomposition parameters
%p.method = 'mtmconvol'; p.freqs = [30:2:90]; p.timeres = 200; p.timestep = 20; p.freqres = 30;
p.freqs = [4:2:80]; %Vector of frequencies of interest
p.method = 'morlet'; %method
p.ncycles = 7; %number of wavelet cycles
p.phase = 1; %save phase information too? (prefixed with tph)
p.tf_chans = 'All'; %cell array of channel names. Can include generic wildcards: 'All', 'EEG', 'MEG' etc.
p.timewin = [-500 1500]; %time window of interest
p.preBase_tf = -100; %TF baseline correct period with below (I don't know why this isn't a two element vector - don't blame me.)
p.postBase_tf = 0;
p.tf.method = 'LogR'; %'LogR', 'Diff', 'Rel', 'Log', 'Sqrt', 'None'
p.tf.subsample = 5; %subsample by a factor of 5 - mainly to save disk space and speed up subsequent processing. Without this, produced a file of 20-40Gb for each subject!

%% Event-related preprocessing steps

% note: should high-pass filter or baseline-correct before lowpass fitering
% to avoid ringing artefacts

memoryrequired = num2str(8*size(subjects,2));

try
    workerpool = cbupool(size(subjects,2));
    workerpool.ResourceTemplate=['-l nodes=^N^,mem=' memoryrequired 'GB,walltime=48:00:00'];
    matlabpool(workerpool)
catch
    fprintf([ '\n\nUnable to open up a cluster worker pool - opening a local cluster instead' ]);
    matlabpool(12)
end
parfor cnt = 1:size(subjects,2)
    Preprocessing_mainfunction('ICA_artifacts_copy','ICA_artifacts',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt,dates,blocksin,blocksout,rawpathstem, badeeg, badchannels, source_directory)
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('downsample','ICA_artifacts_copy',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
% parfor cnt = 1:size(subjects,2)
%     SD_Preprocessing_mainfunction('rereference','downsample',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
% end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('baseline','downsample',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end

parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('filter','baseline',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end

%to filter at 50Hz too.
p.filter = 'stop';
p.freq = [48 52];
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('filter','filter',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
   SD_Preprocessing_mainfunction('epoch','secondfilter',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt,dates,blocksin,blocksout,rawpathstem, badeeg);
end
p.filestring_length = 4; %Specify that filenames are the first 4 unique letters and anything after this denotes a repeat (e.g. tray vs tray_1)
p.blocksout = blocksout;
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('merge_recoded','epoch',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
p.conditions = postmerge_conditions_tf;
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('sort','merge',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('average','merge',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('filter','average',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2) 
    SD_Preprocessing_mainfunction('combineplanar','fmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end

Preprocessing_mainfunction('grand_average','pfmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects);
% This saves the grand unweighted average file for each group in the folder of the
% first member of that group. For convenience, you might want to move them
% to separate folders.


hasallconditions = zeros(1,size(subjects,2));
parfor cnt = 1:size(subjects,2)    
    try %Some participants didn't do all conditions, so can't be weighted with pre-specified contrasts.
   SD_Preprocessing_mainfunction('weight','pfmcfbdeMr*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
   hasallconditions(cnt) = 1;
    catch
    end
end

Preprocessing_mainfunction('grand_average','wpfmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects(logical(hasallconditions)));
% This saves the grand weighted average file for each group in the folder of the
% first member of that group. For convenience, you might want to move them
% to separate folders.
parfor cnt = 1:size(subjects,2)
    warning('off','MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId') %Suppress the warning about duplicate datapoints. This is caused by having two gradiometers at each location. For evoked data, this warning is valid as they should be rms combined, but for induced data it shouldn't make a difference and saves a step.
    SD_Preprocessing_mainfunction('image','fmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    % The input for smoothing should be the same as the input used to make
    % the image files.
    SD_Preprocessing_mainfunction('smooth','fmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
for cnt = 1
    % The input for smoothing should be the same as the input used to make
    % the image files. Only need to do this for a single subject
    SD_Preprocessing_mainfunction('mask','fmceffbdMr*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end  

% now, if you want to simplify, you can move all of the smoothed nifti images into folders marked
% controls/patients, either manually or with copyniftitofolder.py (you will
% need to change the paths and search characteristics appropriately).
% Alternatively, you can use recursive search in your analysis scripts

%Time frequency analysis
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('TF','merge',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('average','TF_power',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
p.robust = 0; %robust averaging doesn't work for phase data
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('average','TF_phase',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
p.robust = 1; % just in case we want to do any more averaging later
%TF_rescale to baseline correct the induced power data only
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('TF_rescale','mtf_c*dMrun*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
Preprocessing_mainfunction('grand_average','TF_rescale',p,pathstem, maxfilteredpathstem, subjects);
hasallconditions = zeros(1,size(subjects,2));
parfor cnt = 1:size(subjects,2)    
    try %Some participants didn't do all conditions, so can't be weighted with pre-specified contrasts.
   SD_Preprocessing_mainfunction('weight','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
   hasallconditions(cnt) = 1;
    catch
    end
end
Preprocessing_mainfunction('grand_average','wrmtf_c*.mat',p,pathstem, maxfilteredpathstem, subjects(logical(hasallconditions)));
parfor cnt = 1:size(subjects,2)
    warning('off','MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId') %Suppress the warning about duplicate datapoints. This is caused by having two gradiometers at each location. For evoked data, this warning is valid as they should be rms combined, but for induced data it shouldn't make a difference and saves a step.
    SD_Preprocessing_mainfunction('image','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    % The input for smoothing should be the same as the input used to make
    % the image files.
    SD_Preprocessing_mainfunction('smooth','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
for cnt = 1
    % The input for smoothing should be the same as the input used to make
    % the image files. Only need to do this for a single subject
    SD_Preprocessing_mainfunction('mask','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end

%Now to do the higher frequencies with multitapers! - If you want to do
%this, you must copy the merged files, to another folder appended with '_taper' and re-run from
%the appropriate step above
% 
pathstem = [pathstem(1:end-1) '_taper/'] ; 
p.method = 'mtmconvol'; 
p.freqs = [30:2:90]; 
p.timeres = 200; 
p.timestep = 20; 
p.freqres = 10; 
source_directory = '/imaging/tc02/SD_Wordending/preprocess/2016_tf/';


parfor cnt = 1:size(subjects,2)
    Preprocessing_mainfunction('ICA_artifacts_copy','merge',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt,dates,blocksin,blocksout,rawpathstem, badeeg, badchannels, source_directory)
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('TF','merge',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('average','TF_power',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
% p.robust = 0; %robust averaging doesn't work for phase data
% parfor cnt = 1:size(subjects,2)
%     Preprocessing_mainfunction('average','TF_phase',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
% end
% p.robust = 1; % just in case we want to do any more averaging later
%TF_rescale to baseline correct the induced power data only
parfor cnt = 1:size(subjects,2)
    SD_Preprocessing_mainfunction('TF_rescale','mtf_c*dMrun*.mat',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
SD_Preprocessing_mainfunction('grand_average','TF_rescale',p,pathstem, maxfilteredpathstem, subjects);
hasallconditions = zeros(1,size(subjects,2));
parfor cnt = 1:size(subjects,2)    
    try %Some participants didn't do all conditions, so can't be weighted with pre-specified contrasts.
   SD_Preprocessing_mainfunction('weight','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
   hasallconditions(cnt) = 1;
    catch
    end
end
Preprocessing_mainfunction('grand_average','wrmtf_c*.mat',p,pathstem, maxfilteredpathstem, subjects(logical(hasallconditions)));
parfor cnt = 1:size(subjects,2)
    warning('off','MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId') %Suppress the warning about duplicate datapoints. This is caused by having two gradiometers at each location. For evoked data, this warning is valid as they should be rms combined, but for induced data it shouldn't make a difference and saves a step.
    SD_Preprocessing_mainfunction('image','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
parfor cnt = 1:size(subjects,2)
    % The input for smoothing should be the same as the input used to make
    % the image files.
    SD_Preprocessing_mainfunction('smooth','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end
for cnt = 1
    % The input for smoothing should be the same as the input used to make
    % the image files. Only need to do this for a single subject
    SD_Preprocessing_mainfunction('mask','TF_rescale',p,pathstem, maxfilteredpathstem, subjects{cnt},cnt);
end

