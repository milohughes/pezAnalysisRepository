function runPezControl_v4
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all force

% data destination folder
data_dir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'Data_pez3000'];
% camera IP address
cameraIP = '192.168.0.10';
% in multi screen setup, this determines which screen to be used
screen2use = 1;
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
switch screen2use
    case 1
        FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
            (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
    case 2
        FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+[scrnPos(1),...
            (monPos(1,4)-monPos(screen2use,4))+1],...
            (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
    case 3
        FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+[scrnPos(1),...
            (monPos(1,4)-monPos(screen2use,4))+1],...
            (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
end

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

panPos = [0.67,0.428,0.22,0.144];
hPan = uipanel(hFigA,'position',panPos,'backgroundcolor',backC,'Visible','off');
hAxesP = axes('parent',hPan,'position',[.01 .1 .98 .2],...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[]);
barIm = zeros(10,1000,3);
hImBar = image(barIm,'parent',hAxesP);
set(hAxesP,'XLim',[1 1000],'YLim',[1 10])
hCancelBar = uicontrol('units','normalized','parent',hPan,'position',[.35 .4 .3 .3],...
    'style','togglebutton','string','Cancel','fontsize',10);
hTitleBar = uicontrol('units','normalized','parent',hPan,'position',[.01 .8 .98 .2],...
    'style','text','string','Downloading: ',...
    'fontsize',10);

% Main panels
hPanelsMain = uipanel('Position',[0.015,0.02,0.55,0.96],...
    'Units','normalized','backgroundcolor',backC);

%Logo
pezControlLogoFun

%%%%% Control panels %%%%%
panStr = {'flyPez','Camera','Experiment Control'};
posOps = [.01 .17 .64 .82
    .66 .25 .33 .74
    .01 .01 .98 .15];
hCtrlPnl = zeros(3,1);
for iterC = 1:3
    hCtrlPnl(iterC) = uipanel('Parent',hPanelsMain,'Title',panStr{iterC},...
        'Position',posOps(iterC,:),...
        'FontSize',12,'fontunits','normalized','backgroundcolor',backC);
end

hMsgPnl = uipanel('Parent',hPanelsMain,'Position',[.66 .17 .33 .07],...
    'FontSize',10,'fontunits','normalized','backgroundcolor',backC,'Title','Message Board');

msgString = {'I have nothing to say','at this time.'};
hTxtMsg = uicontrol(hMsgPnl,'style','text','string',msgString,...
    'fontsize',10,'backgroundcolor',backC,'units','normalized','fontunits',...
    'normalized','position',[.01 .01 .98 .85],'foregroundcolor',[0 0 .6]);

%%%%Experiment Panel
%camera 'edit' controls
editStrCell = {'Experiment Designer','Experiment Manager','Collection ID',...
    'Genotype ID','Experiment ID','Designer Notes','Manager Notes',...
    'Runtime (minutes)','videos'};
hCt = numel(editStrCell);
hNames = {'designer','manager','collection','genotype','experiment',...
    'designernotes','managernotes','duration','stopafter'};
hExptEntry = struct;
posOpsLabel = [.01 .80 .15 .13
    .01 .61 .15 .13
    .01 .43 .15 .13
    .01 .24 .15 .13
    .01 .05 .15 .13
    .33 .83 .13 .13
    .48 .83 .13 .13
    .78 .8 .15 .13
    .92 .6 .05 .13];
posOpsEdit = [.15 .80 .15 .14
    .15 .61 .15 .14
    .15 .43 .15 .14
    .15 .24 .15 .14
    .15 .05 .15 .14
    .33 .05 .13 .75
    .48 .05 .13 .75
    .91 .8 .05 .14
    .865 .6 .045 .14];
for iterG = 1:hCt
    uicontrol(hCtrlPnl(3),'Style','text',...
        'string',editStrCell{iterG},'Units','normalized',...
        'HorizontalAlignment','left','position',posOpsLabel(iterG,:),...
        'fontsize',9,'fontunits','normalized','BackgroundColor',backC);
    hExptEntry.(hNames{iterG}) = uicontrol(hCtrlPnl(3),'Style',...
        'edit','Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',[],...
        'position',posOpsEdit(iterG,:),'backgroundcolor',editC);
    set(hExptEntry.(hNames{iterG}),'fontunits','normalized')
end

set(hExptEntry.designernotes,'max',2)
set(hExptEntry.managernotes,'max',2)


% simple controls with callbacks other than pushbuttons
posOp = [.78 .6 .08 .14
    .65 .6 .1 .25
    .65 .1 .1 .27
    .76 .1 .1 .27
    .87 .1 .1 .27];
styleOp = {'checkbox','pushbutton','pushbutton','pushbutton','pushbutton'};
strOp = {'Stop after','Show More','Run','Extend','Stop'};
hName = {'stopafter','addlinfo','run','extend','stop'};
ctrlCt = numel(hName);
hExptCtrl = struct;
for iterG = 1:ctrlCt
    hExptCtrl.(hName{iterG}) = uicontrol(hCtrlPnl(3),'Style',styleOp{iterG},...
        'Units','normalized','HorizontalAlignment','center','fontsize',9,...
        'string',strOp{iterG},'fontunits','normalized','position',...
        posOp(iterG,:),'backgroundcolor',backC);
end


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
    [0.025 Yops(53) 0.95 H*7],'backgroundcolor',backC,...
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
    .05 .33 .4 .08];
posOpsPops = [.05 .5 .27 .15
    .35 .5 .27 .15
    .65 .5 .3 .15
    .45 .72 .5 .1
    .05 .72 .35 .1
    .05 .39 .35 .1
    .45 .39 .5 .1
    .45 .07 .5 .1
    .28 .33 .3 .1];
for iterS = 1:camStrCt
    uicontrol(hCamSubPnl(hCamParents(iterS)),'Style','text',...
        'string',[' ' camStrCell{iterS} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',posOpsLabels(iterS,:),...
        'fontsize',9,'fontunits','normalized','BackgroundColor',backC);
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
    .65 .35 .3 .1
    .05 .2 .3 .1
    .35 .2 .3 .1
    .65 .2 .3 .1];
for iterB = 1:btnStrCt
    hCamBtns.(hNames{iterB}) = uicontrol(hCamSubPnl(hParents(iterB)),...
        'style','pushbutton','units','normalized',...
        'string',btnStrCell{iterB},'Position',posOps(iterB,:),...
        'fontsize',8,'fontunits','normalized','backgroundcolor',backC);
end

%%playback controls
iconshade = 0.3;
hCamPlayback = struct;
hCamPlayback.parent = uibuttongroup('parent',hCamSubPnl(3),'position',...
    guiPosFun([.5 .12],[.95 .09]),'backgroundcolor',backC);
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
    'Position',guiPosFun([.5 .04],[.95 .05]),'Backgroundcolor',backC);

%%camera edit controls
trigStrCell = {[],'Frames Pre/Post:',[],'Time Pre/Post:',...
    'Frames Available','Time Available'};
trigStrCt = numel(trigStrCell);
hNames = {'beforetrig','aftertrig','durbefore','durafter','frminmem','durinmem'};
hCamEdit = struct;
hParents = [3,3,3,3,3,3];
posOpsLabel = [.05 .72 .4 .075
    .05 .72 .4 .075
    .05 .6 .4 .075
    .05 .6 .4 .075
    .05 .9 .4 .075
    .55 .9 .4 .075];
posOpsEdit = [.45 .74 .25 .07
    .725 .74 .25 .07
    .45 .62 .25 .07
    .725 .62 .25 .07
    .05 .85 .4 .07
    .55 .85 .4 .07];
for iterG = 1:trigStrCt
    uicontrol(hCamSubPnl(hParents(iterG)),'Style','text',...
        'fontsize',9,'string',trigStrCell{iterG},'Units','normalized',...
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

hCamCheck = uicontrol(hCamSubPnl(3),'Style','checkbox',...
    'Units','normalized','fontsize',9,...
    'string','Optimize speed with dual download','fontunits','normalized',...
    'position',[.11 .48 .8 .09],'backgroundcolor',backC);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% flyPez Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lightInit = 40;
shadow = 225;
gap = 2;
setTempFan = 26;
ellovervee = 40;
aziVal = 0;
aziOffVal = 0;
eleVal = 45;

%Define spatial options
xBlox = 62;
yBlox = 104;
Xops = linspace(1/xBlox,1,xBlox);
Yops = fliplr(linspace(1/yBlox,1,yBlox));
W = 1/xBlox;
H = 1/yBlox;

%Headings
headStrCell = {'Environment','Mechanics','Camera & Projector Management'};
headStrCt = numel(headStrCell);
headYops = [6 31 71];
for iterH = 1:headStrCt
    labelPos = [W,Yops(headYops(iterH)) W*60 H*3];
    uicontrol(hCtrlPnl(1),'Style','text',...
        'string',['  ' headStrCell{iterH}],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'fontunits','normalized','BackgroundColor',bhC,...
        'foregroundcolor',logoC);
end

%Gate plots
pezAxesPos = guiPosFun([0.59,Yops(headYops(2)+30)],[0.77 H*8]);
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
pezStrCell = {'Temp','Humidity','Temperature Control','A Lights',...
    'B Lights','Sweeper','Gate Control','Gate Calibration',...
    'ROI & Focus','Fly Count','Fly Detect','Visual Stimulus'};
pezStrCt = numel(pezStrCell);
hSubPnl = zeros(pezStrCt,1);
posOp = [Xops(1) Yops(headYops(1)+6) W*15 H*5
    Xops(1) Yops(headYops(1)+12) W*15 H*5
    Xops(16) Yops(headYops(1)+12) W*45 H*11
    Xops(1) Yops(headYops(1)+19) W*30 H*6
    Xops(31) Yops(headYops(1)+19) W*30 H*6
    Xops(1) Yops(headYops(2)+14) W*12 H*13
    Xops(13) Yops(headYops(2)+14) W*36 H*13
    Xops(1) Yops(headYops(2)+24) W*60 H*9
    Xops(1) Yops(headYops(3)+33) W*16 H*32
    Xops(49) Yops(headYops(2)+14) W*12 H*13
    Xops(17) Yops(headYops(3)+33) W*22 H*32
    Xops(39) Yops(headYops(3)+33) W*22 H*32];
for iterG = 1:pezStrCt
    hSubPnl(iterG) = uipanel(hCtrlPnl(1),'HitTest','off','FontSize',10,...
        'Title',pezStrCell{iterG},'FontUnits','Normalized',...
        'TitlePosition','lefttop','Position',posOp(iterG,:),...
        'BackgroundColor',backC);
    
end

% pez text only
posOp = {[.45 .1 .5 .7],[.45 .1 .5 .7],[.5 .53 .33 .35],...
    [.8 .08 .19 .25],[.78 .1 .2 .7],[.78 .1 .2 .7],[.01 .47 .3 .4],...
    [.01 .07 .3 .4],[.4 .5 .3 .4],[.4 .1 .3 .4],[.1 .45 .8 .45],...
    [.05 .7 .12 .1],[.45 .7 .27 .1],[.45 .56 .27 .1],[.45 .43 .27 .1],...
    [.05 .56 .4 .1]};
hP = [1 2 3 3 4 5 8 8 8 8 10 12 12 12 12 12];
strOp = {'XX.X deg C','XX.X%','Fan Trigger (deg C): ','XXX% power',...
    [num2str(lightInit) '%'],[num2str(lightInit) '%'],...
    'Set Shadow Threshold: ','Set Gap Threshold: ',...
    'Open position: XXX% ---------','Block position: XXX% ------',...
    'Click reset to enable','l/v :','Elevation :','Azimuth :',...
    'Heading :','Length (ms)'};
hName = {'temp','humid','fantrig','fanpwr','lightA','lightB',...
    'shadow','gap','openpos','closepos','flycount','loverv','ele',...
    'aziOff','aziFly','stimdur'};
ctrlCt = numel(hP);
hPezReport = struct;
for iterG = 1:ctrlCt
    hPezReport.(hName{iterG}) = uicontrol(hSubPnl(hP(iterG)),'Style','text',...
        'Units','normalized','HorizontalAlignment','left',...
        'fontsize',9,'string',strOp{iterG},'fontunits','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
end

% simple controls with callbacks other than pushbuttons
posOp = {[.85 .55 .1 .4],[.25 .5 .1 .4],[.25 .1 .1 .4],[.2 .82 .6 .15],...
    [.1 .65 .8 .125],[.15 .85 .8 .125],[.15 .75 .8 .125],...
    [.15 .65 .8 .125],[.18 .72 .2 .1],[.76 .72 .2 .1],[.76 .58 .2 .1],...
    [.76 .45 .2 .1],[.05 .45 .3 .1],[.1 .15 .8 .1],[.1 .05 .8 .1]};
hP = [3 8 8 9 9 11 11 11 12 12 12 12 12 12 12];
styleOp = {'edit','edit','edit','checkbox','togglebutton','checkbox',...
    'checkbox','checkbox','edit','edit','edit','edit','edit',...
    'checkbox','checkbox'};
strOp = {num2str(setTempFan)
    shadow
    gap
    'Display ROI'
    'Show Background'
    'Engage Fly Detect'
    'Run Autopilot'
    'Overlay Annotations'
    num2str(ellovervee)
    num2str(eleVal)
    num2str(aziOffVal)
    num2str(aziVal)
    '...'
    'Alternate azimuth left / right'
    'Couple with camera trigger'};
ctrlCt = numel(hP);
hName = {'temp','shadow','gap','roi','showback','flydetect','runauto','annotate',...
    'eloverv','ele','aziOff','aziFly','stimdur','alternate','couple'};
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

% Fan toggle manual versus auto
hFanStates = uibuttongroup('parent',hSubPnl(3),'position',[.02 .12 .36 .7],...
    'backgroundcolor',backC);
btnNames = {'Manual','Auto'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hFanBtnStates = zeros(btnCt,1);
for iterStates = 1:btnCt
    hFanBtnStates(iterStates) = uicontrol(hFanStates,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
set(hFanStates,'SelectedObject',[])

% pezSliders
posOp = {[.43 .11 .35 .22],[.05 .2 .7 .5],[.05 .2 .7 .5],[.65 .6 .3 .25],...
    [.65 .2 .3 .25]};
hP = [3 4 5 8 8];
pezSlideCt = numel(posOp);
pezSlideVals = [setTempFan,lightInit,lightInit,0,0];
hNames = {'fan','lightA','lightB','open','block'};
hPezSlid = struct;
for iterSD = 1:pezSlideCt
    hPezSlid.(hNames{iterSD}) = uicontrol('Parent',hSubPnl(hP(iterSD)),'Style','slider',...
        'Units','normalized','Min',0,'Max',100,'Value',pezSlideVals(iterSD),...
        'Position',posOp{iterSD},'Backgroundcolor',backC);
end

% pezButtons
posOp = {[.1 .51 .8 .4],[.1 .1 .8 .4],[.1 .55 .25 .35],[.1 .45 .8 .125],...
    [.1 .325 .8 .125],[.1 .15 .8 .125],[.1 .025 .8 .125],[.1 .1 .8 .35],...
    [.05 .29 .45 .1],[.5 .29 .45 .1]};
hP = [6 6 7 9 9 9 9 10 12 12];
strOp = {'Calibrate','Sweep','Find Gates','Auto Set ROI','Manual Set ROI',...
    'Coarse Focus','Fine Focus','Reset','Initialize','Display'};
ctrlCt = numel(hP);
hNames = {'calib','sweep','findgates','autoroi','manualroi','coarsefoc',...
    'finefoc','reset','initialize','display'};
hPezButn = struct;
for iterG = 1:ctrlCt
    hPezButn.(hNames{iterG}) = uicontrol(hSubPnl(hP(iterG)),'Style','pushbutton',...
        'fontsize',8,'string',strOp{iterG},'units','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
    set(hPezButn.(hNames{iterG}),'fontunits','normalized')
end
set(hPezButn.coarsefoc,'Style','togglebutton')
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
pezmodepos = guiPosFun([0.1,Yops(headYops(2)+30)],[0.17 H*8.2]);
hPezMode.parent = uibuttongroup('parent',hCtrlPnl(1),'position',...
    pezmodepos,'backgroundcolor',backC,'title','Pez Monitor',...
    'fontsize',10,'fontunits','normalized');
btnNames = {'On','Off'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hPezMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hPezMode.child(iterStates) = uicontrol(hPezMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end

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
    [.025 .425 .95 .2],'backgroundcolor',backC,'Title','Trigger on');
btnNames = {'Escape','Single in frame'};
btnCt = numel(btnNames);
posOps = {[.05 .05 .35 .9],[.45 .05 .5 .9]};
hTrigMode.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hTrigMode.child(iterStates) = uicontrol(hTrigMode.parent,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
set(hTrigMode.parent,'SelectedObject',hTrigMode.child(2))

% Fly detect status report
hDetectRadio = struct;
hDetectRadio.parent = uibuttongroup('parent',hSubPnl(11),'position',...
    [.025 .01 .95 .35],'backgroundcolor',backC,'Title','Fly Detect Interpretations');

btnNames = {'Searching','Fly in View','Fly is Ready','Fly Escaped'};
btnCt = numel(btnNames);
posOps = {[.05 .55 .35 .4],[.425 .55 .55 .4],[.425 .05 .55 .4],[.05 .05 .35 .4]};
hDetectRadio.child = zeros(btnCt,1);
for iterStates = 1:btnCt
    hDetectRadio.child(iterStates) = uicontrol(hDetectRadio.parent,'style','radiobutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},'fontsize',8,...
        'fontunits','normalized','HandleVisibility','off','backgroundcolor',backC);
end
set(hDetectRadio.parent,'SelectedObject',hDetectRadio.child(1))

% Visual stimulus popmenu
stimStrOps = {'Black disk on white background'};
visStimPop = uicontrol(hSubPnl(12),'style','popupmenu','units','normalized',...
    'position',[.05 .825 .9 .125],'string',stimStrOps,'fontunits','normalized');


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
nChannel = 20;
nXPos = nWidthMax/2-nWidth/2;
nYPos = nHeightMax/2-nHeight/2;
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
set(hExptCtrl.addlinfo,'callback',@addlinfoCallback)
set(hExptCtrl.run,'callback',@runexptCallback)
set(hExptCtrl.extend,'callback',@extendexptCallback)
set(hExptCtrl.stop,'callback',@stopexptCallback)

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

set(hDetectRadio.parent,'SelectionChangeFcn',@hTrigSelectCallback);
set(hPezRandom.temp,'callback',@setTemperature);
set(hPezRandom.shadow,'callback',@hshadowth)
set(hPezRandom.gap,'callback',@hgapth)
set(hPezRandom.roi,'callback',@hDispROICall)
set(hPezRandom.showback,'callback',@highlightBackground)
set(hPezRandom.flydetect,'callback',@setFlydetectCall)
set(hPezRandom.runauto,'callback',@runAutoPilotCall)
set(hPezRandom.annotate,'callback',@overlayAnnotationsCall)
set(hPezRandom.couple,'callback',@coupleToCameraCall)
set(hGateMode.parent,'SelectionChangeFcn',@hAutoButtonCallback);
set(hGateState.parent,'SelectionChangeFcn',@gateSelectCallback);
set(hFanStates,'SelectionChangeFcn',@fanToggleCallback);
set(hPezButn.calib,'callback',@hCalibrate)
set(hPezButn.sweep,'callback',@hSweepGateCallback)
set(hPezButn.findgates,'callback',@hFindButtonCallback)
set(hPezButn.autoroi,'callback',@hAutoSetROI)
set(hPezButn.manualroi,'callback',@hManualSetROI)
set(hPezButn.coarsefoc,'callback',@coarseCallback)
set(hPezButn.finefoc,'callback',@focusFeedback)
set(hPezButn.reset,'callback',@flyCountCallback)
set(hPezButn.initialize,'callback',@initializeVisStim)
set(hPezButn.display,'callback',@displayVisStim)
set(hPezSlid.fan,'callback',@setFanCallback)
set(hPezSlid.lightA,'callback',@lightAcallback)
set(hPezSlid.lightB,'callback',@lightBcallback)
set(hPezSlid.open,'callback',@hOpen1Callback)
set(hPezSlid.block,'callback',@hBlock1Callback)
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
spokeStack = size(initTmpl,1);
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
tCam = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',round((1/10)*100)/100,'StartDelay',1);
tDet = timer('TimerFcn',@resetDetectFun,'ExecutionMode','fixedRate',...
    'Period',30,'StartDelay',30);
tExpt = timer('TimerFcn',@stopexptCallback,'StartDelay',20*60);
tFoc = timer('TimerFcn',@focusTimerFun,'ExecutionMode','fixedRate',...
    'Period',round((1/30)*100)/100);
FocTab = zeros(6,1);
tMsg = timer('TimerFcn',@removeMsg,'StartDelay',5.0);
tPos = timer('TimerFcn',@hPlaybackCallback,'ExecutionMode','fixedRate',...
    'Period',0.3);
frmRate = 30;
frmOps = [];
frmDelta = 1;
frmVecRef = [];
frmCount = [];
tPlay = timer('TimerFcn',@timerVidFun,'ExecutionMode','fixedRate',...
    'Period',round((1/frmRate)*100)/100);


%prepare for photodiode acquisition
sDiode = initializeDiodeNidaq;
hListener = sDiode.addlistener('DataAvailable',@trigDetect);
overSampleFactor = 10;
[nRet,nErrorCode] = PDC_SetSyncOutTimes(nDeviceNo,uint32(overSampleFactor));
sDiode.IsContinuous = true;
sDiode.Rate = double(nFps*overSampleFactor);
sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
diodeDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
recEndTime = [];

% Setup the serial
delete(instrfindall)
% Lookup table to convert computer name to pez number
[~, comp_name] = system('hostname');
comp_name = comp_name(1:(length(comp_name)-1)); %Remove trailing character.
switch comp_name
    case 'peekm-ww4'
        %brain_num = 1;
        sPez = serial('COM4');
        pezName = 'pez3001';
    case 'cardlab-ww9'
        %brain_num = 2;
        sPez = serial('COM4');
        pezName = 'pez3002';
    case 'cardlab-ww10'
        %brain_num = 3;
        sPez = serial('COM4');
        pezName = 'pez3003';
    otherwise
end
runPath = [];
runFolder = [];
set(sPez,'baudrate',250000,'inputbuffersize',100*(128+3),...
    'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
    @receiveData,'Terminator','CR/LF','StopBits',2);
fopen(sPez);
set(hFigA,'CloseRequestFcn',@myCloseFun)
% end
disp('camStartupFun called')
camStartupFun
disp('camStartupFun passed')

    function camStartupFun
        % send linear array data
        fwrite(sPez,sprintf('%s\r','V'));
        lightAcallback([],[])
        lightBcallback([],[])
        dispCurrentSettings([],[])
        disp('applyNewSettings called')
        applyNewSettings([],[])
        disp('applyNewSettings passed')
        messageFun('Camera is ready')
        disp('camStateCallback called')
        camStateCallback([],[])
        disp('camStateCallback passed')
    end

% message center functions
    function removeMsg(~,~)
        set(hTxtMsg,'string',[])
    end
    function messageFun(msgStr)
        if strcmp(tMsg.Running,'on'), stop(tMsg), end
        set(hTxtMsg,'string',msgStr)
        start(tMsg)
    end

% experiment management functions
    function addlinfoCallback(~,~)
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
            mkdir(runPath)
            set(hPezRandom.runauto,'Value',1)
            runAutoPilotCall([],[])
            start(tExpt)
        else
            messageFun('Experiment already in progress')
        end
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
    function stopexptCallback(~,~)
        if strcmp(tExpt.Running,'on'), stop(tExpt), end
        if strcmp(tDet.Running,'on'), stop(tDet), end
        set(hPezRandom.runauto,'Value',0)
        messageFun('Experiment done')
    end

% camera functions
    function dispCurrentSettings(~,~)
        set(hCamPop.width,'Value',find(nWidth == listWidthNum))
        set(hCamPop.height,'Value',find(nHeight == listHeightNum))
        set(hCamPop.recrate,'Value',find(nRate == nRecordRateList))
    end
    function applyNewSettings(~,~)
        disp('applyNewSettings started')
        nWidth = listWidthNum(get(hCamPop.width,'Value'));
        nHeight = listHeightNum(get(hCamPop.height,'Value'));
        nRate = nRecordRateList(get(hCamPop.recrate,'Value'));
        nXPos = nWidthMax/2-nWidth/2;
        nYPos = nHeightMax/2-nHeight/2;
        nFps = nShutterList(nShutterSize);
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
        pause(0.1)
        [nRet,nErrorCode] = PDC_SetVariableChannelInfo(nDeviceNo,...
            nChannel,nRate,nWidth,nHeight,nXPos,nYPos);
        pause(0.1)
        [nRet,nErrorCode] = PDC_SetVariableChannel(nDeviceNo,nChildNo,nChannel);
        pause(0.3)
        [nRet,nShutterSize,nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nDeviceNo,nChildNo);
        nFps = nShutterList(1);
        [nRet, nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo, nChildNo, nFps);
        pause(0.1)
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
        
        disp('applyNewSettings complete')
    end
    function shutterSpeedCallback(~,~)
        if strcmp(tCam.Running,'on'), stop(tCam), end
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
        lightAcallback([],[])
        lightBcallback([],[])
    end
    function dispLiveImage(~,~)
        try
        [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
        frmData = nBuf';
        set(hImA,'CData',frmData)
        drawnow
        flyDetect([],[])
        updateGatePlot
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
            t = double(htCell{2})/10;
            h = double(htCell{1})/10;
            set(hPezReport.humid,'String',[num2str(h) ' %']);
            set(hPezReport.temp,'String',[num2str(t) ' degC']);
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
            set(hTxtMsg,'string','Set ROI first')
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
            fwrite(sPez,sprintf('%s %u\r','L',40));
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
            lightAcallback([],[])
            lightBcallback([],[])
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
    function hAutoSetROI(~,~)
        toggleChildren(hPanelsMain,0)
        try
            if get(hPezRandom.showback,'Value') == 0
                set(hPezRandom.showback,'Value',1)
                highlightBackground
            end
            if strcmp(tCam.Running,'on'), stop(tCam), end
            dispLiveImage
            nRet = 0;
            dispLiveImage
            while nRet == 0, end
            grth = graythresh(frmData)*1;
            frmGr = im2bw(frmData,grth);
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
            frmBotBW = im2bw(frmBot,graythresh(frmBot)*(1.5));
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
        catch ME
            getReport(ME)
            toggleChildren(hPanelsMain,1)
        end
        toggleChildren(hPanelsMain,1)
    end
    function setFlydetectCall(~,~)
        if isempty(roiPos)
            set(hTxtMsg,'string','Set ROI first')
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
        if get(hPezMode.parent,'SelectedObject') == hPezMode.child(2)
            set(hPezMode.parent,'SelectedObject',hPezMode.child(1));
            pezMonitorFun
        end
        if get(hPezRandom.runauto,'Value') == 1
            if strcmp(tPlay.Running,'on'),stop(tPlay),end
            if strcmp(tCam.Running,'on'),stop(tCam),end
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
            if strcmp(tCam.Running,'off'),start(tCam),end
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
            set(hDetectRadio.parent,'SelectedObject',hDetectRadio.child(3))
        elseif detectTabs(1) == 0
            set(hDetectRadio.parent,'SelectedObject',hDetectRadio.child(1))
        else
            set(hDetectRadio.parent,'SelectedObject',hDetectRadio.child(2))
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

    function coarseCallback(~,~)
        state = get(hPezButn.coarsefoc,'Value');
        if state == 1
            if get(hPezRandom.showback,'Value') == 0
                set(hPezRandom.showback,'Value',1)
                highlightBackground
            end
            hCalibrate
        else
            hSweepGateCallback
        end
    end
    function focusFeedback(~,~)
        focusVal = get(hPezButn.finefoc,'Value');
        if stagePos == 0
            set(hTxtMsg,'string','Set ROI first')
            if get(hPezButn.coarsefoc,'Value') == 1
                set(hPezButn.coarsefoc,'Value',0)
                hSweepGateCallback
            end
            return
        elseif focusVal == 1
            if get(hPezRandom.showback,'Value') == 0
                set(hPezRandom.showback,'Value',1)
                highlightBackground
            end
            if get(hPezButn.coarsefoc,'Value') == 1
                set(hPezButn.coarsefoc,'Value',0)
            else
                hCalibrate
            end
            set(hAxesT,'Visible','on')
            set(hAxesT,'XLim',[-20 20],'YLim',[0 2])
            FocTab(3:6) = round([min(stagePos(:,1)),max(stagePos(:,1)),...
                mean(stagePos(:,2))-100,mean(stagePos(:,2))-10]);
            focDims = [FocTab(6)-FocTab(5),FocTab(4)-FocTab(3)];
            xOpsVec = (1:2:focDims(2));
            yOpsVec = (1:2:focDims(1));
            xFoc = [xOpsVec,repmat(focDims(2),1,numel(yOpsVec))...
                xOpsVec,ones(1,numel(yOpsVec))]+FocTab(3);
            yFoc = [ones(1,numel(xOpsVec)),yOpsVec,...
                repmat(focDims(1),1,numel(xOpsVec)),yOpsVec]+FocTab(5);
            set(hPlotROI,'XData',xFoc,'YData',yFoc,'Visible','on')
            start(tFoc)
        else
            delete(get(hAxesT,'Children'))
            set(hAxesT,'Visible','off')
            stop(tFoc)
            FocTab = zeros(6,1);
            hSweepGateCallback
            removePlot
        end
    end
    function focusTimerFun(~,~)
        delete(get(hAxesT,'Children'))
        focusIm = frmData(FocTab(5):FocTab(6),FocTab(3):FocTab(4));
        FM = fmeasure(focusIm,'SFRQ',[]);
        switch FocTab(1)
            case 0
                FocStr = '1: Turn focus knob one direction';
                FocTab(1) = 1;
                FocTab(2) = FM;
            case 1
                FocStr = '1: Turn focus knob one direction';
                if FM > FocTab(2), FocTab(2) = FM; end
                focDrop = (FocTab(2)-FM)/FocTab(2);
                if focDrop > 0.3
                    FocTab(1) = 2;
                    FocTab(2) = FM;
                end
            case 2
                FocStr = '2: Turn focus knob the OTHER way';
                if FM > FocTab(2), FocTab(2) = FM; end
                focDrop = (FocTab(2)-FM)/FocTab(2);
                if focDrop > 0.2
                    FocTab(1) = 3;
                end
            case 3
                FocStr = {'3: Turn focus knob slowly the FIRST way';
                        'until the lines are as close as possible'};
                xF = [-10 10 NaN -10 10];
                FM = 1-(FocTab(2)-FM)/FocTab(2)*3;
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
            set(hCamPlayback.parent,'SelectedObject',[])
            set(hCamPlayback.children(:),'enable','inactive')
            set(hCamPlaybackSlider,'enable','inactive')
        end
        butValN = get(hCamStates.parent,'SelectedObject');
        caseVal = find(butValN == hCamStates.children);
        [nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
        switch caseVal
            case 1
                if nStatus ~= PDC.STATUS_LIVE
                    [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
                    if nRet == PDC.FAILED, messageFun(['SetStatus Error ' int2str(nErrorCode)]), end
                end
                if strcmp(tCam.Running,'off'),start(tCam),end
            case 2
                if strcmp(tCam.Running,'on')
                    stop(tCam)
                else
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
        end
        disp('camStateCallback completed')
    end
    function partcountCallback(~,~)
        nCount = partitionOps(get(hCamPop.partcount,'value'));
        partitionAvail = (1:nCount);
        set(hCamPop.partition,'string',cellstr(num2str(partitionAvail')))
        [nRet,nErrorCode] = PDC_SetPartitionList(nDeviceNo,nChildNo,nCount,[]);
        [nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
        set(hCamPop.partition,'value',1)
        partitionCallback([],[])
    end
    function partitionCallback(~,~)
        nNo = get(hCamPop.partition,'value');
        [nRet,nErrorCode] = PDC_SetCurrentPartition(nDeviceNo,nChildNo,nNo);
        triggerModeCallback([],[])
    end
    function framesEditCallback(~,~)
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
            case 2
                frmsB4 = (nFrames-1)/2;
                frmsAftr = (nFrames-1)/2;
            case 3
                frmsB4 = nFrames-1;
                frmsAftr = 0;
                set(hCamEdit.aftertrig,'enable','inactive')
                set(hCamEdit.durafter,'enable','inactive')
            case 4
                frmsAftr = (nFrames-1)/2;
                nAFrames = frmsAftr;
                frmsB4 = frmsAftr;
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
        set(hCamEdit.durinmem,'string',durstr)
        set(hCamEdit.durbefore,'string',durB4str,'UserData',durB4)
        set(hCamEdit.durafter,'string',durAftrStr,'UserData',durAftr)
    end
    function triggerCallback(~,~)
        disp('triggerCallback started')
        if strcmp(tDet.Running,'on'),stop(tDet),end
        if strcmp(tCam.Running,'on'),stop(tCam),end
        if strcmp(tMsg.Running,'on'),stop(tMsg),end
        if get(hPezMode.parent,'SelectedObject') == hPezMode.child(1)
            set(hPezMode.parent,'SelectedObject',hPezMode.child(2));
            pezMonitorFun
        end
        
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            displayVisStim([],[])
        else
            [nRet,nErrorCode] = PDC_TriggerIn(nDeviceNo);
        end
        
%         messageFun('Trigger')
        pause(get(hCamEdit.durafter,'userdata'))
        if get(hPezRandom.runauto,'Value') == 1
            reviewMemoryCallback([],[])
        else
%             start(tCam)
            set(hPezMode.parent,'SelectedObject',hPezMode.child(1));
            pezMonitorFun
        end
        disp('triggerCallback complete')
    end
    function reviewMemoryCallback(~,~)
        disp('reviewMemoryCallback started')
        if strcmp(tCam.Running,'on'),stop(tCam),end
        set(hCamStates.parent,'SelectedObject',[]);
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
        [nRet,memFrameInfo,nErrorCode] = PDC_GetMemFrameInfo(nDeviceNo,nChildNo);
        [nRet,memRate,nErrorCode] = PDC_GetMemRecordRate(nDeviceNo,nChildNo);
        [nRet,memWidth,memHeight,nErrorCode] = PDC_GetMemResolution(nDeviceNo,nChildNo);
        if get(hPezRandom.runauto,'Value') == 1
            downloadRecordingCallback([],[])
%             runAutoPilotCall([],[])
        end
        set(hCamPlayback.children(:),'enable','on')
        set(hCamPlaybackSlider,'enable','on')
        disp('reviewMemoryCallback complete')
    end
    function downloadRecordingCallback(~,~)
        disp('downloadRecordingCallback started')
        currTime = datestr(rem(now,1),'HHMMSS');
        destA = get(hExptEntry.collection,'string');
        destB = get(hExptEntry.genotype,'string');
        destC = get(hExptEntry.experiment,'string');
        
        if isempty(runPath)
            runFolder = ['pez3000' datestr(now,'yyyymmdd')];
            saveDir = 'Z:\Data_pez3000\Testing';
%             saveDir = 'C:\Users\cardlab\Documents\pez3000_testing';
            runPath = fullfile(saveDir,runFolder);
        end
        
        video_files = dir(fullfile(runPath,'*.mp4'));
        vid_count = numel({video_files(:).name});
        vidName = [runFolder,'_vid',sprintf('%04.0f',vid_count+1),'.mp4'];
        vidDest = fullfile(runPath,vidName); %path to save next video
        
        backgrFolder = fullfile(runPath,'backgroundFrames');
        if ~isdir(backgrFolder), mkdir(backgrFolder), end
        backfrName = [runFolder,'_backgroundFrame',sprintf('%04.0f',vid_count+1),'.tif'];
        backgrDest = fullfile(backgrFolder,backfrName); %path to save background
        imwrite(backgrFrm,backgrDest,'tif')
        
        
        if get(hPezRandom.runauto,'Value') == 1
            [nRet, nData, nErrorCode] = PDC_GetMemImageData(nDeviceNo,nChildNo,frmVecRef(1),nBitDepth,nColorMode,nBayer,nWidth,nHeight);
            frmOne = nData'-backgrFrm;
            frmOne(frmOne < 0) = 0;
            [flycount,counterIm] = flyCounter_3000(frmOne(1:nWidth,:));
            inspectDir = fullfile(runPath,'inspectionResults');
            if ~isdir(inspectDir), mkdir(inspectDir), end
            image_files = dir(fullfile(inspectDir,'*.tif'));
            im_count = numel({image_files(:).name});
            image_name = [runFolder,'_flyCounterImage',sprintf('%04.0f',im_count+1),'.tif'];
            imageDest = fullfile(inspectDir,image_name);
            imwrite(counterIm,imageDest,'tif')
%             flycount
            if flycount ~= 1
                runAutoPilotCall([],[])
                return
            end
        end
        
        dataFolder = fullfile(runPath,'videoData');
        if ~isdir(dataFolder), mkdir(dataFolder), end
        dataName = [runFolder,'_videoData',sprintf('%04.0f',vid_count+1),'.mat'];
        vidDataDest = fullfile(dataFolder,dataName); %path to save data
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            diodeDataProcessed = mean(reshape(diodeData,overSampleFactor,...
                numel(diodeData)/overSampleFactor));
            if numel(diodeDataProcessed) < nFrames
                messageFun('Diode error')
                if get(hPezRandom.runauto,'Value') == get(hPezRandom.runauto,'Max')
                    runAutoPilotCall([],[])
                end
            end
            
            nTrigRef = get(hCamPop.trigmode,'Value');
            switch nTrigRef
                case 1
                    diodeData2save = diodeDataProcessed(1:frmCount);
                case 2
                    diodeData2save = diodeDataProcessed(frmVecRef);
                otherwise
                    diodeData2save = diodeDataProcessed(nFrames-frmCount+1:nFrames);
            end
%                     figure,plot(diodeData2save)
%                     figure,plot(diodeData)
%                     uiwait
            save(vidDataDest,'diodeData2save')
            diodeData = [];
%                     return
        end
        
        %%%%%% The following code uses the mex files which came with the
        %%%%%% camera to compress and save videos.  It take five times
        %%%%%% longer than using MATLAB using all possible permutations.
%         nShowCompressDlg = 0;
%         nPlayRate = 30;
%         vidDest = regexprep(vidDest,'.mp4','.avi');
%         [nRet,nErrorCode] = PDC_AVIFileSaveOpen(nDeviceNo,nChildNo,vidDest,nPlayRate,nShowCompressDlg);
%         for iterFrm = 1:frmCount
%             frmRef = frmVecRef(iterFrm);
%             [nRet,nPlaySize,nErrorCode] = PDC_AVIFileSave(nDeviceNo,nChildNo,frmRef);
%         end
%         [nRet,nErrorCode] = PDC_AVIFileSaveClose(nDeviceNo,nChildNo);
        
%         %%% Preparing custom waitbar
%         set(hPan,'Visible','on');
%         barImage = zeros(10,numel(frmVecRef),3);
%         set(hImBar,'CData',barImage);
%         set(hAxesP,'XLim',[1 numel(frmVecRef)],'YLim',[1 10])
        titleStr = ['Downloading: ' vidName];
%         set(hTitleBar,'string',titleStr);
%         set(hCancelBar,'Value',0)
%         %%%%%% The waitbar is updated only 50 times during the download
%         %%%%%% becasue the 'drawnow' command slows down the download
%         barSegment = ceil(frmCount/50);
        
        %%%%%% Saving as a '.avi' in MATLAB took 10x longer then '.mp4'
%         vidDest = regexprep(vidDest,'.mp4','.avi');
%         vidObj = VideoWriter(vidDest,'Grayscale AVI');

        vidObj = VideoWriter(vidDest,'MPEG-4');
        open(vidObj)
        
        if get(hCamCheck,'Value') == 1
        end
        
        tic
        hWait = waitbar(0,'1','Name',titleStr,...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(hWait,'canceling',0)
        
        for iterFrm = 1:10:frmCount
%         for iterFrm = 1:frmCount
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
            
            [flycount,~] = flyCounter_3000(frmWrite(1:nWidth,:));
            
%             % Report current estimate in the waitbar's message field
%             if round((iterFrm-1)/barSegment) == (iterFrm-1)/barSegment
%                 % Check for Cancel button press
%                 if get(hCancelBar,'Value') == 1
%                     break
%                 end
%                 barImage(:,1:iterFrm,1) = 1;
%                 set(hImBar,'CData',barImage)
%                 drawnow
%             end
            
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
        
        %%%%%% Bookending the download with the following commands tacks on
        %%%%%% time and seems to do nothing useful
%         [nRet,~,nErrorCode] = PDC_GetMemImageDataStart(nDeviceNo, nChildNo,frmVecRef(1),nBitDepth,nColorMode,nBayer,nWidth,nHeight);
%         [nRet,~,nErrorCode] = PDC_GetMemImageDataEnd(nDeviceNo,nChildNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);

        %%%%%% Simply saving the variable took 1.5 times that of saving the
        %%%%%% movie as an '.mp4'
%         movWrite = uint8(zeros(nHeight,nWidth,frmCount)); %preallocating
%         .....(for loop)  movWrite(:,:,iterFrm) = frmWrite;
%         vidDest = regexprep(vidDest,'.mp4','.mat');
%         save(vidDest,'movWrite')
        
        %%%%%% Assigning the compression to a worker requires the variables
        %%%%%% sent to be saved to the hard drive first.  This takes too
        %%%%%% long.  Simply calling the function interrupts this GUI
%         batch('compressionFun_pez3000',0,{vidDest,movWrite});
%         compressionFun_pez3000(vidDest,movWrite);

%         %%% Close custom waitbar
%         set(hPan,'Visible','off')

        if get(hPezRandom.runauto,'Value') == get(hPezRandom.runauto,'Max')
            runAutoPilotCall([],[])
        end
        disp('downloadRecordingCallback complete')
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
                set(tPlay,'Period',perVal)
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

% visual stimulus functions
    function initializeVisStim(~,~)
        stimStruct = get(hPezButn.initialize,'UserData');
        if isempty(Screen('Windows'))
            stimStruct = initializeVisualStimulusGeneral;
            set(hPezButn.initialize,'UserData',stimStruct)
        end
        stimStruct.ellovervee = str2double(get(hPezRandom.eloverv,'string'));
        stimTrigStruct = initializeBlackDiskOnWhite(stimStruct);
        stimTrigStruct(1).eleVal = str2double(get(hPezRandom.ele,'string'));
        set(hPezButn.display,'UserData',stimTrigStruct)
        stimdurstr = num2str(round(stimTrigStruct.stimTotalDuration));
        set(hPezRandom.stimdur,'string',stimdurstr)
    end
    function displayVisStim(~,~)
        if isempty(Screen('Windows'))
            messageFun('Initialize visual stimulus first!')
            return
        end
        stimTrigStruct = get(hPezButn.display,'UserData');
        offset = str2double(get(hPezRandom.aziOff,'string'));
        azifly = str2double(get(hPezRandom.aziFly,'string'));
        stimTrigStruct(1).aziVal = azifly+offset;
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            missedFrames = presentDiskStimulus(stimTrigStruct,nDeviceNo);
%             missedFrames = presentDiodeTest(stimTrigStruct,nDeviceNo);
        else
            missedFrames = presentDiskStimulus(stimTrigStruct,[]);
%             missedFrames = presentDiodeTest(stimTrigStruct,[]);
        end
        messageFun(['Missed flip count: ' num2str(missedFrames)])
        if get(hPezRandom.alternate,'Value') == 1
            set(hPezRandom.aziOff,'string',num2str(-offset))
        end
    end
    function coupleToCameraCall(~,~)
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
            sDiode.startBackground();
        else
            stop(sDiode)
        end
    end
    function recDetect(~,event)
        recData = event.Data(:,2);
%         max(recData)
        if max(recData) > 4
%             disp('more than four')
            stop(sDiode)
            delete(hListener)
            hListener = sDiode.addlistener('DataAvailable',@trigDetect);
            sDiode.startBackground();
        end
    end
    function trigDetect(~,event)
%         size(event.Data)
        diodeDataB = event.Data(:,1);
        recData = event.Data(:,2);
%         min(recData)
        if min(recData) < 1
%             disp('less')
            stop(sDiode)
            delete(hListener)
            diodeData = [diodeDataA;diodeDataB];
            endRef = find(recData < 1,1,'first');
            cropDataEnd = numel(recData)+endRef-1;
            cropDataBegin = endRef;
            diodeData = diodeData(cropDataBegin:cropDataEnd);
%             diodeData = diodeData(end-nFrames+1:end);
%             diodeDataDir = 'Z:\W Ryan W\PezDocs\diodeData\diodeData.mat';
%             save(diodeDataDir,'diodeData','recData')
            diodeTimeStamps = event.TimeStamps;
            recEndTime = diodeTimeStamps(endRef);
%             figure,plot(diodeData(end-3000:end))
%             numel(diodeData)
%             uiwait(gcf)
            hListener = sDiode.addlistener('DataAvailable',@recDetect);
            sDiode.startBackground();
        else
            diodeDataA = diodeDataB;
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

% Fan Control
    function setFanCallback(hObject,~)
        slider_value = round(get(hObject,'Value')/10)*10;
        set(hObject,'Value',slider_value);
        set(hPezReport.fanpwr,'String',[num2str(slider_value) '%'])
        fwrite(sPez,sprintf('%s %u\r','U',slider_value));
    end
    function fanToggleCallback(~,eventdata)
        butnValN = eventdata.NewValue;
        caseVal = find(butnValN == hFanBtnStates);
        switch caseVal
            case 1
            % Turn on fan
            fwrite(sPez,sprintf('%s\r','Y'));
            case 2
            % Turn off fan
            fwrite(sPez,sprintf('%s\r','P'));
        end
    end
    function setTemperature(hObject,~)
        entry = str2double(get(hObject,'string'));
        tempFan = round(entry*10)/10;
        fwrite(sPez,sprintf('%s %u\r','Q',tempFan));
    end

% Light Control
    function lightAcallback(~,~)
        slider_value = round(get(hPezSlid.lightA,'Value'));
        set(hPezSlid.lightA,'Value',slider_value);
        set(hPezReport.lightA,'String',[num2str(slider_value) '%'])
        fwrite(sPez,sprintf('%s %u\r','I',slider_value));
    end
    function lightBcallback(~,~)
        slider_value = round(get(hPezSlid.lightB,'Value'));
        set(hPezSlid.lightB,'Value',slider_value);
        set(hPezReport.lightA,'String',[num2str(slider_value) '%'])
        fwrite(sPez,sprintf('%s %u\r','L',slider_value));
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
        fwrite(sPez,sprintf('%s\r','F'));
        set(hGateState.parent,'SelectedObject',hGateState.child(1))
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
        if (get(hPezRandom.couple,'Value') == get(hPezRandom.couple,'Max'))
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

