addpath('Z:\Erica\test_courtship\BatchSongAnalysis')
addpath('Z:\Erica\test_courtship\BatchSongAnalysis\chronux')
addpath('Z:\Erica\test_courtship\BatchSongAnalysis\SplitVec')  

genotype_of_interest = 'SS47120';
channel_path = 'Z:\Erica\test_courtship\activation\20171205103909_1644000G5X_out';
file_dir = dir('Z:\Erica\test_courtship\activation\20171205103909_1644000G5X_Results_LLR=0_20171205205409');
file_dir = struct2dataset(file_dir);
file_dir = file_dir(cellfun(@(x) ~isempty(strfind(x,'channel')),file_dir.name),:);

file_dir = file_dir(cellfun(@(x) ~isempty(strfind(x,genotype_of_interest)),file_dir.name),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
channel_dir = dir(channel_path);
channel_dir = struct2dataset(channel_dir);
channel_dir = channel_dir(cellfun(@(x) ~isempty(strfind(x,'channel')),channel_dir.name),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
geno_index = cellfun(@(x) strfind(x,'channel'),file_dir.name,'uniformoutput',false);
geno_index = cellfun(@(x,y) x(y:end),file_dir.name,geno_index,'uniformoutput',false);
geno_index = cellfun(@(x) x(1:strfind(x,genotype_of_interest)-2),geno_index,'uniformoutput',false);

channel_index = cellfun(@(x) strfind(x,'channel'),channel_dir.name,'uniformoutput',false);
channel_index = cellfun(@(x,y) x(y:end),channel_dir.name,channel_index,'uniformoutput',false);
channel_index = regexprep(channel_index,'.mat','');

[locA,~] = ismember(channel_index,geno_index);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load_list = channel_dir.name(locA);
%%
pulse_interval_info = csvread('Z:\Erica\test_courtship\activation\courtshiperica.txt');
pulse_header_list = arrayfun(@(x,y,z) sprintf('pulse_%2.0f_pct_%.0f_dur_%2.0f',x,y,z),(1:1:20)',pulse_interval_info(:,1),pulse_interval_info(:,2),'uniformoutput',false);

%%
dummy_load_var = load([channel_path filesep load_list{1}]);
dummy_load_var = struct2dataset(dummy_load_var);
cut_off_times = [0;cumsum(pulse_interval_info(:,2)) .*dummy_load_var.Data.fs];
%%
[Stats2Plot, AllStats] = AnalyzeChannel_parsed(dummy_load_var.Pulses,dummy_load_var.Sines,dummy_load_var.Data);
%%
figure
for iterZ = 1:20
    subplot(4,5,iterZ)
    partial_data = dummy_load_var.Data.d((cut_off_times(iterZ)+1):cut_off_times(iterZ+1));
    if cellfun(@(x) ~isempty(strfind(x,'dur_60')),pulse_header_list(iterZ))
        plot_color = rgb('black');
    else 
        plot_color = rgb('red');
    end
    
    plot(partial_data,'color',plot_color);
    set(gca,'Ylim',[-.2 .2]);    
    title(sprintf('%s',pulse_header_list{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',15);
end