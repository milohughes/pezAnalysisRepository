% FlyPez3000_BasicAnalysis
%
% 1) Enter data to be visualized and parameters
% 2) Pipeline throughput, Load data, & data checks
% 3) Data visualizations
%
%----------------------------------
% HOW/WHERE THE DATA IS GENERATED:
%----------------------------------
% MANUAL ANNOTATION:
% - Run: Video_viewer_with_analysis_v3.m
% - Output: 0032000004300171_manualAnnotations.mat
%       *manualAnnotations has same number of rows as rawDataAssessment
% 
% DAILY PROCESSING:
% - (0) Process video names
% 	automated script: [run daily]
% 	Input/Output: 	0032000004300171_videoStatisticsMerged.mat      
% 			0032000004300171_experimentInfoMerged.mat       
% 			0032000004300171_rawDataAssessment.mat?
% 		*Appends empty rows with new file names
% 		*New experiments appended daily
% 
% CURATION:
% - (1) Curation
% 	Run: pez3000_curator_v4.m
% 	Input/Output: 0032000004300171_rawDataAssessment.mat
% 		*Checks 'Curation_Status' column to see if needs to be tracked
% 
% TRACKING:
% - (2) Locator
% 	Input:	0032000004300171_rawDataAssessment.mat? .avi files
% 	Output: 0032000004300171_flyLocator3000_v9
% 		*Folder containing files by exp_id 
% - (3) Tracker
% 	Input: 
% 	Output: 0032000004300171_flyTracker3000_v16                                                  
%
% - (4) Analyzer
% 	Input:
% 	Output:	0032000004300171_pezAnalyzer3000_v11
% 
% AUTOMATED ANNOTATION:
% - (5) Automated annotation
% 	Input:	0032000004300171_rawDataAssessment.mat? .avi files
% 	Output:	0032000004300171_ automatedAnnotations.mat
% 		*Data must be curated; uses adjusted line in top video
%           
% NOT USED:
% 0032000004300171_rawDataReference_v2.mat            
% automatedAnnotations.mat  


%% 1) USER: Enter Data

clear all, clc
close all

%--------------------------------------------------------------------------
% USER INPUT
%--------------------------------------------------------------------------
exp_ID_to_load = '0031';                                                    % Change this to alter which experiment ID set get processed %Sahana 0032 %0033 martin?

load_by_group = 0;                                                          % SET TO 1 to LOAD BY GROUP; if set to 0, will load by "exp_ID_to_load
group_to_load = ' LC4 DN CsChr 7_15_14';

use_auto_frame_of_takeoff = 1;                                              % Use Manually annotated (0) vs. Automatic (1) frame of takeoff
skip_all = 1;                                                               % 1=plot graphs; 0=skip plotting

plot_pipeline_stats = 1; % 2) Pipeline throughput & data checks

save_out_data = 0;
if strmatch(computer,'MACI64')
    save_folder = '/Volumes/card/Sahana/Matalbroot/analysis/';
else
    save_folder = '\\tier2\card\Sahana\Matlabroot\analysis\';
end
%--------------------------------------------------------------------------

if strmatch(computer,'MACI64')                                              % Hard-wired folder paths depending on platform
    data_path = '/Volumes/cardlab/Data_pez3000_analyzed';                   % location of data analysis info organized by exp_id
    group_path = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables'; % location of group info 
else
    data_path = '\\Dm11\cardlab\Data_pez3000_analyzed';
    group_path = '\\Dm11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
end

filepaths.files.exp_info = '_experimentInfoMerged.mat';   
filepaths.files.manualAnnotations = '_manualAnnotations.mat';               % Hard-wired filenames of data files
filepaths.files.vid_stats = '_videoStatisticsMerged.mat';
filepaths.files.curation = '_rawDataAssessment.mat';
filepaths.files.autoAnnotations = '_automatedAnnotations.mat';
%filepaths.files.autoAnnotations = 'automatedAnnotations.mat';
filepaths.folders.locator = '_flyLocator3000_v9';                           % Hard-wired names of data folders
filepaths.folders.tracker = '_flyTracker3000_v16';
filepaths.folders.analyzer = '_pezAnalyzer3000_v11';                       


if use_auto_frame_of_takeoff, takeoff_field = 'autoFrameOfTakeoff';         % Based on user input, assign name of takeoff frame field
else takeoff_field = 'frame_of_take_off'; end

currentFolder = pwd; new_folder =  fileparts(currentFolder);                % Add paths to needed support functions
addpath([new_folder filesep 'Support_Programs']);


if load_by_group                                                            % load by group
    groupInfo = load([group_path filesep 'Saved_Group_IDs.mat']);
    struct_name = fieldnames(groupInfo);           
    groupInfo  =  dataset2cell(groupInfo.(struct_name{1}));
    exp_list = groupInfo(strcmp(group_to_load,groupInfo(:,3)),1);
    save_name = 'group';                                                    %**some groups have spaces, fix later
    
    disp('Using Experiment IDs with the following group names:')
    groupInfo(strcmp(group_to_load,groupInfo(:,3)),3)
else                                                                        % load by collection number
    run_ids = struct2dataset(dir(data_path));
    run_ids = run_ids.name;
    
    run_ids = run_ids(cellfun(@(x) length(x) == 16,run_ids));               % get only valid ids
    exp_list = run_ids(cellfun(@(x) strcmp(x(1:length(exp_ID_to_load)),exp_ID_to_load),run_ids));
    save_name = exp_ID_to_load;
end

% for i = 1:length(exp_list)                                                  % Limit experiment ID's to only those that have analysis run:
%     isitthere(i) = exist([data_path filesep exp_list{i} filesep 'automatedAnnotations.mat']);
% end
% exp_list = exp_list(find(isitthere));

disp('Evaluating the following Experiment IDs:')
exp_list


%% 2) Pipeline throughput, Data loading, & Data checks
% For each exp_id, Check that rawDataAssessment and videoStatisticsMerged
% are the same size and have the same entries

load_kind = {'files','folders'};

for i = 1:length(load_kind)                                                 % MAKE FIELDNAMES to load data into
    toload.(load_kind{i}) = fieldnames(filepaths.(load_kind{i}));
    var_names.(load_kind{i}) = cellfun(@(x) x(1:7),toload.(load_kind{i}),'uniformoutput',0);
end
var_names_all = vertcat(var_names.files,var_names.folders);

% pipe_stats = cell2table(cell(length(exp_list),length(var_names_all)));
% pipe_stats.Properties.RowNames = exp_list;
% pipe_stats.Properties.VariableNames = var_names_all;

for iterA = 1:length(exp_list)                                              % LOADING DATA
    
    exp_struct(iterA).Exp_ID  = exp_list(iterA);                            % For each value of exp_struct, enter experiment ID
    
    temp_path = [data_path,filesep,exp_list{iterA},filesep,exp_list{iterA}];% Load processed data files from Data_pez300_analyzed folder
    
    for i = 1:length(load_kind)
        switch load_kind{i}
            case 'files'
                for j = 1:length(toload.(load_kind{i}))
                    
                    %once autoannotations all updated, can only use these
                    %lines to load
%                     temp=load([temp_path data.(toload.(load_kind{i}){j})]);
%                     s_names = fieldnames(temp);  
%                     data.(var_names.(load_kind{i}){j}) = temp.(s_names{1});
                    
                    if strmatch('autoAnnotations',toload.(load_kind{i}){j}) % Automated frame of takeoff needs to be multiplied by 10
                        %isitthere = exist([data_path,filesep,exp_list{iterA},filesep, filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                        isitthere = exist([temp_path filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                        if isitthere
                        
                        %temp=load([data_path,filesep,exp_list{iterA},filesep, filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                        temp=load([temp_path filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                        s_names = fieldnames(temp);
                        data(iterA).(var_names.(load_kind{i}){j}) = temp.(s_names{1});
                        
                        data(iterA).(var_names.(load_kind{i}){j}){:,3} = cellfun(@(x)...
                              x*10,data(iterA).(var_names.(load_kind{i}){j}){:,3},...
                              'UniformOutput',0); 
                        else
                            data(iterA).(var_names.(load_kind{i}){j}) = [];
                        end
                          
                    else
                        isitthere = exist([temp_path filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                        if isitthere
                            
                            temp=load([temp_path filepaths.(load_kind{i}).(toload.(load_kind{i}){j})]);
                            s_names = fieldnames(temp);
                            data(iterA).(var_names.(load_kind{i}){j}) = temp.(s_names{1});
                            
                            try
                                data(iterA).(var_names.(load_kind{i}){j}) = dataset2table(data(iterA).(var_names.(load_kind{i}){j}));
                            catch
                                continue
                            end
                        else
                            data(iterA).(var_names.(load_kind{i}){j}) = [];
                        end

                    end
                end
            case 'folders'
                for j = 1:length(toload.(load_kind{i}))
                    
                    temp = dir([temp_path filepaths.(load_kind{i}).(toload.(load_kind{i}){j}) filesep '*.mat']);
                    temp = struct2cell(temp);
                    data(iterA).(var_names.(load_kind{i}){j}) = temp(1,:)';
                    
                end
        end
    end
       
%     temp = structfun(@(x) size(x,1),data(iterA));
%     pipe_stats(iterA,:) = mat2cell(temp',1,ones(8,1));
%     
    pipe_stats(:,iterA) = structfun(@(x) size(x,1),data(iterA));            % Rows are var_names_all, columns are exp_list
    
    if ~isempty(data(iterA).curatio)
        temp = data(iterA).curatio.Raw_Data_Decision;
        temp = temp(~cellfun('isempty',temp));
        cur_pass(iterA) = size(strmatch('Pass',temp),1);
%        cur_pass(iterA) = size(strmatch('Pass',data(iterA).curatio.Raw_Data_Decision),1);

        pass_flies{iterA} = data(iterA).curatio.Properties.RowNames(strmatch('Pass',temp)); % Save row names of flies that pass
    else
        cur_pass(iterA) = 0;
    end
end 
pipe_stats_plot = [pipe_stats(3:5,:);cur_pass;pipe_stats(6:end,:)];
var_names_pipe_stats = [var_names_all(3:5);'cur_pass';var_names_all(6:end)];

if plot_pipeline_stats                                                      % PLOTTING for pipeline throughput
    figure
    plot(pipe_stats_plot,'.','LineStyle','-','MarkerSize',30)
    set(gca,'XTick',1:size(pipe_stats_plot,1),'XTickLabel',...
        var_names_pipe_stats)
    %legend(exp_list,'location','SouthWest')
    set(gcf,'Color','w')
    grid on
    ylabel('Number of Flies','FontSize',24)
    set(gca,'FontSize',24)
    
    pipe_stats_norm = pipe_stats_plot ./ repmat(pipe_stats_plot(1,:),size(pipe_stats_plot,1),1);
    
    figure
    plot(pipe_stats_norm,'.','LineStyle','-','MarkerSize',30)
    set(gca,'XTick',1:size(pipe_stats_norm,1),'XTickLabel',...
        var_names_pipe_stats)
    %ylim([0.5 1])
    %legend(exp_list,'location','SouthWest')
    set(gcf,'Color','w')
    grid on
    ylabel('Percent of Flies Run','FontSize',24)
    set(gca,'FontSize',24)
end

%% 3) DataVisualization: Extract general parameters needed for analysis indexing

for iterA = 1:length(exp_list)
    
    if ~isempty(data(iterA).exp_inf) && ~strcmp('None',data(iterA).exp_inf(1,:).Stimuli_Type)
        
        % Get number for l/v
        temp = data(iterA).exp_inf(1,:).Stimuli_Type;
        temp_ind = strfind(temp,'lv');
        temp = temp{1}(temp_ind{1}+2:temp_ind{1}+5);
        temp_ind = strfind(temp,'_');
        temp = temp(1:temp_ind-1);
        cur_lv = str2num(temp);
        analysis.lv_list(iterA) = cur_lv;
        
        % Get start size
        temp = data(iterA).exp_inf(1,:).Stimuli_Type;
        temp_ind = strfind(temp,'loom_');
        temp = temp{1}(temp_ind{1}+5:temp_ind{1}+10);
        temp_ind = strfind(temp,'to');
        temp = temp(1:temp_ind-1);
        cur_stsize = str2num(temp);
        analysis.stsize_list(iterA) = cur_stsize;
        
        % Get end size (not needed here but parcing things here)
        temp = data(iterA).exp_inf(1,:).Stimuli_Type;
        temp_ind = strfind(temp,'to');
        temp = temp{1}(temp_ind{1}+2:temp_ind{1}+6);
        temp_ind = strfind(temp,'_');
        temp = temp(1:temp_ind-1);
        cur_stopsize = str2num(temp);
        analysis.stopsize_list(iterA) = cur_stopsize;
        
    else
        analysis.lv_list(iterA) = nan;
        analysis.stsize_list(iterA) = nan;
        analysis.stopsize_list(iterA) = nan;
    end
    
end

%% 3A) Data Visualization: Takeoff percent (jumped) and Survival Rate (jumped before TOC)

for iterA = 1:length(exp_list)
    
    % only plot if there is an autoAnnotation matrix
    if ~isempty(data(iterA).autoAnn)
    
    % Get number for l/v
    temp = data(iterA).exp_inf(1,:).Stimuli_Type;
    temp_ind = strfind(temp,'lv');
    temp = temp{1}(temp_ind{1}+2:temp_ind{1}+5);
    temp_ind = strfind(temp,'_');
    temp = temp(1:temp_ind-1);
    cur_lv = str2num(temp);
    
    % Get start size
    temp = data(iterA).exp_inf(1,:).Stimuli_Type;
    temp_ind = strfind(temp,'loom_');
    temp = temp{1}(temp_ind{1}+5:temp_ind{1}+10);
    temp_ind = strfind(temp,'to');
    temp = temp(1:temp_ind-1);
    cur_stsize = str2num(temp);
    
    % Get end size (not needed here but parcing things here)
    temp = data(iterA).exp_inf(1,:).Stimuli_Type;
    temp_ind = strfind(temp,'to');
    temp = temp{1}(temp_ind{1}+2:temp_ind{1}+6);
    temp_ind = strfind(temp,'_');
    temp = temp(1:temp_ind-1);
    cur_stopsize = str2num(temp);
    
    % Calculate FRAME of contact
    % TOC = (l/v) / tan(th/2) for starting size th (so tan(5*pi/180) for
    % starting size 10-deg; l/v in ms, so time in ms
    foc = 6 * (cur_lv) / tan(cur_stsize/2 * (pi/180));
    
    % automated frame of takeoff might be off by +/- 10 frames, so pad a
    % bit:
    foc_thresh = foc;% + 15;
    
    % Find frame of takeoff less than this
    if use_auto_frame_of_takeoff
        if ~isempty(data(iterA).autoAnn)
            jump_vect = cellfun(@minus, data(iterA).autoAnn.autoFrameOfTakeoff, data(iterA).autoAnn.visStimFrameStart,'Un',0);
            %jump_vect = data(iterA).autoAnn.autoFrameOfTakeoff;
            ind_empty = cellfun('isempty', jump_vect);
            jump_vect(ind_empty) = cellfun(@(x) {nan},jump_vect(ind_empty));
            jump_vect = cell2mat(jump_vect);
            
            jump_test = data(iterA).autoAnn.jumpTest;
            ind_empty = cellfun('isempty', jump_test);
            jump_test(ind_empty) = cellfun(@(x) {nan},jump_test(ind_empty));
            jump_test = cellfun(@(x) double(x),jump_test);
            
            jump_vect = jump_vect .* jump_test;
        else
            jump_vect = [];
        end
    else
        %jump_vect = cell2mat(data(iterA).manualA.frame_of_take_off);
        jump_vect = cellfun(@minus, data(iterA).manualA.frame_of_take_off, data(iterA).autoAnn.visStimFrameStart,'Un',0)
        %jump_vect = data(iterA).manualA.frame_of_take_off;
        ind_empty = cellfun('isempty', jump_vect);
        jump_vect(ind_empty) = cellfun(@(x) {nan},jump_vect(ind_empty));
        jump_vect = cell2mat(jump_vect);
    end

    analysis.to_rate(iterA,1) = sum(~isnan(jump_vect));                     % 1 total number analyzed | 2 # jumped | 3 # jumped before foc | 4 % to | 5 % survival
    analysis.to_rate(iterA,2) = sum(jump_vect>0);
    if ~isempty(foc)
        analysis.to_rate(iterA,3) = sum(jump_vect>0 & jump_vect<foc);
    else
        analysis.to_rate(iterA,3) = nan;
    end
    analysis.to_rate(iterA,4) = analysis.to_rate(iterA,2) / analysis.to_rate(iterA,1);
    analysis.to_rate(iterA,5) = analysis.to_rate(iterA,3) / analysis.to_rate(iterA,1);
    if ~isempty(cur_lv)
        analysis.to_rate(iterA,6) = cur_lv;
    else
        analysis.to_rate(iterA,6) = nan;
    end
    
    analysis.exp_list(iterA) = exp_list(iterA);
    
    end
end

% Plot
exp_num = length(analysis.exp_list);

figure, hold on
plot(1:exp_num,analysis.to_rate(:,4),'bo','MarkerFaceColor','b','MarkerEdgeColor','b')
plot(1:exp_num,analysis.to_rate(:,5),'ko','MarkerFaceColor','k','MarkerEdgeColor','k')
set(gca,'ylim',[0 1],'xlim',[0 exp_num+1],...
    'xtick',[1:exp_num],'xticklabel',{''},'FontSize',16)
ylabel('% takeoff')
legend({'All takeoffs'; 'Takeoffs before TOC'})
hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
y=repmat(y,exp_num,1);
hText = text(1:1:exp_num, y, analysis.exp_list,'parent',gca);
set(hText,'Rotation',45,'HorizontalAlignment','right','Color',...
    rgb('black'),'Interpreter','none','fontunits','normalized','fontsize',0.015);

%% 3B) Data Visualization: Escape duration distribution (requires manualAnnotations.mat)

analysis.etho = [];%cell(1,2);

for iterA = 1:length(exp_list)
    
    if ~isempty(data(iterA).curatio)                                        % Make table from the entries that pass curation
        temp = data(iterA).curatio.Raw_Data_Decision;
        name_index = data(iterA).curatio.Properties.RowNames(strcmp('Pass',temp));
        %var_index = find(strcmp('Raw_Data_Decision',data(iterA).curatio.Properties.VariableNames));
        cur_table = data(iterA).curatio(name_index,:);                      % Now save out entire curation table (as of 20140804)
        if isempty(cur_table), continue, end                                % if nothing passes curation, go to next iteration
    else
        disp(['Skipping ',exp_list{iterA},' because no curation table'])
        continue
    end
    if ~isempty(data(iterA).manualA)                                        % Get manual annotations for flies that pass curation
        man_table = data(iterA).manualA(name_index,:);
    else
        % make empty man_table?
    end
    if ~isempty(data(iterA).autoAnn)
        if size(data(iterA).autoAnn,1) == size(data(iterA).curatio,1)       % In the future this should always be true
            aut_table = data(iterA).autoAnn(name_index,:);
        else
            disp(['WARNING: ',exp_list{iterA},' has rawDataAssessment size ',...
                num2str(size(data(iterA).curatio,1)),' but automaticAnnotations size ',...
                num2str(size(data(iterA).autoAnn,1))])
            try 
                aut_table = data(iterA).autoAnn(name_index,:);
            catch
                disp('...and not all flies that passed curation have an entry in autoAnnotation')
            end
            
            add_names = setdiff(name_index,data(iterA).autoAnn.Properties.RowNames);
            temp_table = cell2table(cell(size(add_names,1),size(data(iterA).autoAnn,2)),'RowNames',add_names,'VariableNames',data(iterA).autoAnn.Properties.VariableNames);
            aut_table = [data(iterA).autoAnn; temp_table];
            aut_table = aut_table(name_index,:);

        end
    else
        
    end
    lv = analysis.lv_list(iterA);
    el = str2num(data(iterA).exp_inf.Stimuli_Vars(1).Elevation);
    az = str2num(data(iterA).exp_inf.Stimuli_Vars(1).Azimuth);
    st = analysis.stsize_list(iterA);
    sp = analysis.stopsize_list(iterA);
    ph_del = str2num(data(iterA).exp_inf.Photo_Vars(1).Photo_Delay);
    temp_num = repmat([lv el az st sp ph_del],size(name_index));
    num_table = array2table(temp_num,'RowNames',name_index,'VariableNames',{'lv','el','az','st','sp','ph_del'});
    
    gnA = data(iterA).exp_inf.ParentB_name(1);
    gnB = data(iterA).exp_inf.ParentA_name(1);
    vis = data(iterA).exp_inf.Stimuli_Type(1);
    ph = data(iterA).exp_inf.Photo_Activation{1}(1);
    food = data(iterA).exp_inf.Food_Type(1);
    foil = data(iterA).exp_inf.Foiled(1);
    temp_txt = repmat([gnA gnB vis ph food foil],size(name_index));
    txt_table = cell2table(temp_txt,'RowNames',name_index,'VariableNames',{'gnA','gnB','vis','ph','food','foil'});
    
    temp_table = [cur_table man_table aut_table num_table txt_table];
    analysis.etho = [analysis.etho; temp_table];
    
end


%% SAVE OUT DATA
if save_out_data
    save([save_folder,'saved_data_',exp_ID_to_load,'_',datestr(now,'yyyymmdd_HHMMSS'),'.mat'])
end