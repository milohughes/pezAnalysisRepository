function Experiment_setup_gui
repositoryDir = fileparts(fileparts(mfilename('fullpath')));
%addpath(fullfile(repositoryDir,'Support_Programs'))

screen2use = 1;         % in multi screen setup, this determines which screen to be used
screen2cvr = 0.85;       % portion of the screen to cover

monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets labels and background
backColor = [0 0 0.2];
ID_Label = [{'Designer ID'};{'Collection ID'};{'Genotype ID'};{'Protocol ID'};{'Experiment_ID'}];
label_defaults = [{'Janelia ID'};{'Collection ID'};{'Genotype ID'};{'Protocol ID'};{'0000000000000000'}];
desigen_info = [{'Designer Full Name'};{'Desk Location'};{'Phone Number'};{'Janelia Email'}];
Genotype_labels = [{'Parent A'};{'Parent B'};{'Genders Included'};{'Balancers'}];

FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
    (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
figure('NumberTitle','off','Name','Experimental Design Gui',...
    'menubar','none','units','pix','Color',backColor,'pos',FigPos,'colormap',gray(256));
hPanA = uipanel('Position',[0.00 3/4 1.0 1/4],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP LEFT PANNEL
hPanB = uipanel('Position',[0.70 3/4 1.0 1/4],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP RIGHT PANNEL
hPanD = uipanel('Position',[0.00 .70 1.0 1/20],'Visible','On','BackgroundColor',rgb('light grey'));     %TOP MIDDLE (FULL LENGTH)
hPanG = uipanel('Position',[0.00 0.0 1.0 1/10],'Visible','On','BackgroundColor',rgb('light grey'));     %BOTTOM PANNEL (FULL LENGTH)

hPanE = uipanel('Position',[0.00 .425 1.0 .225],'Visible','On','BackgroundColor',rgb('light grey'));    %GENDER/GENOTYPE PANNEL
hPanW = uipanel('Position',[0.00 .650 1.0 .050],'Visible','On','BackgroundColor',rgb('light grey'));    %WARNING / STATUS PANNEL

hPanF = uipanel('Position',[0.00 .100 1.0 .325],'Visible','On','BackgroundColor',rgb('light grey'));    %HANDLE/REARING PROTOCOL PANNEL
hPanC = uipanel('Position',[0.70 .100 1.0 .650],'Visible','On','BackgroundColor',rgb('light grey'));    %PANNEL FOR BROWSING AND ADDING
hTable = uitable('Parent',hPanC,'visible','off');
hbrowselist = uicontrol(hPanC,'Style','listbox','string','','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.0204,'position',[0 .025 .3 .95]);
hbrowseproto = uicontrol(hPanC,'Style','listbox','string','','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.0408,'position',[0 .025 .3 .470],'visible','off');
browse_pan = uicontrol(hPanC,'Style','text','string','','visible','off','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0 .975 .200 .025]);
hSelectUser = uicontrol(hPanC,'Style','pushbutton','string','Select','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[.200 .975 .100 .025],'callback',@updatefields,'Visible','off');
op_sys = system_dependent('getos');

hbrowse_IDS = uicontrol(hPanC,'Style','listbox','string','','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.0175,'position',[0 .025 .0400 .95],'visible','off','callback',@selectgenotype);
hid_name = uicontrol(hPanC,'Style','text','string','Robot_ID','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7500,'position',[0 .975 .0400 .025],'visible','off');
hbrowse_Stocks = uicontrol(hPanC,'Style','listbox','string','','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.0175,'position',[.0400 .025 .110 .95],'visible','off','callback',@selectgenotype);
hstock_name = uicontrol(hPanC,'Style','text','string','Stock Name','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7500,'position',[.0400 .975 .110 .025],'visible','off');
hbrowse_Other = uicontrol(hPanC,'Style','listbox','string','','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.0175,'position',[.150 .025 .150 .95],'visible','off','callback',@selectgenotype);
hother_name = uicontrol(hPanC,'Style','text','string','More Information','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7500,'position',[.150 .975 .150 .025],'visible','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets variables

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
file_dir = fullfile(fileDir,'Pez3000_Gui_folder','Gui_saved_variables');
dateDir =   fullfile(fileDir,'data_all');
stim_path = fullfile(fileDir,'pez3000_variables','visual_stimuli');
photo_path = fullfile(fileDir,'pez3000_variables','photoactivation_stimuli');

file_path_users = 'Saved_User_names.mat';
file_path_collection = 'Saved_Collection.mat';
file_path_genotype =   'Saved_Genotypes.mat';
file_path_protocol_new = 'Saved_Protocols_new_version.mat';
file_path_experiments = 'Saved_Experiments.mat';
file_path_lines = 'Saved_User_Lines.mat';

%    Saved_Protocols_new_version = [];

Saved_User_names   = load_variables(file_dir, file_path_users,'users');
Saved_Collection =  load_variables(file_dir, file_path_collection,'collection');
Saved_Genotypes   = load_variables(file_dir, file_path_genotype,'genotype');
%    Saved_Protocols = load_variables(file_dir, file_path_protocol,'protocol');
Saved_Protocols_new_version = load_variables(file_dir, file_path_protocol_new,'protocol_new');
Saved_Experiments = load_variables(file_dir, file_path_experiments,'experiment');
Saved_User_Lines = load_variables(file_dir, file_path_lines,'lines');

Saved_Groups = load_variables(file_dir, 'Saved_Group_IDs.mat','groups');
user_names = Saved_User_names;

incubator_list = load([file_dir filesep 'Saved_Incubators.mat']);
Saved_Incubators = incubator_list.incubatorList;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set up Variables

hTlabels = zeros(4,1);                          hTdropdown = zeros(4,1);                hDesign = zeros(4,1);
hTbrowsebutton = zeros(4,1);                    hTaddbutton = zeros(4,1);               hJlbhA =  cell(1,3);
hTdropdown_Robot_ID = zeros(2,1);               hTdropdown_genotype_name = zeros(2,1);
hTbrowse_genotype = zeros(2,1);                 hTadd_genotype = zeros(2,1);            current_protocol = [];
genotype_list = [];                             hNewLine = [];                          hStocklabel = [];
hGenolabel = [];                                hLineLabel = [];                        full_collection = [];
hTdropdown_protocol = zeros(3,1);               srch_button = [];                       srch_field = [];
name_index = 0;                                 parent_index = 0;                       hGender = zeros(2,1);
hBalance = zeros(3,1);                          collection_edit_flag = 0;               hNewGeno = [];
hcanceladd = [];                                hcheckadd = [];                         genotype_subset = [];
hFname = [];                                    hLname = [];                            user_text = [];
name_entry = [];                                current_collection = [];                saved_geno_ids = [];
runs_per_day = 0;                               vids_per_run = 0;                       one_fly_rate = .60;
browseflag = 'All';                             showflag = 'All';                       New_User_Lines = [];
parent_genotype = cell(2,1);                    type_of_stim = [];                      rearing_name = [];
hFoodtype = [];                                 hDarkness = [];                         hNote_box = [];
hElevation = [];                                hAzimuth = [];                          azi_options = [];
type_of_photoA = []; type_of_photoB = []; type_of_photoC = []; hStimDelay = [];         hPhotoDelay = [];
hCompress_opt = [];                             hDownload_opt = [];                     hRecord_rate = [];
hTrigger_type = [];                             hFrame_before = [];                     hFrame_after = [];
relative_pos = [];                              match_index = [];                       hRoomTemp = [];
hBulklabel = [];                                hBulkPath = [];                         hElevation2 = [];
hAzimuth2 = [];                                 relative_pos2 = [];                     secondstim = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets up the flyboy mySQL
thisPath = mfilename('fullpath');
parentDir = fileparts(fileparts(thisPath));
jarpath = fullfile([parentDir filesep 'Support_Programs'], 'mysql-connector-java-5.0.8-bin.jar');
if ~ismember(jarpath,javaclasspath)
    javaaddpath(jarpath, '-end');
end

drv = com.mysql.jdbc.Driver;
url = 'jdbc:mysql://prd-db.int.janelia.org:3306/flyboy?user=flyfRead&password=flyfRead';
try
    con = drv.connect(url,'');
    stm = con.createStatement;
catch
    stm = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% status pannel
uicontrol(hPanW,'Style','text','string','Status','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500,'position',[.01 .15 .250 .7]);
status_name = uicontrol(hPanW,'Style','text','string','Starting new Experiment','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500,'position',[.2750 .15 .4150 .7],'ForegroundColor',rgb('blue'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets buttons and call backs for Name, Collection, Genotype and protocol IDS
label_space = .0075;
bar_width = .1900;
for iterS = 1:5
    hTlabels(iterS) = uicontrol(hPanA,'Style','text',...
        'string',sprintf('\n%s:',ID_Label{iterS}),'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2667,'position',[.01 (1-((label_space+bar_width)*iterS)) .2500 bar_width]);
    menu_pos = (1-((label_space+bar_width)*iterS))+(bar_width/2);
    hTdropdown(iterS) = uicontrol(hPanA,'Style','popup','string',label_defaults{iterS},'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.2750 (menu_pos-.05) .1500 0.1]);
    hTbrowsebutton(iterS) = uicontrol(hPanA,'Style','pushbutton','string','Browse','Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.4400 (menu_pos-.05) .120 0.1]);
    hTaddbutton(iterS) = uicontrol(hPanA,'Style','pushbutton','string','Add','Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.5700 (menu_pos-.05) .120 0.1]);
end
genoPos = get(hTaddbutton(3),'position');
genoPos(3) = genoPos(3)*0.5;
set(hTaddbutton(3),'position',genoPos,'string','Add one')
genoPos(1) = genoPos(1)+genoPos(3);
hTbulkaddgeno = uicontrol(hPanA,'Style','pushbutton','string','Add many','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.5700 (menu_pos-.05) .120 0.1]);
set(hTbulkaddgeno,'position',genoPos,'callback',@loadbulk_genotype)

set(hTdropdown(1),'string',[{'Janelia ID'};user_names.User_ID],'callback',@setfullname);
set(hTbrowsebutton(1),'callback',@browsenames);
set(hTaddbutton(1),'callback',@addusers)

set(hTdropdown(2),'string',[{'Collection ID'};get(full_collection,'ObsNames')],'callback',@setcollectioninfo);
set(hTbrowsebutton(2),'callback',@browsecollections);
set(hTaddbutton(2),'callback',@addcollectioninfo);

set(hTdropdown(3),'string',[{'Genotype ID'};get(Saved_Genotypes,'ObsNames')],'callback',@setgenotypeinfo);
set(hTbrowsebutton(3),'callback',@browsegenotypes);
set(hTaddbutton(3),'callback',@addgenotypeinfo);

set(hTdropdown(4),'string',[{'Protocol ID'};get(Saved_Protocols_new_version,'ObsNames')],'callback',@setprotocolinfo);
set(hTbrowsebutton(4),'callback',@browseprotocol);
set(hTaddbutton(4),'callback',@addprotocolinfo);

set(hTdropdown(5),'style','text','FontSize',.75);
set(hTbrowsebutton(5),'string','Save','callback',@save_experiment);
set(hTaddbutton(5),'string','Create Bulk Ids','callback',@set_bulk);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   sets buttons and call backs for Individual Genotype information
for iterS = 1:4
    hTlabels_genotype(iterS) = uicontrol(hPanE,'Style','text',...
        'string',sprintf('\n\n%s:',Genotype_labels{iterS}),'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2222,'position',[.01 (1-((label_space+.2380)*iterS)) .2500 .2380]); %#ok<*AGROW>
end
for iterS = 1:2
    menu_pos = (1-((label_space+.2380)*iterS))+(.2380/2);
    hTdropdown_Robot_ID(iterS) = uicontrol(hPanE,'Style','text',...
        'string','Robot ID','Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.5000,'position',[.2750 (menu_pos-.05) .0500 0.1],'Enable','off','fontweight','bold');
    hTdropdown_genotype_name(iterS) = uicontrol(hPanE,'Style','text','string',Genotype_labels{iterS},'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.5000,'position',[.3300 (menu_pos-.05) .1500 0.1],'Enable','off','fontweight','bold','min',0,'max',1);
    hTbrowse_genotype(iterS) = uicontrol(hPanE,'Style','pushbutton',...
        'string','Browse','Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.5000 (menu_pos-.05) .0750 0.1],'Enable','off','callback',@search_genotype_database);
    hTadd_genotype(iterS) = uicontrol(hPanE,'Style','pushbutton',...
        'string','Add','Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.6000 (menu_pos-.05) .0750 0.1],'Enable','off','callback',@addnewline);
end
% gender
hGender(1) = uicontrol(hPanE,'Style','checkbox','string',{'Male Flies'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2222,'position',[.3750 .2500 .1500 .2300],'Enable','off','callback',@setgenders);
hGender(2) = uicontrol(hPanE,'Style','checkbox','string',{'Female Flies'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2222,'position',[.5250 .2500 .1500 .2300],'Enable','off','callback',@setgenders);
% balancers
hBalance(1) = uicontrol(hPanE,'Style','checkbox','string',{'No Balancers'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2192,'position',[.3000 .0100 .0750 .2300],'Enable','off','callback',@setblancers);
hBalance(2) = uicontrol(hPanE,'Style','checkbox','string',{'Chromosome 1'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2192,'position',[.4000 .0100 .0750 .2300],'Enable','off','callback',@setblancers);
hBalance(3) = uicontrol(hPanE,'Style','checkbox','string',{'Chromosome 2'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2192,'position',[.5000 .0100 .0750 .2300],'Enable','off','callback',@setblancers);
hBalance(4) = uicontrol(hPanE,'Style','checkbox','string',{'Chromosome 3'},'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.2192,'position',[.6000 .0100 .0750 .2300],'Enable','off','callback',@setblancers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user information
for iterA = 1:4
    uicontrol(hPanB,'Style','text','string',sprintf('\n%s:',desigen_info{iterA}),'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2540,'position',[.01 (.96-(.21*iterA)) .10 .20]);
    hDesign(iterA) = uicontrol(hPanB,'Style','text','string',sprintf('\n.....'),'Units','normalized','HorizontalAlignment','center',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2540,'position',[.12 (.96-(.21*iterA)) .165 .20]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% collection name
hColection_label = uicontrol(hPanD,'Style','text','string',sprintf('\nCollection Name:'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3810,'position',[.01 .15 .250 .7]);
collection_name = uicontrol(hPanD,'Style','text','string',sprintf('\n....'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3810,'position',[.2750 .15 .325 .7]);
hEditCollection = uicontrol(hPanD,'Style','pushbutton','string','Edit Colletion','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.3333,'position',[.61 .15 .075 .7],'enable','off','callback',@editcollection);
hShow_desc = uicontrol(hPanC,'Style','pushbutton','string','Show Collection Description','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.005 .975 .15 .025],'visible','off','enable','off','callback',@show_description);
hShow_lines = uicontrol(hPanC,'Style','pushbutton','string','Show Lines in Collection','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.15 .975 .15 .025],'visible','off','enable','off','callback',@show_lines_in_collection);

hBrowseAll = uicontrol(hPanC,'Style','pushbutton','string','Browse All Genotypes','Units','normalized','HorizontalAlignment','center','visible','off',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.005 .975 .15 .025],'visible','off','enable','off','callback',@setbrowseflag);
hBrowsePartial = uicontrol(hPanC,'Style','pushbutton','string','Browse Genotypes previously used','Units','normalized','HorizontalAlignment','center','visible','off',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.15 .975 .15 .025],'visible','off','enable','off','callback',@setbrowseflag);

hshowAll = uicontrol(hPanC,'Style','pushbutton','string','Show All Detail','Units','normalized','HorizontalAlignment','center','visible','off',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.005 1.00 .096 .025],'visible','off','enable','off','callback',@setbrowseflag);
hshowparents = uicontrol(hPanC,'Style','pushbutton','string','Show Parents Only','Units','normalized','HorizontalAlignment','center','visible','off',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.101 1.00 .096 .025],'visible','off','enable','off','callback',@setbrowseflag);
hshowgenotypes = uicontrol(hPanC,'Style','pushbutton','string','Show Genotypes Only','Units','normalized','HorizontalAlignment','center','visible','off',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.6500,'position',[.197 1.00 .096 .025],'visible','off','enable','off','callback',@setbrowseflag);
%% sets Calender and Target one fly
hCount_box = uicontrol(hPanG,'Style','text','string',sprintf('\nTarget One Fly Count:'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2326,'position',[.01 .15 .150 .7]);
hCount_val = uicontrol(hPanG,'Style','edit','string',sprintf(''),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2326,'position',[.175 .15 .05 .7],'Enable','off','callback',@getcounts);

uicontrol(hPanG,'Style','text','string',sprintf('\nEstimated Experimental Duration'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2326,'position',[.250 .15 .175 .70]);

hDuration_runs = uicontrol(hPanG,'Style','text','string',sprintf('.....'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.450 .15 .115 .333]);
hDuration_days = uicontrol(hPanG,'Style','text','string',sprintf('.....'),'Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.5000,'position',[.450 .517 .115 .333]);
hCalender = uicontrol(hPanG,'Style','pushbutton','string','Schedule Pez Time','Units','normalized','HorizontalAlignment','center',...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.2326,'position',[.600 .15 .150 .7],'callback',@setupCalender,'Enable','off');
set_rearing_info
set_stimuli_info
set_download_opts
flip_protocol('off')
flip_genotypes('off')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     function bulkaddgeno(~,~)
%         filename = '\\DM11\cardlab\Pez3000_Gui_folder\bulk_testing_geno.xlsx';
%         excelData = xlsread(filename);
%         if isnumeric(excelData.ParentA)
%             excelData.ParentA = num2cell(excelData.ParentA);
%             excelData.ParentA = cellfun(@(x) num2str(x),excelData.ParentA,'uniformoutput',false);
%         end
%         if isnumeric(excelData.ParentB)
%             excelData.ParentB = num2cell(excelData.ParentB);
%             excelData.ParentB = cellfun(@(x) num2str(x),excelData.ParentB,'uniformoutput',false);
%         end
%
% %         addgenotypeinfo
%     end
    function set_rearing_info(~,~)
        food_types = [{'Standard (Cornmeal)'},{'Agar Food'},{'Retinal (1:250)'},{'Retinal (1:500)'},{'Cornmeal + Water'},{'Agar Food + Water'},{'Cornmeal + Sugar Water'},{'Agar Food + Sugar Water'},...
            {'Standard (Cornmeal) Dark'},{'Agar Food'},{'Retinal (1:250) Dark'}];
        uicontrol(hPanF,'Style','pushbutton','string','Incubator Ref','Units','normalized','HorizontalAlignment','center','UserData',0,...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.001 .875 .120 .105],'Enable','on','callback',@browseincubators);
        rearing_name = uicontrol(hPanF,'Style','popup','string',Saved_Incubators.Name,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.250,'position',[0.125 .795 .170 .175],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Food Type','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.45,'position', [0.300 .875 .070 .085],'Enable','on');
        hFoodtype = uicontrol(hPanF,'Style','popup','string',food_types,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.250,'position',[0.375 .795 .100 .175],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Foiled','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.475,'position',[0.480 .875 .060 .085],'Enable','on');
        hDarkness = uicontrol(hPanF,'Style','popup','string',[{'No'},{'Yes'}],'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.250,'position',[0.545 .795 .040 .175],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Room Temp (C)','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.40,'position',[0.590 .875 .060 .085],'Enable','on');
        hRoomTemp = uicontrol(hPanF,'Style','edit','string','23','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.40,'position',[0.660 .885 .035 .090],'Enable','on','callback',@populate_current_proto);
        
        hNote_box = uicontrol(hPanF,'Style','edit','string','','Units','normalized','HorizontalAlignment','left','min',0,'max',2,...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.05,'position',[.520 .050 .170 .780],'Enable','on','callback',@populate_current_proto);
    end
    function set_stimuli_info(~,~)
        stim_list = struct2dataset(dir(fullfile([stim_path filesep],'*.mat')));
        stimuli_types= [{'None'};regexprep(stim_list.name,'.mat','')];
        
        photo_list = struct2dataset(dir(fullfile([photo_path filesep],'*.mat')));
        photo_types= [{'None'};regexprep(photo_list.name,'.mat','');{'Alternating'}];
        
        uicontrol(hPanF,'Style','text','string','Visual Stimulus','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.001 .75 .120 .08],'Enable','on');
        type_of_stim = uicontrol(hPanF,'Style','popup','string',stimuli_types,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.125 .75 .200 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Elevation','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.001 .65 .075 .08],'Enable','on');
        hElevation = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.090 .65 .075 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Azimuth','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.170 .65 .075 .08],'Enable','on','callback',@populate_current_proto);
        hAzimuth = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.250 .65 .075 .08],'Enable','on','callback',@populate_current_proto);
        azi_options = uicontrol(hPanF,'Style','checkbox','string','  Alternate Left/Right','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4,'fontweight','bold','position',[0.435 .65 .075 .08],'Enable','on','callback',@populate_current_proto);
        relative_pos = uicontrol(hPanF,'Style','checkbox','string','      Relative to Fly Pos','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4,'fontweight','bold','position',[0.330 .65 .100 .08],'Enable','on','callback',@populate_current_proto);
        
        uicontrol(hPanF,'Style','text','string','Elevation 2','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.001 .5 .075 .08],'Enable','on');
        hElevation2 = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.090 .5 .075 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Azimuth 2','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.170 .5 .075 .08],'Enable','on','callback',@populate_current_proto);
        hAzimuth2 = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.250 .5 .075 .08],'Enable','on','callback',@populate_current_proto);
        relative_pos2 = uicontrol(hPanF,'Style','checkbox','string','      Relative to Fly Pos 2','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4,'fontweight','bold','position',[0.330 .5 .100 .08],'Enable','on','callback',@populate_current_proto);
        secondstim = uicontrol(hPanF,'Style','checkbox','string','  Second Vis Stim','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4,'fontweight','bold','position',[0.435 .5 .075 .08],'Enable','on','callback',@populate_current_proto);
        
        uicontrol(hPanF,'Style','text','string','Photo-Activation','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.001 .350 .120 .08],'Enable','on');
        type_of_photoA = uicontrol(hPanF,'Style','popup','string',photo_types,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.125 .350 .067 .08],'Enable','on','callback',@populate_current_proto);
        type_of_photoB = uicontrol(hPanF,'Style','popup','string',photo_types,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.192 .350 .067 .08],'Enable','on','callback',@populate_current_proto);
        type_of_photoC = uicontrol(hPanF,'Style','popup','string',photo_types,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.258 .350 .067 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Stimuli Delay (ms)','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.330 .780 .075 .08],'Enable','on');
        hStimDelay = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.410 .780 .100 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Photo Delay (ms)','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.330 .350 .075 .08],'Enable','on');
        hPhotoDelay = uicontrol(hPanF,'Style','edit','string','0','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.410 .350 .100 .08],'Enable','on','callback',@populate_current_proto);
    end
    function set_download_opts(~,~)
        Compress_opts = [{'Use Compression (MP4 format)'};{'Use No Compression (AVI format)'}];
        Download_opts = [{'1/10th Rate'};{'Full Rate'};{'Restricted Full Rate'}];
        rate_list = {'6000','3000','2000','1000','500','250','125'};
        trigger_list = [{'When Ready'};{'On Escape'};{'Retain'}];
        
        uicontrol(hPanF,'Style','text','string','Compression Options','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.001 .25 .120 .08],'Enable','on');
        hCompress_opt = uicontrol(hPanF,'Style','popup','string',Compress_opts,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [.125 .250 .200 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Download Options','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[.001 .15 .120 .08],'Enable','on');
        hDownload_opt = uicontrol(hPanF,'Style','popup','string',Download_opts,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [.125 .15 .200 .08],'Enable','on','value',3,'callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Record Rate','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.330 .250 .075 .08],'Enable','on');
        hRecord_rate = uicontrol(hPanF,'Style','popup','string',rate_list,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.410 .250 .100 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Trigger Type','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.330 .150 .075 .08],'Enable','on');
        hTrigger_type = uicontrol(hPanF,'Style','popup','string',trigger_list,'Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.410 .150 .100 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Time Before Trigger (ms)','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.001 .050 .200 .08],'Enable','on');
        hFrame_before = uicontrol(hPanF,'Style','edit','string','50','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.210 .050 .050 .08],'Enable','on','callback',@populate_current_proto);
        uicontrol(hPanF,'Style','text','string','Time After Trigger (ms)','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position', [0.270 .050 .175 .08],'Enable','on','callback',@populate_current_proto);
        hFrame_after = uicontrol(hPanF,'Style','edit','string','100','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.475,'position',[0.455 .050 .050 .08],'Enable','on','callback',@populate_current_proto);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% counts and save
    function getcounts(hObj,~)
        if get(hTdropdown(2),'value') == 1
            set(status_name,'string','No Collection has been selected');
            set(hCount_val,'string','');
            return
        end
        set(hCount_box,'backgroundcolor',[.8 .8 .8]);
        target_count = str2double(get(hObj,'string'));
        
        curr_id = get(hTdropdown(5),'string');
        curr_id = curr_id(1:4);
        
        exp_names = get(Saved_Experiments,'ObsNames');
        if ~isempty(exp_names)
            partial_names = cellfun(@(x) x(1:4),exp_names,'uniformoutput',false);
            Saved_Experiments.Target_count(strcmp(curr_id,partial_names)) = {num2str(target_count)};
            save([file_dir filesep file_path_experiments],'Saved_Experiments');
            set(status_name,'string','Target count has been updated');
        end
        
        get_runs_per_day
        
        one_fly_per_day = runs_per_day * vids_per_run * one_fly_rate;
        one_fly_per_run = vids_per_run * one_fly_rate;
        show_lines_in_collection
        total_lines = length(saved_geno_ids);
        set(hbrowselist,'visible','on','string','','min',0,'max',2,'HorizontalAlignment','left','style','text')
        set(hTable,'visible','off')
        days_to_schedule = (total_lines * target_count) / one_fly_per_day;
        runs_to_schedule = (total_lines * target_count) / one_fly_per_run;
        
        set(hDuration_days,'String',sprintf('%5.2f Days',days_to_schedule));
        set(hDuration_runs,'String',sprintf('%5.2f Runs',runs_to_schedule));
    end
    function get_runs_per_day(~,~)
        daily_exp = [];
        vid_count = [];
        end_date = now;
        start_date = end_date - 7;
        
        end_date = datevec(end_date);
        end_date = sprintf('%04s%02s%02s',num2str(end_date(1)),num2str(end_date(2)),num2str(end_date(3)));
        start_date = datevec(start_date);
        start_date = sprintf('%04s%02s%02s',num2str(start_date(1)),num2str(start_date(2)),num2str(start_date(3)));
        
        date_folders = struct2dataset(dir(dateDir));
        date_folders = date_folders(~isnan(str2double(date_folders.name)),:);
        if ~isempty(start_date)
            date_folders = date_folders(str2double(date_folders.name) >= str2double(start_date),:);
        end
        if ~isempty(end_date)
            date_folders = date_folders(str2double(date_folders.name) <= str2double(end_date),:);
        end
        for iterZ = 1:length(date_folders(:,1))
            new_folder = fullfile(dateDir,filesep,date_folders.name(iterZ));
            exp_index = struct2dataset(dir(new_folder{1}));
            daily_exp = [daily_exp sum(cellfun(@(x) contains(x,'exp'),exp_index.name))];
            for iterB = 3:length(exp_index)
                file_list = struct2dataset(dir(fullfile(dateDir,filesep,date_folders.name{iterZ},filesep,exp_index.name{iterB},'*.avi')));
                vid_count = [vid_count length(file_list)];
            end
        end
        %%
        date_folders = date_folders(daily_exp > 0,:);                         %remove dates with no experiments run
        %        daily_exp = daily_exp(daily_exp > 0);                                %runs with no video
        runs_per_day = sum(daily_exp) / length(date_folders);
        vids_per_run = sum(vid_count) / sum(daily_exp);
    end
    function save_experiment(~,~)
        update = 'Yes';
        if get(hTdropdown(1),'value') == 1
            set(status_name,'string','No User Name is given')
            set(hTlabels(1),'backgroundcolor',rgb('light red'));
            return
        end
        if get(hTdropdown(2),'value') == 1
            set(status_name,'string','No Collection was choosen')
            set(hTlabels(2),'backgroundcolor',rgb('light red'));
            return
        end
        if get(hTdropdown(3),'value') == 1
            set(status_name,'string','No Genotypes selected')
            set(hTlabels(3),'backgroundcolor',rgb('light red'));
            return
        end
        if get(hTdropdown(4),'value') == 1
            set(status_name,'string','No Protocol information')
            set(hTlabels(4),'backgroundcolor',rgb('light red'));
            return
        end
        
        if isempty(get(hCount_val,'string'))
            set(status_name,'string','No Target Count is set')
            set(hCount_box,'backgroundcolor',rgb('light red'));
            return
        end
        
        collect_index = get(hTdropdown(2),'value');
        collect_str = get(hTdropdown(2),'string');
        current_collection = collect_str(collect_index);
        if ismember(get(hTdropdown(5),'string'),get(Saved_Experiments,'ObsNames'))
            update = questdlg('Experiment record already exists, Wish to update counts?','','Yes','No','No');
        end
        if strcmp(update,'Yes')
            update_Saved_Experiments
        end
    end
    function update_Saved_Experiments
        var_names = [{'User_ID'},{'Target_count'},{'Status'},{'Saved_Dates'},{'Partail_Date'}];
        varspecs = cell(1,numel(var_names));
        current_experiment = dataset([{varspecs},var_names]);
        current_experiment = set(current_experiment,'ObsName',get(hTdropdown(5),'string'));
        
        name_list = get(hTdropdown(1),'string');
        name_index = get(hTdropdown(1),'value');
        
        current_experiment.User_ID = name_list(name_index);
        current_experiment.Target_count = {get(hCount_val,'string')};
        current_experiment.Status = {'Open'};
        if ismember(get(hTdropdown(5),'string'),get(Saved_Experiments,'ObsNames'))
            Saved_Experiments(get(hTdropdown(5),'string'),:) = [];
        end
        if isempty(Saved_Experiments)
            Saved_Experiments = current_experiment;
        else
            Saved_Experiments = [Saved_Experiments;current_experiment];
        end
        
        save([file_dir filesep file_path_experiments],'Saved_Experiments');
        setcollectioninfo(hTdropdown(2))
        set(status_name,'string','Experiment has been Saved')
        show_lines_in_collection
    end
    function set_bulk(~,~)
        if get(hTdropdown(1),'value') == 1
            disp('select user first')
            return
        end
        [filename,filedir] = uigetfile({'*.xls;*.xlsx','Excel Files'},'Select the Excel file for bulk loading',...
            fileparts(file_dir));
        if filename == 0, return, end
        filepath = fullfile(filedir,filename);
        if exist(filepath,'file')
            excelData = dataset('XLSFile',filepath,'Sheet','query_info');
            colVec = excelData.Collection_ID;
            genoVec = excelData.Genotype_ID;
            protoVec = excelData.Protocol_ID;
            countVec = excelData.Target_Counts;
            collectionOps = get(hTdropdown(2),'string');
            genotypeOps = get(hTdropdown(3),'string');
            protocolOps = get(hTdropdown(4),'string');
            bulkCt = min([numel(colVec) numel(genoVec) numel(protoVec) numel(countVec)]);
            sheetName = ['failures_' datestr(now,'yyyymmddHHMM')];
            xlsResult = {'Genotype_ID','Protocol_ID','Collection_ID','Target_Counts'};
            xlswrite(filepath,xlsResult,sheetName,...
                ['A' num2str(1) ':D' num2str(1)]);
            xlsRef = 0;
            for iterB = 1:bulkCt
                colStr = sprintf('%04s',num2str(colVec(iterB)));
                genoStr = sprintf('%08s',num2str(genoVec(iterB)));
                protoStr = sprintf('%04s',num2str(protoVec(iterB)));
                colRef = find(strcmp(collectionOps,colStr));
                genoRef = find(strcmp(genotypeOps,genoStr));
                protoRef = find(strcmp(protocolOps,protoStr));
                if isempty(colRef) || isempty(genoRef) || isempty(protoRef)
                    xlsResult = [colVec(iterB) genoVec(iterB) protoVec(iterB) countVec(iterB)];
                    xlsResult = num2cell(xlsResult);
                    xlsRef = xlsRef+1;
                    xlswrite(filepath,xlsResult,sheetName,...
                        ['A' num2str(xlsRef) ':D' num2str(xlsRef)]);
                else
                    set(hTdropdown(2),'value',colRef)
                    setcollectioninfo(hTdropdown(2))
                    set(hTdropdown(3),'value',genoRef)
                    setgenotypeinfo(hTdropdown(3))
                    set(hTdropdown(4),'value',protoRef)
                    setprotocolinfo(hTdropdown(4))
                    set(hCount_val,'string',countVec(iterB))
                    exptID = [colStr,genoStr,protoStr];
                    disp(exptID)
                    set(hTdropdown(5),'string',exptID)
                    update_Saved_Experiments
                end
            end
            disp(['failure count: ' num2str(xlsRef)])
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% button functions
    function flip_genotypes(flag)
        for iterZ = 1:4
            set(hBalance(iterZ),'Enable',flag);
        end
        for iterZ = 1:2
            set(hTdropdown_Robot_ID(iterZ),'Enable',flag);
            set(hTdropdown_genotype_name(iterZ),'Enable',flag);
            set(hTbrowse_genotype(iterZ),'Enable',flag);
            set(hTadd_genotype(iterZ),'Enable',flag);
            set(hGender(iterZ),'Enable',flag);
        end
    end
    function flip_protocol(flag)
        set(type_of_stim ,'Enable',flag);
        set(rearing_name ,'Enable',flag);
        set(hFoodtype ,'Enable',flag);
        set(hDarkness ,'Enable',flag);
        set(hNote_box ,'Enable',flag);
        set(hElevation,'Enable',flag);
        set(hAzimuth ,'Enable',flag);
        set(hElevation2,'Enable',flag);
        set(hAzimuth2 ,'Enable',flag);
        set(relative_pos2,'Enable',flag);
        set(secondstim ,'Enable',flag);
        set(azi_options,'Enable',flag);
        set(relative_pos,'Enable',flag);
        set(type_of_photoA,'Enable',flag);
        set(type_of_photoB,'Enable',flag);
        set(type_of_photoC,'Enable',flag);
        set(hStimDelay,'Enable',flag);
        set(hPhotoDelay,'Enable',flag);
        set(hCompress_opt,'Enable',flag);
        set(hDownload_opt,'Enable',flag);
        set(hRecord_rate,'Enable',flag);
        set(hTrigger_type,'Enable',flag);
        set(hFrame_before,'Enable',flag);
        set(hFrame_after,'Enable',flag);
        set(hRoomTemp,'Enable',flag);
    end
    function flip_buttons(flag)
        for iterZ = 1:5
            set(hTdropdown(iterZ),'Enable',flag);
            set(hTbrowsebutton(iterZ),'Enable',flag);
            set(hTaddbutton(iterZ),'Enable',flag);
        end
    end
    function allbuttons_off(~,~)
        flip_genotypes('off')
        flip_protocol('off')
        flip_buttons('off')
        set(hCount_val,'Enable','off');
        set(hCalender,'Enable','off');
    end
    function collection_buttons(flag,type)
        set(hbrowselist,'fontsize',.0204,'position',[0 .025 .3 .95]);
        set(hbrowseproto,'visible','off');
        if strcmp(type,'collection') || strcmp(flag,'off')
            set(hEditCollection,'Enable',flag);
            set(hShow_desc,'Enable',flag,'Visible',flag);
            set(hShow_lines,'Enable',flag,'Visible',flag');
        end
        if strcmp(type,'genotype') || strcmp(flag,'off')
            set(hBrowseAll,'Enable',flag,'Visible',flag);
            set(hBrowsePartial,'Enable',flag,'Visible',flag);
            set(hshowAll,'Enable',flag,'Visible',flag);
            set(hshowparents,'Enable',flag,'Visible',flag);
            set(hshowgenotypes,'Enable',flag,'Visible',flag);
        end
        if strcmp(type,'protocol') || strcmp(flag,'off')
            if strcmp(flag,'on')
                set(hbrowselist,'fontsize',.0408,'position',[0 .5000 .3 .475]);
                set(hbrowseproto,'visible','off');
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check warnings
    function check_warnings(~,~)
        set(hBrowseAll,'visible','off')
        set(hBrowsePartial,'visible','off')
        set(hshowAll,'visible','off')
        set(hshowparents,'visible','off')
        set(hshowgenotypes,'visible','off')
        
        warning_message = get(status_name,'string');
        switch warning_message
            case 'Starting new Experiment'
                clear_warning;
            case 'Experiment has been Saved'
                clear_warning;
            case 'Searching Complete'
                clear_warning;
            case 'Database has been updated'
                %                clear_warning;
            case 'Target count has been updated'
                clear_warning;
            case 'No user names to browse'
                if length(get(hTdropdown(1),'string')) > 1
                    clear_warning;
                end
            case 'Name already exists, please check spelling'
                if get(hTdropdown(1),'value') > 1
                    clear_warning
                end
            case 'Set all Experiment Information before using Calender'
                if sum(cell2mat(get(hTdropdown(1:2),'value')) == 1) == 0
                    clear_warning;
                end
            case 'User Selected both No balancers as well as a Chromosome Balancer'
                if sum(cell2mat(get(hBalance,'value'))) > 0
                    clear_warning;
                end
            case 'No Collections to browse'
                if length(get(hTdropdown(2),'string')) > 1
                    clear_warning;
                end
            case 'No User Selected, please fix before browsing collections'
                if get(hTdropdown(1),'value') > 1
                    clear_warning;
                end
            case 'No User Selected, please fix before creating a new collection'
                if get(hTdropdown(1),'value') > 1
                    clear_warning;
                end
            case 'Description is empty, please Enter a Description for this collection'
                if ~isempty(user_text{1})
                    clear_warning;
                end
            case 'Name of Collection is empty, please Enter a Name for this collection'
                if ~isempty(name_entry{1})
                    clear_warning;
                end
            case 'No saved genotypes to browse'
                if length(get(hTdropdown(3),'string')) > 1
                    clear_warning;
                end
            case 'No genders selected for this genotype, please selecet at least one gender'
                if sum(cell2mat(get(hGender,'value'))) > 0
                    clear_warning
                end
            case 'Select at least One Balancer option'
                if sum(cell2mat(get(hBalance,'value'))) > 0
                    clear_warning
                end
            case 'Parents are Missing, please select Parents'
                if ~(strcmp(get(hTdropdown_genotype_name(1),'string'),'Parent A') || strcmp(get(hTdropdown_genotype_name(2),'string'),'Parent B'))
                    clear_warning;
                end
            case 'No saved protocols to browse'
                if length(get(hTdropdown(4),'string')) > 1
                    clear_warning;
                end
            case 'Need to set all Protocol information'
                if sum(cell2mat(get(hTdropdown_protocol,'value')) == 1) == 0
                    clear_warning
                end
            case 'Select Download and Compression methods'
                if sum(cell2mat(get(hDownload_opt,'value')) == 1) ==1  && sum(cell2mat(get(hCompress_opt,'value')) == 1) == 1
                    clear_warning
                end
                
            case 'No User Name is given'
                if get(hTdropdown(1),'value') > 1
                    clear_warning
                end
            case 'No Collection was choosen'
                if get(hTdropdown(2),'value') > 1
                    clear_warning
                end
            case 'No Protocol information'
                if get(hTdropdown(3),'value') > 1
                    clear_warning
                end
            case 'No Target Count is set'
                if ~isempty(get(hCount_val,'string'))
                    clear_warning;
                end
            case 'No Collection has been selected'
                if get(hTdropdown(2),'value') > 1
                    clear_warning
                end
        end
    end
    function clear_warning(~,~)
        set(status_name,'string','');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Name information
    function browsenames(~,~)
        flip_protocol('off')
        collection_buttons('off','All')
        if isempty(user_names)              %if no names, then nothing to browse
            set(status_name,'string','No user names to browse')
            return
        end
        new_string = cellfun(@(x,y) sprintf('%s:     %s',x,y),user_names.User_ID,user_names.User_Full_Name,'UniformOutput',false);
        set(hbrowselist,'visible','on','string',new_string,'min',0,'max',2,'HorizontalAlignment','left')
        set(hTable,'visible','off')
        set(hTdropdown(1),'value',1);
        set(status_name,'string','Searching Complete')
    end
    function updatefields(~,~)
        flip_protocol('off')
        set(status_name,'string','');
        child = get(hPanC,'children');
        for iterC = 1:length(child)
            set(child(iterC),'Visible','off');
        end
        if name_index > 0
            set(hTdropdown(1),'value',name_index+1)
            set(hDesign(1),'string',sprintf('\n%s',user_names{name_index,2}))
        end
        flip_buttons('on')
    end
    function addusers(~,~)
        allbuttons_off
        collection_buttons('Off','All')
        check_warnings
        set(status_name,'string','Enter Name for new user');
        
        set(hbrowselist,'Visible','off');
        set(hSelectUser,'Visible','off');
        set(browse_pan,'string','Input New User Information','visible','on','position',[0 .975 .300 .025]);
        
        uicontrol(hPanC,'Style','text','string','First Name:','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0.01 .775 .050 .025]);
        hFname = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.7619,'position',[0.07 .775 .200 .025]);
        uicontrol(hPanC,'Style','text','string','Last Name:','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0.01 .575 .050 .025]);
        hLname = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.7619,'position',[0.07 .575 .200 .025]);
        uicontrol(hPanC,'Style','pushbutton','string','Save User','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0.10 .35 .10 .025],'callback',@savenewuser);
        uicontrol(hPanC,'Style','pushbutton','string','Cancel','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0.10 .25 .10 .025],'callback',@updatefields);
        set(hTdropdown(1),'string',[{'Janelia ID'};user_names.User_ID],'callback',@setfullname);
        set(hTbrowsebutton(1),'callback',@browsenames);
    end
    function savenewuser(~,~)
        flip_protocol('off')
        lastname = get(hLname,'string');
        lastname = regexprep(lastname,'(\<\w)','${upper($1)}');
        firstname = get(hFname,'string');
        firstname = regexprep(firstname,'(\<\w)','${upper($1)}');
        
        var_names = [{'User_ID'},{'User_Full_Name'}];
        varspecs = cell(1,numel(var_names));
        current_names = dataset([{varspecs},var_names]);
        
        current_names.User_ID(1) = {strcat(lastname,lower(firstname(1)))};
        current_names.User_Full_Name(1) = {strcat(lastname,', ',firstname)};
        if ismember(current_names.User_ID,user_names.User_ID)
            set(status_name,'string','Name already exists, please check spelling')
            updatefields
        else
            if isempty(user_names)
                user_names = current_names;
            else
                user_names = [user_names;current_names];
            end
            set(hTdropdown(1),'string',[{'Janelia ID'};user_names.User_ID]);
            updatefields
            
            set(hTdropdown(1),'value',length(get(hTdropdown(1),'string')))
            set(hDesign(1),'string',sprintf('\n%s',user_names{length(get(hTdropdown(1),'string'))-1,2}))
            set(status_name,'string','Database has been updated');
        end
        flip_genotypes('off')
        flip_protocol('off')
        flip_buttons('on')
        Saved_User_names = user_names;
        fileattrib([file_dir filesep file_path_users],'+w');
        save([file_dir filesep file_path_users],'Saved_User_names');
        setfullname(hTdropdown(1));
    end
    function setfullname(hObj,~)
        set(browse_pan,'Visible','off','string','');
        flip_protocol('off')
        collection_buttons('Off','All')
        set(hTdropdown(2),'value',1);
        setcollectioninfo(hTdropdown(2))
        set(hTdropdown(3),'value',1);
        setgenotypeinfo(hTdropdown(3))
        set(hTdropdown(4),'value',1);
        index = get(hObj,'Value')-1;
        if index > 0
            set(hDesign(1),'string',sprintf('\n%s',user_names.User_Full_Name{index}))
            find_match = strcmp(Saved_Collection.User_ID,user_names.User_ID{index});
            set(hTlabels(1),'backgroundcolor',[.8 .8 .8]);
        else
            set(hDesign(1),'string',sprintf('\n....'))
            find_match = false;
        end
        full_collection = Saved_Collection(find_match,:);
        set(hTdropdown(2),'string',[{'Collection ID'};get(full_collection,'ObsNames')],'callback',@setcollectioninfo);
        set(hTdropdown(2),'value', 1)
        setcollectioninfo(hTdropdown(2))
        flip_buttons('on')
        check_warnings
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calender
    function setupCalender(~,~)
        set(hCalender,'backgroundcolor',[.8 .8 .8]);
        if sum(cell2mat(get(hTdropdown(1:2),'value')) == 1) > 0
            set(status_name,'string','Set all Experiment Information before using Calender')
        else
            collect_list = get(hTdropdown(2),'string');
            curr_collection = collect_list(get(hTdropdown(2),'value'));
            [~,Saved_Experiments] = makeCalender_v2(now,curr_collection,Saved_Collection,Saved_Experiments,Saved_Genotypes,Saved_Protocols_new_version,Saved_Groups);
            set(status_name,'string','Database has been updated');
        end
        check_warnings
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% protocol and stimuli
    function browseincubators(hObj,~)
        set(hbrowseproto,'visible','off');
        if get(hObj,'UserData') == 1
            set(hObj,'BackgroundColor',[0.8 0.8 0.8],'UserData',0)
            set(hbrowselist,'style','listbox','string','','Visible','on','HorizontalAlignment','left','value',1,'min',0,'max',2,'callback',[]);
        else
            mls = cellfun(@(w,x,y,z,a) sprintf('Name :: %s\n  Lights On: %s   Lights Off: %s  \nLocation: %s,     Temperature: %s\n',w,x,y,z,a),...
                Saved_Incubators.Name,Saved_Incubators.LightsOn,Saved_Incubators.LightsOff,Saved_Incubators.Location,Saved_Incubators.Temperature,'UniformOutput',false);
            set(hObj,'BackgroundColor',rgb('light blue'),'UserData',1);
            [outstring,~] = textwrap(hbrowselist,mls);
            set(hbrowselist,'style','listbox','string',outstring,'Visible','on','HorizontalAlignment','left','value',1,'min',0,'max',2,'callback',@getincubatorentry);
        end
    end
    function getincubatorentry(~,~)
        index = get(hbrowselist,'value');
        blank_lines = cellfun(@(x) isempty(x),get(hbrowselist,'string'));
        
        upper_limit =  find(blank_lines(index:end),1,'first') - 2;
        lower_limit =  find(blank_lines(1:index),1,'last') +1;
        if upper_limit == -1     %blank space
            return
        end
        if isempty(lower_limit)
            lower_limit = 1;
        end
        
        set(hbrowselist,'value',lower_limit:1:(index+upper_limit))
        new_spot = sum(blank_lines(1:index))+1;
        set(rearing_name,'value',new_spot);
        populate_current_proto(rearing_name)
    end
    function restore_defaults(~,~)
        set(type_of_stim,'value',1);
        set(rearing_name,'value',1);
        set(hFoodtype,'value',1);
        set(hDarkness,'value',1);
        set(hNote_box ,'string','');
        set(type_of_photoA ,'value',1);
        set(type_of_photoB ,'value',1);
        set(type_of_photoC ,'value',1);
        set(hCompress_opt ,'value',1);
        set(hDownload_opt ,'value',3);
        set(hRecord_rate ,'value',1);
        set(hTrigger_type ,'value',1);
        set(hFrame_before ,'string','50');
        set(hFrame_after ,'string','100');
        set(hRoomTemp ,'string','23');
    end
    function setprotocolinfo(hObj,~)
        check_warnings
        proto_string = get(hObj,'string');
        if get(hObj,'value') > length(proto_string)
        else
            proto_index = proto_string(get(hObj,'value'));
            proto_info = Saved_Protocols_new_version(ismember(get(Saved_Protocols_new_version,'ObsNames'),proto_index),:);
        end
        set_new_proto(type_of_stim, proto_info.Stimuli_Type);
        set_new_proto(type_of_stim,proto_info.Stimuli_Type);
        set_new_proto(rearing_name,proto_info.Incubator_Info);
        set_new_proto(hFoodtype,proto_info.Food_Type);
        set_new_proto(hDarkness,proto_info.Foiled);
        set_new_proto(hNote_box ,proto_info.Notes);
        strOps = get(type_of_photoA,'string');
        activationChoices = proto_info.Photo_Activation{1};
        hOps = [type_of_photoA,type_of_photoB,type_of_photoC];
        if iscell(activationChoices)
            for iterAct = 1:numel(activationChoices)
                actVal = find(strcmp(strOps,activationChoices{iterAct}));
                if isempty(actVal), actVal = 1; end
                set(hOps(iterAct),'value',actVal);
            end
        else
            actVal = find(strcmp(strOps,activationChoices));
            if isempty(actVal), actVal = 1; end
            set(type_of_photoA ,'value',actVal);
            set(type_of_photoB ,'value',1);
            set(type_of_photoC ,'value',1);
        end
        
        set_new_proto(hCompress_opt ,proto_info.Compression_Opts);
        set_new_proto(hDownload_opt ,proto_info.Download_Opts);
        set_new_proto(hRecord_rate ,proto_info.Record_Rate);
        set_new_proto(hTrigger_type ,proto_info.Trigger_Type);
        set_new_proto(hFrame_before ,proto_info.Time_Before);
        set_new_proto(hFrame_after ,proto_info.Time_After);
        set_new_proto(hRoomTemp ,proto_info.Room_Temp);
        
        set_new_proto(hAzimuth ,proto_info.Stimuli_Vars);
        set_new_proto(hElevation ,proto_info.Stimuli_Vars);
        set_new_proto(azi_options ,proto_info.Stimuli_Vars);
        set_new_proto(relative_pos ,proto_info.Stimuli_Vars);
         if proto_info.Stimuli_Vars.Second_Stim == 1
            set_new_proto(hAzimuth2 ,proto_info.Stimuli_Vars);
            set_new_proto(hElevation2 ,proto_info.Stimuli_Vars);
            set_new_proto(relative_pos2 ,proto_info.Stimuli_Vars);
            set_new_proto(secondstim ,proto_info.Stimuli_Vars);
        end
        set_new_proto(hStimDelay ,proto_info.Stimuli_Vars);
        set_new_proto(hPhotoDelay ,proto_info.Photo_Vars);
        new_id = get(hTdropdown(5),'string');
        new_id(13:16) = proto_index{1};
        set(hTdropdown(5),'string',new_id);
    end
    function set_new_proto(hObj,Var_list)
        curr_list = get(hObj,'string');
        if isstruct(Var_list)
            switch hObj
                case rearing_name
                    rearing_ops = get(rearing_name,'string');
                    rearing_ref = find(strcmp(rearing_ops,Var_list.Name));
                    if ~isempty(rearing_ref)
                        set(rearing_name,'value',rearing_ref);
                    end
                case hAzimuth
                    set(hObj,'string',Var_list.Azimuth);
                case hElevation
                    set(hObj,'string',Var_list.Elevation);
                case azi_options
                    set(hObj,'value',Var_list.Azimuth_Opts);
                case relative_pos
                    set(hObj,'value',Var_list.Relative_Pos);
                case hAzimuth2
                    set(hObj,'string',Var_list.Azimuth2);
                case hElevation2
                    set(hObj,'string',Var_list.Elevation2);
                case relative_pos2
                    set(hObj,'value',Var_list.Relative_Pos2);
                case hStimDelay
                    set(hObj,'string',Var_list.Stimuli_Delay);
                case secondstim
                    set(hObj,'value',Var_list.Second_Stim);
                case hPhotoDelay
                    set(hObj,'string',Var_list.Photo_Delay);
            end
        else
            if length(curr_list) > 1
                try
                    var_index = find(ismember(get(hObj,'string'),Var_list),1,'first');
                    set(hObj,'value',var_index);
                catch
                    return
                end
            else
                set(hObj,'string',Var_list{1});
            end
        end
    end
    function addprotocolinfo(~,~)
        %         restore_defaults
        flip_buttons('off')
        check_warnings
        flip_protocol('on')
        set(hTbrowsebutton(4),'string','Save','callback',@save_protocol,'Enable','On');
        set(hTaddbutton(4),'String','Cancel','callback',@cancel_protocol,'Enable','On');
        
        var_names = [{'Incubator_Info'},{'Food_Type'},{'Foiled'},{'Stimuli_Type'},{'Stimuli_Vars'},{'Photo_Activation'},{'Photo_Vars'},...
            {'Compression_Opts'},{'Download_Opts'},{'Record_Rate'},{'Trigger_Type'},{'Time_Before'},{'Time_After'},{'Notes'},{'Room_Temp'}];
        varspecs = cell(1,numel(var_names));
        current_protocol = dataset([{varspecs},var_names]);
        current_protocol.Stimuli_Vars = cell2struct({'0','0','0','0','0'},{'Elevation','Azimuth','Azimuth_Opts','Relative_Pos','Stimuli_Delay'},2);
        current_protocol.Photo_Vars = cell2struct({'0'},{'Photo_Delay'},2);
        populate_current_proto(type_of_stim,'Stimuli_Type');
        populate_current_proto(rearing_name,'Incubator_Info');
        populate_defaults(hFoodtype,'Food_Type');
        populate_defaults(hDarkness,'Foiled');
        populate_defaults(hNote_box ,'Notes');
        populate_defaults(type_of_photoA ,'Photo_Activation');
        populate_defaults(type_of_photoB ,'Photo_Activation');
        populate_defaults(type_of_photoC ,'Photo_Activation');
        populate_defaults(hCompress_opt ,'Compression_Opts');
        populate_defaults(hDownload_opt ,'Download_Opts');
        populate_defaults(hRecord_rate ,'Record_Rate');
        populate_defaults(hTrigger_type ,'Trigger_Type');
        populate_defaults(hFrame_before ,'Time_Before');
        populate_defaults(hFrame_after ,'Time_After');
        populate_defaults(hRoomTemp ,'Room_Temp');
    end
    function populate_current_proto(hObj,~)
        curr_list = get(hObj,'string');
        if isempty(current_protocol)
            restore_defaults
            addprotocolinfo
        end
        switch hObj
            case type_of_stim
                current_protocol.Stimuli_Type = curr_list(get(hObj,'Value'));
                populate_default_opts
            case rearing_name
                current_protocol.Incubator_Info = dataset2struct(Saved_Incubators(get(hObj,'Value'),:));
            case hFoodtype
                current_protocol.Food_Type = curr_list(get(hObj,'Value'));
            case hDarkness
                current_protocol.Foiled = curr_list(get(hObj,'Value'));
            case hNote_box
                current_protocol.Notes = curr_list(get(hObj,'Value'));
            case hElevation
                current_protocol.Stimuli_Vars.Elevation = curr_list;
            case hAzimuth
                current_protocol.Stimuli_Vars.Azimuth = curr_list;
            case azi_options
                current_protocol.Stimuli_Vars.Azimuth_Opts = get(hObj,'Value');
            case relative_pos
                current_protocol.Stimuli_Vars.Relative_Pos = get(hObj,'Value');
            case hElevation2
                current_protocol.Stimuli_Vars.Elevation2 = curr_list;
            case hAzimuth2
                current_protocol.Stimuli_Vars.Azimuth2 = curr_list;
            case relative_pos2
                current_protocol.Stimuli_Vars.Relative_Pos2 = get(hObj,'Value');
            case secondstim
                current_protocol.Stimuli_Vars.Second_Stim = get(hObj,'Value');
            case hStimDelay
                current_protocol.Stimuli_Vars.Stimuli_Delay = curr_list;
            case type_of_photoA
                current_protocol.Photo_Activation = {cat(1,[curr_list(get(type_of_photoA,'Value')),...
                    curr_list(get(type_of_photoB,'Value')),...
                    curr_list(get(type_of_photoC,'Value'))])};
            case type_of_photoB
                current_protocol.Photo_Activation = {cat(1,[curr_list(get(type_of_photoA,'Value')),...
                    curr_list(get(type_of_photoB,'Value')),...
                    curr_list(get(type_of_photoC,'Value'))])};
            case type_of_photoC
                current_protocol.Photo_Activation = {cat(1,[curr_list(get(type_of_photoA,'Value')),...
                    curr_list(get(type_of_photoB,'Value')),...
                    curr_list(get(type_of_photoC,'Value'))])};
            case hPhotoDelay
                current_protocol.Photo_Vars.Photo_Delay = curr_list;
            case hCompress_opt
                current_protocol.Compression_Opts = curr_list(get(hObj,'Value'));
            case hDownload_opt
                current_protocol.Download_Opts = curr_list(get(hObj,'Value'));
            case hRecord_rate
                current_protocol.Record_Rate = curr_list(get(hObj,'Value'));
            case hTrigger_type
                current_protocol.Trigger_Type = curr_list(get(hObj,'Value'));
            case hFrame_before
                current_protocol.Time_Before = {curr_list};
            case hFrame_after
                current_protocol.Time_After = {curr_list};
        end
    end
    function populate_default_opts(~,~)
        if get(type_of_stim,'value') == 1
            set(hElevation,'string',0);
            set(hAzimuth,'string',0);
            set(azi_options,'value',0);
            set(relative_pos,'value',0);
            set(hStimDelay,'string',0);
            set(hElevation2,'string',0);
            set(hAzimuth2,'string',0);
            set(secondstim,'value',0);
            set(relative_pos2,'value',0);
        else
            set(hElevation,'string',45);
            set(hAzimuth,'string',0);
            set(azi_options,'value',1);
            set(relative_pos,'value',1);
            set(hStimDelay,'string',0);
            set(hElevation2,'string',0);
            set(hAzimuth2,'string',0);
            if contains(current_protocol.Stimuli_Type,'dual')
                set(secondstim,'value',1);
                set(relative_pos2,'value',1);
            else
                set(secondstim,'value',0);
                set(relative_pos2,'value',0);
            end
        end
        set(hPhotoDelay,'string',0);
        
        current_protocol.Stimuli_Vars.Elevation = get(hElevation,'string');
        current_protocol.Stimuli_Vars.Azimuth = get(hAzimuth,'string');
        current_protocol.Stimuli_Vars.Azimuth_Opts = get(azi_options,'value');
        current_protocol.Stimuli_Vars.Relative_Pos = get(relative_pos,'value');
        current_protocol.Stimuli_Vars.Stimuli_Delay = get(hStimDelay,'string');
        current_protocol.Photo_Vars.Photo_Delay = get(hPhotoDelay,'string');
%         if get(secondstim,'value')==1
            current_protocol.Stimuli_Vars.Elevation2 = get(hElevation2,'string');
            current_protocol.Stimuli_Vars.Azimuth2 = get(hAzimuth2,'string');
            current_protocol.Stimuli_Vars.Relative_Pos2 = get(relative_pos2,'value');
            current_protocol.Stimuli_Vars.Second_Stim = get(secondstim,'value');
%         end
    end
    function populate_defaults(hObj,Var_list)
        curr_list = get(hObj,'string');
        curr_len = size(curr_list);
        if curr_len(1) > 1
            current_protocol.(Var_list) = curr_list(get(hObj,'Value'));
        elseif isempty(curr_list)
            current_protocol.(Var_list) = {' '};
        else
            current_protocol.(Var_list) = {curr_list};
        end
    end
    function cancel_protocol(~,~)
        flip_protocol('off')
        flip_buttons('on')
        set(hTbrowsebutton(4),'string','Browse');
        set(hTaddbutton(4),'string','Add','callback',@addprotocolinfo);
        check_warnings
    end
    function browseprotocol(~,~)
        collection_buttons('off','All')
        collection_buttons('on','protocol')
        if isempty(Saved_Protocols_new_version)
            set(status_name,'string','No saved protocols to browse');
            cancel_protocol
            return
        end
        set(hbrowselist,'visible','off','string','','min',0,'max',2,'HorizontalAlignment','left','style','listbox','callback',@getprotocols,'value',1)
        set(hTable,'visible','off')
        protocolCell = dataset2cell(Saved_Protocols_new_version);
        varNames = protocolCell(1,:);
        protocolCell(1,:) = [];
        incubatorStruct = Saved_Protocols_new_version.Incubator_Info(:);
        incubatorList = {incubatorStruct(:).Name};
        protocolCell(:,2) = incubatorList;
        stimStruct = Saved_Protocols_new_version.Stimuli_Vars(:);
        varNames(6) = {'Ele_Azi'};
        elevationList = {stimStruct(:).Elevation};
        azimuthList = {stimStruct(:).Azimuth};
        eleaziList = cellfun(@(x,y) cat(2,x,'/',y),elevationList,azimuthList,'uniformoutput',false);
        protocolCell(:,6) = eleaziList;
        cellRefs = cellfun(@(x) iscell(x),protocolCell(:,7));
        photoList = protocolCell(:,7);
        photoList(cellRefs) = cellfun(@(x) cat(2,x{:}),photoList(cellRefs),'uniformoutput',false);
        protocolCell(:,7) = photoList;
        protocolCell(:,8) = [];
        cellRefs = cellfun(@(x) iscell(x),protocolCell(:,10));
        protocolCell(cellRefs,10) = cellfun(@(x) x{1},protocolCell(cellRefs,10),'uniformoutput',false);
        %         protocolCell(:,10) = cellfun(@(x) cat(2,x{:}),protocolCell(:,10),'uniformoutput',false);
        varNames(8) = [];
        varNames(1) = [];
        set(hTable,'Data',protocolCell(:,2:end),'ColumnName',varNames,...
            'RowName',protocolCell(:,1),'units','normalized','visible','on');
        set(hTable,'position',[0 0 .3 1])
        set(browse_pan,'Visible','off','string','','position',[0 .980 .300 .025],'fontweight','bold');
    end

    function save_protocol(~,~)
        flip_buttons('on')
        set(hTbrowsebutton(4),'string','Browse');
        set(hTaddbutton(4),'string','Add','callback',@addprotocolinfo);
        last_list = 99;
        if isempty(Saved_Protocols_new_version)
            list_index = 0 + last_list;
        else
            list_index = str2double(get(Saved_Protocols_new_version,'ObsNames'));
        end
        new_index = max(list_index) + 1;
        exp_index = sprintf('%04s',num2str(new_index));
        current_protocol = set(current_protocol,'ObsNames',exp_index);
        
        if isempty(Saved_Protocols_new_version)
            Saved_Protocols_new_version = current_protocol;
        else
            check_for_dup_entry
            if ~isempty(match_index)
                new_index = last_list + match_index + 1;
            else
                Saved_Protocols_new_version = [Saved_Protocols_new_version;current_protocol];
                list_index = str2double(get(Saved_Protocols_new_version,'ObsNames'));
                new_index = numel(list_index) + last_list + 1;
            end
        end
        set(hTdropdown(4),'string',[{'Protocol ID'};get(Saved_Protocols_new_version,'ObsNames')],'value',(new_index - last_list));
        save([file_dir filesep file_path_protocol_new],'Saved_Protocols_new_version');
        check_warnings
        %        set(hTdropdown(4),'string',[{'Protocol ID'};get(Saved_Protocols_new_version,'ObsNames')],'value',(new_index - (last_list+1));
        
        setprotocolinfo(hTdropdown(4))
        match_index = [];
    end
    function check_for_dup_entry(~,~)
        entry_list = get(Saved_Protocols_new_version,'VarNames');
        var_list = get(Saved_Protocols_new_version,'ObsNames');
        Logic_match = zeros(length(var_list),length(entry_list));
        for iterZ = 1:length(entry_list)
            try
                Logic_match(:,iterZ) =  ismember(Saved_Protocols_new_version.(entry_list{iterZ}),current_protocol.(entry_list{iterZ}));
            catch
                Logic_match(:,iterZ) =  arrayfun(@(x) isequal(x,current_protocol.(entry_list{iterZ})),Saved_Protocols_new_version.(entry_list{iterZ}));
            end
        end
        matching = sum(Logic_match,2) == length(entry_list);
        if sum(matching) > 0
            current_protocol = [];
            match_index = find(matching,1,'first');
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% genders and balancers
    function setgenders(~,~)
        if sum(cell2mat(get(hGender,'value'))) >= 1
            set(hTlabels_genotype(3),'backgroundcolor',rgb('light green'));
        else
            set(hTlabels_genotype(3),'backgroundcolor',rgb('light red'));
        end
        check_warnings
    end
    function setblancers(~,~)
        if sum(cell2mat(get(hBalance,'value'))) >= 2 &&  get(hBalance(1),'value') == 1
            set(status_name,'string','User Selected both No balancers as well as a Chromosome Balancer')
            set(hBalance,'Value',0);
        end
        
        if sum(cell2mat(get(hBalance,'value'))) >= 1
            set(hTlabels_genotype(4),'backgroundcolor',rgb('light green'));
        else
            set(hTlabels_genotype(4),'backgroundcolor',rgb('light red'));
        end
        check_warnings
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% collection functions
    function browsecollections(~,~)
        flip_protocol('off')
        set(hTdropdown(2),'value',1);
        setcollectioninfo(hTdropdown(2))
        if get(hTdropdown(1),'value') == 1
            set(status_name,'string','No User Selected, please fix before browsing collections')
            return
        end
        if isempty(full_collection)
            set(status_name,'string','No Collections to browse')
            return
        end
        collection_buttons('off','All')
        collection_buttons('on','collection')
        new_string = cellfun(@(x,y) sprintf('%s:   %s',x,y),get(full_collection,'ObsNames'),full_collection.Collection_Name,'UniformOutput',false);
        set(hbrowselist,'visible','on','string',new_string,'min',0,'max',2,'HorizontalAlignment','left','style','listbox','value',1,'callback',@getcollect)
        set(hTable,'visible','off')
        set(status_name,'string','Searching Complete')
    end
    function getcollect(~,~)
        index = get(hbrowselist,'value');
        set(hTdropdown(2),'value',(index+1));
        setcollectioninfo(hTdropdown(2))
    end
    function setcollectioninfo(hObj,~)
        flip_protocol('off')
        value = get(hObj,'Value') - 1;
        if value > 0
            set(hCount_val,'Enable','On');
            set(hCalender,'Enable','On');
            set(hTlabels(2),'backgroundcolor',[.8 .8 .8]);
            collection_buttons('On','collection');
            set(collection_name,'Style','text','string',sprintf('%s',full_collection.Collection_Name{value}));        %sets the name of the collection
            new_id = get(hTdropdown(5),'string');
            entries = get(full_collection,'ObsNames');
            new_id(1:4) = entries{value};
            set(hTdropdown(5),'string',new_id);
            show_description
            
            exp_names = get(Saved_Experiments,'ObsNames');
            if ~isempty(exp_names)
                partial_names = cellfun(@(x) x(1:4),exp_names,'uniformoutput',false);
                set(hCount_val,'string',max(str2double(Saved_Experiments.Target_count(strcmp(entries{value},partial_names)))));
                getcounts(hCount_val)
            end
            show_description
        else
            set(hCount_val,'Enable','Off');
            set(hCalender,'Enable','Off');
            set(hEditCollection,'Enable','Off')
            collection_buttons('Off','All');
            set(collection_name,'string',newline);        %sets the name of the collection
            set(hbrowselist,'Style','text','visible','on','string','','min',0,'max',2,'HorizontalAlignment','left')
            new_id = get(hTdropdown(5),'string');
            new_id(1:4) ='0000';
            set(hTdropdown(5),'string',new_id);
            set(hDuration_days,'String',sprintf('.....'));
            set(hDuration_runs,'String',sprintf('.....'));
            set(hCount_val,'string','100');
            
        end
        check_warnings
    end
    function show_description(~,~)
        flip_protocol('off')
        set(hEditCollection,'Enable','On');
        value = get(hTdropdown(2),'value')-1;
        if value == 0
            value = get(hbrowselist,'value');
            set(hTdropdown(2),'value',(value+1));
        end
        set(hbrowselist,'visible','on','string',full_collection.Collection_Description{value},'min',0,'max',2,'HorizontalAlignment','left','style','text')
        set(hTable,'visible','off')
    end
    function show_lines_in_collection(~,~)
        flip_protocol('off')
        collect_ids = cellfun(@(x) x(1:4),(get(Saved_Experiments,'ObsNames')),'UniformOutput',false);
        genotype_ids = cellfun(@(x) x(5:12),(get(Saved_Experiments,'ObsNames')),'UniformOutput',false);
        
        value = get(hTdropdown(2),'value')-1;
        if value == 0
            value = get(hbrowselist,'value');
            set(hTdropdown(2),'value',(value+1));
        end
        if value > 0
            collection_selected = get(full_collection,'ObsNames');
            collection_selected = collection_selected(value);
            genotype_ids = genotype_ids(ismember(collect_ids,collection_selected));
            saved_geno_ids = Saved_Genotypes(ismember(get(Saved_Genotypes,'ObsNames'),genotype_ids),:);
        else
            saved_geno_ids = [];
        end
        
        if isempty(saved_geno_ids)
            new_string = 'No Genotypes are in this Collection';
        else
            new_string = cellfun(@(v,w,x) sprintf('           Genotype_ID:    %s \n  ParentA:  %s\n  ParentB: %s\n',v,w,x),...
                get(saved_geno_ids,'ObsNames'),saved_geno_ids.ParentA_name,saved_geno_ids.ParentB_name,'UniformOutput',false);
        end
        collections = get(hTdropdown(2),'string');
        collections = collections(2:end);
        
        all_experiments = get(Saved_Experiments,'ObsNames');
        matching = cellfun(@(x) ismember(x(1:4),collections),all_experiments);
        matching = cellfun(@(x) x(5:12),all_experiments(matching),'uniformoutput',false);
        matching = cellfun(@(x) sum(cell2mat(strfind(matching,x))),get(Saved_Genotypes,'ObsNames'),'uniformoutput',false);
        genotype_subset = Saved_Genotypes(cell2mat(matching) > 0,:);
        
        set(hbrowselist,'value',1);
        if length(get(hbrowselist,'string')) > 1
            [outstring,~] = textwrap(hbrowselist,new_string);
        else
            outstring = new_string;
        end
        set(hbrowselist,'visible','on','string',outstring,'min',0,'max',2,'HorizontalAlignment','left','style','listbox','callback',@getgeno_entry)
        set(hTable,'visible','off')
    end
    function editcollection(~,~)
        flip_protocol('off')
        show_description
        if strcmp(get(hEditCollection,'Enable'),'Off')
            collection_edit_flag = 0;
        else
            collection_edit_flag = 1;
        end
        addcollectioninfo
    end
    function addcollectioninfo(~,~)
        flip_protocol('off')
        set(status_name,'string','Enter Name and Description for this Collection');
        collection_buttons('Off','All')
        if get(hTdropdown(1),'value') == 1
            cancel_collection
            set(status_name,'string','No User Selected, please fix before creating a new collection')
            return
        end
        set(hColection_label,'backgroundcolor',rgb('light red'));
        flip_genotypes('off')
        flip_protocol('off')
        flip_buttons('off')
        if collection_edit_flag == 0
            set(collection_name,'style','edit','string',{''});        %sets the name of the collection
            set(hbrowselist,'style','edit','visible','on','string',{''},'min',0,'max',2,'HorizontalAlignment','left')
        elseif collection_edit_flag == 1
            set(collection_name,'style','edit');        %sets the name of the collection
            show_description
            set(hbrowselist,'style','edit','visible','on','min',0,'max',2,'HorizontalAlignment','left')
        end
        
        set(hTbrowsebutton(2),'string','Save','callback',@save_collection,'enable','on');
        set(hTaddbutton(2),'String','Cancel','callback',@cancel_collection,'enable','on');
    end
    function save_collection(~,~)
        set(status_name,'string','');
        set(hColection_label,'backgroundcolor',[.8 .8 .8]);
        user_text = get(hbrowselist,'string');
        name_entry = get(collection_name,'string');
        if ischar(name_entry)
            name_entry = cellstr(name_entry);
        end
        if isempty(user_text{1,1})
            set(status_name,'string','Description is empty, please Enter a Description for this collection');
        elseif isempty(name_entry{1,1})
            set(status_name,'string','Name of Collection is empty, please Enter a Name for this collection');
        else
            if collection_edit_flag == 0
                var_names = [{'Collection_Name'},{'Collection_Description'},{'User_ID'},{'Videos_In_Collection'}];
                varspecs = cell(1,numel(var_names));
                current_collection = dataset([{varspecs},var_names]);
                
                last_index = length(Saved_Collection(:,1));
                if max(str2double(get(Saved_Collection,'ObsNames'))) > last_index
                    records_exists = ~ismember((1:1:max(str2double(get(Saved_Collection,'ObsNames')))),str2double(get(Saved_Collection,'ObsNames')));
                    last_index = find(records_exists,1,'first') - 1;
                end
                
                current_collection.Collection_Name(1) = name_entry;
                current_collection.Collection_Description(1) = {user_text};
                name_list = get(hTdropdown(1),'string');
                name_index = get(hTdropdown(1),'value');
                
                current_collection.User_ID(1) = name_list(name_index);
                current_collection.Videos_In_Collection(1) = {0};
                current_collection.Archived_Videos(1) = {0};
                current_collection.Videos_In_Collection = cell2mat(current_collection.Videos_In_Collection);
                current_collection.Archived_Videos = cell2mat(current_collection.Archived_Videos);
                current_collection = set(current_collection,'ObsNames',{sprintf('%04s',num2str((last_index+1)))});
                if isempty(Saved_Collection)
                    Saved_Collection = current_collection;
                else
                    Saved_Collection = [Saved_Collection;current_collection];
                end
            else
                col_list = get(hTdropdown(2),'string');
                col_index = get(hTdropdown(2),'value');
                mod_collections = strcmp(get(Saved_Collection,'ObsNames'),col_list(col_index));
                Saved_Collection.Collection_Name(mod_collections) = name_entry;
                Saved_Collection.Collection_Description(mod_collections) = {user_text};
            end
            
            index = get(hTdropdown(1),'Value')-1;
            find_match = strcmp(Saved_Collection.User_ID,user_names.User_ID{index});
            full_collection = Saved_Collection(find_match,:);
            set(hTdropdown(2),'string',[{'Collection ID'};get(full_collection,'ObsNames')],'callback',@setcollectioninfo);
            
            fileattrib([file_dir filesep file_path_collection],'+w');
            save([file_dir filesep file_path_collection],'Saved_Collection');
            set(hbrowselist,'style','text','visible','off')
            
            set(hTbrowsebutton(2),'string','Browse','callback',@browsecollections);
            set(hTaddbutton(2),'string','Add','callback',@addcollectioninfo);
            set(hTdropdown(2),'value', length(get(hTdropdown(2),'string')))
            setcollectioninfo(hTdropdown(2))
            
            flip_genotypes('off')
            flip_protocol('off')
            flip_buttons('on')
            set(status_name,'string','Database has been updated');
        end
        check_warnings
    end
    function cancel_collection(~,~)
        set(status_name,'string','');
        set(hColection_label,'backgroundcolor',[.8 .8 .8]);
        flip_genotypes('off')
        flip_protocol('off')
        flip_buttons('on')
        set(hTbrowsebutton(2),'string','Browse');
        set(hTaddbutton(2),'string','Add','callback',@addcollectioninfo);
        set(hTbrowsebutton(2),'callback',@browsecollections);
        if collection_edit_flag == 0
            set(collection_name,'style','text','string',{''});        %sets the name of the collection
            set(hbrowselist,'style','text','visible','off')
        else
            collection_buttons('On','collection')
        end
        check_warnings
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% summary genotype functions
    function setbrowseflag(hObj,~)
        flip_protocol('off')
        if hObj == hBrowseAll
            browseflag = 'All';
            set(hBrowseAll,'backgroundcolor',rgb('light purple'))
            set(hBrowsePartial,'backgroundcolor',[.8 .8 .8])
        elseif hObj == hBrowsePartial
            browseflag = 'User';
            set(hBrowseAll,'backgroundcolor',[.8 .8 .8])
            set(hBrowsePartial,'backgroundcolor',rgb('light purple'))
        end
        if hObj == hshowAll
            showflag = 'All';
            set(hshowAll,'backgroundcolor',rgb('light purple'))
            set(hshowparents,'backgroundcolor',[.8 .8 .8])
            set(hshowgenotypes,'backgroundcolor',[.8 .8 .8])
        elseif hObj ==  hshowparents
            showflag = 'Parents';
            set(hshowAll,'backgroundcolor',[.8 .8 .8])
            set(hshowparents,'backgroundcolor',rgb('light purple'))
            set(hshowgenotypes,'backgroundcolor',[.8 .8 .8])
            
        elseif hObj == hshowgenotypes
            showflag = 'Genotypes';
            set(hshowAll,'backgroundcolor',[.8 .8 .8])
            set(hshowparents,'backgroundcolor',[.8 .8 .8])
            set(hshowgenotypes,'backgroundcolor',rgb('light purple'))
        end
        browsegenotypes
    end
    function browsegenotypes(~,~)
        set(browse_pan,'Visible','on','string','','position',[0 .980 .300 .025],'fontweight','bold');
        flip_protocol('off')
        collection_buttons('off','All')
        set(hBrowseAll,'visible','on','enable','on')
        set(hBrowsePartial,'visible','on','enable','on')
        set(hshowAll,'visible','on','enable','on')
        set(hshowparents,'visible','on','enable','on')
        set(hshowgenotypes,'visible','on','enable','on')
        
        if isempty(Saved_Genotypes)              %if no names, then nothing to browse
            set(status_name,'string','No saved genotypes to browse');
            return
        end
        if strcmp(browseflag,'All')
            genotype_subset = Saved_Genotypes;
        elseif strcmp(browseflag,'User')
            collect_value = get(hTdropdown(2),'value');
            collections = get(hTdropdown(2),'string');
            collections = collections(collect_value);
            
            all_experiments = get(Saved_Experiments,'ObsNames');
            matching = cellfun(@(x) ismember(x(1:4),collections),all_experiments);
            matching = cellfun(@(x) x(5:12),all_experiments(matching),'uniformoutput',false);
            matching = cellfun(@(x) sum(cell2mat(strfind(matching,x))),get(Saved_Genotypes,'ObsNames'),'uniformoutput',false);
            genotype_subset = Saved_Genotypes(cell2mat(matching) > 0,:);
        end
        geno_dim = length(genotype_subset(:,1));
        gender_cat = cell(geno_dim,1);
        balance_cat = cell(geno_dim,1);
        
        gender_cat(cell2mat(genotype_subset.Males) == 1 & cell2mat(genotype_subset.Females) == 0) = {'Male Flies only'};
        gender_cat(cell2mat(genotype_subset.Males) == 0 & cell2mat(genotype_subset.Females) == 1) = {'Female Flies only'};
        gender_cat(cell2mat(genotype_subset.Males) == 1 & cell2mat(genotype_subset.Females) == 1) = {'Male and Female Flies'};
        
        balance_cat(cell2mat(genotype_subset.No_Balancers) == 1) = {'No Balancers Selected'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 1 & cell2mat(genotype_subset.Chromosome2) == 0 & cell2mat(genotype_subset.Chromosome3) == 0) = {'Balancers on Chromosome 1 only'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 0 & cell2mat(genotype_subset.Chromosome2) == 1 & cell2mat(genotype_subset.Chromosome3) == 0) = {'Balancers on Chromosome 2 only'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 0 & cell2mat(genotype_subset.Chromosome2) == 0 & cell2mat(genotype_subset.Chromosome3) == 1) = {'Balancers on Chromosome 3 only'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 1 & cell2mat(genotype_subset.Chromosome2) == 1 & cell2mat(genotype_subset.Chromosome3) == 1) = {'Balancers on Chromosomes 1,2 and 3'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 1 & cell2mat(genotype_subset.Chromosome2) == 1 & cell2mat(genotype_subset.Chromosome3) == 0) = {'Balancers on Chromosomes 1 and 2'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 1 & cell2mat(genotype_subset.Chromosome2) == 0 & cell2mat(genotype_subset.Chromosome3) == 1) = {'Balancers on Chromosomes 1 and 3'};
        balance_cat(cell2mat(genotype_subset.Chromosome1) == 0 & cell2mat(genotype_subset.Chromosome2) == 2 & cell2mat(genotype_subset.Chromosome3) == 1) = {'Balancers on Chromosomes 2 and 3'};
        
        if isempty(genotype_subset)
            outstring = 'No Genotypes are saved for this User';
        else
            switch showflag
                case 'All'
                    new_string = cellfun(@(v,w,x,y,z,a,b) sprintf('           Genotype_ID:    %s \n ParentA_Name:  %s\n     Genotype:  %s\nParentB_Name:  %s\n     Genotype:  %s\nGenders Used:   %s\nBalancers Used:   %s\n',v,w,x,y,z,a,b),...
                        get(genotype_subset,'ObsNames'),genotype_subset.ParentA_name,genotype_subset.ParentA_genotype,genotype_subset.ParentB_name,genotype_subset.ParentB_genotype,gender_cat,balance_cat,'UniformOutput',false);
                case 'Parents'
                    new_string = cellfun(@(v,w,x) sprintf('           Genotype_ID:    %s \n ParentA_Name:  %s\nParentB_Name:  %s\n',v,w,x),...
                        get(genotype_subset,'ObsNames'),genotype_subset.ParentA_name,genotype_subset.ParentB_name,'UniformOutput',false);
                case 'Genotypes'
                    new_string = cellfun(@(v,w,x) sprintf('           Genotype_ID:    %s \n ParentA_Genotype:  %s\nParentB_Genotype:  %s\n',v,w,x),...
                        get(genotype_subset,'ObsNames'),genotype_subset.ParentA_genotype,genotype_subset.ParentB_genotype,'UniformOutput',false);
            end
            [outstring,~] = textwrap(hbrowselist,new_string);
        end
        set(hbrowselist,'visible','on','string',outstring,'min',0,'max',2,'HorizontalAlignment','left','style','listbox','callback',@getgeno_entry,'value',1)
        set(hTable,'visible','off')
        set(status_name,'string','Searching Complete')
    end
    function getgeno_entry(~,~)
        index = get(hbrowselist,'value');
        blank_lines = cellfun(@(x) isempty(x),get(hbrowselist,'string'));
        
        upper_limit =  find(blank_lines(index:end),1,'first') - 2;
        lower_limit =  find(blank_lines(1:index),1,'last') +1;
        if upper_limit == -1     %blank space
            return
        end
        if isempty(lower_limit)
            lower_limit = 1;
        end
        
        set(hbrowselist,'value',lower_limit:1:(index+upper_limit))
        new_spot = sum(blank_lines(1:index))+1;
        matching = ismember(get(Saved_Genotypes,'ObsNames'),get(genotype_subset(new_spot,:),'ObsNames'));
        set(hTdropdown(3),'value',(find(matching,1,'first')+1));
        setgenotypeinfo(hTdropdown(3))
        set(hBrowseAll,'visible','on','enable','on')
        set(hBrowsePartial,'visible','on','enable','on')
        set(hshowAll,'visible','on','enable','on')
        set(hshowparents,'visible','on','enable','on')
        set(hshowgenotypes,'visible','on','enable','on')
    end
    function setgenotypeinfo(hObj,~)
        flip_protocol('off')
        collection_buttons('off','All')
        collection_buttons('on','collection')
        value = get(hObj,'Value') - 1;
        if value > 0
            set(hTlabels(3),'backgroundcolor',[.8 .8 .8]);
            set(hTdropdown_Robot_ID(1),'string',Saved_Genotypes.ParentA_ID{value});
            set(hTdropdown_Robot_ID(2),'string',Saved_Genotypes.ParentB_ID{value});
            set(hTdropdown_genotype_name(1),'string',Saved_Genotypes.ParentA_name{value});
            set(hTdropdown_genotype_name(2),'string',Saved_Genotypes.ParentB_name{value});
            
            set(hGender(1),'value',Saved_Genotypes.Males{value});
            set(hGender(2),'value',Saved_Genotypes.Females{value});
            set(hBalance(1),'value',Saved_Genotypes.No_Balancers{value});
            set(hBalance(2),'value',Saved_Genotypes.Chromosome1{value});
            set(hBalance(3),'value',Saved_Genotypes.Chromosome2{value});
            set(hBalance(4),'value',Saved_Genotypes.Chromosome3{value});
            
            entries = get(Saved_Genotypes,'ObsNames');
            new_id = get(hTdropdown(5),'string');
            new_id(5:12) = entries{value};
            %            new_id(9:12) = entries{value};
            set(hTdropdown(5),'string',new_id);
        else
            set(hTdropdown_Robot_ID(1),'string','Robot_ID');
            set(hTdropdown_Robot_ID(2),'string','Robot_ID');
            set(hTdropdown_genotype_name(1),'string','ParentA');
            set(hTdropdown_genotype_name(2),'string','ParentB');
            
            set(hGender(1),'value',0);              set(hGender(2),'value',0);
            set(hBalance(1),'value',0);             set(hBalance(2),'value',0);
            set(hBalance(3),'value',0);             set(hBalance(4),'value',0);
            
            new_id = get(hTdropdown(5),'string');
            new_id(5:12) ='00000000';
            %            new_id(9:12) ='00000000';
            set(hTdropdown(5),'string',new_id);
        end
        check_warnings
    end
    function addgenotypeinfo(~,~)
        flip_protocol('off')
        check_warnings
        collection_buttons('off','All')
        set(hTlabels_genotype,'backgroundcolor',rgb('light red'));
        set(hTdropdown(3),'value',1)
        set(hbrowselist,'style','edit','visible','on','string',{''},'min',0,'max',2,'HorizontalAlignment','left')
        %        set(hTdropdown_genotype_name(1),'string',Genotype_labels(1))
        %        set(hTdropdown_genotype_name(2),'string',Genotype_labels(2))
        %        set(hTdropdown_Robot_ID(1),'string','Robot_ID')
        %        set(hTdropdown_Robot_ID(2),'string','Robot_ID')
        %        set(hGender,'value',0);
        %        set(hBalance,'value',0);
        
        flip_genotypes('on')
        flip_protocol('off')
        flip_buttons('off')
        
        set(hTbrowsebutton(3),'string','Save','callback',@save_genotypes,'Enable','On');
        set(hTaddbutton(3),'String','Cancel','callback',@cancel_genotypes,'Enable','On');
    end
    function save_genotypes(~,~)
        flip_genotypes('off')
        flip_buttons('on')
        
        if get(hGender(1),'value') == 0 && get(hGender(2),'value') == 0
            set(status_name,'string','No genders selected for this genotype, please selecet at least one gender');
            flip_genotypes('on')
            flip_buttons('off')
            set(hTbrowsebutton(3),'Enable','On');
            set(hTaddbutton(3),'Enable','On');
            return
        end
        if sum(cell2mat(get(hBalance,'value'))) == 0
            set(status_name,'string','Select at least One Balancer option');
            flip_genotypes('on')
            flip_buttons('off')
            set(hTbrowsebutton(3),'Enable','On');
            set(hTaddbutton(3),'Enable','On');
            return
        end
        if strcmp(get(hTdropdown_genotype_name(1),'string'),'Parent A') || strcmp(get(hTdropdown_genotype_name(2),'string'),'Parent B')
            set(status_name,'string','Parents are Missing, please select Parents');
            flip_genotypes('on')
            flip_buttons('off')
            set(hTbrowsebutton(3),'Enable','On');
            set(hTaddbutton(3),'Enable','On');
            return
        end
        set(hTlabels_genotype,'backgroundcolor',[.8 .8 .8]);
        last_index = length(Saved_Genotypes(:,1));
        var_names = [{'ParentA_name'},{'ParentA_ID'},{'ParentA_genotype'},{'ParentB_name'},{'ParentB_ID'},{'ParentB_genotype'},{'Males'},{'Females'},{'No_Balancers'},{'Chromosome1'},{'Chromosome2'},{'Chromosome3'}];
        varspecs = cell(1,numel(var_names));
        current_genotypes = dataset([{varspecs},var_names]);
        
        if ~iscell(get(hTdropdown_genotype_name(1),'string'))
            current_genotypes.ParentA_name = {get(hTdropdown_genotype_name(1),'string')};
            current_genotypes.ParentA_ID = {get(hTdropdown_Robot_ID(1),'string')};
            current_genotypes.ParentA_genotype =  parent_genotype(1);
        else
            current_genotypes.ParentA_name = get(hTdropdown_genotype_name(1),'string');
            current_genotypes.ParentA_ID = get(hTdropdown_Robot_ID(1),'string');
            current_genotypes.ParentA_genotype =  parent_genotype(1);
        end
        if ~iscell(get(hTdropdown_genotype_name(2),'string'))
            current_genotypes.ParentB_name = {get(hTdropdown_genotype_name(2),'string')};
            current_genotypes.ParentB_ID = {get(hTdropdown_Robot_ID(2),'string')};
            current_genotypes.ParentB_genotype =  parent_genotype(2);
            
        else
            current_genotypes.ParentB_name = get(hTdropdown_genotype_name(2),'string');
            current_genotypes.ParentB_ID = get(hTdropdown_Robot_ID(2),'string');
            current_genotypes.ParentB_genotype =  parent_genotype(2);
        end
        
        current_genotypes.Males = {get(hGender(1),'value')};
        current_genotypes.Females = {get(hGender(2),'value')};
        
        current_genotypes.No_Balancers = {get(hBalance(1),'value')};
        current_genotypes.Chromosome1 =  {get(hBalance(2),'value')};
        current_genotypes.Chromosome2 =  {get(hBalance(3),'value')};
        current_genotypes.Chromosome3 =  {get(hBalance(4),'value')};
        current_genotypes = set(current_genotypes,'ObsNames',{sprintf('%08s',num2str((last_index+1)))});
        
        if isempty(Saved_Genotypes )
            Saved_Genotypes  = current_genotypes;
            logical_match = 0;
        else
            logical_match = cellfun(@(r,s,t,u,v,w,x,y) strcmp(r, current_genotypes.ParentA_name) & strcmp(s, current_genotypes.ParentB_name) & t == cell2mat(current_genotypes.Males) & u == cell2mat(current_genotypes.Females) & ...
                v == cell2mat(current_genotypes.No_Balancers) & w == cell2mat(current_genotypes.Chromosome1) & x == cell2mat(current_genotypes.Chromosome2) & y == cell2mat(current_genotypes.Chromosome3),...
                Saved_Genotypes.ParentA_name,Saved_Genotypes.ParentB_name,Saved_Genotypes.Males,Saved_Genotypes.Females,Saved_Genotypes.No_Balancers,Saved_Genotypes.Chromosome1,Saved_Genotypes.Chromosome2,Saved_Genotypes.Chromosome3,'UniformOutput',false);
            
            logical_match = cellfun(@(x) sum(x), logical_match);
            if sum(logical_match) == 0
                Saved_Genotypes  = [Saved_Genotypes ;current_genotypes];
            end
        end
        
        fileattrib([file_dir filesep file_path_genotype],'+w');
        save([file_dir filesep file_path_genotype],'Saved_Genotypes');
        set(hbrowselist,'style','listbox','visible','off')
        
        set(hTbrowsebutton(3),'string','Browse');
        set(hTaddbutton(3),'string','Add','callback',@addgenotypeinfo);
        set(hTbrowsebutton(3),'callback',@browsegenotypes);
        set(hTdropdown(3),'string',[{'Genotype ID'};get(Saved_Genotypes,'ObsNames')],'callback',@setgenotypeinfo);
        if sum(logical_match) > 0
            new_index = find(logical_match,1,'first') + 1;
            set(hTdropdown(3),'value',new_index);
        else
            set(hTdropdown(3),'value', length(get(hTdropdown(3),'string')))
        end
        setgenotypeinfo(hTdropdown(3));
        check_warnings
        set(status_name,'string','Database has been updated');
    end
    function cancel_genotypes(~,~)
        flip_protocol('off')
        cancelnewline
        
        set(hTlabels_genotype,'backgroundcolor',[.8 .8 .8]);
        set(hTdropdown_genotype_name(1),'string','Robot_ID')
        set(hTdropdown_genotype_name(2),'string','Robot_ID')
        set(hTdropdown_Robot_ID(1),'string',Genotype_labels(1))
        set(hTdropdown_Robot_ID(2),'string',Genotype_labels(2))
        set(hGender,'value',0);
        set(hBalance,'value',0);
        flip_genotypes('off')
        flip_buttons('on')
        set(hTbrowsebutton(3),'string','Browse');
        set(hTaddbutton(3),'string','Add','callback',@addgenotypeinfo);
        set(hTbrowsebutton(3),'callback',@browsegenotypes);
        set(collection_name,'style','text','string',{''});        %sets the name of the collection
        set(hbrowselist,'style','listbox','visible','off')
        check_warnings
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% line searching functions
    function addnewline(hObj,~)
        flip_genotypes('off')
        collection_buttons('off','All')
        parent_index = hTadd_genotype == hObj;
        set(hbrowselist,'visible','on','string','')
        set(hTable,'visible','off')
        %         hBulklabel = uicontrol(hPanC,'Style','text','string','Load Bulk Data','Units','normalized','HorizontalAlignment','center',...
        %             'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4519,'position',[0.10 .715 .100 .05]);
        %         hBulkPath = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','center',...
        %             'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.4519,'position',[0.01 .680 .275 .05],'callback',@loadbulk_genotype);
        
        hLineLabel = uicontrol(hPanC,'Style','text','string','Enter Line Information:','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.8619,'position',[0.01 .900 .280 .025]);
        hStocklabel = uicontrol(hPanC,'Style','text','string','Stock Name','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4519,'position',[0.10 .615 .100 .05]);
        hNewLine = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.4519,'position',[0.01 .575 .275 .05]);
        hGenolabel = uicontrol(hPanC,'Style','text','string','Genotype','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4519,'position',[0.1 .490 .100 .05]);
        hNewGeno = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('white'),'fontunits','normalized','fontsize',.4519,'position',[0.01 .425 .275 .05]);
        
        hcheckadd = uicontrol(hPanC,'Style','pushbutton','string','Compare','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.4519,'position',[0.01 .325 .275 .05],'callback',@checknewline);
        hcanceladd = uicontrol(hPanC,'Style','pushbutton','string','Cancel','Units','normalized','HorizontalAlignment','center',...
            'BackgroundColor',rgb('light grey'),'fontunits','normalized','fontsize',.4519,'position',[0.01 .250 .275 .05],'callback',@cancelnewline);
    end
    function loadbulk_genotype(~,~)
        addgenotypeinfo
        addnewline(hTadd_genotype(1))
        fliplabels('off');
        [filename,filedir] = uigetfile({'*.xls;*.xlsx','Excel Files'},'Select the Excel file for bulk loading',...
            fileparts(file_dir));
        if filename == 0, return, end
        filepath = fullfile(filedir,filename);
        if exist(filepath,'file')
            excelData = dataset('XLSFile',filepath);
            ParentA_list = excelData.ParentA;
            ParentB_list = excelData.ParentB;
            if ~iscell(ParentA_list)
                ParentA_list = ParentA_list(arrayfun(@(x) ~isempty(x),ParentA_list));
            else
                ParentA_list = ParentA_list(cellfun(@(x) ~isempty(x),ParentA_list));
            end
            if ~iscell(ParentB_list)
                ParentB_list = ParentB_list(arrayfun(@(x) ~isempty(x),ParentB_list));
            else
                ParentB_list = ParentB_list(cellfun(@(x) ~isempty(x),ParentB_list));
            end
            Act = length(ParentA_list);
            Bct = length(ParentB_list);
            sheetName = ['results_' datestr(now,'yyyymmddHHMM')];
            for iterZ = 1:Act
                for iterQ = 1:Bct
                    if isnumeric(ParentA_list(iterZ))
                        set(hNewLine,'string',num2str(ParentA_list(iterZ)));
                    else
                        set(hNewLine,'string',num2str(ParentA_list{iterZ}));
                    end
                    execute_query(hNewLine);
                    parent_index = [true;false];
                    name_index = 1;
                    emptyBool = cellfun(@(x) ~isempty(x),genotype_list.Robot_ID,'uniformoutput',false);
                    singleTest = sum(cell2mat(emptyBool));
                    if singleTest > 1
                        sprintf('%s has multiple matches',get(hNewLine,'string'))
                    else
                        set(hTdropdown_Robot_ID(parent_index),'string',genotype_list.Robot_ID(name_index))
                        set(hTdropdown_genotype_name(parent_index),'string',genotype_list.Stock_Name(name_index),'HorizontalAlignment','left')
                        set(hTlabels_genotype([parent_index; false;false]),'backgroundcolor',rgb('light green'));
                        parent_genotype(parent_index) = genotype_list.Genotype(name_index);
                    end
                    
                    if isnumeric(ParentB_list(iterQ))
                        set(hNewLine,'string',num2str(ParentB_list(iterQ)));
                    else
                        set(hNewLine,'string',num2str(ParentB_list{iterQ}));
                    end
                    execute_query(hNewLine);
                    parent_index = [false;true];
                    name_index = 1;
                    emptyBool = cellfun(@(x) ~isempty(x),genotype_list.Robot_ID,'uniformoutput',false);
                    singleTest = sum(cell2mat(emptyBool));
                    if singleTest > 1
                        sprintf('%s has multiple matches',get(hNewLine,'string'))
                    else
                        set(hTdropdown_Robot_ID(parent_index),'string',genotype_list.Robot_ID(name_index))
                        set(hTdropdown_genotype_name(parent_index),'string',genotype_list.Stock_Name(name_index),'HorizontalAlignment','left')
                        set(hTlabels_genotype([parent_index; false;false]),'backgroundcolor',rgb('light green'));
                        parent_genotype(parent_index) = genotype_list.Genotype(name_index);
                    end
                    
                    set(hGender(1),'value',1)
                    set(hGender(2),'value',1)
                    set(hBalance(1),'value',1)
                    
                    save_genotypes
                    clear_list
                    drawnow
                    
                    parent_index = [true;false];
                    parentArecord = {get(hTdropdown_Robot_ID(parent_index),'string'),...
                        get(hTdropdown_genotype_name(parent_index),'string'),...
                        parent_genotype{parent_index}};
                    
                    parent_index = [false;true];
                    parentBrecord = {get(hTdropdown_Robot_ID(parent_index),'string'),...
                        get(hTdropdown_genotype_name(parent_index),'string'),...
                        parent_genotype{parent_index}};
                    
                    genoStrings = get(hTdropdown(3),'string');
                    genoVal = get(hTdropdown(3),'value');
                    if iterZ == 1 && iterQ == 1
                        xlsResult = {'Genotype_ID','ParentA_ID','ParentA_Name','ParentA_Genotype',...
                            'ParentB_ID','ParentB_Name','ParentB_Genotype'};
                        xlswrite(filepath,xlsResult,sheetName,...
                            ['A' num2str(1) ':G' num2str(1)]);
                    end
                    xlsResult = [genoStrings(genoVal) parentArecord parentBrecord];
                    xlsRef = (iterZ-1)*Bct+iterQ+1;
                    xlswrite(filepath,xlsResult,sheetName,...
                        ['A' num2str(xlsRef) ':G' num2str(xlsRef)]);
                end
            end
        end
    end
    function fliplabels(flag)
        set(hLineLabel,'visible',flag);
        set(hNewLine,'visible',flag);
        set(hNewGeno,'visible',flag);
        set(hStocklabel,'visible',flag);
        set(hGenolabel,'visible',flag);
        set(hBulklabel,'visible',flag);
        set(hBulkPath,'visible',flag);
        set(hcanceladd,'visible',flag)
        set(hcheckadd,'visible',flag)
    end
    function cancelnewline(~,~)
        flip_genotypes('on')
        genotype_list = [];
        set(hbrowselist,'string',genotype_list)
        fliplabels('off');
        set(hbrowse_IDS,'visible','off');
        set(hid_name,'visible','off');
        set(hbrowse_Stocks,'visible','off');
        set(hstock_name,'visible','off');
        set(hbrowse_Other,'visible','off');
        set(hother_name,'visible','off');
        check_warnings
    end
    function checknewline(~,~)
        set(hTbrowse_genotype(parent_index),'string','Ok','callback',@add_to_list)
        set(hTadd_genotype(parent_index),'string','Cancel','callback',@reset_genotype)
        
        flip_genotypes('on')
        line_result = {get(hNewLine,'string')};
        geno_result = {get(hNewGeno,'string')};
        
        fliplabels('off');
        
        last_index = length(Saved_User_Lines(:,1));
        list_names = str2double(cellfun(@(x) x(5:end),get(Saved_User_Lines,'ObsNames'),'uniformoutput',false));
        if max(list_names) > last_index
            records_exists = ~ismember((1:1:max(list_names)),list_names);
            last_entry = find(records_exists,1,'first') - 1;
        else
            last_entry = last_index;
        end
        
        var_names = [{'Robot_ID'},{'Stock_Name'},{'Genotype'}];
        varspecs = cell(1,numel(var_names));
        New_User_Lines = dataset([{varspecs},var_names]);
        New_User_Lines.Genotype = geno_result;
        New_User_Lines.Stock_Name = line_result;
        New_User_Lines.Robot_ID = {sprintf('Card%03s',num2str(last_entry+1))};
        New_User_Lines = set(New_User_Lines,'ObsNames',{sprintf('Card%03s',num2str(last_entry+1))});
        
        parse_adding
    end
    function add_to_list(~,~)
        reset_genotype
        set(hTdropdown_genotype_name(parent_index),'string',New_User_Lines.Stock_Name)
        set(hTdropdown_Robot_ID(parent_index),'string',get(New_User_Lines,'ObsNames'))
        set(hTlabels_genotype([parent_index; false;false]),'backgroundcolor',rgb('light green'));
        
        if isempty(Saved_User_Lines)
            Saved_User_Lines = New_User_Lines;
        else
            Saved_User_Lines = [Saved_User_Lines;New_User_Lines];
        end
        fileattrib([file_dir filesep file_path_lines],'+w');
        save([file_dir filesep file_path_lines],'Saved_User_Lines');
        
        check_warnings
        set(status_name,'string','Database has been updated');
        set(hTbrowse_genotype(parent_index),'enable','on')
    end
    function parse_adding(~,~)
        execute_query(hNewLine);
        match_check = cellfun(@(x) strcmp(get(hNewLine,'string'),x),genotype_list.Stock_Name);
        if sum(match_check) > 0
            
            set(hNewLine,'value',find(match_check,1,'first'));
            selectgenotype(hNewLine)
            cancelnewline
            clear_list
            return
        end
        
        set(hbrowselist,'position',[0 0.500 0.3000  0.4750],'fontsize',.0408)
        fliplabels('off');
        
        if isempty(genotype_list)
            set(hbrowselist,'string','no matching records');
        end
        geno_string = cellfun(@(x,y) sprintf('%8s    %s',x,y),...
            get(New_User_Lines,'ObsNames'),New_User_Lines.Stock_Name,'UniformOutput',false);
        
        set(hbrowseproto,'visible','on','string',geno_string);
        set(hbrowse_IDS,'string',genotype_list.Robot_ID,'value',1,'position',[0 .5000 .0400 .4750],'fontsize',0.0350);
        set(hbrowse_Stocks,'string',genotype_list.Stock_Name,'value',1,'position',[.0400 .5000 .110 .4750],'fontsize',0.0350);
        set(hbrowse_Other,'string',genotype_list.Genotype,'value',1,'position',[.150 .5000 .150 .4750],'fontsize',0.0350);
        
        if isempty(genotype_list)
            add_to_list
            return
        end
        %        set(hbrowselist,'style','listbox','visible','on','string',genotype_list.Stock_Name,'min',0,'max',2,'callback',[])
        set(status_name,'string','Searching Complete')
        
    end
    function search_genotype_database(hObj,~)
        parent_index = hTbrowse_genotype == hObj;
        genotype_list = [];
        set(hTbrowse_genotype(parent_index),'string','Ok','callback',@clear_list)
        set(hTadd_genotype(parent_index),'string','Cancel','callback',@reset_genotype)
        set(hTbrowse_genotype(~parent_index),'Enable','Off')
        set(hTadd_genotype(~parent_index),'Enable','Off')
        
        srch_button = uicontrol(hPanC,'Style','text','string','Search','Units','normalized','HorizontalAlignment','left',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[0 0 .1 .025],'visible','on','backgroundcolor',rgb('light orange'));
        
        srch_field = uicontrol(hPanC,'Style','edit','string','','Units','normalized','HorizontalAlignment','left',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.7619,'position',[.1 0 .3 .025],'callback',@execute_query,'visible','on');
    end
    function execute_query(hObj,~)
        set(status_name,'string','Searching Database')
        genotype_list = [];
        set(hbrowselist,'value',1)
        search_str = get(hObj,'string');
        if isempty(search_str)
            set(status_name,'string','Searching Complete')
            return
        end
        
        qry_line_name = ['select * from StockFinder where Stock_Name like ''%',search_str,'%''',''];
        qry_line_ID = ['select * from StockFinder where RobotIDBarcode like ''%',search_str,'%''',''];
        qry_line_other = ['select * from StockFinder where GENOTYPE_GSI_NAME_PLATEWELL like ''%',search_str,'%''',''];
        
        qry_effect_name = ['select * from Reporter where Label_Name like ''%',search_str,'%''',''];
        qry_effect_ID = ['select * from Reporter where Barcode like ''%',search_str,'%''',''];
        
        res = stm.executeQuery(qry_line_name);
        counter = 1;
        while res.next
            output = {char(res.getString(2)),char(res.getString(9)),char(res.getString(4))};
            if isempty(output)
                continue
            elseif counter == 1
                genotype_list = output;
            else
                genotype_list = [output;genotype_list];
            end
            counter = counter + 1;
        end
        res = stm.executeQuery(qry_line_ID);
        while res.next
            output = {char(res.getString(2)),char(res.getString(9)),char(res.getString(4))};
            if isempty(output)
                continue
            elseif counter == 1
                genotype_list = output;
            else
                genotype_list = [output;genotype_list];
            end
            counter = counter + 1;
        end
        res = stm.executeQuery(qry_line_other);
        while res.next
            output = {char(res.getString(2)),char(res.getString(9)),char(res.getString(4))};
            if isempty(output)
                continue
            elseif counter == 1
                genotype_list = output;
            else
                genotype_list = [output;genotype_list];
            end
            counter = counter + 1;
        end
        
        res = stm.executeQuery(qry_effect_name);
        while res.next
            output = {char(res.getString(3)), char(res.getString(2)),' '};
            if isempty(output)
                continue
            elseif counter == 1
                genotype_list = output;
            else
                genotype_list = [output;genotype_list];
            end
            counter = counter + 1;
        end
        res = stm.executeQuery(qry_effect_ID);
        while res.next
            output = {char(res.getString(3)), char(res.getString(2)),' '};
            if isempty(output)
                continue
            elseif counter == 1
                genotype_list = output;
            else
                genotype_list = [output;genotype_list];
            end
            counter = counter + 1;
        end
        if isempty(genotype_list)
            var_names = [{'Robot_ID'},{'Stock_Name'},{'Genotype'}];
            varspecs = cell(0,numel(var_names));
            genotype_list = dataset([{varspecs},var_names]);
        else
            genotype_list = cell2dataset(genotype_list,'ReadVarNames',false,'VarNames',[{'Robot_ID'},{'Stock_Name'},{'Genotype'}]);
        end
        if ~isempty(Saved_User_Lines)
            id_match = cellfun(@(x) ~isempty(regexpi(x,search_str)),Saved_User_Lines.Robot_ID);
            stock_match = cellfun(@(x) ~isempty(regexpi(x,search_str)),Saved_User_Lines.Stock_Name);
            geno_match = cellfun(@(x) ~isempty(regexpi(x,search_str)),Saved_User_Lines.Genotype);
            
            logic_match = (id_match | stock_match | geno_match);
            genotype_list = [genotype_list;Saved_User_Lines(logic_match,:)];
        end
        
        genotype_list = unique(genotype_list);
        table = tabulate(genotype_list.Robot_ID);
        table(strcmp(table(:,1),'0'),:) = [];
        [~,sort_index] = sort(table(:,1));
        multi_entries = cell2mat(table(sort_index,2)) > 1;
        uni_entries = unique(genotype_list.Robot_ID);
        uni_entries(strcmp(uni_entries,'0')) = [];
        duplicate = uni_entries(multi_entries);
        
        if ~isempty(duplicate)
            logical_dup = cellfun(@(x) logical(sum(strcmp(x,duplicate))),genotype_list.Robot_ID);
            duplicate = genotype_list(logical_dup,:);
            genotype_list = genotype_list(~logical_dup,:);
            [uni_entry,~,dup_index] = unique(duplicate.Robot_ID);
            var_names = [{'Robot_ID'},{'Stock_Name'},{'Genotype'}];
            varspecs = cell(length(unique(dup_index)),numel(var_names));
            dup_list = dataset([{varspecs},var_names]);
            for iterZ = 1:length(dup_list)
                dup_list.Robot_ID(iterZ) = uni_entry(iterZ);
                dup_list.Stock_Name(iterZ) = {[duplicate.Stock_Name{2*iterZ-1}, duplicate.Stock_Name{2*iterZ}]};
                dup_list.Genotype(iterZ) = {[duplicate.Genotype{2*iterZ-1}, duplicate.Genotype{2*iterZ}]};
            end
            genotype_list = [genotype_list;dup_list];
        end
        
        genotype_list = unique(genotype_list);
        
        var_names = [{'Robot_ID'},{'Stock_Name'},{'Genotype'}];
        varspecs = cell(1,numel(var_names));
        blank_record = dataset([{varspecs},var_names]);
        genotype_list = [genotype_list;blank_record];
        
        blank_stock = cellfun(@(x) isempty(x),genotype_list.Stock_Name);
        genotype_list.Stock_Name(blank_stock) = genotype_list.Genotype(blank_stock);
        
        set(hbrowse_IDS,'string',genotype_list.Robot_ID,'visible','on','value',1,'position',[0 .025 .0400 .95],'fontsize', 0.0175);
        set(hid_name,'visible','on','String','Robot ID');
        set(hbrowse_Stocks,'string',genotype_list.Stock_Name,'visible','on','value',1,'position',[.0400 .025 .110 .95],'fontsize', 0.0175);
        set(hstock_name,'visible','on');
        set(hbrowse_Other,'string',genotype_list.Genotype,'visible','on','value',1,'position',[.150 .025 .150 .95],'fontsize',0.0175);
        set(hother_name,'visible','on');
        
        try
            toggle_scroll_bars
        catch
        end
        set(hbrowselist,'style','listbox','visible','on','string','','min',0,'max',2,'callback',[])
        set(status_name,'string','Searching Complete')
    end
    function selectgenotype(hselect,~)
        name_index = get(hselect,'Value');
        set(hbrowse_IDS,'value',name_index);
        set(hbrowse_Stocks,'value',name_index);
        set(hbrowse_Other,'value',name_index);
        if name_index == 0
            return
        end
        set(hTdropdown_Robot_ID(parent_index),'string',genotype_list.Robot_ID(name_index))
        set(hTdropdown_genotype_name(parent_index),'string',genotype_list.Stock_Name(name_index),'HorizontalAlignment','left')
        set(hTlabels_genotype([parent_index; false;false]),'backgroundcolor',rgb('light green'));
        parent_genotype(parent_index) = genotype_list.Genotype(name_index);
        check_warnings
    end
    function clear_list(~,~)
        genotype_list = [];
        set(hbrowselist,'string',genotype_list)
        set(hTadd_genotype(parent_index),'string','Add','callback',@addnewline)
        set(hTbrowse_genotype(parent_index),'string','Browse','callback',@search_genotype_database)
        set(srch_button,'visible','off')
        set(srch_field,'visible','off')
        set(hTbrowse_genotype(~parent_index),'Enable','On')
        set(hTadd_genotype(~parent_index),'Enable','On')
        check_warnings
        set(hbrowse_IDS,'visible','off');
        set(hid_name,'visible','off');
        set(hbrowse_Stocks,'visible','off');
        set(hstock_name,'visible','off');
        set(hbrowse_Other,'visible','off');
        set(hother_name,'visible','off');
    end
    function reset_genotype(~,~)
        clear_list
        set(hbrowseproto,'visible','off','string','');
        set(hbrowselist,'position',[0 0.0250 0.3000  0.950],'fontsize',.0204)
        set(hTlabels_genotype([parent_index; false;false]),'backgroundcolor',rgb('light red'));
        set(hTdropdown_Robot_ID(parent_index),'string','Robot_ID')
        set(hTdropdown_genotype_name(parent_index),'string',Genotype_labels{parent_index})
        set(hTbrowse_genotype(parent_index),'enable','on')
    end
    function toggle_scroll_bars(~,~)
        [hJlbhA{1},levels_1] = findjobj(hbrowse_IDS);
        [hJlbhA{2},levels_2] = findjobj(hbrowse_Stocks);
        [hJlbhA{3},levels_3] = findjobj(hbrowse_Other);
        
        hJlbhA{1}.AdjustmentValueChangedCallback = @adjustmentCallA;
        if levels_2 > levels_1
            hJlbhA{2} = get(hJlbhA{2},'Container');
        end
        if levels_3 > levels_1
            hJlbhA{3} = get(hJlbhA{3},'Container');
        end
        set(hJlbhA{2},'VerticalScrollBarPolicy',21);
        set(hJlbhA{3},'VerticalScrollBarPolicy',21);
    end
    function adjustmentCallA(~,event)
        vertVal = event.getValue;
        for iterZ = 2:3
            try
                hVertA = hJlbhA{iterZ}.getVerticalScrollBar;
                hVertA.setValue(vertVal)
                hVertA.requestFocus
            catch ME
                getReport(ME)
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% summary protocol functions
%%
function saved_variable = load_variables(file_dir, file_path,save_flag)
switch save_flag
    case 'users'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'User_ID'},{'User_Full_Name'}];
            varspecs = cell(0,numel(var_names));
            Saved_User_names = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_User_names');
        end
        saved_variable = Saved_User_names;
    case 'collection'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Collection_Name'},{'Collection_Description'},{'User_ID'},{'Videos_In_Collection'},{'Archived_Videos'}];
            varspecs = cell(0,numel(var_names));
            Saved_Collection = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Collection');
        end
        saved_variable = Saved_Collection;
    case 'genotype'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'ParentA_name'},{'ParentA_ID'},{'ParentA_genotype'},{'ParentB_name'},{'ParnetB_ID'},{'ParentB_genotype'},{'Males'},{'Females'},{'No_Balancers'},{'Chromosome1'},{'Chromosome2'},{'Chromosome3'}];
            varspecs = cell(0,numel(var_names));
            Saved_Genotypes = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Genotypes');
        end
        saved_variable = Saved_Genotypes;
    case 'protocol'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Exp_protocol'},{'Rearing_protocol'},{'Handling_protocol'},{'Download_rate'},{'Compression_Options'}];
            varspecs = cell(0,numel(var_names));
            Saved_Protocols =  dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Protocols');
        end
        saved_variable = Saved_Protocols;
    case 'protocol_new'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Incubator_Info'},{'Food_Type'},{'Foiled'},{'Stimuli_Type'},{'Stimuli_Vars'},{'Photo_Activation'},{'Photo_Vars'},...
                {'Compression_Opts'},{'Download_Opts'},{'Record_Rate'},{'Trigger_Type'},{'Time_Before'},{'Time_After'},{'Notes'},{'Room_Temp'}];
            varspecs = cell(0,numel(var_names));
            Saved_Protocols_new_version = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Protocols_new_version');
        end
        saved_variable = Saved_Protocols_new_version;
        
    case 'experiment'
        if exist([file_dir filesep file_path],'file') == 2
            load([file_dir filesep file_path]);
        else
            var_names = [{'User_ID'},{'Target_count'},{'Status'},{'Saved_Dates'},{'Partail_Date'}];
            varspecs = cell(0,numel(var_names));
            Saved_Experiments = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Experiments');
        end
        try
            saved_variable = saved_experiments;
        catch
            saved_variable = Saved_Experiments;
        end
    case 'lines'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Robot_ID'},{'Stock_Name'},{'Genotype'}];
            varspecs = cell(0,numel(var_names));
            Saved_User_Lines = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_User_Lines');
        end
        saved_variable = Saved_User_Lines;
    case 'Rearing_protocol'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Incubator_Name'},{'Location'},{'Time_Lights_On'},{'Lights_on_Duration'},{'Time_Lights_Off'},{'Lights_off_Duration'},{'Incubator_Temp'},{'Food_Type'},{'Darkness'}];
            varspecs = cell(0,numel(var_names));
            Rearing_protocols = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Rearing_protocols');
        end
        saved_variable = Rearing_protocols;
    case 'Handling_protocol'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Heat_shock_temp'},{'Heat_Shock_duration'},{'Notes'}];
            varspecs = cell(0,numel(var_names));
            Handling_protocols = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Handling_protocols');
        end
        saved_variable = Handling_protocols;
    case 'Experiment_protocol'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Room_temp'},{'Stimuli_type'},{'Stimuli_l_v'},{'Stimuli_start'},{'Stimuli_stop'},{'Stimuli_elevation'},{'Stimuli_azimuth'},{'Azimuth_options'},{'Photo_time'},{'Photo_intensity'}];
            varspecs = cell(0,numel(var_names));
            Exp_protocol = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Exp_protocol');
        end
        saved_variable = Exp_protocol;
    case 'groups'
        if exist([file_dir filesep file_path],'file')
            load([file_dir filesep file_path]);
        else
            var_names = [{'Experiment_ID'},{'User_ID'},{'Group_Desc'}];
            varspecs = cell(0,numel(var_names));
            Saved_Group_IDs = dataset([{varspecs},var_names]);
            save([file_dir filesep file_path],'Saved_Group_IDs');
        end
        saved_variable = Saved_Group_IDs;
end
fileattrib([file_dir filesep file_path],'+w');
end