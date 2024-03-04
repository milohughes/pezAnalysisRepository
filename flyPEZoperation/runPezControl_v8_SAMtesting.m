function runPezControl_v8_SAMtesting
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all force
% cd('C:\Users\cardlab\Documents\Photron_flyPez3000')

% data destination folder
data_dir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'Data_pez3000'];

% computer-specific information
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
funcFull = mfilename('fullpath');
funcPath = fileparts(funcFull);
cd(funcPath)
switch comp_name
    
    %%% pez3001 %%%
    case 'peekm-ww4'
        % in multi screen setup, this determines which screen to be used
        screen2use = 1;
        cameraIP = '192.168.0.10';
        comRef = 'COM7';
        devID = 'Dev2';
        pezName = 'pez3001';
        hostIP = '169.254.111.59';
        portNum = 21566;
        posOpen = 82;
        posBlock = 90;
        activationBool = true;
        defaultLightIntensity = 20;
    %%% pez3002 %%%
    case 'cardlab-ww10'
        screen2use = 2;
        cameraIP = '192.168.0.10';
        comRef = 'COM4';
        devID = 'Dev1';
        pezName = 'pez3002';
        hostIP = '169.254.71.206';
        portNum = 21566;
        posOpen = 85;
        posBlock = 88;
        activationBool = false;
        defaultLightIntensity = 20;
    %%% pez3003 %%%
    case 'cardlab-ww11'
        screen2use = 2;
        cameraIP = '192.168.0.10';
        comRef = 'COM5';
        devID = 'Dev2';
        pezName = 'pez3003';
        hostIP = '10.103.40.44';
        portNum = 21566;
        posOpen = 82;
        posBlock = 88;
        activationBool = true;
        defaultLightIntensity = 30;
    otherwise
        screen2use = 2;
        cameraIP = '192.168.0.10';
        comRef = 'COM5';
        devID = 'Dev2';
        pezName = 'pez3003';
        hostIP = '10.103.40.44';
        portNum = 21566;
        posOpen = 82;
        posBlock = 88;
        activationBool = true;
        defaultLightIntensity = 30;
        
end

% portion of the screen to cover
screen2cvr = 0.9;

funcFull = mfilename('fullpath');
funcPath = fileparts(funcFull);
snapDir = fullfile(funcPath,'Captured_Images');
if ~isdir(snapDir), mkdir(snapDir), end

%%%%%%%%%%%%%% Main GUI uicontrol objects %%%%%%%%%%%%%%%%%
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];%input center(x,y) and size(x,y)
monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);

% Color standards
backC = [0.8 0.8 0.8];
editC = [.85 .85 .85];
logoC = [0 0 0];
bhC = [.7 .7 .74];

%%%% Main GUI Figure %%%%%
FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
    (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
% FigPos(2) = FigPos(2)-scrnPos(4);
hFigA = figure('NumberTitle','off','Name','flyPez3000 CONTROL MODULE - WRW',...
    'menubar','none','Visible','off',...
    'units','pix','Color',[0.05 0 0.25],'pos',FigPos,'colormap',gray(256));
if isempty(mfilename)
    set(hFigA,'Visible','on')
end
%Experiment display panel
hAxesA = axes('Parent',hFigA,'Position',guiPosFun([.78 .5],[.4 .96]),...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[]);
hAxesT = axes('Parent',hFigA,'Position',[.8 .8 .2 .2],...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'Visible','off');

% Main panels
hPanelsMain = uipanel('Position',[0.015,0.02,0.55,0.96],...
    'Units','normalized','backgroundcolor',backC);

%Logo
pezControlLogoFun

%%%%% Control panels %%%%%
panStr = {'flyPez','Camera','Experiment Control'};
posOps = [.01 .14 .64 .85
    .66 .35 .33 .64
    .01 .01 .98 .12];
hCtrlPnl = zeros(3,1);
for iterC = 1:3
    hCtrlPnl(iterC) = uipanel('Parent',hPanelsMain,'Title',panStr{iterC},...
        'Position',posOps(iterC,:),...
        'FontSize',12,'fontunits','normalized','backgroundcolor',backC);
end

%%%%% Message Panel
hMsgPnl = uipanel('Parent',hPanelsMain,'Position',[.66 .14 .33 .2],...
    'FontSize',10,'fontunits','normalized','backgroundcolor',backC,'Title','Message Board');
msgString = {'I have nothing to say','at this time.'};
hTxtMsgA = uicontrol(hMsgPnl,'style','text','string',msgString,...
    'fontsize',10,'backgroundcolor',backC,'units','normalized','fontunits',...
    'normalized','position',[.01 .75 .98 .2],'foregroundcolor',[0.6 0 0]);
hTxtMsgB = uicontrol(hMsgPnl,'style','text','string','Camera Info',...
    'fontsize',10,'backgroundcolor',editC,'units','normalized','fontunits',...
    'normalized','position',[.05 .01 .9 .7],'foregroundcolor',[0 0 .6],...
    'horizontalalignment','left');

%%%%Experiment Panel
%experiment 'edit' controls
editStrCell = {'Experiment Designer','Experiment Manager','Experiment ID',...
    'Manager Notes','Runtime (minutes)','Download Options'};
hCt = numel(editStrCell);
hNames = {'designer','manager','experiment',...
    'managernotes','duration','downloadops'};
hExptEntry = struct;
posOpsLabel = [.01 .65 .13 .2
    .01 .35 .13 .2
    .01 .05 .13 .2
    .76 .8 .2 .22
    .32 .73 .11 .2
    .53 .8 .15 .2];
posOpsEdit = [.15 .65 .15 .23
    .15 .35 .15 .23
    .15 .05 .15 .23
    .76 .05 .23 .77
    .43 .74 .05 .23
    .53 .55 .18 .23];
for iterG = 1:hCt
    uicontrol(hCtrlPnl(3),'Style','text',...
        'string',editStrCell{iterG},'Units','normalized',...
        'HorizontalAlignment','left','position',posOpsLabel(iterG,:),...
        'fontsize',8,'fontunits','normalized','BackgroundColor',backC);
    hExptEntry.(hNames{iterG}) = uicontrol(hCtrlPnl(3),'Style',...
        'edit','Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',[],...
        'position',posOpsEdit(iterG,:),'backgroundcolor',editC);
    set(hExptEntry.(hNames{iterG}),'fontunits','normalized')
end
set(hExptEntry.managernotes,'max',2)
downloadStrCell = {'Save Cut Rate','Save Full Rate','Restricted full rate'};
set(hExptEntry.downloadops,'Style','popupmenu','string',downloadStrCell);
userPath = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables\Saved_User_names.mat';
if exist(userPath,'file')
    userLoading = load(userPath);
    Saved_User_names = userLoading.Saved_User_names;
    saved_variable = Saved_User_names.User_ID;
    set(hExptEntry.manager,'Style','popupmenu','string',saved_variable,...
        'value',find(strcmp('Breadsp',saved_variable)))
end

posOp = [.32 .46 .18 .25
    .32 .05 .08 .3
    .4 .05 .08 .3
    .48 .05 .08 .3
    .56 .05 .08 .3
    .64 .05 .08 .3];
styleOp = {'checkbox','pushbutton','pushbutton',...
    'pushbutton','pushbutton','pushbutton'};
strOp = {'Auto discard','Run','Extend','Pause','Stop','Resume'};
hName = {'autodiscard','run','extend','pause','stop','resume'};
ctrlCt = numel(hName);
hExptCtrl = struct;
for iterG = 1:ctrlCt
    hExptCtrl.(hName{iterG}) = uicontrol(hCtrlPnl(3),'Style',styleOp{iterG},...
        'Units','normalized','HorizontalAlignment','center','fontsize',8,...
        'string',strOp{iterG},'fontunits','normalized','position',...
        posOp(iterG,:),'backgroundcolor',backC);
end
set(hExptCtrl.pause,'enable','off')
set(hExptCtrl.stop,'enable','off')
set(hExptCtrl.extend,'enable','off')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Camera panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define spatial options
yBlox = 104;
Yops = fliplr(linspace(1/yBlox,1,yBlox));
H = 1/yBlox;

%Headings
headStrCell = {'Frame','Setup','Record'};
headStrCt = numel(headStrCell);
panelY = Yops([17 43 104]);
panelH = [15 25 49];
hCamSubPnl = zeros(headStrCt,1);
for iterH = 1:headStrCt
    panelPos = [0.025 panelY(iterH) 0.95 panelH(iterH)*H];
    hCamSubPnl(iterH) = uipanel(hCtrlPnl(2),'HitTest','off',...
        'Position',panelPos,'BackgroundColor',backC);
end
set(hCamSubPnl(3),'Title','Recording','fontsize',10)
hd1posA = get(hCamSubPnl(1),'position');
hd1posB = [hd1posA(1)+0.2,hd1posA(2),hd1posA(3)-0.2,hd1posA(4)];
set(hCamSubPnl(1),'position',hd1posB)
masterCamera = uicontrol(hCtrlPnl(2),'style','togglebutton','units','normalized',...
    'string','Off','Position',[hd1posA(1),hd1posA(2),0.2,hd1posA(4)],...
    'fontsize',12,'fontunits','normalized','backgroundcolor',backC);

%%camera controls
hCamStates = struct;
hCamStates.parent = uibuttongroup('parent',hCtrlPnl(2),'position',...
    [0.025 Yops(53) 0.95 H*8],'backgroundcolor',backC,...
    'Title','Camera Mode Control','fontsize',10,'fontunits','normalized');
btnH = 1;
btnW = 1/3;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
btnNames = {'Live','Stop','Record'};
for iterStates = 1:3
    hCamStates.children(iterStates) = uicontrol(hCamStates.parent,...
        'style','togglebutton','units','normalized',...
        'string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end


% Camera Popup menus
camStrCell = {'Width','Height','Rec Rate','Shutter Speed','Bit Shift',...
    'Partition Count','Trigger Mode','Compression Method','Partition'};
camStrCt = numel(camStrCell);
hCamFields = {'width','height','recrate','shutter','bitshift',...
    'partcount','trigmode','compressmethod','partition'};
hCamPop = struct;
hCamParents = [1,1,1,2,2,2,2,2,3];
posOpsLabels = [.05 .75 .25 .15
    .35 .75 .25 .15
    .65 .75 .3 .15
    .45 .82 .4 .13
    .05 .82 .4 .13
    .05 .49 .4 .13
    .45 .49 .4 .13
    .45 .17 .5 .13
    .05 .39 .4 .08];
posOpsPops = [.05 .5 .27 .15
    .35 .5 .27 .15
    .65 .5 .3 .15
    .45 .72 .5 .1
    .05 .72 .35 .1
    .05 .39 .35 .1
    .45 .39 .5 .1
    .45 .07 .5 .1
    .28 .4 .3 .1];
for iterS = 1:camStrCt
    uicontrol(hCamSubPnl(hCamParents(iterS)),'Style','text',...
        'string',[' ' camStrCell{iterS} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',posOpsLabels(iterS,:),...
        'fontsize',8,'fontunits','normalized','BackgroundColor',backC);
    hCamPop.(hCamFields{iterS}) = uicontrol(hCamSubPnl(hCamParents(iterS)),'Style',...
        'popupmenu','Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string','...',...
        'position',posOpsPops(iterS,:),'backgroundcolor',editC);
    set(hCamPop.(hCamFields{iterS}),'fontunits','normalized')
end
set(hCamPop.bitshift,'String',{'0','1','2','3','4'},'Value',3)
set(hCamPop.trigmode,'String',{'START','CENTER','END','MANUAL'},'Value',1)
% save modes
listCompress = {'MPEG-4 (high-quality, compressed)','Grayscale AVI (uncompressed)'};
set(hCamPop.compressmethod,'string',listCompress)
    

%%Camera panel buttons
btnStrCell = {'Revert Old','Apply New','Calibrate',...
    'Snapshot','Trigger','Review','Download'};
btnStrCt = numel(btnStrCell);
hCamBtns = struct;
hNames = {'display','apply','calib','snap','trig',...
    'review','download'};
hParents = [1,1,2,3,3,3,3];
posOps = [.05 .05 .4 .25
    .55 .05 .4 .25
    .05 .05 .35 .2
    .65 .42 .3 .1
    .05 .26 .3 .1
    .35 .26 .3 .1
    .65 .26 .3 .1];
for iterB = 1:btnStrCt
    hCamBtns.(hNames{iterB}) = uicontrol(hCamSubPnl(hParents(iterB)),...
        'style','pushbutton','units','normalized',...
        'string',btnStrCell{iterB},'Position',posOps(iterB,:),...
        'fontsize',8,'fontunits','normalized','backgroundcolor',backC);
end
set(hCamBtns.trig,'enable','off')
set(hCamBtns.review,'enable','off')
set(hCamBtns.download,'enable','off')
        
%%playback controls
iconshade = 0.3;
hCamPlayback = struct;
hCamPlayback.parent = uibuttongroup('parent',hCamSubPnl(3),'position',...
    guiPosFun([.5 .17],[.95 .12]),'backgroundcolor',backC);
btnH = 1;
btnW = 1/7;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hCamPlayback.children = zeros(7,1);
btnIcons = {'frev','rev','slowrev','stop','slowfwd','fwd','ffwd'};
for iterBtn = 1:7
    hCamPlayback.children(iterBtn) = uicontrol(hCamPlayback.parent,'style',...
        'togglebutton','units','normalized','string',[],'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterBtn-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',15,'fontunits','normalized','backgroundcolor',backC,...
        'enable','inactive','HandleVisibility','off');
    makePezIcon(hCamPlayback.children(iterBtn),0.7,btnIcons{iterBtn},iconshade,backC)
end
speedOps = [3,30,120];
speedOps = [fliplr(speedOps).*(-1) 0 speedOps];
set(hCamPlayback.parent,'SelectedObject',[])

hCamPlaybackSlider = uicontrol('Parent',hCamSubPnl(3),'Style','slider',...
    'Units','normalized','Min',0,'Max',100,'enable','inactive',...
    'Position',guiPosFun([.5 .06],[.95 .08]),'Backgroundcolor',backC);

%%camera edit controls
trigStrCell = {[],'Frames Pre/Post:',[],'Time Pre/Post:',...
    'Frames Available','Time Available'};
trigStrCt = numel(trigStrCell);
hNames = {'beforetrig','aftertrig','durbefore','durafter','frminmem','durinmem'};
hCamEdit = struct;
hParents = [3,3,3,3,3,3];
posOpsLabel = [.05 .67 .35 .08
    .05 .67 .35 .08
    .05 .55 .35 .08
    .05 .55 .35 .08
    .05 .9 .4 .08
    .55 .9 .4 .08];
posOpsEdit = [.4 .7 .25 .08
    .7 .7 .25 .08
    .4 .57 .25 .08
    .7 .57 .25 .08
    .05 .825 .4 .08
    .55 .825 .4 .08];
for iterG = 1:trigStrCt
    uicontrol(hCamSubPnl(hParents(iterG)),'Style','text',...
        'fontsize',8,'string',trigStrCell{iterG},'Units','normalized',...
        'HorizontalAlignment','left','position',posOpsLabel(iterG,:),...
        'BackgroundColor',backC,'fontunits','normalized');
%     'BackgroundColor',backC,'fontunits','normalized');
    hCamEdit.(hNames{iterG}) = uicontrol(hCamSubPnl(hParents(iterG)),'Style',...
        'edit','Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',[],...
        'position',posOpsEdit(iterG,:),'backgroundcolor',editC);
    set(hCamEdit.(hNames{iterG}),'fontunits','normalized')
end
set(hCamEdit.frminmem,'enable','inactive','backgroundcolor',backC)
set(hCamEdit.durinmem,'enable','inactive','backgroundcolor',backC)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% flyPez Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setTemp = 22;
lightInit = 0;
shadow = 225;
gap = 2;
ellovervee = 40;
aziVal = 0;
aziOffVal = 0;
eleVal = 45;
radiusBegin = 10;
radiusEnd = 180;
tempMCU = 22;
humidMCU = 50;
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radius_begin',radiusBegin,'radius_end',radiusEnd,'stimulus_duration',[]);

%Define spatial options
xBlox = 62;
yBlox = 108;
Xops = linspace(1/xBlox,1,xBlox);
Yops = fliplr(linspace(1/yBlox,1,yBlox));
W = 1/xBlox;
H = 1/yBlox;

%Headings
headStrCell = {'Environment','Mechanics','Camera & Projector Management'};
headStrCt = numel(headStrCell);
headYops = [6 19 59];
for iterH = 1:headStrCt
    labelPos = [W,Yops(headYops(iterH)) W*60 H*3];
    uicontrol(hCtrlPnl(1),'Style','text',...
        'string',['  ' headStrCell{iterH}],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'fontunits','normalized','BackgroundColor',bhC,...
        'foregroundcolor',logoC);
end

%Gate plots
pezAxesPos = [Xops(14) Yops(headYops(2)+34) W*46 H*9];
hAxesPez = axes('xtick',[],'ytick',[],'xticklabel',[],...
    'yticklabel',[],'xlim',[1 128],'ylim',[0 275],...
    'position',pezAxesPos,'nextplot','add','parent',hCtrlPnl(1));
hPlotGate = struct;
hNames = {'data','shadow','start','end','gap'};
colorGate = {'k','b','r','r','k'};
for iterGate = 1:numel(hNames)
    hPlotGate.(hNames{iterGate}) = plot(1,1,'linewidth',1,'color',...
        colorGate{iterGate},'parent',hAxesPez);
end
set(hPlotGate.data,'linewidth',2)
set(hPlotGate.shadow,'XData',0:127,'YData',repmat(shadow,1,128))

% flyPez subpanels
pezStrCell = {'Temp','Humidity','Cooling Pwr','IR Lights',...
    'Photoactivation','Sweeper','Gate Control','Gate Calibration',...
    'ROI & Focus','Fly Count','Fly Detect','Visual Stimulus',...
    'Target'};
pezStrCt = numel(pezStrCell);
hSubPnl = zeros(pezStrCt,1);
posOp = [Xops(1) Yops(headYops(1)+7) W*10 H*6
    Xops(21) Yops(headYops(1)+7) W*9 H*6
    Xops(30) Yops(headYops(1)+7) W*11 H*6
    Xops(41) Yops(headYops(1)+7) W*20 H*6
    Xops(1) Yops(headYops(3)+49) W*60 H*15
    Xops(1) Yops(headYops(2)+14) W*12 H*13
    Xops(13) Yops(headYops(2)+14) W*36 H*13
    Xops(13) Yops(headYops(2)+24) W*48 H*9
    Xops(1) Yops(headYops(3)+33) W*16 H*32
    Xops(49) Yops(headYops(2)+14) W*12 H*13
    Xops(17) Yops(headYops(3)+33) W*15 H*32
    Xops(32) Yops(headYops(3)+33) W*29 H*32
    Xops(11) Yops(headYops(1)+7) W*10 H*6];
for iterG = 1:pezStrCt
    hSubPnl(iterG) = uipanel(hCtrlPnl(1),'HitTest','off','FontSize',10,...
        'Title',pezStrCell{iterG},'FontUnits','Normalized',...
        'TitlePosition','lefttop','Position',posOp(iterG,:),...
        'BackgroundColor',backC);
    
end

% pez text only
posOp = {[.55 .1 .4 .7],[.1 .1 .9 .7],[.1 .1 .9 .7],[.1 .1 .9 .7],...
    [.8 .1 .15 .7],[.05 .47 .3 .4],[.05 .07 .3 .4],[.4 .5 .3 .4],...
    [.4 .1 .3 .4],[.1 .45 .8 .45],[.05 .69 .25 .1],[.5 .69 .3 .1],...
    [.5 .56 .3 .1],[.5 .43 .3 .1],[.7 .15 .27 .1],[.1 .675 .6 .1],...
    [.05 .56 .25 .1],[.05 .43 .25 .1]};
hP = [13 1 2 3 4 8 8 8 8 10 12 12 12 12 12 9 12 12];
strOp = {'deg C'
    'XX.X deg C'
    'XX.X%'
    'XXX% power'
    [num2str(lightInit) '%']
    'Shadow:'
    'Gap:'
    'Open: XXX%'
    'Block: XXX%'
    'Click reset to enable'
    'l/v :'
    'Elevation :'
    'Azimuth Offset:'
    'Fly Heading :'
    'Duration (ms)'
    'Auto threshold:'
    'Radius begin:'
    'Radius end:'};
hName = {'target','temp','humid','fanpwr','IRlights','shadow','gap',...
    'openpos','closepos','flycount','loverv','ele','aziOff','aziFly',...
    'stimdur','autothresh','radiusbegin','radiusend'};
ctrlCt = numel(hP);
hPezReport = struct;
for iterG = 1:ctrlCt
    hPezReport.(hName{iterG}) = uicontrol(hSubPnl(hP(iterG)),'Style','text',...
        'Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',strOp{iterG},'fontunits','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
end

% Photoactivation panel
hWH = [.16 .18];
posOp = [.02 .1
    .02 .7
    .25 .7
    .02 .4
    .25 .4
    .74 .7
    .74 .4
    .74 .1];
strOp = {'Cycles:'
    'Time High(ms):'
    'Power High(%):'
    'Time Low(ms):'
    'Power Low(%):'
    'Power Begin(%):'
    'Power End(%):'
    'Duration(ms):'};
hName = {'cycles','timehigh','powerhigh','timelow','powerlow','powerbegin',...
    'powerend','duration'};
ctrlCt = numel(hName);
hPezActivation = struct;
for iterG = 1:ctrlCt
    hPezActivation.(hName{iterG}) = uicontrol(hSubPnl(5),'Style','text',...
        'Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',strOp{iterG},'fontunits','normalized',...
        'position',[posOp(iterG,:) hWH],'backgroundcolor',backC);
end

photo = struct('Cycles',10,'TimeHigh',100,'PowerHigh',20,'TimeLow',900,...
    'PowerLow',0,'PowerBegin',0,'PowerEnd',50,'Duration',2000,'PowerStep',2.381);
hWH = [.08 .23];
posOp = [.1 .1
    .16 .7
    .4 .7
    .16 .4
    .4 .4
    .9 .7
    .9 .4
    .9 .1];
strOp = {num2str(photo.Cycles)
    num2str(photo.TimeHigh)
    num2str(photo.PowerHigh)
    num2str(photo.TimeLow)
    num2str(photo.PowerLow)
    num2str(photo.PowerBegin)
    num2str(photo.PowerEnd)
    num2str(photo.Duration)};
hPezActivationEdit = struct;
for iterG = 1:ctrlCt
    hPezActivationEdit.(hName{iterG}) = uicontrol(hSubPnl(5),'Style','edit',...
        'Units','normalized','HorizontalAlignment','center','fontsize',8,...
        'string',strOp{iterG},'fontunits','normalized','position',...
        [posOp(iterG,:) hWH],'backgroundcolor',editC);
end

% Photoactivation options
hPhotoMode = struct;
hPhotoMode.parent = uibuttongroup('parent',hSubPnl(5),'position',...
    [.5 .4 .22 .63],'backgroundcolor',backC);
btnNames = {'Square Wave','Linear Ramp'};
btnCt = numel(btnNames);
posOps = {[.05 .5 .9 .45],[.05 .05 .9 .45]};
hPhotoMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hPhotoMode.child(iterStates) = uicontrol(hPhotoMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
activationInfo = struct;
visStimInfo = struct;


% simple controls with callbacks other than pushbuttons
posOp = {[.1 .1 .4 .8],[.2 .5 .1 .4],[.2 .1 .1 .4],[.2 .15 .6 .15],...
    [.1 .825 .8 .125],[.1 .85 .8 .125],[.1 .75 .8 .125],[.1 .65 .8 .125],...
    [.3 .71 .15 .1],[.8 .71 .15 .1],[.8 .58 .15 .1],[.8 .45 .15 .1],...
    [.7 .05 .24 .1],[.05 .15 .65 .1],[.05 .05 .65 .1],[.65 .7 .25 .1],...
    [.2 .08 .31 .2],[.3 .58 .15 .1],[.3 .45 .15 .1]};
hP = [13 8 8 9 9 11 11 11 12 12 12 12 12 12 12 9 5 12 12];
styleOp = {'edit','edit','edit','checkbox','togglebutton','checkbox',...
    'checkbox','checkbox','edit','edit','edit','edit','edit',...
    'checkbox','checkbox','edit','checkbox','edit','edit'};
strOp = {num2str(setTemp)
    num2str(shadow)
    num2str(gap)
    'Display ROI'
    'Show Background'
    'Engage Fly Detect'
    'Run Autopilot'
    'Show Overlay'
    num2str(ellovervee)
    num2str(eleVal)
    num2str(aziOffVal)
    num2str(aziVal)
    '...'
    'Alternate azimuth left vs right'
    'Display when camera triggers'
    num2str(0.5)
    'Execute when camera triggers'
    num2str(radiusBegin)
    num2str(radiusEnd)};
ctrlCt = numel(hP);
hName = {'target','shadow','gap','roi','showback','flydetect','runauto','annotate',...
    'eloverv','ele','aziOff','aziFly','stimdur','alternate','couple',...
    'autothresh','photocouple','radiusbegin','radiusend'};
hPezRandom = struct;
for iterG = 1:ctrlCt
    hPezRandom.(hName{iterG}) = uicontrol(hSubPnl(hP(iterG)),'Style',styleOp{iterG},...
        'Units','normalized','HorizontalAlignment','center','fontsize',8,...
        'string',strOp{iterG},'fontunits','normalized','position',...
        posOp{iterG},'backgroundcolor',backC);
    if strcmp(styleOp{iterG},'edit')
        set(hPezRandom.(hName{iterG}),'backgroundcolor',editC)
    end
end
set(hPezRandom.stimdur,'enable','inactive','backgroundcolor',backC)
roiSubPanel = hSubPnl(9);

% pezSliders
posOp = {[.1 .2 .65 .56],[.6 .6 .35 .3],...
    [.6 .2 .35 .3]};
hP = [4 8 8];
pezSlideCt = numel(posOp);
pezSlideVals = [lightInit,0,0];
hNames = {'IRlights','open','block'};
hPezSlid = struct;
for iterSD = 1:pezSlideCt
    hPezSlid.(hNames{iterSD}) = uicontrol('Parent',hSubPnl(hP(iterSD)),'Style','slider',...
        'Units','normalized','Min',0,'Max',50,'Value',pezSlideVals(iterSD),...
        'Position',posOp{iterSD},'Backgroundcolor',backC);
end

% pezButtons
posOp = {[.1 .51 .8 .4],[.1 .1 .8 .4],[.1 .55 .25 .35],[.1 .425 .8 .125],...
    [.1 .3 .8 .125],[.1 .025 .8 .125],[.1 .1 .8 .35],...
    [.05 .29 .45 .12],[.5 .29 .45 .12],[.1 .6 .4 .08],[.5 .6 .4 .08],...
    [.52 .07 .18 .23]};
hP = [6 6 7 9 9 9 10 12 12 9 9 5];
strOp = {'Calibrate','Sweep','Find Gates','Auto ROI','Manual ROI',...
    'Fine Focus','Reset','Initialize','Display','More','Less','Execute'};
ctrlCt = numel(hP);
hNames = {'calib','sweep','findgates','autoroi','manualroi',...
    'finefoc','reset','initialize','display','more','less','photodisplay'};
hPezButn = struct;
for iterG = 1:ctrlCt
    hPezButn.(hNames{iterG}) = uicontrol(hSubPnl(hP(iterG)),'Style','pushbutton',...
        'fontsize',8,'string',strOp{iterG},'units','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
    set(hPezButn.(hNames{iterG}),'fontunits','normalized')
end
set(hPezButn.finefoc,'Style','togglebutton')

% Gate auto versus manual
hGateMode = struct;
hGateMode.parent = uibuttongroup('parent',hSubPnl(7),'position',...
    [.425 .55 .5 .4],'backgroundcolor',backC);
btnNames = {'Manual Block','Auto Block'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hGateMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hGateMode.child(iterStates) = uicontrol(hGateMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end

% pez communication on or off
hPezMode = struct;
pezmodepos = [Xops(1) Yops(headYops(2)+34) W*12 H*19];
hPezMode.parent = uibuttongroup('parent',hCtrlPnl(1),'position',...
    pezmodepos,'backgroundcolor',backC,'title','Com Control',...
    'fontsize',10,'fontunits','normalized');
btnNames = {'On','Off'};
btnCt = numel(btnNames);
btnH = 0.25;
btnW = 1;
btnXinit = 0.55;
btnXstep = btnH;
btnY = 0.5;
hPezMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hPezMode.child(iterStates) = uicontrol(hPezMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnY btnXinit+(btnXstep*(iterStates-1))],[btnW btnH]*0.8),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
hPezButn.controlreset = uicontrol(hPezMode.parent,'Style','pushbutton',...
    'fontsize',8,'string','Hard Reset','units','normalized',...
    'position',[0.1 0.05 0.8 0.3],'backgroundcolor',backC,...
    'fontunits','normalized');

% Manually Selecting Gate Mode
hGateState = struct;
hGateState.parent = uibuttongroup('parent',hSubPnl(7),'position',...
    [.01 .01 .98 .45],'backgroundcolor',backC);
btnNames = {'Open','Block','Close','Clean'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hGateState.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hGateState.child(iterStates) = uicontrol(hGateState.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
set(hGateState.parent,'SelectedObject',hGateState.child(1));

% Trigger on single versus escape
hTrigMode = struct;
hTrigMode.parent = uibuttongroup('parent',hSubPnl(11),'position',...
    [.025 .26 .95 .37],'backgroundcolor',backC,'Title','Trigger on');
btnNames = {'Ready','Escaped'};
btnCt = numel(btnNames);
posOps = {[.05 .5 .9 .45],[.05 .1 .9 .45]};
hTrigMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hTrigMode.child(iterStates) = uicontrol(hTrigMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end

% Fly detect status report
hDetectReadout = struct;
detectPanel = uipanel('parent',hSubPnl(11),'position',...
    [.025 .01 .95 .2],'backgroundcolor',backC,'Title','Fly Status');
hDetectReadout.options = {'Searching','In View','Ready','Escaped'};
hDetectReadout.textbox = uicontrol(detectPanel,'style','edit',...
    'Units','normalized','HorizontalAlignment','center','enable','inactive',...
    'fontsize',8,'string',hDetectReadout.options{1},'fontunits','normalized',...
    'position',[.05 .05 .9 .9],'backgroundcolor',backC);

% Visual stimulus popmenu
stimStrOps = {'Looming disk',...
    'Stimulus from file','Crosshairs',...
    'Calibration','Grid','Full on','Full off','RGB Order test',...
    'Disk Size Measurement'};
visStimPop = uicontrol(hSubPnl(12),'style','popupmenu','units','normalized',...
    'position',[.05 .825 .4 .125],'string',stimStrOps,'fontunits','normalized');
whiteCt = [];
initVersion = 'na';
set(hPezRandom.aziFly,'enable','inactive');
set(hPezButn.display,'enable','off');
stimFiles = dir('\\dm11\cardlab\pez3000_variables\visual_stimuli');
stimFiles = {stimFiles(:).name};
fileStimPop = uicontrol(hSubPnl(12),'style','popupmenu','units','normalized',...
    'position',[.5 .825 .45 .125],'string',stimFiles,'fontunits','normalized');

%%
set(hExptCtrl.run,'callback',@runexptCallback)
set(hExptCtrl.extend,'callback',@extendexptCallback)
set(hExptCtrl.pause,'callback',@pauseexptCallback)
set(hExptCtrl.stop,'callback',@stopexptCallback)
set(hExptCtrl.resume,'callback',@resumeExptCallback)
set(hExptEntry.managernotes,'callback',@savenotesCallback)
set(hExptEntry.experiment,'callback',@experimentIdCallback)

set(masterCamera,'Callback',@masterCameraToggle)
set(hCamBtns.display,'callback',@dispCurrentSettings)
set(hCamBtns.apply,'callback',@applyNewSettings)
set(hCamBtns.calib,'callback',@calibrateCallback)
set(hCamBtns.snap,'callback',@captureSingleCallback)
set(hCamBtns.trig,'callback',@triggerCallback)
set(hCamBtns.review,'callback',@reviewMemoryCallback)
set(hCamBtns.download,'callback',@downloadRecordingCallback)
set(hCamPop.shutter,'callback',@shutterSpeedCallback)
set(hCamPop.bitshift,'callback',@bitshiftCallback)
set(hCamPop.trigmode,'callback',@triggerModeCallback)
set(hCamPop.partcount,'callback',@partcountCallback)
set(hCamPop.partition,'callback',@partitionCallback)
set(hCamStates.parent,'SelectionChangeFcn',@camStateCallback)
set(hCamStates.parent,'SelectedObject',hCamStates.children(1))
set(hCamEdit.beforetrig,'callback',@framesEditCallback)
set(hCamEdit.aftertrig,'callback',@framesEditCallback)
set(hCamEdit.durbefore,'callback',@durationEditCallback)
set(hCamEdit.durafter,'callback',@durationEditCallback)
set(hCamPlaybackSlider,'callback',@playbackSliderCallback)
set(hCamPlayback.parent,'SelectionChangeFcn',@playbackButtonsCallback)
hJScrollBar = findjobj(hCamPlaybackSlider);
hJScrollBar.MousePressedCallback = @PosClickCallback;
hJScrollBar.MouseReleasedCallback = @PosReleaseCallback;
hJScrollBar.MouseWheelMovedCallback = @PosWheelCallback;

set(hPezActivationEdit.cycles,'callback',@squareWaveEditCallback)
set(hPezActivationEdit.timehigh,'callback',@squareWaveEditCallback)
set(hPezActivationEdit.powerhigh,'callback',@squareWaveEditCallback)
set(hPezActivationEdit.timelow,'callback',@squareWaveEditCallback)
set(hPezActivationEdit.powerlow,'callback',@squareWaveEditCallback)
set(hPezActivationEdit.powerbegin,'callback',@linearRampEditCallback)
set(hPezActivationEdit.powerend,'callback',@linearRampEditCallback)
set(hPezActivationEdit.duration,'callback',@linearRampEditCallback)
set(hPezRandom.shadow,'callback',@hshadowth)
set(hPezRandom.gap,'callback',@hgapth)
set(hPezRandom.roi,'callback',@hDispROICall)
set(hPezRandom.showback,'callback',@highlightBackground)
set(hPezRandom.flydetect,'callback',@setFlydetectCall)
set(hPezRandom.runauto,'callback',@runAutoPilotCall)
set(hPezRandom.annotate,'callback',@overlayAnnotationsCall)
set(hPezRandom.couple,'callback',@coupleToCameraCall)
set(hPezRandom.photocouple,'callback',@coupleToCameraCall)
set(hPezRandom.target,'callback',@setTemperature)
set(hGateMode.parent,'SelectionChangeFcn',@hAutoButtonCallback);
set(hGateState.parent,'SelectionChangeFcn',@gateSelectCallback);
set(hPezButn.calib,'callback',@hCalibrate)
set(hPezButn.sweep,'callback',@hSweepGateCallback)
set(hPezButn.findgates,'callback',@hFindButtonCallback)
set(hPezButn.autoroi,'callback',@hAutoSetROI)
set(hPezButn.manualroi,'callback',@hManualSetROI)
set(hPezButn.finefoc,'callback',@focusFeedback)
set(hPezButn.reset,'callback',@flyCountCallback)
set(hPezButn.initialize,'callback',@initializeVisStim)
set(hPezButn.display,'callback',@displayVisStim)
set(hPezButn.more,'callback',@moreThreshCall)
set(hPezButn.less,'callback',@lessThreshCall)
set(hPezButn.photodisplay,'callback',@photoDisplayCall)
set(hPezButn.controlreset,'callback',@controllerResetCall)
set(hPezSlid.IRlights,'callback',@IRlightsCallback)
set(hPezSlid.open,'callback',@hOpen1Callback)
set(hPezSlid.block,'callback',@hOpen1Callback)
set(visStimPop,'callback',@visStimCallback)
set(hTrigMode.parent,'SelectionChangeFcn',@hTrigSelectCallback)
set(hPezMode.parent,'SelectionChangeFcn',@pezMonitorFun)

%%%% Fly Detect Setup %%%%
template_dir = fullfile(funcPath,'pez3000_templates');
tmplName = 'template_flyDetect.mat';
tmplLoading = load(fullfile(template_dir,tmplName));
tmplGeno = tmplLoading.geno;
tmplLeg = (tmplGeno.source_dim-1)/2;
hortRefs = tmplGeno.hort_refs;
dwnFac = tmplGeno.dwnsampl_factor;

initTmpl = tmplGeno.template_3D;
initNdxr = tmplGeno.indexer_3D;
rotOpsTmpl = size(initTmpl,2);
spokeL = size(initTmpl,1)/rotOpsTmpl;
sizeCt = size(initTmpl,3);
preTmpl = reshape(initTmpl(:,1,:),spokeL,rotOpsTmpl,sizeCt);
preTmpl = squeeze(mean(preTmpl,2));
preNdxR = reshape(initNdxr(:,1,:),spokeL,rotOpsTmpl,sizeCt);
preNdxT = preNdxR;
preReNdxR = repmat((1:sizeCt),spokeL,1);
preReNdxT = preReNdxR;

headTmplB = initTmpl(:,:,(hortRefs == 1));
layerFindr = repmat((1:size(headTmplB,3)),size(headTmplB,2),1);
layerFindr = layerFindr(:)';
headTmplA = reshape(headTmplB,size(headTmplB,1),size(headTmplB,2)*size(headTmplB,3));
tailTmplB = initTmpl(:,:,(hortRefs == 2));
tailTmplA = reshape(tailTmplB,size(tailTmplB,1),size(tailTmplB,2)*size(tailTmplB,3));

headNdxrB = initNdxr(:,:,(hortRefs == 1));
headNdxrA = reshape(headNdxrB,size(headNdxrB,1),size(headNdxrB,2)*size(headNdxrB,3));
tailNdxrB = initNdxr(:,:,(hortRefs == 2));
tailNdxrA = reshape(tailNdxrB,size(tailNdxrB,1),size(tailNdxrB,2)*size(tailNdxrB,3));
reNdxrPost = ones(size(tailNdxrA,1),1);

tmplName = 'template_flyDetect_hortRot.mat';
tmplLoading = load(fullfile(template_dir,tmplName));
tmplGeno = tmplLoading.geno;
initTmplRot = tmplGeno.template_3D;
rotOpsTmplRot = (1:size(initTmplRot,2));
rotOpsTmplRot = -(rotOpsTmplRot-1)*3*(pi/180);

headTmplRot = initTmplRot(:,:,(hortRefs == 1));
tailTmplRot = initTmplRot(:,:,(hortRefs == 2));

initNdxrRot = tmplGeno.indexer_3D;
headNdxrRot = initNdxrRot(:,:,(hortRefs == 1));
tailNdxrRot = initNdxrRot(:,:,(hortRefs == 2));
reNdxrRot = ones(size(tailNdxrRot,1),1);

xOpsEdges = {[]};
yOpsEdges = {[]};
smlDims = [];
flyTheta = 0;
roiPos = [];
detectTabs = 0;
rateCounter = 0;
tunnelFlyCt = [];
prismFlyCt = [];
gatePosMCU = [];
gateStateMCU = [];
gateBoundMCU =  [];
gateDataMCU = [];
htDataMCU = [];
inplineMCU = [];
exptInfo = [];
exptID = [];

%additional children
frmData = uint8(zeros(832,384));
backgrFrm = frmData;
hImA = image('Parent',hAxesA,'CData',frmData);
xROI = 0;
yROI = 0;
stagePos = 0;
set(hAxesA,'nextplot','add','YDir','reverse')
hPlotROI = plot(0,0,'Marker','.','Color',[0 0 0.8],...
    'Parent',hAxesA,'LineStyle','none');
hPlotPre = plot(0,0,'Parent',hAxesA,'LineStyle','none','visible','off');
hPlotPost = plot(0,0,'Parent',hAxesA,'LineStyle','none','visible','off');
set(hPlotPost,'Marker','o','MarkerFaceColor',[1 1 0],...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',4)
set(hPlotPre,'Marker','o','MarkerFaceColor',[0 0 1],...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',4)
hPlotH = plot(0,0,'Marker','*','Color',[0 1 0],'visible','off',...
    'Parent',hAxesA,'LineStyle','none','MarkerSize',15);
hPlotT = plot(0,0,'Marker','*','Color',[1 0 0],'visible','off',...
    'Parent',hAxesA,'LineStyle','none','MarkerSize',15);
u = cos(flyTheta).*tmplLeg*2+1;
v = -sin(flyTheta).*tmplLeg*2+1;
hQuivA = quiver(0,0,u,v,'MaxHeadSize',1,'LineWidth',1.5,...
    'AutoScaleFactor',1,'Color',[1 1 1],'Parent',hAxesA,'Visible','off');
set(hAxesA,'nextplot','replacechildren')


%% only run the following as a function!!!
%initialize timers
liveRate = 15;%times to be executed per second, i.e. live camera monitor
tPlay = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',round((1/liveRate)*100)/100,'StartDelay',1,'Name','tPlay');
tDet = timer('TimerFcn',@resetDetectFun,'ExecutionMode','fixedRate',...
    'Period',30,'StartDelay',30,'Name','tDet');
tExpt = timer('TimerFcn',@stopexptCallback,'StartDelay',20*60,'Name','tExpt');
tFun = timer('TimerFcn',@blankFun,'StartDelay',0.3,'Name','tFun');


runPath = [];
runFolder = [];
runStats = struct;
runStatsDest = [];

stageTab = zeros(6,1);

tMsg = timer('TimerFcn',@removeMsg,'StartDelay',5.0);
tPos = timer('TimerFcn',@playbackSliderCallback,'ExecutionMode','fixedRate',...
    'Period',0.3);

frmOps = [];
frmDelta = 1;
frmVecRef = [];
frmCount = [];

PDC = runSetPDCvalues;
nCam = struct;
varsNidaq = struct;
sNidaq = [];
sPez = [];


initStates = struct('camera',false,'controller',false,'flydetect',false,...
    'focus',false,'memplayback',false,'cameramonitor',false);
itemStates = struct('isAvail',initStates,'isRun',initStates,'shouldRun',initStates);

set(hFigA,'CloseRequestFcn',@myCloseFun)

disp('camStartupFun called')
camStartupFun
disp('camStartupFun passed')

%% Initialization functions
    function blankFun(~,~)
    end
    function camStartupFun
        visStimCallback
        try
            controllerResetCall
            linearRampEditCallback
            squareWaveEditCallback
            hFindButtonCallback
            itemStates.isRun.controller = true;
        catch
            itemStates.isRun.controller = false;
        end
        itemStates.shouldRun.cameramonitor = itemStates.isRun.cameramonitor;
        set(masterCamera,'value',1)
        toggleChildren(hCtrlPnl(2),0)
        masterCameraToggle
        if strcmp(tPlay.Running,'off'),start(tPlay),end
        set(hFigA,'Visible','on')
    end
    function masterCameraToggle(~,~)
        if get(masterCamera,'Value') == 1
            try
                openCamera
                dispCurrentSettings
                disp('applyNewSettings called')
                applyNewSettings
                disp('applyNewSettings passed')
                calibrateCallback
                messageFun('Camera is ready')
                disp('camStateCallback called')
                camStateCallback
                disp('camStateCallback passed')
                bitshiftCallback
                set(masterCamera,'string','On')
                toggleChildren(hCtrlPnl(2),1)
            catch
                messageFun('Camera open failure')
                set(masterCamera,'string','Off','value',0,'enable','on')
            end
        else
            try
                itemStates.isRun.cameramonitor = false;
                itemStates.shouldRun.cameramonitor = false;
                %undo highlight background if set because otherwise camera will
                %restart in wrong configuration
                if get(hPezRandom.showback,'Value') == 1
                    set(hPezRandom.showback,'Value',0)
                    highlightBackground
                end
                %reset the nidaq cleanly
                try
                    stop(sNidaq)
                    delete(varsNidaq.nidaqListener)
                    release(sNidaq)
                catch
                end
                %close the camera
                if ~isempty(nCam.DeviceNo)
                    [nRet,nErrorCode] = PDC_CloseDevice(nCam.DeviceNo);
                    if nRet == PDC.FAILED
                        disp(['CloseDevice Error ' int2str(nErrorCode)])
                    else
                        nCam.DeviceNo = [];
                    end
                end
                toggleChildren(hCtrlPnl(2),0)
                set(masterCamera,'string','Off','enable','on')
            catch
                set(masterCamera,'string','On','value',1)
                messageFun('Camera close failure')
            end
        end
    end
    function openCamera % Initializing and opening camera
        nCam.DeviceNo = pezControlOpenCamera(cameraIP,PDC);
        if isempty(nCam.DeviceNo)
            messageFun('Camera was not opened');
            return
        end
        [nRet, nErrorCode] = PDC_SetStorePreset(nCam.DeviceNo,1);
        errorCodeTest(nRet,nErrorCode)
        % get device properties
        nCam.nChildNo = 1;
        [nRet,nCam.nDeviceName,nErrorCode] = PDC_GetDeviceName(nCam.DeviceNo,0 );
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nFrames,~,nErrorCode] = PDC_GetMaxFrames(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nRate,nErrorCode] = PDC_GetRecordRate(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nColorMode,nErrorCode] = PDC_GetColorType(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nWidthMax,nCam.nHeightMax,nErrorCode] = PDC_GetMaxResolution(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nWidth,nCam.nHeight,nErrorCode] = PDC_GetResolution(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nWidthStep,nCam.nHeightStep,~,~,nCam.nWidthMin,nCam.nHeightMin,~,nErrorCode] = PDC_GetVariableRestriction(nCam.DeviceNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nFps,nErrorCode] = PDC_GetShutterSpeedFps(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nTrigMode,nCam.nAFrames,nCam.nRFrames,nCam.nRCount,nErrorCode] = PDC_GetTriggerMode(nCam.DeviceNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.n8BitSel,nCam.nBayer,nCam.nInterleave,nErrorCode] = PDC_GetTransferOption(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        nCam.nBitDepth = 8;
        nCam.nChannel = 1;
        % populate lists
        [nRet,nRecordRateSize,nCam.nRecordRateList,nErrorCode] = PDC_GetRecordRateList(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        nCam.nRecordRateList = nCam.nRecordRateList(1:nRecordRateSize);
        [nRet,nCam.nShutterSize,nCam.nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        
        % frame
        listRecord = arrayfun(@(x) cellstr(int2str(x)),nCam.nRecordRateList);
        listRecord = cellfun(@(x) cat(2,x,' fps'),listRecord,'UniformOutput',false);
        set(hCamPop.recrate,'String',listRecord)
        listHeight = (nCam.nHeightMin:nCam.nHeightStep:nCam.nHeightMax);
        listHeightStr = cellstr(int2str(listHeight'));
        listWidth = (nCam.nWidthMin:nCam.nWidthStep:nCam.nWidthMax);
        listWidthStr = cellstr(int2str(listWidth'));
        set(hCamPop.width,'String',listWidthStr)
        set(hCamPop.height,'String',listHeightStr)
        
        % setup partition controls
        [nRet,nMaxCount,~,nErrorCode] = PDC_GetMaxPartition(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        num = nMaxCount;
        iters = 0;
        while num > 1
            num = num/2;
            iters = iters+1;
        end
        nCam.nPartitionOps = zeros(iters,1);
        nCam.nPartitionOps(1) = nMaxCount;
        for i = 1:iters-1
            nCam.nPartitionOps(i+1) = nCam.nPartitionOps(i)/2;
        end
        nCam.nPartitionOps = flipud(uint32([nCam.nPartitionOps(:);1]));
        [nRet,Count,~,~,nErrorCode] = PDC_GetPartitionList(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        Count = Count(Count > 0);
        partitionOpsVal = find(Count == nCam.nPartitionOps);
        set(hCamPop.partcount,'string',num2str(nCam.nPartitionOps),'value',partitionOpsVal)
        partitionAvailA = (1:Count);
        [nRet,nCam.nNo,nErrorCode] = PDC_GetCurrentPartition(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        set(hCamPop.partition,'string',cellstr(num2str(partitionAvailA')),'value',nCam.nNo)
        
        %Jumbo packet test, correction if fail
        nInterfaceCode = PDC.INTTYPE_G_ETHER;
        [nRet,nParam1,nParam2,nParam3,nParam4,nErrorCode] = PDC_GetInterfaceInfo(nInterfaceCode);
        errorCodeTest(nRet,nErrorCode)
        testGBa = nParam1 ~= PDC.GETHER_PACKETSIZE_DEFAULT;
        testGBb = nParam4 ~= PDC.GETHER_CONNECT_NORMAL;
        if testGBa || testGBb
            nParam1 = PDC.GETHER_PACKETSIZE_DEFAULT;
            nParam4 = PDC.GETHER_CONNECT_NORMAL;
            [nRet, nErrorCode] = PDC_SetInterfaceInfo(nInterfaceCode,nParam1,...
                nParam2,nParam3,nParam4);
            errorCodeTest(nRet,nErrorCode)
        end
        
        %prepare for photodiode acquisition
        sNidaq = initializeDiodeNidaq(devID);
        varsNidaq.nidaqListener = sNidaq.addlistener('DataAvailable',@trigDetect);
        varsNidaq.overSampleFactor = 10;
        [nRet,nErrorCode] = PDC_SetSyncOutTimes(nCam.DeviceNo,uint32(varsNidaq.overSampleFactor));
        errorCodeTest(nRet,nErrorCode)
        sNidaq.IsContinuous = true;
        sNidaq.Rate = double(nCam.nFps*varsNidaq.overSampleFactor);
        sNidaq.NotifyWhenDataAvailableExceeds = double(nCam.nFrames*varsNidaq.overSampleFactor);
        varsNidaq.nidaqDataA = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
        varsNidaq.nidaqDataB = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
        varsNidaq.nidaqDataC = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
        varsNidaq.recData = zeros(sNidaq.NotifyWhenDataAvailableExceeds,1);
        varsNidaq.recState = 1;
    end
    function errorCodeTest(nRet,nErrorCode)
        if nRet ~= 1
            disp(['Camera error: ' num2str(nErrorCode)]);
            ST = dbstack;
            errorMsg = cell(numel(ST),1);
            for iterST = 1:numel(ST)
                errorMsg{iterST} = [ST(iterST).name,',  line: ',num2str(ST(iterST).line)];
            end
            disp(errorMsg)
        end
    end

    function controllerResetCall(~,~)
        % Setup the serial
        delete(instrfindall)
        sPez = serial(comRef);
        set(sPez,'baudrate',250000,'inputbuffersize',100*(128+3),...
            'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
            @receiveData,'Terminator','CR/LF','StopBits',2);
        fopen(sPez);
        java.lang.Thread.sleep(1000);
        set(hPezMode.parent,'SelectedObject',hPezMode.child(1));
        pezMonitorFun([],[])
        set(hPezSlid.IRlights,'Value',defaultLightIntensity)
        IRlightsCallback([],[])
        fwrite(sPez,sprintf('%s\r','T'));
        itemStates.isRun.controller = true;
    end


%% Message center and experiment management functions
    function removeMsg(~,~)
        set(hTxtMsgA,'string',[])
    end
    function messageFun(msgStr)
        if strcmp(tMsg.Running,'on'), stop(tMsg), end
        set(hTxtMsgA,'string',msgStr)
        start(tMsg)
    end

    function experimentIdCallback(~,~)
        if strcmp(tExpt.Running,'on')
            messageFun('Experiment in progress')
            set(hExptEntry.experiment,'string',exptID)
            return
        end
        exptID = get(hExptEntry.experiment,'string');
        if isempty(exptID)
            exptID = [];
            exptInfo = [];
        elseif numel(exptID) ~= 16
            messageFun('Experiment ID is not the correct length (16)')
            set(hExptEntry.experiment,'string',[])
            exptID = [];
            exptInfo = [];
        elseif strcmp(exptID,'0000000000000000')
            set(hExptEntry.designer,'string','generic')
            %for debugging purposes only
        else
            exptInfo = parseExpID(exptID);
            downloadRate = find(exptInfo.Download_rate{1});
            set(hExptEntry.downloadops,'Value',downloadRate)
            compressionOp = find(exptInfo.Compression_Options{1});
            set(hCamPop.compressmethod,'Value',compressionOp)
            roomTemp = exptInfo.Room_temp{1};
            set(hPezRandom.target,'String',num2str(roomTemp))
            setTemperature([],[])
            stimType = exptInfo.Stimuli_type{1};
            stimOps = {'Looming black disk on white background','ChRimson Activation',...
                'Combo','Looming disk, brighter background','Looming disk, white LED',...
                'Looming disk, arc lamp'};
            stimTest = strcmp(stimType,stimOps);
            %preparing photoactivation
            if max(stimTest(2:3))
                if ~activationBool
                    messageFun('This system is not equipped for activation')
                else
                    if strcmp(comp_name,'cardlab-ww11')
                        set(hCamPop.partcount,'value',4)
                    else
                        set(hCamPop.partcount,'value',5)
                    end
                    partcountCallback([],[])
                    set(hCamEdit.aftertrig,'string','2000')
                    framesEditCallback([],[])
                    set(hPezActivationEdit.powerhigh,'string',num2str(exptInfo.Photo_intensity{1}))
                    set(hPezActivationEdit.timehigh,'string',num2str(exptInfo.Photo_time{1}))
                    squareWaveEditCallback([],[])
                    set(hPezRandom.photocouple,'value',1)
                    coupleToCameraCall([],[])
                end
            end
            %preparing visual stimulus
            if  ~stimTest(2)
                elovervNew = num2str(exptInfo.Stimuli_l_v{1});
                initTestA = strcmp(get(hPezRandom.eloverv,'string'),elovervNew);
                startNew = num2str(exptInfo.Stimuli_start{1});
                initTestB = strcmp(get(hPezRandom.radiusbegin,'string'),startNew);
                endNew = num2str(exptInfo.Stimuli_stop{1});
                initTestC = strcmp(get(hPezRandom.radiusend,'string'),endNew);
                eleNew = num2str(exptInfo.Stimuli_elevation{1});
                initTestD = strcmp(get(hPezRandom.ele,'string'),eleNew);
                aziNew = num2str(exptInfo.Stimuli_azimuth{1});
                initTestE = strcmp(get(hPezRandom.aziOff,'string'),aziNew);
                if stimTest(1)
                    initTestF = get(visStimPop,'Value') == 1;
                else
                    initTestF = get(visStimPop,'Value') == 2;
                end
                initVersionOld = get(hPezButn.initialize,'UserData');
                initTestG = strcmp(initVersion,initVersionOld);
                initTestVec = [initTestA,initTestB,initTestC,initTestD,...
                    initTestE,initTestF,initTestG];
                if ~min(initTestVec)
                    set(hPezRandom.eloverv,'string',elovervNew)
                    set(hPezRandom.radiusbegin,'string',startNew)
                    set(hPezRandom.radiusend,'string',endNew)
                    set(hPezRandom.ele,'string',eleNew)
                    set(hPezRandom.aziOff,'string',aziNew)
                    if stimTest(1)
                        set(visStimPop,'Value',1)
                    else
                        set(visStimPop,'Value',2)
                    end
                    visStimCallback
                    try
                        initializeVisStim([],[])
                    catch
                        messageFun('Visual stimulus failed to initialize.  Try again.')
                        return
                    end
                end
                set(hPezRandom.alternate,'value',exptInfo.Azimuth_options)
                set(hPezRandom.couple,'value',1)
                coupleToCameraCall([],[])
                stimdur = str2double(get(hPezRandom.stimdur,'string'));
                partAdjFac = 1./(double(nCam.nPartitionOps)./double(nCam.nNo));
                durrec = get(hCamEdit.durinmem,'UserData')*1000;
                partDurCmp = partAdjFac*durrec-(stimdur+200);
                partIdeal = find(partDurCmp > 0,1,'last');
                partIdeal = get(hCamPop.partcount,'value')+partIdeal-1;
                if isempty(partIdeal), partIdeal = 1; end
                set(hCamPop.partcount,'value',partIdeal)
                partcountCallback([],[])
                framesIdeal = ((stimdur/1000)+(200/1000))*double(nCam.nRate);
                framesIdeal = ceil(framesIdeal/500)*500;
                if framesIdeal < 1000, framesIdeal = 1000; end
                if framesIdeal >= nCam.nFrames, framesIdeal = nCam.nFrames-1; end
                set(hCamEdit.aftertrig,'string',num2str(framesIdeal))
                framesEditCallback([],[])
            end
            %preparing the experiment control box
            set(hExptEntry.designer,'string',exptInfo.User_ID)
            set(hExptCtrl.autodiscard,'value',1)
        end
    end
    function resumeExptCallback(~,~)
        if isempty(roiPos)
            messageFun('Set ROI first')
        elseif strcmp(tExpt.Running,'on')
            messageFun('Experiment already in progress')
        else
            exptdur = get(hExptEntry.duration,'string');
            if isempty(exptdur)
                set(hExptEntry.duration,'string','20')
                exptdur = get(hExptEntry.duration,'string');
            end
            set(tExpt,'StartDelay',str2double(exptdur)*60)
            % date folder check
            currDate = datestr(date,'yyyymmdd');
            destDatedDir = fullfile(data_dir,currDate);
            % new expt folder
            runFolderCount = dir(fullfile(destDatedDir,'run*'));
            runIndex = numel({runFolderCount(:).name});
            runBool = false(1,runIndex);
            for iterResume = 1:runIndex
                runFolders = ['run',sprintf('%03.0f',iterResume),'_',pezName,'_',currDate];
                runPaths = fullfile(destDatedDir,runFolders);
                runStatsDests = fullfile(runPaths,[runFolders,'_runStatistics.mat']); %path to save runStatistics
                runBool(iterResume) = exist(runStatsDests,'file');
            end
            lastRunRef = find(runBool,1,'last');
            if isempty(lastRunRef)
                messageFun('No previous run found')
            else
                runFolder = ['run',sprintf('%03.0f',lastRunRef),'_',pezName,'_',currDate];
                runPath = fullfile(destDatedDir,runFolder);
                runStatsDest = fullfile(runPath,[runFolder,'_runStatistics.mat']); %path to save runStatistics
                runStatsLoading = load(runStatsDest);
                runStats = runStatsLoading.runStats;
                runStats.time_stop = [];
                save(runStatsDest,'runStats')
                exptID = runStats.experimentID;
                set(hExptEntry.experiment,'string',exptID);
                experimentIdCallback([],[])
                set(hPezRandom.runauto,'Value',1)
                set(hExptCtrl.pause,'enable','on')
                set(hExptCtrl.stop,'enable','on')
                set(hExptCtrl.extend,'enable','on')
                set(hExptCtrl.resume,'enable','off')
                set(hExptCtrl.run,'enable','off')
                set(hPezRandom.runauto,'Value',1)
                tunnelFlyCt = runStats.tunnel_fly_count;
                prismFlyCt = runStats.prism_fly_count;
                set(hPezReport.flycount,'String',num2str(tunnelFlyCt));
                runAutoPilotCall([],[])
                start(tExpt)
            end
        end
    end
    function runexptCallback(~,~)
        if isempty(roiPos)
            messageFun('Set ROI first')
        elseif strcmp(tExpt.Running,'on')
            messageFun('Experiment already in progress')
        else
            exptdur = get(hExptEntry.duration,'string');
            if isempty(exptdur)
                set(hExptEntry.duration,'string','20')
                exptdur = get(hExptEntry.duration,'string');
            end
            if isempty(get(hExptEntry.experiment,'string'))
                messageFun('Enter a valid experiment ID')
                return
            end
            set(tExpt,'StartDelay',str2double(exptdur)*60)
            set(hPezReport.flycount,'String','0');
            % date folder check
            currDate = datestr(date,'yyyymmdd');
            destDatedDir = fullfile(data_dir,currDate);
            if isdir(destDatedDir) == 0, mkdir(destDatedDir),end
            % new expt folder
            runFolderCount = dir(fullfile(destDatedDir,'run*'));
            runIndex = numel({runFolderCount(:).name})+1;
            runFolder = ['run',sprintf('%03.0f',runIndex),'_',pezName,'_',currDate];
            runPath = fullfile(destDatedDir,runFolder);
            runStatsDest = fullfile(runPath,[runFolder,'_runStatistics.mat']); %path to save runStatistics
            if ~isdir(runPath), mkdir(runPath), end
            exptInfoDest = fullfile(runPath,[runFolder,'_experimentIDinfo.mat']); %path to save exptInfo
            runStats(1).time_start = datestr(now);
            runStats.experimentID = get(hExptEntry.experiment,'string');
            runStats.empty_count = 0;
            runStats.single_count = 0;
            runStats.multi_count = 0;
            runStats.diode_failures = 0;
            runStats.manager_notes = [];
            runStats.time_stop = [];
            runStats.tunnel_fly_count = 0;
            tunnelFlyCt = 0;
            set(hPezReport.flycount,'String',num2str(tunnelFlyCt));
            runStats.prism_fly_count = 0;
            prismFlyCt = 0;
            save(runStatsDest,'runStats')
            manStr = get(hExptEntry.manager,'string');
            if strcmp(get(hExptEntry.manager,'style'),'edit')
                exptInfo.Manager{1} = manStr;
            else
                exptInfo.Manager{1} = manStr{get(hExptEntry.manager,'value')};
            end
            save(exptInfoDest,'exptInfo')
            set(hExptCtrl.pause,'enable','on')
            set(hExptCtrl.stop,'enable','on')
            set(hExptCtrl.extend,'enable','on')
            set(hExptCtrl.resume,'enable','off')
            set(hExptCtrl.run,'enable','off')
            set(hPezRandom.runauto,'Value',1)
            runAutoPilotCall([],[])
            start(tExpt)
        end
    end
    function savenotesCallback(~,~)
        runStats.manager_notes = get(hExptEntry.managernotes,'string');
        save(runStatsDest,'runStats')
    end
    function extendexptCallback(~,~)
        exptdur = get(hExptEntry.duration,'string');
        if isempty(exptdur)
            set(hExptEntry.duration,'string','20')
            exptdur = get(hExptEntry.duration,'string');
        end
        if strcmp(tExpt.Running,'on'),stop(tExpt),end
        set(tExpt,'Period',str2double(exptdur)*60)
        start(tExpt)
    end
    function pauseexptCallback(~,~)
        butStr = get(hExptCtrl.pause,'string');
        if strcmp(butStr,'Pause')
            if strcmp(tExpt.Running,'on')
                set(hPezRandom.flydetect,'Value',0)
                setFlydetectCall([],[])
                itemStates.isRun.flydetect = false;
                stop(tExpt)
                set(hExptCtrl.pause,'string','Resume')
                set(hExptCtrl.stop,'enable','off')
                set(hExptCtrl.extend,'enable','off')
                set(hPezRandom.runauto,'Value',0)
                set(hPezRandom.flydetect,'Value',0)
            end
        else
            set(hPezRandom.flydetect,'Value',1)
            setFlydetectCall([],[])
            itemStates.isRun.flydetect = true;
            start(tExpt)
            set(hExptCtrl.pause,'string','Pause')
            set(hExptCtrl.stop,'enable','on')
            set(hExptCtrl.extend,'enable','on')
            set(hPezRandom.runauto,'Value',1)
            set(hPezRandom.flydetect,'Value',1)
        end
    end
    function stopexptCallback(~,~)
        if strcmp(tExpt.Running,'on'), stop(tExpt), end
        set(hPezRandom.couple,'value',0)
        set(hPezRandom.photocouple,'value',0)        
        coupleToCameraCall
        set(hPezRandom.flydetect,'Value',0)
        setFlydetectCall([],[])
        set(hPezRandom.runauto,'Value',0)
        runAutoPilotCall([],[])
        runStats.time_stop = datestr(now);
        save(runStatsDest,'runStats')
        runStats = struct;
        set(hExptEntry.experiment,'string',[]);
        experimentIdCallback([],[])
        set(hExptCtrl.run,'enable','on')
        set(hExptCtrl.resume,'enable','on')
        set(hExptCtrl.pause,'enable','off')
        set(hExptCtrl.stop,'enable','off')
        set(hExptCtrl.extend,'enable','off')
        messageFun('Experiment done')
    end


%% Timer-related functions
    function dispLiveImage(~,~)
        if itemStates.isRun.cameramonitor
            showLiveFrame
        elseif itemStates.isRun.memplayback
            timerVidFun
        end
        if itemStates.isRun.focus, focusFun, end
        if itemStates.isRun.flydetect, flyDetect, end
        if itemStates.isRun.controller, updateGatePlot, end
        drawnow
    end
    function showLiveFrame
        [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nCam.DeviceNo,nCam.nChildNo,...
            nCam.nBitDepth,nCam.nColorMode,nCam.nBayer,nCam.nWidth,nCam.nHeight);
        errorCodeTest(nRet,nErrorCode)
        frmData = nBuf';
        set(hImA,'CData',frmData)
    end
    function updateGatePlot
        if ~isempty(gatePosMCU)
            posCell = textscan(gatePosMCU,'%u%u','delimiter',',');
            set(hPezSlid.open,'Min',posCell{1},'Max',posCell{2},'Value',posOpen);
            set(hPezSlid.block,'Min',posCell{1},'Max',posCell{2},'Value',posBlock);
            hOpen1Callback([],[])
            gatePosMCU = [];
        end
        if ~isempty(gateStateMCU)
            stateCell = textscan(gateStateMCU,'%u%s','delimiter',',');
            if (stateCell{1} == 1)
                stateRef = strfind('OBCH',stateCell{2}{1});
                if stateRef == 2 && get(hPezRandom.flydetect,'Value') == 1
                    setFlydetectCall([],[])
                end
                set(hGateState.parent,'SelectedObject',hGateState.child(stateRef));
            end
            gateStateMCU = [];
        end
        if ~isempty(gateBoundMCU)
            gateCell = textscan(gateBoundMCU,'%u%u%u','delimiter',',');
            gStart = gateCell{1};
            gEnd = gateCell{2};
            gapval = gateCell{3};
            set(hPlotGate.start,'XData',repmat(gStart,1,270),'YData',0:269)
            set(hPlotGate.end,'XData',repmat(gEnd,1,270),'YData',0:269)
            set(hPlotGate.gap,'XData',repmat(gEnd+gapval,1,270),'YData',0:269)
            gateBoundMCU = [];
        end
        if ~isempty(gateDataMCU)
            set(hPlotGate.data,'XData',(0:127),'YData',gateDataMCU(1:128)*2)
            gateDataMCU = [];
        else
            ctrlData = get(hPezButn.controlreset,'userdata');
            if ~isempty(ctrlData)
                oldTime = ctrlData(1);
                oldCount = ctrlData(2);
                if oldCount == 0
                    ctrlData = [cputime 1];
                elseif oldCount > 60
                    itemStates.isRun.cameramonitor = false;
                    itemStates.isRun.controller = false;
                    posOpen = get(hPezSlid.open,'Value');
                    posBlock = get(hPezSlid.block,'Value');
%                     controllerResetCall
                    java.lang.Thread.sleep(5000);
                    itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
                    disp('controller frozen!!!')
                    ctrlData = [0 0];
                else
                    if (cputime-oldTime) > 10
                        ctrlData = [0 0];
                    else
                        ctrlData(2) = oldCount+1;
                    end
                end
                set(hPezButn.controlreset,'userdata',ctrlData)
            else
                ctrlData = [0 0];
                set(hPezButn.controlreset,'userdata',ctrlData)
            end
        end
        if ~isempty(htDataMCU)
            htCell = textscan(htDataMCU,'%u%u','delimiter',',');
            tempMCU = double(htCell{2})/10;
            humidMCU = double(htCell{1})/10;
            set(hPezReport.temp,'String',[num2str(tempMCU) ' deg C']);
            set(hPezReport.humid,'String',[num2str(humidMCU) ' %']);
            htDataMCU = [];
        end
         if ~isempty(inplineMCU)
            inpCell = textscan(inplineMCU,'%u%u','delimiter',',');
            if get(hPezRandom.runauto,'Value') == 1
                tunnelFlyCt = tunnelFlyCt+1;
                runStats.tunnel_fly_count = tunnelFlyCt;
                set(hPezReport.flycount,'String',num2str(tunnelFlyCt));
            else
                set(hPezReport.flycount,'String',num2str(inpCell{1}));
            end
            inplineMCU = [];
        end
    end

%% ROI and fly-detect related functions
    function hDispROICall(~,~)
        if isempty(roiPos)
            messageFun('Set ROI first')
            set(hPezRandom.flydetect,'Value',0)
            return
        end
        dispVal = get(hPezRandom.roi,'Value');
        switch dispVal
            case 0
                set(hPlotROI,'Visible','off')
            case 1
                set(hPlotROI,'XData',[xROI(:);NaN;stagePos(:,1)],...
                    'YData',[yROI(:);NaN;stagePos(:,2)],'Visible','on')
        end
    end
    function highlightBackground(~,~)
        butVal = get(hPezRandom.showback,'Value');
        tempVal = 3;
        if butVal == 1
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            toggleChildren(roiSubPanel,0)
            toggleChildren(hFigA,0)
            drawnow expose
            rateVal = get(hCamPop.recrate,'Value');
            set(hCamPop.recrate,'Value',tempVal)
            applyNewSettings
            set(hPezSlid.IRlights,'Value',40)
            IRlightsCallback([],[])
            bitVal = get(hCamPop.bitshift,'Value');
            set(hCamPop.bitshift,'Value',1)
            bitshiftCallback
            set(hPezRandom.showback,'UserData',[rateVal bitVal])
            toggleChildren(roiSubPanel,1)
            if strcmp(tPlay.Running,'off'),start(tPlay),end
        else
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            toggleChildren(roiSubPanel,0)
            drawnow expose
            userVals = get(hPezRandom.showback,'UserData');
            rateVal = userVals(1);
            bitVal = userVals(2);
            set(hPezSlid.IRlights,'Value',defaultLightIntensity)
            IRlightsCallback([],[])
            set(hCamPop.recrate,'Value',rateVal)
            applyNewSettings
            set(hCamPop.bitshift,'Value',bitVal)
            bitshiftCallback
            toggleChildren(hFigA,1)
            toggleChildren(roiSubPanel,1)
            if strcmp(tPlay.Running,'off'),start(tPlay),end
        end
    end
    function moreThreshCall(~,~)
        oldVal = str2double(get(hPezRandom.autothresh,'string'));
        newVal = oldVal+0.1;
        set(hPezRandom.autothresh,'string',num2str(newVal))
    end
    function lessThreshCall(~,~)
        oldVal = str2double(get(hPezRandom.autothresh,'string'));
        newVal = oldVal-0.1;
        set(hPezRandom.autothresh,'string',num2str(newVal))
    end
    function hAutoSetROI(~,~)
        itemStates.isRun.cameramonitor = false;
        try
            threshVal = str2double(get(hPezRandom.autothresh,'string'));
            grth = graythresh(frmData)*threshVal;
            frmGr = im2bw(frmData,grth);
            frmGr = imerode(frmGr,strel('disk',3));
            frmGr = imdilate(frmGr,strel('disk',3));
            [rBW,cBW] = find(frmGr);
            [cBWu,ui] = unique(cBW);
            rBWu = rBW(ui);
            xFind = double(round([nCam.nWidth*0.2,nCam.nWidth*0.8]));
            xFind = [find(cBWu > xFind(1),1),find(cBWu > xFind(2),1)];
            xdata = cBWu(xFind(1):xFind(2));
            ydata = rBWu(xFind(1):xFind(2));
            f = fittype('poly1');
            fitObj = fit(xdata,ydata,f);
            fdata = feval(fitObj,xdata);
            I = abs(fdata - ydata) > std(ydata)^0.5;%iqr(ydata)/1;
            outliers = excludedata(xdata,ydata,'indices',I);
            set(hImA,'CData',frmGr.*255)
            set(hPlotROI,'xdata',xdata(~outliers),'ydata',ydata(~outliers),'visible','on');
            drawnow expose
            java.lang.Thread.sleep(2000);
            set(hImA,'CData',frmData)
            set(hPlotROI,'visible','off');
            drawnow expose
            messageFun(['Outlier count: ' num2str(sum(outliers))])
%             if numel(xdata)-sum(outliers) < 50, return, end
            fitObj2 = fit(xdata,ydata,f,'Exclude',outliers);
            stageX = cBWu(xFind(1):xFind(2));
            stageY = feval(fitObj2,stageX);
%             pp = polyfit(cBWu(xFind(1):xFind(2)),rBWu(xFind(1):xFind(2)),1);
%             stageY = polyval(pp,cBWu(xFind(1):xFind(2)));
%             stageX = cBWu(xFind(1):xFind(2));
            stagePos = [stageX(:),stageY(:)];
            stageTab(3:6) = round([min(stagePos(:,1)),max(stagePos(:,1)),...
            mean(stagePos(:,2))-100,mean(stagePos(:,2))-10]);
            sideNdx = round(max(stageY))+200;
            
            frmBot = frmData(sideNdx:end,:,1);
            roiSwell = 15;
            frmBotSum = sum(frmBot);
            halfref = round(numel(frmBotSum)/2);
            [~,mNdxA] = max(frmBotSum(1:halfref));
            [~,mNdxB] = max(frmBotSum(halfref:end));
            mNdxB = mNdxB+halfref;
            botSpread = mNdxB-mNdxA;
            frmBotSum = sum(frmBot,2);
            halfref = round(numel(frmBotSum)/2);
            [~,mNdxC] = max(frmBotSum);
            if mNdxC > halfref
                roiPos = [mNdxA-roiSwell, mNdxC-botSpread+sideNdx-roiSwell,...
                    mNdxB+roiSwell, mNdxC+sideNdx+roiSwell];
            else
                roiPos = [mNdxA-roiSwell, mNdxC+sideNdx-roiSwell,...
                    mNdxB+roiSwell, mNdxC+botSpread+sideNdx+roiSwell];
            end
%             frmBotBW = frmGr(sideNdx:end,:,1);
%             [rBotBW,cBotBW] = find(frmBotBW);
%             roiSwell = 5;
%             roiPos = [min(cBotBW)-roiSwell,min(rBotBW)+sideNdx-roiSwell,...
%                 max(cBotBW)+roiSwell,max(rBotBW)+sideNdx+roiSwell];
            
            lrgDims = [roiPos(4)-roiPos(2),roiPos(3)-roiPos(1)];
            smlDims = floor(lrgDims*dwnFac);
            xOpsVec = (tmplLeg+1:6:smlDims(2)-tmplLeg);
            yOpsVec = (tmplLeg+1:6:smlDims(1)-tmplLeg);
            xOpsEdges = repmat(xOpsVec,1,numel(yOpsVec));
            yOpsEdges = repmat(yOpsVec,numel(xOpsVec),1);
            xOpsEdges = xOpsEdges(:);
            yOpsEdges = yOpsEdges(:);
            
            set(hQuivA,'XData',roiPos(1)+lrgDims(2)/2,...
                'YData',roiPos(2)+lrgDims(1)/2,'Visible','off')
            xPlot = roiPos(1)+xOpsEdges(:)*2;
            yPlot = roiPos(2)+yOpsEdges(:)*2;
            set(hPlotPre,'XData',xPlot,'YData',yPlot,'Visible','off')
            
            xOpsVec = (1:2:lrgDims(2));
            yOpsVec = (1:2:lrgDims(1));
            xROI = [xOpsVec,repmat(lrgDims(2),1,numel(yOpsVec))...
                xOpsVec,ones(1,numel(yOpsVec))]+roiPos(1);
            yROI = [ones(1,numel(xOpsVec)),yOpsVec,...
                repmat(lrgDims(1),1,numel(xOpsVec)),yOpsVec]+roiPos(2);
            set(hPlotROI,'XData',[xROI(:);NaN;stageX(:)],...
                'YData',[yROI(:);NaN;stageY(:)],'Visible','on')
            drawnow expose
            java.lang.Thread.sleep(2000);
            hDispROICall
        catch ME
            getReport(ME)
        end
        itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
    end
    function setFlydetectCall(~,~)
        if isempty(roiPos)
            messageFun('Set ROI first')
            set(hPezRandom.flydetect,'Value',0)
        elseif get(hPezRandom.flydetect,'Value') == 1
            itemStates.isRun.flydetect = true;
            if strcmp(tDet.Running,'off')
                start(tDet)
            elseif strcmp(tDet.Running,'on')
                stop(tDet)
                start(tDet)
            end
        elseif get(hPezRandom.flydetect,'Value') == 0
            itemStates.isRun.flydetect = false;
            if strcmp(tDet.Running,'on'), stop(tDet), end
        end
    end
    function runAutoPilotCall(~,~)
        if get(hPezRandom.runauto,'Value') == 0
            if strcmp(get(hCamBtns.trig,'enable'),'on')
                triggerCallback
            end
            set(hCamStates.parent,'SelectedObject',hCamStates.children(1))
            camStateCallback([],[])
        elseif isempty(roiPos)
            messageFun('Set ROI first')
            set(hPezRandom.runauto,'Value',0)
        else    
            itemStates.isRun.cameramonitor = false;
            detectTabs = 0;
            hSweepGateCallback
            java.lang.Thread.sleep(1000);
            [nRet,nStatus,nErrorCode] = PDC_GetStatus(nCam.DeviceNo);
            errorCodeTest(nRet,nErrorCode)
            if nStatus ~= PDC.STATUS_LIVE
                [nRet,nErrorCode] = PDC_SetStatus(nCam.DeviceNo,PDC.STATUS_LIVE);
                errorCodeTest(nRet,nErrorCode)
            end
            for iterBack = 1:10
                showLiveFrame
            end
            backAvgCt = 15;
            backgrArray = uint8(zeros(double([nCam.nHeight,nCam.nWidth,backAvgCt])));
            for iterBack = 1:backAvgCt
                showLiveFrame
                backgrArray(:,:,iterBack) = frmData;
            end
            backgrFrm = max(backgrArray,[],3);
            set(hCamStates.parent,'SelectedObject',hCamStates.children(1))
            camStateCallback([],[])
            set(hCamStates.parent,'SelectedObject',hCamStates.children(3))
            camStateCallback([],[])
            if get(hGateMode.parent,'SelectedObject') ~= hGateMode.child(2)
                set(hGateMode.parent,'SelectedObject',hGateMode.child(2))
                hAutoButtonCallback([],[])
            end
            if get(hGateState.parent,'SelectedObject') ~= hGateState.child(1)
                set(hGateState.parent,'SelectedObject',hGateState.child(1))
                gateSelectCallback([],[])
            end
            coupleToCameraCall
            set(hPezRandom.flydetect,'Value',1)
            setFlydetectCall([],[])
        end
        disp('Autopilot initialization complete')
    end
    function overlayAnnotationsCall(~,~)
        if get(hPezRandom.annotate,'Value') == 0
            set(hPlotPre,'Visible','off')
            set(hPlotPost,'Visible','off')
            set(hPlotH,'Visible','off')
            set(hPlotT,'Visible','off')
            set(hQuivA,'Visible','off')
        else
            set(hPlotPre,'Visible','on')
        end
    end
    function resetDetectFun(~,~)
        hSweepGateCallback
        java.lang.Thread.sleep(500)
        if get(hGateState.parent,'SelectedObject') ~= hGateState.child(1)
            set(hGateState.parent,'SelectedObject',hGateState.child(1))
        end
            gateSelectCallback([],[])
%         end
        detectTabs = 0;
        
%         %%%%%%%%%%%%% for testing purposes only!!!!!
%         set(hGateState.parent,'SelectedObject',hGateState.child(2))
%         gateSelectCallback([],[])
%         triggerCallback([],[])
%         %%%%%%%%%%%%%
        
    end
    function flyDetect(~,~)
        if rateCounter == 1
%             tic
%             rateCounter = 1;
%         else
%             rateCounter = rateCounter+1;
%             if rateCounter >= 120
%                 totTime = toc;
%                 disp(['Average rate: ',num2str(rateCounter/totTime,2) ' per second']);
%                 rateCounter = 0;
%             end
        end

        if get(hPezRandom.flydetect,'Value') == 0, return, end
        
        %%%%% If a fly is detected at the top of the prism and then leaves,
        %%%%% flyDetect is reset.  If 'Trigger on...' is set to 'Escaped',
        %%%%% then the camera is triggered.
        stageIm = frmData(stageTab(5):stageTab(6),stageTab(3):stageTab(4));
        mVal = round(prctile(stageIm(:),95));
        resetThresh = 50;%empirically determined brightest pixel when fly is present
        if stageTab(1) == 0
            if mVal > resetThresh %must reach thresh to start looking for dips in brightness
                stageTab(1:2) = [1,0];
                if get(hPezRandom.runauto,'Value') == 1
                    prismFlyCt = prismFlyCt+1;
                    runStats.prism_fly_count = prismFlyCt;
                end
            end
        elseif stageTab(1) == 1
            if mVal < resetThresh/2 %must dip below half thresh to start counting frames
                stageTab(2) = stageTab(2)+1;
            else
                stageTab(2) = 0; %resets if dip doesn't last long enough
            end
            if stageTab(2) > 30 %number of frames which must be empty before reset
                set(hDetectReadout.textbox,'String',hDetectReadout.options{3})
                setFlydetectCall
                if get(hGateState.parent,'SelectedObject') ~= hGateState.child(1)
                    set(hGateState.parent,'SelectedObject',hGateState.child(1))
                    gateSelectCallback([],[])
                end
                stageTab(1:2) = [0,0];
            end
        else
            stageTab(1:2) = [0,0];
        end
        
        %%%%% The underside view fly detection begins here
        annotateBool = get(hPezRandom.annotate,'Value') == 1;
        roiBlock = frmData(roiPos(2):roiPos(4),...
            roiPos(1):roiPos(3));
        roiBlkSml = double(imresize(roiBlock,dwnFac))./255;
        roiBlkSml = imadjust(roiBlkSml);
        ptOps = [xOpsEdges(:),yOpsEdges(:)];
        blkValPre = zeros(size(ptOps,1),1);
        for iterTm = 1:size(ptOps,1)
            negDim = ptOps(iterTm,:)-tmplLeg;
            posDim = ptOps(iterTm,:)+tmplLeg;
            blkPre = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
            preNdxT = blkPre(preNdxR);
            blkNdxtPreB = squeeze(mean(preNdxT,2));
            blkMeanPreC = mean(blkNdxtPreB);
            preReNdxT = blkMeanPreC(preReNdxR);
            ss_totalPre = sum((blkNdxtPreB-preReNdxT).^2);
            ss_residPre = sum((blkNdxtPreB-preTmpl).^2);
            mvPre = max(1-ss_residPre./ss_totalPre);
            blkValPre(iterTm) = mvPre;
        end
        maxValPre = max(blkValPre);
        [~,ptidx] = sort(blkValPre,'descend');
        ptTryCt = 4;
        ptTryVec = [-2,0,2];
        xOffs = repmat(ptTryVec,[3,1,ptTryCt]);
        yOffs = repmat(ptTryVec',[1,3,ptTryCt]);
        xOps = ptOps(ptidx(1:ptTryCt),1);
        yOps = ptOps(ptidx(1:ptTryCt),2);
        
        if maxValPre < 0.5
            if annotateBool
                set(hPlotPost,'Visible','off')
                set(hPlotH,'Visible','off')
                set(hPlotT,'Visible','off')
                set(hQuivA,'Visible','off')
            end
            return
        end
        
        if annotateBool
            xPlot = roiPos(1)+xOps(:)*2;
            yPlot = roiPos(2)+yOps(:)*2;
            set(hPlotPost,'XData',xPlot,'YData',yPlot,'Visible','on')
        end
        
        xOps = repmat(xOps,numel(xOffs)/ptTryCt,1)+xOffs(:);
        yOps = repmat(yOps,numel(yOffs)/ptTryCt,1)+yOffs(:);
        ptOps = [xOps,yOps];
        
%             % Initialize the following to visualize fly-finding templates 
%             % and the winning blocks (see commented-out sections below)           
%         iDemo = 0;

        headVals = posFinder(headNdxrA,headTmplA);
        tailVals = posFinder(tailNdxrA,tailTmplA);
        [headMax,headNdx] = max(headVals(:,1));
        headPos = ptOps(headNdx,:);
        [tailMax,tailNdx] = max(tailVals(:,1));
        tailPos = ptOps(tailNdx,:);
        maxThresh = 0.7;
        
        %%%% Independent test to see if points are too close together
        headState = (headMax > maxThresh);
        tailState = (tailMax > maxThresh);
        if headState && tailState
            distTest = ptOps(headNdx)-ptOps(tailNdx);
            distTest = sqrt(sum(distTest.^2));
            distThresh = tmplLeg*(.75);
            if distTest < distThresh
                if headMax > tailMax
                    headPos = ptOps(headNdx,:);
                    ptDiff = repmat(headPos,size(ptOps,1),1)-ptOps;
                    distDiff = sqrt(sum(ptDiff.^2,2));
                    refPosOps = find(distDiff > distThresh);
                    if ~isempty(refPosOps)
                        tailVals = tailVals(refPosOps,:);
                        [tailMax,tailNdx] = max(tailVals(:,1));
                        tailPos = ptOps(refPosOps(tailNdx),:);
                    else
                        tailMax = 0;
                    end
                else
                    tailPos = ptOps(tailNdx,:);
                    ptDiff = repmat(tailPos,size(ptOps,1),1)-ptOps;
                    distDiff = sqrt(sum(ptDiff.^2,2));
                    refPosOps = find(distDiff > distThresh);
                    if ~isempty(refPosOps)
                        headVals = headVals(refPosOps,:);
                        [headMax,headNdx] = max(headVals(:,1));
                        headPos = ptOps(refPosOps(headNdx),:);
                    else
                        headMax = 0;
                    end
                end
            end
        end
        
        %%%% Determine theta
        headState = (headMax > maxThresh);
        tailState = (tailMax > maxThresh);
        rotThresh = 0.7;
        rotInset = 0;
        if headState && tailState
            zeroXY = headPos-tailPos;
            flyTheta = -cart2pol(zeroXY(1),zeroXY(2));
            if detectTabs(1) ~= 1
                detectTabs(1) = 1;
                detectTabs(2:3) = mean([headPos;tailPos]);
                detectTabs(4) = flyTheta;
            else
                detectTabs(1) = 4;
                detectTabs(2:3) = mean([headPos;tailPos])-detectTabs(2:3);
                detectTabs(4) = flyTheta-detectTabs(4);
            end
            if annotateBool
                xPlot = roiPos(1)+[headPos(1) tailPos(1)]*2;
                yPlot = roiPos(2)+[headPos(2) tailPos(2)]*2;
                set(hPlotH,'XData',xPlot(1),'YData',yPlot(1),'Visible','on')
                set(hPlotT,'XData',xPlot(2),'YData',yPlot(2),'Visible','on')
            end
        elseif headState
            headSize = layerFindr(headVals(headNdx,2));
            if annotateBool
                xPlot = roiPos(1)+headPos(1)*2;
                yPlot = roiPos(2)+headPos(2)*2;
                set(hPlotH,'XData',xPlot,'YData',yPlot,'Visible','on')
                set(hPlotT,'Visible','off')
            end
            testY = max(headPos <= tmplLeg+1+rotInset);
            testX = max(fliplr(headPos) >= smlDims-tmplLeg-rotInset);
            testZ = headMax < rotThresh;
            if ~max([testX,testY,testZ])
                flyTheta = rotFinder(headPos,headNdxrRot(:,:,headSize),...
                    headTmplRot(:,:,headSize));
                if detectTabs(1) ~= 2
                    detectTabs = [2,headPos,flyTheta];
                else
                    detectTabs(1) = 4;
                    detectTabs(2:3) = headPos-detectTabs(2:3);
                    detectTabs(4) = flyTheta-detectTabs(4);
                end
            else
                flyTheta = NaN;
            end
        elseif tailState
            tailSize = layerFindr(tailVals(tailNdx,2));
            if annotateBool
                xPlot = roiPos(1)+tailPos(1)*2;
                yPlot = roiPos(2)+tailPos(2)*2;
                set(hPlotT,'XData',xPlot,'YData',yPlot,'Visible','on')
                set(hPlotH,'Visible','off')
            end
            testX = max(tailPos <= tmplLeg+1+rotInset);
            testY = max(fliplr(tailPos) >= smlDims-tmplLeg-rotInset);
            testZ = tailMax < rotThresh;
            if ~max([testX,testY,testZ])
                flyTheta = rotFinder(tailPos,tailNdxrRot(:,:,tailSize),...
                    tailTmplRot(:,:,tailSize));
                if detectTabs(1) ~= 3
                    detectTabs = [3,tailPos,flyTheta];
                else
                    detectTabs(1) = 4;
                    detectTabs(2:3) = tailPos-detectTabs(2:3);
                    detectTabs(4) = flyTheta-detectTabs(4);
                end
            else
                flyTheta = NaN;
            end
        else
            flyTheta = NaN;
            if annotateBool
                set(hPlotH,'Visible','off')
                set(hPlotT,'Visible','off')
            end
        end
        
%             % The following is to visualize the fly-finding templates 
%             % and the winning blocks            
%         iDemo(size(roiBlkSml,1),end) = 0;
%         roiBlkSml(size(iDemo,1),end) = 0;
%         roiBlkSml = [roiBlkSml,iDemo];
%         frmData(1:size(roiBlkSml,1),1:size(roiBlkSml,2)) = uint8(roiBlkSml.*255);
        
        if ~isnan(flyTheta)
            set(hPezRandom.aziFly,'String',num2str(flyTheta/(pi/180)))
            if ~annotateBool
                set(hQuivA,'Visible','off')
            else
                u = cos(flyTheta).*tmplLeg*2+1;
                v = -sin(flyTheta).*tmplLeg*2+1;
                set(hQuivA,'UData',u,'VData',v,'Visible','on')
            end
        end
        
        
%         posThresh = 5;%still not sure what values these should have
        dirThresh = (pi/180)*10;%still not sure what values these should have
        if detectTabs(1) == 4
%             posDelta = sqrt(sum(detectTabs(2:3).^2));
            dirDelta = detectTabs(4);
%             if posDelta < posThresh && dirDelta < dirThresh
            if dirDelta < dirThresh
                detectTabs = 0;
                disp('trigger')
                triggerCallback([],[])
            end
            set(hDetectReadout.textbox,'String',hDetectReadout.options{3})
        elseif detectTabs(1) == 0
            set(hDetectReadout.textbox,'String',hDetectReadout.options{1})
        else
            set(hDetectReadout.textbox,'String',hDetectReadout.options{2})
        end
        
        
        %%%%%%%% FlyDetect Subfunctions %%%%%%%
        function blkVal = posFinder(ndxr,tmpl)
            blkVal = ones(size(ptOps,1),2);
            blkVal(:,1) = blkVal(:,1)-1;
            for iterF = 1:size(ptOps,1)
                negDim = ptOps(iterF,:)-tmplLeg;
                posDim = ptOps(iterF,:)+tmplLeg;
                if min(negDim) < 1 || max(fliplr(posDim) > smlDims)
                    blkVal(iterF,:) = [NaN,NaN];
                    continue
                end
                blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
                blkNdxt = blk(ndxr);
                blkMeanPostA = mean(blkNdxt(:,1));
                blkMeanPostB = blkMeanPostA(reNdxrPost);
                ss_totalPost = sum((blkNdxt(:,1)-blkMeanPostB).^2);
                ss_residPost = sum((blkNdxt-tmpl).^2);
                [mvPost,miPost] = max(1-ss_residPost./ss_totalPost);
                blkVal(iterF,:) = [mvPost,miPost];
            end
            
%             % The following is to visualize the fly-finding templates 
%             % and the winning blocks            
%             [~,maxPos] = max(blkVal(:,1));
%             miB = blkVal(maxPos,2);
%             if ~isnan(miB)
%                 negDim = ptOps(maxPos,:)-tmplLeg;
%                 posDim = ptOps(maxPos,:)+tmplLeg;
%                 if min(negDim) < 1, return, end
%                 if max(fliplr(posDim) > smlDims), return, end
%                 blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
%                 blkNdxt = blk(ndxr);
%                 blkDemo = reshape(blkNdxt(:,miB),spokeL,rotOpsTmpl);
%                 tmplDemo = reshape(tmpl(:,miB),spokeL,rotOpsTmpl);
%                 demoBlk = imresize([blkDemo;tmplDemo],3);
%                 iDemo(size(demoBlk,1),end) = 0;
%                 demoBlk(size(iDemo,1),end) = 0;
%                 iDemo = [iDemo,zeros(size(demoBlk,1),10),demoBlk];
%             end
        end
        
        function theta = rotFinder(pt,ndxr,tmpl)
            negDim = pt-tmplLeg;
            posDim = pt+tmplLeg;
            blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
            blkNdxt = blk(ndxr);
            blkMeanA = mean(blkNdxt(:,1));
            blkMeanB = blkMeanA(reNdxrRot);
            ss_total = sum((blkNdxt(:,1)-blkMeanB).^2);
            ss_resid = sum((blkNdxt-tmpl).^2);
            [~,mi] = max(1-ss_resid./ss_total);
            tryRot = flipud(rotOpsTmplRot(:));
            theta = tryRot(mi);
            
%             % The following is to visualize the fly-finding templates 
%             % and the winning blocks
%             blkDemo = reshape(blkNdxt(:,mi),spokeL,120);
%             tmplDemo = reshape(tmpl(:,mi),spokeL,120);
%             demoBlk = imresize([blkDemo;tmplDemo],2);
%             iDemo(end,size(demoBlk,2)) = 0;
%             demoBlk(end,size(iDemo,2)) = 0;
%             iDemo = [iDemo;zeros(size(demoBlk));demoBlk];
        end
    end

    function focusFeedback(~,~)
        focusVal = get(hPezButn.finefoc,'Value');
        if focusVal == 1
            if get(hPezRandom.showback,'Value') == 0
                set(hPezRandom.showback,'Value',1)
                highlightBackground
            end
            hCalibrate
            set(hAxesT,'Visible','on')
            set(hAxesT,'XLim',[-20 20],'YLim',[0 2])
            focDims = [stageTab(6)-stageTab(5),stageTab(4)-stageTab(3)];
            xOpsVec = (1:2:focDims(2));
            yOpsVec = (1:2:focDims(1));
            xFoc = [xOpsVec,repmat(focDims(2),1,numel(yOpsVec))...
                xOpsVec,ones(1,numel(yOpsVec))]+stageTab(3);
            yFoc = [ones(1,numel(xOpsVec)),yOpsVec,...
                repmat(focDims(1),1,numel(xOpsVec)),yOpsVec]+stageTab(5);
            set(hPlotROI,'XData',xFoc,'YData',yFoc,'Visible','on')
            itemStates.isRun.focus = true;
        else
            if get(hPezRandom.showback,'Value') == 1
                set(hPezRandom.showback,'Value',0)
                highlightBackground
            end
            delete(get(hAxesT,'Children'))
            set(hAxesT,'Visible','off')
            itemStates.isRun.focus = false;
            hSweepGateCallback
            removePlot
        end
    end
    function focusFun
        delete(get(hAxesT,'Children'))
        focusIm = frmData(stageTab(5):stageTab(6),stageTab(3):stageTab(4));
        FM = fmeasure(focusIm,'SFRQ',[]);
        switch stageTab(1)
            case 0
                FocStr = '1: Turn focus knob one direction';
                stageTab(1) = 1;
                stageTab(2) = FM;
            case 1
                FocStr = '1: Turn focus knob one direction';
                if FM > stageTab(2), stageTab(2) = FM; end
                focDrop = (stageTab(2)-FM)/stageTab(2);
                if focDrop > 0.3
                    stageTab(1) = 2;
                    stageTab(2) = FM;
                end
            case 2
                FocStr = '2: Turn focus knob the OTHER way';
                if FM > stageTab(2), stageTab(2) = FM; end
                focDrop = (stageTab(2)-FM)/stageTab(2);
                if focDrop > 0.2
                    stageTab(1) = 3;
                end
            case 3
                FocStr = {'3: Turn focus knob slowly the FIRST way';
                        'until the lines are as close as possible'};
                xF = [-10 10 NaN -10 10];
                FM = 1-(stageTab(2)-FM)/stageTab(2)*3;
                yF = [FM FM NaN 1 1];
                plot(xF,yF,'Parent',hAxesT,'linewidth',2.5)
        end
        text(0,1.2,num2str(FM,3),'Parent',hAxesT,'Color','w',...
            'fontsize',12)
        text(0,1.6,FocStr,'Parent',hAxesT,'fontsize',12,'Color','w',...
            'HorizontalAlignment','Center','fontweight','bold')
    end
    function removePlot(~,~)
        set(hPlotROI,'Visible','off')
    end
    function hManualSetROI(~,~)
    end



%% Camera control functions
    function dispCurrentSettings(~,~)
        listHeightNum = (nCam.nHeightMin:nCam.nHeightStep:nCam.nHeightMax);
        listWidthNum = (nCam.nWidthMin:nCam.nWidthStep:nCam.nWidthMax);
        set(hCamPop.width,'Value',find(nCam.nWidth == listWidthNum))
        set(hCamPop.height,'Value',find(nCam.nHeight == listHeightNum))
        set(hCamPop.recrate,'Value',find(nCam.nRate == nCam.nRecordRateList))
    end
    function applyNewSettings(~,~)
        disp('applyNewSettings started')
        %pause live camera feed if necessary
        itemStates.isRun.cameramonitor = false;
        
        listHeightNum = (nCam.nHeightMin:nCam.nHeightStep:nCam.nHeightMax);
        listWidthNum = (nCam.nWidthMin:nCam.nWidthStep:nCam.nWidthMax);
        nCam.nWidth = listWidthNum(get(hCamPop.width,'Value'));
        nCam.nHeight = listHeightNum(get(hCamPop.height,'Value'));
        nCam.nRate = nCam.nRecordRateList(get(hCamPop.recrate,'Value'));
        nXPos = nCam.nWidthMax/2-nCam.nWidth/2;
        nYPos = nCam.nHeightMax/2-nCam.nHeight/2;
        nCam.nFps = nCam.nShutterList(nCam.nShutterSize);
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nCam.DeviceNo,nCam.nChildNo,nCam.nFps);
        errorCodeTest(nRet,nErrorCode)
        java.lang.Thread.sleep(100);
        disp('shutter')
        [nRet,nErrorCode] = PDC_SetVariableChannelInfo(nCam.DeviceNo,...
            nCam.nChannel,nCam.nRate,nCam.nWidth,nCam.nHeight,nXPos,nYPos);
        errorCodeTest(nRet,nErrorCode)
        java.lang.Thread.sleep(100);
        disp('set channel info')
        [nRet,nErrorCode] = PDC_SetVariableChannel(nCam.DeviceNo,nCam.nChildNo,nCam.nChannel);
        errorCodeTest(nRet,nErrorCode)
        java.lang.Thread.sleep(300);
        disp('set channel')
        [nRet,nCam.nShutterSize,nCam.nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        nCam.nFps = nCam.nShutterList(1);
        disp('get shutter speed')
        [nRet, nErrorCode] = PDC_SetShutterSpeedFps(nCam.DeviceNo, nCam.nChildNo, nCam.nFps);
        errorCodeTest(nRet,nErrorCode)
        java.lang.Thread.sleep(100);
        disp('set shutter speed')
        listShutter = arrayfun(@(x) cellstr(int2str(x)),(nCam.nShutterList(nCam.nShutterList > 0)));
        if ~isempty(listShutter)
            listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
            set(hCamPop.shutter,'String',listShutter,'Value',1);
        end
        [nRet,nCam.nFrames,~,nErrorCode] = PDC_GetMaxFrames(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        stop(sNidaq)
        sNidaq.Rate = double(nCam.nFps*varsNidaq.overSampleFactor);
        sNidaq.NotifyWhenDataAvailableExceeds = double(nCam.nFrames*varsNidaq.overSampleFactor);
        coupleToCameraCall
        boxRatio = double([nCam.nWidth nCam.nHeight])./double(max(nCam.nWidth,nCam.nHeight));
        boxRatio(3) = 1;
        set(hAxesA,'xlim',[1 nCam.nWidth],'ylim',[1 nCam.nHeight],...
            'PlotBoxAspectRatio',boxRatio)
        
        disp('triggerModeCallback called')
        triggerModeCallback([],[])
        disp('triggerModeCallback passed')
        itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
        disp('applyNewSettings complete')
    end
    function shutterSpeedCallback(~,~)
        itemStates.isRun.cameramonitor = false;
        nCam.nFps = nCam.nShutterList(get(hCamPop.shutter,'Value'));
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nCam.DeviceNo,nCam.nChildNo,nCam.nFps);
        errorCodeTest(nRet,nErrorCode)
        itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
    end
    function bitshiftCallback(~,~)
        itemStates.isRun.cameramonitor = false;
        shiftOps = fliplr(0:4);
        sourceVal = get(hCamPop.bitshift,'Value');
        nCam.n8BitSel = shiftOps(sourceVal);
        [nRet, nErrorCode] = PDC_SetTransferOption(nCam.DeviceNo,nCam.nChildNo,nCam.n8BitSel,nCam.nBayer,nCam.nInterleave);
        errorCodeTest(nRet,nErrorCode)
        itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
    end
    function calibrateCallback(~,~) %calibrate camera
        fwrite(sPez,sprintf('%s %u\r','I',0));
        fwrite(sPez,sprintf('%s %u\r','L',0));
        java.lang.Thread.sleep(1000);
        [nRet,nErrorCode] = PDC_SetShadingMode(nCam.DeviceNo,nCam.nChildNo,2);
        errorCodeTest(nRet,nErrorCode)
        java.lang.Thread.sleep(1000);
        IRlightsCallback([],[])
    end
    function camStateCallback(~,~)
        disp('camStateCallback started')
        if strcmp(get(hCamPlaybackSlider,'enable'),'on')
            itemStates.isRun.memplayback = false;
            set(hCamPlayback.parent,'SelectedObject',[])
            set(hCamPlayback.children(:),'enable','inactive')
            set(hCamPlaybackSlider,'enable','inactive')
        end
        set(hCamBtns.trig,'enable','off')
        set(hCamBtns.review,'enable','off')
        set(hCamBtns.download,'enable','off')
        butValN = get(hCamStates.parent,'SelectedObject');
        caseVal = find(butValN == hCamStates.children);
        [nRet,nStatus,nErrorCode] = PDC_GetStatus(nCam.DeviceNo);
        errorCodeTest(nRet,nErrorCode)
        switch caseVal
            case 1
                while nStatus ~= PDC.STATUS_LIVE
                    [nRet,nErrorCode] = PDC_SetStatus(nCam.DeviceNo,PDC.STATUS_LIVE);
                    errorCodeTest(nRet,nErrorCode)
                    java.lang.Thread.sleep(200);
                    [nRet,nStatus,nErrorCode] = PDC_GetStatus(nCam.DeviceNo);
                    errorCodeTest(nRet,nErrorCode)
                end
                itemStates.isRun.cameramonitor = true;
                itemStates.shouldRun.cameramonitor = true;
            case 2
                itemStates.isRun.cameramonitor = false;
                itemStates.shouldRun.cameramonitor = false;
                set(hCamBtns.review,'enable','on')
            case 3
                errorCodeTest(nRet,nErrorCode)
                nTrigRef = get(hCamPop.trigmode,'Value');
                if nTrigRef == 1
                    while nStatus ~= PDC.STATUS_RECREADY
                        [nRet,nErrorCode] = PDC_SetRecReady(nCam.DeviceNo);
                        errorCodeTest(nRet,nErrorCode)
                        java.lang.Thread.sleep(200);
                        [nRet,nStatus,nErrorCode] = PDC_GetStatus(nCam.DeviceNo);
                        errorCodeTest(nRet,nErrorCode)
                    end
                    [nRet,nMode,nErrorCode] = PDC_GetExternalOutMode(nCam.DeviceNo,1);
                    errorCodeTest(nRet,nErrorCode)
                    while nMode ~= PDC.EXT_OUT_READY_POSI
                        [nRet, nErrorCode] = PDC_SetExternalOutMode(nCam.DeviceNo,1,PDC.EXT_OUT_READY_POSI);
                        errorCodeTest(nRet,nErrorCode)
                        java.lang.Thread.sleep(200);
                        [nRet,nMode,nErrorCode] = PDC_GetExternalOutMode(nCam.DeviceNo,1);
                        errorCodeTest(nRet,nErrorCode)
                    end
                else
                    while nStatus ~= PDC.STATUS_ENDLESS
                        [nRet,nErrorCode] = PDC_SetRecReady(nCam.DeviceNo);
                        errorCodeTest(nRet,nErrorCode)
                        [nRet,nErrorCode] = PDC_SetEndless(nCam.DeviceNo);
                        errorCodeTest(nRet,nErrorCode)
                        java.lang.Thread.sleep(200);
                        [nRet,nStatus,nErrorCode] = PDC_GetStatus(nCam.DeviceNo);
                        errorCodeTest(nRet,nErrorCode)
                    end
                end
                set(hCamBtns.trig,'enable','on')
                set(hCamStates.children,'enable','off')
        end
        if strcmp(tPlay.Running,'off'),start(tPlay),end
        disp('camStateCallback completed')
    end
    function partcountCallback(~,~)
        nCount = nCam.nPartitionOps(get(hCamPop.partcount,'value'));
        partitionAvail = (1:nCount);
        set(hCamPop.partition,'string',cellstr(num2str(partitionAvail')))
        [nRet,nErrorCode] = PDC_SetPartitionList(nCam.DeviceNo,nCam.nChildNo,nCount,[]);
        errorCodeTest(nRet,nErrorCode)
        [nRet,nCam.nFrames,~,nErrorCode] = PDC_GetMaxFrames(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        stop(sNidaq)
        sNidaq.NotifyWhenDataAvailableExceeds = double(nCam.nFrames*varsNidaq.overSampleFactor);
        coupleToCameraCall
        set(hCamPop.partition,'value',1)
        partitionCallback([],[])
    end
    function partitionCallback(~,~)
        nCam.nNo = get(hCamPop.partition,'value');
        [nRet,nErrorCode] = PDC_SetCurrentPartition(nCam.DeviceNo,nCam.nChildNo,nCam.nNo);
        errorCodeTest(nRet,nErrorCode)
        triggerModeCallback([],[])
    end
    function framesEditCallback(~,~)
        frmsB4 = str2double(get(hCamEdit.beforetrig,'string'));
        frmsAftr = str2double(get(hCamEdit.aftertrig,'string'));
        totFrm = frmsB4+frmsAftr+1;
        resetFrms = false;
        if totFrm > nCam.nFrames
            resetFrms = true;
            messageFun('Total frames exceeds maximum in memory')
        end
        if frmsB4 < 0 || frmsAftr < 0
            resetFrms = true;
            messageFun('This value must be greater than zero')
        end
        nTrigRef = get(hCamPop.trigmode,'Value');
        switch nTrigRef
            case 3
                oldB4 = get(hCamEdit.beforetrig,'UserData');
                oldAftr = get(hCamEdit.aftertrig,'UserData');
                if frmsB4 > oldB4 || frmsAftr > oldAftr
                    resetFrms = true;
                    messageFun(['Enter a number less than or equal to ',...
                       num2str(oldB4)])
                end
            case 4
                nCam.nAFrames = frmsAftr;
                [nRet,nErrorCode] = PDC_SetTriggerMode(nCam.DeviceNo,nCam.nTrigMode,nCam.nAFrames,nCam.nRFrames,nCam.nRCount);
                errorCodeTest(nRet,nErrorCode)
        end
        
        if resetFrms
            frmsB4 = get(hCamEdit.beforetrig,'UserData');
            frmsAftr = get(hCamEdit.aftertrig,'UserData');
            set(hCamEdit.beforetrig,'string',num2str(frmsB4))
            set(hCamEdit.beforetrig,'string',num2str(frmsAftr))
        else
            durB4 = double(frmsB4)/double(nCam.nRate);
            durAftr = double(frmsAftr)/double(nCam.nRate);
            durB4str = [num2str(round(durB4*1000)) ' ms'];
            durAftrStr = [num2str(round(durAftr*1000)) ' ms'];
            set(hCamEdit.durbefore,'string',durB4str,'UserData',durB4)
            set(hCamEdit.durafter,'string',durAftrStr,'UserData',durAftr)
        end 
    end
    function durationEditCallback(~,~)
%         set(hCamEdit.totframes,'string',[])
    end
    function triggerModeCallback(~,~)
        itemStates.isRun.cameramonitor = false;
        nTrigRef = get(hCamPop.trigmode,'Value');
        nCam.nAFrames = 0;
        nCam.nRFrames = 0;
        nCam.nRCount = 0;
        nTriggerModeList = [PDC.TRIGGER_START,PDC.TRIGGER_CENTER,...
            PDC.TRIGGER_END,PDC.TRIGGER_MANUAL];
        nCam.nTrigMode = nTriggerModeList(nTrigRef);
        set(hCamEdit.beforetrig,'enable','on')
        set(hCamEdit.aftertrig,'enable','on')
        set(hCamEdit.durbefore,'enable','on')
        set(hCamEdit.durafter,'enable','on')
        switch nTrigRef
            case 1
                frmsB4 = 0;
                frmsAftr = nCam.nFrames-1;
                set(hCamEdit.beforetrig,'enable','inactive')
                set(hCamEdit.durbefore,'enable','inactive')
            case 2
                frmsB4 = (nCam.nFrames-1)/2;
                frmsAftr = (nCam.nFrames-1)/2;
            case 3
                frmsB4 = nCam.nFrames-1;
                frmsAftr = 0;
                set(hCamEdit.aftertrig,'enable','inactive')
                set(hCamEdit.durafter,'enable','inactive')
            case 4
                frmsAftr = (nCam.nFrames-1)/2;
                nCam.nAFrames = frmsAftr;
                frmsB4 = frmsAftr;
        end
        set(hCamEdit.beforetrig,'String',num2str(frmsB4),'UserData',frmsB4)
        set(hCamEdit.aftertrig,'String',num2str(frmsAftr),'UserData',frmsAftr)
        [nRet, nErrorCode] = PDC_SetTriggerMode(nCam.DeviceNo,nCam.nTrigMode,nCam.nAFrames,nCam.nRFrames,nCam.nRCount);
        errorCodeTest(nRet,nErrorCode)
        set(hCamEdit.frminmem,'string',num2str(nCam.nFrames))
        durrec = double(nCam.nFrames)/double(nCam.nRate);
        durB4 = double(frmsB4)/double(nCam.nRate);
        durAftr = double(frmsAftr)/double(nCam.nRate);
        durstr = [num2str(round(durrec*1000)) ' ms'];
        durB4str = [num2str(round(durB4*1000)) ' ms'];
        durAftrStr = [num2str(round(durAftr*1000)) ' ms'];
        set(hCamEdit.durinmem,'string',durstr,'UserData',durrec)
        set(hCamEdit.durbefore,'string',durB4str,'UserData',durB4)
        set(hCamEdit.durafter,'string',durAftrStr,'UserData',durAftr)
        itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
    end
    function triggerCallback(~,~)
        if strcmp(tPlay.Running,'on'),stop(tPlay),end
        disp('triggerCallback started')
        itemStates.isRun.cameramonitor = false;
        itemStates.isRun.flydetect = false;
        if strcmp(tDet.Running,'on'),stop(tDet),end
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            displayVisStim([],[])
        else
            [nRet,nErrorCode] = PDC_TriggerIn(nCam.DeviceNo);
            errorCodeTest(nRet,nErrorCode)
            if get(hPezRandom.photocouple,'Value') == 1
                java.lang.Thread.sleep(33);
                photoDisplayCall([],[])
            end
        end
        waitTime = get(hCamEdit.durinmem,'userdata')*2-get(hCamEdit.durbefore,'userdata');
        java.lang.Thread.sleep(round(waitTime*1000));
        set(hCamBtns.trig,'enable','off')
        set(hCamBtns.review,'enable','on')
        set(hCamStates.children,'enable','on')
        set(hCamStates.parent,'SelectedObject',hCamStates.children(2));
        drawnow expose
        if get(hPezRandom.runauto,'Value') == 1
            set(tFun,'StopFcn',@reviewMemoryCallback)
            start(tFun)
        else
            if strcmp(tPlay.Running,'off'),start(tPlay),end
        end
        disp('triggerCallback complete')
    end
    function reviewMemoryCallback(~,~)
        disp('reviewMemoryCallback started')
        frmsB4 = str2double(get(hCamEdit.beforetrig,'string'));
        frmsAftr = str2double(get(hCamEdit.aftertrig,'string'));
        nTrigRef = get(hCamPop.trigmode,'Value');
        switch nTrigRef
            case 1
                frmVecRef = (1:frmsAftr);
            case 3
                frmVecRef = (nCam.nFrames-frmsB4+1:nCam.nFrames);
            otherwise
                frmVecRef = [(nCam.nFrames-frmsB4-1:nCam.nFrames),(1:frmsAftr-1)];
        end
        frmCount = numel(frmVecRef);
%         frmOps = (1:frmCount)';
        frmOps = frmVecRef(:);
        set(hCamPlaybackSlider,'Max',frmCount,'Min',1,'Value',1)
        set(hCamPlayback.children(:),'enable','on')
        set(hCamPlaybackSlider,'enable','on')
        set(hCamBtns.review,'enable','off')
        set(hCamBtns.download,'enable','on')
        drawnow expose
        [nRet,nErrorCode] = PDC_SetStatus(nCam.DeviceNo,PDC.STATUS_PLAYBACK);
        errorCodeTest(nRet,nErrorCode)
        if get(hPezRandom.runauto,'Value') == 1
            set(tFun,'StopFcn',@downloadRecordingCallback)
            start(tFun)
        else
            if strcmp(tPlay.Running,'off'),start(tPlay),end
        end
        disp('reviewMemoryCallback complete')
    end
    function downloadRecordingCallback(~,~)
        if strcmp(tPlay.Running,'on'),stop(tPlay),end
        set(hCamPlayback.parent,'SelectedObject',[])
        set(hCamPlayback.children(:),'enable','inactive')
        set(hCamPlaybackSlider,'enable','inactive')
        set(hCamBtns.download,'enable','off')
        toggleChildren(hPanelsMain,0)
        drawnow expose
        try
            downloadRecordingFun
            toggleChildren(hPanelsMain,1)
        catch ME
            toggleChildren(hPanelsMain,1)
            getReport(ME)
        end
        drawnow expose
    end
    function downloadRecordingFun
        disp('downloadRecordingCallback started')
        
        if strcmp(tExpt.Running,'off')
            % date folder check
            currDate = datestr(date,'yyyymmdd');
            destDatedDir = fullfile(data_dir,currDate);
            if ~isdir(destDatedDir), mkdir(destDatedDir),end
            % new generic folder
            runFolder = ['generic_',pezName,'_',currDate];
            runPath = fullfile(destDatedDir,runFolder);
            if ~isdir(runPath), mkdir(runPath),end
        end
        
        [nRet,memFrameInfo,nErrorCode] = PDC_GetMemFrameInfo(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,memRate,nErrorCode] = PDC_GetMemRecordRate(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        [nRet,memWidth,memHeight,nErrorCode] = PDC_GetMemResolution(nCam.DeviceNo,nCam.nChildNo);
        errorCodeTest(nRet,nErrorCode)
        memFrmCount = frmCount;
        
        autoDiscard = get(hExptCtrl.autodiscard,'Value') == 1;
        discardBool = 0;
        diodeDecision = [];
        diodeData2save = [];
        lightData2save = [];
        frmVecRefCutrate10th = [];
        frmVecRefSuppl = [];
        testA = get(hPezRandom.couple,'Value') == 1;
        testB = get(hPezRandom.photocouple,'Value') == 1;
        testC = strcmp(stimStrOps{get(visStimPop,'Value')},'Black disk on white background');
        testD = strcmp(stimStrOps{get(visStimPop,'Value')},'Black disk on brighter background');
        testData = true;
        
        compressStrOps = {'MPEG-4','Grayscale AVI'};
        compressString = compressStrOps{get(hCamPop.compressmethod,'value')};
        videoExtOps = {'.mp4','.avi'};
        videoExtStr = videoExtOps{get(hCamPop.compressmethod,'value')};
        
        % prepare file names
        video_files = dir(fullfile(runPath,['*' videoExtStr]));
        vid_count = numel({video_files(:).name});
        vidName = [runFolder,'_expt',exptID,'_vid',sprintf('%04.0f',vid_count+1)];
        vidStatsDest = fullfile(runPath,[runFolder,'_videoStatistics.mat']); %path to save vidStatistics
        
        % makes blank background if none found, otherwise saves it
        if get(hPezRandom.runauto,'Value') == 0
            backgrFrm = uint8(zeros(double(nCam.nHeight),double(nCam.nWidth)));
        end
        
        % examines first frame if autodiscard is selected
        if autoDiscard
            [nRet, nData, nErrorCode] = PDC_GetMemImageData(nCam.DeviceNo,nCam.nChildNo,frmVecRef(1),nCam.nBitDepth,nCam.nColorMode,nCam.nBayer,nCam.nWidth,nCam.nHeight);
            errorCodeTest(nRet,nErrorCode)
            frmOne = nData'-backgrFrm;
            frmOne(frmOne < 0) = 0;
            [flycount,counterIm] = flyCounter_3000(frmOne(1:nCam.nWidth,:));
%             figure
%             imshowpair(counterIm,nData','montage')
%             uiwait
            inspectDir = fullfile(runPath,'inspectionResults');
            if ~isdir(inspectDir), mkdir(inspectDir), end
            autoResultsDest = fullfile(inspectDir,[runFolder,'_autoAnalysisResults.mat']); %path to save autoAnalysisResults
            image_files = dir(fullfile(inspectDir,'*.tif'));
            im_count = numel({image_files(:).name});
            image_name = [runFolder,'_flyCounterImage',sprintf('%04.0f',im_count+1),'.tif'];
            imageDest = fullfile(inspectDir,image_name);
            imwrite(counterIm,imageDest,'tif')
            if flycount ~= 1
                discardBool = 1;
                closeDownload
                return
            end
        end
        
        %initial parsing of nidaq data
        if testA || testB
            diodeDataProcessed = mean(reshape(varsNidaq.nidaqDataC(:,1),varsNidaq.overSampleFactor,nCam.nFrames));
            lightDataProcessed = mean(reshape(varsNidaq.nidaqDataC(:,2),varsNidaq.overSampleFactor,nCam.nFrames));
            if numel(diodeDataProcessed) < nCam.nFrames
                diodeDecision = 'data acquisition malfunction';
                if autoDiscard
                    discardBool = 2;
                    closeDownload
                    return
                end
                testData = false;
            end
            nTrigRef = get(hCamPop.trigmode,'Value');
            switch nTrigRef
                case 1
                    diodeData2save = diodeDataProcessed(1:frmCount);
                    lightData2save= lightDataProcessed(1:frmCount);
                case 2
                    diodeData2save = diodeDataProcessed(frmVecRef);
                    lightData2save = lightDataProcessed(frmVecRef);
                otherwise
                    diodeData2save = diodeDataProcessed(nCam.nFrames-frmCount+1:nCam.nFrames);
                    lightData2save = lightDataProcessed(nCam.nFrames-frmCount+1:nCam.nFrames);
            end
%             figure,plot(diodeData2save)
%                     figure,plot(diodeDataProcessed)
%                     uiwait
            visStimInfo.nidaq_data = diodeData2save;
            activationInfo.nidaq_data = lightData2save;
        end
        if testA && testData && (testC || testD)
            visStimInfo.whiteCt = whiteCt;
            stimDwellTime = memRate/360;
            phBrks = round(linspace(1,frmCount,30));
            ranges = zeros(numel(phBrks)-1,1);
            means = zeros(numel(phBrks)-1,1);
            for iterPh = 1:numel(phBrks)-1
                ranges(iterPh) = iqr(diodeData2save(phBrks(iterPh):phBrks(iterPh+1)));
                means(iterPh) = mean(diodeData2save(phBrks(iterPh):phBrks(iterPh+1)));
            end
            avgBase = means(min(ranges) == ranges);
            avgPeak = means(max(ranges) == ranges);
            photoTestA = abs((avgPeak-avgBase)/min(ranges));
            if photoTestA < 10
                diodeDecision = 'signal to noise ratio insufficient';
                if autoDiscard
                    discardBool = 2;
                    closeDownload
                    return
                end
            else
                dataNorm = abs(diodeData2save-avgBase(1))./max(ranges);
                minPkHt = 0.25;
                pkThresh = 0.5;
                dataNorm(dataNorm > pkThresh) = pkThresh;
                minPkDist = floor(stimDwellTime*1.5);
                [peakVals,peakPos] = findpeaks(dataNorm,'MINPEAKHEIGHT',minPkHt,'MINPEAKDISTANCE',minPkDist);
                visStimInfo.peakPos = peakPos;
                visStimInfo.peakVals = peakVals;
                visStimInfo.normalized_data = dataNorm;
                flipLengths = diff(peakPos);
                peakRange = range(flipLengths);
                if peakRange > 2
                    diodeDecision = 'frames were dropped';
                    if autoDiscard
                        discardBool = 2;
                        closeDownload
                        return
                    end
                elseif numel(peakPos) < whiteCt-1
                    diodeDecision = 'visual stimulus incomplete';
                    if autoDiscard
                        discardBool = 2;
                        closeDownload
                        return
                    end
                else
                    diodeDecision = 'good photodiode';
                end
%             whiteCt
%             numel(peakPos)
%             figure,plot(dataNorm)
%             hold on
%             plot(peakPos,peakVals,'.')
            end
%                     figure,plot(diodeData2save)
%                     figure,plot(diodeData)
%                     uiwait
%                     return
            
        end
        messageFun(diodeDecision)
        if testB && testData
%             figure,plot(lightData)
%             figure,plot(lightData2save)
%             uiwait
%             return
            
        end
        varsNidaq.nidaqDataC = varsNidaq.nidaqDataC.*0;
        
        % saving the background frame
        backgrFolder = fullfile(runPath,'backgroundFrames');
        if ~isdir(backgrFolder), mkdir(backgrFolder), end
        backfrName = [runFolder,'_backgroundFrame',sprintf('%04.0f',vid_count+1),'.tif'];
        backgrDest = fullfile(backgrFolder,backfrName); %path to save background
        imwrite(backgrFrm,backgrDest,'tif')
        
        % saving the trigger frame
        triggerFolder = fullfile(runPath,'triggerFrames');
        if ~isdir(triggerFolder), mkdir(triggerFolder), end
        trigrName = [runFolder,'_triggerFrame',sprintf('%04.0f',vid_count+1),'.tif'];
        trigrDest = fullfile(triggerFolder,trigrName); %path to save background
        imwrite(frmData,trigrDest,'tif')
        
        % Downloading the movie(s)
        dwnloadOps = get(hExptEntry.downloadops,'Value');
        if dwnloadOps == 1 || dwnloadOps == 3
            titleStr = ['Downloading: ' vidName];
            hWait = waitbar(0,'1','Name',titleStr,...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
            setappdata(hWait,'canceling',0)
            
            vidDest = fullfile(runPath,[vidName,videoExtStr]); %path to save next video
            vidObj = VideoWriter(vidDest,compressString);
            open(vidObj)
            
            frmCountRoundedTenth = floor(frmCount/10)*10;
            frmVecRef = frmVecRef(1:frmCountRoundedTenth);
            frmMatRefTenth = reshape(frmVecRef,10,frmCountRoundedTenth/10);
            frmVecRefTenth = frmMatRefTenth(1,:);
            [~,frmVecRefCutrate10th] = ismember(frmVecRefTenth,frmVecRef);
            frmCountTenth = numel(frmVecRefTenth);
            deltaPix = zeros(1,frmCountTenth-1);
            tic
            for iterFrm = 1:frmCountTenth
                frmRef = frmVecRefTenth(iterFrm);
                [nRet,nData,nErrorCode] = PDC_GetMemImageData(nCam.DeviceNo,...
                    nCam.nChildNo,frmRef,nCam.nBitDepth,nCam.nColorMode,nCam.nBayer,nCam.nWidth,nCam.nHeight);
                if nRet == PDC.FAILED
                    messageFun(['PDC_GetMemImageData Error : ' num2str(nErrorCode)]);
                    break
                end
                frmWrite = nData'-backgrFrm;
                frmWrite(frmWrite < 0) = 0;
                writeVideo(vidObj,frmWrite)
                
                if ~isempty(roiPos)
                    % acquire luminance change information
                    roiBlockA = frmWrite(roiPos(2):roiPos(4),...
                        roiPos(1):roiPos(3));
                    if iterFrm > 1
                        deltaPix(iterFrm-1) = sum(abs(roiBlockB(:)-roiBlockA(:)));
                    end
                    roiBlockB = roiBlockA;
                end
                
                % Check for Cancel button press
                if getappdata(hWait,'canceling')
                    break
                end
                % Report current estimate in the waitbar's message field
                waitbar(iterFrm/frmCountTenth,hWait)
            end
            delete(hWait)
            messageFun(['Video downloaded in ' num2str(round(toc)) ' seconds'])
            close(vidObj)
%             fullspeedFrmRefs = find(deltaPix > fullspeedThresh);
%             numel(fullspeedFrmRefs)
%             figure,scatter(frmVecRefTenth,deltaPix)
%             uiwait
%             return
        end
        
        if dwnloadOps == 2 || dwnloadOps == 3
            if dwnloadOps == 3
                fullspeedPrctile = round((frmCount-500)/frmCount*100);
                if fullspeedPrctile > 100, fullspeedPrctile = 100; end
                fullspeedThresh = prctile(deltaPix,fullspeedPrctile);
                frmVecRefSuppl = frmVecRef;
                frmVecRef = frmMatRefTenth(:,deltaPix > fullspeedThresh);
                frmVecRef = frmVecRef(:);
                totFrames = double(nCam.nFrames);
                frmVecRef(frmVecRef > totFrames) = frmVecRef(frmVecRef > totFrames)-totFrames;
                frmCount = numel(frmVecRef);
                [~,frmVecRefSuppl] = ismember(frmVecRef,frmVecRefSuppl);
                
                supplementFolder = fullfile(runPath,'highSpeedSupplement');
                if ~isdir(supplementFolder), mkdir(supplementFolder), end
                vidDest = fullfile(supplementFolder,[vidName,'_supplement' videoExtStr]); %path to save suppl video
            else
                vidDest = fullfile(runPath,[vidName,videoExtStr]); %path to save next video
            end
            titleStr = ['Downloading: ' vidName];
            hWait = waitbar(0,'1','Name',titleStr,...
                'CreateCancelBtn',...
                'setappdata(gcbf,''canceling'',1)');
            setappdata(hWait,'canceling',0)
            
            vidObj = VideoWriter(vidDest,compressString);
            open(vidObj)
            tic
            for iterFrm = 1:frmCount
                frmRef = frmVecRef(iterFrm);
                [nRet,nData,nErrorCode] = PDC_GetMemImageData(nCam.DeviceNo,...
                    nCam.nChildNo,frmRef,nCam.nBitDepth,nCam.nColorMode,nCam.nBayer,nCam.nWidth,nCam.nHeight);
                if nRet == PDC.FAILED
                    messageFun(['PDC_GetMemImageData Error : ' num2str(nErrorCode)]);
                    break
                end
                frmWrite = nData'-backgrFrm;
                frmWrite(frmWrite < 0) = 0;
                writeVideo(vidObj,frmWrite)
                % Check for Cancel button press
                if getappdata(hWait,'canceling')
                    break
                end
                % Report current estimate in the waitbar's message field
                waitbar(iterFrm/frmCount,hWait)
            end
            delete(hWait)
            messageFun(['Video downloaded in ' num2str(round(toc)) ' seconds'])
            close(vidObj)
        end
        closeDownload
        
        function closeDownload
            if autoDiscard
                if exist(autoResultsDest,'file') == 2
                    autoResultsImport = load(autoResultsDest);
                    autoResults = autoResultsImport.autoResults;
                    obsList = get(autoResults,'ObsNames');
                    autoCount = numel(obsList);
                else
                    autoResults = [];
                    autoCount = 0;
                end
                if discardBool == 0
                    obsName = vidName;
                else
                    obsName = ['discard' sprintf('%04.0f',autoCount+1)];
                end
                emptyVal = flycount == 0;
                singleVal = flycount == 1;
                multiVal = flycount == 2;
                autoResults2add = dataset({{datestr(now)},'timestamp'},...
                    {singleVal,'single_count'},{emptyVal,'empty_count'},...
                    {multiVal,'multi_count'},{{diodeDecision},'diode_decision'},...
                    {{visStimInfo},'diode_data'},{{imageDest},'inspection_image_path'},...
                    'ObsNames',{obsName});
                autoResults = [autoResults;autoResults2add];
                save(autoResultsDest,'autoResults')
                autoResults = [];
                if get(hPezRandom.runauto,'Value') == 1
                    runStats.empty_count = runStats.empty_count+emptyVal;
                    runStats.single_count = runStats.single_count+singleVal;
                    runStats.multi_count = runStats.multi_count+multiVal;
                    if discardBool == 2
                        runStats.diode_failures = runStats.diode_failures+1;
                    end
                    runStats.time_stop = datestr(now);
                    save(runStatsDest,'runStats')
                end
            end
            
            if ~discardBool
                if exist(vidStatsDest,'file') == 2
                    vidStatsImport = load(vidStatsDest);
                    vidStats = vidStatsImport.vidStats;
                else
                    vidStats = [];
                end
                nTrigRef = get(hCamPop.trigmode,'Value');
                listTrigger = get(hCamPop.trigmode,'String');
                trigMode = listTrigger{nTrigRef};
                IRlights = round(get(hPezSlid.IRlights,'Value'));
                azifly = str2double(get(hPezRandom.aziFly,'string'));
                dwnLoadOp = downloadStrCell{get(hExptEntry.downloadops,'value')};
                vidStats2add = dataset({{vidName},'videoID'},{{memFrameInfo.m_nTrigger},'trigger_timestamp'},...
                    {{nCam.nDeviceName},'device_name'},{memWidth,'frame_width'},{memHeight,'frame_height'},...
                    {memFrmCount,'frame_count'},{memRate,'record_rate'},{nCam.nFps,'shutter_speed'},...
                    {nCam.n8BitSel,'bit_shift'},{{trigMode},'trigger_mode'},{tempMCU,'temp_degC'},...
                    {humidMCU,'humidity_percent'},{IRlights,'IR_light_internsity'},{azifly,'fly_detect_azimuth'},...
                    {{roiPos},'roi'},{{stagePos},'prism_base'},{{frmVecRefCutrate10th},'cutrate10th_frame_reference'},...
                    {{frmVecRefSuppl},'supplement_frame_reference'},{{dwnLoadOp},'download_option'},...
                    {{visStimInfo},'visual_stimulus_info'},{{activationInfo},'photoactivation_info'},'ObsNames',{vidName});
                vidStats = [vidStats;vidStats2add];
                save(vidStatsDest,'vidStats')
                vidStats = [];
                visStimInfo = struct;
                activationInfo = struct;
                diodeData2save = diodeData2save.*0;
                lightData2save = lightData2save.*0;
            end
            if get(hPezRandom.runauto,'Value') == 1
                if sNidaq.IsRunning, stop(sNidaq), end
                set(tFun,'StopFcn',@runAutoPilotCall)
                start(tFun)
            end
            disp('downloadRecordingCallback complete')
        end
    end

% playback functions
    function playbackButtonsCallback(~,eventdata)
        butValN = eventdata.NewValue;
        frmDelta = speedOps(butValN == hCamPlayback.children);
        if frmDelta == 0
            itemStates.isRun.memplayback = false;
        else
            itemStates.isRun.memplayback = true;
        end
%             perVal = round((1/abs(frmRate))*100)/100;
%             if perVal > 0.001
%                 frmDelta = abs(frmRate)/frmRate;
%                 if strcmp(tPlay.Running,'on'),stop(tPlay),end
%                 set(tPlay,'Period',perVal,'TimerFcn',@timerVidFun)
%                 if strcmp(tPlay.Running,'off'),start(tPlay),end
%             end
%         else
%             if strcmp(tPlay.Running,'on'),stop(tPlay),end
%             frmDelta = 0;
%         end
    end
    function timerVidFun(~,~)
        frmOps = circshift(frmOps,-frmDelta);
        set(hCamPlaybackSlider,'Value',frmOps(1))
        playbackDisp
    end
    function PosClickCallback(~,~)
        disp('click')
        start(tPos)
    end
    function PosReleaseCallback(~,~)
        stop(tPos)
    end
    function PosWheelCallback(~,event)
        frmOff = event.getWheelRotation;
        frmNum = get(hCamPlaybackSlider,'Value')-frmOff;
        maxFrm = get(hCamPlaybackSlider,'Max');
        minFrm = get(hCamPlaybackSlider,'Min');
        if frmNum < minFrm || frmNum > maxFrm, return, end
        set(hCamPlaybackSlider,'Value',frmNum)
        playbackDisp
    end
    function playbackSliderCallback(~,~)
        frmNum = round(get(hCamPlaybackSlider,'Value'));
        playbackDisp
        frmOff = find(frmOps == frmNum);
        frmOps = circshift(frmOps,-frmOff+1);
    end
    function playbackDisp
        nFrameNo = frmVecRef(round(get(hCamPlaybackSlider,'Value')));
        [nRet,nData,nErrorCode] = PDC_GetMemImageData(nCam.DeviceNo,nCam.nChildNo,nFrameNo,nCam.nBitDepth,nCam.nColorMode,nCam.nBayer,nCam.nWidth,nCam.nHeight);
        if nRet == PDC.FAILED
            messageFun(['Error: ' num2str(nErrorCode)])
        end
        frmData = (nData');
        fD = double(frmData);
        fD = (fD-min(fD(:)))./range(fD(:));
        frmData = uint8(fD.*255);
        set(hImA,'CData',frmData)
        drawnow expose
    end

%snap shot of single frame
    function captureSingleCallback(~,~)
        imageCap = frmData;
        currDate = datestr(date,'yyyymmdd');
        currTime = datestr(rem(now,1),'HHMMSS');
        capDest = fullfile(snapDir,[currDate '_' currTime '.tif']);
        imwrite(imageCap,capDest,'tif')
        messageFun('Image saved in Captured_Images subdirectory')
    end



%% Photostimulation and Visual Stimulus Control
    function squareWaveEditCallback(~,~)
        photo.Cycles = round(str2double(get(hPezActivationEdit.cycles,'string')));
        if photo.Cycles < 1, photo.Cycles = 1; end
        if photo.Cycles > 100, photo.Cycles = 100; end
        photo.TimeHigh = round(str2double(get(hPezActivationEdit.timehigh,'string')));
        if photo.TimeHigh < 10, photo.TimeHigh = 10; end
        photo.TimeLow = round(str2double(get(hPezActivationEdit.timelow,'string')));
        if photo.TimeLow < 10, photo.TimeLow = 10; end
        photo.PowerHigh = round(str2double(get(hPezActivationEdit.powerhigh,'string')));
        if photo.PowerHigh < 0, photo.PowerHigh = 0; end
        if photo.PowerHigh > 100, photo.PowerHigh = 100; end
        photo.PowerLow = round(str2double(get(hPezActivationEdit.powerlow,'string')));
        if photo.PowerLow < 0, photo.PowerLow = 0; end
        if photo.PowerLow > 100, photo.PowerLow = 100; end
        set(hPezActivationEdit.cycles,'string',num2str(photo.Cycles))
        set(hPezActivationEdit.timehigh,'string',num2str(photo.TimeHigh))
        set(hPezActivationEdit.timelow,'string',num2str(photo.TimeLow))
        set(hPezActivationEdit.powerhigh,'string',num2str(photo.PowerHigh))
        set(hPezActivationEdit.powerlow,'string',num2str(photo.PowerLow))
    end
    function linearRampEditCallback(~,~)
        photo.PowerBegin = round(str2double(get(hPezActivationEdit.powerbegin,'string')));
        if photo.PowerBegin < 0, photo.PowerBegin = 0; end
        if photo.PowerBegin > 100, photo.PowerBegin = 100; end
        photo.PowerEnd = round(str2double(get(hPezActivationEdit.powerend,'string')));
        if photo.PowerEnd < 0, photo.PowerEnd = 0; end
        if photo.PowerEnd > 100, photo.PowerEnd = 100; end
        photo.Duration = round(str2double(get(hPezActivationEdit.duration,'string')));
        if photo.Duration < 10, photo.Duration = 10; end
        deltaPower = photo.PowerEnd-photo.PowerBegin;
        taskCt = round(photo.Duration/100)+1;
        photo.PowerStep = deltaPower/(taskCt-1);
        set(hPezActivationEdit.powerbegin,'string',num2str(photo.PowerBegin))
        set(hPezActivationEdit.powerend,'string',num2str(photo.PowerEnd))
        set(hPezActivationEdit.duration,'string',num2str(photo.Duration))
    end
    function squareWaveOnFun(~,~)
        fwrite(sPez,sprintf('%s %u\r','L',photo.PowerHigh));
        java.lang.Thread.sleep(photo.TimeHigh)
%         fwrite(sPez,sprintf('%s %u\r','L',photo.PowerLow));
        fwrite(sPez,sprintf('%s %u\r','L',0));
        activationInfo.method = 'square_wave';
        activationComplete([],[])
    end
%     function linearRampFun(~,~)
%         newPwr = photo.PowerBegin+photo.PowerStep*(tLinearRamp.TasksExecuted-1);
%         fwrite(sPez,sprintf('%s %u\r','L',round(newPwr)));
%         activationInfo.method = 'linear_ramp';
%     end
    function photoDisplayCall(~,~)
        cfgPlTrn_test20140207(sPez)
%         selObj = get(hPhotoMode.parent,'SelectedObject');
%         if selObj == hPhotoMode.child(1)
%             squareWaveOnFun([],[])
%         else
% %             linearRampFun([],[])
%         end
    end
    function activationComplete(~,~)
%         fwrite(sPez,sprintf('%s %u\r','L',0));
%         set(hPezButn.photodisplay,'string','Execute')
        activationInfo.parameters = photo;
    end
% visual stimulus functions
    function visStimCallback(~,~)
        initVersionOld = get(hPezButn.initialize,'UserData');
        switch stimStrOps{get(visStimPop,'Value')}
            case 'Looming disk'
                initVersion = 'initA';
            case 'Stimulus from file'
                initVersion = 'initC';
            case 'Crosshairs'
                initVersion = 'initB';
            case 'Calibration'
                initVersion = 'initB';
            case 'Grid'
                initVersion = 'initB';
            case 'Full on'
                initVersion = 'initB';
            case 'Full off'
                initVersion = 'initB';
            case 'RGB Order test'
                initVersion = 'initB';
            case 'Disk Size Measurement'
                initVersion = 'initA';
        end
        if ~strcmp(initVersion,initVersionOld)
            set(hPezButn.display,'enable','off')
        else
            set(hPezButn.display,'enable','on')
        end
    end
    function initializeVisStim(~,~)
        try
            itemStates.isRun.cameramonitor = false;
            toggleChildren(hPanelsMain,0)
            drawnow expose
            initializeVisStimPart2
            toggleChildren(hPanelsMain,1)
            itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
            set(hPezButn.display,'enable','on');
        catch ME
            getReport(ME)
            toggleChildren(hPanelsMain,1)
            itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
        end
        drawnow expose
    end
    function initializeVisStimPart2
        initState = get(hPezButn.initialize,'UserData');
        if ~strcmp(initVersion,initState)
            switch initVersion
                case 'initA'
                    disp('Initializing UDP connection');
                    for iterInit = 1:3
                        judp('send',portNum,hostIP,int8(0))
                        try
                            rcvdMssg = judp('receive',portNum,50,15000);
                            break
                        catch
                            if iterInit == 3
                                messageFun('UDP communication error')
                                return
                            end
                        end
                    end
                case 'initC'
                    disp('Initializing UDP connection');
                    for iterInit = 1:3
                        judp('send',portNum,hostIP,int8(0))
                        try
                            rcvdMssg = judp('receive',portNum,50,15000);
                            break
                        catch
                            if iterInit == 3
                                messageFun('UDP communication error')
                                return
                            end
                        end
                    end
                case 'initB'
                    for iterInit = 1:3
                        judp('send',portNum,hostIP,int8(5))
                        try
                            rcvdMssg = judp('receive',portNum,50,15000);
                            break
                        catch
                            if iterInit == 3
                                messageFun('UDP communication error')
                                return
                            end
                        end
                    end
                    java.lang.Thread.sleep(1500);
                    displayVisStim([],[])
            end
            if strcmp(char(rcvdMssg'),'error')
                messageFun('Initialization Error')
                return
            end
        end
        java.lang.Thread.sleep(1000);
        switch initVersion
            case 'initA'
                elloverveeStr = get(hPezRandom.eloverv,'string');
                visParams.ellovervee = str2double(elloverveeStr);
                radiusbeginStr = get(hPezRandom.radiusbegin,'string');
                visParams.radiusbegin = str2double(radiusbeginStr);
                radiusendStr = get(hPezRandom.radiusend,'string');
                visParams.radiusend = str2double(radiusendStr);
                %Setup data to send to the slave computer for stim projection.
                stim_data_string = [elloverveeStr,';',radiusbeginStr,';',radiusendStr];
                disp('Writing out the elleovervee, radiusbegin, radiusend');
                judp('send',portNum,hostIP,[int8(1) int8(stim_data_string)])
                stimdurstr = judp('receive',portNum,50,15000);
                visParams.stimulus_duration = str2double(char(stimdurstr'));
                set(hPezRandom.stimdur,'string',char(stimdurstr'))
            case 'initC'
                stim_data_string = get(fileStimPop,'string')
                stim_data_string = stim_data_string{get(fileStimPop,'value')}
                judp('send',portNum,hostIP,[int8(3) int8(stim_data_string)])
                stimdurstr = judp('receive',portNum,50,15000);
                visParams.stimulus_duration = str2double(char(stimdurstr'));
                set(hPezRandom.stimdur,'string',char(stimdurstr'))
        end
        set(hPezButn.initialize,'UserData',initVersion)
    end
    
    function displayVisStim(~,~)
        set(hPezButn.display,'enable','off')
        switch stimStrOps{get(visStimPop,'Value')}
            case 'Looming disk'
                diskPresentation
            case 'Stimulus from file'
                generalPresentation
            case 'Crosshairs'
                judp('send',portNum,hostIP,int8(6))
            case 'Calibration'
                judp('send',portNum,hostIP,int8(7))
            case 'Grid'
                judp('send',portNum,hostIP,int8(8))
            case 'Full on'
                judp('send',portNum,hostIP,int8(9))
            case 'Full off'
                judp('send',portNum,hostIP,int8(10))
            case 'RGB Order test'
                judp('send',portNum,hostIP,int8(11))
                if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
                    java.lang.Thread.sleep(33);
                    [nRet,nErrorCode] = PDC_TriggerIn(nCam.DeviceNo);
                    errorCodeTest(nRet,nErrorCode)
                end
            case 'Disk Size Measurement'
                offset = str2double(get(hPezRandom.aziOff,'string'));
                azifly = str2double(get(hPezRandom.aziFly,'string'));
                dispAziVal = azifly+offset;
                dispEleVal = str2double(get(hPezRandom.ele,'string'));
                stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
                judp('send',portNum,hostIP,int8(11))
                java.lang.Thread.sleep(500);
                judp('send',portNum,hostIP,int8(stim_data_matrix))
        end
        function diskPresentation
            offset = str2double(get(hPezRandom.aziOff,'string'));
            azifly = str2double(get(hPezRandom.aziFly,'string'));
            dispAziVal = azifly+offset;
            dispEleVal = str2double(get(hPezRandom.ele,'string'));
            stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
            if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
                judp('send',portNum,hostIP,int8([2 stim_data_matrix]))
                java.lang.Thread.sleep(33);
                [nRet,nErrorCode] = PDC_TriggerIn(nCam.DeviceNo);
                errorCodeTest(nRet,nErrorCode)
            else
                judp('send',portNum,hostIP,int8([2 stim_data_matrix]))
            end
            try
                mssgDisp = judp('receive',portNum,50,visParams.stimulus_duration+3000);
            catch
                messageFun('Stimulus presentation fail')
                return
            end
            mssgDispCell = strsplit(char(mssgDisp'),';');
            missedFrames = str2double(mssgDispCell{1});
            whiteCt = str2double(mssgDispCell{2});
            messageFun(['Missed flip count: ' num2str(missedFrames)])
            visParams.azimuth = dispAziVal;
            visParams.elevation = dispEleVal;
            visStimInfo.parameters = visParams;
            visStimInfo.method = stimStrOps{get(visStimPop,'Value')};
            if get(hPezRandom.alternate,'Value') == 1
                set(hPezRandom.aziOff,'string',num2str(-offset))
            end
        end
        function generalPresentation
            offset = str2double(get(hPezRandom.aziOff,'string'));
            azifly = str2double(get(hPezRandom.aziFly,'string'));
            dispAziVal = azifly+offset;
            dispEleVal = str2double(get(hPezRandom.ele,'string'));
            stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
            if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
                judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
                java.lang.Thread.sleep(33);
                [nRet,nErrorCode] = PDC_TriggerIn(nCam.DeviceNo);
                errorCodeTest(nRet,nErrorCode)
            else
                judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
            end
            try
                mssgDisp = judp('receive',portNum,50,visParams.stimulus_duration+3000);
            catch
                messageFun('Stimulus presentation fail')
                return
            end
            mssgDispCell = strsplit(char(mssgDisp'),';');
            missedFrames = str2double(mssgDispCell{1});
            whiteCt = str2double(mssgDispCell{2});
            messageFun(['Missed flip count: ' num2str(missedFrames)])
            visParams.azimuth = dispAziVal;
            visParams.elevation = dispEleVal;
            visStimInfo.parameters = visParams;
            visStimInfo.method = stimStrOps{get(visStimPop,'Value')};
            if get(hPezRandom.alternate,'Value') == 1
                set(hPezRandom.aziOff,'string',num2str(-offset))
            end
        end
        set(hPezButn.display,'enable','on')
    end


%% NIDAQ control functions
    function coupleToCameraCall(~,~)
        drawnow
        testA = get(hPezRandom.couple,'Value') == 1;
        testB = get(hPezRandom.photocouple,'Value') == 1;
        testC = sNidaq.IsRunning;
        if testA || testB
            varsNidaq.nidaqDataA = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
            varsNidaq.nidaqDataB = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
            varsNidaq.nidaqDataC = zeros(sNidaq.NotifyWhenDataAvailableExceeds,2);
            varsNidaq.recData = zeros(sNidaq.NotifyWhenDataAvailableExceeds,1);
            if ~testC
                sNidaq.startBackground();
            end
        elseif testC
            stop(sNidaq)
        end
        varsNidaq.recState = 1;
        pause(0.1)
    end
    function trigDetect(~,event)
        recMax = round(max(event.Data(:,2)));
        recMin = round(min(event.Data(:,2)));
        nTrigRef = get(hCamPop.trigmode,'Value');
        if nTrigRef == 1
            switch varsNidaq.recState
                case 1
                    if recMax == 5
                        varsNidaq.nidaqDataA = [event.Data(:,1),event.Data(:,3)];
                        varsNidaq.recState = 2;
                    end
                case 2
                    if recMin == 0
                        varsNidaq.recState = 3;
                        varsNidaq.nidaqDataA = [event.Data(:,1),event.Data(:,3)];
                        varsNidaq.recData = event.Data(:,2);
                    end
                case 3
                    varsNidaq.nidaqDataB = [event.Data(:,1),event.Data(:,3)];
                    varsNidaq.nidaqDataC = [varsNidaq.nidaqDataA;varsNidaq.nidaqDataB];
                    cropDataBegin = find(varsNidaq.recData < 1,1,'first')+1;
                    cropDataEnd = cropDataBegin+varsNidaq.overSampleFactor*nCam.nFrames-1;
                    varsNidaq.nidaqDataC = varsNidaq.nidaqDataC(cropDataBegin:cropDataEnd,:);
%                     nCam.nFrames
%                     numel(varsNidaq.nidaqDataC)/2
%                     visStimInfo.rawData = [varsNidaq.nidaqDataA,varsNidaq.nidaqDataB,varsNidaq.recData,event.Data];
%                     activationInfo.rawData = [varsNidaq.nidaqDataA,varsNidaq.nidaqDataB,varsNidaq.recData,event.Data];
                    varsNidaq.recState = 1;
            end
        else
            if varsNidaq.recState == 1
                if recMax == 5
                    varsNidaq.nidaqDataB = [event.Data(:,1),event.Data(:,3)];
                    varsNidaq.recState = 2;
                end
            else
                if recMin == 0
                    endRef = find(varsNidaq.recData < 1,1,'first');
                    if endRef < varsNidaq.overSampleFactor*nCam.nFrames
                        endRef = varsNidaq.overSampleFactor*nCam.nFrames;
                    end
                    varsNidaq.nidaqDataC = [varsNidaq.nidaqDataA;varsNidaq.nidaqDataB];
                    cropDataEnd = varsNidaq.overSampleFactor*nCam.nFrames+endRef-1;
                    cropDataBegin = endRef;
                    varsNidaq.nidaqDataC = varsNidaq.nidaqDataC(cropDataBegin:cropDataEnd,:);
                    varsNidaq.rawData = [varsNidaq.nidaqDataA,varsNidaq.nidaqDataB,varsNidaq.recData,event.Data];
                    %                     diodeTimeStamps = event.TimeStamps;
                    varsNidaq.recState = 1;
                else
                    varsNidaq.nidaqDataA = varsNidaq.nidaqDataB;
                end
            end
        end
    end

%% flyPez Controller Functions
    function pezMonitorFun(~,~)
        butnValN = get(hPezMode.parent,'SelectedObject');
        caseVal = find(butnValN == hPezMode.child);
        switch caseVal
            case 1 %monitoring on
                fwrite(sPez,sprintf('%s\r','V'));
            case 2 %monitoring off
                fwrite(sPez,sprintf('%s\r','N'));
        end
    end
    function setTemperature(~,~)
        newTemp = str2double(get(hPezRandom.target,'string'));
        newTemp = round(newTemp*10)/10;
        tempAdjust = 0;
        if newTemp > 30 || newTemp < 18
            messageFun('Temperature must be >18 and <30')
        else
            setTemp = newTemp;
            fwrite(sPez,sprintf('%s %u\r','Q',setTemp+tempAdjust));
        end
        set(hPezRandom.target,'string',num2str(setTemp))
    end
% Graph Thresholds
    function hshadowth(hObject,~)
        entry = str2double(get(hObject,'string'));
        entry = round(entry); %Set limit 0 - 275
        if entry > 275
            entry = 275;
        elseif entry < 0
            entry = 0;
        end
        set(hObject,'String',num2str(entry))
        fwrite(sPez,sprintf('%s %u\r','E',entry));
        set(hPlotGate.shadow,'XData',0:127,'YData',repmat(entry,1,128))
    end

    function hgapth(hObject,~)
        entry = str2double(get(hObject,'string'));
        entry = round(entry);
        if entry > 100
            entry = 100;
        elseif entry < 0
            entry = 0;
        end
        fwrite(sPez,sprintf('%s %u\r','K',entry));
        set(hObject,'String',num2str(entry))
    end

% Light Control
    function IRlightsCallback(~,~)
        slider_value = round(get(hPezSlid.IRlights,'Value'));
        set(hPezSlid.IRlights,'Value',slider_value);
        set(hPezReport.IRlights,'String',[num2str(slider_value) '%'])
        fwrite(sPez,sprintf('%s %u\r','I',slider_value));
    end

% Sweeper Motor Functions
    function hCalibrate(~,~)
        fwrite(sPez,sprintf('%s\r','J'));%holds sweeper over prism
    end
    function hSweepGateCallback(~,~)%sweeps
        fwrite(sPez,sprintf('%s\r','S'));
    end

% Find Gates
    function hFindButtonCallback(~,~)
        fwrite(sPez,sprintf('%s\r','B'));
        java.lang.Thread.sleep(500)
        fwrite(sPez,sprintf('%s\r','F'));
        java.lang.Thread.sleep(500)
        gateSelectCallback([],[])
    end
    function hAutoButtonCallback(~,~)
        butnValN = get(hGateMode.parent,'SelectedObject');
        caseVal = find(butnValN == hGateMode.child);
        stateVal = get(hGateState.parent,'SelectedObject');
        if stateVal == hGateState.child(1)
            switch caseVal
                case 1
                    fwrite(sPez,sprintf('%s\r','O'));
                case 2
                    fwrite(sPez,sprintf('%s\r','R'));
            end
        end     
    end
% Set Gate Position Functions
    function gateSelectCallback(~,~)
        butnValN = get(hGateState.parent,'SelectedObject');
        caseVal = find(butnValN == hGateState.child);
        switch caseVal
            case 1 %Opens Gate1
                MvAval = get(hGateMode.parent,'SelectedObject');
                if MvAval == hGateMode.child(1)
                    fwrite(sPez,sprintf('%s\r','O'));
                else
                    fwrite(sPez,sprintf('%s\r','R'));
                end
            case 2 %Blocks Gate1
                fwrite(sPez,sprintf('%s\r','B'));
            case 3 %Closes Gate1
                fwrite(sPez,sprintf('%s\r','C'));
            case 4 %Cleaning Gate1
                fwrite(sPez,sprintf('%s\r','H'));
        end
    end

% Set open and block position with slider bar.
    function hOpen1Callback(~,~)
        slider_value = round(get(hPezSlid.open,'Value'));
        set(hPezSlid.open,'Value',slider_value);
        set(hPezReport.openpos,'String',...
            ['Open position: ' num2str(slider_value) ' ---------'])
        slider_value = round(get(hPezSlid.block,'Value'));
        set(hPezSlid.block,'Value',slider_value);
        set(hPezReport.closepos,'String',...
            ['Block position: ' num2str(slider_value) ' ------'])
        fwrite(sPez,sprintf('%s %u %u\r','D',get(hPezSlid.open,'Value'),...
            get(hPezSlid.block,'Value')));
        gateSelectCallback([],[])
    end

% Communication to MCU
    function receiveData(~,~)
        token = fscanf(sPez,'%s',4);
        switch token
            case '$GS,'
                gatePosMCU = fscanf(sPez);
            case '$GF,'
                gateBoundMCU = fscanf(sPez);
            case '$GE,'
                gateStateMCU = fscanf(sPez);
            case '$FC,'
                inplineMCU = fscanf(sPez);
            case '$ID,'
                gateDataMCU = fread(sPez,128);
                fscanf(sPez);
            case '$TD,'
                htDataMCU = fscanf(sPez);
        end
    end


%% Close and clean up
    function myCloseFun(~,~)
        
        set(masterCamera,'value',0)
        masterCameraToggle
        
        %stop visual stimulus listener
        judp('send',portNum,hostIP,int8(86))
        
        %stop and delete all timer objects
        hTimers = timerfindall;
        for iT = 1:size(hTimers,2)
            if strcmp(hTimers(iT).Running,'on')
                stop(hTimers(iT))
                java.lang.Thread.sleep(500);
            end
        end
        delete(hTimers)
        delete(instrfindall);
        
        
        %delete the figure
        delete(hFigA)
        
        %delete any hidden handles such as waitbars
        set(0,'ShowHiddenHandles','on')
        delete(get(0,'Children'))
        
        %cover our bases
        clear all
        close all
    end
end

