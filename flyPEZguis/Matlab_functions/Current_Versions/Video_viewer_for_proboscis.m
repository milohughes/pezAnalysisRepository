function Video_viewer_for_proboscis
%% gets pathing info
repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))

op_sys = system_dependent('getos');
if contains(op_sys,'Microsoft Windows')
    file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
    analysis_path = '\\DM11\cardlab\Data_pez3000_analyzed';
    data_path = '\\DM11\cardlab\Data_pez3000'; 
    save_data_path = '\\DM11\cardlab\Proboscis_annotations';
else
    file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
    analysis_path = '/Volumes/cardlab/Data_pez3000_analyzed';
    data_path = '/Volumes/cardlab/Data_pez3000';    
    save_data_path = '/Volumes/cardlab/Proboscis_annotations';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saved_collections = load([file_dir filesep 'Saved_Collection.mat']);
saved_collections = saved_collections.Saved_Collection;

saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);
saved_groups = saved_groups.Saved_Group_IDs;

exp_dir =  struct2dataset(dir(analysis_path)); 
exp_dir = exp_dir.name;
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));

exp_cut = 115;
exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= exp_cut,exp_dir));

saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:);
[~,sort_idx] = sort(lower(regexprep(saved_groups.Properties.RowNames,' ','')));
saved_groups = saved_groups(sort_idx,:);
saved_users   = unique([saved_collections.User_ID;saved_groups.User_ID]);
saved_groups = saved_groups(cellfun(@(x) contains(x,'Active'),saved_groups.Status),:);


if exist(fullfile(save_data_path,'Proboscis_Annotations.mat'),'file')
    Proboscis_Annotations = load(fullfile(save_data_path,'Proboscis_Annotations'));
    Proboscis_Annotations = Proboscis_Annotations.Proboscis_Annotations;
else
    Proboscis_Annotations = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s%%%%%%%%%%%%%
%% sets background
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];     %input center(x,y) and size(x,y)

screen2use = 2;         % in multi screen setup, this determines which screen to be used
screen2cvr = 0.8;       % portion of the screen to cover
    
monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);    
backColor = [0 0 0.2];
%%%%% Figure and children %%%%%
FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),(scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
hFigA = figure('NumberTitle','off','Name','flyPez Video Explorer - by WRW','menubar','none','units','pix','Color',backColor,'pos',FigPos,'colormap',gray(256));

set(hFigA,'WindowButtonDownFcn',@FigClickCallback);
set(hFigA,'WindowButtonUpFcn',@FigReleaseCallback);
set(hFigA,'WindowScrollWheelFcn',@FigWheelCallback);
% control panel
hPanA = uipanel('Position',guiPosFun([.15 .53],[.25 .9]),'Visible','On');
set(hFigA,'CloseRequestFcn',@myCloseFun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame and graph axes
%hAxesA = axes('Parent',hFigA,'Position',guiPosFun([.456 .53],[.345 .9]),'color','k','tickdir','in','nextplot','replacechildren','xticklabel',[],'yticklabel',[],'visible','off','YDir','reverse');
hAxesA = axes('Parent',hFigA,'Position',[.35,.40,.575,.575],'color','k','tickdir','in','nextplot','replacechildren','xticklabel',[],'yticklabel',[],'visible','on','YDir','reverse');
set(hAxesA,'DataAspectRatio',[1 1 1],'DrawMode','fast','units','pix');
axesApos = get(hAxesA,'position');
set(hAxesA,'units','normalized')
%axesBpos = guiPosFun([.82 .55],[.3 .78]);
axesBpos = [.2835,.122,.6865,.2];
hAxesB = axes('Parent',hFigA,'Position',axesBpos,'visible','on','Color',rgb('black'));

bout_table = uitable(hPanA,'units','normalized','position',[.02 .271 .955 .300]);           %max height 0.55

set(bout_table,'RowName',[],'ColumnName',[{'Bout Number'},{'Start of Bout'},{'End of Bout'}],'ColumnEditable',false(1,3),'columnwidth',[{150},{150},{150}]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% video slidder
hCpos = uicontrol(hFigA,'style','slider','units','normalized',...
    'Position',guiPosFun([.5 .05],[.95 .03]),'backgroundcolor',[.8 .8 .8]);
set(hCpos,'Interruptible','off');
hJScrollBar = findjobj(hCpos);
if ~isempty(hJScrollBar)
    hJScrollBar.MousePressedCallback = @PosClickCallback;
    hJScrollBar.MouseReleasedCallback = @PosReleaseCallback;
    hJScrollBar.MouseWheelMovedCallback = @PosWheelCallback;
end
set(hCpos,'callback',@positionCallback)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frame reset button
frmResetPos = get(hAxesA,'Position');
frmResetPos = frmResetPos.*[1.7 1.0 0.25 0.05];
hCreset = uicontrol('style','pushbutton','units','normalized',...
    'string','Reset Frame','Position',frmResetPos,'fontunits','normalized','fontsize',.4638,...
    'parent',hFigA,'callback',@resetFigCallback,'visible','off','Enable','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define spatial options
xBlox = 21;
yBlox = 31;
texXops = linspace(1/xBlox,1,xBlox)-1/xBlox/2;
texYops = fliplr(linspace(1/yBlox,1,yBlox)-1/yBlox/2);
texW = 1/xBlox;
texH = 1/yBlox;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Labels
guiStrCell = {'Select User','','','','','Gamma'};
frmStrCell = {'Frame'};
guiStrCt = numel(guiStrCell);
frmStrCt = numel(frmStrCell);
guiRefs = (1:guiStrCt);
vidRefs = max(guiRefs);
frmRefs = (1:frmStrCt)+max(vidRefs);
guiYcell = {texYops(2),texYops(3),texYops(4),texYops(5),texYops(6),texYops(9)};
guiYcell{6} = .1;
compoStrCell = cat(1,guiStrCell(:),frmStrCell(:));
compoCt = sum([guiStrCt,frmStrCt]);
hTlabels = zeros(compoCt,1);
hTedit = zeros(guiStrCt,1);

for iterS = 1:compoCt
    hTlabels(iterS) = uicontrol(hPanA,'Style','text','string',[compoStrCell{iterS} ':'],'Units','normalized',...
        'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000);
    hTedit(iterS) = uicontrol(hPanA,'Style','popup','string','...','Units','normalized','HorizontalAlignment','left',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000);
end
for iterPA = 1:guiStrCt
    textPos = guiPosFun([texXops(3),guiYcell{iterPA}],[texW*5 texH*0.8]);
    set(hTlabels(guiRefs(iterPA)),'Position',textPos)
    textPos = guiPosFun([texXops(13),guiYcell{iterPA}],[texW*13.75 texH*0.8]);
    textPos = textPos + [0.01 0 0.0410 0];
    set(hTedit(guiRefs(iterPA)),'Position',textPos)
end
for iterPC = 1:frmStrCt
%    textPos = guiPosFun([texXops(7),texYops(iterPC+14)],[texW*7.75 texH*0.8]);
    textPos = [.125,.615,.3690 .0250];
    set(hTlabels(frmRefs(iterPC)),'Position',textPos,'fontunits','normalized')
%    textPos = guiPosFun([texXops(15),texYops(iterPC+14)],[texW*7.75 texH*0.8]);
    textPos = [.5060,.615,.3690 .0250];
    set(hTedit(frmRefs(iterPC)),'Position',textPos,'Style','text','fontunits','normalized')
end
set(hTedit(6),'Style','text');
set(hTedit(7),'Style','edit','String','1','callback',@changeframe);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hide_completed = uicontrol(hPanA,'Style','pushbutton','string','Hide Completed','Units','normalized','Position',[.05 .9700 .29 .0250],...
    'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0,'callback',@filter_data);
show_not_tracked = uicontrol(hPanA,'Style','pushbutton','string','Show Not Tracked Only','Units','normalized','Position',[.35 .9700 .29 .0250],...
    'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0,'callback',@filter_data);
curator_fail = uicontrol(hPanA,'Style','pushbutton','string','Curator Fail Only','Units','normalized','Position',[.65 .9700 .29 .0250],...
    'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'FontWeight','bold','UserData',0,'callback',@filter_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% prev/next video pushbuttons
prevFilePos = guiPosFun([texXops(6)*1.06,texYops(7)],[texW*8.8 texH*0.8]);
nextFilePos = guiPosFun([texXops(15)*1.03,texYops(7)],[texW*8.8 texH*0.8]);
hCprevVid = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Prev Video',...
    'Position',prevFilePos - [0 .0325 0 0],'fontunits','normalized','fontsize', 0.4598,'callback',@setprevvid,'Enable','off');
hCnextVid = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Next Video','Position',nextFilePos - [0 .0325 0 0],'fontunits','normalized','fontsize', 0.4598,'callback',@setnextvid,'Enable','off');
hCprevFile = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Prev Dataset','Position',prevFilePos,'fontunits','normalized','fontsize', 0.4598,'callback',@pfileCallback,'Enable','off');
hCnextFile = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Next Dataset','Position',nextFilePos,'fontunits','normalized','fontsize', 0.4598,'callback',@nfileCallback,'Enable','off');
iconshade = 0.1;
makeFolderIcon(hCnextFile,0.8,'next',iconshade)
makeFolderIcon(hCnextVid,0.8,'next',iconshade)
makeFolderIcon(hCprevFile,0.8,'prev',iconshade)
makeFolderIcon(hCprevVid,0.8,'prev',iconshade)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gamma slider
gamPos = guiPosFun([.49 .0725],[.86 .02]);
hCgamma = uicontrol(hPanA,'style','slider','units','normalized','Position',gamPos,'backgroundcolor',[.8 .8 .8],...
    'Enable','off','fontunits','normalized','fontsize',0.4638,'Interruptible','off','Min',0.001,'Max',2,'Value',1,'callback',@gammaCallback);
hJGammaBar = findjobj(hCgamma);
if ~isempty(hJGammaBar)
    hJGammaBar.MousePressedCallback = @GammaClickCallback;
    hJGammaBar.MouseReleasedCallback = @GammaReleaseCallback;
end
gammaVal = 1;
set(hTedit(guiRefs(6)),'string',['   ' num2str(gammaVal)])
gamResetPos = guiPosFun([texXops(17),guiYcell{6}],[texW*5.5 texH*0.66]);
hCgamReset = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Gamma Reset',...
    'Position',gamResetPos,'fontunits','normalized','fontsize',0.4638,'callback',@gammaResetCallback,'Enable','off');
motionBox = uicontrol(hPanA,'Style','checkbox', 'string','   Show Movement','Units','normalized','HorizontalAlignment','left','value',0,'callback',@videoDisp,...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.4598,'Position',guiPosFun([texXops(7),texYops(24)],[texW*7.75 texH*0.8]));
enhanceBox = uicontrol(hPanA,'Style','checkbox', 'string','   Enhance Image','Units','normalized','HorizontalAlignment','left','value',1,'callback',@videoDisp,...
    'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.4598,'Position',guiPosFun([texXops(15),texYops(24)],[texW*7.75 texH*0.8]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parsed exp info
uicontrol(hPanA,'style','text','units','normalized','string','Experiments :: ',...
    'Position',[0.05 .6450 .1400 .0220],'fontunits','normalized','fontsize',.4444);
exp_count = uicontrol(hPanA,'style','text','units','normalized','string','0','ForegroundColor',rgb('red'),...
    'Position',[0.1900 .6450 .050 .0220],'fontunits','normalized','fontsize',.4444);
uicontrol(hPanA,'style','text','units','normalized','string','Videos :: ',...
    'Position',[0.250 .6450 .140 .0220],'fontunits','normalized','fontsize',.4444);
vids_count = uicontrol(hPanA,'style','text','units','normalized','string','0 ',...
    'Position',[0.385 .6450 .095 .0220],'fontunits','normalized','fontsize',.4444);

uicontrol(hPanA,'style','text','units','normalized','string','One Fly ::',...
    'Position',[0.475 .6450 .140 .0220],'fontunits','normalized','fontsize',.4444);
one_count = uicontrol(hPanA,'style','text','units','normalized','string','0',...
    'Position',[0.615 .6450 .095 .0220],'fontunits','normalized','fontsize',.4444);
uicontrol(hPanA,'style','text','units','normalized','string','Need To Work ::',...
    'Position',[0.725 .6450 .175 .0220],'fontunits','normalized','fontsize',.4444);
work_count = uicontrol(hPanA,'style','text','units','normalized','string','0 ',...
    'Position',[0.900 .6450 .095 .0220],'fontunits','normalized','fontsize',.4444);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pos, vel acc options
edge_dist =.04;                         butwidth = .2619;
mid_pos = (((1-(butwidth+edge_dist)) - (edge_dist + butwidth)) - butwidth)/2 + (edge_dist + butwidth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fly count and gender
hSingle = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Single Fly Video',...
    'Position',[edge_dist .710 butwidth .0200],'fontunits','normalized','fontsize',0.5333,'callback',@setsinglevid,'Enable','off');
hBlank = uicontrol(hPanA,'style','pushbutton','units','normalized','string','No Fly in Video',...
    'Position',[mid_pos .710 butwidth .0200],'fontunits','normalized','fontsize',0.5333,'callback',@setblankvid,'Enable','off');
hMulti = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Multiple Flies',...
    'Position',[(1-(butwidth+edge_dist)) .710 butwidth .0200],'fontunits','normalized','fontsize',0.5333,'callback',@setmultivid,'Enable','off');
hGender(1) = uicontrol(hPanA,'Style','pushbutton', 'string','   Male','Units','normalized','HorizontalAlignment','left',...
    'BackgroundColor',[0.9412 0.9412 0.9412],'fontunits','normalized','fontsize', 0.4598,'Position',[edge_dist .679 butwidth .0200],'callback',@setgender,'Enable','off');
hGender(2) = uicontrol(hPanA,'Style','pushbutton', 'string','   Female','Units','normalized','HorizontalAlignment','left',...
    'BackgroundColor',[0.9412 0.9412 0.9412],'fontunits','normalized','fontsize', 0.4598,'Position',[mid_pos .679 butwidth .0200],'callback',@setgender,'Enable','off');
hGender(3) = uicontrol(hPanA,'Style','pushbutton', 'string','   Not Sure','Units','normalized','HorizontalAlignment','left',...
    'BackgroundColor',[0.9412 0.9412 0.9412],'fontunits','normalized','fontsize', 0.4598,'Position',[(1-(butwidth+edge_dist)) .679 butwidth .0200],'callback',@setgender,'Enable','off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% graph zoom fillider
hPanBpos = axesBpos;
hPanBpos(2) = 0.085;
hPanBpos(4) = 0.02;
hPanB = uipanel(hFigA,'Position',hPanBpos,'Visible','On');
zoomPos = guiPosFun([.5 .5],[.6 .95]);
hCzoom = uicontrol(hPanB,'style','slider','units','normalized',...
    'Position',zoomPos,'backgroundcolor',[.8 .8 .8],'Enable','off');
set(hCzoom,'Min',0,'Max',.99,'Value',0)
set(hCzoom,'Interruptible','off');
hJZoomBar = findjobj(hCzoom);
if ~isempty(hJZoomBar)
    hJZoomBar.MousePressedCallback = @ZoomClickCallback;
    hJZoomBar.MouseReleasedCallback = @ZoomReleaseCallback;
end
zoomVal = 1;
uicontrol(hPanB,'Style','text','string','Zoom Out','Units','normalized','Position',guiPosFun([.1 .5],[.15 .95]),...
    'HorizontalAlignment','left','fontunits','normalized','fontsize', 0.7018);
uicontrol(hPanB,'Style','text','string','Zoom In','Units','normalized','Position',guiPosFun([.9 .5],[.15  .95]),...
    'HorizontalAlignment','right','fontunits','normalized','fontsize', 0.7018);
set(hCzoom,'callback',@zoomCallback)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% playback controls %%%%%
hCspeedOps = [3,30,120].*4;
hCspeedOps = [fliplr(hCspeedOps).*(-1) 0 hCspeedOps];
hBplayback = uibuttongroup('parent',hPanA,'position',guiPosFun([.5 .030],[.85 .05]),'Visible','off');
btnHmat = zeros(7,1);
btnH = 1;
btnW = 1/7;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
btnIcons = {'frev','rev','slowrev','stop','slowfwd','fwd','ffwd'};
for iterBtn = 1:7
    btnHmat(iterBtn) = uicontrol(hBplayback,'style','togglebutton','units','normalized',...
        'string',[],'Position',guiPosFun([btnXinit+(btnXstep*(iterBtn-1)) btnY],[btnW btnH]*0.9),...
        'fontunits','normalized','fontsize',0.4255,'HandleVisibility','off');
    makeIcon(btnHmat(iterBtn),0.7,btnIcons{iterBtn},iconshade)
end
set(hBplayback,'SelectionChangeFcn',@rateCallback)
set(hBplayback,'SelectedObject',btnHmat(4))

frmTct = 10;
hFramelabel = zeros(1,frmTct);
frmTcenters = linspace(.05,.95,frmTct);
for iterFA = 1:frmTct
    hFramelabel(iterFA) = uicontrol(hFigA,'style','text','units','normalized','Position',guiPosFun([frmTcenters(iterFA) .016],[.03 .03]),...
        'string',' ','fontunits','normalized','fontsize',0.3419,'BackgroundColor',backColor,'ForegroundColor','w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% variables
collect_list = [];          exp_list = [];              vid_list = [];              exp_id = [];                vidName = [];                   vidOps = [];
vidHeight = [];             vidWidth = [];              vidFrames_partial = [];     frameInit = [];             hIm = [];                       frmRate = 30;
frmNum = [];                frmDelta = 1;               diodeData = [];             markerY = [0;4];            markerX = [];                   hPlotC = [];
frmOps = [];                zoomMag = 1;                clickPos = [];              centerIm = [];              hInputvalues = zeros(4,1);      video_index = 1;
vidOff = 0;                 vidObjCell = cell(2,1);     collect_select = [];        frameReferenceMesh = [];    slip_opts = [];                 hNotes = [];
frameRefcutrate = [];       frameReffullrate = [];      group_list = [];            hFramebutton = zeros(2,1);  photoData = [];                 frame_count = 0;
graph_annotations = [];
auto_annotations = [];      stimuli_info = [];          assess_table = [];          man_annotations = [];       annotate_error = [];            track_data = [];
frm_remap = [];             save_table = [];      
filt_annotations = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% timmers used
tVid  = timer('TimerFcn',@timerVidFun, 'ExecutionMode','fixedRate','Period',round((1/frmRate)*100)/100);
tPos  = timer('TimerFcn',@timerPosFun, 'ExecutionMode','fixedRate','Period',0.3);
tGam  = timer('TimerFcn',@timerGamFun, 'ExecutionMode','fixedRate','Period',0.1);
tFig  = timer('TimerFcn',@timerFigFun, 'ExecutionMode','fixedRate','Period',0.1);
tZoom = timer('TimerFcn',@timerZoomFun,'ExecutionMode','fixedRate','Period',0.1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% starting functions
load_options
setframeinput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setframeinput(~,~)
        hNotes = uicontrol(hPanA,'Style','edit', 'string',' ','Units','normalized','HorizontalAlignment','left',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.0900,'Position',[.1250 .1175 .7500 .1075],'min',0,'max',2,'callback',@setnotes);
        Input_opts = {'Proboscis is Extended';'Proboscis is Retracted'};
        for iterC = 1:length(Input_opts)
            
            x_pos = .01 + (iterC-1)*.50;         y_pos = .575;
%            textPos = guiPosFun([texXops(7),texYops(iterC+18)],[texW*7.75 texH*0.8]);
            textPos = [x_pos, y_pos, .475 .026];
            hFramebutton(iterC) = uicontrol(hPanA,'Style','pushbutton','string',Input_opts{iterC},'Units','normalized',...
                'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.400,...
                'Position',textPos,'callback',@getframeinfo);
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selct video options
    function load_options(~,~)
        reset_video
        turn_flags_off
        set(hTedit,'Value',1);
        set(hCnextFile,'string','Next Experiment');
        set(hCprevFile,'string','Prev Experiment');
        set(hTedit(1),'String', ['...';saved_users],'Callback', @select_user);
    end
    function select_user(hObj,~)
        reset_video
        turn_flags_off
        
        set(hTedit(2),'Value',1,'String','....');
        set(hTedit(3),'Value',1,'String','....');
        set(hTedit(4),'Value',1,'String','....');
        set(hTedit(5),'Value',1,'String','....');
        user_val = get(hObj,'Value');
        user_select = saved_users(user_val-1);
        
        if strcmp(user_select,'All Users')
            collect_list = [saved_collections.Collection_Name;'All Collections'];
            group_list = [unique(saved_groups.Properties.RowNames);'All Groups'];
            num_list =[get(saved_collections,'ObsNames');{'0000'}];
            num_list = cellfun(@(x,y) [x ' :: ' y],num_list,collect_list,'uniformoutput',false);
        else
            logic_match = strcmp(saved_collections.User_ID,user_select);
            num_list = get(saved_collections(logic_match,:),'ObsNames');
            collect_list = saved_collections(logic_match,:).Collection_Name;
            num_list = cellfun(@(x,y) [x ' :: ' y],num_list,collect_list,'uniformoutput',false);
            group_list = saved_groups(strcmp(saved_groups.User_ID,user_select),:);
            group_list = unique(group_list.Properties.RowNames,'stable');
        end
       
        set(hTedit(2),'String',[{'...'};num_list],'Callback', @select_list);
        set(hTlabels(2),'String','Select Collection:');
        
        set(hTedit(3),'String',[{'...'};group_list],'Callback', @select_list);
        set(hTlabels(3),'String','Select  Group:');
    end
    function select_list(hObj,~)
        reset_video
        collect_val = get(hObj,'Value') - 1;
        
        set(hTlabels(4),'String','Select Experiment_ID:');
        if hObj == hTedit(2)
            set(hTedit(3),'value',1);
            collect_select = collect_list(collect_val);
            if strcmp(collect_select,'All Collections')
                load_files = exp_dir;
            else
                Collect_index = get(saved_collections(strcmp(saved_collections.Collection_Name,collect_select),:),'ObsName');
                load_files = exp_dir(cellfun(@(x) strcmp(x(1:4),Collect_index{1}),exp_dir));
            end
        elseif hObj == hTedit(3)
            set(hTedit(2),'value',1);
            collect_select = group_list(collect_val);
            if strcmp(collect_select,'All Groups')
                load_files = exp_dir;
            else
                load_files = (saved_groups(strcmp(saved_groups.Properties.RowNames,collect_select),:).Experiment_IDs);
                if ~iscell(load_files{1})
                    load_files = cellfun(@(x) strtrim(x),load_files,'uniformoutput',false);
                else
                    load_files = unique(load_files{1});
                    load_files = cellfun(@(x) strtrim(x),load_files,'uniformoutput',false);
                end
            end
        end
        load_files(cellfun(@(x) contains(x,'0108') & contains(x,'0739') ,load_files)) = [];
        exp_list = regexprep(load_files,'.mat','');
%        [~,si] = sort(cellfun(@(x) x(13:16),exp_list,'uniformoutput',false));
        [~,si] = sort(cellfun(@(x) x(1:12),exp_list,'uniformoutput',false));
        load_files = exp_list(si);
        
        set(hTedit(4),'String',['...';load_files],'Callback', @populate_vid_list);
        set(hCnextFile,'enable','on');
        set(hCprevFile,'enable','on');
    end
    function populate_vid_list(hObj,~)
        reset_video
        set(hTedit(5),'value',1);
        vid_val = get(hObj,'Value');
        exp_list = get(hObj,'String');
        exp_id = exp_list{vid_val};
        annotate_error = false;
        
        try
            man_annotations = load([analysis_path filesep exp_id filesep exp_id '_manualAnnotations']);
        catch
            annotate_error = true;
            nfileCallback
        end
        autoPath = [analysis_path filesep exp_id filesep exp_id '_automatedAnnotations.mat'];
        graphPath = [analysis_path filesep exp_id filesep exp_id '_dataForVisualization.mat'];
        if exist(graphPath,'file') ==2
            graph_annotations = load([analysis_path filesep exp_id filesep exp_id '_dataForVisualization']);
            graph_annotations = graph_annotations.graphTable;
        else
            graph_annotations = [];
        end
        if exist(autoPath,'file') ==2
            auto_annotations = load([analysis_path filesep exp_id filesep exp_id '_automatedAnnotations']);
            auto_annotations = auto_annotations.automatedAnnotations;
        else
            auto_annotations = [];
        end
        
        stimuli_info = load([analysis_path filesep exp_id filesep exp_id '_videoStatisticsMerged']);
        assess_table = load([analysis_path filesep exp_id filesep exp_id '_rawDataAssessment']);
        
        man_annotations = man_annotations.manualAnnotations;
        stimuli_info = stimuli_info.videoStatisticsMerged;
        assess_table = assess_table.assessTable;
                
        vid_list = man_annotations.Properties.RowNames;
        set(exp_count,'string','1');
        
        assess_table = assess_table(vid_list,:);
        stimuli_info = stimuli_info(vid_list,:);
        
                
        set(hTlabels(5),'String','Select Video:');

        filter_vid_list
    end
    function filter_vid_list(~,~)
        temp_data = Experiment_ID(exp_id);
        temp_data.load_data;
        vid_list = temp_data.Complete_usuable_data.Properties.RowNames;
        filt_annotations = temp_data.Complete_usuable_data(vid_list,:);
        
        vid_list(cellfun(@(x) isempty(x), filt_annotations.Gender),:) = [];        
        filt_annotations(cellfun(@(x) isempty(x), filt_annotations.Gender),:) = [];
        
        set(vids_count,'string',num2str(height(filt_annotations)),'ForegroundColor',rgb('red'))
        done = filt_annotations(cellfun(@(x) ~isempty(x),filt_annotations.frame_of_take_off),:);
        not_done = height(filt_annotations(cellfun(@(x) isempty(x),filt_annotations.frame_of_take_off),:));
%        done = assess_table(done.Properties.RowNames,:);
        
        one_done =sum(cellfun(@(x) strcmp(x,'Single'),done.Fly_Count));
        
        set(one_count ,'string',num2str(one_done),'ForegroundColor',rgb('red'))
        set(work_count,'string',num2str(not_done),'ForegroundColor',rgb('red'))        
        
        if isempty(vid_list)
            set(hTedit(5),'value',1,'String','...','enable','off')
            nfileCallback
        end
        if get(curator_fail,'UserData') == 1

            empty_logic = cellfun(@(x) isempty(x),filt_annotations.frame_of_leg_push);
            fail = cellfun(@(x) strcmp(x,'Fail'),filt_annotations.Raw_Data_Decision);
            new_table = filt_annotations((fail & empty_logic),:);
            vid_list = new_table.Properties.RowNames;
        end
        if get(show_not_tracked,'UserData') == 1
            empty_logic = cellfun(@(x) isempty(x),filt_annotations.frame_of_leg_push);
            not_track_1 = cellfun(@(x) isempty(x), filt_annotations.finalStatus);
            not_track_2 = cellfun(@(x) isempty(x), filt_annotations.Analysis_Status);
            not_track_3 = arrayfun(@(x) x == 0, filt_annotations.trkEnd);
            
            not_tracked = not_track_1 | not_track_2 | not_track_3;
            
            new_table = filt_annotations((not_tracked & empty_logic),:);
            vid_list = new_table.Properties.RowNames;            
        end

%         if isempty(vid_list)
%             return
%         end
        if get(hide_completed,'UserData') == 1
            table_data = table2cell(filt_annotations(:,1:4));
            empty_logic = cellfun(@(x) isempty(x),table_data);
            nan_logic = cellfun(@(x) isnan(x) | isempty(x),table_data,'uniformoutput',false);
            nan_logic(cellfun(@(x) isempty(x),nan_logic)) = {false};
            nan_logic = cell2mat(nan_logic);
            
            empty_res = sum(empty_logic,2) > 0; %has an empty entry
            nan_res = sum(nan_logic,2) > 0 & sum(nan_logic,2) < 4;     %has a nan entry with data
            
            done_gender = cellfun(@(x) contains(x,'Unknown'), filt_annotations.Gender);
            single_logic = cellfun(@(x) contains(x,'Single'), filt_annotations.Fly_Count);

%            done_gender(old_logic,:) = [];  single_logic(old_logic,:) = [];
            
            missing_logic = ~(single_logic & done_gender);      %single with unknown gender            
            done_logic = ~(nan_res | empty_res);    %has all nans or data
            
            vid_list(done_logic & missing_logic) = [];
        end
        
        org_list_index = cellfun(@(y) sprintf('%04s',num2str(y)),num2cell(1:1:height(filt_annotations))','UniformOutput',false);
        org_list_index = org_list_index(ismember(filt_annotations.Properties.RowNames,vid_list));
        
        index = cellfun(@(x) strfind(x,'expt'),vid_list);

        if ~isempty(vid_list)
            short_list = cellfun(@(x,y,z) sprintf('%s%04s_orgvid%04s',x(index:(index+23)),num2str(y),num2str(z)),vid_list,num2cell(1:1:length(index))',org_list_index,'UniformOutput',false);        
            set(hTedit(5),'value',1,'String',short_list,'Callback',@select_video,'enable','on');
%            set(hTedit(5),'value',1,'String',vid_list,'Callback',@select_video,'enable','on');
            select_video(hTedit(5))            
        else
            set(hTedit(5),'value',1,'String','...','enable','off')
            nfileCallback
        end
    end
    function select_video(hObj,~)
        video_index = get(hObj,'Value');
        set(hCnextVid,'Enable','on');
        set(hCprevVid,'Enable','on');
        vidOps = vid_list;
        vidOps = circshift(vidOps,-vidOff+1);
        vidOff = 1;
        vidName = vid_list(video_index,:);
        set_user_data
        clear_graph
        videoLoad
    end
    function filter_data(hObj,~)
        curr_val = get(hObj,'UserData');
        if isempty(man_annotations)
            return
        end
        vid_list = man_annotations.Properties.RowNames;
        if curr_val == 1
            set(hide_completed,  'BackgroundColor',[.8 .8 .8],'UserData',0);
            set(show_not_tracked,'BackgroundColor',[.8 .8 .8],'UserData',0);
            set(curator_fail , 'BackgroundColor',[.8 .8 .8],'UserData',0);
        else
            if hObj == hide_completed
                set(hide_completed,'BackgroundColor',rgb('light cyan'),'UserData',1);
            elseif hObj == show_not_tracked
                set(show_not_tracked,'BackgroundColor',rgb('light cyan'),'UserData',1);
            elseif hObj == curator_fail
                set(curator_fail , 'BackgroundColor',rgb('light cyan'),'UserData',1);
            end
        end
%         if get(show_jumpers,'UserData') == 1
%             set(curator_fail , 'BackgroundColor',rgb('light cyan'),'UserData',1);
%         end
        filter_vid_list
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets user data
    function set_user_data(~,~)
        curr_entry = assess_table(vidName,:);
        set(hSingle,'backgroundcolor',rgb('light grey'))
        set(hBlank,'backgroundcolor',rgb('light grey'))
        set(hMulti,'backgroundcolor',rgb('light grey'))        
        
        if ~isempty(curr_entry.Fly_Count{1})
            switch curr_entry.Fly_Count{1}
                case 'Blank'
                    set(hBlank,'backgroundcolor',rgb('light orange'))
                case 'Empty'
                    set(hBlank,'backgroundcolor',rgb('light orange'))                    
                case 'Single'
                    set(hSingle,'backgroundcolor',rgb('light green'))
                case 'Multi'
                    set(hMulti,'backgroundcolor',rgb('light red'))
            end
        end
        
        set(hGender,'backgroundcolor',[.8 .8 .8])
        set(slip_opts,'value',0);
        curr_entry = assess_table(vidName,:);
        if isempty(curr_entry.Gender{1})
            return
        end
        switch curr_entry.Gender{1}
            case 'Male'
                set(hGender(1),'backgroundcolor',rgb('very light blue'));
            case 'Female'
                set(hGender(2),'backgroundcolor',rgb('very light blue'));
            case 'Not Sure'
                set(hGender(3),'backgroundcolor',rgb('very light blue'));
        end
        curr_entry = man_annotations(vidName,:);
        set(hNotes,'string',curr_entry.notes{1});
        set_bout_data
    end
    function set_bout_data(~,~)
        %loads saved bout data for matching videos
        if ~isempty(Proboscis_Annotations)
            if ismember(vidName,Proboscis_Annotations.Properties.RowNames)      %current video in save file
                curr_vid = Proboscis_Annotations(vidName,:);
                set(bout_table,'Data',curr_vid.Proboscis{1});
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load and parsing functions
    function videoLoad
        save_table = struct('Fly_Count','Single','Gender','Unknown','Notes',[],'Proboscis',[]);
        delete(get(hAxesA,'Children'));
        set(hAxesA,'NextPlot','Add');
        vid_name = vidName{1};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);
        
        try
             temp_vidStats = stimuli_info(vidName,:);
        catch
             stimuli_info = stimuli_info.videoStatisticsMerged;
             temp_vidStats = stimuli_info(vidName,:);
        end
        try
            if exist(fullfile([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v14' filesep vidName{1} '_flyAnalyzer3000_v14_data.mat']),'file') == 2
                track_data = load([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v14' filesep vidName{1} '_flyAnalyzer3000_v14_data']);
            elseif exist(fullfile([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v13' filesep vidName{1} '_flyAnalyzer3000_v13_data.mat']),'file') == 2
                track_data = load([analysis_path filesep exp_id filesep exp_id '_flyAnalyzer3000_v13' filesep vidName{1} '_flyAnalyzer3000_v13_data']);
            end            
            
            track_data = track_data.saveobj;
            vid_stats = load([analysis_path filesep exp_id filesep exp_id '_videoStatisticsMerged']);
            vid_stats = dataset2table(vid_stats.videoStatisticsMerged(track_data.Properties.RowNames,:));
            track_data = [track_data,vid_stats];
        catch
            track_data = [];
        end
        
        if strcmp(tVid.Running,'on'),stop(tVid),end
        
        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vidName{1},'.mp4']);
        fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[vidName{1},'_supplement.mp4']);
        turn_flags_on
        
        if ~exist(fullPath_parital,'file')
            setnextvid
        end
        
        vidObj_partail = VideoReader(fullPath_parital);
        try
            vidObj_supplement = VideoReader(fullPath_supplement);
            vidObjCell{1} = vidObj_partail;
            vidObjCell{2} = vidObj_supplement;
        catch
            vidObjCell{1} = vidObj_partail;
            vidObjCell{2} =  vidObj_partail;
            
        end
        vidWidth = vidObj_partail.Width;
        vidHeight = vidObj_partail.Height;
        vidFrames_partial = round(vidObj_partail.Duration*vidObj_partail.FrameRate);
        
        frameRefcutrate = double(temp_vidStats.cutrate10th_frame_reference{1});
        frameReffullrate = double(temp_vidStats.supplement_frame_reference{1});
        Y = (1:numel(frameRefcutrate));
%        x = frameRefcutrate;
        xi = (1:(vidFrames_partial*10));
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*10));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        
        if length(xi) ~= length(yi)
            setnextvid
        end
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
        
        frmOps = 1:1:(vidFrames_partial*10);
        frmOps = frmOps';
        
        frameInit = 1;
        
        set(hCpos,'Min',frameInit,'Max',length(frmOps),'Value',frameInit)
        set(hCpos,'sliderstep',[1/length(frmOps) .05])
        set(hCzoom,'Min',0,'Max',1-10/length(frmOps))
        frmTct = 10;
        frmTops = round(linspace(frameInit,length(frmOps),frmTct));
        frmTcenters = linspace(.05,.95,frmTct);
        for iterF = 1:frmTct
            set(hFramelabel(iterF),'string',int2str(frmTops(iterF)));
        end
        
        matlab.video.read.UseHardwareAcceleration('off');
        frmData = read(vidObj_partail,1); %#ok<VIDREAD>
        
        tI = log(double(frmData)+15);
        frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
        [~,frm_graymap] = gray2ind(frmAdj,256);
        tol = [0 0.9999];
        gammaAdj = 0.75;
        lowhigh_in = stretchlim(frmAdj,tol);
        lowhigh_in(1) = 0.01;
        frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
        frm_remap = uint8(frm_remap(:,1).*255);
        if get(enhanceBox,'value') == 1
            frmData = intlut(frmAdj,frm_remap);
        end
        frmData = frmData(1:vidWidth,:,:);       %top view only
        hIm = image('Parent',hAxesA,'CData',frmData);
        
%         hWidth = vidWidth*zoomMag/2;
%         hHeight = vidHeight*zoomMag/2;
%         if isempty(centerIm)
%             centerIm = [vidWidth/2 vidHeight/2];
%         end
%         set(hAxesA,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth],...
%             'ylim',[centerIm(2)-hHeight centerIm(2)+hHeight])
        set(hCreset,'Visible','off')
%         frmNum = get(hInputvalues(4),'string');
%         frmNum = str2double(frmNum(4:end));
%         if isnan(frmNum)
            frmNum = 1;
%         end
        
        temp_vidStats = stimuli_info(vidName,:);
        frame_count = temp_vidStats.frame_count;
        if ~isempty(temp_vidStats.photoactivation_info{1,1})
            try
                photoData = temp_vidStats.photoactivation_info{1,1}.nidaq_data;
            catch
                photoData = temp_vidStats.photoactivation_info{1,1}.diode_data;
            end
        else
            photoData = zeros(1,frame_count);
        end
        if ~isempty(temp_vidStats.visual_stimulus_info{1,1})
            try
                diodeData = temp_vidStats.visual_stimulus_info{1,1}.nidaq_data;
            catch
                diodeData = temp_vidStats.visual_stimulus_info{1,1}.diode_data;
            end
        else
            diodeData = zeros(1,frame_count);
        end
        diodeData = double(diodeData);
        photoData = double(photoData);
        
        if ~isempty(diodeData)
            
            clear_graph
            diodeData = diodeData(:)';
            diodeData = mean([circshift(diodeData,[0 -1]);diodeData]);
            phBrks = round(linspace(1,frame_count,30));
            ranges = zeros(numel(phBrks)-1,2);
            means = zeros(numel(phBrks)-1,2);
            
            for iterPh = 1:numel(phBrks)-1
                ranges(iterPh,1) = iqr(diodeData(phBrks(iterPh):phBrks(iterPh+1)));
                means(iterPh,1) = mean(diodeData(phBrks(iterPh):phBrks(iterPh+1)));
                
                ranges(iterPh,2) = iqr(photoData(phBrks(iterPh):phBrks(iterPh+1)));
                means(iterPh,2) = mean(photoData(phBrks(iterPh):phBrks(iterPh+1)));
            end
                        
            avgBase_photo = means(min(ranges(:,2)) == ranges(:,2));
            avgPeak_photo = means(max(ranges(:,2)) == ranges(:,2));
            
            photoSignalTest_p = abs((avgPeak_photo(1)-avgBase_photo(1))/min(ranges(:,2)));
            
            diodeData = (diodeData ./ 255) + 1;       %makes 1 to 2 scale
            diodeData = 2./(diodeData);       %makes 1 to 2 scale
            
            if photoSignalTest_p >= 10
                photoData = abs(photoData-avgBase_photo(1))./max(ranges(:,2)) + 3.0;
            else
                photoData = abs(photoData-avgBase_photo(1)) + 3.0;
            end
            
            if max(photoData) > 5
                photoData = photoData ./ max(photoData) + 3.0;
            end
            
            plot(diodeData,'parent',hAxesB,'Color',rgb('light red'),'tag','diode_graph');
            set(hAxesB,'YLim',[0 5.25],'XLim',[1 length(frmOps)],'Color',[0 0 0],'XColor',[1 1 1],'YColor',[1 1 1],'TickDir','in','NextPlot','add')
            plot(photoData,'parent',hAxesB,'Color',rgb('light blue'),'tag','diode_graph');
            xlimit = get(hAxesB,'Xlim');
            line(xlimit,[2 2],'color',rgb('green'),'linewidth',1,'parent',hAxesB);
            
            %         stim_duration = stim_lv/(tan((start_angle * pi/180)/2)) - stim_lv/(tan((end_angle * pi/180)/2));
            %         time_duration = (end_frame - start_frame)/ 6;
            title(hAxesB,sprintf(' Photo Activation :: Blue Trace              Loominging Stimuli :: Red Trace \n  Supplemental Frame Information :: Orange Trace'),...
                'Color',[1 1 1], 'fontweight','demi','fontunits','normalized','FontSize',0.100,'Interpreter','none')
            texUpdate
            
            frame_data = frameReferenceMesh(:,3);
            frame_data = (((frame_data ./ max(frame_data)) - 0.5));
            plot(frame_data,'color',rgb('orange'),'parent',hAxesB);
            
            xlabel(hAxesB,'frame','fontunits','normalized','fontsize', 0.0160,'fontweight','demi')
            ylabel(hAxesB,'Value','fontunits','normalized','fontsize', 0.0160,'fontweight','demi')
            
            markerX = [frmNum;frmNum];
            hPlotC = plot(markerX,markerY,'Color',[1 1 1],'parent',hAxesB);
            
            set(hAxesB,'NextPlot','add')
        else
            chAx = get(hAxesB,'Children');
            delete(chAx)
            set(hTedit(frmRefs(2)),'string','...')
            set(hTedit(frmRefs(3)),'string','...')
        end
        set(hTedit(7),'string',num2str(frmNum))
        draw_lines
        changeframe(hTedit(7))
        resetFigCallback
    end
    function draw_lines(~,~)
        curr_data = filt_annotations(vidName,:);
        if ~isempty(curr_data.visStimFrameStart{1})
            start_stim_frame = cell2mat(curr_data.visStimFrameStart);
            line([start_stim_frame start_stim_frame],[1 1.25],'parent',hAxesB,'color',rgb('light green'),'lineWidth',1.5)
            last_stim_frame = start_stim_frame + cell2mat(curr_data.visStimFrameCount) + 1;
            line([last_stim_frame last_stim_frame],[1 1.25],'parent',hAxesB,'color',rgb('light green'),'lineWidth',1.5)
        end 
        try
            jump_test =  curr_data.autoJumpTest;
        catch
            jump_test =  cell2mat(curr_data.jumpTest);
        end
       
        if jump_test == 1
            try
                ryans_frame = curr_data.autoFot;
                plot(hAxesB,ryans_frame,2.75,'g*','MarkerSize',10)
            catch
                ryans_frame = cell2mat(curr_data.autoFrameOfTakeoff);
                plot(hAxesB,ryans_frame,2.75,'g*','MarkerSize',10)                
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% show the video
    function videoDisp(~,~)
        if isempty(frameReferenceMesh)
            return
        end
        texUpdate
        if isnan(frameReferenceMesh(frmNum,2))
            frmNum = find(~isnan(frameReferenceMesh(:,2)),1,'last');
        end
        try
            frmData = read(vidObjCell{frameReferenceMesh(frmNum,3)},frameReferenceMesh(frmNum,2));
        catch
            fprintf('unable to read frame %4.0f',frmNum);
        end
        if get(enhanceBox,'value') == 1
            backoff = 15;
            tI = log(double(frmData(:,:,1))+backoff);
            frmAdj = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
            frmAdj = intlut(frmAdj,frm_remap);
        else
            frmAdj = frmData(:,:,1);
        end
        if get(motionBox,'value') == 1
            frmData(:,:,1) = frmAdj;
            frmData(:,:,3) = frmAdj;
            frmNumPre = frmNum-50;
            if frmNumPre < 1, frmNumPre = 1; end
            if frmNumPre > max(frmOps), frmNumPre = max(frmOps); end
            frmDataPre = read(vidObjCell{frameReferenceMesh(frmNumPre,3)},frameReferenceMesh(frmNumPre,2));
            if get(enhanceBox,'value') == 1
                tI = log(double(frmDataPre(:,:,1))+backoff);
                frmAdj = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
                frmAdj = intlut(frmAdj,frm_remap);
            else
                frmAdj = frmDataPre(:,:,1);
            end
            frmData(:,:,2) = frmAdj;
        else
            frmData = frmAdj;
        end
            frmData = frmData(1:vidWidth,:,:);
        try
            set(hIm,'CData',frmData);
        catch
            hIm = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
            set(hIm,'CData',frmData);
            warning('error')
        end
        drawnow
    end
    function texUpdate
        set(hTedit(frmRefs(1)),'string',['   ' int2str(frmNum)])
        if ~isempty(diodeData)
            markerY = get(hAxesB,'Ylim');
            markerX = [frmNum;frmNum];
            set(hPlotC,'XData',markerX,'YData',markerY)
            timerZoomFun([],[])
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% button toggle functions
    function turn_flags_on(~,~)
        set(hSingle,'Enable','on')
        set(hBlank,'Enable','on')
        set(hMulti,'Enable','on')
        set(hGender,'Enable','on')
        set(hCgamma,'Enable','on');
        set(hCzoom,'Enable','on');
        set(hCgamReset,'Enable','on');
        set(hCreset,'Enable','on');
        set(hBplayback,'Visible','on')
    end
    function turn_flags_off(~,~)
        set(hSingle,'Enable','off')
        set(hBlank,'Enable','off')
        set(hMulti,'Enable','off')
        set(hGender,'Enable','off')
        set(hCgamma,'Enable','off');
        set(hCzoom,'Enable','off');
        set(hCgamReset,'Enable','off');
        set(hCreset,'Enable','off');
        set(hBplayback,'Visible','off')
        set(hCnextVid,'Enable','off');
        set(hCprevVid,'Enable','off');
        set(hCnextFile,'Enable','off');
        set(hCprevFile,'Enable','off');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% updates video functions
    function timerVidFun(~,~)
        frmOps = circshift(frmOps,-frmDelta);
        frmNum = frmOps(1);
        set(hCpos,'Value',frmNum)
        videoDisp
    end
    function rateCallback(~,eventdata)
        butValN = eventdata.NewValue;
        frmRate = hCspeedOps(butValN == btnHmat);
        if frmRate ~= 0
            perVal = round((1/abs(frmRate))*1000)/1000;
            if perVal > 0.001
                frmDelta = abs(frmRate)/frmRate;
                if strcmp(tVid.Running,'on'),stop(tVid),end
                set(tVid,'Period',perVal)
                if strcmp(tVid.Running,'off'),start(tVid),end
            end
        else
            if strcmp(tVid.Running,'on'),stop(tVid),end
            frmDelta = 0;
        end
    end
    function changeframe(hObj,~)
        frmOff = frmOps(1) - str2double(get(hObj,'string'));
        frmOps = circshift(frmOps,frmOff);
        frmNum = frmOps(1);
        videoDisp
        set(hCpos,'Value',frmNum)
    end
%% next and last experiment
    function pfileCallback(~,~)
        save_tables
        resetbuttons
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        timerZoomFun([],[])
        
        gammaResetCallback
        last_value = get(hTedit(4),'value');
        if last_value == 2
            set(hTedit(4),'value',length(get(hTedit(4),'string')));
        else
            set(hTedit(4),'value',last_value - 1);
        end
        set(hTedit(5),'Value',1,'String','....');
        populate_vid_list(hTedit(4));
        
%        clear_graph
    end
    function nfileCallback(~,~)
        if ~annotate_error
            save_tables
        end
        resetbuttons
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        timerZoomFun([],[])
        
        gammaResetCallback
        last_value = get(hTedit(4),'value');
        if last_value == length(get(hTedit(4),'string'))
            set(hTedit(4),'value',2);
        else
            set(hTedit(4),'value',last_value + 1);
        end
        set(hTedit(5),'Value',1,'String','....');
        populate_vid_list(hTedit(4));
        
%        clear_graph
    end
    function setprevvid(~,~)
        save_tables
        if length(vidOps) == 1
            return
        end
        resetbuttons
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        timerZoomFun([],[])
        
        if video_index > 1
            video_index = video_index - 1;
        else
            video_index = length(vidOps);
        end
        vidName = vid_list(video_index,:);
        
        set(hTedit(5),'Value',video_index+1)
        timerGamFun([],[])
        clear_graph
        
        set_user_data
        videoLoad
    end
    function setnextvid(~,~)
        save_tables
        if length(vidOps) == 1
            return
        end
        resetbuttons
        set(hCzoom,'Value',0);      %resets zoom when vid changes
        timerZoomFun([],[])
        
        if video_index < length(vidOps)
            video_index = video_index + 1;
        else
            video_index = 1;
        end
        
        vidName = vid_list(video_index,:);
        set(hTedit(5),'Value',video_index)
        timerGamFun([],[])
        clear_graph
        
        set_user_data
        videoLoad
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% figure click functions
    function FigClickCallback(~,~)
        clickPos = get(0,'PointerLocation');
        set(hCreset,'Visible','on')
        minPos = clickPos-FigPos(1:2)-axesApos(1:2);
        maxPos = axesApos(3:4)-minPos;
        if min([minPos maxPos]) > 0 && strcmp(get(hCreset,'Enable'),'on')
            start(tFig)
        end
    end
    function resetFigCallback(~,~)
%        centerIm = [vidWidth/2 vidHeight/2];
        centerIm = [vidWidth/2 vidWidth/2];
        zoomMag = 1;
        clickPos = get(0,'PointerLocation');
        timerFigFun([],[])
        set(hCreset,'Visible','off')
        set(hFigA,'CurrentAxes',[])
    end
    function FigReleaseCallback(~,~)
        stop(tFig)
        dragDist = clickPos-get(0,'PointerLocation');
        if isempty(centerIm)
            centerIm = [dragDist(1) -dragDist(2)];
        else
            centerIm = centerIm+[dragDist(1) -dragDist(2)];
        end
    end
    function FigWheelCallback(~,event)
        clickPos = get(0,'PointerLocation');
        minPos = clickPos-FigPos(1:2)-axesApos(1:2);
        maxPos = axesApos(3:4)-minPos;
        if min([minPos maxPos]) > 0
            zoomMag = zoomMag+(event.VerticalScrollCount/100)*3;
            timerFigFun([],[])
            set(hCreset,'Visible','on')
        end
    end
    function timerFigFun(~,~)
        dragDist = clickPos-get(0,'PointerLocation');
        hWidth = vidWidth*zoomMag/2;
%        hHeight = vidHeight*zoomMag/2;
%        set(hAxesA,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth]+dragDist(1),...
%            'ylim',[centerIm(2)-hHeight centerIm(2)+hHeight]-dragDist(2))
        set(hAxesA,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth]+dragDist(1),...
            'ylim',[centerIm(2)-hWidth centerIm(2)+hWidth]-dragDist(2))
        videoDisp
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% zoom function
    function ZoomClickCallback(~,~)
        start(tZoom)
    end
    function ZoomReleaseCallback(~,~)
        stop(tZoom)
    end
    function zoomCallback(~,~)
        timerZoomFun([],[])
    end
    function timerZoomFun(~,~)
        if ~isempty(diodeData)
            zoomVal = 1-get(hCzoom,'Value');
            tarSpan = length(frmOps)*zoomVal/2;
            xlimGrph = [-tarSpan tarSpan]+frmNum;
            minXlim = min(xlimGrph);
            maxXlim = length(frmOps)-max(xlimGrph);
            if minXlim < 1
                xlimGrph = xlimGrph-minXlim+1;
            elseif maxXlim < 0
                xlimGrph = xlimGrph+maxXlim;
            end
            set(hAxesB,'XLim',xlimGrph)
        end
        %         get(hAxesB)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% position slider functions
    function PosClickCallback(~,~)
        if strcmp(tVid.Running,'on')
            set(hBplayback,'SelectedObject',btnHmat(4))
            stop(tVid)
        end
        start(tPos)
    end
    function PosReleaseCallback(~,~)
        stop(tPos)
    end
    function PosWheelCallback(~,event)
        frmOff = event.getWheelRotation;
        frmOps = circshift(frmOps,frmOff);
        frmNum = frmOps(1);
        videoDisp
        set(hCpos,'Value',frmNum)
        drawnow
    end
    function positionCallback(~,~)
        timerPosFun([],[])
    end
    function timerPosFun(~,~)
        frmNum = round(get(hCpos,'Value'));
        videoDisp
        frmOff = find(frmOps == frmNum);
        frmOps = circshift(frmOps,-frmOff+1);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% gamma slider functions
    function GammaClickCallback(~,~)
        start(tGam)
    end
    function GammaReleaseCallback(~,~)
        stop(tGam)
    end
    function gammaCallback(~,~)
        timerGamFun([],[])
    end
    function timerGamFun(~,~)
        gammaVal = get(hCgamma,'Value');
        set(hFigA,'colormap',gray(256).^gammaVal)
        set(hTedit(guiRefs(6)),'string',['   ' num2str(gammaVal)])
        videoDisp
    end
    function gammaResetCallback(~,~)
        set(hCgamma,'Value',1)
        timerGamFun([],[])
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets count / gender / slip and frame info
    function setgender(hObj,~)
        if hObj == hGender(1) && get(hObj,'value') == 1
            set(hGender(1),'backgroundcolor',rgb('very light blue'));
            set(hGender(2),'backgroundcolor',[0.9412 0.9412 0.9412]);
            set(hGender(3),'backgroundcolor',[0.9412 0.9412 0.9412]);
            get_user_data('Male','Gender');
        elseif hObj == hGender(2) && get(hObj,'value') == 1
            set(hGender(1),'backgroundcolor',[0.9412 0.9412 0.9412]);
            set(hGender(2),'backgroundcolor',rgb('very light blue'));
            set(hGender(3),'backgroundcolor',[0.9412 0.9412 0.9412]);
            get_user_data('Female','Gender');
        elseif hObj == hGender(3) && get(hObj,'value') == 1
            set(hGender(1),'backgroundcolor',[0.9412 0.9412 0.9412]);
            set(hGender(2),'backgroundcolor',[0.9412 0.9412 0.9412]);
            set(hGender(3),'backgroundcolor',rgb('very light blue'));
            get_user_data('Not_Sure','Gender');            
        else
            get_user_data('Unknown','Gender');
        end
    end
    function setsinglevid(~,~)
        get_user_data('Single','Fly_count');
        set(hSingle,'backgroundcolor',rgb('light green'))
        set(hBlank,'backgroundcolor',rgb('light grey'))
        set(hMulti,'backgroundcolor',rgb('light grey'))
    end
    function setblankvid(~,~)
        get_user_data('Empty','Fly_count');
        get_user_data('Unknown','Gender');
        set(hSingle,'backgroundcolor',rgb('light grey'))
        set(hBlank,'backgroundcolor',rgb('light orange'))
        set(hMulti,'backgroundcolor',rgb('light grey'))
    end
    function setmultivid(~,~)
        get_user_data('Multi','Fly_count');
        get_user_data('Unknown','Gender');
        set(hSingle,'backgroundcolor',rgb('light grey'))
        set(hBlank,'backgroundcolor',rgb('light grey'))
        set(hMulti,'backgroundcolor',rgb('light red'))
    end
    function getframeinfo(hObj,~)
                
        prev_data = get(bout_table,'Data');
        frame_match = find(hObj == hFramebutton,1,'first');
        frame_val = str2double(get(hTedit(7),'string'));        
        
        if isempty(prev_data) && frame_match == 1       %start of new bout
            new_bout = cell(1,3);
            new_bout(1) = {1};
            new_bout(2) = num2cell(frame_val);
            bout_data = [prev_data;new_bout];
        elseif isempty(prev_data) && frame_match == 2    %user hit rectaced but no bout started
            %do nothing for this case
        elseif ~isempty(cell2mat(prev_data(end,2))) && isempty(cell2mat(prev_data(end,3))) && frame_match == 1
            prev_data(end,2) = num2cell(frame_val);
            bout_data = prev_data;
        elseif isempty(cell2mat(prev_data(end,3))) && frame_match == 2
            %probscis is retacted, finish bout
            prev_data(end,3) = num2cell(frame_val);
            bout_data = prev_data;
        elseif ~isempty(cell2mat(prev_data(end,:))) && frame_match == 2
            %probscis is retacted, finish bout
            prev_data(end,3) = num2cell(frame_val);
            bout_data = prev_data;
            
        elseif sum(cellfun(@(x) isempty(x),prev_data(end,:))) == 0 && frame_match == 1
            %previos bouts finished start a new one
            index = cell2mat(prev_data(end,1)) + 1;
            new_bout = cell(1,3);
            new_bout(1) = {index};
            new_bout(2) = num2cell(frame_val);
            bout_data = [prev_data;new_bout];
        end
        
        set(bout_table,'Data',bout_data,'fontsize',10);
    end
    function setnotes(~,~)
        note_str = get(hNotes,'string');
        get_user_data(note_str,'Notes');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reset/clear and save functions
    function reset_video
        resetbuttons
        clear_graph
        hIm = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
        set(hIm,'CData',(zeros(vidHeight,vidWidth,1)))
        set(hAxesB,'YLim',[0 4],'XLim',[1 2],'Color',[0 0 0],'XColor',[1 1 1],'YColor',[1 1 1],'TickDir','in')
%        title(hAxesB,'Photo-Diode Data','Color',[1 1 1], 'fontweight','demi','fontunits','normalized','FontSize',0.0187)
        title(hAxesB,'Photo-Diode Data','Color',[1 1 1], 'fontweight','demi','fontunits','normalized','FontSize',0.10)
    end
    function reset_matching(~,~)
        if hInputvalues(1) == 0
            return
        end
        set(hInputvalues,'string',['   ' '0']);
        set(hNotes,'string','');
        set(slip_opts,'value',0);
    end
    function clear_graph
        set(hAxesB,'NextPlot','replacechildren')
        plot(0,0,'marker','none','parent',hAxesB,'tag','empty_plot');
        set(hAxesB,'NextPlot','add','Color',[0 0 0])
        hPlotC = plot([0 0],[0 4],'color',rgb('white'),'Marker','none','parent',hAxesB);
    end
    function resetbuttons
        set(hSingle,'BackgroundColor',[0.941176 0.941176 0.941176])
        set(hGender,'BackgroundColor',[0.941176 0.941176 0.941176])
        set(hBlank,'backgroundcolor',[0.941176 0.941176 0.941176])
        set(hMulti,'backgroundcolor',[0.941176 0.941176 0.941176])
        reset_matching
        set(bout_table,'Data',[]);
    end

    function myCloseFun(~,~)
        save_tables
        if strcmp(tVid.Running,'on'),stop(tVid),end
        if strcmp(tPos.Running,'on'),stop(tPos),end
        if strcmp(tGam.Running,'on'),stop(tGam),end
        if strcmp(tFig.Running,'on'),stop(tFig),end
        if strcmp(tZoom.Running,'on'),stop(tZoom),end
        delete(tVid)
        delete(tPos)
        delete(tGam)
        delete(tFig)
        delete(tZoom)
        delete(hFigA)
    end
    function get_user_data(value,options)
        switch options
            case 'Fly_count'
                save_table.Fly_Count = {value};
            case 'Gender'
                save_table.Gender = {value};
            case 'Notes'
                save_table.Notes = {value};                
            case 'Proboscis'                
                save_table.Proboscis = {value};
        end
    end
    function save_tables(~,~)
        curr_data = get(bout_table,'Data');
        get_user_data(curr_data,'Proboscis');
        var_names = fieldnames(save_table);
        new_save_table = cell2table(struct2cell(save_table)');
        new_save_table.Properties.VariableNames = var_names;
        new_save_table.Properties.RowNames = vidName;
        
        if ~isempty(Proboscis_Annotations)
            if ismember(vidName,Proboscis_Annotations.Properties.RowNames)      
                Proboscis_Annotations(vidName,:) = new_save_table;              %record exists, update with new info
            else
                Proboscis_Annotations = [Proboscis_Annotations;new_save_table]; %record not in save table, add it
            end
        else
            Proboscis_Annotations = [Proboscis_Annotations;new_save_table];     %save table is empty, add new record
        end
        
        save(fullfile(save_data_path,'Proboscis_Annotations'),'Proboscis_Annotations');
    end
end