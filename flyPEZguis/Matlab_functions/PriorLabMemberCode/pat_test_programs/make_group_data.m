
clear all
clc
repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
saved_exps = load([file_dir filesep 'Saved_Experiments.mat']); 
saved_exps = saved_exps.Saved_Experiments;
exp_dir = get(saved_exps,'ObsNames');

%group_name = {'Katie Lv 20'};
%group_name = {'Katie Lv 40'};
%group_name = {'Katie Lv 10'};
group_name = {'Katie Lv 80'};

%group_name = {'Martin Kir All'};
%group_name = {'Martin Kir Group 3'};
%group_name = {'Martin Kir Chrim Group'};

%group_name = {'Ryan DL Data'};

if ~strcmp(group_name,'Ryan DL Data')
    filt_list = exp_dir(cellfun(@(x) strcmp(x(1:4),'0024'),exp_dir));
else
    filt_list = [{'0032000004300578'};{'0032000004300577'};{'0066000004300576'};{'0066000004300575'};...
        {'0044000004300574'};{'0044000004300573'};{'0044000004300572'}];
end


for iterA = 1:length(filt_list)
    try
        results(iterA,:) = parse_expid_v2(filt_list{iterA});
    catch
        warning('error')
    end
end
results = set(results,'ObsNames',filt_list);         
stim_info = struct2dataset(vertcat(results.Stimuli_Vars(:)));

if cellfun(@(x) ~isempty(strfind(x,'Martin')),group_name)
    group_1_list =[{'JRC_SS04519'};{'JRC_SS04521'};{'BJD_SS00857GMR_SS00857'}];
    group_2_list = [{'JRC_SS04520'};{'GMR_OL0015B'};{'GMR_SS00510'}];
    group_3_list = [{'GMR_SS00584'};{'JRC_SS04529'};{'GMR_76B06_AE_01'};{'SS01586'};{'GMR_SS01586'}];

    if strcmp(group_name,('Martin Kir Group 1'));
        exp_list = group_1_list;
    elseif strcmp(group_name,('Martin Kir Group 2'));
        exp_list = group_2_list;
    elseif strcmp(group_name,('Martin Kir Group 3'));
        exp_list = group_3_list;
    elseif strcmp(group_name,('Martin Kir Chrim Group'));
        exp_list = [group_1_list;group_2_list;group_3_list];
    elseif strcmp(group_name,('Martin Kir All'));
        exp_list = [group_1_list;group_2_list;group_3_list];
        
    end

    ctrl_list = [{'17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)'};{'CTRL_DL_1500090_0028FCF_DL_1500090'};{'GMR_SS00797'}];
    ctrl_loom = {'loom_10to180_lv40_blackonwhite'};

    if strcmp(group_name,('Martin Kir Chrim Group'));
        chrim_logic = strcmp(results.ParentB_name,'UAS_Chrimson_Venus_X_0070');
        Ctrl_logic = ismember(results.ParentA_name,ctrl_list);

        ctrl_experiments = results(Ctrl_logic & chrim_logic,:);    
        exp_experiments = results(ismember(results.ParentA_name,exp_list) & chrim_logic,:);
    else
        Stim_logic = strcmp(stim_info.Elevation,'45') & strcmp(stim_info.Azimuth,'45');
        Ctrl_logic = ismember(results.ParentA_name,ctrl_list) & ismember(results.Stimuli_Type,ctrl_loom);

        ctrl_experiments = results(Ctrl_logic & Stim_logic,:);
        exp_experiments = results(ismember(results.ParentA_name,exp_list) & Stim_logic,:);
    end

    group_res = [ctrl_experiments;exp_experiments];
    %group_res = exp_experiments;

    remove_list = [{'0073000022390344'};{'0073000022260345'};{'0073000022270345'};{'0073000019660345'}];

    group_res = group_res(~ismember(get(group_res,'ObsNames'),remove_list),:);
elseif cellfun(@(x) ~isempty(strfind(x,'Katie')),group_name)
    if strcmp(group_name,('Katie Lv 20'));
       lv_20_logic = cellfun(@(x) ~isempty(strfind(x,'lv20')),results.Stimuli_Type);
       group_res = results(lv_20_logic,:);
    elseif strcmp(group_name,('Katie Lv 40'));
        lv_40_logic = cellfun(@(x) ~isempty(strfind(x,'lv40')),results.Stimuli_Type);
        group_res = results(lv_40_logic,:);
    elseif strcmp(group_name,('Katie Lv 80'));
        lv_40_logic = cellfun(@(x) ~isempty(strfind(x,'lv80')),results.Stimuli_Type);
        group_res = results(lv_40_logic,:);
        
    elseif strcmp(group_name,('Katie Lv 10'));
        lv_10_logic = cellfun(@(x) ~isempty(strfind(x,'lv10')),results.Stimuli_Type);
        group_res = results(lv_10_logic,:);
        
        stim_vars = struct2dataset(group_res.Stimuli_Vars);
        correct_logic = str2double(stim_vars.Azimuth) == 45;
%        group_res = group_res(correct_logic,:);
        
        remove_list = {'0075000022560580'};
        group_res = group_res(~ismember(get(group_res,'ObsNames'),remove_list),:);
        
    end
else
    group_res = results;
end

group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],get(group_res,'ObsNames'),'uniformoutput',false);
group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');

col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
entry = cell(1,3);                       
entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                    entry(1,3) = {'Active'};
entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

group_ids = group_ids.Saved_Group_IDs;
group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
%Saved_Group_IDs = group_ids;
Saved_Group_IDs = [group_ids;entries];
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');