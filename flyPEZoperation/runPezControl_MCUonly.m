function runPezControl_MCUonly
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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


set(hDetectRadio.parent,'SelectionChangeFcn',@hTrigSelectCallback);
set(hPezRandom.temp,'callback',@setTemperature);
set(hPezRandom.shadow,'callback',@hshadowth)
set(hPezRandom.gap,'callback',@hgapth)
set(hGateMode.parent,'SelectionChangeFcn',@hAutoButtonCallback);
set(hGateState.parent,'SelectionChangeFcn',@gateSelectCallback);
set(hFanStates,'SelectionChangeFcn',@fanToggleCallback);
set(hPezButn.calib,'callback',@hCalibrate)
set(hPezButn.sweep,'callback',@hSweepGateCallback)
set(hPezButn.findgates,'callback',@hFindButtonCallback)
set(hPezButn.reset,'callback',@flyCountCallback)
set(hPezSlid.fan,'callback',@setFanCallback)
set(hPezSlid.lightA,'callback',@lightAcallback)
set(hPezSlid.lightB,'callback',@lightBcallback)
set(hPezSlid.open,'callback',@hOpen1Callback)
set(hPezSlid.block,'callback',@hBlock1Callback)
set(hPezMode.parent,'SelectionChangeFcn',@pezMonitorFun)


gatePosMCU = [];
gateStateMCU = [];
gateBoundMCU =  [];
gateDataMCU = [];
htDataMCU = [];
inplineMCU = [];


%% only run the following as a function!!!
%initialize timers
tCam = timer('TimerFcn',@dispLiveImage,'ExecutionMode','fixedRate',...
    'Period',round((1/10)*100)/100,'StartDelay',1);

% Setup the serial
delete(instrfindall)



%%% Modify this....
sPez = serial('COM5');




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
        start(tCam)
    end
    function dispLiveImage(~,~)
        try
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
        fclose('all');
        hTimers = timerfindall;
        for iT = 1:size(hTimers,2)
            if strcmp(hTimers(iT).Running,'on'),stop(hTimers(iT)),end
        end
        delete(hTimers)
        delete(sPez);
        delete(hFigA)
        clear all
        close all
    end
end

