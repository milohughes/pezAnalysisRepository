function flyReleaseControl
%flyReleaseControl For standalone FlyPEZ function
%   Detailed explanation goes here

close all force

%%%%%%%%%%%%%% Main GUI uicontrol objects %%%%%%%%%%%%%%%%%
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];%input center(x,y) and size(x,y)
monPos = get(0,'MonitorPositions');
screen2use = 2;
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(1,:);
screen2cvr = 0.9;% portion of the screen to cover

% Color standards
backC = [0.8 0.8 0.8];
editC = [.85 .85 .85];
logoC = [0 0 0];
bhC = [.7 .7 .74];

%%%% Main GUI Figure %%%%%
set(groot,'defaultuipanelfontunits','points')
set(groot,'defaultuipanelunits','normalized')

set(groot,'defaultuicontrolfontunits','points')
set(groot,'defaultuicontrolunits','normalized')

set(groot,'defaultuibuttongroupfontunits','points')
set(groot,'defaultuibuttongroupunits','normalized')

FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
    (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
% FigPos(2) = FigPos(2)-scrnPos(4);
hFigA = figure('NumberTitle','off','Name','flyPez3000 CONTROL MODULE - WRW',...
    'menubar','none','Visible','off',...
    'units','pix','Color',[0.05 0 0.25],'pos',FigPos,'colormap',gray(256));
if isempty(mfilename) || strcmp(mfilename,'LiveEditorEvaluationHelperESectionEval')
    set(hFigA,'Visible','on')
end
% Main panels
hPanelsMain = uipanel('Units','normalized','Position',[0.015,0.02,0.55,0.96],...
    'backgroundcolor',backC);

%Logo
pezControlLogoFun

%%%%% Control panels %%%%%
posOps = [.01 .55 .64 .44];
hCtrlPnl = uipanel('Parent',hPanelsMain,'Title','flyPEZ',...
    'units','normalized','Position',posOps,...
    'FontSize',12,'backgroundcolor',backC);
set(hCtrlPnl,'fontunits','normalized')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% flyPez Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
setTemp = 23;
shadow = 225;
gap = 35;
tempMCU = 23;
humidMCU = 50;
coolerMCU = 100;

%Define spatial options
xBlox = 62;
yBlox = 108;
Xops = linspace(1/xBlox,1,xBlox);
Yops = fliplr(linspace(1/yBlox,1,yBlox));
Yops = (Yops-0.5)*2;
W = 1/xBlox;
H = 1/yBlox*2;

%Headings
headStrCell = {'Environment','Mechanics'};
headStrCt = numel(headStrCell);
headYops = [6 19 59];
for iterH = 1:headStrCt
    labelPos = [W,Yops(headYops(iterH)) W*60 H*3];
    hHead = uicontrol(hCtrlPnl(1),'Style','text',...
        'string',['  ' headStrCell{iterH}],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'BackgroundColor',bhC,...
        'foregroundcolor',logoC);
    set(hHead,'fontunits','normalized')
end

% Gate plots
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
    Xops(1) 0.05 W*30 0.93
    Xops(1) Yops(headYops(2)+14) W*12 H*13
    Xops(13) Yops(headYops(2)+14) W*36 H*13
    Xops(13) Yops(headYops(2)+24) W*48 H*9
    Xops(1) Yops(headYops(3)+33) W*16 H*32
    Xops(49) Yops(headYops(2)+14) W*12 H*13
    Xops(1) 0.05 W*45 0.5
    Xops(32) 0.05 W*29 0.93
    Xops(11) Yops(headYops(1)+7) W*10 H*6];
panelRefs = [1 1 1 1 4 1 1 1 2 1 3 4 1];
for iterG = 1:pezStrCt
    if panelRefs(iterG) > 1
        continue
    end
    hSubPnl(iterG) = uipanel(hCtrlPnl(panelRefs(iterG)),'HitTest','off','FontSize',10,...
        'Title',pezStrCell{iterG},...
        'TitlePosition','lefttop','Position',posOp(iterG,:),...
        'BackgroundColor',backC);
    set(hSubPnl(iterG),'FontUnits','Normalized')
end

% pez text only
posOp = {[.55 .1 .4 .7],[.1 .1 .9 .7],[.1 .1 .9 .7],[.1 .1 .9 .7],...
    [.8 .1 .15 .7],[.05 .47 .3 .4],[.05 .07 .3 .4],[.4 .5 .3 .4],...
    [.4 .1 .3 .4],[.1 .45 .8 .45],[.4 .03 .5 .1],[.55 .69 .3 .1],...
    [.55 .59 .3 .1],[.55 .49 .3 .1],[.67 .33 .27 .1],[.05 .4 .4 .15]};
hP = [13 1 2 3 4 8 8 8 8 10 12 12 12 12 12 9];
strOp = {'deg C'
    'XX.X deg C'
    'XX.X%'
    'XXX% power'
    '0%'
    'Shadow:'
    'Gap:'
    'Open: XXX%'
    'Block: XXX%'
    'Click reset to enable'
    'ms after camera triggers'
    'Elevation :'
    'Azimuth:'
    'Fly Heading :'
    'Duration (ms) '
    'Auto threshold:'};
hName = {'target','temp','humid','cooler','IRlights','shadow','gap',...
    'openpos','closepos','flycount','visdelay','ele','aziOff','aziFly',...
    'stimdur','autothresh'};
ctrlCt = numel(hP);
hPezReport = struct;
for iterG = 1:ctrlCt
    parentVal = hSubPnl(hP(iterG));
    if hP(iterG) == 9
%         parentVal = hCamSubPnl(4);
    end
    if panelRefs(hP(iterG)) > 1
        continue
    end
    hPezReport.(hName{iterG}) = uicontrol(parentVal,'Style','text',...
        'Units','normalized','HorizontalAlignment','left',...
        'fontsize',8,'string',strOp{iterG},...
        'position',posOp{iterG},'backgroundcolor',backC);
    set(hPezReport.(hName{iterG}),'fontunits','normalized')
end
% set(hPezReport.visdelay,'horizontalalignment','right')
% set(hPezReport.stimdur,'horizontalalignment','right')

% simple controls with callbacks other than pushbuttons
posOp = {[.1 .1 .4 .8],[.2 .5 .1 .4],[.2 .1 .1 .4],[.1 .05 .5 .15],...
    [.05 .67 .42 .25],[.025 .7 .25 .15],[.025 .25 .25 .15],[.2 .7 .15 .15],...
    [.2 .25 .15 .15],[.05 .05 .25 .1],[.8 .72 .15 .1],[.8 .62 .15 .1],[.8 .52 .15 .1],...
    [.74 .26 .2 .08],[.05 .15 .65 .1],[.27 .06 .17 .08],[.32 .45 .15 .15],...
    [.05 .25 .65 .1],[.05 .35 .55 .1]};
hP = [13 8 8 9 9 11 11 11 11 12 12 12 12 12 12 12 9 12 12];
styleOp = {'edit','edit','edit','checkbox','togglebutton','checkbox',...
    'checkbox','checkbox','checkbox','checkbox','edit','edit','edit','edit',...
    'checkbox','edit','edit','checkbox','checkbox'};
strOp = {num2str(setTemp)
    num2str(shadow)
    num2str(gap)
    'Display ROI'
    'Show Background'
    'Engage'
    'Autopilot'
    'Overlay'
    'Retain'
    'Display '
    '45'
    '0'
    '0'
    '0'
    'Alternate azimuth left vs right'
    '0'
    num2str(1)%auto threshold
    'Discard photodiode failures'
    'Azimuth relative to fly'};
ctrlCt = numel(hP);
hName = {'target','shadow','gap','roi','showback','flydetect','runauto','annotate',...
    'retain','couple','ele','aziOff','aziFly','stimdur','alternate','visdelay',...
    'autothresh','discard','aziRel2fly'};
hPezRandom = struct;
for iterG = 1:ctrlCt
    parentVal = hSubPnl(hP(iterG));
    if hP(iterG) == 9
%         parentVal = hCamSubPnl(4);
    end
    if panelRefs(hP(iterG)) > 1
        continue
    end
    
    hPezRandom.(hName{iterG}) = uicontrol(parentVal,'Style',styleOp{iterG},...
        'Units','normalized','HorizontalAlignment','center','fontsize',8,...
        'string',strOp{iterG},'position',...
        posOp{iterG},'backgroundcolor',backC);
    if strcmp(styleOp{iterG},'edit')
        set(hPezRandom.(hName{iterG}),'backgroundcolor',editC)
    end
    set(hPezRandom.(hName{iterG}),'fontunits','normalized')
end
% set(hPezRandom.stimdur,'enable','inactive','backgroundcolor',backC)
% set(hPezRandom.runauto,'enable','inactive')

% pezSliders
posOp = {[.1 .2 .65 .56],[.6 .6 .35 .3],...
    [.6 .2 .35 .3]};
hP = [4 8 8];
pezSlideCt = numel(posOp);
pezSlideVals = [0,0,0];
hNames = {'IRlights','open','block'};
hPezSlid = struct;
for iterSD = 1:pezSlideCt
    hPezSlid.(hNames{iterSD}) = uicontrol('Parent',hSubPnl(hP(iterSD)),'Style','slider',...
        'Units','normalized','Min',0,'Max',50,'Value',pezSlideVals(iterSD),...
        'Position',posOp{iterSD},'Backgroundcolor',backC);
end

% pezButtons
posOp = {[.1 .51 .8 .4],[.1 .1 .8 .4],[.1 .55 .25 .35],[.55 .67 .42 .25],...
    [.55 .4 .42 .25],[.55 .05 .42 .25],[.1 .1 .8 .35],...
    [.05 .65 .4 .12],[.05 .53 .4 .12],[.05 .24 .21 .15],[.26 .24 .21 .15]};
hP = [6 6 7 9 9 9 10 12 12 9 9];
strOp = {'Calibrate','Sweep','Find Gates','Auto ROI','Manual ROI',...
    'Fine Focus','Reset','Initialize','Display','More','Less'};
ctrlCt = numel(hP);
hNames = {'calib','sweep','findgates','autoroi','manualroi',...
    'finefoc','reset','initialize','display','more','less'};
hPezButn = struct;
for iterG = 1:ctrlCt
    parentVal = hSubPnl(hP(iterG));
    if hP(iterG) == 9
%         parentVal = hCamSubPnl(4);
    end
    if panelRefs(hP(iterG)) > 1
        continue
    end
    hPezButn.(hNames{iterG}) = uicontrol(parentVal,'Style','pushbutton',...
        'fontsize',8,'string',strOp{iterG},'units','normalized',...
        'position',posOp{iterG},'backgroundcolor',backC);
    set(hPezButn.(hNames{iterG}),'fontunits','normalized')
end
% set(hPezButn.finefoc,'Style','togglebutton')

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
        'fontsize',8,'HandleVisibility','off',...
        'backgroundcolor',backC);
    set(hGateMode.child(iterStates),'fontunits','normalized')
end

% pez communication on or off
hPezMode = struct;
pezmodepos = [Xops(1) Yops(headYops(2)+34) W*12 H*19];
hPezMode.parent = uibuttongroup('parent',hCtrlPnl(1),'position',...
    pezmodepos,'backgroundcolor',backC,'title','Com Control',...
    'fontsize',10);
set(hPezMode.parent,'fontunits','normalized')
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
        'fontsize',8,'HandleVisibility','off',...
        'backgroundcolor',backC);
    set(hPezMode.child(iterStates),'fontunits','normalized')
end
hPezButn.controlreset = uicontrol(hPezMode.parent,'Style','pushbutton',...
    'fontsize',8,'string','Hard Reset','units','normalized',...
    'position',[0.1 0.05 0.8 0.3],'backgroundcolor',backC);
set(hPezButn.controlreset,'fontunits','normalized')

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
        'fontsize',8,'HandleVisibility','off',...
        'backgroundcolor',backC);
    set(hGateState.child(iterStates),'fontunits','normalized')
end
set(hGateState.parent,'SelectedObject',hGateState.child(1));

if screen2use == 2
    FigPos(1) = monPos(2,1)+FigPos(1);
end
set(hFigA,'pos',FigPos)

set(hPezRandom.shadow,'callback',@hshadowth)
set(hPezRandom.gap,'callback',@hgapth)
set(hPezRandom.target,'callback',@setTemperature)
set(hGateMode.parent,'SelectionChangeFcn',@hAutoButtonCallback);
set(hGateState.parent,'SelectionChangeFcn',@gateSelectCallback);
set(hPezButn.calib,'callback',@hCalibrate)
set(hPezButn.sweep,'callback',@hSweepGateCallback)
set(hPezButn.findgates,'callback',@hFindButtonCallback)
set(hPezButn.reset,'callback',@flyCountCallback)
set(hPezButn.controlreset,'callback',@controllerResetCall)
set(hPezSlid.IRlights,'callback',@IRlightsCallback)
set(hPezSlid.open,'callback',@hOpen1Callback)
set(hPezSlid.block,'callback',@hOpen1Callback)
set(hPezMode.parent,'SelectionChangeFcn',@pezMonitorFun)

tunnelFlyCt = [];
MCUvar_gatePos = [];
MCUvar_gateState = [];
MCUvar_gateBound =  [];
MCUvar_gateData = [];
MCUvar_htData = [];
MCUvar_inpline = [];
MCUvar_cooler = [];
sPez = [];

posOpen = 90;
posBlock = 95;
defaultLightIntensity = 35;
comRef = '';
variablesDir = fullfile(userpath,'flyReleaseControl');
if ~isfolder(variablesDir)
    mkdir(variablesDir)
end
compDataPath = fullfile(variablesDir,'flyReleaseControl.pez');

%% only run the following as a function!!!
%initialize timers
liveRate = 10;%times to be executed per second
tPlay = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',round((1/liveRate)*100)/100,'StartDelay',1,'Name','tPlay');

initStates = struct('controller',false);
itemStates = struct('isAvail',initStates,'isRun',initStates,'shouldRun',initStates);

set(hFigA,'CloseRequestFcn',@myCloseFun)
pezStartupFun

%% Initialization functions
    function pezStartupFun
        %%%%% computer and directory variables and information
        if exist(compDataPath,'file')
            load(compDataPath,'compData','-mat')
            posOpen = compData.gate_open_pos;
            posBlock = compData.gate_block_pos;
            defaultLightIntensity = compData.IR_light_intensity;
        end
        serialOps = seriallist;
        portFound = false;
        for sIter = 1:numel(serialOps)
            try
                comRef = serialOps{sIter};
                controllerResetCall
                portFound = true;
                break
            catch
                continue
            end
        end
        
        if ~portFound
            errordlg('Valid COM port not found')
            pause(3)
            close(hFigA)
            return
        end
        hFindButtonCallback
        itemStates.isRun.controller = true;
        start(tPlay)
        set(hFigA,'Visible','on')
    end
    function controllerResetCall(~,~)
        itemStates.isRun.controller = false;
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
%         if get(hTrigMode.parent,'SelectedObject') ~= hTrigMode.child(3)
            set(hPezSlid.IRlights,'Value',defaultLightIntensity)
            IRlightsCallback([],[])
%         end
        fwrite(sPez,sprintf('%s\r','T'));
        itemStates.isRun.controller = true;
    end

%% Timer-related functions
    function dispLiveImage(~,~)
        if itemStates.isRun.controller, updateGatePlot, end
        drawnow
    end
    function updateGatePlot
        if ~isempty(MCUvar_gatePos)
            slideMin = 80;
            slideMax = 99;
            slideStep = 1/(abs(slideMax-slideMin)-1);
            set(hPezSlid.open,'Min',slideMin,'Max',slideMax,...
                'Value',posOpen,'Sliderstep',[slideStep slideStep]);
            set(hPezSlid.block,'Min',slideMin,'Max',slideMax,...
                'Value',posBlock,'Sliderstep',[slideStep slideStep]);
            hOpen1Callback([],[])
            MCUvar_gatePos = [];
        end
        if ~isempty(MCUvar_gateState)
            stateCell = textscan(MCUvar_gateState,'%u%s','delimiter',',');
            if (stateCell{1} == 1)
                stateRef = strfind('OBCH',stateCell{2}{1});
%                 if stateRef == 2 && get(hPezRandom.flydetect,'Value') == 1
%                     setFlydetectCall([],[])
%                 end
                set(hGateState.parent,'SelectedObject',hGateState.child(stateRef));
            end
            MCUvar_gateState = [];
        end
        if ~isempty(MCUvar_gateBound)
            gateCell = textscan(MCUvar_gateBound,'%u%u%u','delimiter',',');
            gStart = gateCell{1};
            gEnd = gateCell{2};
            gapval = gateCell{3};
            set(hPlotGate.start,'XData',repmat(gStart,1,270),'YData',0:269)
            set(hPlotGate.end,'XData',repmat(gEnd,1,270),'YData',0:269)
            set(hPlotGate.gap,'XData',repmat(gEnd+gapval,1,270),'YData',0:269)
            MCUvar_gateBound = [];
        end
        if ~isempty(MCUvar_gateData)
            MCUvar_gateData(MCUvar_gateData > 90) = 127;
            MCUvar_gateData = medfilt1(MCUvar_gateData);
            MCUvar_gateData(end) = 127;
            set(hPlotGate.data,'XData',(0:127),'YData',MCUvar_gateData(1:128)*2)
            MCUvar_gateData = [];
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
                    controllerResetCall
                    java.lang.Thread.sleep(5000);
                    itemStates.isRun.cameramonitor = itemStates.shouldRun.cameramonitor;
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
        if ~isempty(MCUvar_htData)
            htCell = textscan(MCUvar_htData,'%u%u%u','delimiter',',');
            tempMCU = double(htCell{2})/10;
            humidMCU = double(htCell{1})/10;
            coolerMCU = round((double(htCell{3})/255)*100);
            set(hPezReport.temp,'String',[num2str(tempMCU) ' deg C']);
            set(hPezReport.humid,'String',[num2str(humidMCU) ' %']);
            set(hPezReport.cooler,'String',[num2str(coolerMCU) ' % power']);
            MCUvar_htData = [];
        end
        if ~isempty(MCUvar_cooler)
            htCell = textscan(MCUvar_htData,'%u%u','delimiter',',');
            coolerMCU = double(htCell{1})/10;
            set(hPezReport.cooler,'String',[num2str(coolerMCU) ' % power']);
            MCUvar_cooler = [];
        end
         if ~isempty(MCUvar_inpline)
            inpCell = textscan(MCUvar_inpline,'%u%u','delimiter',',');
            if get(hPezRandom.runauto,'Value') == 1
                runEventLog('Fly detected in tunnel')
                tunnelFlyCt = tunnelFlyCt+1;
                set(hPezReport.flycount,'String',num2str(tunnelFlyCt));
            else
                set(hPezReport.flycount,'String',num2str(inpCell{1}));
            end
            MCUvar_inpline = [];
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

% Fly Count Reset
    function flyCountCallback(~,~)
        set(hPezReport.flycount,'String','0');
    end

% Sweeper Motor Functions
    function hCalibrate(~,~)
        fwrite(sPez,sprintf('%s\r','J'));%holds sweeper over prism
    end
    function hSweepGateCallback(~,~)%sweeps
%         if get(hPezRandom.retain,'Value') == 0
            fwrite(sPez,sprintf('%s\r','S'));
%         end
    end

% Find Gates
    function hFindButtonCallback(~,~)
        fwrite(sPez,sprintf('%s\r','C'));
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
                MCUvar_gatePos = fscanf(sPez);
            case '$GF,'
                MCUvar_gateBound = fscanf(sPez);
            case '$GE,'
                MCUvar_gateState = fscanf(sPez);
            case '$FC,'
                MCUvar_inpline = fscanf(sPez);
            case '$ID,'
                MCUvar_gateData = fread(sPez,128);
                fscanf(sPez);
            case '$TD,'
                MCUvar_htData = fscanf(sPez);
            case '$FB,'
                MCUvar_cooler = fscanf(sPez);
        end
    end


%% Close and clean up
    function myCloseFun(~,~)
        
        %stop and delete all timer objects
        stop(tPlay)
        delete(tPlay)
        delete(instrfindall);
        
        compData = struct();
%         compData.controller_COM_port = comRef;
        compData.gate_open_pos = posOpen;
        compData.gate_block_pos = posBlock;
        compData.IR_light_intensity = defaultLightIntensity; %#ok<STRNU>
        save(compDataPath,'compData');
        
        %delete the figure
        delete(hFigA)
        
        %delete any hidden handles such as waitbars
        set(0,'ShowHiddenHandles','on')
        delete(get(0,'Children'))
        
        %cover our bases
        close all
    end
end

