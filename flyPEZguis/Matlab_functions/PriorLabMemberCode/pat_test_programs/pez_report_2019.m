repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(repositoryDir,'Support_Programs'))
base_path = 'Z:\Data_pez3000';

date_list = struct2dataset(dir(base_path));                                              %list of folders in Data_pez3000 dir
date_list = date_list(cellfun(@(x) length(x) == 8,date_list.name),:);                    %only date folders
date_list = date_list(cellfun(@(x) str2double(x) >= 20190601 & str2double(x) <  20191001,date_list.name),:).name;    %list of dates run between june 1st 2019


date_results = cell(length(date_list),2);

for iterZ = 1:length(date_list)
    date_results(iterZ,1) = date_list(iterZ);
    run_info = struct2dataset(dir(fullfile(base_path,date_list{iterZ})));
    run_info = run_info(cellfun(@(x) contains(x,'run'),run_info.name),:).name;            %list of runs for a given day
    run_info(cellfun(@(x) contains(x,'error'),run_info)) = [];            %list of runs for a given day
    all_exptInfo = [];
    trigger_count = zeros(length(run_info),1);
    multi_error_count = zeros(length(run_info),1);
    stim_error_count = zeros(length(run_info),1);
    video_count = zeros(length(run_info),1);
    vid_time_stamp = zeros(length(run_info),1);
    incubator_name_list = cell(length(run_info),1);
    exp_id = cell(length(run_info),1);
    
    for iterR = 1:length(run_info)
        exptInfo = load([base_path, filesep, date_list{iterZ}, filesep, run_info{iterR},filesep ,run_info{iterR},'_experimentIDinfo.mat']);
        try
            incubator_name = exptInfo.exptInfo.Incubator_Info.Name; 
            
            incubator_name_list(iterR) = {incubator_name};
            exp_id(iterR) = get(exptInfo.exptInfo,'ObsNames');
        catch
             incubator_name_list(iterR) = {'No Videos'};
             exp_id(iterR) = {0};
        end
        runStats = load([base_path, filesep, date_list{iterZ}, filesep, run_info{iterR},filesep ,run_info{iterR},'_runStatistics']);
        runStats = runStats.runStats;        

        try
            trigger_list = load(fullfile(base_path, date_list{iterZ}, run_info{iterR}, 'inspectionResults', [run_info{iterR} '_autoAnalysisResults.mat']));
            trigger_list = trigger_list.autoResults;                
            trigger_count(iterR) = size(trigger_list,1);
        
            multi_error_count(iterR) = sum(trigger_list.empty_count | trigger_list.multi_count);
            stim_error_count(iterR) = sum(cellfun(@(x) ~strcmp(x,'good photodiode'),trigger_list.diode_decision));
            stim_error_count(iterR) = stim_error_count(iterR) - sum(cellfun(@(x) isempty(x),trigger_list.diode_decision));        
        catch  %no triggers found for this experiment
            trigger_count(iterR) = 0;            
            multi_error_count(iterR) = 0;
            stim_error_count(iterR) = 0;
        end
        
        video_info = struct2dataset(dir(fullfile(base_path, date_list{iterZ}, run_info{iterR})));
        video_info = video_info(cellfun(@(x) contains(x,'run'),video_info.name),:);
        video_info = video_info(cellfun(@(x) contains(x,'.mp4'),video_info.name),:);
        
        video_count(iterR) = size(video_info.name,1);
        
        if (trigger_count(iterR) - (multi_error_count(iterR) + stim_error_count(iterR))) ~= video_count(iterR)
            warning('mis match')
        end
            
        try
            time_stamp = datevec(datenum(runStats.time_start));
            vid_time_stamp(iterR) = time_stamp(:,4) + time_stamp(:,5)/60;
        catch
            time_stamp = datevec(datenum(runStats.time_stop));
            vid_time_stamp(iterR) = time_stamp(:,4) + time_stamp(:,5)/60;
        end
    end
    trigger_info = [trigger_count,multi_error_count,stim_error_count,video_count];
    date_results(iterZ,2) = {[run_info,exp_id,num2cell(trigger_info),incubator_name_list,num2cell(vid_time_stamp)]};
    cleanup_logic = cell2mat(cellfun(@(x) cellfun(@(y) length(y) < 16,  x(:,2)) ,date_results(iterZ,2),'UniformOutput',false));
    date_results(iterZ,2) = cellfun(@(x) x(~cleanup_logic,:),date_results(iterZ,2),'UniformOutput',false); 
end
%%
summary_list = date_results(:,2);
summary_list = vertcat(summary_list{:});
%summary_list(:,5) = cellfun(@(x) regexprep(x,'Project Technical Resources #3','Darwin Incubator :: #BB'),summary_list(:,5),'UniformOutput',false);

dates_run = unique(cellfun(@(x) x(16:23),summary_list(:,1),'UniformOutput',false));

download_per_day = arrayfun(@(x) sum(cell2mat(summary_list(ismember(cellfun(@(y) y(16:23),summary_list(:,1),'UniformOutput',false),x),6))),dates_run);

[f] = histc(download_per_day,0:100:1500);
f = f ./ sum(f);
figure; bar(0:100:1500,f);
set(gca,'fontsize',16,'Xlim',[-50 1450])
xlabel('Total Videos Downloaded','fontsize',16);
ylabel('Percent Of Total Runs','fontsize',16)


[f] = hist(cellfun(@(x) length(x),date_results(:,2)),0:5:100);
f = f ./ sum(f);
figure; bar(0:5:100,f);

set(gca,'fontsize',16,'Xlim',[0 100])
xlabel('Pez Runs Per Day','fontsize',16);
ylabel('Percent Of Total Days','fontsize',16)
%%
exp_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
exp_list = exp_list(cellfun(@(x) length(x) == 16, exp_list.name),:).name;
exp_list = exp_list(cellfun(@(x) str2double(x(1:4)) >= 171, exp_list));


% load_files = summary_list(cell2mat(summary_list(:,3)) > 0,2);
% collect_list = cellfun(@(x) str2double(x(1:4)),load_files);
% remove_collect = collect_list == 144 | collect_list == 206 | collect_list == 211;
% load_files(remove_collect) = [];
load_files = exp_list;
load_files = unique(load_files);

steps = length(load_files);
%%
combine_data = [];

parfor iterZ = 1:steps
    test_data =  Experiment_ID(load_files{iterZ});
    test_data.temp_range = [22.5,24.5];
    test_data.humidity_cut_off = 40;
    test_data.remove_low = false;
    test_data.low_count = 0;
    test_data.azi_off = 180;
    test_data.ignore_graph_table = true;

    try
        test_data.load_data;
        test_data.make_tables;
    catch               
        warning('no data to load');
        disp(load_files{iterZ});
    end
    combine_data = [combine_data;test_data];                             
end       
no_data_index = arrayfun(@(x) isempty(combine_data(x).video_table),1:1:length(combine_data));
combine_data(no_data_index,:) = [];
clc

steps = length(combine_data);
for iterZ = 1:steps
    try
        combine_data(iterZ).get_tracking_data;
    catch
        combine_data(iterZ).fill_blank_track;        
    end
end 
clc
for iterZ = 1:steps
    combine_data(iterZ).display_data
    if size(combine_data(iterZ).Complete_usuable_data,2) == 47
        combine_data(iterZ).make_blank_entries('Complete_usuable_data');
    end    
    if size(combine_data(iterZ).Bad_Tracking,2) == 47
        combine_data(iterZ).make_blank_entries('Bad_Tracking');
    end        
    if size(combine_data(iterZ).Vid_Not_Tracked,2) == 47
        combine_data(iterZ).make_blank_entries('Vid_Not_Tracked');
    end    
end 
clc
%%

summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
pez_errors = [vertcat(combine_data(:).Pez_Issues);vertcat(combine_data(:).Multi_Blank);vertcat(combine_data(:).Balancer_Wings);vertcat(combine_data(:).Failed_Location)];
tracking_errors = [vertcat(combine_data(:).Bad_Tracking);vertcat(combine_data(:).Vid_Not_Tracked)];

summary_table = summary_table(cellfun(@(x) str2double(x(16:23)) >= 20190601 & str2double(x(16:23)) <= 20190930,summary_table.Properties.RowNames),:);
pez_errors = pez_errors(cellfun(@(x) str2double(x(16:23)) >= 20190601 & str2double(x(16:23)) <= 20190930,pez_errors.Properties.RowNames),:);
tracking_errors = tracking_errors(cellfun(@(x) str2double(x(16:23)) >= 20190601 & str2double(x(16:23)) <= 20190930,tracking_errors.Properties.RowNames),:);

all_data_combined = [summary_table.Properties.RowNames;pez_errors.Properties.RowNames;tracking_errors.Properties.RowNames];


