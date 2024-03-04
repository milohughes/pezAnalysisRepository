function runPezControl_v2
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all force


Debug = 0;
% To debug a specific parameter of the gui, set to:
% 0 - Run all
% 1 - Only initialize flyPez
% 2 - Only initialize Camera
% 3 - Only initialize Metadata

% camera IP address
cameraIP = '192.168.0.10';
% in multi screen setup, this determines which screen to be used
screen2use = 2;
% portion of the screen to cover
screen2cvr = 0.9;

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

hFigA = figure('NumberTitle','off','Name','PEZ 3000 CONTROL - WRW','menubar','none',...
    'units','pix','Color',[0 0 0],'pos',FigPos,'colormap',gray(256));
set(hFigA,'Visible','on')
%Logo
logo = imread('logo.bmp');
logo(:,:,3) = round(logo(:,:,3).*0.7);
logo(:,:,1:2) = round(logo(:,:,1:2).*0.2);
logo = uint8(logo);
logo = imresize(logo,1.75);
logoSz = size(logo);
logoPos = [FigPos(3:4)*0.99-fliplr(logoSz(1:2)) fliplr(logoSz(1:2))];
hIcon = axes('Units','pix', 'Position', logoPos,'parent',hFigA);
image(logo,'Parent',hIcon,'HitTest','off');
set(hIcon,'units','normalized')
axis off
%Experiment display panel
hAxesA = axes('Parent',hFigA,'Position',guiPosFun([.21 .5],[.4 .96]),...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[]);

%Main panels and pseudo tabs
backC = [0.8 0.8 0.8];
tabC = [.7 .47];
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

%%%%% Control panels %%%%%
panStr = {'flyPez','Camera'};
panXops = [.34 .83];
panWops = [.64 .3];
hControlPanels = zeros(2,1);
for iterC = 1:2
    hControlPanels(iterC) = uipanel('Parent',hPanelsMain(1),'Title',panStr{iterC},...
        'Position',guiPosFun([panXops(iterC) 0.5],[panWops(iterC) 0.95]),...
        'FontSize',12,'backgroundcolor',backC);
end

%%%Camera panel
%Define spatial options
xBlox = 11;
yBlox = 27;
texXops = linspace(1/xBlox,1,xBlox)-1/xBlox/2;
texYops = fliplr(linspace(1/yBlox,1,yBlox)-1/yBlox/2);
texW = 1/xBlox;
texH = 1/yBlox;

%Labels
camStrCell = {'Width','Height','Rec Rate','Shutter Speed','Bit Shift',...
    'Trigger Mode','Partition'};
camStrCt = numel(camStrCell);
hCamLabels = zeros(camStrCt,1);
hCamPop = zeros(camStrCt,1);
camYops = [3 4 5 10 11 18 21];
for iterS = 1:camStrCt
    labelPos = guiPosFun([0.5,texYops(camYops(iterS))],[0.95 texH*0.8]);
    hCamLabels(iterS) = uicontrol(hControlPanels(2),'Style','text',...
        'string',[camStrCell{iterS} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',10,'BackgroundColor',[.7 .7 .7]);
    editPos = guiPosFun([texXops(8),texYops(camYops(iterS))],[texW*6.3 texH*0.75]);
    hCamPop(iterS) = uicontrol(hControlPanels(2),'Style',...
        'popupmenu','Units','normalized','HorizontalAlignment','left',...
        'fontsize',10,'string','...',...
        'position',editPos,'backgroundcolor',[.85 .85 .85]);
end
set(hCamLabels,'fontunits','normalized')
set(hCamPop,'fontunits','normalized')

%Headings
headStrCell = {'Frame','Camera','Record'};
headStrCt = numel(headStrCell);
headYops = [2 9 17];
for iterH = 1:headStrCt
    labelPos = guiPosFun([0.5,texYops(headYops(iterH))],[0.95 texH*0.8]);
    uicontrol(hControlPanels(2),'Style','text',...
        'string',headStrCell{iterH},'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',11,'BackgroundColor',[.7 .7 .8]);
end

btnStrCell = {'Display Current Settings','Apply New Settings','Calibrate'};
btnStrCt = numel(btnStrCell);
btnYops = [6 7 12];
hCamBtns = zeros(btnStrCt,1);
for iterB = 1:btnStrCt
    setBtnPos = guiPosFun([0.5,texYops(btnYops(iterB))],[0.95 texH*0.8]);
    hCamBtns(iterB) = uicontrol(hControlPanels(2),'style','pushbutton','units','normalized',...
        'string',btnStrCell{iterB},'Position',setBtnPos,...
        'fontsize',10,'fontunits','normalized');
end

%%record controls
hBstates = uibuttongroup('parent',hControlPanels(2),'position',...
    guiPosFun([.5 texYops(22)],[.95 texH]),'backgroundcolor',backC);
btnH = 1;
btnW = 1/4;
btnXinit = btnW/2;
btnXstep = btnW;
btnY = 0.5;
btnStates = zeros(4,1);
btnNames = {'Live','Stop','Trig','Dwnld'};
for iterStates = 1:4
    btnStates(iterStates) = uicontrol(hBstates,'style','togglebutton','units','normalized',...
        'string',btnNames{iterStates},'Position',...
        guiPosFun([btnXinit+(btnXstep*(iterStates-1)) btnY],[btnW btnH]*0.9),...
        'fontsize',10,'fontunits','normalized','HandleVisibility','off');
end

trigStrCell = {'frames before trigger','frames after trigger'};
trigStrCt = numel(trigStrCell);
hTrigLabels = zeros(trigStrCt,1);
hTrigEdit = zeros(trigStrCt,1);
trigYops = [19 20];
for iterG = 1:trigStrCt
    labelPos = guiPosFun([0.5,texYops(trigYops(iterG))],[0.95 texH*0.8]);
    hTrigLabels(iterG) = uicontrol(hControlPanels(2),'Style','text',...
        'string',[trigStrCell{iterG} ':'],'Units','normalized',...
        'HorizontalAlignment','left','position',labelPos,...
        'fontsize',10,'BackgroundColor',[.7 .7 .7]);
    editPos = guiPosFun([texXops(9),texYops(trigYops(iterG))],[texW*4.1 texH*0.75]);
    hTrigEdit(iterG) = uicontrol(hControlPanels(2),'Style',...
        'edit','Units','normalized','HorizontalAlignment','left',...
        'fontsize',10,'string','...',...
        'position',editPos,'backgroundcolor',[.85 .85 .85]);
end
set(hTrigLabels,'fontunits','normalized')
set(hTrigEdit,'fontunits','normalized')

%%playback controls
iconshade = 0.1;
hBplayback = uibuttongroup('parent',hControlPanels(2),'position',...
    guiPosFun([.5 texYops(26)],[.95 texH]),'backgroundcolor',backC);
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
        'fontsize',15,'fontunits','normalized',...
        'HandleVisibility','off','Enable','off');
    makePezIcon(btnHmat(iterBtn),0.7,btnIcons{iterBtn},iconshade,backC)
end
speedOps = [3,30,120];
speedOps = [fliplr(speedOps).*(-1) 0 speedOps];
set(hBplayback,'SelectedObject',[])

open1 = 80;
block1 = 90;
light1 = 20;
shadow = 225;
gap = 2;
setTempFan = 26;
gatestart = 0;
gateend = 0;
goColor = [.7 .8 .7];
stopColor = [.8 .7 .7];

%%%%%%% flyPez Panel %%%%%%%
pez_axes1 = axes('xtick',[1, 128],'ytick',[0, 127],'xticklabel',[0, 128],...
    'yticklabel',[0, 127],'xlim',[1 128],'ylim',[0 275],...
    'position',[.05 .13 .90 .3],'nextplot','add','parent',hControlPanels(1));

% Graph Threshold Values
pez_shadowth = uicontrol('Parent',hControlPanels(1),'Style','edit','Units','normalized','HandleVisibility','callback',...
                       'String',num2str(shadow),'Position',[0.3 0.06 0.08 0.04],'Callback',@hshadowth,'background',backC);
pez_shadowtxt = uicontrol('Parent',hControlPanels(1),'Style','text','Units','normalized','String', 'Set Shadow Threshold here:',...
                          'Position',[0.04 0.03 0.25 0.06],'backgroundcolor',backC);
pez_gapth = uicontrol('Parent',hControlPanels(1),'Style','edit','Units','normalized','HandleVisibility','callback',...
                       'String',gap,'Position',[0.68 0.06 0.08 0.04],'Callback',@hgapth,'background',backC); %Add correct initial value
pez_gaptxt = uicontrol('Parent',hControlPanels(1),'Style','text','Units','normalized','String','Set Gap Threshold here:',...
                       'Position',[0.45 0.03 0.21 0.06],'backgroundcolor',backC);
                   
% Random buttons
pez_release = uicontrol('Parent', hControlPanels(1),'Units','normalized','HandleVisibility','callback', ...
                      'Position',[0.63 0.88 0.14 0.05],'String','Release fly','Callback', @hReleaseButtonCallback);
pez_find=uicontrol('Parent', hControlPanels(1),'Units','normalized','HandleVisibility','callback', ...
                      'Position',[0.80 0.88 0.14 0.05],'String','Find gates','Callback', @hFindButtonCallback);
pez_auto = uicontrol('Parent', hControlPanels(1),'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                      'BackGroundColor',goColor, ...
                      'Value',0,'Position',[0.63 0.94 0.14 0.05],'String','Manual release','Callback', @hAutoButtonCallback);
pez_image = uicontrol('Parent', hControlPanels(1),'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                      'BackGroundColor',goColor, ...
                      'Value',0,'Position',[0.80 0.94 0.14 0.05],'String','Image data','Callback', @hImageButtonCallback);

% Manually Selecting Gate Mode
pez_buttons = uibuttongroup('Title','Gate Mode',...
    'Position',[0.05 0.82 .55 .08],'parent',hControlPanels(1),'backgroundcolor',backC);
gateRadStrs = {'Running','Opened','Blocked','Closed','Cleaning'};
hGateRadio = zeros(5,1);
for iterGR = 1:5
    hGateRadio(iterGR) = uicontrol('Style','Radio','Units','normalized','String',gateRadStrs{iterGR},...
        'pos',[0.0+(iterGR-1)*0.2 0.25 0.20 0.50],'parent',pez_buttons,...
        'HandleVisibility','off','backgroundcolor',backC);
end
set(pez_buttons,'SelectionChangeFcn',@selcbk);
set(pez_buttons,'SelectedObject',hGateRadio(1));

% Light Control
pez_light = uipanel('Title','Light Control','Position',[0.05 0.65 .5 .183],...
    'parent',hControlPanels(1),'backgroundcolor',backC);
pez_front = uicontrol('Parent',pez_light,'Style','text','Units','normalized','String','Front',...
                      'Position',[0 0.75 0.1 0.1],'backgroundcolor',backC);
pez_intfront = uicontrol('Parent',pez_light,'Style','slider','Units','normalized','HandleVisibility','callback',...
                         'Min',0,'Max',100,'Value',light1,'Position',[0.1 0.72 0.41 0.18],'Callback',@hintfront);
pez_lightfront = uicontrol('Parent', pez_light,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(pez_intfront,'Value')),'Position',[0.51 0.72 0.08 0.18],...
                    'Callback',@hlightfront,'background',backC);     
pez_back = uicontrol('Parent',pez_light,'Style','text','Units','normalized','String','Back',...
                     'Position',[0 0.45 0.1 0.1],'backgroundcolor',backC);
pez_intback = uicontrol('Parent', pez_light,'Style','slider','Units','normalized','HandleVisibility','callback',...
                        'Min',0,'Max',100,'Value',light1,'Position',[0.1 0.4 0.41 0.18],'Callback',@hintback);
pez_lightback = uicontrol('Parent', pez_light,'Style','edit','Units','normalized','HandleVisibility','callback',...
                          'String',num2str(get(pez_intback,'Value')),'Position',[0.51 0.4 0.08 0.18],...
                          'Callback',@hlightback,'background',backC);
pez_frontlights = uicontrol('Parent', pez_light,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Front Lights','Position',[0.6 0.7 0.28 0.23],'Callback', @hfrontLights);
pez_backlights = uicontrol('Parent',pez_light,'Units','normalized','HandleVisibility','callback',...
                           'String','Set Back Lights','Position',[0.6 0.38 0.28 0.23],'Callback', @hbackLights);

% Fan Control                
pez_fan = uipanel('Title','Fan Intensity Control',...
    'Position',[0.5 0.65 .45 .183],'parent',hControlPanels(1),'backgroundcolor',backC);
pez_fanslide = uicontrol('Parent',pez_fan,'Style','slider','Units','normalized','HandleVisibility','callback',...
                         'Min',0,'Max',100,'Value',50,'Position',[0.09 0.6 0.41 0.18],'Callback',@hfanslide);
pez_fanedit = uicontrol('Parent', pez_fan,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(pez_fanslide,'Value')),'Position',[0.5 0.6 0.09 0.18],'Callback',@hfanEdit,...
                    'background',backC);                     
pez_setfan = uicontrol('Parent', pez_fan,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Fan','Position',[0.7 0.7 0.18 0.23],'Callback', @hSetFanCallback);
pez_fanbutton = uicontrol('Parent', pez_fan,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                     'BackGroundColor',goColor,...
                     'Value',0,'Position',[0.7 0.42 0.18 0.23],'String','Fan On','Callback',@hfan);                 

% Gate Position Control
pez_panel = uipanel('Title','Gate position control',...
    'Position',[0.05 0.58 .9 .125],'parent',hControlPanels(1),'backgroundcolor',backC);

pez_text1 = uicontrol('Parent', pez_panel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','Open position','Position',[0.08 0.8 0.19 0.15],'backgroundcolor',backC);
pez_text2 = uicontrol('Parent', pez_panel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','Block position','Position',[0.48 0.8 0.19 0.15],'backgroundcolor',backC);
pez_open1slider = uicontrol('Parent', pez_panel,'Style','slider','Units','normalized','HandleVisibility','callback', ...
                      'Min',0,'Max',100,'Value',open1,'SliderStep',[.01 .1],'Position',[0.05 0.45 0.25 0.22], ...
                      'Callback', @hOpen1Callback);
pez_open1edit = uicontrol('Parent', pez_panel,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(pez_open1slider,'Value')),'Position',[0.3 0.45 0.05 0.22],...
                    'Callback',@hOpen1EditCallback,'background',backC);
pez_block1slider=uicontrol('Parent', pez_panel,'Style','slider','Units','normalized','HandleVisibility','callback', ...
                      'Min',0,'Max',100,'Value',block1,'SliderStep',[.01 .1],'Position',[0.45 0.45 0.25 0.22], ...
                      'Callback', @hBlock1Callback);
pez_block1edit = uicontrol('Parent', pez_panel,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(pez_block1slider,'Value')),'Position',[0.70 0.45 0.05 0.22],...
                    'Callback',@hBlock1EditCallback,'background',backC);
pez_setgate1 = uicontrol('Parent', pez_panel,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Gate 1','Position',[0.80 0.45 0.14 0.25],'Callback', @hSetGate1Callback);

% Gate State Indicators                  
pez_gates = uipanel('Title','Gate State',...
    'Position',[0.05 0.45 .9 .15],'parent',hControlPanels(1),'backgroundcolor',backC);
pez_gate1 = uibuttongroup('Parent', pez_gates,'Title','Gate 1','Position',[0.04 0.05 .28 .9],'backgroundcolor',backC);
set(pez_gate1,'SelectionChangeFcn',@gateselcbk);
gateStateXY = {[0.05 0.6],[0.5 0.6],[0.05 0.14],[0.5 0.14]};
gateStateStr = {'Opened','Blocked','Closed','Cleaning'};
hGateStates = zeros(4,1);
for iterGS = 1:4
hGateStates(iterGS) = uicontrol('Style','Radio','Units','normalized','String',gateStateStr{iterGS},...
    'pos',[gateStateXY{iterGS} 0.45 0.28],'parent',pez_gate1,'HandleVisibility','off','backgroundcolor',backC);
end

% Sweeper Calibration
pez_calibrate = uipanel('Title','Sweeper Control',...
    'Position',[0.46 0.45 0.25 0.15],'parent',hControlPanels(1),'backgroundcolor',backC);
pez_calbutton = uicontrol('Parent',pez_calibrate,'Style','pushbutton','Units','normalized',...
                          'String','Calibrate','Position',[0.25 0.6 0.5 0.3],'Callback',@hCalibrate);
pez_sweep = uicontrol('Parent', pez_calibrate,'Units','normalized',...
                      'Position',[0.25 0.2 0.5 0.3],'String','Sweep','Callback',@hSweepGateCallback);                      

% Fly Count Display
pez_cpanel = uipanel('Title','Fly Count',...
    'Position',[0.7 0.45 .25 .15],'parent',hControlPanels(1),'backgroundcolor',backC);
pez_count = uicontrol('Parent', pez_cpanel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','0','Position',[0.40 0.80 0.20 0.15],'backgroundcolor',backC);
pez_file = uicontrol('Parent', pez_cpanel,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
		     'BackGroundColor',goColor, ...
		     'Value',0,'Position',[0.25 0.40 0.50 0.30],'String','Recording off','Callback', @hRecordingButtonCallback);
set(hControlPanels(1),'backgroundcolor', backC);

% Temperature and Humidity Panel/Display
pez_environment = uipanel('Title','System Environment',...
    'Position',[0.05 0.90 0.3 0.08],'parent',hControlPanels(1),'backgroundcolor',backC);
pez_temp = uicontrol('Parent',pez_environment,'Style','edit','Units','normalized',...
                     'Position',[0.1 0.025 .3 0.6],'HandleVisibility','off','FontSize',16);
pez_tempedit = uicontrol('Parent',pez_environment,'Style','text','Units','normalized',...
                         'Position',[0 0.7 0.5 0.3],'String','Temperature','backgroundcolor',backC);
pez_humidity = uicontrol('Parent',pez_environment,'Style','edit','Units','normalized',...
                     'Position',[0.55 0.025 .3 0.6],'HandleVisibility','off','FontSize',16);
pez_humidityedit = uicontrol('Parent',pez_environment,'Style','text','Units','normalized',...
                         'Position',[0.45 0.7 0.5 0.3],'String','Humidity, %','backgroundcolor',backC);

% Set Temperature Trigger of Fan
pez_temptrigger = uicontrol('Style','text','Units','normalized',...
    'Position',[0.35 0.94 0.2 0.04],'String','Fan Temperature Trigger, C',...
    'parent',hControlPanels(1),'backgroundcolor',backC);
pez_temptriggeredit = uicontrol('Style','edit','Units','normalized','Position',[0.4 0.90 0.1 0.04],...
    'HandleVisibility','on','String','26','Callback',@setTemperature,'background',backC,...
    'FontSize',16,'parent',hControlPanels(1),'backgroundcolor',backC);


if Debug == 0 || Debug == 2
% Initializing and opening camera
PDC = runSetPDCvalues;
IPcell = strsplit(cameraIP,'.');
Detect_auto1_hex = dec2hex(str2double(IPcell{1}));
Detect_auto2_hex = dec2hex(str2double(IPcell{2}));
Detect_auto3_hex = strcat('0',dec2hex(str2double(IPcell{3})));
Detect_auto4_hex = strcat('0',dec2hex(str2double(IPcell{4})));
Detect_auto_hex = strcat(Detect_auto1_hex,Detect_auto2_hex,Detect_auto3_hex,Detect_auto4_hex);
IPList = hex2dec(Detect_auto_hex);
nInterfaceCode = uint32(2);
nDetectNo = uint32(IPList);
nDetectNum = uint32(1);
nDetectParam = uint32(0);
[nRet,nErrorCode] = PDC_Init;
if nRet == PDC.FAILED, disp(['Init Error ' int2str(nErrorCode)]), end
[nRet,nDetectNumInfo,nErrorCode] = PDC_DetectDevice( nInterfaceCode, nDetectNo, nDetectNum, nDetectParam );
if nRet == PDC.FAILED, disp(['DetectDevice Error ' int2str(nErrorCode)]), end
if nDetectNumInfo.m_nDeviceNum == 0
    disp('nDetectNumInfo.m_nDeviceNum Error : nDetectNumInfo.m_nDeviceNum = 0');
    return
end
[nRet,nDeviceNo,nErrorCode] = PDC_OpenDevice(nDetectNumInfo.m_DetectInfo);
if nRet == PDC.FAILED, disp(['OpenDevice Error ' int2str(nErrorCode)]), end
if nRet == PDC.FAILED
    [nRet,nErrorCode] = PDC_CloseDevice(nDeviceNo);
    [nRet,nDeviceNo,nErrorCode] = PDC_OpenDevice( nDetectNumInfo.m_DetectInfo );
    if nRet == PDC.FAILED
        disp(['PDC_OpenDevice Error : ' num2str(nErrorCode)]);
        msgbox('Camera was not opened','No camera opened','Warn');
        return
    end
end

% confirm zero children
[nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
[nRet,nMaxChildCount,nErrorCode] = PDC_GetMaxChildDeviceCount(nDeviceNo);
[nRet,nChildSize,nChildList,nErrorCode] = PDC_GetExistChildDeviceList(nDeviceNo);
nChildNo = nChildList(1);

% get device properties
[nRet,nDeviceName,nErrorCode] = PDC_GetDeviceName(nDeviceNo,0 );
[nRet,nFrames,nBlock,nErrorCode] = PDC_GetMaxFrames(nDeviceNo,nChildNo);
[nRet,nRate,nErrorCode] = PDC_GetRecordRate(nDeviceNo,nChildNo);
[nRet,nMode,nErrorCode] = PDC_GetColorType(nDeviceNo,nChildNo);
[nRet,nWidthMax,nHeightMax,nErrorCode] = PDC_GetMaxResolution(nDeviceNo,nChildNo);
[nRet,nWidth,nHeight,nErrorCode] = PDC_GetResolution(nDeviceNo,nChildNo);
[nRet,nFps,nErrorCode] = PDC_GetShutterSpeedFps(nDeviceNo,nChildNo);
[nRet,nTrgMode,nAFrames,nRFrames,nRCount,nErrorCode] = PDC_GetTriggerMode(nDeviceNo);
[nRet,n8BitSel,nBayer,nInterleave,nErrorCode] = PDC_GetTransferOption(nDeviceNo,nChildNo);
[nRet,nWidthStep,nHeightStep,nXPosStep,nYPosStep,nWidthMin,nHeightMin,nFreePos,nErrorCode] = PDC_GetVariableRestriction(nDeviceNo);

% populate lists
[nRet,nRecordRateSize,nRecordRateList,nErrorCode] = PDC_GetRecordRateList(nDeviceNo,nChildNo);
[nRet,nResolutionSize,nResolutionList,nErrorCode] = PDC_GetResolutionList(nDeviceNo,nChildNo);
[nRet,nShutterSize,nShutterList,nErrorCode] = PDC_GetShutterSpeedFpsList(nDeviceNo,nChildNo);
[nRet,nTriggerModeSize,nTriggerModeList,nErrorCode] = PDC_GetTriggerModeList(nDeviceNo);

% set camera states
if nStatus ~= PDC.STATUS_LIVE
    [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
    if nRet == PDC.FAILED, disp(['SetStatus Error ' int2str(nErrorCode)]), end
end
[nRet,nErrorCode] = PDC_SetRecordingType(nDeviceNo,2);
[nRet,nErrorCode] = PDC_SetDownloadMode(nDeviceNo,PDC.DOWNLOAD_MODE_PLAYBACK_OFF);
[nRet,nErrorCode] = PDC_SetAutoPlay(nDeviceNo,PDC.AUTOPLAY_OFF);
nBitDepth = 8;
nChannel = 20;
nXPos = nWidthMax/2-nWidth/2;
nYPos = nHeightMax/2-nHeight/2;
[nRet,nErrorCode] = PDC_SetVariableChannelInfo(nDeviceNo,nChannel,nRate,nWidth,nHeight,nXPos,nYPos);
[nRet,nErrorCode] = PDC_SetVariableChannel(nDeviceNo,nChildNo,nChannel);

disp('Camera is ready')

% frame %
listRecord = arrayfun(@(x) cellstr(int2str(x)),(nRecordRateList(nRecordRateList > 0)));
listRecord = cellfun(@(x) cat(2,x,' fps'),listRecord,'UniformOutput',false);
set(hCamPop(3),'String',listRecord)
listHeightNum = (nHeightMin:nHeightStep:nHeightMax);
listHeightStr = cellstr(int2str(listHeightNum'));
listWidthNum = (nWidthMin:nWidthStep:nWidthMax);
listWidthStr = cellstr(int2str(listWidthNum'));
set(hCamPop(1),'String',listWidthStr)
set(hCamPop(2),'String',listHeightStr)

% camera %
set(hCamPop(5),'String',{'0','1','2','3','4'})
listShutter = arrayfun(@(x) cellstr(int2str(x)),(nShutterList(nShutterList > 0)));
listShutter = cellfun(@(x) cat(2,'1/',x,' sec'),listShutter,'UniformOutput',false);
set(hCamPop(4),'String',listShutter)
listTrigger = {'START','CENTER','END','RANDOM','MANUAL',...
    'RANDOM_RESET','RANDOM_CENTER','RANDOM_MANUAL',...
    'TWOSTAGE','TWOSTAGE_HALF','TWOSTAGE_QUARTER',...
    'TWOSTAGE_ONEEIGHTH','RESET'};
set(hCamPop(6),'String',listTrigger)
% [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nMode,nBayer,nWidth,nHeight);
frmData = uint8(zeros(nHeight,nWidth));
hImA = image('Parent',hAxesA,'CData',frmData);

set(hFigA,'CloseRequestFcn',@myCloseFun)
set(hCamBtns(1),'callback',@dispCurrentSettings)
set(hCamBtns(2),'callback',@applyNewSettings)
set(hCamBtns(3),'callback',@calibrateCallback)
set(hCamPop(4),'callback',@shutterSpeedCallback)
set(hCamPop(5),'callback',@bitshiftCallback)
set(hBstates,'SelectionChangeFcn',@stateCallback)

tCam = timer('TimerFcn',@camTimerFun,'ExecutionMode','fixedRate',...
    'Period',round((1/30)*100)/100);
end
% if Debug == 0 || Debug == 1
% Setup the serial
delete(instrfindall)

s = serial('COM4');
set(s,'baudrate',250000,'inputbuffersize',100*(128+3),...
    'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
    @receiveData,'Terminator','CR/LF','StopBits',2);
fopen(s);
% end
if Debug == 0 || Debug == 2
camStartupFun
end
    function camStartupFun
        dispCurrentSettings([],[])
        applyNewSettings([],[])
        set(hBstates,'SelectedObject',btnStates(1))
        start(tCam)
    end

    function dispCurrentSettings(~,~)
        set(hCamPop(1),'Value',find(nWidth == listWidthNum))
        set(hCamPop(2),'Value',find(nHeight == listHeightNum))
        set(hCamPop(3),'Value',find(nRate == nRecordRateList))
    end
    function applyNewSettings(~,~)
        nWidth = listWidthNum(get(hCamPop(1),'Value'));
        nHeight = listHeightNum(get(hCamPop(2),'Value'));
        nRate = nRecordRateList(get(hCamPop(3),'Value'));
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
        set(hCamPop(4),'String',listShutter,'Value',1);
        boxRatio = double([nWidth nHeight])./double(max(nWidth,nHeight));
        boxRatio(3) = 1;
        set(hAxesA,'xlim',[1 nWidth],'ylim',[1 nHeight],...
            'PlotBoxAspectRatio',boxRatio)
    end
    function shutterSpeedCallback(source,~)
        nFps = nShutterList(get(source,'Value'));
        [nRet,nErrorCode] = PDC_SetShutterSpeedFps(nDeviceNo,nChildNo,nFps);
    end
    function bitshiftCallback(source, ~)
        shiftOps = fliplr(0:4);
        sourceVal = get(source,'Value');
        n8BitSel = shiftOps(sourceVal);
        [nRet, nErrorCode] = PDC_SetTransferOption(nDeviceNo,nChildNo,n8BitSel,nBayer,nInterleave);
    end
%calibrate camera
    function calibrateCallback(~,~)
        [nRet,nErrorCode] = PDC_SetShadingMode(nDeviceNo,nChildNo,2);
    end
    function camTimerFun(~,~)
        dispLiveImage
    end
    function dispLiveImage
        [nRet,nBuf,nErrorCode] = PDC_GetLiveImageData(nDeviceNo,nChildNo,nBitDepth,nMode,nBayer,nWidth,nHeight);
        frmData = flipud(nBuf');
        set(hImA,'CData',frmData)
        drawnow
    end
    function stateCallback(~,eventdata)
        butValN = eventdata.NewValue;
        caseVal = find(butValN == btnStates);
        switch caseVal
            case 1
                start(tCam)
            case 2
                stop(tCam)
            case 3
            case 4
        end
    end


%%%%%%% flyPez Control Functions %%%%%%%
% Graph Thresholds

    function hshadowth(hObject, ~) %Add code to send data to the MCU
        [entry,status] = str2num(get(hObject,'string'));
        shadow = round(entry); %Set limitations 0 - 275        
        fwrite(s,sprintf('%s %u\r','E',shadow));
    end

    function hgapth(hObject,~) %Add code to send data to the MCU
        [entry,status] = str2num(get(hObject,'string'));
        gap = round(entry);        
        fwrite(s,sprintf('%s %u\r','K',gap));        
    end

% Find Gates

    function hFindButtonCallback(~, ~)   
        if (get(pez_buttons,'SelectedObject') ~= hGateRadio(1))
            set(pez_buttons,'SelectedObject', hGateRadio(1));
        end
        fwrite(s,sprintf('%s\r','F'));                %Find Gates
    end


% Fan Control
    function hfanslide(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(pez_fanedit,'String',num2str(slider_value));
    end

    function hfanEdit(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(pez_fanslide,'Value',value);
            else
                set(hObject,'String',num2str(get(pez_fanslide,'Value')));
            end
        else
            set(hObject,'String',num2str(get(pez_fanslide,'Value')));
        end
    end

    function hSetFanCallback(~, ~)
        fwrite(s,sprintf('%s %u\r','U',get(pez_fanslide,'Value')));
    end

    function hfan(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - turn on fan
            fwrite(s,sprintf('%s\r','Y'));
            set(hObject,'BackgroundColor','red');
            set(hObject,'String','Fan Off');
        elseif button_state == get(hObject,'Min')
            %Toggle button is not pressed - turn off fan
            fwrite(s,sprintf('%s\r','P'));
            set(hObject,'BackgroundColor','green');
            set(hObject,'String','Fan On');
        end
    end

% Fan Temperature Trigger
    function setTemperature(hObject,~)
        entry = str2double(get(hObject,'string'));
        setTempFan = round(entry*10)/10;
        fwrite(s,sprintf('%s %u\r','Q',setTempFan));
    end

% Light Control

    function hintfront(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(pez_lightfront,'String',num2str(slider_value));
    end
    
    function hlightfront(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(pez_intfront,'Value',value);
            else
                set(hObject,'String',num2str(get(pez_intfront,'Value')));
            end
        else
            set(hObject,'String',num2str(get(pez_intfront,'Value')));
        end
    end
    function hintback(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(pez_lightback,'String',num2str(slider_value));
    end

    function hlightback(hObject, ~)
        entry = str2double(get(hObject,'string'));
%         if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(pez_intback,'Value',value);
            else
                set(hObject,'String',num2str(get(pez_intback,'Value')));
            end
%         else
%             set(hObject,'String',num2str(get(pez_intback,'Value')));
%         end
    end

    %----------------------------------------------------------------------

    function hfrontLights(~, ~)
        fwrite(s,sprintf('%s %u\r','I',get(pez_intfront,'Value')));
    end

    %----------------------------------------------------------------------
    
    function hbackLights(~, ~)
        fwrite(s,sprintf('%s %u\r','L',get(pez_intback,'Value')));
    end

% Sweeper Motor Functions
    function hCalibrate(~,~)
        fwrite(s,sprintf('%s\r','J'));%holds sweeper over prism
    end
    function hSweepGateCallback(~,~)%sweeps
        fwrite(s,sprintf('%s\r','S'));
    end

% Fly Release Function

    function hReleaseButtonCallback(~, ~)
        if (get(pez_buttons,'SelectedObject') ~= hGateRadio(1))
            set(pez_buttons,'SelectedObject', hGateRadio(1))
        end
	fwrite(s,sprintf('%s\r','R'));                %Prepares firmware for character command
    end

% Image Transfer Function

    function hImageButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - send linear array data
            fwrite(s,sprintf('%s\r','V'));
            set(hObject,'BackgroundColor',stopColor);
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed - stop sending linear array data
            fwrite(s,sprintf('%s\r','N'));
            set(hObject,'BackgroundColor',goColor);
        end
    end

% Auto Function
    
    function hAutoButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - turn on auto release
            fwrite(s,sprintf('%s\r','A'));
            set(hObject,'BackgroundColor',stopColor);
            set(hObject,'String','Auto release');
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed - turn off auto release
            fwrite(s,sprintf('%s\r','M'));
            set(hObject,'BackgroundColor',goColor);
            set(hObject,'String','Manual release');
        end
    end

% Set Gate Position Functions

    function selcbk(~,eventdata)
        if (eventdata.NewValue == hGateRadio(4))
            fwrite(s,sprintf('%s\r','C'));            %Closes Gate1
        elseif (eventdata.NewValue == hGateRadio(3))
            fwrite(s,sprintf('%s\r','B'));            %Blocks Gate1
        elseif (eventdata.NewValue == hGateRadio(2))
            fwrite(s,sprintf('%s\r','O'));            %Opens Gate1
        elseif (eventdata.NewValue == hGateRadio(5))
            fwrite(s,sprintf('%s\r','H'));            %Cleaning Gate1
        else
            fwrite(s,sprintf('%s\r','G'));            %Running
        end
    end
    
    function hOpen1Callback(hObject, ~, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(pez_open1edit,'String',num2str(slider_value));
    end

    %----------------------------------------------------------------------

    function hOpen1EditCallback(hObject, ~, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(pez_open1slider,'Value',value);
            else
                set(hObject,'String',num2str(get(pez_open1slider,'Value')));
            end
        else
            set(hObject,'String',num2str(get(pez_open1slider,'Value')));
        end
    end

    %----------------------------------------------------------------------

    function hBlock1Callback(hObject, ~, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(pez_block1edit,'String',num2str(slider_value));
    end
    function hBlock1EditCallback(hObject, ~, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(pez_block1slider,'Value',value);
            else
                set(hObject,'String',num2str(get(pez_block1slider,'Value')));
            end
        else
            set(hObject,'String',num2str(get(pez_block1slider,'Value')));
        end
    end

    %----------------------------------------------------------------------

    % Set open and blocked position with slider bar.

    function hSetGate1Callback(~, ~)   
        fwrite(s,sprintf('%s %u %u\r','D',get(pez_open1slider,'Value'),get(pez_block1slider,'Value')));
    end

    %----------------------------------------------------------------------

    function gateselcbk(source,eventdata)
        if (eventdata.NewValue ~= eventdata.OldValue)
            set(source,'SelectedObject',eventdata.OldValue);
        end
    end

% Fly Count Recording Function
    
    function hRecordingButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed-take appropriate action
            fwrite(s,sprintf('%s\r','T'));
            set(hObject,'BackgroundColor','red');
            set(hObject,'String','Recording on');
            fileN = sprintf('%s_%s.%s','flycount',datestr(now,30),'txt');
            set(pez_count,'String','0');
            pez_logfileID = fopen(fileN,'w');
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed-take appropriate action
            %fwrite(s,sprintf('%s\r','M'));
            set(hObject,'BackgroundColor','green');
            set(hObject,'String','Recording off');
            fclose(pez_logfileID);
        end
    end

% Communication to MCU

    function receiveData(obj,evnt)
        token = fscanf(s,'%s',4);
        %display(token);
        if (strcmp('$FR,', token) == true)
            name = fscanf(s);
%             set(pez_fig,'name',name);
%             set(pez_fig,'Visible','on');
        elseif(strcmp('$GS,', token) == true)
            gatepos = fscanf(s);
            [open1,block1] = strread(gatepos,'%u%u','delimiter',',');
            set(pez_open1slider,'Value',open1);
            set(pez_block1slider,'Value',block1);
            set(pez_open1edit,'String',num2str(open1));
            set(pez_block1edit,'String',num2str(block1));
        elseif(strcmp('$LS,',token) == true) %Add this to MCU code
            light1 = fscanf(s);
            set(pez_intslide,'Value',light1);
            set(pez_lightedit,'String',num2str(light1));
        elseif(strcmp('$GF,',token) == true)
            gateFind = fscanf(s);
            [gatestart, gateend, gap] = strread(gateFind,'%u%u%u','delimiter',',');


            disp(gatestart)
            disp(gateend)
            disp(gap)
        elseif(strcmp('$GE,',token) == true)
            gatestate = fscanf(s);
            [gate, state] = strread(gatestate,'%u%s','delimiter',',');
            if (gate == 1)
                if (strcmp('O', state) == true)
                    set(pez_gate1,'SelectedObject',hGateStates(1));
                elseif (strcmp('B', state) == true)
                    set(pez_gate1,'SelectedObject',hGateStates(2));
                elseif (strcmp('H', state) == true)
                    set(pez_gate1,'SelectedObject',hGateStates(3));
                else
                    set(pez_gate1,'SelectedObject',hGateStates(4));
                end
            end
        elseif(strcmp('$FC,',token) == true)
            inpline = fscanf(s);
            [cnt,sec] = strread(inpline,'%u%u','delimiter',',');
            set(pez_count,'String',num2str(cnt));
            fprintf(pez_logfileID,'%s %s\r\n',num2str(cnt),num2str(sec));
        elseif(strcmp('$ID,', token) == true)
            data = fread(s,128);
            junk = fscanf(s);
            cla;
            pez_hline1=plot(0:127,2*data(1:128),'linewidth',2,'color','k','parent',pez_axes1);
%             pez_axes1=get(pez_hline1,'parent');
            pez_hline4=plot(0:127,repmat(shadow,1,128),'linewidth',1,'color','b','parent',pez_axes1);
%             pez_axes1=get(pez_hline4,'parent');
            plot(repmat(gatestart,1,270),0:269,'linewidth',1,'color','r');
            plot(repmat(gateend,1,270),0:269,'linewidth',1,'color','r');
            plot(repmat(gateend+gap,1,270),0:269,'linewidth',1,'color','k');
%             pez_hline2 = plot(repmat(94,1,128),0:127,'linewidth',1,'color','r');
%             pez_axes1=get(pez_hline2,'parent');
%              plot(x,y);
%              plot(x2,y); 
        elseif(strcmp('$TD,',token) == true)
            input = fscanf(s);           
            [h,t] = strread(input,'%u%u','delimiter',',');
            t = t/10;
            h = h/10;
            set(pez_humidity,'String',num2str(h));
            set(pez_temp,'String',num2str(t));
        end
    end


% close and clean up
    function myCloseFun(~,~)
    fclose('all');
        if strcmp(tCam.Running,'on'),stop(tCam),end
        delete(timerfindall)
        delete(hFigA)
        delete(s);
        [nRet,nErrorCode] = PDC_CloseDevice(nDeviceNo);
        if nRet == PDC.FAILED
            disp(['CloseDevice Error ' int2str(nErrorCode)])
        end
        clear all
        close all
    end
end

