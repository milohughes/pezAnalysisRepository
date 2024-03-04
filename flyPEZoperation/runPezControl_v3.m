function runPezControl_v3
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all force

% camera IP address
cameraIP = '192.168.0.10';
% in multi screen setup, this determines which screen to be used
screen2use = 3;
% portion of the screen to cover
screen2cvr = 0.9;

funcFull = mfilename('fullpath');
funcPath = fileparts(funcFull);
funcParent = fileparts(funcPath);
snapDir = fullfile(funcParent,'Captured_Images');
vidDir = fullfile(funcParent,'Captured_Videos');
if ~isdir(snapDir), mkdir(snapDir), end
if ~isdir(vidDir), mkdir(vidDir), end
currDate = datestr(date,'yyyymmdd');


%%%%%%%%%%%%%% Main GUI uicontrol objects %%%%%%%%%%%%%%%%%
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];%input center(x,y) and size(x,y)
monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);

%%%%% Main GUI Figure %%%%%
if screen2use > 1
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+[scrnPos(1),(monPos(1,4)-scrnPos(4)-scrnPos(2))],...
        (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
else
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
        (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
end

hFigA = figure('NumberTitle','off','Name','flyPEZ 3000 CONTROL MODULE - WRW',...
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

% Main panels and pseudo tabs
backC = [0.8 0.8 0.8];
texC = [0.7 0.7 0.7];
editC = [.85 .85 .85];
logoC = [0 0 0];
bhC = [.7 .7 .74];
tabC = [.29 .47];
tabS = [.55 .9];
hPanelsMain = zeros(2,1);

for iterP = 1:2
    hPanelsMain(iterP) = uipanel('Position',guiPosFun(tabC,tabS),...
        'Visible','Off','Units','normalized','backgroundcolor',backC);
end
set(hPanelsMain(1),'Visible','on')

tabPosA = guiPosFun(tabC,tabS);
tabPosB = tabPosA(2)+tabPosA(4);
tabPosA(2:4) = [];
tabPosC = 0.07;
tabStr = {'Control','Metadata'};
hTabs = zeros(2,1);
for iterT = 1:2
    tabPos = [tabPosA+tabPosC*(iterT-1) tabPosB tabPosC .04];
    hTabs(iterT) = uicontrol(hFigA, 'Style','togglebutton',...
        'String',tabStr{iterT},'Value',0,'Units','normalized',...
        'fontsize',12,'Position',tabPos,'backgroundcolor',backC);
end
set(hTabs(1),'Value',1)

%Logo
pezControlLogoFun

%%%%% Control panels %%%%%
panStr = {'flyPez','Camera'};
panXops = [.33 .82];
panWops = [.64 .33];
hCtrlPnl = zeros(2,1);
for iterC = 1:2
    hCtrlPnl(iterC) = uipanel('Parent',hPanelsMain(1),'Title',panStr{iterC},...
        'Position',guiPosFun([panXops(iterC) 0.5],[panWops(iterC) 0.95]),...
        'FontSize',12,'backgroundcolor',backC);
end

%%%Camera panel
%Define spatial options
xBlox = 11;
yBlox = 27*2;
Xops = linspace(1/xBlox,1,xBlox)-1/xBlox/2;
Yops = fliplr(linspace(1/yBlox,1,yBlox)-1/yBlox/2);
W = 1/xBlox*2;
H = 1/yBlox*2;

%Headings
headStrCell = {'Frame','Setup','Record'};
headStrCt = numel(headStrCell);
headYops = [3 15 35];
panelH = H*([3.5,5.5,8.5]);
hCamSubPnl = zeros(headStrCt,1);
for iterH = 1:headStrCt
    labelPos = guiPosFun([0.5,Yops(headYops(iterH))+H/2],[0.95 H*0.8]);
    uicontrol(hCtrlPnl(2),'Style','text',...
        'string',headStrCell{iterH},'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'BackgroundColor',bhC,'foregroundcolor',logoC);
    panelPos = labelPos+[0 -panelH(iterH)-H 0 panelH(iterH)];
    hCamSubPnl(iterH) = uipanel(hCtrlPnl(2),'HitTest','off',...
        'Position',panelPos,'BackgroundColor',backC);
end

%Labels
camStrCell = {'Width','Height','Rec Rate','Shutter Speed','Bit Shift',...
    'Partition Count','Trigger Mode','Partition'};
camStrCt = numel(camStrCell);
hCamFields = {'width','height','recrate','shutter','bitshift',...
    'partcount','trigmode','partition'};
hCamPop = struct;
hCamParents = [1,1,1,2,2,2,2,3];
posOps = [.05 .75 .8 .15
    .05 .55 .8 .15
    .05 .35 .8 .15
    .05 .83 .8 .1
    .05 .67 .8 .1
    .05 .51 .8 .1
    .05 .36 .8 .1
    .05 .85 .8 .075];
for iterS = 1:camStrCt
    labelPos = posOps(iterS,:);
    uicontrol(hCamSubPnl(hCamParents(iterS)),'Style','text',...
        'string',[' ' camStrCell{iterS} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',9,'BackgroundColor',backC);
    editPos = labelPos+[0.4,0.09,-0.3,-0.06];
    hCamPop.(hCamFields{iterS}) = uicontrol(hCamSubPnl(hCamParents(iterS)),'Style',...
        'popupmenu','Units','normalized','HorizontalAlignment','left',...
        'fontsize',9,'string','...',...
        'position',editPos,'backgroundcolor',editC);
    set(hCamPop.(hCamFields{iterS}),'fontunits','normalized')
end

%Camera panel buttons
btnStrCell = {'Revert Old','Apply New','Calibrate',...
    'Snapshot','Trigger','Download','Refresh Image','Review'};
btnStrCt = numel(btnStrCell);
hCamBtns = struct;
hNames = {'display','apply','calib','snap','trig','download','refresh','review'};
hParents = [1,1,2,2,3,3,2,3];
posOps = [.05 .05 .4 .2
    .55 .05 .4 .2
    .05 .18 .9 .13
    .55 .03 .4 .13
    .05 .23 .3 .1
    .65 .23 .3 .1
    .05 .03 .4 .13
    .35 .23 .3 .1];
for iterB = 1:btnStrCt
    hCamBtns.(hNames{iterB}) = uicontrol(hCamSubPnl(hParents(iterB)),...
        'style','pushbutton','units','normalized',...
        'string',btnStrCell{iterB},'Position',posOps(iterB,:),...
        'fontsize',9,'fontunits','normalized','backgroundcolor',backC);
end

% camera controls
hCamStates = struct;
hCamStates.parent = uibuttongroup('parent',hCtrlPnl(2),'position',...
    guiPosFun([.5 .44],[.95 .06]),'backgroundcolor',backC,...
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
        'fontsize',9,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end

%%playback controls
iconshade = 0.1;
hBplayback = uibuttongroup('parent',hCamSubPnl(3),'position',...
    guiPosFun([.5 .15],[.95 .1]),'backgroundcolor',backC);
btnH = 1;
btnW = 1/7;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
btnHmat = zeros(7,1);
btnIcons = {'frev','rev','slowrev','stop','slowfwd','fwd','ffwd'};
for iterBtn = 1:7
    btnHmat(iterBtn) = uicontrol(hBplayback,'style','togglebutton','units','normalized',...
        'string',[],'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterBtn-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',15,'fontunits','normalized','backgroundcolor',backC,...
        'HandleVisibility','off','Enable','inactive');
    makePezIcon(btnHmat(iterBtn),0.7,btnIcons{iterBtn},iconshade,backC)
end
speedOps = [3,30,120];
speedOps = [fliplr(speedOps).*(-1) 0 speedOps];
set(hBplayback,'SelectedObject',[])

hCamPlayback = uicontrol('Parent',hCamSubPnl(3),'Style','slider',...
    'Units','normalized','Min',0,'Max',100,'callback',@hPlaybackCallback,...
    'Position',guiPosFun([.5 .05],[.95 .06]),'Backgroundcolor',backC);

%camera 'edit' controls
trigStrCell = {'Frames Before','Frames After',...
    'Total Frames','Total Duration'};
trigStrCt = numel(trigStrCell);
hNames = {'beforetrig','aftertrig','totframes','totdur'};
hCamEdit = struct;
hParents = [3,3,3,3];
posOps = [.05 .73 .8 .075
    .05 .61 .8 .075
    .05 .495 .8 .075
    .05 .37 .8 .075];
for iterG = 1:trigStrCt
    labelPos = posOps(iterG,:);
    uicontrol(hCamSubPnl(hParents(iterG)),'Style','text',...
        'string',[' ' trigStrCell{iterG} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',9,'BackgroundColor',backC);
    editPos = labelPos+[0.4,0.02,-0.3,0];
    hCamEdit.(hNames{iterG}) = uicontrol(hCamSubPnl(hParents(iterG)),'Style',...
        'edit','Units','normalized','HorizontalAlignment','left',...
        'fontsize',9,'string','...',...
        'position',editPos,'backgroundcolor',editC);
    set(hCamEdit.(hNames{iterG}),'fontunits','normalized')
end



%%%%%%% flyPez Panel %%%%%%%
lightInit = 40;
shadow = 225;
gap = 2;
setTempFan = 26;
gatestart = 0;
gateend = 0;
ellovervee = 70;
aziVal = 0;
eleVal = 0;

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
        'string',headStrCell{iterH},'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'BackgroundColor',bhC,'foregroundcolor',logoC);
end

%Gate plots
pezAxesPos = guiPosFun([0.5,Yops(headYops(2)+30)],[0.95 H*8]);
hAxesPez = axes('xtick',[],'ytick',[],'xticklabel',[],...
    'yticklabel',[],'xlim',[1 128],'ylim',[0 275],...
    'position',pezAxesPos,'nextplot','add','parent',hCtrlPnl(1));
hPlotGate = cell(5,1);
colorGate = {'k','b','r','r','k'};
for iterGate = 1:numel(hPlotGate)
    hPlotGate{iterGate} = plot(1,1,'linewidth',1,'color',...
        colorGate{iterGate},'parent',hAxesPez);
end
set(hPlotGate{1},'linewidth',2)
set(hPlotGate{2},'XData',0:127,'YData',repmat(shadow,1,128))

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
    [.05 .7 .12 .1],[.45 .7 .27 .1],[.1 .43 .4 .1]};
hP = [1 2 3 3 4 5 8 8 8 8 10 12 12 12];
strOp = {'XX.X deg C','XX.X%','Fan Trigger (deg C): ','XXX% power',...
    [num2str(lightInit) '%'],[num2str(lightInit) '%'],...
    'Set Shadow Threshold: ','Set Gap Threshold: ',...
    'Open position: XXX% ---------','Closed position: XXX% ------',...
    'Click reset to enable','l/v :','Elevation :','Azimuth :'};
ctrlCt = numel(hP);
hPezReport = zeros(ctrlCt,1);
for iterG = 1:ctrlCt
    hPezReport(iterG) = uicontrol(hSubPnl(hP(iterG)),'Style','text',...
        'Units','normalized','HorizontalAlignment','left',...
        'fontsize',9,'string',strOp{iterG},'fontunits','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
end

% simple controls with callbacks other than pushbuttons
posOp = {[.85 .55 .1 .4],[.25 .5 .1 .4],[.25 .1 .1 .4],[.2 .82 .6 .15],...
    [.05 .65 .9 .125],[.15 .85 .8 .125],[.15 .75 .8 .125],...
    [.15 .65 .8 .125],[.18 .72 .2 .1],[.76 .72 .2 .1],...
    [.4 .45 .2 .1],[.1 .35 .8 .1],[.1 .05 .8 .1]};
hP = [3 8 8 9 9 11 11 11 12 12 12 12 12];
styleOp = {'edit','edit','edit','checkbox','togglebutton','checkbox',...
    'checkbox','checkbox','edit','edit','edit','checkbox','checkbox'};
strOp = {num2str(setTempFan)%1
    shadow%2
    gap%3
    'Display ROI'%4
    'Show Background'%5
    'Engage Fly Detect'%6
    'Run Autopilot'%7
    'Overlay Annotations'%8
    num2str(ellovervee)%9
    num2str(eleVal)%10
    num2str(aziVal)%11
    'Import from fly detect'%12
    'Couple with camera trigger'};%13
callbackOp = {@setTemperature,@hshadowth,@hgapth,@hDispROICall,...
    @highlightBackground,[],@setAutopilotCall,...
    @overlayAnnotationsCall,[],[],[],[],...
    @coupleToCameraCall};
ctrlCt = numel(hP);
hPezRandom = zeros(ctrlCt,1);
for iterG = 1:ctrlCt
    hPezRandom(iterG) = uicontrol(hSubPnl(hP(iterG)),'Style',styleOp{iterG},...
        'Units','normalized','HorizontalAlignment','center','fontsize',9,...
        'string',strOp{iterG},'fontunits','normalized','position',...
        posOp{iterG},'backgroundcolor',backC,'Callback',callbackOp{iterG});
end

% Fan toggle manual versus auto
hFanStates = uibuttongroup('parent',hSubPnl(3),'position',[.02 .12 .36 .7],...
    'backgroundcolor',backC,'SelectionChangeFcn',@fanToggleCallback);
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
pezSlideCall = {@setFanCallback,@lightAcallback,@lightBcallback,...
    @hOpen1Callback,@hBlock1Callback};
pezSlideVals = [setTempFan,lightInit,lightInit,0,0];
hPezSlid = zeros(pezSlideCt,1);
for iterSD = 1:pezSlideCt
    hPezSlid(iterSD) = uicontrol('Parent',hSubPnl(hP(iterSD)),'Style','slider',...
        'Units','normalized','Min',0,'Max',100,'Value',pezSlideVals(iterSD),...
        'Position',posOp{iterSD},'Backgroundcolor',backC,...
        'Callback',pezSlideCall{iterSD});
end

% pezButtons
posOp = {[.1 .51 .8 .4],[.1 .1 .8 .4],[.1 .55 .25 .35],[.1 .45 .8 .125],...
    [.1 .325 .8 .125],[.1 .15 .8 .125],[.1 .025 .8 .125],[.1 .1 .8 .35],...
    [.1 .58 .8 .1],[.1 .2 .8 .1]};
hP = [6 6 7 9 9 9 9 10 12 12];
strOp = {'Calibrate','Sweep','Find Gates','Auto Set ROI','Manual Set ROI',...
    'Coarse Focus','Fine Focus','Reset','Initialize','Display'};
callbackOp = {@hCalibrate,@hSweepGateCallback,@hFindButtonCallback,...
    @hAutoSetROI,@hManualSetROI,@coarseCallback,@focusFeedback,...
    @flyCountCallback,@initializeVisStim,@displayVisStim};
ctrlCt = numel(hP);
hPezButn = zeros(ctrlCt,1);
for iterG = 1:ctrlCt
    hPezButn(iterG) = uicontrol(hSubPnl(hP(iterG)),'Style','pushbutton',...
        'fontsize',8,'string',strOp{iterG},'units','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC,...
        'callback',callbackOp{iterG});
end
set(hPezButn,'fontunits','normalized')
set(hPezButn(6:7),'Style','togglebutton')

% Gate auto versus manual
hGateMvA = uibuttongroup('parent',hSubPnl(7),'position',...
    [.425 .55 .5 .4],'backgroundcolor',backC);
set(hGateMvA,'SelectionChangeFcn',@hAutoButtonCallback);
btnNames = {'Manual Block','Auto Block'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hGateModeBtns = zeros(btnCt,1);
for iterStates = 1:btnCt
    hGateModeBtns(iterStates) = uicontrol(hGateMvA,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end

% Manually Selecting Gate Mode
hGateStatePnl = uibuttongroup('parent',hSubPnl(7),'position',...
    [.01 .01 .98 .45],'backgroundcolor',backC);
set(hGateStatePnl,'SelectionChangeFcn',@gateSelectCallback);
btnNames = {'Open','Block','Close','Clean'};
btnCt = numel(btnNames);
btnH = 1;
btnW = 1/btnCt;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
hGateStates = zeros(btnCt,1);
for iterStates = 1:btnCt
    hGateStates(iterStates) = uicontrol(hGateStatePnl,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
set(hGateStatePnl,'SelectedObject',hGateStates(1));

% Trigger on single versus escape
hTrigSvE = uibuttongroup('parent',hSubPnl(11),'position',...
    [.025 .425 .95 .2],'backgroundcolor',backC,'Title','Trigger on');
set(hTrigSvE,'SelectionChangeFcn',@hTrigSelectCallback);
btnNames = {'Escape','Single in frame'};
btnCt = numel(btnNames);
posOps = {[.05 .05 .35 .9],[.45 .05 .5 .9]};
hTrigModeBtns = zeros(btnCt,1);
for iterStates = 1:btnCt
    hTrigModeBtns(iterStates) = uicontrol(hTrigSvE,'style','togglebutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},...
        'fontsize',8,'fontunits','normalized','HandleVisibility','off',...
        'backgroundcolor',backC);
end
set(hTrigSvE,'SelectedObject',hTrigModeBtns(2))

% Fly detect status report
hDetectRadioGrp = uibuttongroup('parent',hSubPnl(11),'position',...
    [.025 .01 .95 .35],'backgroundcolor',backC,'Title','Fly Detect Interpretations');
set(hDetectRadioGrp,'SelectionChangeFcn',@hTrigSelectCallback);
btnNames = {'Empty','Single in view','Single in frame','Multi'};
btnCt = numel(btnNames);
posOps = {[.05 .55 .35 .4],[.425 .55 .55 .4],[.425 .05 .55 .4],[.05 .05 .35 .4]};
hDetectRadios = zeros(btnCt,1);
for iterStates = 1:btnCt
    hDetectRadios(iterStates) = uicontrol(hDetectRadioGrp,'style','radiobutton',...
        'units','normalized','string',btnNames{iterStates},'Position',...
        posOps{iterStates},'fontsize',8,...
        'fontunits','normalized','HandleVisibility','off','backgroundcolor',backC);
end
set(hDetectRadioGrp,'SelectedObject',hDetectRadios(1))

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

disp('Camera is ready')

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

listShutter = arrayfun(@(x) cellstr(int2str(x)),(nShutterList(nShutterList > 0)));
listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
set(hCamPop.shutter,'String',listShutter)
nTriggerModeList = [PDC.TRIGGER_START,PDC.TRIGGER_CENTER,...
    PDC.TRIGGER_END,PDC.TRIGGER_MANUAL];
listTrigger = {'START','CENTER','END','MANUAL'};
trigVal = find(nTrigMode == nTriggerModeList);
set(hCamPop.trigmode,'String',listTrigger,'Value',trigVal)

set(hCamBtns.display,'callback',@dispCurrentSettings)
set(hCamBtns.apply,'callback',@applyNewSettings)
set(hCamBtns.calib,'callback',@calibrateCallback)
set(hCamBtns.snap,'callback',@captureSingleCallback)
set(hCamBtns.trig,'callback',@triggerCallback)
set(hCamBtns.download,'callback',@downloadRecordingCallback)
set(hCamBtns.refresh,'callback',@refreshFrameCallback)
set(hCamPop.shutter,'callback',@shutterSpeedCallback)
set(hCamPop.bitshift,'callback',@bitshiftCallback)
set(hCamPop.trigmode,'callback',@triggerModeCallback)
set(hCamStates.parent,'SelectionChangeFcn',@camStateCallback)
set(hCamStates.parent,'SelectedObject',hCamStates.children(1))


%%%% Fly Detect Setup %%%%
template_dir = fullfile(funcParent,'pez3000_templates');
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

%additional children
frmData = uint8(zeros(nHeight,nWidth));
hImA = image('Parent',hAxesA,'CData',frmData);
rowROI = [NaN NaN];
colROI = [NaN NaN];
xROI = 0;
yROI = 0;
stagePos = 0;
set(hAxesA,'nextplot','add','YDir','reverse')
hPlotROI = plot(0,0,'Marker','.','Color',[0 0 0.8],...
    'Parent',hAxesA,'LineStyle','none');
hPlotPre = plot(0,0,'Parent',hAxesA,'LineStyle','none');
hPlotPost = plot(0,0,'Parent',hAxesA,'LineStyle','none');
set(hPlotPost,'Marker','o','MarkerFaceColor',[1 1 0],...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',4)
set(hPlotPre,'Marker','o','MarkerFaceColor',[0 0 1],...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',4)
hPlotH = plot(0,0,'Marker','*','Color',[0 1 0],...
    'Parent',hAxesA,'LineStyle','none','MarkerSize',15);
hPlotT = plot(0,0,'Marker','*','Color',[1 0 0],...
    'Parent',hAxesA,'LineStyle','none','MarkerSize',15);
u = cos(flyTheta).*tmplLeg*2+1;
v = -sin(flyTheta).*tmplLeg*2+1;
hQuivA = quiver(0,0,u,v,'MaxHeadSize',1,'LineWidth',1.5,...
    'AutoScaleFactor',1,'Color',[1 1 1],'Parent',hAxesA,'Visible','off');
set(hAxesA,'nextplot','replacechildren')


%% only run the following as a function!!!
%initialize timers
frmCounter = 0;
tCam = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',round((1/30)*100)/100);
tDet = timer('TimerFcn',@resetDetectFun,'Period',10);
tExpt = timer('TimerFcn',@experimentOverFun,'Period',20*60);
tFoc = timer('TimerFcn',@focusTimerFun,'ExecutionMode','fixedRate',...
    'Period',round((1/30)*100)/100);
FocTab = zeros(6,1);
% tPlot = timer('TimerFcn',@removePlot,'StartDelay',3.0);

%prepare for photodiode acquisition
sDiode = initializeDiodeNidaq;
hListener = sDiode.addlistener('DataAvailable',@trigDetect);
diodeDataA = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeDataB = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
diodeData = zeros(sDiode.NotifyWhenDataAvailableExceeds,1);
overSampleFactor = 10;
sDiode.IsContinuous = true;
sDiode.Rate = double(nFps*overSampleFactor);
sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
recEndTime = [];

% Setup the serial
delete(instrfindall)
sPez = serial('COM4');
set(sPez,'baudrate',250000,'inputbuffersize',100*(128+3),...
    'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
    @receiveData,'Terminator','CR/LF','StopBits',2);
fopen(sPez);
set(hFigA,'CloseRequestFcn',@myCloseFun)
% end
camStartupFun

    function camStartupFun
        % send linear array data
        fwrite(sPez,sprintf('%s\r','V'));
        lightAcallback([],[])
        lightBcallback([],[])
        dispCurrentSettings([],[])
        applyNewSettings([],[])
        camStateCallback([],[])
    end
    function dispCurrentSettings(~,~)
        set(hCamPop.width,'Value',find(nWidth == listWidthNum))
        set(hCamPop.height,'Value',find(nHeight == listHeightNum))
        set(hCamPop.recrate,'Value',find(nRate == nRecordRateList))
    end
    function applyNewSettings(~,~)
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
        listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
        set(hCamPop.shutter,'String',listShutter,'Value',1);
        [nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
        sDiode.Rate = double(nFps*overSampleFactor);
        sDiode.NotifyWhenDataAvailableExceeds = double(nFrames*overSampleFactor);
        boxRatio = double([nWidth nHeight])./double(max(nWidth,nHeight));
        boxRatio(3) = 1;
        set(hAxesA,'xlim',[1 nWidth],'ylim',[1 nHeight],...
            'PlotBoxAspectRatio',boxRatio)
    end
    function shutterSpeedCallback(~,~)
        if strcmp(tCam.Running,'on')
            stop(tCam)
            nFps = nShutterList(get(hCamPop.shutter,'Value'));
            [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
            start(tCam)
        else
            nFps = nShutterList(get(hCamPop.shutter,'Value'));
            [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
        end
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
%         drawnow
        [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nColorMode,nBayer,nWidth,nHeight);
        frmData = nBuf';
        flyDetect([],[])
        set(hImA,'CData',frmData)
        drawnow
        if frmCounter == 0
            tic
            frmCounter = 1;
        else
            frmCounter = frmCounter+1;
            if frmCounter >= 120
                totTime = toc;
                disp(['Average frame rate: ',num2str(frmCounter/totTime,2)]);
                frmCounter = 0;
            end
        end
    end
    function resetDetectFun(~,~)
        detectTabs = 0;
        hSweepGateCallback
    end
    function hDispROICall(~,~)
        dispVal = get(hPezRandom(4),'Value');
        switch dispVal
            case 0
                set(hPlotROI,'Visible','off')
            case 1
                set(hPlotROI,'XData',[xROI(:);NaN;stagePos(:,1)],...
                    'YData',[yROI(:);NaN;stagePos(:,2)],'Visible','on')
                
        end
    end
    function highlightBackground(~,~)
        butVal = get(hPezRandom(5),'Value');
        tempVal = 1;
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
            set(hPezRandom(5),'UserData',[rateVal bitVal])
        else
            userVals = get(hPezRandom(5),'UserData');
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
    function startExptCallback(~,~)
        if strcmp(tExpt.Running,'off'), start(tExpt), end
    end
    function experimentOverFun(~,~)
    end
    function hAutoSetROI(~,~)
%         inactivateChildren(hPanelsMain(1))
%         toggleChildren(hPanelsMain(1),0)
        if get(hPezRandom(5),'Value') == 0
            set(hPezRandom(5),'Value',1)
            highlightBackground
        end
        if strcmp(tCam.Running,'on'), stop(tCam), end
        dispLiveImage
        nRet = 0;
        dispLiveImage
        while nRet == 0, end
        grth = graythresh(frmData)*1;
        frmGr = im2bw(frmData,grth);
%         figure,imshow(frmGr)
%         uiwait(gcf)
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
%         figure,imshow(frmBotBW)
%         uiwait(gcf)
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
        set(hPlotPre,'XData',xPlot,'YData',yPlot)
        
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
%         activateChildren(hPanelsMain(1))
%         toggleChildren(hPanelsMain(1),1)
    end
    function flyDetect(~,~)
        if get(hPezRandom(6),'Value') == 0, return, end
%         tic
        if isempty(roiPos), return, end
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
            set(hPlotPost,'Visible','off')
            set(hPlotH,'Visible','off')
            set(hPlotT,'Visible','off')
            set(hQuivA,'Visible','off')
            diodeData = blkValPre;
            diodeData(diodeData < -5) = -5;
%             toc
            return
        end
        xPlot = roiPos(1)+xOps(:)*2;
        yPlot = roiPos(2)+yOps(:)*2;
        set(hPlotPost,'XData',xPlot,'YData',yPlot,'Visible','on')
        
        xOps = repmat(xOps,numel(xOffs)/ptTryCt,1)+xOffs(:);
        yOps = repmat(yOps,numel(yOffs)/ptTryCt,1)+yOffs(:);
        ptOps = [xOps,yOps];
        iDemo = 0;
        headVals = posFinder(headNdxrA,headTmplA);
        tailVals = posFinder(tailNdxrA,tailTmplA);
        diodeData = [headVals(:,1),tailVals(:,1)];
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
            elseif detectTabs(1) == 1;
                detectTabs(1) = 4;
                detectTabs(2:3) = mean([headPos;tailPos])-detectTabs(2:3);
                detectTabs(4) = flyTheta-detectTabs(4);
            else
                detectTabs = 0;
            end
            
            xPlot = roiPos(1)+[headPos(1) tailPos(1)]*2;
            yPlot = roiPos(2)+[headPos(2) tailPos(2)]*2;
            set(hPlotH,'XData',xPlot(1),'YData',yPlot(1),'Visible','on')
            set(hPlotT,'XData',xPlot(2),'YData',yPlot(2),'Visible','on')
        elseif headState
            headState = 2;
            headSize = layerFindr(headVals(headNdx,2));
            xPlot = roiPos(1)+headPos(1)*2;
            yPlot = roiPos(2)+headPos(2)*2;
            set(hPlotH,'XData',xPlot,'YData',yPlot,'Visible','on')
            set(hPlotT,'Visible','off')
            testY = max(headPos <= tmplLeg+1+rotInset);
            testX = max(fliplr(headPos) >= smlDims-tmplLeg-rotInset);
            testZ = headMax < rotThresh;
            if ~max([testX,testY,testZ])
                flyTheta = rotFinder(headPos,headNdxrRot(:,:,headSize),...
                    headTmplRot(:,:,headSize));
                if detectTabs(1) ~= 2
                    detectTabs = [2,headPos,flyTheta];
                elseif detectTabs(1) == 2;
                    detectTabs(1) = 4;
                    detectTabs(2:3) = headPos-detectTabs(2:3);
                    detectTabs(4) = flyTheta-detectTabs(4);
                else
                    detectTabs = 0;
                end
            else
                flyTheta = NaN;
            end
        elseif tailState
            tailState = 2;
            tailSize = layerFindr(tailVals(tailNdx,2));
            xPlot = roiPos(1)+tailPos(1)*2;
            yPlot = roiPos(2)+tailPos(2)*2;
            set(hPlotT,'XData',xPlot,'YData',yPlot,'Visible','on')
            set(hPlotH,'Visible','off')
            testX = max(tailPos <= tmplLeg+1+rotInset);
            testY = max(fliplr(tailPos) >= smlDims-tmplLeg-rotInset);
            testZ = tailMax < rotThresh;
            if ~max([testX,testY,testZ])
                flyTheta = rotFinder(tailPos,tailNdxrRot(:,:,tailSize),...
                    tailTmplRot(:,:,tailSize));
                if detectTabs(1) ~= 3
                    detectTabs = [3,tailPos,flyTheta];
                elseif detectTabs(1) == 3;
                    detectTabs(1) = 4;
                    detectTabs(2:3) = tailPos-detectTabs(2:3);
                    detectTabs(4) = flyTheta-detectTabs(4);
                else
                    detectTabs = 0;
                end
            else
                flyTheta = NaN;
            end
        else
            flyTheta = NaN;
            set(hPlotH,'Visible','off')
            set(hPlotT,'Visible','off')
        end
%         toc
        
        iDemo(size(roiBlkSml,1),end) = 0;
        roiBlkSml(size(iDemo,1),end) = 0;
        roiBlkSml = [roiBlkSml,iDemo];
        frmData(1:size(roiBlkSml,1),1:size(roiBlkSml,2)) = uint8(roiBlkSml.*255);
        
        if isnan(flyTheta)
            set(hQuivA,'Visible','off')
        else
            u = cos(flyTheta).*tmplLeg*2+1;
            v = -sin(flyTheta).*tmplLeg*2+1;
            set(hQuivA,'UData',u,'VData',v,'Visible','on')
            if get(hPezRandom(12),'Value') == 1
                set(hPezRandom(11),'String',num2str(flyTheta/(pi/180)))
            end
        end
        
        posThresh = 5;
        dirThresh = 10;
        if detectTabs(1) == 4
            posDelta = sqrt(sum(detectTabs(2:3).^2))
            dirDelta = detectTabs(4)
            if posDelta < posThresh && dirDelta < dirThresh
                triggerCallback([],[])
            end
        elseif detectTabs(1) == 0
            if strcmp(tDet.Running,'on'), stop(tDet), end
        else
            if strcmp(tDet.Running,'off'), start(tDet), end
        end
        
        set(hDetectRadioGrp,'SelectedObject',hDetectRadios(2))
        
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
            [~,maxPos] = max(blkVal(:,1));
            miB = blkVal(maxPos,2);
            
            if ~isnan(miB)
                negDim = ptOps(maxPos,:)-tmplLeg;
                posDim = ptOps(maxPos,:)+tmplLeg;
                if min(negDim) < 1, return, end
                if max(fliplr(posDim) > smlDims), return, end
                blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
                blkNdxt = blk(ndxr);
                blkDemo = reshape(blkNdxt(:,miB),spokeL,rotOpsTmpl);
                tmplDemo = reshape(tmpl(:,miB),spokeL,rotOpsTmpl);
                demoBlk = imresize([blkDemo;tmplDemo],3);
                iDemo(size(demoBlk,1),end) = 0;
                demoBlk(size(iDemo,1),end) = 0;
                iDemo = [iDemo,zeros(size(demoBlk,1),10),demoBlk];
            end
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
            
            blkDemo = reshape(blkNdxt(:,mi),spokeL,120);
            tmplDemo = reshape(tmpl(:,mi),spokeL,120);
            demoBlk = imresize([blkDemo;tmplDemo],2);
            iDemo(end,size(demoBlk,2)) = 0;
            demoBlk(end,size(iDemo,2)) = 0;
            iDemo = [iDemo;zeros(size(demoBlk));demoBlk];
        end
    end

    function coarseCallback(~,~)
        state = get(hPezButn(6),'Value');
        if state == 1
            if get(hPezRandom(5),'Value') == 0
                set(hPezRandom(5),'Value',1)
                highlightBackground
            end
            hCalibrate
        else
            hSweepGateCallback
        end
    end
    function focusFeedback(~,~)
        focusVal = get(hPezButn(7),'Value');
        if stagePos == 0
            disp('Set ROI first')
            if get(hPezButn(6),'Value') == 1
                set(hPezButn(6),'Value',0)
                hSweepGateCallback
            end
            return
        elseif focusVal == 1
            if get(hPezRandom(5),'Value') == 0
                set(hPezRandom(5),'Value',1)
                highlightBackground
            end
            if get(hPezButn(6),'Value') == 1
                set(hPezButn(6),'Value',0)
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
%             xFoc = [FocTab(3) FocTab(4) FocTab(4) FocTab(3) FocTab(3)];
%             yFoc = [FocTab(6) FocTab(6) FocTab(5) FocTab(5) FocTab(6)];
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
        butValN = get(hCamStates.parent,'SelectedObject');
        caseVal = find(butValN == hCamStates.children);
        switch caseVal
            case 1
                if nStatus ~= PDC.STATUS_LIVE
                    [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
                    if nRet == PDC.FAILED, disp(['SetStatus Error ' int2str(nErrorCode)]), end
                end
                if strcmp(tCam.Running,'off'),start(tCam),end
            case 2
                if strcmp(tCam.Running,'on'),stop(tCam),end
            case 3
                [nRet, nErrorCode] = PDC_SetRecReady(nDeviceNo)
                [nRet, nErrorCode] = PDC_SetEndless(nDeviceNo)
            case 4
                if strcmp(tCam.Running,'on'),stop(tCam),end
                set(hCamPlayback,'Max',nFrames)
                if nTrigMode == PDC.TRIGGER_MANUAL
                    playMin = nFrames-nAFrames-str2double(get(hCamEdit.beforetrig,'String'))
                    set(hCamPlayback,'Min',playMin)
                end
                [nRet, nErrorCode] = PDC_SetStatus(nDeviceNo, PDC.STATUS_PLAYBACK)
                [ nRet, FrameInfo, nErrorCode ] = PDC_GetMemFrameInfo( nDeviceNo, nChildNo );
                [ nRet, nRate, nErrorCode ] = PDC_GetMemRecordRate( nDeviceNo, nChildNo );
                [ nRet, nWidth, nHeight, nErrorCode ] = PDC_GetMemResolution( nDeviceNo, nChildNo );
                [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );
        end
    end
    function triggerModeCallback(~,~)
        nTrigRef = get(hCamPop.trigmode,'Value');
        nAFrames = 0;
        nRFrames = 0;
        nRCount = 0;
        nTrigMode = nTriggerModeList(nTrigRef);
        switch nTrigRef
            case 1
                set(hCamEdit.beforetrig,'String',num2str(0))
                set(hCamEdit.aftertrig,'String',num2str(nFrames))
            case 2
                set(hCamEdit.beforetrig,'String',num2str(nFrames/2))
                set(hCamEdit.aftertrig,'String',num2str(nFrames/2))
            case 3
                set(hCamEdit.beforetrig,'String',num2str(nFrames))
                set(hCamEdit.aftertrig,'String',num2str(0))
            case 4
                nAFrames = str2double(get(hCamEdit.aftertrig,'String'));
                set(hCamEdit.beforetrig,'String',num2str(nFrames-nAFrames))
        end
        [nRet, nErrorCode] = PDC_SetTriggerMode(nDeviceNo,nTrigMode,nAFrames,nRFrames,nRCount);
    end
    function triggerCallback(~,~)
        if (get(hPezRandom(13),'Value') == get(hPezRandom(13),'Max'))
            displayVisStim([],[])
        end
        [nRet,nErrorCode] = PDC_TriggerIn(nDeviceNo);
    end

    function downloadRecordingCallback(~,~)
        currTime = datestr(rem(now,1),'HHMMSS');
        vidDest = fullfile(vidDir,[currDate '_' currTime '.mp4']);
        vidObj = VideoWriter(vidDest,'MPEG-4');
        open(vidObj)
        vidBegin = str2double(get(hCamEdit.beforetrig,'String'))
        vidEnd = str2double(get(hCamEdit.aftertrig,'String'))
        tic
        for frmRef = vidBegin:vidEnd
            frmRef
            nErrorCode = 0;
            [nRet, nData, nErrorCode] = PDC_GetMemImageData(nDeviceNo, nChildNo, frmRef, nBitDepth, nColorMode, nBayer, nWidth, nHeight);
            while nErrorCode == 0, end
            frmWrite = nData';
            %                     vidArray(:,:,frmRef) = frmWrite;
            writeVideo(vidObj,frmWrite)
        end
        close(vidObj)
        disp('file saved')
        toc
    end
    function hPlaybackCallback(~,~)
        nFrameNo = round(get(hCamPlayback,'Value'));
        [nRet, nData, nErrorCode] = PDC_GetMemImageData(nDeviceNo, nChildNo, nFrameNo, nBitDepth, nColorMode, nBayer, nWidth, nHeight);
        frmData = flipud(nData');
        fD = double(frmData);
        fD = (fD-min(fD(:)))./range(fD(:));
        frmData = uint8(fD.*255);
        set(hImA,'CData',frmData)
        drawnow
        disp(num2str(nFrameNo))
    end
    function captureSingleCallback(~,~)
        imageCap = flipud(frmData);
        currTime = datestr(rem(now,1),'HHMMSS');
        capDest = fullfile(snapDir,[currDate '_' currTime '.tif']);
        imwrite(imageCap,capDest,'tif')
    end

    function initializeVisStim(~,~)
        stimStruct = get(hPezButn(9),'UserData');
        if isempty(stimStruct)
            stimStruct = initializeVisualStimulusGeneral;
            set(hPezButn(9),'UserData',stimStruct)
        end
        stimStruct.ellovervee = str2double(get(hPezRandom(9),'string'));
        stimTrigStruct = initializeBlackDiskOnWhite(stimStruct);
        stimTrigStruct(1).eleVal = str2double(get(hPezRandom(10),'string'));
        set(hPezButn(10),'UserData',stimTrigStruct)
    end
    function displayVisStim(~,~)
        stimTrigStruct = get(hPezButn(10),'UserData');
        stimTrigStruct(1).aziVal = str2double(get(hPezRandom(11),'string'));
%         fwrite(sPez,sprintf('%s\r','N'));
%         stopasync(sPez)
%         fclose(sPez)
        presentDiskStimulus(stimTrigStruct)
%         readasync(sPez)
%         fwrite(sPez,sprintf('%s\r','V'));
%         get(sPez)
%         j = batch('presentDiskStimulus',1,{stimTrigStruct},'CaptureDiary', true);
%         wait(j)
%         diary(j)
%         load(j)
    end
    function coupleToCameraCall(~,~)
        if (get(hPezRandom(13),'Value') == get(hPezRandom(13),'Max'))
            sDiode.startBackground();
        else
            stop(sDiode)
        end
    end
    function recDetect(~,event)
        recData = event.Data(:,2);
%         max(recData)
        if max(recData) > 4
            stop(sDiode)
            delete(hListener)
            hListener = sDiode.addlistener('DataAvailable',@trigDetect);
            sDiode.startBackground();
        end
    end
    function trigDetect(~,event)
        diodeDataB = event.Data(:,1);
        recData = event.Data(:,2);
%         min(recData)
        if min(recData) < 1
            stop(sDiode)
            delete(hListener)
            diodeData = [diodeDataA;diodeDataB];
            endRef = find(recData < 1,1,'first');
            cropDataEnd = numel(recData)+endRef-1;
            cropDataBegin = endRef;
%             diodeData = diodeData(cropDataBegin:cropDataEnd);
%             diodeData = mean(reshape(diodeData,overSampleFactor,...
%                 numel(recData)/overSampleFactor));
            diodeDataDir = 'Z:\W Ryan W\PezDocs\diodeData\diodeData.mat';
            save(diodeDataDir,'diodeData','recData')
            diodeTimeStamps = event.TimeStamps;
            recEndTime = diodeTimeStamps(endRef);
            hListener = sDiode.addlistener('DataAvailable',@recDetect);
            sDiode.startBackground();
        else
            diodeDataA = diodeDataB;
        end
    end

%%%%%%% flyPez Control Functions %%%%%%%
% Graph Thresholds
    function hshadowth(hObject,~)
        entry = str2double(get(hObject,'string'));
        entry = round(entry); %Set limit 0 - 275
        if entry >= 0 && entry <= 275
            shadow = entry;
            fwrite(sPez,sprintf('%s %u\r','E',shadow));
            set(hPlotGate{2},'XData',0:127,'YData',repmat(shadow,1,128))
        else
            set(hObject,'String',num2str(shadow))
        end
    end

    function hgapth(hObject,~)
        entry = str2double(get(hObject,'string'));
        entry = round(entry);
        if entry >= 1 && entry <= 100 %guessing what these should be... WRW
            gap = entry;
            fwrite(sPez,sprintf('%s %u\r','K',gap));
        else
            set(hObject,'String',num2str(gap))
        end
    end

% Fan Control
    function setFanCallback(hObject,~)
        slider_value = round(get(hObject,'Value')/10)*10;
        set(hObject,'Value',slider_value);
        set(hPezReport(4),'String',[num2str(slider_value) '%'])
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
        setTempFan = round(entry*10)/10;
        fwrite(sPez,sprintf('%s %u\r','Q',setTempFan));
    end

% Light Control
    function lightAcallback(~,~)
        slider_value = round(get(hPezSlid(2),'Value'));
        set(hPezSlid(2),'Value',slider_value);
        set(hPezReport(5),'String',[num2str(slider_value) '%'])
        fwrite(sPez,sprintf('%s %u\r','I',slider_value));
    end
    function lightBcallback(~,~)
        slider_value = round(get(hPezSlid(3),'Value'));
        set(hPezSlid(3),'Value',slider_value);
        set(hPezReport(6),'String',[num2str(slider_value) '%'])
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
        fwrite(sPez,sprintf('%s\r','F'));                %Find Gates
    end
    function hAutoButtonCallback(~,eventdata)
        butnValN = eventdata.NewValue;
        caseVal = find(butnValN == hGateModeBtns);
        stateVal = get(hGateStatePnl,'SelectedObject');
        if stateVal == hGateStates(1)
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
        butnValN = get(hGateStatePnl,'SelectedObject');
        caseVal = find(butnValN == hGateStates);
        switch caseVal
            case 1 %Opens Gate1
                MvAval = get(hGateMvA,'SelectedObject');
                if MvAval == hGateModeBtns(1)
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

% Set open and blocked position with slider bar.
    function hOpen1Callback(~,~)
        slider_value = round(get(hPezSlid(4),'Value'));
        set(hPezSlid(4),'Value',slider_value);
        set(hPezReport(9),'String',...
            ['Open position: ' num2str(slider_value) ' ---------'])
        setGateFun
    end
    function hBlock1Callback(~,~)
        slider_value = round(get(hPezSlid(5),'Value'));
        set(hPezSlid(5),'Value',slider_value);
        set(hPezReport(10),'String',...
            ['Closed position: ' num2str(slider_value) ' ------'])
        setGateFun
    end
    function setGateFun
        fwrite(sPez,sprintf('%s %u %u\r','D',get(hPezSlid(4),'Value'),get(hPezSlid(5),'Value')));
        gateSelectCallback([],[])
    end

% Fly Count Recording Function
    function flyCountCallback(~,~)
        fwrite(sPez,sprintf('%s\r','T'));
        set(hPezReport(11),'String','0');
    end

% Communication to MCU
    function receiveData(~,~)
        token = fscanf(sPez,'%s',4);
        switch token
            case '$GS,'
                gatepos = fscanf(sPez);
                posCell = textscan(gatepos,'%u%u','delimiter',',');
                set(hPezSlid(4),'Min',posCell{1},'Max',posCell{2},'Value',posCell{1});
                set(hPezSlid(5),'Min',posCell{1},'Max',posCell{2},'Value',posCell{2});
                hOpen1Callback([],[])
                hBlock1Callback([],[])
            case '$GF,'
                gateFind = fscanf(sPez);
                gateCell = textscan(gateFind,'%u%u%u','delimiter',',');
                gatestart = gateCell{1};
                gateend = gateCell{2};
                gap = gateCell{3};
                set(hPlotGate{3},'XData',repmat(gatestart,1,270),'YData',0:269)
                set(hPlotGate{4},'XData',repmat(gateend,1,270),'YData',0:269)
                set(hPlotGate{5},'XData',repmat(gateend+gap,1,270),'YData',0:269)
            case '$GE,'
                gatestate = fscanf(sPez);
                stateCell = textscan(gatestate,'%u%s','delimiter',',');
                if (stateCell{1} == 1)
                    stateRef = strfind('OBCH',stateCell{2}{1});
                    set(hGateStatePnl,'SelectedObject',hGateStates(stateRef));
                end
            case '$FC,'
                inpline = fscanf(sPez);
                inpCell = textscan(inpline,'%u%u','delimiter',',');
                set(hPezReport(11),'String',[num2str(inpCell{1}) num2str(inpCell{2})]);
            case '$ID,'
                gateData = fread(sPez,128);
                fscanf(sPez);
                gateData = gateData(1:128)*2;
                set(hPlotGate{1},'XData',(0:127),'YData',gateData)
            case '$TD,'
                input = fscanf(sPez);
                htCell = textscan(input,'%u%u','delimiter',',');
                t = double(htCell{2})/10;
                h = double(htCell{1})/10;
                set(hPezReport(2),'String',[num2str(h) ' %']);
                set(hPezReport(1),'String',[num2str(t) ' degC']);
        end
    end


% close and clean up
    function myCloseFun(~,~)
        sca
        fclose('all');
        if strcmp(tCam.Running,'on'),stop(tCam),end
        delete(timerfindall)
        delete(hFigA)
        delete(sPez);
        [nRet,nErrorCode] = PDC_CloseDevice(nDeviceNo);
        if nRet == PDC.FAILED
            disp(['CloseDevice Error ' int2str(nErrorCode)])
        end
        clear all
        close all
    end
end

