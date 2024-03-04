clc
repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(repositoryDir,'Support_Programs'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
saved_exps = load([file_dir filesep 'Saved_Experiments.mat']); 
analysis_path = '\\DM11\cardlab\Data_pez3000_analyzed';
% saved_exps = saved_exps.Saved_Experiments;
% exp_dir = get(saved_exps,'ObsNames');

exp_dir = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir.name),:).name;


%group_name =  {'Ryan Data'};
%group_name =  {'LC4 Silencing'};
%group_name =  {'Martin DN058 Data'};
group_name =  {'Martin DN133 Data'};
%group_name =  {'Pat Control Data'};
%group_name =  {'Pat Parent Data'};
%group_name =  {'Pat DL Data'};
%group_name =  {'Tess GF Test'};
%group_name =  {'Martin DN Testing'};
%group_name =  {'Jan LPLC2 Data'};
%group_name =  {'Jan LPLC2 Data :: Kir'};
%group_name =  {'Jan LPLC2 Data :: TNT'};
%group_name =  {'Martin SS1062 data'};
%group_name =  {'Loom from 180 data'};
%group_name =  {'Loom from azi0 data'};
%group_name =  {'Pat Data :: GF Data'};
%group_name =  {'Tess Data :: CS Data'};
%group_name =  {'Jan Loom / Activation Data'};
%group_name =  {'Wall Data'};
%group_name =  {'Pat Move Testing'};
%group_name =  {'Pat: layout testing'};
%group_name =  {'Pat Off Axis'};

if contains(group_name, {'Ryan Data'})
   exp_dir =  [exp_dir(cellfun(@(x) contains(x,'00001014'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00001074'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00001134'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00001194'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00000664'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00000818'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00000908'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00000143'),exp_dir))];
elseif contains(group_name, {'LC4 Silencing'})
   exp_dir =  [exp_dir(cellfun(@(x) contains(x,'00001823'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00002352'),exp_dir));
    exp_dir(cellfun(@(x) contains(x,'00002497'),exp_dir))];
    
elseif contains(group_name, {'Martin DN058 Data'})
%    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 109,exp_dir));     
%    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) <= 112,exp_dir));     
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 112,exp_dir));     
elseif contains(group_name, {'Martin DN133 Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 48,exp_dir));         
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) <= 112 ,exp_dir));
elseif contains(group_name, {'Martin SS1062 data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) == 109,exp_dir));         
elseif contains(group_name, {'Martin DN Testing'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 67 ,exp_dir));         
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) <= 112 ,exp_dir));
elseif contains(group_name, {'Tess GF Test'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 106,exp_dir));         
elseif contains(group_name, {'Jan LPLC2 Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) == 116,exp_dir));     
elseif contains(group_name, {'Pat Control Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 118, exp_dir));         
%    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 100, exp_dir));
elseif contains(group_name, {'Pat Move Testing'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 135, exp_dir));
elseif contains(group_name, {'Loom from 180 data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 110,exp_dir));
elseif contains(group_name, {'Loom from azi0 data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 107,exp_dir));    
elseif contains(group_name, {'Pat Data :: GF Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 73,exp_dir));
elseif contains(group_name, {'Pat DL Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 150,exp_dir));
elseif contains(group_name, {'Pat Parent Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 68,exp_dir));    
    
    
elseif contains(group_name, {'Jan Loom / Activation Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) == 141,exp_dir));    
elseif contains(group_name, {'Tess Data :: CS Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 120,exp_dir));
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) < 122,exp_dir));
elseif contains(group_name, {'Wall Data'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 143,exp_dir));    
elseif contains(group_name,{'Pat: layout testing'})
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 140,exp_dir));    
elseif contains(group_name,{'Pat Off Axis'})    
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) == 212,exp_dir));    
else
    exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 48,exp_dir));
end
filt_list = exp_dir;

clear results
%%
rem_entry = [];
for iterA = 1:length(filt_list)
    try
        results(iterA,:) = parse_expid_v2(filt_list{iterA}); %#ok<SAGROW>
    catch
        rem_entry = [rem_entry;iterA]; %#ok<AGROW>
        continue
    end
end
filt_list(rem_entry) = [];
results(rem_entry,:) = [];
results = set(results,'ObsNames',filt_list);
%loom_results = [];
%chrim_results = [];
%%
% Incubator_info = struct2dataset(results.Incubator_Info);
% incubator_logic = cellfun(@(x) contains(x,'Resources #3') | contains(x,'Resources #4') | contains(x,'Incubator :: #BB') | contains(x,'Incubator :: #DD'),Incubator_info.Name);
% results = results(incubator_logic,:);

parent_A_logic = cellfun(@(x) contains(x,'1117481'),results.ParentA_ID);
parent_B_logic = cellfun(@(x) contains(x,'1117481'),results.ParentB_ID);
Kir_logic = parent_A_logic | parent_B_logic;

parent_A_logic = cellfun(@(x) contains(x,'1150416'),results.ParentA_ID);
parent_B_logic = cellfun(@(x) contains(x,'1150416'),results.ParentB_ID);
Chrim_logic = parent_A_logic | parent_B_logic;

DL_data  = results(cellfun(@(x) contains(x,'1500090'),results.ParentA_ID) & cellfun(@(x) contains(x,'1500090'),results.ParentB_ID),:);
DL_data = DL_data(cellfun(@(x) str2double(x(1:4)) >= 80,get(DL_data,'ObsNames')),:);

%%
chrim_results  = [];
loom_results = results;
if strcmp(group_name, {'Pat: layout testing'})
    %brings in all data from collection 138+ regardless of what it is or
    %stimuli
    chrim_results  = [];
    loom_results = results;
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90_lv40'),loom_results.Stimuli_Type),:);
elseif contains(group_name,{'Pat Off Axis'})
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'1500090'),loom_results.ParentA_ID) & cellfun(@(x) contains(x,'1500090'),loom_results.ParentB_ID),:);            
    
elseif strcmp(group_name, {'Pat Parent Data'})
    %brings in all data from collection 138+ regardless of what it is or
    %stimuli
    chrim_results  = [];
    loom_results = results(cellfun(@(x,y) strcmp(x,y), results.ParentA_ID, results.ParentB_ID),:);
    loom_results(cellfun(@(x) contains(x,'Card'),loom_results.ParentA_ID),:) = [];
    loom_results(cellfun(@(x) str2double(x) == 0,loom_results.ParentA_ID),:) = [];
    loom_results(cellfun(@(x) str2double(x) == 1117481,loom_results.ParentA_ID),:) = [];
    loom_results(cellfun(@(x) str2double(x) == 2135384,loom_results.ParentA_ID),:) = [];
    loom_results(cellfun(@(x) str2double(x) == 3005229,loom_results.ParentA_ID),:) = [];
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
%    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),[0,45,90,135,180]);
%    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),0);
    logic_1 = str2double(loom_info.Elevation) == 45;
    loom_results = loom_results(logic_1,:);      
    loom_results = loom_results(cellfun(@(x) contains(x,'Breadsp'),loom_results.User_ID),:);
        
elseif strcmp(group_name, {'Wall Data'})
    chrim_results  = [];
    loom_results = results;
    loom_results = loom_results(cellfun(@(x,y) contains(x,'1500090') & contains(y,'1500090'),loom_results.ParentA_ID ,loom_results.ParentB_ID),:);     % dl x dl
    loom_results = loom_results(cellfun(@(x) contains(x,'Standard (Cornmeal)'),loom_results.Food_Type),:);                      %only cornmeal food
    
%    loom_results = loom_results(cellfun(@(x) contains(x,'wall'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90_lv40'),loom_results.Stimuli_Type),:);
    loom_results(cellfun(@(x) iscell(x),loom_results.Photo_Activation),:) = [];     %remove combo chrim stimuli    
    loom_results(cellfun(@(x) contains(x,'pez'),loom_results.Collection_Name),:) = [];
    loom_results(cellfun(@(x) contains(x,'Pez'),loom_results.Collection_Name),:) = [];
    
loom_results(cellfun(@(x) str2double(x(1:4)) == 145,get(loom_results,'ObsNames')),:) = [];       %non walll runs
loom_results(cellfun(@(x) str2double(x(1:4)) == 146,get(loom_results,'ObsNames')),:) = [];       %non walll runs
loom_results(cellfun(@(x) str2double(x(1:4)) == 150,get(loom_results,'ObsNames')),:) = [];       %non walll runs
loom_results(cellfun(@(x) str2double(x(1:4)) == 192,get(loom_results,'ObsNames')),:) = [];       %non walll runs  
loom_results(cellfun(@(x) str2double(x(1:4)) == 204,get(loom_results,'ObsNames')),:) = [];       %various wall sizes
    
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    logic_1 = str2double(loom_info.Elevation) == 45;
    loom_results = loom_results(logic_1,:);    

elseif strcmp(group_name, {'Jan LPLC2 Data :: Kir'})
    chrim_results  = [];
    loom_results = results;    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results(cellfun(@(x) contains(x,'GMR_SS00797'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'GMR_SS00315'),loom_results.ParentA_name),:) = [];
%    loom_results(cellfun(@(x) contains(x,'JRC_SS27721'),loom_results.ParentA_name),:) = [];   
    loom_results = loom_results(cellfun(@(x) contains(x,'Kir'),loom_results.ParentB_name),:);
elseif strcmp(group_name, {'Jan LPLC2 Data :: TNT'})
    chrim_results  = [];
    loom_results = results;    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results(cellfun(@(x) contains(x,'GMR_SS00797'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'GMR_SS00315'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'JRC_SS27721'),loom_results.ParentA_name),:) = [];
    loom_results = loom_results(cellfun(@(x) contains(x,'TNT'),loom_results.ParentB_name),:);        
elseif strcmp(group_name, {'Jan LPLC2 Data'})
    chrim_results  = [];
    loom_results = results;    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results(cellfun(@(x) contains(x,'GMR_SS00797'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'GMR_SS00315'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'JRC_SS27721'),loom_results.ParentA_name),:) = [];   
elseif strcmp(group_name, {'Jan Loom / Activation Data'})
    chrim_results  = [];
    loom_results = results;    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_5to90') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results(cellfun(@(x) contains(x,'Dark'),loom_results.Food_Type),:) = [];
elseif strcmp(group_name, {'Pat DL Data'})
%    chrim_results  = [];
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(cellfun(@(x) contains(x,'0430'),get(loom_results,'ObsNames')),:);
    loom_results = loom_results(cellfun(@(x) contains(x,'(Cornmeal)'),loom_results.Food_Type),:);        
    
    loom_results(cellfun(@(x) str2double(x(1:4)) == 121,get(loom_results,'ObsNames')),:) = [];       %training data    
elseif strcmp(group_name, {'Tess Data :: CS Data'})
%    chrim_results  = [];
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(cellfun(@(x) contains(x,'2527'),get(loom_results,'ObsNames')),:);
    
    loom_results = loom_results(cell2mat(loom_results.Males) == 1 & cell2mat(loom_results.Females) == 1,:);
elseif strcmp(group_name, {'Pat Control Data'})
%    chrim_results  = [];
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(str2double(loom_results.ParentA_ID) == str2double(loom_results.ParentB_ID),:);

    loom_results(cellfun(@(x) contains(x,'25190773'),get(loom_results,'ObsNames')),:) = [];    
    loom_results = loom_results(cell2mat(loom_results.Males) == 1 & cell2mat(loom_results.Females) == 1,:);
    
    loom_results(cellfun(@(x) contains(x,'1117481'),loom_results.ParentA_ID),:) = [];    
    loom_results(cellfun(@(x) contains(x,'Card114'),loom_results.ParentA_ID),:) = [];    
    loom_results(cellfun(@(x) contains(x,'Card115'),loom_results.ParentA_ID),:) = [];    
    loom_results(cellfun(@(x) contains(x,'2135384'),loom_results.ParentA_ID),:) = [];    
    loom_results(cellfun(@(x) contains(x,'Card116'),loom_results.ParentA_ID),:) = [];    
    
    loom_results(cellfun(@(x) strcmp(x,'FCF_DL_1500090'),loom_results.ParentA_name),:) = [];    
    loom_results(cellfun(@(x) strcmp(x,'CTRL_DL_1500090_0028'),loom_results.ParentA_name),:) = [];    

    loom_info = struct2dataset(loom_results.Stimuli_Vars);

    

elseif strcmp(group_name,{'Pat Move Testing'})
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);

    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    logic_1 = str2double(loom_info.Elevation) == 45;
    loom_results = loom_results(logic_1,:);
    
    
elseif strcmp(group_name,{'Pat Data :: GF Data'})
    loom_results = results(Kir_logic,:);
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using        
 
%     loom_info = struct2dataset(loom_results.Stimuli_Vars);
%     %logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),0);
%     logic_1 = str2double(loom_info.Elevation) == 45;
%     loom_results = loom_results(logic_1,:);

    
    
    chrim_results = results(Chrim_logic,:);
    chrim_results = chrim_results(cellfun(@(x) length(x) == 3,chrim_results.Photo_Activation),:);
    chrim_results = chrim_results(cellfun(@(x) contains(x,'Retinal (1:250)') | contains(x,'Retinal (1:500)'),chrim_results.Food_Type),:);
    chrim_proto = cellfun(@(x) x{1},chrim_results.Photo_Activation,'uniformoutput',false);
    chrim_results = chrim_results( cellfun(@(x) contains(x,'pulse_General_widthBegin50_widthEnd50_'),chrim_proto),:);
    chrim_results(cellfun(@(x) str2double(x(1:4)) == 52,get(chrim_results,'ObsNames')),:) = [];       %multi cycle chrimson, dont want for this grouping    

    chrim_results = chrim_results(cellfun(@(x) contains(x,'1500487'),chrim_results.ParentA_ID),:);    
    loom_results = loom_results(cellfun(@(x) contains(x,'1500487'),loom_results.ParentA_ID),:);    

    
elseif strcmp(group_name, {'Tess GF Test'})
    loom_results = results(cellfun(@(x) contains(x,'GFR#4'),results.ParentA_name),:);
    chrim_results = [];
elseif strcmp(group_name, {'Martin DNp11 data'})
    loom_results = results(Kir_logic,:);
    chrim_results = [];
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using    

    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),90);
    loom_results = loom_results(logic_1,:);

    
    dn_p11 = {'SS49010';'SS49024';'SS49051'};
    matching_robot_ids = unique(loom_results(cellfun(@(x) contains(x,dn_p11),loom_results.ParentA_name),:).ParentA_ID);
    loom_results = [loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentA_ID),:);loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentB_ID),:)];
elseif strcmp(group_name, {'Loom from 180 data'})
    %loom_results = results(Kir_logic,:);
    loom_results = results;
    chrim_results = [];
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),180);
    loom_results = loom_results(logic_1,:);
elseif strcmp(group_name, {'Loom from azi0 data'})
    %loom_results = results(Kir_logic,:);
    loom_results = results;
%    chrim_results = [];
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),0);
    loom_results = loom_results(logic_1,:);    
    
    parent_A_logic = cellfun(@(x) contains(x,'3017823'),loom_results.ParentA_ID);
    parent_B_logic = cellfun(@(x) contains(x,'3017823'),loom_results.ParentB_ID);
    TNT_logic = parent_A_logic | parent_B_logic;
    loom_results(TNT_logic,:) = [];
    loom_results(cellfun(@(x) contains(x,'tdtomato'),loom_results.ParentB_genotype),:) = [];
    loom_results(cellfun(@(x) contains(x,'OL0048B'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'0797'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'UAH_R_1220003'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'FCF_OregonR_1500001'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'FCF_pBDPGAL4U_1500437'),loom_results.ParentA_name),:) = [];
    loom_results(cellfun(@(x) contains(x,'DL_UAS_Kir21_3_0090'),loom_results.ParentA_name),:) = [];
    
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 100 & str2double(x(1:4)) <= 105,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 82 & str2double(x(1:4)) <= 96,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 110 & str2double(x(1:4)) <= 112,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) == 117 ,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) == 77 ,get(loom_results,'ObsNames')),:) = [];
    
    chrim_results = results(Chrim_logic,:);
    chrim_results = chrim_results(cellfun(@(x) length(x) == 3,chrim_results.Photo_Activation),:);
    chrim_results = chrim_results(cellfun(@(x) contains(x,'Retinal (1:250)') | contains(x,'Retinal (1:500)'),chrim_results.Food_Type),:);
    chrim_proto = cellfun(@(x) x{1},chrim_results.Photo_Activation,'uniformoutput',false);
    chrim_results = chrim_results( cellfun(@(x) contains(x,'pulse_General_widthBegin50_widthEnd50_'),chrim_proto),:);
    chrim_results(cellfun(@(x) str2double(x(1:4)) == 52,get(chrim_results,'ObsNames')),:) = [];       %multi cycle chrimson, dont want for this grouping    

    chrim_results = chrim_results(cellfun(@(x) contains(x,'1500487'),chrim_results.ParentA_ID),:);    

elseif strcmp(group_name, {'Martin SS1062 data'})
    loom_results = results(Kir_logic,:);
    chrim_results = [];
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using    

    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),90);
    loom_results = loom_results(logic_1,:);

    
%    ss_1062 = {'SS01062'};
%    matching_robot_ids = unique(loom_results(cellfun(@(x) contains(x,ss_1062),loom_results.ParentA_name),:).ParentA_ID);
    matching_robot_ids = {'1500090'};
    loom_results = [loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentA_ID),:);loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentB_ID),:)];
          
elseif strcmp(group_name, {'Martin DN Testing'})
    loom_results = results(Kir_logic,:);
%    chrim_results = results(Chrim_logic,:);
    chrim_results = [];
    
%     chrim_results = chrim_results(cellfun(@(x) length(x) == 3,chrim_results.Photo_Activation),:);
%     chrim_results = chrim_results(cellfun(@(x) contains(x,'Retinal (1:250)') | contains(x,'Retinal (1:500)'),chrim_results.Food_Type),:);
%     chrim_proto = cellfun(@(x) x{1},chrim_results.Photo_Activation,'uniformoutput',false);
%     chrim_results = chrim_results( cellfun(@(x) contains(x,'pulse_General_widthBegin50_widthEnd50_'),chrim_proto),:);
%     chrim_results(cellfun(@(x) str2double(x(1:4)) == 52,get(chrim_results,'ObsNames')),:) = [];       %multi cycle chrimson, dont want for this grouping    
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    
     logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),[0,90,180]);
     loom_results = loom_results(logic_1,:);
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using    
%    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv10') | contains(x,'loom_10to180_lv20') |...
%        contains(x,'loom_10to180_lv40') | contains(x,'loom_10to180_lv80') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);

    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) contains(x,'lv100'),loom_results.Stimuli_Type),:) = [];    

        
    dn_to_add = {'SS49010';'SS49024';'SS49051';'SS01544';'3015814';'3016853';'3015823'};
    add_ids = unique(loom_results(cellfun(@(x) contains(x,dn_to_add),loom_results.ParentA_name),:).ParentA_ID);

%    matching_robot_ids = {'3015814';'3015841';'3015843';'3016853';'3018158';'3018122';'3013846';'1500090';'3015823'};
%    matching_robot_ids = {'3015814';'3015841';'3015843';'3016853';'3018158';'3018122';'3013846';'3015823'};
%    matching_robot_ids = [matching_robot_ids;add_ids];
%    matching_robot_ids = unique(matching_robot_ids);

    loom_results = [loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentA_ID),:);loom_results(cellfun(@(x) contains(x,matching_robot_ids),loom_results.ParentB_ID),:)];        
    
    loom_results(cellfun(@(x) str2double(x(1:4)) == 117,get(loom_results,'ObsNames')),:) = [];       %tess testing, dont need for this set
elseif strcmp(group_name,{'Martin DN133 Data'})
    loom_results = results(Kir_logic,:);
    chrim_results = [];
       
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    
%    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),90);
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DN058_robot_ids = unique(loom_results(cellfun(@(x)  contains(x,'SS01053') | contains(x,'SS01554'),loom_results.ParentA_name),:).ParentA_ID);
%    DN058_robot_ids = unique(loom_results(cellfun(@(x) contains(x,'SS02292') | contains(x,'SS01544') | contains(x,'SS49010') | contains(x,'SS49024')| contains(x,'SS49051') | ...
%                                                       contains(x,'SS01053') | contains(x,'SS01554') | contains(x,'SS00934') | contains(x,'SS01080')| contains(x,'SS02256'),loom_results.ParentA_name),:).ParentA_ID);
%    control_robot_ids = [{'3007648'};{'3015823'};{'1500090'};{'1500487'}];
%    control_robot_ids = [{'3007648'};{'3015823'};{'1500090'}];
    %                         GF         1062         DL 

    dn_58_loom_results = [loom_results(cellfun(@(x) contains(x,DN058_robot_ids),loom_results.ParentA_ID),:);loom_results(cellfun(@(x) contains(x,DN058_robot_ids),loom_results.ParentB_ID),:)];
    
    loom_match = loom_results(ismember(cellfun(@(x) x(1:4),get(loom_results,'ObsNames'),'UniformOutput',false),cellfun(@(x) x(1:4),get(dn_58_loom_results,'ObsNames'),'UniformOutput',false)),:);
%    ctrl_loom_results = [loom_match(cellfun(@(x) contains(x,control_robot_ids),loom_match.ParentA_ID),:);loom_match(cellfun(@(x) contains(x,control_robot_ids),loom_match.ParentB_ID),:)];
    
%    loom_results = [dn_58_loom_results;ctrl_loom_results];
    loom_results = dn_58_loom_results;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%     dn_58_chrim_results = [chrim_results(cellfun(@(x) contains(x,DN058_robot_ids),chrim_results.ParentA_ID),:);chrim_results(cellfun(@(x) contains(x,DN058_robot_ids),chrim_results.ParentB_ID),:)];        
% 
%     chrim_match = chrim_results(ismember(cellfun(@(x) x(1:4),get(chrim_results,'ObsNames'),'UniformOutput',false),cellfun(@(x) x(1:4),get(dn_58_chrim_results,'ObsNames'),'UniformOutput',false)),:);
%     ctrl_chrim_results = [chrim_match(cellfun(@(x) contains(x,control_robot_ids),chrim_match.ParentA_ID),:);chrim_match(cellfun(@(x) contains(x,control_robot_ids),chrim_match.ParentB_ID),:)];
%     
%     chrim_results = [dn_58_chrim_results;ctrl_chrim_results];    
    
elseif strcmp(group_name,{'Martin DN058 Data'})
    loom_results = results(Kir_logic,:);
%    chrim_results = results(Chrim_logic,:);
    chrim_results = [];
    
%     chrim_results = chrim_results(cellfun(@(x) length(x) == 3,chrim_results.Photo_Activation),:);
%     chrim_results = chrim_results(cellfun(@(x) contains(x,'Retinal (1:250)') | contains(x,'Retinal (1:500)'),chrim_results.Food_Type),:);
%     chrim_proto = cellfun(@(x) x{1},chrim_results.Photo_Activation,'uniformoutput',false);
%     chrim_results = chrim_results( cellfun(@(x) contains(x,'pulse_General_widthBegin50_widthEnd50_'),chrim_proto),:);
%     chrim_results(cellfun(@(x) str2double(x(1:4)) == 52,get(chrim_results,'ObsNames')),:) = [];       %multi cycle chrimson, dont want for this grouping    
    
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    
    logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),90);
%    loom_results = loom_results(logic_1,:);
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    
    loom_results(cellfun(@(x) str2double(x(13:16)) == 594,get(loom_results,'ObsNames')),:) = [];        %evening incubator, not using    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DN058_robot_ids = unique(loom_results(cellfun(@(x)  contains(x,'SS49010') | contains(x,'SS49024')| contains(x,'SS49051') |...
                     contains(x,'SS01053') | contains(x,'SS01554') | contains(x,'SS01062'),loom_results.ParentA_name),:).ParentA_ID);
%    DN058_robot_ids = unique(loom_results(cellfun(@(x) contains(x,'SS02292') | contains(x,'SS01544') | contains(x,'SS49010') | contains(x,'SS49024')| contains(x,'SS49051') | ...
%                                                       contains(x,'SS01053') | contains(x,'SS01554') | contains(x,'SS00934') | contains(x,'SS01080')| contains(x,'SS02256'),loom_results.ParentA_name),:).ParentA_ID);
%    control_robot_ids = [{'3007648'};{'3015823'};{'1500090'};{'1500487'}];
%    control_robot_ids = [{'3007648'};{'3015823'};{'1500090'}];
    %                         GF         1062         DL 

    dn_58_loom_results = [loom_results(cellfun(@(x) contains(x,DN058_robot_ids),loom_results.ParentA_ID),:);loom_results(cellfun(@(x) contains(x,DN058_robot_ids),loom_results.ParentB_ID),:)];
    
    loom_match = loom_results(ismember(cellfun(@(x) x(1:4),get(loom_results,'ObsNames'),'UniformOutput',false),cellfun(@(x) x(1:4),get(dn_58_loom_results,'ObsNames'),'UniformOutput',false)),:);
%    ctrl_loom_results = [loom_match(cellfun(@(x) contains(x,control_robot_ids),loom_match.ParentA_ID),:);loom_match(cellfun(@(x) contains(x,control_robot_ids),loom_match.ParentB_ID),:)];
    
%    loom_results = [dn_58_loom_results;ctrl_loom_results];
    loom_results = dn_58_loom_results;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%     dn_58_chrim_results = [chrim_results(cellfun(@(x) contains(x,DN058_robot_ids),chrim_results.ParentA_ID),:);chrim_results(cellfun(@(x) contains(x,DN058_robot_ids),chrim_results.ParentB_ID),:)];        
% 
%     chrim_match = chrim_results(ismember(cellfun(@(x) x(1:4),get(chrim_results,'ObsNames'),'UniformOutput',false),cellfun(@(x) x(1:4),get(dn_58_chrim_results,'ObsNames'),'UniformOutput',false)),:);
%     ctrl_chrim_results = [chrim_match(cellfun(@(x) contains(x,control_robot_ids),chrim_match.ParentA_ID),:);chrim_match(cellfun(@(x) contains(x,control_robot_ids),chrim_match.ParentB_ID),:)];
%     
%     chrim_results = [dn_58_chrim_results;ctrl_chrim_results];    
elseif strcmp(group_name,{'Pat Control Data'})
    %loom_results = results(Kir_logic,:);
    loom_results = results;
    loom_results = loom_results(cellfun(@(x) contains(x,'loom_10to180_lv40') & contains(x,'blackonwhite'),loom_results.Stimuli_Type),:);
    loom_results = loom_results(cellfun(@(x) ~contains(x,'grayDome'),loom_results.Stimuli_Type),:);    

    control_robot_ids_par_A = [{'3015823'};{'1500090'};{'1117481'}];
    control_robot_ids_par_B = [{'3015823'};{'1500090'};{'1117481'}];
    
    parent_a_logic = cellfun(@(x) contains(x,control_robot_ids_par_A),loom_results.ParentA_ID);
    parent_b_logic = cellfun(@(x) contains(x,control_robot_ids_par_B),loom_results.ParentB_ID);
    loom_results = loom_results(parent_a_logic & parent_b_logic,:);
    
    loom_info = struct2dataset(loom_results.Stimuli_Vars);
    %logic_1 = str2double(loom_info.Elevation) == 45 & ismember(str2double(loom_info.Azimuth),[0,45,90,135,180]);
    logic_1 = str2double(loom_info.Elevation) == 45;
    loom_results = loom_results(logic_1,:);
    loom_results(cellfun(@(x) contains(x,'00001706') | contains(x,'00001707'),get(loom_results,'ObsNames')),:) = [];
    
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 57 & str2double(x(1:4)) <=  80,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 82 & str2double(x(1:4)) <=  105,get(loom_results,'ObsNames')),:) = [];
    loom_results(cellfun(@(x) str2double(x(1:4)) >= 107 & str2double(x(1:4)) <=  117,get(loom_results,'ObsNames')),:) = [];
end
%%
filt_results = [loom_results;chrim_results];

filt_results(cellfun(@(x) str2double(x(1:4)) == 89,get(filt_results,'ObsNames')),:) = [];       %dome testing
filt_results(cellfun(@(x) str2double(x(1:4)) == 93,get(filt_results,'ObsNames')),:) = [];       %dome testing
filt_results(cellfun(@(x) str2double(x(1:4)) == 94,get(filt_results,'ObsNames')),:) = [];       %training data
filt_results(cellfun(@(x) str2double(x(1:4)) == 99,get(filt_results,'ObsNames')),:) = [];       %training data
filt_results(cellfun(@(x) str2double(x(1:4)) == 100,get(filt_results,'ObsNames')),:) = [];       %training data

filt_results(cellfun(@(x) str2double(x(1:4)) == 173,get(filt_results,'ObsNames')),:) = [];       %training data
filt_results(cellfun(@(x) str2double(x(1:4)) == 123,get(filt_results,'ObsNames')),:) = [];       %training data
filt_results(cellfun(@(x) str2double(x(1:4)) == 1707,get(filt_results,'ObsNames')),:) = [];       %SS1062 X DL
%%
group_res = filt_results;    
group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],get(group_res,'ObsNames'),'uniformoutput',false);

group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');

col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
entry = cell(1,3);                       
entry(1,1) = {'Breadsp'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
%entry(1,1) = {'Oramt'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
%entry(1,1) = {'Peekm'};                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
entries = cell2table(entry);             entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;            

group_ids = group_ids.Saved_Group_IDs;
group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];
%Saved_Group_IDs = group_ids;
Saved_Group_IDs = [group_ids;entries];
save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');
clear all %#ok<CLALL>
clc