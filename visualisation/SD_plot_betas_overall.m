%A function for plotting two spm files against each other over time, with a
%t contrast for thresholding
%(assumes a -500 to 1500ms window, with 250Hz sampling)
%Suggested inputs:
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[-47,8],'MEGCOMB')
%Plot the activity at the point of maximum group activity in combined
%gradiometers for Match-Mismatch
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[-38,34],'EEG')
%Point of maximum combined in EEG (anterior)
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[-26,14],'EEG')
%EEG (posterior)
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[-42,29],'MEGMAG')
%MEGMAG (left anterior)
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[42,34],'MEGMAG')
%MEGMAG (right anterior)
%plot_betas([1:6],[-1 1 -1 1 -1 1],{'T_0017','T_0018'},22,[-38,-41],'MEGMAG')
%MEGMAG (left posterior)

function SD_plot_betas_overall(modality,varargin)
hold on

contrast_labels = {'Sum all standard onsets';'Sum all D deviant onsets';'Sum all T deviant onsets';'Sum all onsets';'Sum all offsets'; 'Onset_D-S'; 'Onset_Dd-S'; 'Onset_Dt-S'; 'Onset_Dd-Dt'; 'Offset_D-S'; 'Offset_Dd-S'; 'Offset_Dt-S'; 'Offset_Dd-Dt'; 'Play-Tray'; 'Play-Qway'; 'Tray-Qway'};

%for this_word = 1:16
for this_word = 14;
    
    data{1} = spm_eeg_load('/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/meg08_0252/controls_weighted_grandmean.mat');
data{2} = spm_eeg_load('/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/meg09_0183/patients_weighted_grandmean.mat');

controltoplot = rms(data{1}(data{1}.selectchannels(modality),:,this_word));

figure

plot(-500:4:1500,controltoplot,'g','LineWidth',4)

hold on

patienttoplot = rms(data{2}(data{2}.selectchannels(modality),:,this_word));


plot(-500:4:1500,patienttoplot,'r','LineWidth',4)

plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k')
xlim([-100 900])

xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB') || strcmp(modality,'MEGPLANAR')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

title(['RMS Overall ' modality ' Power for ' contrast_labels{this_word}],'fontsize',20)
legend({'Controls','Patients'})

contrastnumber = this_word

for i = 1:length(varargin)
H(varargin{i}(1)+500:varargin{i}(2)+500) = 1;
end
H = downsample(H,4);
jbfill(-500:4:1500,patienttoplot,zeros(1,length(patienttoplot)),H,'k','k',[],0.3);

save_string = ['./Significant_peaks/RMS Overall ' modality ' Power for' contrast_labels{this_word} '.pdf'];
% eval(['export_fig ''' save_string ''' -transparent'])


%timewindow = input('\nPlease input a two element vector of milliseconds to plot the topographies for each group\n');

figHandles = findobj('Type','axes');
% for i = 1:length(varargin)
%     fieldtrip_topoplot_highlight(varargin{i},contrastnumber,[],modality)
%     scales(:,i) = caxis;
% end

figHandles2 = findobj('Type','axes');
newfigHandles = setdiff(figHandles2,figHandles);
for i = 1:length(newfigHandles)
    caxis(newfigHandles(i),[min(min(scales)) max(max(scales))])
end

end

%Now finish with Wd-NonWd
  
    data{1} = spm_eeg_load('/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/meg08_0252/controls_weighted_grandmean.mat');
    data{2} = spm_eeg_load('/imaging/mlr/users/tc02/SD_Wordending/preprocess/2016/meg09_0183/patients_weighted_grandmean.mat');

controltoplot = rms(rms(data{1}(data{1}.selectchannels(modality),:,15:16),3));

figure

plot(-500:4:1500,controltoplot,'g','LineWidth',4)

hold on

patienttoplot = rms(rms(data{2}(data{2}.selectchannels(modality),:,15:16),3));


plot(-500:4:1500,patienttoplot,'r','LineWidth',4)

plot(-500:4:1500,zeros(1,length([-500:4:1500])),'k')
xlim([-100 900])

xlabel('ms','fontsize',20)
if strcmp(modality,'MEGCOMB') || strcmp(modality,'MEGPLANAR')
    ylabel('fT/mm','fontsize',20)
elseif strcmp(modality,'MEGMAG')
    ylabel('fT','fontsize',20)
elseif strcmp(modality,'EEG')
    ylabel('uV','fontsize',20)
end
set(gca,'fontsize',20)

title(['RMS Overall ' modality ' Power for Word-NonWord'],'fontsize',20)
legend({'Controls','Patients'})

contrastnumber = 17

for i = 1:length(varargin)
H(varargin{i}(1)+500:varargin{i}(2)+500) = 1;
end
H = downsample(H,4);
jbfill(-500:4:1500,patienttoplot,zeros(1,length(patienttoplot)),H,'k','k',[],0.3);

save_string = ['./Significant_peaks/RMS Overall ' modality ' Power for Word-NonWord.pdf'];
% eval(['export_fig ''' save_string ''' -transparent'])


%timewindow = input('\nPlease input a two element vector of milliseconds to plot the topographies for each group\n');

figHandles = findobj('Type','axes');
% for i = 1:length(varargin)
%     fieldtrip_topoplot_highlight(varargin{i},contrastnumber,[],modality)
%     scales(:,i) = caxis;
% end

figHandles2 = findobj('Type','axes');
newfigHandles = setdiff(figHandles2,figHandles);
for i = 1:length(newfigHandles)
    caxis(newfigHandles(i),[min(min(scales)) max(max(scales))])
end
