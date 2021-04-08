% List of open inputs
nrun = 25; % enter the number of runs here
jobfile = {'/group/language/data/thomascope/SD_Wordending/SD_template_batch_forwardmodel_job_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);

%% Define inputs

meglist = {   
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0252/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0259/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0260/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0264/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0265/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0266/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0292/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0293/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0295/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0307/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0311/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0330/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0338/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg08_0462/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg09_0183/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg09_0185/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg09_0186/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg09_0228/fmcfbdeMrun_play_1_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg10_0026/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg10_0314/fmcfbdeMrun_play_1_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg12_0208/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg12_0261/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg12_0262/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg12_0359/fmcfbdeMrun_play_raw_ssst.mat'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/final_ICA/meg12_0404/fmcfbdeMrun_play_raw_ssst.mat'};
                                          
mrilist = { 
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0252/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0259/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0260/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0264/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0265/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0266/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0292/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0293/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0295/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0307/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0311/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0330/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0338/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg08_0462/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg09_0183/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg09_0185/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg09_0186/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg09_0228/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg10_0026/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg10_0314/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg12_0208/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg12_0261/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg12_0262/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg12_0359/structural/structural.nii'
                                              '/imaging/mlr/users/tc02/SD_Wordending/preprocess/meg12_0404/structural/structural.nii'};
                                          
for crun = 1:nrun
    inputs{1, crun} = cellstr(meglist{crun}); % Head model specification: M/EEG datasets - cfg_files
%     inputs{2, crun} = cellstr(mrilist{crun}); % Head model specification: Individual structural image - cfg_files
end


%% Now compute the forwards model based on template structural images
forwardmodelworkedcorrectly = zeros(1,nrun);
jobs = repmat(jobfile, 1, 1);

parfor crun = 1:nrun
    spm('defaults', 'EEG');
    spm_jobman('initcfg')
    try
        spm_jobman('run', jobs, inputs{:,crun});
        forwardmodelworkedcorrectly(crun) = 1;
    catch
        forwardmodelworkedcorrectly(crun) = 0;
    end
end