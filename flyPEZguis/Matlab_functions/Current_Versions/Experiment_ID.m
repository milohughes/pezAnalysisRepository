classdef Experiment_ID < handle
    properties
        exp_id = [];
        temp_range = [22.5,24.5];
        humidity_cut_off = 40;
        %        azi_off = 22.5;
        azi_off = 180;
        parsed_data = [];           %parsed info for the exp id
        video_table = [];           %table of all runs for experiment

        Complete_usuable_data = []; %all useable data
        %        Unusable_data = [];
        Multi_Blank = [];           %multi/blank fly videos
        Pez_Issues = [];            %temp and nidaq issue
        Balancer_Wings = [];        %balancer and wing issues

        Failed_Location = [];       %Orgional position is off
        Vid_Not_Tracked = [];       %video not tracked but passed other filters
        Bad_Tracking = [];          %Tracking is off by alot
        Out_Of_Range = [];          %For looming stimuli more then azi off away from stim requested

        Videos_Need_To_Work = [];   %data to annotate

        all_triggers = [];
        total_counts = [];          %summary of counts

        analysis_path = '\\locker-smb.engram.rc.zi.columbia.edu\card-locker\hhmiData\dm11\cardlab\Data_pez3000_analyzed';
        %        remove_low = true;
        remove_low = false;
        low_count = 5;
        stim_type = 'loom';
        ignore_graph_table = false;
        %        ignore_graph_table = false;
        filter_toggle = 'on';
    end
    properties (Constant,Hidden)
        parsed_filter = {'ParentA_name','ParentA_ID','ParentB_name','ParentB_ID','Males','Females','Name','Food_Type','Foiled','Stimuli_Type','Photo_Activation',...
            'Elevation','Azimuth','Stimuli_Delay','Photo_Delay'};
        auto_filter = {'jumpTest','autoFrameOfTakeoff','visStimProtocol','visStimFrameStart','visStimFrameCount','photoStimProtocol','photoStimFrameStart','photoStimFrameCount'};
        manual_filter = {'frame_of_wing_movement','frame_of_leg_push','wing_down_stroke','frame_of_take_off'};

        %        graph_filter = {'autoJumpTest','autoFot','trkEnd','stimStart','zeroFly_XYZT_fac1000','relPosition_FB_LR_T_fac1000','rawFly_XYZT_atFrmOne','flyLength','mm_per_pixel','zeroFly_StimAtStimStart','zeroFly_StimAtFrmOne','timestamp','temp_degC','humidity','IRlights'};
        graph_filter = {'manual_wingup_wingdwn_legpush','stimStart_flyTheta','autoJumpTest','autoFot','trkEnd','stimStart','zeroFly_XYZT_fac1000','relPosition_FB_LR_T_fac1000','rawFly_XYZT_atFrmOne','flyLength','mm_per_pixel','zeroFly_StimAtStimStart','zeroFly_StimAtFrmOne','timestamp','IRlights','zeroFly_Jump','flipBool'};
        graph_filter_v2 = {'manual_wingup_wingdwn_legpush','stimStart_flyTheta','autoJumpTest','autoFot','trkEnd','stimStart','zeroFly_XYZT_fac1000','relPosition_FB_LR_T_fac1000','rawFly_XYZT_atFrmOne','flyLength','mm_per_pixel','zeroFly_StimAtStimStart','zeroFly_StimAtFrmOne','zeroFly_Jump','flipBool'};
        graph_filter_v3 = {'manual_wingup_wingdwn_legpush','autoJumpTest','autoFot','trkEnd','stimStart','zeroFly_XYZT_fac1000','relPosition_FB_LR_T_fac1000','rawFly_XYZT_atFrmOne','flyLength','mm_per_pixel','zeroFly_StimAtStimStart','zeroFly_StimAtFrmOne','zeroFly_Jump','flipBool'};
        asses_filter = {'Data_Acquisition','Fly_Count','Gender','Balancer','Physical_Condition','Analysis_Status','Fly_Detect_Accuracy','NIDAQ','Raw_Data_Decision','Adjusted_ROI'};
        vid_filter = {'trigger_timestamp','fly_detect_azimuth','visual_stimulus_info','photoactivation_info','supplement_frame_reference','cutrate10th_frame_reference','frame_count','temp_degC','humidity_percent','record_rate'};

        tracked_filter = {'XYZ_3D_filt','top_points_and_thetas','bot_points_and_thetas','final_frame_tracked','stimulus_azimuth','departure_az_ele_rad'};
        locate_filter = {'center_point','tracking_point','fly_length','tracking_hort','fly_theta'};
        trk_filter = {'mvmnt_ref','range_trk','change_trk'};
        trigger_filter = {'single_count','empty_count','multi_count','diode_decision'};


        table_header = {'Vials_Run','Total_Videos','Pez_Issues','Multi_Blank','Balancers','Failed_Location','Vid_Not_Tracked','Bad_Tracking','Out_Of_Range',...
            'Need_To_Annotate','Usuable_Complete'};
    end
    methods
        function add_pathing(obj)
            repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
            addpath(fullfile(repositoryDir,'Support_Programs'))
            op_sys = system_dependent('getos');
            if contains(op_sys,'Microsoft Windows')
                obj.analysis_path = [filesep filesep 'dm11' filesep 'cardlab' filesep 'Data_pez3000_analyzed'];
            else
                obj.analysis_path = [filesep 'Volumes' filesep 'cardlab' filesep 'Data_pez3000_analyzed'];
            end

        end
        function parse_data(obj)
            try
                obj.parsed_data = parse_expid_v2(obj.exp_id);
            catch
                obj.add_pathing
                obj.parsed_data = parse_expid_v2(obj.exp_id);
            end
            try
                stim_info = [struct2dataset(obj.parsed_data.Incubator_Info),struct2dataset(obj.parsed_data.Stimuli_Vars),struct2dataset(obj.parsed_data.Photo_Vars)];
            catch
                warning('what happened');
            end

            stim_info.Stimuli_Delay = str2double(stim_info.Stimuli_Delay);
            stim_info.Photo_Delay = str2double(stim_info.Photo_Delay);
            switch stim_info.Temperature
                case '16.C'
                    stim_info.Temperature = '16.0 C';
                case '16.0C'
                    stim_info.Temperature = '16.0 C';
                case '21.5C'
                    stim_info.Temperature = '21.5 C';
                case '21.8C'
                    stim_info.Temperature = '21.8 C';
                case '25C'
                    stim_info.Temperature = '25.0 C';
                case '25 C'
                    stim_info.Temperature = '25.0 C';
                case '25.0C'
                    stim_info.Temperature = '25.0 C';
            end
            if ischar(stim_info.Location)
                stim_info.Location = {stim_info.Location};
            end
            if ischar(stim_info.Name)
                stim_info.Location = {stim_info.Name};
            end

            obj.parsed_data = [obj.parsed_data,stim_info];
            obj.parsed_data.Azimuth = {obj.parsed_data.Azimuth};
            obj.parsed_data.Elevation = {obj.parsed_data.Elevation};
            obj.parsed_data.Name = {obj.parsed_data.Name};

            %            obj.parsed_data = obj.parsed_data(:,obj.parsed_filter);
            if strcmp(obj.parsed_data.Stimuli_Type,'None')
                obj.stim_type = 'Chrimson';
            end
        end
        function load_annotations(obj)
            auto_annotations = load([obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_automatedAnnotations']);
            auto_annotations = auto_annotations.automatedAnnotations(:,obj.auto_filter);

            manual_annotations = load([obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_manualAnnotations']);

            videoStats = load([obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_videoStatisticsMerged']);

            val_count = zeros(length(get(videoStats.videoStatisticsMerged,'ObsNames')),1);
            flip_count = zeros(length(get(videoStats.videoStatisticsMerged,'ObsNames')),1);
            if strcmp(obj.parsed_data.Stimuli_Type,'None')
            elseif cellfun(@(x) contains(x,'whiteonwhite'),obj.parsed_data.Stimuli_Type)
            else
                nidaq_data = cellfun(@(x) x.nidaq_data,videoStats.videoStatisticsMerged.visual_stimulus_info,'uniformoutput',false);
                test_count = length(nidaq_data);
                keep_logic = arrayfun(@(y) sum(cellfun(@(x) contains(x,'peakPos'),fieldnames(videoStats.videoStatisticsMerged.visual_stimulus_info{y}))) == 1,1:test_count)';

                peakPos = cellfun(@(x) x.peakPos,videoStats.videoStatisticsMerged(keep_logic,:).visual_stimulus_info,'uniformoutput',false);
                peak_min(keep_logic) = cellfun(@(x) min(x), peakPos);
                peak_min(~keep_logic) = 0;

                val = cellfun(@(x,y) x(y-8), nidaq_data(keep_logic & peak_min' > 10),peakPos(peak_min(keep_logic)' > 10),'uniformoutput',false);
                val_count(peak_min > 10) = cellfun(@(x) sum(x > (double(max(x))-5)), val);
                flip_count(peak_min > 10) = cellfun(@(x) length(x), peakPos(peak_min(keep_logic)' > 10));
            end
            if strcmp(obj.filter_toggle,'on')
                videoStats = dataset2table(videoStats.videoStatisticsMerged(:,obj.vid_filter));
            else
                videoStats = dataset2table(videoStats.videoStatisticsMerged);
            end
            error_logic = val_count < flip_count;

            try
                stim_azimuth = cellfun(@(x) x.azimuth,videoStats.visual_stimulus_info);
                stim_azimuth = stim_azimuth.*pi/180;
            catch
                stim_azimuth = zeros(height(videoStats),1);
            end

            combo_data = [val_count,flip_count,error_logic,stim_azimuth];
            combo_data = cell2table(num2cell(combo_data));
            combo_data.Properties.RowNames = videoStats.Properties.RowNames;
            combo_data.Properties.VariableNames = [{'Val_Count'},{'Flip_Count'},{'Error_logic'},{'VidStat_Stim_Azi'}];

            videoStats = [videoStats,combo_data];

            raw_data = load([obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_rawDataAssessment.mat']);
            if strcmp(obj.filter_toggle,'on')
                raw_data = raw_data.assessTable(:,obj.asses_filter);
                manual_annotations = manual_annotations.manualAnnotations(:,obj.manual_filter);
            else
                raw_data = raw_data.assessTable;
                manual_annotations = manual_annotations.manualAnnotations;
            end



            exp_list_m = manual_annotations.Properties.RowNames;
            exp_list_a = auto_annotations.Properties.RowNames;
            exp_list_r = raw_data.Properties.RowNames;

            [~,min_idx] = min([length(exp_list_m);length(exp_list_a);length(exp_list_r)]);
            if min_idx == 1
                exp_list = exp_list_m;
            elseif min_idx == 2
                exp_list = exp_list_a;
            elseif min_idx == 3
                exp_list = exp_list_r;
            end

            graph_path = [obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_dataForVisualization.mat'];
            if obj.ignore_graph_table == 1
                obj.Complete_usuable_data = [manual_annotations(exp_list,:),auto_annotations(exp_list,:),videoStats(exp_list,:),raw_data(exp_list,:)];
            elseif ~exist(graph_path,'file')
                obj.Complete_usuable_data = [manual_annotations(exp_list,:),auto_annotations(exp_list,:),videoStats(exp_list,:),raw_data(exp_list,:)];
            else
                graph_data = load([obj.analysis_path filesep obj.exp_id filesep obj.exp_id '_dataForVisualization.mat']);
                if strcmp(obj.filter_toggle,'on')
                    try
                        graph_data = graph_data.graphTable(:,obj.graph_filter);
                    catch
                        graph_data = graph_data.graphTable(:,obj.graph_filter_v3);
                    end
                else
                    graph_data = graph_data.graphTable;
                end

                missing_ids = exp_list(~ismember(exp_list,graph_data.Properties.RowNames));
                numeric_entry = sum(cell2mat(table2cell(varfun(@(x) isnumeric(x), graph_data))));
                cell_entry = sum(cell2mat(table2cell(varfun(@(x) iscell(x), graph_data))));
                logical_entry = sum(cell2mat(table2cell(varfun(@(x) islogical(x), graph_data))));

                numeric_table = array2table(zeros(length(missing_ids),numeric_entry));
                cell_table = cell2table(cell(length(missing_ids),cell_entry));
                logic_table = array2table(false(length(missing_ids),logical_entry));

                cell_table.Properties.RowNames = missing_ids;
                cell_table.Properties.VariableNames = graph_data.Properties.VariableNames(cell2mat(table2cell(varfun(@(x) iscell(x), graph_data))));

                numeric_table.Properties.RowNames = missing_ids;
                numeric_table.Properties.VariableNames = graph_data.Properties.VariableNames(cell2mat(table2cell(varfun(@(x) isnumeric(x), graph_data))));

                logic_table.Properties.RowNames = missing_ids;
                logic_table.Properties.VariableNames = graph_data.Properties.VariableNames(cell2mat(table2cell(varfun(@(x) islogical(x), graph_data))));

                missing_table = [numeric_table,cell_table,logic_table];
                [~,locB]= ismember(graph_data.Properties.VariableNames,missing_table.Properties.VariableNames);
                missing_table = missing_table(:,locB);

                graph_data = [graph_data;missing_table];
                obj.Complete_usuable_data = [manual_annotations(exp_list,:),auto_annotations(exp_list,:),videoStats(exp_list,:),raw_data(exp_list,:),graph_data(exp_list,:)];
            end
        end
        function data_clean_up(obj)
            remove_errors(obj,73,20160401,'pez3004','all');  %removes pez 4 data prior to 20160401 due to bad stimuli
            remove_errors(obj,98,0,'pez3004','all');         %removes pez 4 from collection 98
            remove_errors(obj,93,0,'pez3003','all');         %removes pez 3 from collection 93
            remove_errors(obj,103,0,'pez3003','all');        %removes pez 3 from collection 103
            remove_errors(obj,99,20170728,'none','all');     %removes all data from collection 99 prior to 7/27/17

            remove_errors(obj,102,20170919,'none','single');   %removes all data from collection 102 for 20170919
            remove_errors(obj,102,20170912,'none','single');   %removes all data from collection 102 for 20170919
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            remove_experiment(obj,'run008_pez3002_20170802');       %gf X chrim with 0% jump rate, wrong label
            remove_experiment(obj,'run007_pez3002_20170807');       %77b x chrim with 12/21 jump rate, possibly wrong, not using

            remove_experiment(obj,'run024_pez3004_20170913');       %bad video quality, high jump rate with possible multi fly in background
            remove_experiment(obj,'run001_pez3002_20171030');       %testing experiment, dont need in dataset
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            remove_experiment(obj,'run008_pez3001_20171120');         %camera moved causing flies to not be in roi properly
            remove_errors(obj,106,0,'pez3004','all');                 %removes pez 4 from collection 106
            remove_errors(obj,106,20171127,'none','single');          %removes 11/27/17 from collection 106

            remove_errors(obj,108,0,'pez3003','all');                 %chrimson lights not accurate, data not useable
            remove_experiment(obj,'run005_pez3001_20171208');         %lights crashed during run, never turned off
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            remove_errors(obj,109,20180126,'pez3003','single');       %tracking issues, has been fixed

            remove_experiment(obj,'run001_pez3004_20181022');       %run removed due to stimuli errors
            remove_experiment(obj,'run002_pez3002_20181102');       %run removed due to stimuli errors
            remove_experiment(obj,'run001_pez3002_20181120');       %testing experiment, bad conditions
            remove_experiment(obj,'run018_pez3002_20190318');       %error in videos, wont display

            remove_errors(obj,116,0,'pez3004','all');               %removes pez 4 from collection 119 prior to 11/11/2018 due to gate noise that was causing problems

            remove_experiment(obj,'run004_pez3002_20190109');       %wrong protocols
            remove_experiment(obj,'run005_pez3001_20190109');       %wrong protocols

            %            remove_errors(obj,119,20190201,'none','all');           %tracking issues, has been fixed

            remove_errors(obj,118,0,'pez3004','all');               %pez 4 data not accurate not using for this dataset
            remove_errors(obj,119,0,'pez3004','all');               %pez 4 data not accurate not using for this dataset
            remove_errors(obj,138,0,'pez3004','all');               %pez 4 data not accurate not using for this dataset


            remove_errors(obj,141,20190221,'none','single');       %tracking issues, has been fixed

            remove_errors(obj,222,20200120,'pez3002','all');               %pez 4 data not accurate not using for this dataset

            %            date_logic = cellfun(@(x) str2double(x(16:23)) < 20181211,obj.Complete_usuable_data.Properties.RowNames);      %only data this year
            %            obj.Complete_usuable_data(date_logic,:) = [];
        end
        function get_trigger_info(obj)
            run_list = unique(cellfun(@(x) x(1:23),obj.Complete_usuable_data.Properties.RowNames,'uniformoutput',false));
            date_str = cellfun(@(x) x(16:23),run_list,'uniformoutput',false);
            for iterZ = 1:length(run_list)
                trigger_path = ['\\DM11\cardlab\Data_pez3000' filesep date_str{iterZ} filesep run_list{iterZ} filesep 'inspectionResults' filesep run_list{iterZ} '_autoAnalysisResults.mat'];
                try
                    trigger_info = load(trigger_path);
                    if strcmp(obj.filter_toggle,'on')
                        trigger_info = trigger_info.autoResults(:,obj.trigger_filter);
                    else
                        trigger_info = trigger_info.autoResults;
                    end

                    discard_logic = cellfun(@(x) contains(x,'discard'),get(trigger_info,'ObsNames'));
                    new_discard_string = cellfun(@(x) sprintf('%s_%s',run_list{iterZ},x),get(trigger_info(discard_logic,:),'ObsNames'),'uniformoutput',false);

                    old_strings = get(trigger_info,'ObsNames');                old_strings(discard_logic) = new_discard_string;
                    trigger_info = set(trigger_info,'ObsNames',old_strings);

                    obj.all_triggers = [obj.all_triggers;trigger_info];
                catch       %no trigger data
                end
            end
            missing_reason = cellfun(@(x) isempty(x),obj.all_triggers.diode_decision);
            obj.all_triggers(missing_reason,:).diode_decision = repmat({'Mutli/blank'},sum(missing_reason),1);
        end
        function load_tracking(obj)
            all_tracked = [];
            all_locate =[];
            all_trk = [];
            track_string = '_flyAnalyzer3000_v14';

            if exist(fullfile([obj.analysis_path filesep obj.exp_id filesep obj.exp_id track_string]),'file') == 7
                track_string = '_flyAnalyzer3000_v14';
            else
                track_string = '_flyAnalyzer3000_v13';
            end

            tracked_list = struct2dataset(dir(fullfile([obj.analysis_path filesep obj.exp_id filesep obj.exp_id track_string],'*.mat')));
            tracked_list = tracked_list.name;
            if isempty(tracked_list)

            elseif ischar(tracked_list)
                locate_list = {regexprep(tracked_list,[track_string '_data.mat'],'_flyLocator3000_v10_data.mat')};
                trk_list = {regexprep(tracked_list,[track_string '_data.mat'],'_flyTracker3000_v17_data_data.mat')};
                tracked_list = {tracked_list};
            else
                locate_list = cellfun(@(x) regexprep(x,[track_string '_data.mat'],'_flyLocator3000_v10_data.mat'),tracked_list,'UniformOutput',false);
                trk_list = cellfun(@(x) regexprep(x,[track_string '_data.mat'],'_flyTracker3000_v17_data.mat'),tracked_list,'UniformOutput',false);
            end

            path_id = obj.analysis_path;
            load_exp_id = obj.exp_id;
            track_filter_used = obj.tracked_filter;
            locate_filter_used = obj.locate_filter;
            trk_filter_used = obj.trk_filter;

            if ~isempty(tracked_list)
                parfor iterA = 1:length(tracked_list)
                    try
                        temp_track  = load([path_id filesep load_exp_id filesep load_exp_id track_string filesep tracked_list{iterA}]);
                        temp_locate = load([path_id filesep load_exp_id filesep load_exp_id '_flyLocator3000_v10'  filesep locate_list{iterA}]);
                        temp_trk = load([path_id filesep load_exp_id filesep load_exp_id '_flyTracker3000_v17'  filesep trk_list{iterA}]);
                    catch
                        continue
                    end
                    if strcmp(obj.filter_toggle,'on') %#ok<PFBNS>
                        all_tracked = [all_tracked;temp_track.saveobj(:,track_filter_used)];
                        all_locate = [all_locate;temp_locate.saveobj(:,locate_filter_used)];
                        all_trk = [all_trk;temp_trk.saveobj(:,trk_filter_used)];
                    else
                        all_tracked = [all_tracked;temp_track.saveobj];
                        all_locate = [all_locate;temp_locate.saveobj];
                        all_trk = [all_trk;temp_trk.saveobj];
                    end
                end
                all_locate(:,ismember(all_locate.Properties.VariableNames,all_tracked.Properties.VariableNames)) = [];
                all_trk(:,ismember(all_trk.Properties.VariableNames,all_tracked.Properties.VariableNames)) = [];
                all_tracked = [all_tracked,all_locate,all_trk];

                if ~isempty(all_tracked)
                    missing_logic = ~ismember(obj.Complete_usuable_data.Properties.RowNames,all_tracked.Properties.RowNames);
                    missing_records = obj.Complete_usuable_data.Properties.RowNames(missing_logic);
                else
                    missing_records = obj.Complete_usuable_data.Properties.RowNames;
                end

                if ~isempty(missing_records)
                    %filter_used = [track_filter_used,locate_filter_used];
                    filter_used = all_tracked.Properties.VariableNames;
                    missing_table = cell2table(cell(length(missing_records),length(filter_used)));
                    missing_table.Properties.RowNames = missing_records;
                    missing_table.Properties.VariableNames = filter_used;
                    all_tracked = [all_tracked;missing_table];
                end

                all_tracked = all_tracked(obj.Complete_usuable_data.Properties.RowNames,:);
                obj.Complete_usuable_data = [obj.Complete_usuable_data,all_tracked];
            end
        end

        function remove_errors(obj,collection,date,pez,date_flag)

            if isempty(obj.Complete_usuable_data)
                return
            end
            collect_logic = cellfun(@(x) str2double(x(29:32)) == collection,obj.Complete_usuable_data.Properties.RowNames);
            if strcmp(pez,'none')
                pez_logic = true(height(obj.Complete_usuable_data),1);
            else
                pez_logic = cellfun(@(x)  contains(x,pez),obj.Complete_usuable_data.Properties.RowNames);
            end
            if date == 0
                date_logic = true(height(obj.Complete_usuable_data),1);
            elseif strcmp(date_flag,'all')
                date_logic = cellfun(@(x)  str2double(x(16:23)) < date,obj.Complete_usuable_data.Properties.RowNames);
            elseif strcmp(date_flag,'single')
                date_logic = cellfun(@(x)  str2double(x(16:23)) == date,obj.Complete_usuable_data.Properties.RowNames);
            end

            remove_errors = collect_logic & date_logic & pez_logic;
            obj.Complete_usuable_data(remove_errors,:) = [];
        end
        function remove_experiment(obj,exp_string)
            if isempty(obj.Complete_usuable_data)
                return
            end
            remove_exp_logic = cellfun(@(x) contains(x,exp_string),obj.Complete_usuable_data.Properties.RowNames);
            obj.Complete_usuable_data(remove_exp_logic,:) = [];
        end
        function remove_protocol(obj,collection,proto_string)
            if isempty(obj.Complete_usuable_data)
                return
            end
            collect_logic = cellfun(@(x) str2double(x(29:32)) == collection,obj.Complete_usuable_data.Properties.RowNames);

            remove_exp_logic = cellfun(@(x) contains(x,proto_string),obj.Complete_usuable_data.Properties.RowNames);
            obj.Complete_usuable_data(remove_exp_logic & collect_logic,:) = [];
        end
    end
    methods
        function error_value = load_data(obj)
            %            tic
            error_value = 0;
            obj.parse_data;
            try
                obj.load_annotations;
            catch
                error_value = 1;
                return
            end
            obj.data_clean_up;
            try
                obj.get_trigger_info;
            catch
                error_value = 2;
%                warning('no trigger?')
            end
            fprintf('loading annotation data :: %s\n',obj.exp_id);
        end
        function make_tables(obj)
            pez_issues = ~strcmp(obj.Complete_usuable_data.NIDAQ,'Good');
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            obj.Complete_usuable_data(pez_issues,:) = [];

            %             pez_issues = obj.Complete_usuable_data.Error_logic == 1;
            %             obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            %             obj.Complete_usuable_data(pez_issues,:) = [];

            %             pez_issues = obj.Complete_usuable_data.Error_logic == 1;
            %             obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            %             obj.Complete_usuable_data(pez_issues,:) = [];

            try
                stim_errors = cellfun(@(x,y) isempty(x) & isempty(y), obj.Complete_usuable_data.visStimProtocol,obj.Complete_usuable_data.photoStimProtocol);
                obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(stim_errors,:)];
                obj.Complete_usuable_data(stim_errors,:) = [];
            catch
                warning('why error')
            end


            obj.get_start_frame;
            if ~isempty(obj.Complete_usuable_data)
                obj.split_tables;
            end
        end
        function get_tracking_data(obj)
            %            tic
            obj.load_tracking;
            %            fprintf('loading tracking Data :: %s  took %2.6f seconds\n',obj.exp_id,toc)
            fprintf('loading tracking Data :: %s\n',obj.exp_id);
        end
        function fill_blank_track(obj)
            need_to_add = [obj.tracked_filter,obj.locate_filter, obj.trk_filter;];
            new_table = cell(height(obj.Complete_usuable_data),length(need_to_add));
            new_table = cell2table(new_table);
            new_table.Properties.RowNames = obj.Complete_usuable_data.Properties.RowNames;
            new_table.Properties.VariableNames = need_to_add;
            obj.Complete_usuable_data = [obj.Complete_usuable_data,new_table];
        end
        function display_data(obj)
            obj.filter_tracked_data;
            if ~isempty(obj.Complete_usuable_data)
                obj.get_stim_info;
                obj.find_vid_to_work;
                white_logic = cellfun(@(x) contains(x,'whiteonwhite'),obj.parsed_data.Stimuli_Type);
                if ~white_logic
                    obj.remove_pre_stim_jump('Complete_usuable_data');
                    obj.remove_pre_stim_jump('Vid_Not_Tracked');
                end
                obj.get_summary_table;
                obj.populate_table;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function get_start_frame(obj)
            start_frame = cell(height(obj.Complete_usuable_data),3);
            if isempty(start_frame)
                return
            end
            start_frame = cell2table(start_frame);
            start_frame.Properties.RowNames = obj.Complete_usuable_data.Properties.RowNames;
            start_frame.Properties.VariableNames = {'Start_Frame','Stimuli_Used','Stimuli_Duration'};

            start_frame_P = cell(height(obj.Pez_Issues),3);
            start_frame_P = cell2table(start_frame_P);
            start_frame_P.Properties.RowNames = obj.Pez_Issues.Properties.RowNames;
            start_frame_P.Properties.VariableNames = {'Start_Frame','Stimuli_Used','Stimuli_Duration'};
            obj.Pez_Issues = [obj.Pez_Issues,start_frame_P];


            loom_logic = cellfun(@(x) ~isempty(x),obj.Complete_usuable_data.visStimFrameStart);
            photo_logic = cellfun(@(x) ~isempty(x),obj.Complete_usuable_data.photoStimFrameStart);
            combo_logic = loom_logic & photo_logic;

            start_frame.Start_Frame(loom_logic & ~combo_logic) = obj.Complete_usuable_data(loom_logic & ~combo_logic,:).visStimFrameStart;
            start_frame.Stimuli_Used(loom_logic & ~combo_logic) = obj.Complete_usuable_data(loom_logic & ~combo_logic,:).visStimProtocol;
            start_frame.Stimuli_Duration(loom_logic & ~combo_logic) = obj.Complete_usuable_data(loom_logic & ~combo_logic,:).visStimFrameCount;

            start_frame.Start_Frame(photo_logic & ~combo_logic) = obj.Complete_usuable_data(photo_logic & ~combo_logic,:).photoStimFrameStart;
            start_frame.Stimuli_Used(photo_logic & ~combo_logic) = obj.Complete_usuable_data(photo_logic & ~combo_logic,:).photoStimProtocol;
            start_frame.Stimuli_Duration(photo_logic & ~combo_logic) = obj.Complete_usuable_data(photo_logic & ~combo_logic,:).photoStimFrameCount;

            start_frame.Start_Frame(combo_logic) = cellfun(@(x,y) min(x,y),obj.Complete_usuable_data(combo_logic,:).photoStimFrameStart,obj.Complete_usuable_data(combo_logic,:).visStimFrameStart,'UniformOutput',false);
            start_frame.Stimuli_Used(combo_logic) = cellfun(@(x,y) sprintf('%s_%s',x,y),obj.Complete_usuable_data(combo_logic,:).visStimProtocol,obj.Complete_usuable_data(combo_logic,:).photoStimProtocol,'UniformOutput',false);
            start_frame.Stimuli_Duration(combo_logic) = cellfun(@(x,y) max(x,y),obj.Complete_usuable_data(combo_logic,:).photoStimFrameCount, obj.Complete_usuable_data(combo_logic,:).visStimFrameCount,'UniformOutput',false);

            stim_table = tabulate(start_frame.Stimuli_Used);
            logic_index = max(cell2mat(stim_table(:,2))) == cell2mat(stim_table(:,2));

            %obj.parsed_data.Stimuli_Type = unique(start_frame.Stimuli_Used);
            obj.parsed_data.Stimuli_Type = stim_table(logic_index,1);

            obj.Complete_usuable_data = [obj.Complete_usuable_data,start_frame];
            logic_1 = cellfun(@(x) contains(x,'0699_'),obj.Complete_usuable_data.Properties.RowNames);
            logic_2 = cellfun(@(x) contains(x,'0701_'),obj.Complete_usuable_data.Properties.RowNames);

            bad_stim = cellfun(@(x) isempty(x),start_frame.Start_Frame);

            good_chrim_data = logic_1 | logic_2;
            obj.Complete_usuable_data.Start_Frame(good_chrim_data & bad_stim) = repmat({0},sum(good_chrim_data & bad_stim),1);

            bad_stim = cellfun(@(x) isempty(x),obj.Complete_usuable_data.Start_Frame);
            if sum(bad_stim) > 0
                obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(bad_stim,:)];
                obj.Complete_usuable_data(bad_stim,:) = [];
            end

            to_short = cellfun(@(x) x < 0,obj.Complete_usuable_data.Start_Frame);
            if sum(to_short) > 0
                obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(to_short,:)];
                obj.Complete_usuable_data(to_short,:) = [];
            end

            to_long_logic = (cellfun(@(x,y,z) (x+y) > z, obj.Complete_usuable_data.Start_Frame,obj.Complete_usuable_data.Stimuli_Duration,num2cell(obj.Complete_usuable_data.frame_count)));
            if sum(to_long_logic) > 0
                obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(to_long_logic,:)];
                obj.Complete_usuable_data(to_long_logic,:) = [];
            end
            obj.remove_variables_not_needed('Complete_usuable_data')
            obj.remove_variables_not_needed('Pez_Issues')

        end
        function remove_variables_not_needed(obj,test_table)
            obj.(test_table).visStimProtocol = [];
            obj.(test_table).visStimFrameStart = [];
            obj.(test_table).visStimFrameCount = [];

            obj.(test_table).photoStimProtocol = [];
            obj.(test_table).photoStimFrameStart = [];
            obj.(test_table).photoStimFrameCount = [];
        end
        function get_summary_table(obj)

            if istable(obj.video_table)
                return
            end
            video_list_c = [];
            video_list_w = [];
            video_list_ch = [];

            if ~isempty(obj.Complete_usuable_data)
                video_list_c = cellfun(@(x) x(1:(end-8)),obj.Complete_usuable_data.Properties.RowNames,'uniformoutput',false);
            end
            if ~isempty(obj.Videos_Need_To_Work)
                video_list_w = cellfun(@(x) x(1:(end-8)),obj.Videos_Need_To_Work.Properties.RowNames,'uniformoutput',false);
            end
            if ~isempty(obj.Vid_Not_Tracked)
                video_list_c = [video_list_c;cellfun(@(x) x(1:(end-8)),obj.Vid_Not_Tracked.Properties.RowNames,'uniformoutput',false)];
            end
            if strcmp(obj.stim_type,'loom')
                passing_table = tabulate([video_list_c;video_list_w]);
            else
                passing_table = tabulate([video_list_c;video_list_w;video_list_ch]);
            end

            if obj.remove_low
                passing_table(cell2mat(passing_table(:,2)) < obj.low_count,:) = [];
            end
            if isempty(passing_table(:,1))
                empty_runs = obj.video_table(:,1);
            else
                empty_runs = obj.video_table(~ismember(obj.video_table(:,1),passing_table(:,1)),1);
            end
            empty_runs = [empty_runs,repmat({0},length(empty_runs),2)];

            passing_table = [passing_table;empty_runs];

            try
                [~,sort_idx] = sort(obj.video_table(:,1));  obj.video_table = obj.video_table(sort_idx,:);
            catch
                [~,sort_idx] = sort(obj.video_table.Properties.RowNames);  obj.video_table = obj.video_table(sort_idx,:);
            end
            [~,sort_idx] = sort(passing_table(:,1));    passing_table = passing_table(sort_idx,:);


            row_names = obj.video_table(:,1);
            col_names = [{'Downloaded'},{'Passing'}];
            obj.video_table = cell2table([obj.video_table(:,2),passing_table(:,2)]);
            obj.video_table.Properties.RowNames = row_names;
            obj.video_table.Properties.VariableNames = col_names;

            if obj.remove_low
                rem_logic = obj.video_table.Passing < obj.low_count;
                rem_list = obj.video_table.Properties.RowNames(rem_logic);
                obj.remove_to_low('Complete_usuable_data',rem_list)
                obj.remove_to_low('Pez_Issues',rem_list)
                obj.remove_to_low('Multi_Blank',rem_list)
                obj.remove_to_low('Balancer_Wings',rem_list)
                obj.remove_to_low('Failed_Location',rem_list)
                obj.remove_to_low('Vid_Not_Tracked',rem_list)
                obj.remove_to_low('Bad_Tracking',rem_list)
                obj.remove_to_low('Out_Of_Range',rem_list)
                obj.remove_to_low('Videos_Need_To_Work',rem_list)
                obj.all_triggers(ismember(cellfun(@(x) x(1:23),get(obj.all_triggers,'ObsNames'),'UniformOutput',false),cellfun(@(x) x(1:23),rem_list,'UniformOutput',false)),:) = [];
            end
        end
        function split_tables(obj)
            video_list_c = cellfun(@(x) x(1:(end-8)),obj.Complete_usuable_data.Properties.RowNames,'uniformoutput',false);
            video_list_p = cellfun(@(x) x(1:(end-8)),obj.Pez_Issues.Properties.RowNames,'uniformoutput',false);
            obj.video_table = tabulate([video_list_c;video_list_p]);

            if obj.remove_low
                rem_list = obj.video_table(cell2mat(obj.video_table(:,2)) < obj.low_count,1);
                obj.remove_to_low('Complete_usuable_data',rem_list)
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % bad sweeper
            pez_issues = strcmp(obj.Complete_usuable_data.Fly_Count,'Empty') & strcmp(obj.Complete_usuable_data.Physical_Condition,'BadSweep');
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            obj.Complete_usuable_data(pez_issues,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %curly / sticky wings
            wing_issues = strcmp(obj.Complete_usuable_data.Balancer,'CyO');
            obj.Balancer_Wings = [obj.Balancer_Wings;obj.Complete_usuable_data(wing_issues,:)];
            obj.Complete_usuable_data(wing_issues,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %multi and blank
            multi_fly = ~strcmp(obj.Complete_usuable_data.Fly_Count,'Single');
            obj.Multi_Blank = [obj.Multi_Blank;obj.Complete_usuable_data(multi_fly,:)];
            obj.Complete_usuable_data(multi_fly,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %shadow flies
            bad_condition = ~strcmp(obj.Complete_usuable_data.Physical_Condition,'Good');
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(bad_condition,:)];
            obj.Complete_usuable_data(bad_condition,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Raw Data Fail
            bad_condition = strcmp(obj.Complete_usuable_data.Analysis_Status,'Raw data fail');
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(bad_condition,:)];
            obj.Complete_usuable_data(bad_condition,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %nidaq and temp
            pez_issues = ~strcmp(obj.Complete_usuable_data.NIDAQ,'Good');
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            obj.Complete_usuable_data(pez_issues,:) = [];

            pez_issues = (obj.Complete_usuable_data.temp_degC > obj.temp_range(2) | obj.Complete_usuable_data.temp_degC < obj.temp_range(1));
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            obj.Complete_usuable_data(pez_issues,:) = [];

            pez_issues = (obj.Complete_usuable_data.humidity_percent < obj.humidity_cut_off);
            obj.Pez_Issues = [obj.Pez_Issues;obj.Complete_usuable_data(pez_issues,:)];
            obj.Complete_usuable_data(pez_issues,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %bad curation location
            %            loom_logic = cellfun(@(x) contains(x,'loom'),obj.Complete_usuable_data.Stimuli_Used);
            failed_loc = ~strcmp(obj.Complete_usuable_data.Fly_Detect_Accuracy,'Good');

            %            obj.Failed_Location = [obj.Failed_Location;obj.Complete_usuable_data(failed_loc & loom_logic,:)];
            %            obj.Complete_usuable_data(failed_loc & loom_logic,:) = [];

            obj.Failed_Location = [obj.Failed_Location;obj.Complete_usuable_data(failed_loc,:)];
            obj.Complete_usuable_data(failed_loc,:) = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %pre stimuli jumpers
            wing_lift_frame = obj.Complete_usuable_data.frame_of_wing_movement;
            if obj.ignore_graph_table == 1
                auto_track = cell2mat(obj.Complete_usuable_data.autoFrameOfTakeoff);
            else
                auto_track = obj.Complete_usuable_data.autoFot;
                missing_records = cellfun(@(x) isempty(x), obj.Complete_usuable_data.autoFrameOfTakeoff);
                obj.Complete_usuable_data.autoFrameOfTakeoff(missing_records) = {20};
                obj.Complete_usuable_data.jumpTest(missing_records) = {false};
            end


            auto_track(auto_track == 0) = cell2mat(obj.Complete_usuable_data.autoFrameOfTakeoff(auto_track == 0));
            auto_jump = obj.Complete_usuable_data.jumpTest;
            if iscell(auto_jump)
                auto_jump = cell2mat(auto_jump);
            end
            if obj.ignore_graph_table == 1
                auto_jump(auto_track == 0) = cell2mat(obj.Complete_usuable_data.jumpTest(auto_track == 0));
            else
                auto_jump(auto_track == 0) = cell2mat(obj.Complete_usuable_data.autoJumpTest(auto_track == 0));
            end

            auto_track(auto_jump ==0) = 0;      %if auto jump is false, set frame to 0 or nan

            wing_lift_frame(cellfun(@(x) isempty(x), wing_lift_frame)) = num2cell(auto_track(cellfun(@(x) isempty(x), wing_lift_frame)));
            wing_lift_frame(cell2mat(wing_lift_frame) == 0) = {NaN};
            wing_lift_frame(cell2mat(wing_lift_frame) == 20) = {NaN};

            pre_stim_jump = cellfun(@(x,y) x < y, wing_lift_frame,obj.Complete_usuable_data.Start_Frame);
            obj.Multi_Blank = [obj.Multi_Blank;obj.Complete_usuable_data(pre_stim_jump,:)];
            obj.Complete_usuable_data(pre_stim_jump,:) = [];
        end
        function remove_to_low(obj,variable,rem_list)
            if ~isempty(obj.(variable))
                org_video_list = cellfun(@(x) x(1:(end-8)),obj.(variable).Properties.RowNames,'uniformoutput',false);
                obj.(variable)(ismember(org_video_list,rem_list),:) = [];
            end
        end
        function find_vid_to_work(obj)
            if isempty(obj.Complete_usuable_data)
                return
            end
            not_done_logic = cellfun(@(x) isempty(x), obj.Complete_usuable_data.frame_of_leg_push);
            obj.Videos_Need_To_Work = obj.Complete_usuable_data(not_done_logic,:);
            obj.Complete_usuable_data(not_done_logic,:) = [];

            error_logic = cellfun(@(x) isempty(x), obj.Complete_usuable_data.frame_of_wing_movement);
            obj.Videos_Need_To_Work = [obj.Videos_Need_To_Work;obj.Complete_usuable_data(error_logic,:)];
            obj.Complete_usuable_data(error_logic,:) = [];
        end
        function remove_pre_stim_jump(obj,test_obj)
            wing_frame = obj.(test_obj).frame_of_wing_movement;
            not_done_logic = cellfun(@(x) isempty(x), wing_frame);

            wing_frame(not_done_logic) = num2cell(cell2mat(obj.(test_obj).Start_Frame(not_done_logic))+1);
            try
                early_jump_logic = cellfun(@(x,y) x<=y, wing_frame,obj.(test_obj).Start_Frame);
            catch
                warning('error?')
            end
            data_to_remove = obj.(test_obj)(early_jump_logic,:);
            data_to_remove(:,~ismember(data_to_remove.Properties.VariableNames,obj.Multi_Blank.Properties.VariableNames)) = [];
            obj.Multi_Blank = [obj.Multi_Blank;data_to_remove];
            obj.(test_obj)(early_jump_logic,:) = [];
        end
        function filter_tracked_data(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %removes blank track, and tracking stoping before stimuli starts
            %no tracking found for any id for this id, removes it all
            if isempty(obj.Complete_usuable_data)
                return
            end
            try
                if sum(cellfun(@(x) contains(x,'bot_points'),obj.Complete_usuable_data.Properties.VariableNames)) == 0
                    obj.Vid_Not_Tracked = [obj.Vid_Not_Tracked;obj.Complete_usuable_data];
                    obj.Complete_usuable_data = [];
                    return
                end
            catch
                warning('new error')
            end

            empty_logic = cellfun(@(x,y) isempty(x),obj.Complete_usuable_data.bot_points_and_thetas);
            obj.Vid_Not_Tracked = [obj.Vid_Not_Tracked;obj.Complete_usuable_data(empty_logic,:)];
            obj.Complete_usuable_data(empty_logic,:) = [];

            try
                short_logic = cellfun(@(x,y) length(x(:,1)) < y,obj.Complete_usuable_data.bot_points_and_thetas,obj.Complete_usuable_data.Start_Frame);
            catch
                short_logic = false(height(obj.Complete_usuable_data),1);
            end
            obj.Bad_Tracking = [obj.Bad_Tracking;obj.Complete_usuable_data(short_logic,:)];
            obj.Complete_usuable_data(short_logic,:) = [];
        end
        function get_stim_info(obj)
            if isempty(obj.Complete_usuable_data)
                return
            end

            obj.make_blank_entries('Vid_Not_Tracked');
            obj.make_blank_entries('Bad_Tracking');
            obj.make_blank_entries('Complete_usuable_data');

            try
                org_fly_pos = obj.Complete_usuable_data.fly_detect_azimuth;
                fly_pos_stim_start = cellfun(@(x,y) x(y,3), obj.Complete_usuable_data.bot_points_and_thetas,obj.Complete_usuable_data.Start_Frame);
                fly_pos_stim_start = fly_pos_stim_start.* 180/pi;
                org_fly_pos = org_fly_pos  + 360;
            catch
                warning('no start frame')
            end
            %                testing_180_flip = cellfun(@(x) ~isempty(strfind(x,'180degOff')),obj.Complete_usuable_data.Fly_Detect_Accuracy);
            %                org_fly_pos(testing_180_flip) = org_fly_pos(testing_180_flip) + 180;

            org_fly_pos = rem(rem(org_fly_pos,360)+360,360);
            fly_pos_stim_start = rem(rem(fly_pos_stim_start,360)+360,360);

            stim_pos = cell2mat(obj.Complete_usuable_data.stimulus_azimuth)*180/pi;
            stim_pos = stim_pos + 360;
            stim_pos = rem(rem(stim_pos,360)+360,360);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            org_stim_offset = stim_pos - org_fly_pos;                           org_stim_offset = round(org_stim_offset*10000)/10000;
            new_stim_offset = stim_pos - fly_pos_stim_start;                    new_stim_offset = round(new_stim_offset*10000)/10000;
            total_movement = fly_pos_stim_start - org_fly_pos;                  total_movement = round(total_movement*10000)/10000;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            org_stim_offset(org_stim_offset < -180) = org_stim_offset(org_stim_offset < -180) + 360;
            org_stim_offset(org_stim_offset >  180) = org_stim_offset(org_stim_offset >  180) - 360;

            new_stim_offset(new_stim_offset < -180) = new_stim_offset(new_stim_offset < -180) + 360;
            new_stim_offset(new_stim_offset >  180) = new_stim_offset(new_stim_offset >  180) - 360;

            total_movement = rem(rem(total_movement,360)+360,360);
            total_movement(total_movement > 180) = total_movement(total_movement > 180) - 360;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Complete_usuable_data.Stim_Pos_At_Trigger = org_stim_offset;
            obj.Complete_usuable_data.Fly_Pos_At_Stim_Start = fly_pos_stim_start;
            obj.Complete_usuable_data.Stim_Fly_Saw_At_Trigger = new_stim_offset;
            %            if contains(stim_shown,'_blackonwhite')  && elevation_shown < 90       %only do stim compare for black on white looms
            %                bad_track = abs(total_movement) > 90;
            bad_track = abs(total_movement) > 60;

            obj.Bad_Tracking = [obj.Bad_Tracking;obj.Complete_usuable_data(bad_track,:)];
            obj.Complete_usuable_data(bad_track,:) = [];
            out_of_range = abs(total_movement(~bad_track)) > obj.azi_off;

            obj.Out_Of_Range = [obj.Out_Of_Range;obj.Complete_usuable_data(out_of_range,:)];
            obj.Complete_usuable_data(out_of_range,:) = [];
            %            end
        end
        function make_blank_entries(obj,variable)
            try
                stim_position = cell(height(obj.(variable)),3);
            catch
                warning('error')
            end
            stim_position = cell2table(stim_position);
            stim_position.Properties.RowNames = obj.(variable).Properties.RowNames;
            stim_position.Properties.VariableNames = [{'Stim_Pos_At_Trigger'},{'Fly_Pos_At_Stim_Start'},{'Stim_Fly_Saw_At_Trigger'}];

            if sum(ismember(stim_position.Properties.VariableNames,obj.(variable).Properties.VariableNames)) == 3
                return  %extra colums already exist
            end
            obj.(variable) = [obj.(variable),stim_position];
            obj.(variable).Stim_Pos_At_Trigger = zeros(height(obj.(variable)),1);
            obj.(variable).Fly_Pos_At_Stim_Start = zeros(height(obj.(variable)),1);
            obj.(variable).Stim_Fly_Saw_At_Trigger = zeros(height(obj.(variable)),1);
        end
        function populate_table(obj)
            obj.total_counts = cell2table(cell(1,length(obj.table_header)));
            obj.total_counts.Properties.VariableNames = obj.table_header;
            obj.total_counts.Properties.RowNames = {obj.exp_id};
            obj.total_counts.Vials_Run = sum(obj.video_table.Passing > 0);
            %            obj.total_counts.Total_Videos = sum(cell2mat(obj.video_table(:,2))) + height(obj.Pez_Issues);
            obj.total_counts.Total_Videos = sum(obj.video_table.Downloaded(obj.video_table.Passing>0));

            check_for_zero(obj,'Pez_Issues','Pez_Issues');
            check_for_zero(obj,'Multi_Blank','Multi_Blank');
            check_for_zero(obj,'Balancer_Wings','Balancers');
            check_for_zero(obj,'Failed_Location','Failed_Location');
            check_for_zero(obj,'Vid_Not_Tracked','Vid_Not_Tracked');
            check_for_zero(obj,'Bad_Tracking','Bad_Tracking');
            check_for_zero(obj,'Out_Of_Range','Out_Of_Range');

            check_for_zero(obj,'Videos_Need_To_Work','Need_To_Annotate');
            check_for_zero(obj,'Complete_usuable_data','Usuable_Complete');
        end
        function check_for_zero(obj,test_string,count_string)
            if isempty(obj.(test_string))
                obj.total_counts.(count_string) = 0;
            else
                obj.total_counts.(count_string) = height(obj.(test_string));
            end
        end

    end
    methods
        function obj = Experiment_ID(test_id)
            obj.exp_id = test_id;
        end
    end
end

