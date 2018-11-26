function convert_waveform_pdf(varargin)

if isempty(varargin)
    allfiles = dir;
    allfilenames = {};
    for i = 1:length(allfiles)
        if strfind(lower(allfiles(i).name),'.wav')
        allfilenames{end+1} = allfiles(i).name;
        end
    end
else
    allfilenames = varargin;
end

for i = 1:length(allfilenames)
[thisdata, fs] = wavread(allfilenames{i});
x = 1:length(thisdata);
x = x/fs;
thisfig = figure;
plot(x,thisdata,'k')
xlim([0 0.5])
ylim([-1 1])
save_string = ['./' allfilenames{i}(1:end-4) '.pdf'];
eval(['export_fig ''' save_string ''' -transparent'])
close(thisfig)
end