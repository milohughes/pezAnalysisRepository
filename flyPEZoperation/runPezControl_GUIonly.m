
close all force

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
FigPos(3) = round(FigPos(3)*0.6);
hFigA = figure('NumberTitle','off','Name','flyPez3000 CONTROL MODULE - WRW',...
    'menubar','none','Visible','off',...
    'units','pix','Color',[0.05 0 0.25],'pos',FigPos,'colormap',gray(256));
set(hFigA,'Visible','on')

% Main panels
hPanelsMain = uipanel('Position',[0.015,0.02,0.95,0.96],...
    'Units','normalized','backgroundcolor',backC);

%Logo
% pezControlLogoFun

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
%     makePezIcon(hCamPlayback.children(iterBtn),0.7,btnIcons{iterBtn},iconshade,backC)
end
speedOps = [3,30,120];
speedOps = [fliplr(speedOps).*(-1) 0 speedOps];
set(hCamPlayback.parent,'SelectedObject',[])

hCamPlaybackSlider = uicontrol('Parent',hCamSubPnl(3),'Style','slider',...
    'Units','normalized','Min',0,'Max',100,'enable','inactive',...
    'Position',guiPosFun([.5 .04],[.95 .05]),'Backgroundcolor',backC);

%%camera edit controls
trigStrCell = {[],'Frames Pre/Post:',[],'Time Pre/Post (ms):',...
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
