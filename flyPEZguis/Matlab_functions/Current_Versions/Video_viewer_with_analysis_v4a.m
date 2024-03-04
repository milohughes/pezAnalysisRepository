function Video_viewer_with_analysis_v4a

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

file_dir = fullfile(fileDir,'Pez3000_Gui_folder','Gui_saved_variables');
analysis_path = fullfile(fileDir,'Data_pez3000_analyzed');
data_path = fullfile(fileDir,'Data_pez3000');

repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));

addpath(genpath('C:\Users\Card Lab\Documents\pezAnalysisRepository\')) %added by SA 8-14-23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saved_collections = load([file_dir filesep 'Saved_Collection.mat']);
saved_collections = saved_collections.Saved_Collection;

saved_groups = load([file_dir filesep 'Saved_Group_IDs_table.mat']);
saved_groups = saved_groups.Saved_Group_IDs;

exp_dir =  struct2dataset(dir(analysis_path)); 
exp_dir = exp_dir.name;
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));

exp_cut = 10;
exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= exp_cut,exp_dir));

saved_collections = saved_collections(ismember(get(saved_collections,'ObsNames'),cellfun(@(x) x(1:4), exp_dir,'uniformoutput',false)),:);
[~,sort_idx] = sort(lower(regexprep(saved_groups.Properties.RowNames,' ','')));
saved_groups = saved_groups(sort_idx,:);
saved_users   = unique([saved_collections.User_ID;saved_groups.User_ID]);
saved_groups = saved_groups(cellfun(@(x) contains(x,'Active'),saved_groups.Status),:);

temp_range = [22.0 24.0];
skip_fail = 0;
flag = 'None';

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
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
hAxesA = axes('Parent',hFigA,'Position',guiPosFun([.456 .53],[.345 .9]),'color','k','tickdir','in','nextplot','replacechildren','xticklabel',[],'yticklabel',[],'visible','off','YDir','reverse');
set(hAxesA,'DataAspectRatio',[1 1 1],'DrawMode','fast','units','pix');
axesApos = get(hAxesA,'position');
set(hAxesA,'units','normalized')
axesBpos = guiPosFun([.82 .55],[.3 .78]);
hAxesB = axes('Parent',hFigA,'Position',axesBpos,'visible','on','Color',rgb('black'));
hPlotA = plot(hAxesA,0,0,'visible','off');
hPlotB = plot(hAxesA,0,0,'visible','off');
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
frmResetPos = frmResetPos.*[1.3 1.1 0.5 0.02];
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
frmStrCell = {'Frame','Corrected Frame','Photodiode Value'};
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
new_y = [13,15,17];
for iterPC = 1:frmStrCt
    textPos = guiPosFun([texXops(7),texYops(iterPC+14)],[texW*7.75 texH*0.8]);
    set(hTlabels(frmRefs(iterPC)),'Position',textPos,'fontunits','normalized')
    textPos = guiPosFun([texXops(15),texYops(iterPC+14)],[texW*7.75 texH*0.8]);
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

uicontrol(hPanA,'Style','text','string','Previous Annotations BY','Units','normalized','Position',[0.0600 .610 .43 0.025],...
        'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500);

uicontrol(hPanA,'Style','text','string','Current Annotater','Units','normalized','Position',[0.0600 .575 .43 0.025],...
        'HorizontalAlignment','center','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500);

prev_user = uicontrol(hPanA,'Style','popup','string','Previous User','Units','normalized','HorizontalAlignment','left',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500,'Position',[0.5000 .605 .43 0.030]);
    
annotate_user = uicontrol(hPanA,'Style','popup','string',['Select User';saved_users],'Units','normalized','HorizontalAlignment','left',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4500,'Position',[0.5000 .570 .43 0.030]);
    
[locA,locB] = ismember(lower(localUserName),lower(saved_users));
if sum(locA) > 0
    set(annotate_user,'value',locB(locA)+1);
else
    set(annotate_user,'value',1);
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

wrn_meg = uicontrol(hPanA,'style','text','units','normalized','string',' ',...
    'Position',[0.5000 .542 .415 0.015],'fontunits','normalized','fontsize',.4444);
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
vidOff = 0;                 vidObjCell = cell(2,1);     collect_select = [];        graph_flag = 'stimuli';     frameReferenceMesh = [];        slip_opts = [];                 hNotes = [];
frameRefcutrate = [];       frameReffullrate = [];      group_list = [];            hFramebutton = zeros(4,1);  photoData = [];                 frame_count = 0;
graph_annotations = [];
auto_annotations = [];      stimuli_info = [];          assess_table = [];          man_annotations = [];       annotate_error = [];            track_data = [];
roi = [];                   hQuiv = [];                 frm_remap = [];             h_plot_top = [];            h_plot_bot = [];        h_plot_top_f = [];            h_plot_bot_f = [];
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
        for iterC = 1:4
            Input_opts = {'Wing Lift Frame:';'Leg Push Frame:';'Downstroke Frame:';'Take off Frame:'};
            textPos = guiPosFun([texXops(7),texYops(iterC+18)],[texW*7.75 texH*0.8]);
            hFramebutton(iterC) = uicontrol(hPanA,'Style','pushbutton','string',Input_opts{iterC},'Units','normalized',...
                'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.500,...
                'Position',textPos,'callback',@getframeinfo);
            textPos = guiPosFun([texXops(15),texYops(iterC+18)],[texW*7.75 texH*0.8]);
            hInputvalues(iterC) = uicontrol(hPanA,'Style','edit','string',['   ' '0'],'Units','normalized','HorizontalAlignment','left',...
                'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.500,'Position',textPos,'callback',@getframeinfo);
        end
        slip_opts = uicontrol(hPanA,'Style','checkbox', 'string','   Fly Sliped','Units','normalized','HorizontalAlignment','left',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.4598,'Position',guiPosFun([texXops(11),texYops(23)],[texW*7.75 texH*0.8]),'callback',@setslippers);
        hNotes = uicontrol(hPanA,'Style','edit', 'string',' ','Units','normalized','HorizontalAlignment','left',...
            'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize', 0.0900,'Position',[.1250 .1175 .7500 .1075],'min',0,'max',2,'callback',@setnotes);
    end
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
%         if strcmp(user_select,'Otero Coronels')
%             flag = 'Santiago';
%         end
        
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
        
        if sum(cellfun(@(x) contains(x,'Annotated_by'),man_annotations.Properties.VariableNames)) == 1
        else        %if field does not exist updated to pat breads annotated
            man_annotations.Annotated_by = repmat({'Breadsp'},height(man_annotations),1);
        end
        not_done = cellfun(@(x) isempty(x), man_annotations.frame_of_leg_push);
        man_annotations(not_done,:).Annotated_by = repmat({''},sum(not_done),1);
                
        vid_list = man_annotations.Properties.RowNames;
        set(exp_count,'string','1');
        
        assess_table = assess_table(vid_list,:);
        stimuli_info = stimuli_info(vid_list,:);
        
                
        set(hTlabels(5),'String','Select Video:');
% keyboard
        filter_vid_list
    end
    function filter_vid_list(~,~)
        temp_data = Experiment_ID(exp_id);
        temp_data.ignore_graph_table = true;
        temp_data.load_data;
%         if strcmp(flag,'Santiago')
%             temp_data.make_tables;
%             temp_data.get_tracking_data;
%             temp_data.display_data;                
%             vid_list = [temp_data.Complete_usuable_data.Properties.RowNames;temp_data.Videos_Need_To_Work.Properties.RowNames];
%             
%             in_range_logic = [abs(temp_data.Complete_usuable_data.Total_Movement) <= 22.5;abs(temp_data.Videos_Need_To_Work.Total_Movement) <= 22.5];
%             vid_list = vid_list(in_range_logic);
%         else
            vid_list = temp_data.Complete_usuable_data.Properties.RowNames;
%        end
        
%        filt_logic = ismember(man_annotations.Properties.RowNames,vid_list);
%        filt_annotations = man_annotations(filt_logic,:);
%        filt_annotations = man_annotations(vid_list,:);        
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
            
            done_gender = cellfun(@(x) (contains(x,'Unknown')) , filt_annotations.Gender);
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
        set(hInputvalues,'string',['   ' '1']);
%         manTests = [isempty(curr_entry.frame_of_take_off{1});
%             curr_entry.frame_of_take_off{1} == 1;
%             curr_entry.frame_of_take_off{1} == 0;
%             isnan(curr_entry.frame_of_take_off{1})];
%         if ~max(manTests)
            set(hInputvalues(1),'string',['   ' num2str(curr_entry.frame_of_wing_movement{1})]);
            set(hInputvalues(2),'string',['   ' num2str(curr_entry.frame_of_leg_push{1})]);
            set(hInputvalues(3),'string',['   ' num2str(curr_entry.wing_down_stroke{1})]);
            set(hInputvalues(4),'string',['   ' num2str(curr_entry.frame_of_take_off{1})]);
%         elseif ~isempty(auto_annotations)
%             if ~isempty(auto_annotations.autoFrameOfTakeoff{vidName})
%                 set(hInputvalues(4),'string',['   ' num2str(auto_annotations.autoFrameOfTakeoff{vidName}*10)]);
%             end
%         end
     if isempty(curr_entry.frame_of_wing_movement{1})
        set(prev_user,'string','No Previous Annoations');
        man_annotations(vidName,:).Annotated_by = {''};
     else
        set(prev_user,'string',man_annotations(vidName,:).Annotated_by);
     end

    set(hNotes,'string',curr_entry.notes{1});
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load and parsing functions
    function videoLoad
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
        try
            vidObj_partail = VideoReader(fullPath_parital);
        catch
            warning('vid reader fail')
            setnextvid
        end
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
        if strcmp(temp_vidStats.download_option,'Save Full Rate')
            frameRefcutrate = (1:1:temp_vidStats.frame_count)';
            frameReffullrate = [];
        else
            frameRefcutrate = double(temp_vidStats.cutrate10th_frame_reference{1});
            frameReffullrate = double(temp_vidStats.supplement_frame_reference{1});
        end
        Y = (1:numel(frameRefcutrate));
        x = frameRefcutrate;
        if ~strcmp(temp_vidStats.download_option,'Save Full Rate')
            xi = (1:(vidFrames_partial*10));
            yi = repmat(Y,10,1);
            yi = yi(:);
            cut_ref = 10;
        else
            yi = Y;
            xi = (1:vidFrames_partial);
            cut_ref = 1;
        end
        
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*cut_ref));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        
        if length(xi) ~= length(yi)
            setnextvid
        end
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
        
        frmOps = 1:1:(vidFrames_partial*cut_ref);
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
        
        
        matlab.video.read.UseHardwareAcceleration('on');
        frmData = read(vidObj_partail,1);  %#ok<VIDREAD>
        
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
            
            avgBase_diode = means(min(ranges(:,1)) == ranges(:,1));
            avgPeak_diode = means(max(ranges(:,1)) == ranges(:,1));
            
            avgBase_photo = means(min(ranges(:,2)) == ranges(:,2));
            avgPeak_photo = means(max(ranges(:,2)) == ranges(:,2));
            
            photoSignalTest_d = abs((avgPeak_diode(1)-avgBase_diode(1))/min(ranges(:,1)));
            photoSignalTest_p = abs((avgPeak_photo(1)-avgBase_photo(1))/min(ranges(:,2)));
            
%             if photoSignalTest_d >= 10
%                 diodeData = abs(diodeData-avgBase_diode(1))./max(ranges(:,1)) + 1.0;
%             else
%                 diodeData = abs(diodeData-avgBase_diode(1)) + 1.0;
%             end

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
            ylimit = get(hAxesB,'Ylim');
            xlimit = get(hAxesB,'Xlim');
            line(xlimit,[2 2],'color',rgb('green'),'linewidth',1,'parent',hAxesB);
            
            %         stim_duration = stim_lv/(tan((start_angle * pi/180)/2)) - stim_lv/(tan((end_angle * pi/180)/2));
            %         time_duration = (end_frame - start_frame)/ 6;
            title(hAxesB,sprintf(' Photo Activation :: Blue Trace              Loominging Stimuli :: Red Trace \n  Supplemental Frame Information :: Orange Trace'),...
                'Color',[1 1 1], 'fontweight','demi','fontunits','normalized','FontSize',0.0150,'Interpreter','none')
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
        temp_vidStats = stimuli_info(vidName,:);
        adj_roi = assess_table(vidName,:).Adjusted_ROI{1};
        if isempty(adj_roi)
            roi = cell2mat(temp_vidStats.roi);
        else
            roi = adj_roi;
        end
        line([roi(1,1) roi(2,1)],[roi(1,2) roi(2,2)],'parent',hAxesA,'Tag','roi line');
        line([roi(3,1) roi(3,1)],[roi(1,2) roi(2,2)],'parent',hAxesA,'Tag','roi line');
        line([roi(1,1) roi(3,1)],[roi(1,2) roi(1,2)],'parent',hAxesA,'Tag','roi line');
        line([roi(1,1) roi(3,1)],[roi(2,2) roi(2,2)],'parent',hAxesA,'Tag','roi line');
        line([roi(7,1) roi(8,1)],[roi(7,2) roi(8,2)],'parent',hAxesA,'Tag','roi line','color',[0 1 0]);
        plotx = [roi(7,1) roi(8,1)];
        ploty = [roi(7,2) roi(8,2)]-3;
        hPlotB = plot(hAxesA,plotx,ploty,'visible','on','color',[0 0 1]);
        
        plotx = [roi(7,1) roi(8,1)];
        ploty = [400 400];
        
        mid_x = (roi(3,1)-roi(1,1))/2+roi(1,1);
        mid_y = (roi(2,2)-roi(1,2))/2+roi(1,2);
        
        line([roi(1,1) roi(3,1)],[mid_y mid_y],'color',rgb('cyan'),'linewidth',.5,'parent',hAxesA);
        line([mid_x,mid_x],[roi(2,2) roi(1,2)],'color',rgb('cyan'),'linewidth',.5,'parent',hAxesA);

%        hPlotA = plot(hAxesA,plotx,ploty,'visible','on','color',[1 0 0],'Marker','none','LineStyle','-');
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
        manual_frame = str2double(get(hInputvalues(4),'string'));
        if ~isnan( manual_frame)
            plot(hAxesB,manual_frame,2.5,'b*','MarkerSize',10)
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% show the video
    function videoDisp(~,~)
        if isempty(frameReferenceMesh)
            return
        end
        plot_tracking_data
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
        try
            set(hIm,'CData',frmData);
        catch
            hIm = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
            set(hIm,'CData',frmData);
            warning('error')
        end
                
        xi = get(hPlotB,'xdata');
        yi = get(hPlotB,'ydata');
        n = 200;
%        [cxa,~,ca] = improfile(frmData(:,:,1),xi,yi,n);
%        ca = (ca/256)*(-100)+350;
%        set(hPlotA,'xdata',cxa,'ydata',ca);
        drawnow
    end
    function texUpdate
        set(hTedit(frmRefs(1)),'string',['   ' int2str(frmNum)])
        if ~isempty(diodeData)
            markerY = get(hAxesB,'Ylim');
            markerX = [frmNum;frmNum];
            set(hPlotC,'XData',markerX,'YData',markerY)
            timerZoomFun([],[])
%             if ~isempty(start_frame)
%                 set(hTedit(frmRefs(2)),'string',['   ' int2str(frmNum-start_frame)])
%             end
            if  strcmp(graph_flag,'stimuli')
                set(hTlabels(frmRefs(3)),'string','Photodiode Value')
                set(hTedit(frmRefs(3)),'string',['   ' num2str(diodeData(frmNum))])
            elseif strcmp(graph_flag,'photo')
                set(hTlabels(frmRefs(3)),'string','Photo-Activation Value')
                set(hTedit(frmRefs(3)),'string',['   ' num2str(diodeData(frmNum))])
            end
        end
    end
    function plot_tracking_data(~,~)
        if ishandle(hQuiv)
            delete(hQuiv);
        end
        if ishandle(h_plot_top)
            delete(h_plot_top)
        end
        if ishandle(h_plot_bot)
            delete(h_plot_bot)
        end        
        if ishandle(h_plot_top_f)
            delete(h_plot_top_f)
        end
        if ishandle(h_plot_bot_f)
            delete(h_plot_bot_f)
        end        
        
        offset = vidHeight - vidWidth;
        hQuiv(1) = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',hAxesA,'Visible','off');
        hQuiv(2) = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',hAxesA,'Visible','off');
        hQuiv(3) = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',hAxesA,'Visible','off');
        roi_top = ((min(roi(1:5,2)) - 832/2))/2+832/2;
        fly_tracked = true;
        frmData = get(hIm,'CData');
        
        if ~isempty(track_data)            
            flyTheta = cell2mat(track_data.bot_points_and_thetas);
            flyAlpha = cell2mat(track_data.top_points_and_thetas);
            flyDelta = cell2mat(track_data.XYZ_3D_filt);
            if isempty(flyTheta)
                fly_tracked = false;
            end
            if fly_tracked == true
                if frmNum <= length(flyTheta(:,3))
                    draw_quivers(1,[.9 .3 .1],flyTheta(frmNum,3),3)
                    h_plot_bot = plot(flyTheta(frmNum,1),offset+flyTheta(frmNum,2),'bo','Parent',hAxesA);
                    h_plot_top = plot(flyAlpha(frmNum,1),flyAlpha(frmNum,2),'bo','Parent',hAxesA);

                    h_plot_top_f = plot(flyDelta(frmNum,1),offset+flyDelta(frmNum,2),'ro','Parent',hAxesA);
                    h_plot_bot_f = plot(flyDelta(frmNum,1),flyDelta(frmNum,3),'ro','Parent',hAxesA);
                    
                else
                    draw_quivers(1,[.9 .3 .1],0,0)
                end
                draw_quivers(2,rgb('green'),track_data.stimulus_azimuth{1},2)
                draw_quivers(3,rgb('light blue'),(track_data.fly_detect_azimuth*(pi/180)),2)
    %            plot(flyTheta(frmNum,1),roi_top+flyTheta(frmNum,2),'bo','Parent',hAxesA)      
                
%                [BW,maskedImage] = segmentImage(frmData);
            else
%                [BW,maskedImage] = segmentImage(frmData);
            end
        end
        if isempty(track_data) || fly_tracked == false
            try
                org_stim_angle = stimuli_info(vidName,:).visual_stimulus_info{1}.azimuth;
                draw_quivers(3,rgb('light blue'),stimuli_info(vidName,:).fly_detect_azimuth*(pi/180),2);            
                draw_quivers(2,rgb('green'),org_stim_angle*(pi/180),2)
            catch
                return
            end
        end
    end
    function draw_quivers(index,color,pos_vect,line_length)
        if line_length == 0 || ~ishandle(hQuiv(index))
            return
        end
        avgPrismL = mean([roi(3)-roi(1),roi(4)-roi(2)]);            
        u = cos(pos_vect)*avgPrismL*0.45;
        v = -sin(pos_vect)*avgPrismL*0.45;
        try
            set(hQuiv(index),'XData',roi(1)+avgPrismL/2,'YData',(vidHeight-(roi(2)+avgPrismL/2)),...
                'MaxHeadSize',5,'LineWidth',line_length,'AutoScaleFactor',1,'color',color,'UData',u,'VData',v,'visible','on')            
        catch
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
        centerIm = [vidWidth/2 vidHeight/2];
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
        hHeight = vidHeight*zoomMag/2;
        set(hAxesA,'xlim',[centerIm(1)-hWidth centerIm(1)+hWidth]+dragDist(1),...
            'ylim',[centerIm(2)-hHeight centerIm(2)+hHeight]-dragDist(2))
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
        man_annotations(vidName,:).Annotated_by = saved_users(get(annotate_user,'Value')-1);
    end
    function getframeinfo(hObj,~)
        frame_val = str2double(get(hObj,'string'));
        frame_match = find(hObj == hInputvalues,1,'first');
        
        if isempty(frame_match)
            frame_match = find(hObj == hFramebutton,1,'first');
            frame_val = str2double(get(hTedit(7),'string'));
        end
        
        switch frame_match
            case 1
                get_user_data(frame_val,'Wings_Up')
                set(hInputvalues(1),'string',['   ' num2str(frame_val)]);
            case 2
                get_user_data(frame_val,'Leg_Kick')
                set(hInputvalues(2),'string',['   ' num2str(frame_val)]);
            case 3
                get_user_data(frame_val,'Wings_Down')
                set(hInputvalues(3),'string',['   ' num2str(frame_val)]);
            case 4
                get_user_data(frame_val,'Take_Off')
                set(hInputvalues(4),'string',['   ' num2str(frame_val)]);
        end
    end
    function setslippers(~,~)
        slip_val = get(slip_opts,'value');
        get_user_data(slip_val,'Slippers');
    end
    function setnotes(~,~)
        note_str = get(hNotes,'string');
        get_user_data(note_str,'Notes');
    end
    function get_user_data(value,options)
        if isstruct(assess_table)
            assess_table = assess_table.assessTable;
        end
        switch options
            case 'Fly_count'
                assess_table(vidName,:).Fly_Count = {value};
            case 'Gender'
                assess_table(vidName,:).Gender = {value};
            case 'Slippers'
                man_annotations(vidName,:).leg_slip = {value};
            case 'Notes'
                man_annotations(vidName,:).notes = {value};                
            case 'Wings_Up'                
                man_annotations(vidName,:).frame_of_wing_movement = {value};
            case 'Leg_Kick'
                man_annotations(vidName,:).frame_of_leg_push = {value};
            case 'Wings_Down'
                man_annotations(vidName,:).wing_down_stroke = {value};
            case 'Take_Off'
                man_annotations(vidName,:).frame_of_take_off = {value};
        end
        man_annotations(vidName,:).Annotated_by = saved_users(get(annotate_user,'Value')-1);
        %when a change is made, change the annotated_by field to current
        %user name who made the change

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% reset/clear and save functions
    function reset_video
        resetbuttons
        clear_graph
        hIm = image('Parent',hAxesA,'CData',zeros(vidHeight,vidWidth,1));
        set(hIm,'CData',(zeros(vidHeight,vidWidth,1)))
        set(hAxesB,'YLim',[0 4],'XLim',[1 2],'Color',[0 0 0],'XColor',[1 1 1],'YColor',[1 1 1],'TickDir','in')
        title(hAxesB,'Photo-Diode Data','Color',[1 1 1], 'fontweight','demi','fontunits','normalized','FontSize',0.0187)
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
    end
    function fill_blanks(~,~)
        vid_index = vid_list(video_index,:);
        if isempty(man_annotations(vid_index,:).frame_of_take_off{1}) || man_annotations(vid_index,:).frame_of_take_off{1} == 0
            man_annotations(vid_index,:).frame_of_take_off = {NaN};
        end
        if isempty(man_annotations(vid_index,:).frame_of_wing_movement{1}) || man_annotations(vid_index,:).frame_of_wing_movement{1} == 0
            man_annotations(vid_index,:).frame_of_wing_movement = {NaN};
        end
        if isempty(man_annotations(vid_index,:).frame_of_leg_push{1}) || man_annotations(vid_index,:).frame_of_leg_push{1} == 0
            man_annotations(vid_index,:).frame_of_leg_push = {NaN};
        end
        if isempty(man_annotations(vid_index,:).wing_down_stroke{1}) || man_annotations(vid_index,:).wing_down_stroke{1} == 0
            man_annotations(vid_index,:).wing_down_stroke = {NaN};
        end
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
    function save_tables(~,~)
        if isempty(vid_list)
            return
        end
        if get(annotate_user,'Value') == 1      %no user was selected
            set(wrn_meg,'string','no annotated user selected: Please select a user');               
        else        %only move on if user was selected
            set(wrn_meg,'string',' ');
            fill_blanks
            manualAnnotations = man_annotations; %#ok<*NASGU>
            if isstruct(manualAnnotations)
                manualAnnotations = manualAnnotations.manualAnnotations;
            end


            save([analysis_path filesep exp_id filesep exp_id '_manualAnnotations'],'manualAnnotations');
            assessTable = assess_table;
            if isstruct(assessTable)
                assessTable = assess_table.assessTable;
            end
            save([analysis_path filesep exp_id filesep exp_id '_rawDataAssessment'],'assessTable');
        end
    end

end