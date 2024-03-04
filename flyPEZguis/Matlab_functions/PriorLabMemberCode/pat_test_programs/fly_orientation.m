file_dir = 'Z:\Data_pez3000';
res_path = 'Z:\Data_pez3000_analyzed';
asses_filter = {'Data_Acquisition','Fly_Count','Gender','Balancer','Physical_Condition','Analysis_Status','Fly_Detect_Accuracy','NIDAQ','Raw_Data_Decision','Adjusted_ROI'};
vid_filter = {'fly_detect_azimuth','frame_width','frame_height'};

file_path = struct2dataset(dir(file_dir));
date_list = file_path(cellfun(@(x) ~isnan(str2double(x)),file_path.name),:).name;
date_list = date_list(str2double(date_list) > 20170600);

All_vidStats = [];
exp_id_list = [];
for iterZ = 1:length(date_list);
    run_list = [file_dir filesep date_list{iterZ}];
    run_list = struct2dataset(dir(run_list));
    run_list = run_list(cellfun(@(x) ~isempty(strfind(x,'run')),run_list.name),:).name;
    if ~isempty(run_list)
        for iterR = 1:length(run_list)
            try
                vidStats = load([file_dir filesep date_list{iterZ} filesep run_list{iterR} filesep run_list{iterR} '_videoStatistics']);
                vidStats = vidStats.vidStats(:,vid_filter); 
                vidStats = vidStats(cellfun(@(x) length(x) == 52,get(vidStats,'ObsNames')),:);
            catch
%                warning('failed to load vid stats');
                continue
            end
            try
                All_vidStats = [All_vidStats;vidStats];
            catch
                warning('unable to add experiment to list');
                continue
            end
            try
                exp_id_list = [exp_id_list;cellfun(@(x) x(29:44),get(vidStats,'ObsNames'),'uniformoutput',false)];
            catch
                 warning('index error');
                continue
            end
        end
    end
end
%%
org_fly_pos = All_vidStats.fly_detect_azimuth;
org_fly_pos = org_fly_pos  + 360;
org_fly_pos = rem(rem(org_fly_pos,360)+360,360);

logic_1 = org_fly_pos >=0 & org_fly_pos <= 15;
logic_2 = org_fly_pos >=345 & org_fly_pos <= 360;
logic_3 = org_fly_pos >=165 & org_fly_pos <= 195;

logic_4 = cellfun(@(x) str2double(x(1:4)) > 50,exp_id_list);
filt_id_list = exp_id_list((logic_1 | logic_2 | logic_3) & logic_4);

filt_id_list = unique(filt_id_list);
filt_id_list = filt_id_list(cellfun(@(x) str2double(x(1:4)) > 50,filt_id_list));
filt_vid_stats = All_vidStats((logic_1 | logic_2 | logic_3) & logic_4,:);
%%
all_raw_data = [];
parfor iterZ = 1:length(filt_id_list)    
    raw_data = load([res_path filesep filt_id_list{iterZ} filesep filt_id_list{iterZ} '_rawDataAssessment.mat']);                                
    raw_data = raw_data.assessTable(:,asses_filter);
    all_raw_data = [all_raw_data;raw_data];
end
%%
[locA,locB] = ismember(get(filt_vid_stats,'ObsNames'),all_raw_data.Properties.RowNames);
filt_raw_data = all_raw_data(locB(locA),:);
filt_raw_data = filt_raw_data(strcmp(filt_raw_data.Raw_Data_Decision,'Pass'),:);
filt_raw_data = filt_raw_data(strcmp(filt_raw_data.Fly_Count,'Single'),:);
filt_raw_data = filt_raw_data(strcmp(filt_raw_data.Balancer,'None'),:);
filt_raw_data = filt_raw_data(strcmp(filt_raw_data.Physical_Condition,'Good'),:);
filt_raw_data = filt_raw_data(strcmp(filt_raw_data.Fly_Detect_Accuracy,'Good'),:);
%%
[locA,locB] = ismember(get(filt_vid_stats,'ObsNames'),filt_raw_data.Properties.RowNames);
filt_raw_data = filt_raw_data(locB(locA),:);
filt_vid_stats = filt_vid_stats(locA,:);
%%
combo_data = [filt_raw_data,dataset2table(filt_vid_stats)];
run_list = combo_data.Properties.RowNames;
date_list = cellfun(@(x) str2double(x(16:23)),run_list);
for iterZ = 1:height(combo_data)
   run_id = cellfun(@(x) sprintf('%s',x(1:23)),run_list(iterZ),'uniformoutput',false);
   trigger_id = cellfun(@(x) sprintf('%s_triggerFrame%s.tif',x(1:23),x(49:52)),run_list(iterZ),'uniformoutput',false);
   trigger_folder = [file_dir filesep num2str(date_list(iterZ)) filesep run_id{1} filesep 'triggerFrames'];
   try
        copyfile([trigger_folder filesep trigger_id{1}],['Z:\Sideview_Trigger_Images' filesep trigger_id{1}])
   catch
       waring('mistake')
   end
end



