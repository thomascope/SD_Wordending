%A function for plotting two spm files against each other over time, with a
%t contrast for thresholding
%(assumes a -500 to 1500ms window, with 250Hz sampling)
%SD_laterality_quotient(whichbetas,contrast,statspm,nsubj,left_location,right_location,modality,numcons,numpats,varargin)
%Suggested inputs:
%SD_laterality_quotient([1:18],kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]),{'T_0016','T_0017'},23,[-47,-9],[47,-9],'MEGCOMB',14,9)
%For deviance ending calculation


function SD_laterality_quotient(whichbetas,contrast,statspm,nsubj,left_location,right_location,modality,numcons,numpats,varargin)

addpath('/group/language/data/thomascope/vespa/SPM12version/Standalone preprocessing pipeline/tc_source_stats/ojwoodford-export_fig-216b30e')

pathstem = ['/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/stats_4sm_/combined_-100_600_' modality];

assert(length(whichbetas) == length(contrast), 'For this to work, the contrast has to completely fill the beta space')

% First load in SPM file
load([pathstem '/SPM.mat'])

% Now organise data to read in files correctly
numfiles = size(SPM.xY.P,2);
numsubjs = numfiles/length(whichbetas);
assert(numsubjs == numcons+numpats, 'Error, number of subjects does not match specified group sizes and betas')

for i = 1:numcons
    con_filenames{i} = SPM.xY.P(i:numcons:numcons*length(whichbetas));
    assert(size(con_filenames{i},2)==length(whichbetas), ['Error, wrong number of filenames for control ' num2str(i)])
end
for i = 1:numpats
    pat_filenames{i} = SPM.xY.P(numcons*length(whichbetas)+i:numpats:end);
    assert(size(pat_filenames{i},2)==length(whichbetas), ['Error, wrong number of filenames for patient ' num2str(i)])
end



% Read in data
Y_raw_con = cell(numcons,length(whichbetas));
for i = 1:numcons
    for j = 1:length(whichbetas)
        Y_raw_con{i,j} = spm_read_vols(spm_vol(con_filenames{i}{j}));
        Y_raw_con{i,j} = Y_raw_con{i,j}*contrast(j);
    end
end

Y_raw_pat = cell(numpats,length(whichbetas));
for i = 1:numpats
    for j = 1:length(whichbetas)
        Y_raw_pat{i,j} = spm_read_vols(spm_vol(pat_filenames{i}{j}));
        Y_raw_pat{i,j} = Y_raw_pat{i,j}*contrast(j);
    end
end
  
% Traditional way of reading in data - for sanity check
Y = cell(1,length(whichbetas));
for i = 1:length(whichbetas)
    if whichbetas(i) <10
        Y{i} = spm_read_vols(spm_vol([pathstem '/' 'beta_000' num2str(whichbetas(i)) '.nii']));
    else
        Y{i} = spm_read_vols(spm_vol([pathstem '/' 'beta_00' num2str(whichbetas(i)) '.nii']));
    end
end
if whichbetas(i) <10
    Y1_data = spm_vol(spm_vol([pathstem '/' 'beta_000' num2str(whichbetas(i)) '.nii']));
else
    Y1_data = spm_vol(spm_vol([pathstem '/' 'beta_00' num2str(whichbetas(i)) '.nii']));
end

if ischar(statspm)
    Y3{1}=spm_read_vols(spm_vol([pathstem '/' 'spm' statspm '.nii']));
    Y3_data{1} = spm_vol(spm_vol([pathstem '/' 'spm' statspm '.nii']));
else
    for i = 1:size(statspm,2)
        Y3{i}=spm_read_vols(spm_vol([pathstem '/' 'spm' statspm{i} '.nii']));
        Y3_data{i} = spm_vol(spm_vol([pathstem '/' 'spm' statspm{i} '.nii']));
    end
end

x_loc_l = round((left_location(1)-Y1_data.mat(1,4))/Y1_data.mat(1,1));
y_loc_l = round((left_location(2)-Y1_data.mat(2,4))/Y1_data.mat(2,2));
x_loc_r = round((right_location(1)-Y1_data.mat(1,4))/Y1_data.mat(1,1));
y_loc_r = round((right_location(2)-Y1_data.mat(2,4))/Y1_data.mat(2,2));

for i = 1:length(contrast)
    Y{i} = Y{i}*contrast(i);
end

datatoplot_l = zeros(length(contrast),size(Y{1},3));
datatoplot_r = zeros(length(contrast),size(Y{1},3));
for i = 1:size(Y{1},3)
    
    for j = 1:length(contrast)
        datatoplot_l(j,i) = Y{j}(x_loc_l,y_loc_l,i);
        datatoplot_r(j,i) = Y{j}(x_loc_r,y_loc_r,i);
    end
    
end

controltoplot_l = mean(datatoplot_l,1);
controltoplot_r = mean(datatoplot_r,1);

whichbetas = whichbetas+max(whichbetas); %Switch to patient betas, assuming listed second 


Y = cell(1,length(whichbetas));
for i = 1:length(whichbetas)
    if whichbetas(i) <10
        Y{i} = spm_read_vols(spm_vol([pathstem '/' 'beta_000' num2str(whichbetas(i)) '.nii']));
    else
        Y{i} = spm_read_vols(spm_vol([pathstem '/' 'beta_00' num2str(whichbetas(i)) '.nii']));
    end
end
if whichbetas(i) <10
    Y1_data = spm_vol(spm_vol([pathstem '/' 'beta_000' num2str(whichbetas(i)) '.nii']));
else
    Y1_data = spm_vol(spm_vol([pathstem '/' 'beta_00' num2str(whichbetas(i)) '.nii']));
end

x_loc_l = round((left_location(1)-Y1_data.mat(1,4))/Y1_data.mat(1,1));
y_loc_l = round((left_location(2)-Y1_data.mat(2,4))/Y1_data.mat(2,2));


for i = 1:length(contrast)
    Y{i} = Y{i}*contrast(i);
end

datatoplot_l = zeros(length(contrast),size(Y{1},3));
datatoplot_r = zeros(length(contrast),size(Y{1},3));
for i = 1:size(Y{1},3)
    
    for j = 1:length(contrast)
        datatoplot_l(j,i) = Y{j}(x_loc_l,y_loc_l,i);
        datatoplot_r(j,i) = Y{j}(x_loc_r,y_loc_r,i);
    end
    
end

patienttoplot_l = mean(datatoplot_l,1);
patienttoplot_r = mean(datatoplot_r,1);

figure
subplot(2,2,1)
plot(-500:4:1500,controltoplot_l,'g','LineWidth',4)
hold on
title('SPM averaged left')
plot(-500:4:1500,patienttoplot_l,'r','LineWidth',4)
plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k-')
xlim([-100 900])

threshold=tinv(0.95,(nsubj-2));
allsigs = zeros(size(squeeze(squeeze(Y3{1}(x_loc_l,y_loc_l,:)))));
for i = 1:size(Y3,2)
    H{i} = squeeze(squeeze(Y3{i}(x_loc_l,y_loc_l,:)))>threshold;
    allsigs = allsigs+H{i};

end

xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

legend({'Controls','Patients'})

pv = [allsigs' 0];
sv = [0 pv(1:(end-1))];
ev = [pv(2:end) 0];
starting = find( pv - sv >= 1 );
ending = find( pv - ev >= 1 );
times=[-500:4:1500];

figHandles = findobj('Type','axes');
if isequal(contrast,kron([1, 0, 0, 0, 0, 0],[1,1,1]))
    contrastnumber = 1; %Sum all standard onsets
elseif isequal(contrast,kron([1, 0, 0, 0, 0, 0],[1,1,0]))
    contrastnumber = 1; %Sum all standard onsets
elseif isequal(contrast,kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]))
    contrastnumber = 10; %Offset D-S
elseif isequal(contrast,kron([ 0, 0, 0, 0, 1, -1],[1,1,1]))
    contrastnumber = 13; %For Overall Power
end
    
    scales = zeros(2,length(starting));
i = 1;
for j = 1:length(starting)
    if ending(i)-starting(i) > 7 %Account for smoothing - crude cluster correction by deletings 'significance' less than 25ms duration.
        
        i = i+1;
    else
        allsigs(starting(i):ending(i)) = 0;
        starting(i) = [];
        ending(i) = [];
    end
end
jbfill(-500:4:1500,controltoplot_l,patienttoplot_l,allsigs','r','none',[],0.5);

subplot(2,2,2)
plot(-500:4:1500,controltoplot_r,'g','LineWidth',4)
hold on
title('SPM averaged right')
plot(-500:4:1500,patienttoplot_r,'r','LineWidth',4)
plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k-')
xlim([-100 900])

threshold=tinv(0.95,(nsubj-2));
allsigs = zeros(size(squeeze(squeeze(Y3{1}(x_loc_r,y_loc_r,:)))));
for i = 1:size(Y3,2)
    H{i} = squeeze(squeeze(Y3{i}(x_loc_r,y_loc_r,:)))>threshold;
    allsigs = allsigs+H{i};

end

xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

legend({'Controls','Patients'})

pv = [allsigs' 0];
sv = [0 pv(1:(end-1))];
ev = [pv(2:end) 0];
starting = find( pv - sv >= 1 );
ending = find( pv - ev >= 1 );
times=[-500:4:1500];

figHandles = findobj('Type','axes');
if isequal(contrast,kron([1, 0, 0, 0, 0, 0],[1,1,1]))
    contrastnumber = 1; %Sum all standard onsets
elseif isequal(contrast,kron([1, 0, 0, 0, 0, 0],[1,1,0]))
    contrastnumber = 1; %Sum all standard onsets
elseif isequal(contrast,kron([ 0, 0, 0, -1, 0.5, 0.5],[1,1,1]))
    contrastnumber = 10; %Offset D-S
elseif isequal(contrast,kron([ 0, 0, 0, 0, 1, -1],[1,1,1]))
    contrastnumber = 13; %For Overall Power
end
    
    scales = zeros(2,length(starting));
i = 1;
for j = 1:length(starting)
    if ending(i)-starting(i) > 7 %Account for smoothing - crude cluster correction by deletings 'significance' less than 25ms duration.
        
        i = i+1;
    else
        allsigs(starting(i):ending(i)) = 0;
        starting(i) = [];
        ending(i) = [];
    end
end
jbfill(-500:4:1500,controltoplot_r,patienttoplot_r,allsigs','r','none',[],0.5);


rawcondatatoplot_l = zeros(numcons,length(contrast),size(Y{1},3));
rawcondatatoplot_r = zeros(numcons,length(contrast),size(Y{1},3));

for k = 1:numcons %subject dimension
    for i = 1:size(Y{1},3) %Time dimension
        
        for j = 1:length(contrast) %betas dimension
            rawcondatatoplot_l(k,j,i) = Y_raw_con{k,j}(x_loc_l,y_loc_l,i);
            rawcondatatoplot_r(k,j,i) = Y_raw_con{k,j}(x_loc_r,y_loc_r,i);
        end
        
    end
end

controlrawtoplot_l = squeeze(mean(mean(rawcondatatoplot_l,2),1));
controlrawtoplot_r = squeeze(mean(mean(rawcondatatoplot_r,2),1));

rawpatdatatoplot_l = zeros(numpats,length(contrast),size(Y{1},3));
rawpatdatatoplot_r = zeros(numpats,length(contrast),size(Y{1},3));

for k = 1:numpats %subject dimension
    for i = 1:size(Y{1},3) %Time dimension
        
        for j = 1:length(contrast) %betas dimension
            rawpatdatatoplot_l(k,j,i) = Y_raw_pat{k,j}(x_loc_l,y_loc_l,i);
            rawpatdatatoplot_r(k,j,i) = Y_raw_pat{k,j}(x_loc_r,y_loc_r,i);
        end
        
    end
end

patientrawtoplot_l = squeeze(mean(mean(rawpatdatatoplot_l,2),1));
patientrawtoplot_r = squeeze(mean(mean(rawpatdatatoplot_r,2),1));

subplot(2,2,3)
plot(-500:4:1500,controlrawtoplot_l,'g','LineWidth',4)
hold on
title('Raw averaged left')
plot(-500:4:1500,patientrawtoplot_l,'r','LineWidth',4)
plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k-')
xlim([-100 900])


xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

legend({'Controls','Patients'})

subplot(2,2,4)
plot(-500:4:1500,controlrawtoplot_r,'g','LineWidth',4)
hold on
title('Raw averaged left')
plot(-500:4:1500,patientrawtoplot_r,'r','LineWidth',4)
plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k-')
xlim([-100 900])


xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

legend({'Controls','Patients'})

% If the sanity check passes, and the figures look the same, calculate
% laterality quotient at every point.
% Q = ((S_l-S_r)/(S_l+S_r))*100

for i = 1:numcons
Q_con_all(i,:) = (squeeze(((mean(rawcondatatoplot_l(i,:,:),2))-(mean(rawcondatatoplot_r(i,:,:),2))))./squeeze((abs(mean(rawcondatatoplot_l(i,:,:),2))+abs(mean(rawcondatatoplot_r(i,:,:),2)))))*100;
Q_con(i,:) = Q_con_all(i,~isnan(controltoplot_l));
end
for i = 1:numpats
Q_pat_all(i,:) = (squeeze(((mean(rawpatdatatoplot_l(i,:,:),2))-(mean(rawpatdatatoplot_r(i,:,:),2))))./squeeze((abs(mean(rawpatdatatoplot_l(i,:,:),2))+abs(mean(rawpatdatatoplot_r(i,:,:),2)))))*100;
Q_pat(i,:) = Q_pat_all(i,~isnan(controltoplot_l));
end
figure
subplot(2,1,1)
stdshade_TEC(Q_con,0.2,'g',-100:4:600,1,1)
hold on
stdshade_TEC(Q_pat,0.2,'r',-100:4:600,1,1)
plot(-100:4:600,zeros(1,length([-100:4:600])),'k-')

p_val = zeros(1,size(Q_pat,2));
h = zeros(1,size(Q_pat,2));
for samp = 1:size(Q_pat,2)
    [h(samp), pval(samp)] = ttest2(Q_con(:,samp),Q_pat(:,samp));
    [h_pat(samp), pval_pat(samp), ~, stat_pat{samp}] = ttest(Q_pat(:,samp));
    [h_con(samp), pval_con(samp), ~, stat_con{samp}] = ttest(Q_con(:,samp));
end

subplot(2,1,2)
plot(-100:4:600,pval)

%Calculate the times at which activity in each scalp location exceeds its standard deviation in the baseline
%times(abs(controltoplot_l)>std(controltoplot_l(times>=-100&times<=0))&abs(patienttoplot_l)>std(patienttoplot_l(times>=-100&times<=0))&abs(controltoplot_r)>std(controltoplot_r(times>=-100&times<=0))&abs(patienttoplot_r)>std(patienttoplot_r(times>=-100&times<=0)))

save_string = ['./Significant_peaks/laterality quotient with pval for ' modality ' at ' num2str(left_location) ' vs ' num2str(right_location) '.pdf'];
eval(['export_fig ''' save_string ''' -transparent'])

figure
stdshade_TEC(Q_con,0.2,'g',-100:4:600,1,1)
hold on
stdshade_TEC(Q_pat,0.2,'r',-100:4:600,1,1)
plot(-100:4:600,zeros(1,length([-100:4:600])),'k-')
ylim([-100 100])
  

save_string = ['./Significant_peaks/laterality quotient for ' modality ' at ' num2str(left_location) ' vs ' num2str(right_location) '.pdf'];
eval(['export_fig ''' save_string ''' -transparent'])



% 
% for i = 1:length(starting)
%     timewindow = [times(starting(i)) times(ending(i))];
%     SD_fieldtrip_topoplot_highlight(timewindow,contrastnumber,left_location,modality)
%     scales(:,i) = caxis;
% end
% figHandles2 = findobj('Type','axes');
% newfigHandles = setdiff(figHandles2,figHandles);
% for i = 1:length(newfigHandles)
%     caxis(newfigHandles(i),[min(min(scales)) max(max(scales))])
% end
% 
% %timewindow = input('\nPlease input a two element vector of milliseconds to plot the topographies for each group\n');
% 
% if isempty(varargin)
%     varargin{1} = [0 400];
% end
% for i = 1:length(varargin)
%     SD_fieldtrip_topoplot_highlight(varargin{i},contrastnumber,left_location,modality)
% end