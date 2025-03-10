function runPezMasterGUI

%Main GUI uicontrol objects
guiPosFun = @(c,s) [c(1)-s(1)/2 c(2)-s(2)/2 s(1) s(2)];%input center(x,y) and size(x,y)

% in multi screen setup, this determines which screen to be used
screen2use = 2;
% portion of the screen to cover
screen2cvr = 0.9;
monPos = get(0,'MonitorPositions');
scrnPos = monPos(screen2use,:);

%Figure/handle
if screen2use > 1
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+[scrnPos(1),(monPos(1,4)-scrnPos(4)-scrnPos(2))],...
        (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
else
    FigPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
        (scrnPos(3:4)-scrnPos(1:2)).*screen2cvr]);
end
GUIhfig = figure('NumberTitle','off','Name','photron SDK WRW','menubar','none',...
    'units','pix','Color',[.9 .9 .9],'pos',FigPos,'colormap',gray(256));

%Logo
GUIaxo = axes('Units','pix', 'Position', [0 0 82 20]);
logo = imread('logo.bmp');
image(logo,'Parent',GUIaxo,'HitTest','off');
axis off

tabC = [.73 .47];
tabS = [.4 .9];
%Camera panel
GUIcamera_panel = uipanel('Position',guiPosFun(tabC,tabS),'Visible','On','Units','normalized');
%Control panel
GUIcontrol_panel = uipanel('Position',guiPosFun(tabC,tabS),'Visible','Off','Units','normalized');
%Meta panel
GUImeta_panel = uipanel('Position',guiPosFun(tabC,tabS),'Visible','Off','Units','normalized');

% Toggle buttons, pseudo tabs
tabPosA = get(GUIcamera_panel,'Position');
tabPosB = tabPosA(2)+tabPosA(4);
tabPosD = tabPosA(1)+tabPosA(3);
tabPosA(2:4) = [];
tabPosC = 0.07;
GUIcamera_toggle_button = uicontrol(GUIhfig, 'Style','togglebutton','String','Camera','Value',1,...
    'Units','normalized','Position',[tabPosA tabPosB tabPosC .06]);
GUIctrl_toggle_button = uicontrol(GUIhfig, 'Style','togglebutton','String','Control','Value',0,...
    'Units','normalized','Position',[tabPosA+tabPosC tabPosB tabPosC .06]);
GUImeta_toggle_button = uicontrol(GUIhfig, 'Style','togglebutton','String','Meta Data','Value',0,...
    'Units','normalized','Position',[tabPosA+tabPosC*2 tabPosB tabPosC .06]);
% Close button %
GUIclose_button = uicontrol(GUIhfig, 'String','Close','Units','normalized',...
    'Position', [tabPosD-tabPosC tabPosB tabPosC .06]);


%%%% Setup panel
GUIsetup_panel = uipanel('Parent',GUIcamera_panel,'Title','Setup',...
    'Position',[.03 .54 .95 .25],...
    'FontName','Century Schoolbook','FontSize',11,'FontWeight','bold');

% record rate %
GUIrecordrate_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Record Rate','Units','normalized', 'Position',[.03 .82 .2 .1],'HorizontalAlignment','left');
MyRecord = arrayfun(@(x) cellstr(int2str(x)),(CAM.nRecordRateList(CAM.nRecordRateList > 0)));
MyRecord = cellfun(@(x) cat(2,x,' fps'),MyRecord,'UniformOutput',false);
GUIrecordrate_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',MyRecord,'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.22 .76 .22 .2]);

% resolution %
CAM.nResolutionList = CAM.nResolutionList(CAM.nResolutionList>0);
MyResolutionA = arrayfun(@(x) cellstr(int2str(x)),bitshift(CAM.nResolutionList,-16));
MyResolutionB = arrayfun(@(x) bitand(hex2dec('FFFF'),x),CAM.nResolutionList);
MyResolutionB = arrayfun(@(x) cellstr(int2str(x)),MyResolutionB);
MyResolution = cellfun(@(x,y) cat(2,x,' x ',y),MyResolutionA,MyResolutionB,'UniformOutput',false);

CAM.heightList = (CAM.nHeightMin:CAM.nHeightStep:CAM.nHeightMax);
MyHeightOps = cellstr(int2str(CAM.heightList'));
CAM.widthList = (CAM.nWidthMin:CAM.nWidthStep:CAM.nWidthMax);
MyWidthOps = cellstr(int2str(CAM.widthList'));

GUIresolutionW_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Frame Width','Units','normalized', 'Position',[.03 .57 .16 .1],'HorizontalAlignment','left');
GUIresolutionW_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',MyWidthOps,'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.22 .51 .22 .2]);
GUIresolutionH_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Frame Height','Units','normalized', 'Position',[.53 .57 .16 .1],'HorizontalAlignment','left');
GUIresolutionH_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',MyHeightOps,'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.75 .51 .22 .2]);

% bit shift %
GUIbitshift_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Bitshift','Units','normalized', 'Position',[.03 .32 .16 .1],'HorizontalAlignment','left');
GUIbitshift_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',{'4','3','2','1','0'},...
    'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.22 .26 .22 .2]);

% shutter speed %
GUIshutter_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Shutter Speed','Units','normalized', 'Position',[.53 .82 .2 .1],'HorizontalAlignment','left');
MyShutter = arrayfun(@(x) cellstr(int2str(x)),(CAM.nShutterList(CAM.nShutterList > 0)));
MyShutter = cellfun(@(x) cat(2,'1/',x,' sec'),MyShutter,'UniformOutput',false);
GUIshutter_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',MyShutter,'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.75 .76 .22 .2]);

% trigger %
GUItrigger_txt = uicontrol(GUIsetup_panel,'Style','text',...
    'String','Trigger Mode','Units','normalized', 'Position',[.03 .07 .2 .1],'HorizontalAlignment','left');

MyTrigger = {'START','CENTER','END','RANDOM','MANUAL',...
    'RANDOM_RESET','RANDOM_CENTER','RANDOM_MANUAL',...
    'TWOSTAGE','TWOSTAGE_HALF','TWOSTAGE_QUARTER',...
    'TWOSTAGE_ONEEIGHTH','RESET'};
GUItrigger_pop = uicontrol(GUIsetup_panel,'Style','popupmenu',...
    'String',MyTrigger,'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.22 .01 .22 .2]);

% trigger parameters %
GUIstart_frame_text = uicontrol(GUIsetup_panel,'Style','text',...
    'Units','normalized','String','Start frame', 'Position',[.53 .2 .2 .14]);
GUIend_frame_text = uicontrol(GUIsetup_panel,'Style','text',...
    'Units','normalized','String','End frame', 'Position',[.75 .2 .2 .14]);

GUIstart_frame_edit = uicontrol(GUIsetup_panel,'Style','edit',...
    'BackgroundColor',[1 1 1],'Units','normalized','String','0', 'Position',[.53 .07 .2 .14]);
GUIend_frame_edit = uicontrol(GUIsetup_panel,'Style','edit',...
    'BackgroundColor',[1 1 1],'Units','normalized','String', int2str(CAM.nAFrames), 'Position',[.75 .07 .2 .14]);

%Save panel
GUIsave_panel = uipanel('Parent',GUIcamera_panel,...
    'Title','Save Panel','Position',[.03 .2 .95 .2],...
    'FontName','Century Schoolbook',...
    'FontSize',11,'FontWeight','bold');
GUIsave_txt = uicontrol(GUIsave_panel,'Style','text',...
    'String','Save path','Units','normalized', 'Position',[.01 .8 .15 .15]);%test string for path
path_txt_test = 'Please select a folder';

GUIpath_edit = uicontrol(GUIsave_panel,'Style','edit',...
    'String',path_txt_test ,'Units','normalized', 'Position',[.03 .6 .82 .18],...
    'Enable','off','BackgroundColor',[1 1 1],'HorizontalAlignment','left');
GUIpath_button = uicontrol(GUIsave_panel,'Style','pushbutton',...
    'String','...' ,'Units','normalized', 'Position',[.88 .6 .08 .17]);
GUIfilename_txt = uicontrol(GUIsave_panel,'Style','text',...
    'String','Filename' ,'Units','normalized', 'Position',[.01 .36 .14 .15]);
GUIfilename_edit = uicontrol(GUIsave_panel,'Style','edit',...
    'String','Data' ,'Units','normalized', 'Position',[.03 .15 .75 .18],'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
GUIformat_pop = uicontrol(GUIsave_panel,'Style','popupmenu',...
    'String',{'AVI','JPEG','BMP'},...
    'BackgroundColor',[1 1 1],'Value',1,'Units','normalized', 'Position',[.83 .15 .12 .18]);


%Experiment display panel
GUIcamera_display_panel = uipanel('Position',guiPosFun([.27 .5],[.4 .98]),'BackgroundColor','k');
GUIhaxA = axes('Parent',GUIcamera_display_panel,'Position',guiPosFun([.5 .5],[.9 .9]),...
    'color','k','tickdir','in','nextplot','replacechildren',...
    'xticklabel',[],'yticklabel',[]);
[ nRet, nBuf, nErrorCode ] = PDC_GetLiveImageData( CAM.nDeviceNo, CAM.nChildNo, CAM.nBitDepth, CAM.nMode, CAM.nBayer, CAM.nWidth, CAM.nHeight );
frmData = flipud(nBuf');
frmData = imadjust(frmData);
GUIhImA = image('Parent',GUIhaxA,'CData',frmData);
GUIboxRatio = double([CAM.nWidth CAM.nHeight])./double(max(CAM.nWidth,CAM.nHeight));
GUIboxRatio(3) = 1;
set(GUIhaxA,'xlim',[1 CAM.nWidth],'ylim',[1 CAM.nHeight],...
    'PlotBoxAspectRatio',GUIboxRatio)


%%%%% Control panel setup
GUIcalibrate_button = uicontrol(GUIcontrol_panel,'Style','pushbutton',...
    'String','Calibrate','Units','normalized', 'Position',[.58 .12 .35 .25],'HorizontalAlignment','left');
GUIdisplay_panel = uipanel('Parent',GUIcontrol_panel,'Title','Display',...
    'Position',[.03 .65 .5 .08],...
    'FontName','Century Schoolbook','FontSize',11,'FontWeight','bold');
GUIlivestop_radio = uicontrol(GUIdisplay_panel,'Style','radiobutton',...
    'String','Live Stop',...
    'Value',0,'Units','normalized','Position',[.03 .3 .3 .5]);
GUIlive_radio = uicontrol(GUIdisplay_panel,'Style','radiobutton',...
    'String','Live',...
    'Value',1,'Units','normalized','Position',[.4 .3 .3 .5]);
GUImemory_radio = uicontrol(GUIdisplay_panel,'Style','radiobutton',...
    'String','Memory',...
    'Value',0,'Units','normalized','Position',[.65 .3 .3 .5]);

GUIrecord_button = uicontrol(GUIcontrol_panel,'Style','pushbutton',...
    'String','Record','Units','normalized', 'Position',[0.57 .65 .2 .08]);
GUIendless_button = uicontrol(GUIcontrol_panel,'Style','pushbutton',...
    'String','Endless Rec','Visible','Off','Units','normalized', 'Position',[0.57 .65 .2 .08]);
GUIwaiting_button = uicontrol(GUIcontrol_panel,'Style','pushbutton',...
    'String','Waiting TRG','Visible','Off','Units','normalized', 'Position',[0.57 .65 .2 .08]);
GUIrecording_toggle_button = uicontrol(GUIcontrol_panel,'Style','togglebutton',...
    'String','Recording','Visible','Off','Units','normalized', 'Position',[0.57 .65 .2 .08]);
GUIrecord_stop_button = uicontrol(GUIcontrol_panel,'Style','pushbutton',...
    'String','Rec Stop','Units','normalized', 'Position',[0.78 .65 .2 .08]);


% set values for pop controls
set(GUIrecordrate_pop,'Value',find(CAM.nRecordRateList == CAM.nRate));
set(GUIshutter_pop,'Value',find(CAM.nShutterList == CAM.nFps ));
set(GUIresolutionW_pop,'Value',find(CAM.widthList == CAM.nWidth));
set(GUIresolutionH_pop,'Value',find(CAM.heightList == CAM.nHeight));
set(GUIbitshift_pop,'Value',CAM.n8BitSel+1);
set(GUItrigger_pop,'Value',find(CAM.nTriggerModeList == CAM.nTrgMode));

% initialize callbacks
set(GUIlive_radio,'Callback',{@live_radio_Callback});
set(GUIlivestop_radio,'Callback',{@livestop_radio_Callback});
set(GUImemory_radio,'Callback',{@memory_radio_Callback});
set(GUIrecord_button,'Callback',{@record_button_Callback});
set(GUIwaiting_button,'Callback',{@waiting_button_Callback});
set(GUIendless_button,'Callback',{@endless_button_Callback});
set(GUIrecord_stop_button,'Callback',{@record_stop_button_Callback});
% set(GUIplay_toggle_button,'Callback',{@play_toggle_button_Callback});
set(GUIpath_button,'Callback',{@path_button_Callback});
% set(GUIstop_button,'Callback',{@stop_button_Callback});
set(GUIstart_frame_edit,'Callback',{@start_frame_edit_Callback});
% set(GUIcurrent_frame_edit,'Callback',{@current_frame_edit_Callback});
set(GUIend_frame_edit,'Callback',{@end_frame_edit_Callback});
% set(GUIframe_slider,'Callback',{@frame_slider_Callback});
set(GUIcamera_toggle_button,'Callback',{@camera_toggle_button_Callback});
set(GUIctrl_toggle_button,'Callback',{@ctrl_toggle_button_Callback});
set(GUImeta_toggle_button,'Callback',{@meta_toggle_button_Callback});
% set(GUIsave_button,'Callback',{@save_button_Callback});
set(GUIclose_button,'Callback',{@close_button_Callback});
set(GUIhfig,'CloseRequestFcn',{@close_button_Callback});
set(GUIrecordrate_pop,'Callback',{@recordrate_pop_Callback});
set(GUIshutter_pop,'Callback',@shutter_pop_Callback);
set(GUItrigger_pop,'Callback',{@trigger_pop_Callback});
set(GUIresolutionW_pop,'Callback',{@resolutionW_pop_Callback});
set(GUIresolutionH_pop,'Callback',{@resolutionH_pop_Callback});
set(GUIbitshift_pop,'Callback',{@bitshift_pop_Callback});
set(GUIcalibrate_button,'Callback',{@calibrate_button_Callback});
set(GUIhfig,'ResizeFcn',{@resizeGUI});

% initialize values

% [nRet, CAM.nChannel, nErrorCode] = PDC_GetVariableChannel(CAM.nDeviceNo, CAM.nChildNo);
% if CAM.nChannel == 0
%     CAM.nChannel = 1;
% end
% [nRet, CAM.VarRate, CAM.VarWidth, CAM.VarHeight, CAM.VarXPos, CAM.VarYPos, nErrorCode] = PDC_GetVariableChannelInfo(CAM.nDeviceNo, CAM.nChannel)
% [nRet, nErrorCode] = PDC_SetVariableChannel(CAM.nDeviceNo, CAM.nChildNo, nChannel);

% [nRet, nErrorCode] = PDC_SetRecReady(CAM.nDeviceNo)
% [nRet, nErrorCode] = PDC_SetEndless(CAM.nDeviceNo)
