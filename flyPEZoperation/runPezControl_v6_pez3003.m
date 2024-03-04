function runPezControl_v6
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all force

% data destination folder
data_dir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'Data_pez3000'];

% computer-specific information
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
switch comp_name
    case 'peekm-ww4'
        % in multi screen setup, this determines which screen to be used
        screen2use = 1;
        cameraIP = '192.168.0.10';
        comRef = 'COM5';
        devID = 'Dev2';
        pezName = 'pez3001';
    case 'cardlab-ww10'
        screen2use = 2;
        cameraIP = '192.168.0.10';
        comRef = 'COM4';
        devID = 'Dev1';
        pezName = 'pez3002';
    case 'cardlab-ww11'
        screen2use = 2;
        cameraIP = '192.168.0.10';
        comRef = 'COM4';
        devID = 'Dev2';
        pezName = 'pez3003';
    otherwise
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
hFigA = figure('NumberTitle','off','Name','flyPez3000 CONTROL MODULE - WRW',...
    'menubar','none','Visible','off',...
    'units','pix','Color',[0.05 0 0.25],'pos',FigPos,'colormap',gray(256));
set(hFigA,'Visible','on')

%Experiment display panel
hAxesA = axes('Parent',hFigA,'Position',guiPosFun([.78 .5],[.4 .96]),...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[]);
hAxesT = axes('Parent',hFigA,'Position',[.8 .8 .2 .2],...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[],'Visible','off');

% panPos = [0.67,0.428,0.22,0.144];
% hPan = uipanel(hFigA,'position',panPos,'backgroundcolor',backC,'Visible','off');
% hAxesP = axes('parent',hPan,'position',[.01 .1 .98 .2],...
%     'color','k','tickdir','in','nextplot','replacechildren',...
%     'xticklabel',[],'yticklabel',[]);
% barIm = zeros(10,1000,3);
% hImBar = image(barIm,'parent',hAxesP);
% set(hAxesP,'XLim',[1 1000],'YLim',[1 10])
% hCancelBar = uicontrol('units','normalized','parent',hPan,'position',[.35 .4 .3 .3],...
%     'style','togglebutton','string','Cancel','fontsize',10);
% hTitleBar = uicontrol('units','normalized','parent',hPan,'position',[.01 .8 .98 .2],...
%     'style','text','string','Downloading: ',...
%     'fontsize',10);

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
    'Manager Notes','Runtime (minutes)','videos','Download Options'};
hCt = numel(editStrCell);
hNames = {'designer','manager','experiment',...
    'managernotes','duration','stopafter','downloadops'};
hExptEntry = struct;
posOpsLabel = [.01 .65 .13 .2
    .01 .35 .13 .2
    .01 .05 .13 .2
    .76 .8 .2 .22
    .32 .73 .11 .2
    .46 .43 .05 .2
    .55 .8 .15 .2];
posOpsEdit = [.15 .65 .15 .23
    .15 .35 .15 .23
    .15 .05 .15 .23
    .76 .05 .23 .77
    .43 .74 .05 .23
    .4 .46 .05 .23
    .55 .55 .18 .23];
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

posOp = [.32 .46 .08 .25
    .32 .05 .08 .3
    .4 .05 .08 .3
    .48 .05 .08 .3
    .56 .05 .08 .3
    .09 .05 .05 .25
    .65 .1 .1 .25
    .85 .85 .14 .2];
styleOp = {'checkbox','pushbutton','pushbutton',...
    'pushbutton','pushbutton','pushbutton','checkbox','pushbutton'};
strOp = {'Stop after','Run','Extend','Pause','Stop','Resume','Auto discard','Save to previous run'};
hName = {'stopafter','run','extend','pause','stop','resume','autodiscard','savenotes'};
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
tempMCU = [];
humidMCU = [];
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radius_begin',radiusBegin,'radius_end',radiusEnd);

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
    num2str(1.0)
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
        'Units','normalized','Min',0,'Max',100,'Value',pezSlideVals(iterSD),...
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
stimStrOps = {'Black disk on white background','Crosshairs',...
    'Calibration','Grid','Full on','Full off','Diode test'};
visStimPop = uicontrol(hSubPnl(12),'style','popupmenu','units','normalized',...
    'position',[.05 .825 .9 .125],'string',stimStrOps,'fontunits','normalized');
stimStruct = [];
stimTrigStruct = [];
whiteCt = [];
set(hPezRandom.aziFly,'enable','inactive');
set(hPezButn.display,'enable','off');
%% Initializing and opening camera
PDC = runSetPDCvalues;
nDeviceNo = pezControlOpenCamera(cameraIP,PDC);

% get device properties
[nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
nChildNo = 1;
[nRet,nDeviceName,nErrorCode] = PDC_GetDeviceName(nDeviceNo,0 );
[nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
[nRet,nRate,nErrorCode] = PDC_GetRecordRate(nDeviceNo,nChildNo);
[nRet,nColorMode,nErrorCode] = PDC_GetColorType(nDeviceNo,nChildNo);
[nRet,nWidthMax,nHeightMax,nErrorCode] = PDC_GetMaxResolution(nDeviceNo,nChildNo);
[nRet,nWidth,nHeight,nErrorCode] = PDC_GetResolution(nDeviceNo,nChildNo);
[nRet,nFps,nErrorCode] = PDC_GetShutterSpeedFps(nDeviceNo,nChildNo);
[nRet,nTrigMode,nAFrames,nRFrames,nRCount,nErrorCode] = PDC_GetTriggerMode(nDeviceNo);
[nRet,n8BitSel,nBayer,nInterleave,nErrorCode] = PDC_GetTransferOption(nDeviceNo,nChildNo);
nBitDepth = 8;

% populate lists
[nRet,nRecordRateSize,nRecordRateList,nErrorCode] = PDC_GetRecordRateList(nDeviceNo,nChildNo);
nRecordRateList = nRecordRateList(1:nRecordRateSize);
[nRet,nShutterSize,nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nDeviceNo,nChildNo);

% variable channel info
[nRet,nWidthStep,nHeightStep,~,~,nWidthMin,nHeightMin,~,nErrorCode] = PDC_GetVariableRestriction(nDeviceNo);
nXPos = nWidthMax/2-nWidth/2;
nYPos = nHeightMax/2-nHeight/2;
nChannel = 1;
[nRet,nErrorCode] = PDC_SetVariableChannelInfo(nDeviceNo,nChannel,nRate,nWidth,nHeight,nXPos,nYPos);
[nRet,nErrorCode] = PDC_SetVariableChannel(nDeviceNo,nChildNo,nChannel);


% frame %
listRecord = arrayfun(@(x) cellstr(int2str(x)),nRecordRateList);
listRecord = cellfun(@(x) cat(2,x,' fps'),listRecord,'UniformOutput',false);
set(hCamPop.recrate,'String',listRecord)
listHeightNum = (nHeightMin:nHeightStep:nHeightMax);
listHeightStr = cellstr(int2str(listHeightNum'));
listWidthNum = (nWidthMin:nWidthStep:nWidthMax);
listWidthStr = cellstr(int2str(listWidthNum'));
set(hCamPop.width,'String',listWidthStr)
set(hCamPop.height,'String',listHeightStr)

% camera %
shiftOps = fliplr(0:4);
sourceVal = 3;
n8BitSel = shiftOps(sourceVal);
set(hCamPop.bitshift,'String',{'0','1','2','3','4'},'Value',sourceVal)
[nRet, nErrorCode] = PDC_SetTransferOption(nDeviceNo,nChildNo,n8BitSel,nBayer,nInterleave);


% setup partition controls
[nRet,nMaxCount,nBlock,nErrorCode] = PDC_GetMaxPartition(nDeviceNo,nChildNo);
num = nMaxCount;
iters = 0;
while num > 1
    num = num/2;
    iters = iters+1;
end
partitionOps = zeros(iters,1);

partitionOps(1) = nMaxCount;
for i = 1:iters-1
    partitionOps(i+1) = partitionOps(i)/2;
end
partitionOps = flipud(uint32([partitionOps(:);1]));

[nRet,nCount,~,~,nErrorCode] = PDC_GetPartitionList(nDeviceNo,nChildNo);
nCount = nCount(nCount > 0);
partitionOpsVal = find(nCount == partitionOps);
set(hCamPop.partcount,'string',num2str(partitionOps),'value',partitionOpsVal)
partitionAvail = (1:nCount);
[nRet,nNo,nErrorCode] = PDC_GetCurrentPartition(nDeviceNo,nChildNo);
set(hCamPop.partition,'string',cellstr(num2str(partitionAvail')),'value',nNo)
listShutter = arrayfun(@(x) cellstr(int2str(x)),(nShutterList(nShutterList > 0)));
listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
set(hCamPop.shutter,'String',listShutter)
nTriggerModeList = [PDC.TRIGGER_START,PDC.TRIGGER_CENTER,...
    PDC.TRIGGER_END,PDC.TRIGGER_MANUAL];
listTrigger = {'START','CENTER','END','MANUAL'};
trigVal = find(nTrigMode == nTriggerModeList);
set(hCamPop.trigmode,'String',listTrigger,'Value',trigVal)

listCompress = {'MPEG-4 (high-quality, compressed)','Grayscale AVI (uncompressed)'};
set(hCamPop.compressmethod,'string',listCompress)

%Jumbo packet test, correction if fail
nInterfaceCode = PDC.INTTYPE_G_ETHER;
[nRet,nParam1,nParam2,nParam3,nParam4,nErrorCode] = PDC_GetInterfaceInfo(nInterfaceCode);
testGBa = nParam1 ~= PDC.GETHER_PACKETSIZE_DEFAULT;
testGBb = nParam4 ~= PDC.GETHER_CONNECT_NORMAL;
if testGBa || testGBb
    nParam1 = PDC.GETHER_PACKETSIZE_DEFAULT;
    nParam4 = PDC.GETHER_CONNECT_NORMAL;
    [nRet, nErrorCode] = PDC_SetInterfaceInfo(nInterfaceCode,nParam1,...
        nParam2,nParam3,nParam4);
end

%%
set(hExptCtrl.run,'callback',@runexptCallback)
set(hExptCtrl.extend,'callback',@extendexptCallback)
set(hExptCtrl.pause,'callback',@pauseexptCallback)
set(hExptCtrl.stop,'callback',@stopexptCallback)
set(hExptCtrl.resume,'callback',@resumeExptCallback)
set(hExptCtrl.savenotes,'callback',@savenotesCallback)
set(hExptEntry.experiment,'callback',@experimentIdCallback)

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
set(hCamPlaybackSlider,'callback',@hPlaybackCallback)
set(hCamPlayback.parent,'SelectionChangeFcn',@playbackRateCallback)
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
set(hPezSlid.block,'callback',@hBlock1Callback)
set(visStimPop,'callback',@visStimCallback)
set(hTrigMode.parent,'SelectionChangeFcn',@hTrigSelectCallback)
set(hPezMode.parent,'SelectionChangeFcn',@pezMonitorFun)

%%%% Fly Detect Setup %%%%
template_dir = fullfile(funcPath,'pez3000_templates');
tmplName = 'template_flyDetect.mat';
tmplLoading = load(fullfile(template_dir,tmplName));
tmplGeno = tmplLoading.geno;
fieldnames(tmplGeno)
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
detectResetTab = false;
gatePosMCU = [];
gateStateMCU = [];
gateBoundMCU =  [];
gateDataMCU = [];
htDataMCU = [];
inplineMCU = [];

%additional children
frmData = uint8(zeros(nHeight,nWidth));
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
rateCounter = 0;
liveRate = round((1/10)*100)/100;
tPlay = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',liveRate,'StartDelay',1);
tDet = timer('TimerFcn',@resetDetectFun,'ExecutionMode','fixedRate',...
    'Period',30,'StartDelay',30);
tExpt = timer('TimerFcn',@stopexptCallback,'StartDelay',20*60);
runPath = [];
runFolder = [];
runStats = struct;
runStatsDest = [];

boolFoc = false;
focTab = zeros(6,1);

tMsg = timer('TimerFcn',@removeMsg,'StartDelay',5.0);
tPos = timer('TimerFcn',@hPlaybackCallback,'ExecutionMode','fixedRate',...
    'Period',0.3);
frmRate = 30;
frmOps = [];
frmDelta = 1;
frmVecRef = [];
frmCount = [];

% tSquareWaveOn = timer('TimerFcn',@squareWaveOnFun,'ExecutionMode','fixedRate',...
%     'Period',photo.TimeHigh/1000,'TasksToExecute',photo.Cycles,...
%     'StartDelay',0,'StopFcn',@activationComplete);
% tSquareWaveOff = timer('TimerFcn',@squareWaveOffFun,'ExecutionMode','fixedRate',...
%     'Period',photo.TimeLow/1000,'TasksToExecute',photo.Cycles,...
%     'StartDelay',0,'StopFcn',@activationComplete);
% tLinearRamp = timer('TimerFcn',@linearRampFun,'ExecutionMode','fixedRate',...
%     'Period',100/1000,'TasksToExecute',10,'StartDelay',0,'StopFcn',@activationComplete);


%prepare for photodiode acquisition
sDiode = initializeDiodeNidaq(devID);
hListener = sDiode.addlistener('DataAvailable',@trigDetect);
testReady = @(x) x;
testTrigger = @(x) x;
overSampleFactor = 10;
[nRet,nErrorCode] = PDC_SetSyncOutTimes(nDeviceNo,uint32(overSampleFactor));
sDiode.IsContinuous = true;
sDiode.Rate = double(nFps*overSampleFactor);
sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
diodeDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
lightDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
lightDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
lightData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
recData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
recState = 1;
recEndTime = [];

sPez = [];
% % Setup the serial
% delete(instrfindall)
% sPez = serial(comRef);
% set(sPez,'baudrate',250000,'inputbuffersize',100*(128+3),...
%     'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
%     @receiveData,'Terminator','CR/LF','StopBits',2);
% fopen(sPez);
set(hFigA,'CloseRequestFcn',@myCloseFun)
% end
disp('camStartupFun called')
camStartupFun
disp('camStartupFun passed')


    function camStartupFun
        % send linear array data
        controllerResetCall([],[])
        linearRampEditCallback([],[])
        squareWaveEditCallback([],[])
        dispCurrentSettings([],[])
        disp('applyNewSettings called')
        applyNewSettings([],[])
        disp('applyNewSettings passed')
        messageFun('Camera is ready')
        disp('camStateCallback called')
        camStateCallback([],[])
        disp('camStateCallback passed')
        
    end

    function controllerResetCall(~,~)
        % Setup the serial
        delete(instrfindall)
        sPez = serial(comRef);
        set(sPez,'baudrate',250000,'inputbuffersize',100*(128+3),...
            'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
            @receiveData,'Terminator','CR/LF','StopBits',2);
        fopen(sPez);
%         fwrite(sPez,sprintf('%s\r','V'));
        pezMonitorFun([],[])
        IRlightsCallback([],[])
    end
% message center functions
    function removeMsg(~,~)
        set(hTxtMsgA,'string',[])
    end
    function messageFun(msgStr)
        if strcmp(tMsg.Running,'on'), stop(tMsg), end
        set(hTxtMsgA,'string',msgStr)
        start(tMsg)
    end

% experiment management functions
    function experimentIdCallback(~,~)
        exptID = get(hExptEntry.experiment,'string');
    end
    function resumeExptCallback(~,~)
        if get(hPezRandom.flydetect,'Value') == 0
            messageFun('Enable fly detect')
            return
        elseif strcmp(tExpt.Running,'off')
            exptdur = get(hExptEntry.duration,'string');
            if isempty(exptdur)
                messageFun('Set runtime')
                return
            end
            set(tExpt,'StartDelay',str2double(exptdur)*60)
            % date folder check
            currDate = datestr(date,'yyyymmdd');
            destDatedDir = fullfile(data_dir,currDate);
            % new expt folder
            runFolderCount = dir(fullfile(destDatedDir,'run*'));
            runIndex = numel({runFolderCount(:).name});
            runFolder = ['run',sprintf('%03.0f',runIndex),'_',pezName,'_',currDate];
            runPath = fullfile(destDatedDir,runFolder);
            runStatsDest = fullfile(runPath,[runFolder,'_runStatistics.mat']) %path to save runStatistics
            if exist(runStatsDest,'file') ~= 2
                messageFun('No previous run found')
                return
            end
            runStatsLoading = load(runStatsDest);
            runStats = runStatsLoading.runStats;
            runStats.time_stop = [];
            save(runStatsDest,'runStats')
            set(hPezRandom.runauto,'Value',1)
            runAutoPilotCall([],[])
            start(tExpt)
        else
            messageFun('Experiment already in progress')
        end
    end
    function runexptCallback(~,~)
        if get(hPezRandom.flydetect,'Value') == 0
            messageFun('Enable fly detect')
            return
        elseif strcmp(tExpt.Running,'off')
            exptdur = get(hExptEntry.duration,'string');
            if isempty(exptdur)
                messageFun('Set runtime')
                return
            end
            if isempty(get(hExptEntry.experiment,'string'))
                messageFun('Enter a valid experiment ID')
                return
            end
            set(tExpt,'StartDelay',str2double(exptdur)*60)
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
            mkdir(runPath)
            runStats(1).time_start = datestr(now);
            runStats.experimentID = get(hExptEntry.experiment,'string');
            runStats.empty_count = 0;
            runStats.single_count = 0;
            runStats.multi_count = 0;
            runStats.diode_failures = 0;
            runStats.manager_notes = [];
            runStats.time_stop = [];
            save(runStatsDest,'runStats')
            set(hExptCtrl.pause,'enable','on')
            set(hExptCtrl.stop,'enable','on')
            set(hExptCtrl.extend,'enable','on')
            set(hExptCtrl.run,'enable','off')
            set(hPezRandom.runauto,'Value',1)
            runAutoPilotCall([],[])
            start(tExpt)
        else
            messageFun('Experiment already in progress')
        end
    end
    function savenotesCallback(~,~)
        currDate = datestr(date,'yyyymmdd');
        destDatedDir = fullfile(data_dir,currDate);
        % new expt folder
        runFolderCount = dir(fullfile(destDatedDir,'run*'));
        runIndex = numel({runFolderCount(:).name});
        runFolder = ['run',sprintf('%03.0f',runIndex),'_',pezName,'_',currDate];
        runPath = fullfile(destDatedDir,runFolder);
        runStatsDest = fullfile(runPath,[runFolder,'_runStatistics.mat']); %path to save runStatistics
        if exist(runStatsDest,'file') == 2
            messageFun('No previous run found')
            return
        end
        runStatsLoading = load(runStatsDest);
        runStats = runStatsLoading.runStats;
        runStats.manager_notes = get(hExptEntry.managernotes,'string');
        save(runStatsDest,'runStats')
    end
    function extendexptCallback(~,~)
        if strcmp(tExpt.Running,'on')
            stop(tExpt)
        end
        exptdur = get(hExptEntry.duration,'string');
        if isempty(exptdur)
            messageFun('Set runtime')
            return
        end
        set(tExpt,'Period',str2double(exptdur)*60)
        set(hPezRandom.runauto,'Value',1)
        runAutoPilotCall([],[])
        start(tExpt)
    end
    function pauseexptCallback(~,~)
        butStr = get(hExptCtrl.pause,'string');
        if strcmp(butStr,'Pause')
            if strcmp(tExpt.Running,'on')
                if strcmp(tDet.Running,'on'), stop(tDet), end
                stop(tExpt)
                set(hExptCtrl.pause,'string','Resume')
                set(hExptCtrl.stop,'enable','off')
                set(hExptCtrl.extend,'enable','off')
                set(hExptCtrl.resume,'enable','off')
                set(hPezRandom.runauto,'Value',0)
                set(hPezRandom.flydetect,'Value',0)
            end
        else
            if strcmp(tDet.Running,'off'), start(tDet), end
            start(tExpt)
            set(hExptCtrl.pause,'string','Pause')
            set(hExptCtrl.stop,'enable','on')
            set(hExptCtrl.extend,'enable','on')
            set(hExptCtrl.resume,'enable','on')
            set(hPezRandom.runauto,'Value',1)
            set(hPezRandom.flydetect,'Value',1)
        end
    end
    function stopexptCallback(~,~)
        if strcmp(tExpt.Running,'on'), stop(tExpt), end
        if strcmp(tDet.Running,'on'), stop(tDet), end
        set(hPezRandom.runauto,'Value',0)
        set(hPezRandom.flydetect,'Value',0)
        runStats.time_stop = datestr(now);
        save(runStatsDest,'runStats')
        runStats(1).time_start = [];
        runStats.experimentID = [];
        runStats.empty_count = 0;
        runStats.single_count = 0;
        runStats.multi_count = 0;
        runStats.diode_failures = 0;
        runStats.manager_notes = [];
        runStats.time_stop = [];
        set(hExptEntry.experiment,'string',[]);
        set(hExptCtrl.run,'enable','on')
        messageFun('Experiment done')
    end

% camera functions
    function dispCurrentSettings(~,~)
        set(hCamPop.width,'Value',find(nWidth == listWidthNum))
        set(hCamPop.height,'Value',find(nHeight == listHeightNum))
        set(hCamPop.recrate,'Value',find(nRate == nRecordRateList))
    end
    function applyNewSettings(~,~)
        if sDiode.IsRunning
            messageFun('Stop NIDAQ acquisition first')
            return
        end
        disp('applyNewSettings started')
        if strcmp(tPlay.Running,'on'), stop(tPlay), end
        nWidth = listWidthNum(get(hCamPop.width,'Value'));
        nHeight = listHeightNum(get(hCamPop.height,'Value'));
        nRate = nRecordRateList(get(hCamPop.recrate,'Value'));
        nXPos = nWidthMax/2-nWidth/2;
        nYPos = nHeightMax/2-nHeight/2;
        nFps = nShutterList(nShutterSize);
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
        pause(0.1)
        disp('shutter')
        [nRet,nErrorCode] = PDC_SetVariableChannelInfo(nDeviceNo,...
            nChannel,nRate,nWidth,nHeight,nXPos,nYPos);
        pause(0.1)
        disp('set channel info')
        [nRet,nErrorCode] = PDC_SetVariableChannel(nDeviceNo,nChildNo,nChannel);
        pause(0.3)
        disp('set channel')
        [nRet,nShutterSize,nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nDeviceNo,nChildNo);
        nFps = nShutterList(1);
        disp('get shutter speed')
        [nRet, nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo, nChildNo, nFps);
        pause(0.1)
        disp('set shutter speed')
        listShutter = arrayfun(@(x) cellstr(int2str(x)),(nShutterList(nShutterList > 0)));
        if ~isempty(listShutter)
        listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
        set(hCamPop.shutter,'String',listShutter,'Value',1);
        end
        [nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
        sDiode.Rate = double(nFps*overSampleFactor);
        sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
        boxRatio = double([nWidth nHeight])./double(max(nWidth,nHeight));
        boxRatio(3) = 1;
        set(hAxesA,'xlim',[1 nWidth],'ylim',[1 nHeight],...
            'PlotBoxAspectRatio',boxRatio)
        
        disp('triggerModeCallback called')
        triggerModeCallback([],[])
        disp('triggerModeCallback passed')
        camStateCallback([],[])
        disp('applyNewSettings complete')
    end
    function shutterSpeedCallback(~,~)
        if strcmp(tPlay.Running,'on'), stop(tPlay), end
        nFps = nShutterList(get(hCamPop.shutter,'Value'));
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
        camStateCallback([],[])
    end
    function bitshiftCallback(~,~)
        shiftOps = fliplr(0:4);
        sourceVal = get(hCamPop.bitshift,'Value');
        n8BitSel = shiftOps(sourceVal);
        [nRet, nErrorCode] = PDC_SetTransferOption(nDeviceNo,nChildNo,n8BitSel,nBayer,nInterleave);
    end
    function calibrateCallback(~,~) %calibrate camera
        fwrite(sPez,sprintf('%s %u\r','I',0));
        fwrite(sPez,sprintf('%s %u\r','L',0));
        pause(1)
        [nRet,nErrorCode] = PDC_SetShadingMode(nDeviceNo,nChildNo,2);
        pause(1)
        IRlightsCallback([],[])
    end
    function dispLiveImage(~,~)
        try
            [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,...
                nBitDepth,nColorMode,nBayer,nWidth,nHeight);
            frmData = nBuf';
            set(hImA,'CData',frmData)
            if boolFoc, focusFun, end
            flyDetect([],[])
            updateGatePlot
            drawnow
        catch ME
            getReport(ME)
        end
    end
    function updateGatePlot
        if ~isempty(gatePosMCU)
            posCell = textscan(gatePosMCU,'%u%u','delimiter',',');
            set(hPezSlid.open,'Min',posCell{1},'Max',posCell{2},'Value',posCell{1});
            set(hPezSlid.block,'Min',posCell{1},'Max',posCell{2},'Value',posCell{2});
            hOpen1Callback([],[])
            hBlock1Callback([],[])
            gatePosMCU = [];
        end
        if ~isempty(gateStateMCU)
            gateStateMCU = fscanf(sPez);
            stateCell = textscan(gateStateMCU,'%u%s','delimiter',',');
            if (stateCell{1} == 1)
                stateRef = strfind('OBCH',stateCell{2}{1});
                if stateRef == 2
                    if detectResetTab
                        if strcmp(tDet.Running,'on'),stop(tDet),start(tDet),end
                        detectResetTab = false;
                    end
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
            set(hPezReport.flycount,'String',[num2str(inpCell{1}) num2str(inpCell{2})]);
            inplineMCU = [];
        end
    end
    function hDispROICall(~,~)
        if isempty(roiPos)
            set(hTxtMsgA,'string','Set ROI first')
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
            rateVal = get(hCamPop.recrate,'Value');
            set(hCamPop.recrate,'Value',tempVal)
            applyNewSettings
            fwrite(sPez,sprintf('%s %u\r','I',40));
            wRate = rateVal;
            while wRate ~= tempVal
                [nRet,nRate,nErrorCode] = PDC_GetRecordRate(nDeviceNo,nChildNo);
                wRate = find(nRate == nRecordRateList);
            end
            bitVal = get(hCamPop.bitshift,'Value');
            set(hCamPop.bitshift,'Value',1)
            nRet = 0;
            bitshiftCallback
            while nRet == 0, end
            set(hPezRandom.showback,'UserData',[rateVal bitVal])
        else
            userVals = get(hPezRandom.showback,'UserData');
            rateVal = userVals(1);
            bitVal = userVals(2);
            wRate = rateVal;
            IRlightsCallback([],[])
            set(hCamPop.recrate,'Value',rateVal)
            applyNewSettings
            while wRate ~= rateVal
                [nRet,nRate,nErrorCode] = PDC_GetRecordRate(nDeviceNo,nChildNo);
                wRate = find(nRate == nRecordRateList);
            end
            set(hCamPop.bitshift,'Value',bitVal)
            nRet = 0;
            bitshiftCallback
            while nRet == 0, end
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
        toggleChildren(hPanelsMain,0)
        try
            if get(hPezRandom.showback,'Value') == 0
                set(hPezRandom.showback,'Value',1)
                highlightBackground
            end
            if strcmp(tPlay.Running,'on'), stop(tPlay), end
            dispLiveImage
            nRet = 0;
            dispLiveImage
            while nRet == 0, end
            threshVal = str2double(get(hPezRandom.autothresh,'string'));
            grth = graythresh(frmData)*threshVal;
            frmGr = im2bw(frmData,grth);
            set(hImA,'CData',frmGr.*255)
            drawnow
            pause(2)
            set(hImA,'CData',frmData)
            drawnow
            [rBW,cBW] = find(frmGr);
            [cBWu,ui] = unique(cBW);
            rBWu = rBW(ui);
            xFind = double(round([nWidth*0.2,nWidth*0.8]));
            xFind = [find(cBWu > xFind(1),1),find(cBWu > xFind(2),1)];
            pp = polyfit(cBWu(xFind(1):xFind(2)),rBWu(xFind(1):xFind(2)),1);
            stageY = polyval(pp,cBWu(xFind(1):xFind(2)));
            stageX = cBWu(xFind(1):xFind(2));
            stagePos = [stageX(:),stageY(:)];
            sideNdx = round(max(stageY))+200;
            frmBot = frmData(sideNdx:end,:,1);
            frmBotBW = im2bw(frmBot,graythresh(frmBot)*(threshVal+0.5));
            [rBotBW,cBotBW] = find(frmBotBW);
            roiSwell = 5;
            roiPos = [min(cBotBW)-roiSwell,min(rBotBW)+sideNdx-roiSwell,...
                max(cBotBW)+roiSwell,max(rBotBW)+sideNdx+roiSwell];
            
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
            pause(3)
            hDispROICall
            camStateCallback([],[])
            toggleChildren(hPanelsMain,1)
        catch ME
            getReport(ME)
            toggleChildren(hPanelsMain,1)
        end
    end
    function setFlydetectCall(~,~)
        if isempty(roiPos)
            set(hTxtMsgA,'string','Set ROI first')
            set(hPezRandom.flydetect,'Value',0)
        elseif get(hPezRandom.flydetect,'Value') == 1
            if strcmp(tDet.Running,'off'), start(tDet), end
        elseif get(hPezRandom.flydetect,'Value') == 0
            if strcmp(tDet.Running,'on'), stop(tDet), end
        end
    end
    function runAutoPilotCall(~,~)
        disp('runAutoPilotCall started')
        if get(hPezRandom.runauto,'Value') == 0
            return
        end
        if get(hPezRandom.flydetect,'Value') == 0
            messageFun('Engage fly detect first')
            set(hPezRandom.runauto,'Value',0)
            return
        end
%         if get(hPezMode.parent,'SelectedObject') == hPezMode.child(2)
%             set(hPezMode.parent,'SelectedObject',hPezMode.child(1));
%             pezMonitorFun
%         end
%         fwrite(sPez,sprintf('%s\r','V'));
        if get(hPezRandom.runauto,'Value') == 1
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            detectTabs = 0;
            hSweepGateCallback
            [nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
            if nStatus ~= PDC.STATUS_LIVE
                [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
                if nRet == PDC.FAILED, messageFun(['SetStatus Error ' int2str(nErrorCode)]), end
                if nRet == PDC.FAILED, disp(['SetStatus Error ' int2str(nErrorCode)]), end
            end
            pause(2)
            for iterBack = 1:10
                nRet = 0;
                [nRet,~,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
                while nRet == 0, end
            end
            backgrArray = uint8(zeros(double([nHeight,nWidth,30])));
            for iterBack = 1:30
                nRet = 0;
                [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
                while nRet == 0, end
                backgrArray(:,:,iterBack) = nBuf';
            end
            backgrFrm = max(backgrArray,[],3);
            set(hCamStates.parent,'SelectedObject',hCamStates.children(3))
            hCamStates.children(3)
            camStateCallback([],[])
            if get(hGateMode.parent,'SelectedObject') ~= hGateMode.child(2)
                set(hGateMode.parent,'SelectedObject',hGateMode.child(2))
                hAutoButtonCallback([],[])
            end
            set(hGateState.parent,'SelectedObject',hGateState.child(1))
            gateSelectCallback([],[])
            if strcmp(tDet.Running,'off'),start(tDet), end
            messageFun('Autopilot initialization complete')
            if strcmp(tPlay.Running,'off'),start(tPlay),end
        end
        disp('runAutoPilotCall completed')
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
        detectTabs = 0;
        hSweepGateCallback
        pause(1)
        set(hGateState.parent,'SelectedObject',hGateState.child(1))
        gateSelectCallback([],[])
        detectResetTab = true;
        if strcmp(tDet.Running,'off'),disp('resetDetectFun tDet was off'),start(tDet),end
        
%         %%%%%%%%%%%%% for testing purposes only!!!!!
%         set(hGateState.parent,'SelectedObject',hGateState.child(2))
%         gateSelectCallback([],[])
%         triggerCallback([],[])
%         %%%%%%%%%%%%%
        
    end
    function flyDetect(~,~)
%         if rateCounter == 0
%             tic
%             rateCounter = 1;
%         else
%             rateCounter = rateCounter+1;
%             if rateCounter >= 120
%                 totTime = toc;
%                 disp(['Average rate: ',num2str(rateCounter/totTime,2) ' per second']);
%                 rateCounter = 0;
%             end
%         end

        if get(hPezRandom.flydetect,'Value') == 0, return, end
        
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
        
        if detectResetTab
            if strcmp(tDet.Running,'on'),stop(tDet),start(tDet),end
            detectResetTab = false;
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
        
        
        posThresh = 5;%still not sure what values these should have
        dirThresh = 10;%still not sure what values these should have
        if detectTabs(1) == 4
            posDelta = sqrt(sum(detectTabs(2:3).^2));
            dirDelta = detectTabs(4);
            if posDelta < posThresh && dirDelta < dirThresh
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
            focTab(3:6) = round([min(stagePos(:,1)),max(stagePos(:,1)),...
                mean(stagePos(:,2))-100,mean(stagePos(:,2))-10]);
            focDims = [focTab(6)-focTab(5),focTab(4)-focTab(3)];
            xOpsVec = (1:2:focDims(2));
            yOpsVec = (1:2:focDims(1));
            xFoc = [xOpsVec,repmat(focDims(2),1,numel(yOpsVec))...
                xOpsVec,ones(1,numel(yOpsVec))]+focTab(3);
            yFoc = [ones(1,numel(xOpsVec)),yOpsVec,...
                repmat(focDims(1),1,numel(xOpsVec)),yOpsVec]+focTab(5);
            set(hPlotROI,'XData',xFoc,'YData',yFoc,'Visible','on')
            boolFoc = true;
        else
            delete(get(hAxesT,'Children'))
            set(hAxesT,'Visible','off')
            boolFoc = false;
            focTab = zeros(6,1);
            hSweepGateCallback
            removePlot
        end
    end
    function focusFun
        delete(get(hAxesT,'Children'))
        focusIm = frmData(focTab(5):focTab(6),focTab(3):focTab(4));
        FM = fmeasure(focusIm,'SFRQ',[]);
        switch focTab(1)
            case 0
                FocStr = '1: Turn focus knob one direction';
                focTab(1) = 1;
                focTab(2) = FM;
            case 1
                FocStr = '1: Turn focus knob one direction';
                if FM > focTab(2), focTab(2) = FM; end
                focDrop = (focTab(2)-FM)/focTab(2);
                if focDrop > 0.3
                    focTab(1) = 2;
                    focTab(2) = FM;
                end
            case 2
                FocStr = '2: Turn focus knob the OTHER way';
                if FM > focTab(2), focTab(2) = FM; end
                focDrop = (focTab(2)-FM)/focTab(2);
                if focDrop > 0.2
                    focTab(1) = 3;
                end
            case 3
                FocStr = {'3: Turn focus knob slowly the FIRST way';
                        'until the lines are as close as possible'};
                xF = [-10 10 NaN -10 10];
                FM = 1-(focTab(2)-FM)/focTab(2)*3;
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
    function camStateCallback(~,~)
        disp('camStateCallback started')
        if strcmp(get(hCamPlaybackSlider,'enable'),'on')
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            set(tPlay,'TimerFcn',@dispLiveImage,'Period',liveRate);
            set(hCamPlayback.parent,'SelectedObject',[])
            set(hCamPlayback.children(:),'enable','inactive')
            set(hCamPlaybackSlider,'enable','inactive')
        end
        set(hCamBtns.trig,'enable','off')
        set(hCamBtns.review,'enable','off')
        set(hCamBtns.download,'enable','off')
        butValN = get(hCamStates.parent,'SelectedObject');
        caseVal = find(butValN == hCamStates.children);
        [nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
        switch caseVal
            case 1
                if nStatus ~= PDC.STATUS_LIVE
                    [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
                    if nRet == PDC.FAILED, messageFun(['SetStatus Error ' int2str(nErrorCode)]), end
                end
                if strcmp(tPlay.Running,'off'),start(tPlay),end
            case 2
                if strcmp(tPlay.Running,'on')
                    stop(tPlay)
                elseif nStatus == PDC.STATUS_RECREADY
                    [nRet,nErrorCode] = PDC_TriggerIn(nDeviceNo);
                elseif nStatus == PDC.STATUS_RECREADY
                    [nRet,nErrorCode] = PDC_TriggerIn(nDeviceNo);
                end
            case 3
                nTrigRef = get(hCamPop.trigmode,'Value');
                if nTrigRef == 1
                    if nStatus ~= PDC.STATUS_RECREADY
                        [nRet,nErrorCode] = PDC_SetRecReady(nDeviceNo);
                    end
                else
                    if nStatus ~= PDC.STATUS_ENDLESS
                        [nRet,nErrorCode] = PDC_SetRecReady(nDeviceNo);
                        [nRet,nErrorCode] = PDC_SetEndless(nDeviceNo);
                    end
                end
                if nRet == PDC.FAILED, messageFun(['SetStatus Error ' int2str(nErrorCode)]), end
                set(hCamBtns.trig,'enable','on')
                set(hCamStates.children,'enable','off')
        end
        disp('camStateCallback completed')
    end
    function partcountCallback(~,~)
        if sDiode.IsRunning
            messageFun('Stop NIDAQ acquisition first')
            return
        end
        nCount = partitionOps(get(hCamPop.partcount,'value'));
        partitionAvail = (1:nCount);
        set(hCamPop.partition,'string',cellstr(num2str(partitionAvail')))
        [nRet,nErrorCode] = PDC_SetPartitionList(nDeviceNo,nChildNo,nCount,[]);
        [nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
        sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
        set(hCamPop.partition,'value',1)
        partitionCallback([],[])
    end
    function partitionCallback(~,~)
        nNo = get(hCamPop.partition,'value');
        [nRet,nErrorCode] = PDC_SetCurrentPartition(nDeviceNo,nChildNo,nNo);
        triggerModeCallback([],[])
    end
    function framesEditCallback(~,~)
        if sDiode.IsRunning
            messageFun('Stop NIDAQ acquisition first')
            return
        end
        frmsB4 = str2double(get(hCamEdit.beforetrig,'string'));
        frmsAftr = str2double(get(hCamEdit.aftertrig,'string'));
        totFrm = frmsB4+frmsAftr+1;
        resetFrms = false;
        if totFrm > nFrames
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
                nAFrames = frmsAftr;
                [nRet,nErrorCode] = PDC_SetTriggerMode(nDeviceNo,nTrigMode,nAFrames,nRFrames,nRCount);
        end
        
        if resetFrms
            frmsB4 = get(hCamEdit.beforetrig,'UserData');
            frmsAftr = get(hCamEdit.aftertrig,'UserData');
            set(hCamEdit.beforetrig,'string',num2str(frmsB4))
            set(hCamEdit.beforetrig,'string',num2str(frmsAftr))
        else
            durB4 = double(frmsB4)/double(nRate);
            durAftr = double(frmsAftr)/double(nRate);
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
        if sDiode.IsRunning
            messageFun('Stop NIDAQ acquisition first')
            return
        end
        nTrigRef = get(hCamPop.trigmode,'Value');
        nAFrames = 0;
        nRFrames = 0;
        nRCount = 0;
        nTrigMode = nTriggerModeList(nTrigRef);
        set(hCamEdit.beforetrig,'enable','on')
        set(hCamEdit.aftertrig,'enable','on')
        set(hCamEdit.durbefore,'enable','on')
        set(hCamEdit.durafter,'enable','on')
        switch nTrigRef
            case 1
                frmsB4 = 0;
                frmsAftr = nFrames-1;
                set(hCamEdit.beforetrig,'enable','inactive')
                set(hCamEdit.durbefore,'enable','inactive')
                testReady = @(x) max(x) > 4;
                testTrigger = @(x) min(x) < 1;
            case 2
                frmsB4 = (nFrames-1)/2;
                frmsAftr = (nFrames-1)/2;
                testReady = @(x) max(x) > 4;
                testTrigger = @(x) min(x) < 1;
            case 3
                frmsB4 = nFrames-1;
                frmsAftr = 0;
                set(hCamEdit.aftertrig,'enable','inactive')
                set(hCamEdit.durafter,'enable','inactive')
                testReady = @(x) max(x) > 4;
                testTrigger = @(x) min(x) < 1;
            case 4
                frmsAftr = (nFrames-1)/2;
                nAFrames = frmsAftr;
                frmsB4 = frmsAftr;
                testReady = @(x) max(x) > 4;
                testTrigger = @(x) min(x) < 1;
        end
        set(hCamEdit.beforetrig,'String',num2str(frmsB4),'UserData',frmsB4)
        set(hCamEdit.aftertrig,'String',num2str(frmsAftr),'UserData',frmsAftr)
        [nRet, nErrorCode] = PDC_SetTriggerMode(nDeviceNo,nTrigMode,nAFrames,nRFrames,nRCount);
        set(hCamEdit.frminmem,'string',num2str(nFrames))
        durrec = double(nFrames)/double(nRate);
        durB4 = double(frmsB4)/double(nRate);
        durAftr = double(frmsAftr)/double(nRate);
        durstr = [num2str(round(durrec*1000)) ' ms'];
        durB4str = [num2str(round(durB4*1000)) ' ms'];
        durAftrStr = [num2str(round(durAftr*1000)) ' ms'];
        set(hCamEdit.durinmem,'string',durstr,'UserData',durrec)
        set(hCamEdit.durbefore,'string',durB4str,'UserData',durB4)
        set(hCamEdit.durafter,'string',durAftrStr,'UserData',durAftr)
    end
    function triggerCallback(~,~)
        disp('triggerCallback started')
        hTimers = timerfindall;
        timerStates = cell(1,size(hTimers,2));
        for iT = 1:size(hTimers,2)
            timerStates{iT} = hTimers(iT).Running;
            if strcmp(timerStates{iT},'on'),stop(hTimers(iT)),end
        end
%         if strcmp(tDet.Running,'on'),stop(tDet),end
%         if strcmp(tPlay.Running,'on'),stop(tCam),end
%         if strcmp(tMsg.Running,'on'),stop(tMsg),end
%         if get(hPezMode.parent,'SelectedObject') == hPezMode.child(1)
%             set(hPezMode.parent,'SelectedObject',hPezMode.child(2));
%             pezMonitorFun
%         end
%         fwrite(sPez,sprintf('%s\r','N'));
%         drawnow
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            displayVisStim([],[])
        else
            [nRet,nErrorCode] = PDC_TriggerIn(nDeviceNo);
            if get(hPezRandom.photocouple,'Value') == 1
                photoDisplayCall([],[])
            end
        end
%         messageFun('Trigger')
        waitTime = get(hCamEdit.durinmem,'userdata')-get(hCamEdit.durbefore,'userdata');
        pause(waitTime)
        set(hCamBtns.trig,'enable','off')
        set(hCamBtns.review,'enable','on')
        set(hCamStates.children,'enable','on')
        set(hCamStates.parent,'SelectedObject',hCamStates.children(2));
        for iT = 1:size(hTimers,2)
            if strcmp(timerStates{iT},'on'),start(hTimers(iT)),end
        end
        if strcmp(tPlay.Running,'on'),stop(tPlay),end
        
        if get(hPezRandom.runauto,'Value') == 1
            reviewMemoryCallback([],[])
        else
            drawnow
%             fwrite(sPez,sprintf('%s\r','N'));
%             set(hPezMode.parent,'SelectedObject',hPezMode.child(1));
%             pezMonitorFun
        end
        disp('triggerCallback complete')
    end
    function reviewMemoryCallback(~,~)
        disp('reviewMemoryCallback started')
%         set(hCamStates.parent,'SelectedObject',[]);
%         set(hCamStates.children,'enable','off')
        frmsB4 = str2double(get(hCamEdit.beforetrig,'string'));
        frmsAftr = str2double(get(hCamEdit.aftertrig,'string'));
        nTrigRef = get(hCamPop.trigmode,'Value');
        switch nTrigRef
            case 1
                frmVecRef = (1:frmsAftr);
            case 3
                frmVecRef = (nFrames-frmsB4+1:nFrames);
            otherwise
                frmVecRef = [(nFrames-frmsB4-1:nFrames),(1:frmsAftr-1)];
        end
        frmCount = numel(frmVecRef);
        frmOps = (1:frmCount)';
        set(hCamPlaybackSlider,'Max',frmCount,'Min',1,'Value',1)
        [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_PLAYBACK);
        set(hCamPlayback.children(:),'enable','on')
        set(hCamPlaybackSlider,'enable','on')
        set(hCamBtns.review,'enable','off')
        set(hCamBtns.download,'enable','on')
        if get(hPezRandom.runauto,'Value') == 1
            downloadRecordingCallback([],[])
%             runAutoPilotCall([],[])
        else
            drawnow
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
        drawnow
        try
            downloadRecordingFun
            toggleChildren(hPanelsMain,1)
        catch ME
            toggleChildren(hPanelsMain,1)
            getReport(ME)
        end
        drawnow
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
            exptID = '';
        else
            exptID = ['_expt' get(hExptEntry.experiment,'string')];
        end
        
        
        [nRet,memFrameInfo,nErrorCode] = PDC_GetMemFrameInfo(nDeviceNo,nChildNo);
        [nRet,memRate,nErrorCode] = PDC_GetMemRecordRate(nDeviceNo,nChildNo);
        [nRet,memWidth,memHeight,nErrorCode] = PDC_GetMemResolution(nDeviceNo,nChildNo);
        memFrmCount = frmCount;
        
        autoDiscard = get(hExptCtrl.autodiscard,'Value') == 1;
        discardBool = 0;
        diodeDecision = [];
        diodeData2save = [];
        lightData2save = [];
        frmVecRefCutrate10th = [];
        frmVecRefSuppl = [];
        
        compressStrOps = {'MPEG-4','Grayscale AVI'};
        compressString = compressStrOps{get(hCamPop.compressmethod,'value')};
        videoExtOps = {'.mp4','.avi'};
        videoExtStr = videoExtOps{get(hCamPop.compressmethod,'value')};
        
        % prepare file names
        video_files = dir(fullfile(runPath,['*' videoExtStr]));
        vid_count = numel({video_files(:).name});
        vidName = [runFolder,exptID,'_vid',sprintf('%04.0f',vid_count+1)];
        vidStatsDest = fullfile(runPath,[runFolder,'_videoStatistics.mat']); %path to save vidStatistics
        
        % makes blank background if none found, otherwise saves it
        if get(hPezRandom.runauto,'Value') == 0
            backgrFrm = uint8(zeros(double(nHeight),double(nWidth)));
        end
        
        % examines first frame if autodiscard is selected
        if autoDiscard
            [nRet, nData, nErrorCode] = PDC_GetMemImageData(nDeviceNo,nChildNo,frmVecRef(1),nBitDepth,nColorMode,nBayer,nWidth,nHeight);
            frmOne = nData'-backgrFrm;
            frmOne(frmOne < 0) = 0;
            [flycount,counterIm] = flyCounter_3000(frmOne(1:nWidth,:));
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
        testA = get(hPezRandom.couple,'Value') == 1;
        testB = get(hPezRandom.photocouple,'Value') == 1;
        testData = true;
        if testA || testB
            diodeDataProcessed = mean(reshape(diodeData,overSampleFactor,...
                numel(diodeData)/overSampleFactor));
            lightDataProcessed = mean(reshape(lightData,overSampleFactor,...
                numel(lightData)/overSampleFactor));
            if numel(diodeDataProcessed) < nFrames
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
                    diodeData2save = diodeDataProcessed(nFrames-frmCount+1:nFrames);
                    lightData2save = lightDataProcessed(nFrames-frmCount+1:nFrames);
            end
        end
        if testA && testData
            stimDwellTime = memRate/360;
            lightThreshNdx = round(whiteCt*stimDwellTime*0.5);
            darkThreshNdx = round((double(frmCount)-whiteCt*stimDwellTime)*0.9);
            sortedData = sort(diodeData2save);
            avgBase = mean(sortedData(end-darkThreshNdx:end));
            avgPeak = abs(mean(sortedData(1:lightThreshNdx))-avgBase);
            photoTestA = avgPeak/range(sortedData(end-darkThreshNdx:end));
            if photoTestA < 10
                diodeDecision = 'signal to noise ratio insufficient';
                if autoDiscard
                    discardBool = 2;
                    closeDownload
                    return
                end
            else
                pkThresh = avgPeak/2;
                dataNorm = abs(diodeData2save-avgBase);
                minPkHt = pkThresh*0.75;
                dataNorm(dataNorm > pkThresh) = pkThresh;
                minPkDist = floor(stimDwellTime)-1;
                [peakVals,peakPos] = findpeaks(dataNorm,'MINPEAKHEIGHT',minPkHt,'MINPEAKDISTANCE',minPkDist);
                flipLengths = diff(peakPos);
                peakRange = range(flipLengths);
                if peakRange > 2
                    diodeDecision = 'frames were dropped';
                    if autoDiscard
                        discardBool = 2;
                        closeDownload
                        return
                    end
%                 elseif numel(peakPos) < whiteCt
%                     diodeDecision = 'visual stimulus incomplete';
%                     if autoDiscard
%                         discardBool = 2;
%                         closeDownload
%                         return
%                     end
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
            diodeData = diodeData.*0;
        end
        messageFun(diodeDecision)
        if testB && testData
%             figure,plot(lightData)
%             figure,plot(lightData2save)
%             uiwait
%             return
            lightData = lightData.*0;
        end
        
        % saving the background frame
        backgrFolder = fullfile(runPath,'backgroundFrames');
        if ~isdir(backgrFolder), mkdir(backgrFolder), end
        backfrName = [runFolder,'_backgroundFrame',sprintf('%04.0f',vid_count+1),'.tif'];
        backgrDest = fullfile(backgrFolder,backfrName); %path to save background
        imwrite(backgrFrm,backgrDest,'tif')
        
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
            
            frmCountRoundedTenth = round(frmCount/10)*10;
            frmVecRef = frmVecRef(1:frmCountRoundedTenth);
            frmMatRefTenth = reshape(frmVecRef,10,frmCountRoundedTenth/10);
            frmVecRefTenth = frmMatRefTenth(1,:);
            [~,frmVecRefCutrate10th] = ismember(frmVecRefTenth,frmVecRef);
            frmCountTenth = numel(frmVecRefTenth);
            deltaPix = zeros(1,frmCountTenth-1);
            tic
            for iterFrm = 1:frmCountTenth
                frmRef = frmVecRefTenth(iterFrm);
                [nRet,nData,nErrorCode] = PDC_GetMemImageData(nDeviceNo,...
                    nChildNo,frmRef,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
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
                totFrames = double(nFrames);
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
                [nRet,nData,nErrorCode] = PDC_GetMemImageData(nDeviceNo,...
                    nChildNo,frmRef,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
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
                    {{diodeData2save},'diode_data'},{{imageDest},'inspection_image_path'},...
                    'ObsNames',{obsName});
                autoResults = [autoResults;autoResults2add];
                save(autoResultsDest,'autoResults')
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
                trigMode = listTrigger{nTrigRef};
                IRlights = round(get(hPezSlid.IRlights,'Value'));
                azifly = str2double(get(hPezRandom.aziFly,'string'));
                dwnLoadOp = downloadStrCell{get(hExptEntry.downloadops,'value')};
                visStimInfo.nidaq_data = diodeData2save;
                activationInfo.nidaq_data = lightData2save;
                vidStats2add = dataset({{vidName},'videoID'},{{memFrameInfo.m_nTrigger},'trigger_timestamp'},...
                    {{nDeviceName},'device_name'},{memWidth,'frame_width'},{memHeight,'frame_height'},...
                    {memFrmCount,'frame_count'},{memRate,'record_rate'},{nFps,'shutter_speed'},...
                    {n8BitSel,'bit_shift'},{{trigMode},'trigger_mode'},{tempMCU,'temp_degC'},...
                    {humidMCU,'humidity_percent'},{IRlights,'IR_light_internsity'},{azifly,'fly_detect_azimuth'},...
                    {{roiPos},'roi'},{{stagePos},'prism_base'},{{frmVecRefCutrate10th},'cutrate10th_frame_reference'},...
                    {{frmVecRefSuppl},'supplement_frame_reference'},{{dwnLoadOp},'download_option'},...
                    {{visStimInfo},'visual_stimulus_info'},{{activationInfo},'photoactivation_info'},'ObsNames',{vidName});
                vidStats = [vidStats;vidStats2add];
                save(vidStatsDest,'vidStats')
                visStimInfo = struct;
                activationInfo = struct;
                diodeData2save = diodeData2save.*0;
                lightData2save = lightData2save.*0;
            end
            if get(hPezRandom.runauto,'Value') == 1
                runAutoPilotCall([],[])
            end
            disp('downloadRecordingCallback complete')
        end
    end

% playback functions
    function playbackRateCallback(~,eventdata)
        butValN = eventdata.NewValue;
        frmRate = speedOps(butValN == hCamPlayback.children);
        if frmRate ~= 0
            perVal = round((1/abs(frmRate))*100)/100;
            if perVal > 0.001
                frmDelta = abs(frmRate)/frmRate;
                if strcmp(tPlay.Running,'on'),stop(tPlay),end
                set(tPlay,'Period',perVal,'TimerFcn',@timerVidFun)
                if strcmp(tPlay.Running,'off'),start(tPlay),end
            end
        else
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            frmDelta = 0;
        end
    end
    function timerVidFun(~,~)
        frmOps = circshift(frmOps,-frmDelta);
        set(hCamPlaybackSlider,'Value',frmOps(1))
        playbackDisp
    end
    function PosClickCallback(~,~)
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
    function hPlaybackCallback(~,~)
        frmNum = round(get(hCamPlaybackSlider,'Value'));
        playbackDisp
        frmOff = find(frmOps == frmNum);
        frmOps = circshift(frmOps,-frmOff+1);
    end
    function playbackDisp
        nFrameNo = frmVecRef(round(get(hCamPlaybackSlider,'Value')));
        [nRet,nData,nErrorCode] = PDC_GetMemImageData(nDeviceNo,nChildNo,nFrameNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
        if nRet == PDC.FAILED
            messageFun(['Error: ' num2str(nErrorCode)])
        end
        frmData = (nData');
        fD = double(frmData);
        fD = (fD-min(fD(:)))./range(fD(:));
        frmData = uint8(fD.*255);
        set(hImA,'CData',frmData)
        drawnow
    end

%snap shot of single frame
    function captureSingleCallback(~,~)
        imageCap = flipud(frmData);
        currDate = datestr(date,'yyyymmdd');
        currTime = datestr(rem(now,1),'HHMMSS');
        capDest = fullfile(snapDir,[currDate '_' currTime '.tif']);
        imwrite(imageCap,capDest,'tif')
    end
%photostimulation
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
%         if strcmp(tSquareWaveOn.Running,'on'), stop(tSquareWaveOn), end
%         set(tSquareWaveOn,'Period',(photo.TimeHigh+photo.TimeLow)/1000,...
%             'TasksToExecute',photo.Cycles)
%         if strcmp(tSquareWaveOff.Running,'on'), stop(tSquareWaveOff), end
%         set(tSquareWaveOff,'Period',(photo.TimeHigh+photo.TimeLow)/1000,...
%             'TasksToExecute',photo.Cycles,'StartDelay',photo.TimeHigh/1000)
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
%         if strcmp(tLinearRamp.Running,'on'), stop(tLinearRamp), end
%         set(tLinearRamp,'TasksToExecute',taskCt)
        set(hPezActivationEdit.powerbegin,'string',num2str(photo.PowerBegin))
        set(hPezActivationEdit.powerend,'string',num2str(photo.PowerEnd))
        set(hPezActivationEdit.duration,'string',num2str(photo.Duration))
    end
    function squareWaveOnFun(~,~)
        fwrite(sPez,sprintf('%s %u\r','L',photo.PowerHigh));
        pause(photo.TimeHigh/1000)
        fwrite(sPez,sprintf('%s %u\r','L',photo.PowerLow));
        activationInfo.method = 'square_wave';
        activationComplete([],[])
    end
%     function linearRampFun(~,~)
%         newPwr = photo.PowerBegin+photo.PowerStep*(tLinearRamp.TasksExecuted-1);
%         fwrite(sPez,sprintf('%s %u\r','L',round(newPwr)));
%         activationInfo.method = 'linear_ramp';
%     end
    function photoDisplayCall(~,~)
        selObj = get(hPhotoMode.parent,'SelectedObject');
        if selObj == hPhotoMode.child(1)
%             if strcmp(tSquareWaveOn.Running,'off')
%                 set(hPezButn.photodisplay,'string','Cancel')
                squareWaveOnFun([],[])
%                 start(tSquareWaveOn)
%             else
%                 set(hPezButn.photodisplay,'string','Execute')
%                 stop(tSquareWaveOn)
%             end
        else
%             if strcmp(tLinearRamp.Running,'off')
%                 set(hPezButn.photodisplay,'string','Cancel')
%                 start(tLinearRamp)
%             else
%                 set(hPezButn.photodisplay,'string','Execute')
%                 stop(tLinearRamp)
%             end
        end
    end
    function activationComplete(~,~)
        fwrite(sPez,sprintf('%s %u\r','L',0));
        set(hPezButn.photodisplay,'string','Execute')
        activationInfo.parameters = photo;
    end
% visual stimulus functions
    function visStimCallback(~,~)
        initState = get(hPezButn.initialize,'UserData');
        switch stimStrOps{get(visStimPop,'Value')}
            case 'Black disk on white background'
                initVersion = 'initA';
            case 'Crosshairs'
                initVersion = 'initB';
            case 'Calibration'
                initVersion = 'initB';
            case 'Grid'
                initVersion = 'initB';
            case 'Full on'
                initVersion = 'initA';
            case 'Full off'
                initVersion = 'initA';
            case 'Diode test'
                initVersion = 'initA';
        end
        if ~strcmp(initVersion,initState)
            set(hPezButn.display,'enable','off')
        else
            set(hPezButn.display,'enable','on')
        end
    end
    function initializeVisStim(~,~)
        initState = get(hPezButn.initialize,'UserData');
        switch stimStrOps{get(visStimPop,'Value')}
            case 'Black disk on white background'
                initVersion = 'initA';
            case 'Crosshairs'
                initVersion = 'initB';
            case 'Calibration'
                initVersion = 'initB';
            case 'Grid'
                initVersion = 'initB';
            case 'Full on'
                initVersion = 'initA';
            case 'Full off'
                initVersion = 'initA';
            case 'Diode test'
                initVersion = 'initA';
        end
        if ~strcmp(initVersion,initState)
            switch initVersion
                case 'initA'
                    stimStruct = initializeVisualStimulusGeneral;
                case 'initB'
                    window = simpleVisStimInitial;
                    varDest = 'C:\Users\cardlab\Documents\Photron_flyPez3000\visual_stimuli';
                    varName = [comp_name '_stimuliVars.mat'];
                    varPath = fullfile(varDest,varName);
                    stimTrigStruct = load(varPath);
                    stimTrigStruct.window = window;
            end
        end
        switch initVersion
            case 'initA'
                visParams.ellovervee = str2double(get(hPezRandom.eloverv,'string'));
                visParams.radiusbegin = str2double(get(hPezRandom.radiusbegin,'string'));
                visParams.radiusend = str2double(get(hPezRandom.radiusend,'string'));
                stimTrigStruct = initializeBlackDiskOnWhite(stimStruct,visParams);
                stimdurstr = num2str(round(stimTrigStruct.stimTotalDuration));
                set(hPezRandom.stimdur,'string',stimdurstr)
            case 'initB'
        end
        set(hPezButn.initialize,'UserData',initVersion)
        set(hPezButn.display,'enable','on');
    end
    function window = simpleVisStimInitial
        AssertOpenGL;
        if ~isempty(Screen('Windows')),Screen('CloseAll'),end
        % Select display with max id for our onscreen window:
        screenidList = Screen('Screens');
        for iterL = screenidList
            [width,~] = Screen('WindowSize', iterL);
            if width == 1024 || width == 1280
                screenid = iterL;
            end
        end
        [width,~]=Screen('WindowSize', screenid);%1024x768, old was 1280x720
        if width ~= 1024
            Screen('Resolution',screenid,1024,768,120)
        end
        window = Screen(screenid,'OpenWindow');
    end
    function displayVisStim(~,~)
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            deviceNoRef = nDeviceNo;
        else
            deviceNoRef = [];
        end
        
        switch stimStrOps{get(visStimPop,'Value')}
            case 'Black disk on white background'
                offset = str2double(get(hPezRandom.aziOff,'string'));
                azifly = str2double(get(hPezRandom.aziFly,'string'));
                stimTrigStruct(1).aziVal = azifly+offset;
                stimTrigStruct(1).eleVal = str2double(get(hPezRandom.ele,'string'));
                [missedFrames,whiteCt] = presentDiskStimulus(stimTrigStruct,deviceNoRef);
                messageFun(['Missed flip count: ' num2str(missedFrames)])
                visParams.azimuth = stimTrigStruct.aziVal;
                visParams.elevation = stimTrigStruct.eleVal;
                visStimInfo.parameters = visParams;
                visStimInfo.method = stimStrOps{get(visStimPop,'Value')};
            case 'Crosshairs'
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.crosshairsIm);
                Screen(stimTrigStruct.window,'Flip');
            case 'Calibration'
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.calibImB);
                Screen(stimTrigStruct.window,'Flip');
            case 'Grid'
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.gridIm);
                Screen(stimTrigStruct.window,'Flip');
            case 'Full on'
            case 'Full off'
            case 'Diode test'
                missedFrames = presentDiodeTest(stimTrigStruct,deviceNoRef);
                messageFun(['Missed flip count: ' num2str(missedFrames)])
        end
        if get(hPezRandom.alternate,'Value') == 1
            set(hPezRandom.aziOff,'string',num2str(-offset))
        end
    end
%nidaq control functions
    function coupleToCameraCall(~,~)
        testA = get(hPezRandom.couple,'Value') == 1;
        testB = get(hPezRandom.photocouple,'Value') == 1;
        testC = sDiode.IsRunning;
        if (testA || testB) && ~testC
            diodeDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            diodeDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            lightDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            lightDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            diodeData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            lightData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            recData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
            sDiode.startBackground();
        else
            stop(sDiode)
        end
    end
    function trigDetect(~,event)
        diodeDataB = event.Data(:,1);
        recData = event.Data(:,2);
        lightDataB = event.Data(:,3);
        
        recMax = round(max(recData));
        recMin = round(min(recData));
%         recState
        switch recState
            case 1
                if recMax == 5
                    diodeDataA = diodeDataB;
                    lightDataA = lightDataB;
                    recState = 2;
                end
            case 2
                if recMin == 0
                    endRef = find(recData < 1,1,'first');
                    diodeData = [diodeDataA;diodeDataB];
                    lightData = [lightDataA;lightDataB];
                    cropDataEnd = numel(recData)+endRef-1;
                    cropDataBegin = endRef;
                    diodeData = diodeData(cropDataBegin:cropDataEnd);
                    lightData = lightData(cropDataBegin:cropDataEnd);
                    diodeTimeStamps = event.TimeStamps;
                    recEndTime = diodeTimeStamps(endRef);
                    recState = 1;
                else
                    diodeDataA = diodeDataB;
                    lightDataA = lightDataB;
                end
        end
    end

%%%%%%% flyPez Control Functions %%%%%%%
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
        if newTemp > 30 || newTemp < 18
            messageFun('Temperature must be >18 and <30')
        else
            setTemp = newTemp;
            fwrite(sPez,sprintf('%s %u\r','Q',setTemp));
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
%         butnValN = get(hGateState.parent,'SelectedObject');
%         caseVal = find(butnValN == hGateState.child);
%         if caseVal == 1
            drawnow
            pause(0.5)
            fwrite(sPez,sprintf('%s\r','F'));
            pause(0.5)
%         else
%             messageFun('Set gate to ''Open'' state first');
%         end
%         set(hGateState.parent,'SelectedObject',hGateState.child(1))
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
        setGateFun
    end
    function hBlock1Callback(~,~)
        slider_value = round(get(hPezSlid.block,'Value'));
        set(hPezSlid.block,'Value',slider_value);
        set(hPezReport.closepos,'String',...
            ['Block position: ' num2str(slider_value) ' ------'])
        setGateFun
    end
    function setGateFun
        fwrite(sPez,sprintf('%s %u %u\r','D',get(hPezSlid.open,'Value'),get(hPezSlid.block,'Value')));
        gateSelectCallback([],[])
    end

% Fly Count Recording Function
    function flyCountCallback(~,~)
        fwrite(sPez,sprintf('%s\r','T'));
        set(hPezReport.flycount,'String','0');
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


% close and clean up
    function myCloseFun(~,~)
        sca
        hTimers = timerfindall;
        for iT = 1:size(hTimers,2)
            if strcmp(hTimers(iT).Running,'on'),stop(hTimers(iT)),end
        end
        delete(hTimers)
        fclose('all');
        testA = get(hPezRandom.couple,'Value') == 1;
        testB = get(hPezRandom.photocouple,'Value') == 1;
        if testA || testB
            stop(sDiode)
            delete(hListener)
        end
        release(sDiode)
        delete(sPez);
        [nRet,nErrorCode] = PDC_CloseDevice(nDeviceNo);
        if nRet == PDC.FAILED
            disp(['CloseDevice Error ' int2str(nErrorCode)])
        end
        delete(hFigA)
        clear all
        close all
    end
end

