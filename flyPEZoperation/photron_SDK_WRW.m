%MAIN GUI

function photron_SDK_WRW
% clc
addpath('C:\Users\cardlab\Desktop\Photron_MATLAB\WRW_Module\Sample_R2013a_64bit_withDLLs')

%PDC Input settings
run_set_PDC_values

%open camera
run_open_camera

%define uicontrol objects
run_uicontrol_WRW

%callback settings
run_initialize_callback

%Handles settings
handles = guihandles(GUI.hfig);
handles.pdc = PDC;
handles.camera = CAM;
handles.gui = GUI;
guidata(GUI.hfig,handles);

%**************************************************************************
%**************************************************************************
%MAIN


if ~ishandle(GUI.close_button)
    PDC_CloseDevice(CAM.nDeviceNo);
    delete(gcf)
    clear all
end

end
%END MAIN
%**************************************************************************
%**************************************************************************

%%%%%     Callback functions     %%%%%

%close function
function close_button_Callback(source, eventdata)
handles = guidata(gcbo);
CAM = handles.camera;
GUI = handles.gui;
selection = questdlg('Do you want to exit the program?',...
    'Exit program',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
            [nRet nErrorCode] = PDC_CloseDevice(CAM.nDeviceNo);
            delete(gcf)
            clear all
    case 'No'
        return;
end
end

%trigger pop
function trigger_pop_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempTrgMode = CAM.nTriggerModeList(get(source,'Value'));
tempStartFrame = str2double(get(GUI.start_frame_edit,'String'));
tempEndFrame = str2double(get(GUI.end_frame_edit,'String'));
sub_SetCameraTrigger
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%start frame edit box
function start_frame_edit_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempTrgMode = CAM.nTriggerModeList(get(GUI.trigger_pop,'Value'));
tempStartFrame = str2double(get(source,'String'));
tempEndFrame = str2double(get(GUI.end_frame_edit,'String'));
sub_SetCameraTrigger
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%end frame edit box
function end_frame_edit_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempTrgMode = CAM.nTriggerModeList(get(GUI.trigger_pop,'Value'));
tempStartFrame = str2double(get(GUI.start_frame_edit,'String'));
tempEndFrame = str2double(get(source,'String'));
sub_SetCameraTrigger
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%camera toggle button
function camera_toggle_button_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;

set(GUI.ctrl_toggle_button,'Value',0);
set(GUI.meta_toggle_button,'Value',0);
set(GUI.camera_panel,'Visible','On');
set(GUI.control_panel,'Visible','Off');
set(GUI.meta_panel,'Visible','Off');

%     set(current_frame_edit,'UserData',1);
%     set(frame_slider,'UserData',1);
%     handles.start_frame_edit = start_frame_edit;
%     handles.current_frame_edit = current_frame_edit;
%     handles.end_frame_edit = end_frame_edit;
%     handles.slider = frame_slider;
%     set(play_toggle_button,'Enable','on');
%     set(play_toggle_button,'Value',0);
%     set(play_toggle_button,'UserData',0);

%     set(source,'UserData',0);
%     set(memory_radio,'Value',1);
%     set(live_radio,'Value',0);
%     set(livestop_radio,'Value',0);
%     set(record_button,'Enable','off');
%     set(record_button,'Visible','on');
%     set(waiting_button, 'Visible','off');
%     set(recording_toggle_button, 'Visible','off');

guidata(source,handles);
end



%ctrl toggle button
function ctrl_toggle_button_Callback(source, eventdata)
end

%meta toggle button
function meta_toggle_button_Callback(source, eventdata)
end

%path button
function path_button_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
folder_name = uigetdir;
set(GUI.path_edit,'String',folder_name);
set(GUI.path_edit,'Enable','on');
guidata(source,handles);
end

%record button
function record_button_Callback(source, eventdata)
handles = guidata(gcbo);
waiting_button = handles.waiting_button;
memory_radio = handles.memory_radio;
nDeviceNo = handles.DeviceNo;

PDC_STATUS_RECREADY = handles.status_recready;
PDC_STATUS_REC = handles.status_rec;
PDC_FAILED = handles.failed;

set(memory_radio,'Enable','off');
set(source,'Visible','off');
set(waiting_button, 'Visible','on');
sub_SetRecReady
end

%waiting button
function waiting_button_Callback(source, eventdata)
handles = guidata(gcbo);
recording_toggle_button = handles.recording_toggle_button;
record_button = handles.record_button;
recordrate_pop = handles.recordrate_pop;
record_stop_button = handles.record_stop_button;
nBitDepth = handles.BitDepth;
nMode = handles.Mode;
nWidth = handles.Width;
nHeight = handles.Height;
nWidthMax = handles.WidthMax;
nHeightMax = handles.HeightMax;
PDC_COLORTYPE_MONO = handles.colortype_mono;
PDC_COLORTYPE_COLOR = handles.colortype_color;
trigger_pop = handles.trigger_pop;
slider = handles.slider;
current_frame_edit = handles.current_frame_edit;
livestop_radio = handles.livestop_radio;
memory_radio = handles.memory_radio;
endless_button = handles.endless_button;

nDeviceNo = handles.DeviceNo;
nChildNo = handles.ChildNo;
PDC_FAILED = handles.failed;
PDC_STATUS_RECREADY = handles.status_recready;
PDC_STATUS_REC = handles.status_rec;
PDC_STATUS_LIVE = handles.status_live;
PDC_8BITSEL_10UPPER = handles.eightbitsel_10upper;
PDC_FUNCTION_OFF = handles.function_off;
PDC_COLORDATA_INTERLEAVE_RGB = handles.colordata_interleave_rgb;
PDC_STATUS_ENDLESS = handles.status_endless;
close = handles.close_button;
stop = handles.record_stop_button(2);
total_frame = handles.total_frame;
fig = handles.figure;
play_toggle_button = handles.play_toggle_button;
data_toggle_button = handles.data_toggle_button;
n8BitSel = handles.eightbitsel;
nBayer = handles.Bayer;
trigger_pop_value = get(trigger_pop,'Value');

set(memory_radio,'Enable','off');
set(data_toggle_button,'Enable','off');
set(source,'Visible','off');
set(play_toggle_button,'UserData',0);

if ( get(trigger_pop,'Value') == 1 )
    %Trigger START
    set(recording_toggle_button ,'Visible','on');
    set(recording_toggle_button ,'Enable','off');
    set(record_stop_button ,'Enable','on');
    set(recording_toggle_button ,'Value',1);
    set(source,'UserData',1);
    sub_TriggerIn
else
    %Trigger END & CENTER
    set(endless_button ,'Visible','on');
    sub_SetEndless
end

guidata(source,handles);
end

%endless button
function endless_button_Callback(source,eventdata)
handles = guidata(gcbo);
memory_radio = handles.memory_radio;
waiting_button = handles.waiting_button;
trigger_pop = handles.trigger_pop;
endless_button = handles.endless_button;
PDC_FAILED = handles.failed;
PDC_STATUS_ENDLESS = handles.status_endless;
PDC_STATUS_REC = handles.status_rec;
PDC_STATUS_RECREADY = handles.status_recready;
PDC_COLORTYPE_MONO = handles.colortype_mono;
PDC_COLORTYPE_COLOR = handles.colortype_color;
PDC_STATUS_PLAYBACK  = handles.status_playback;
PDC_STATUS_LIVE = handles.status_live;
PDC_COLORDATA_INTERLEAVE_RGB = handles.colordata_interleave_rgb;

nMode = handles.Mode;
nDeviceNo = handles.DeviceNo;
nChildNo = handles.ChildNo;
endless_button = handles.endless_button;
livestop_radio = handles.livestop_radio;
nWidthMax = handles.WidthMax;
nHeightMax = handles.HeightMax;
nBitDepth = handles.BitDepth;
slider = handles.slider;
current_frame_edit = handles.current_frame_edit;
close = handles.close_button;
stop = handles.record_stop_button(2);
total_frame = handles.total_frame;
fig = handles.figure;
play_toggle_button = handles.play_toggle_button;
data_toggle_button = handles.data_toggle_button;
recording_toggle_button = handles.recording_toggle_button;
record_button = handles.record_button;
record_stop_button = handles.record_stop_button;
n8BitSel = handles.eightbitsel;
nBayer = handles.Bayer;
set(data_toggle_button,'Enable','on');

sub_GetTriggerMode
if ( nTriggerMode == bitshift(hex2dec('02'),24) )
    %Trigger END
    set(source,'Visible','off');
else
    %Trigger CENTER
    set(recording_toggle_button,'Visible','On');
    set(recording_toggle_button,'Value',1);
    set(recording_toggle_button,'Enable','Off');
    set(data_toggle_button,'Enable','off');
end
sub_TriggerIn
guidata(source,handles);
end

%record stop button
function record_stop_button_Callback(source, eventdata)
handles = guidata(gcbo);
nDeviceNo = handles.DeviceNo;
PDC_STATUS_LIVE = handles.status_live;
PDC_FAILED = handles.failed;
record_button = handles.record_button;
memory_radio = handles.memory_radio;
recording_toggle_button = handles.recording_toggle_button;
waiting_button = handles.waiting_button;
data_toggle_button = handles.data_toggle_button;
endless_button = handles.endless_button;

set(data_toggle_button ,'Enable','on');
set(memory_radio,'Enable','on');
set(record_button,'Visible','on');
set(waiting_button, 'Visible','off');
set(endless_button, 'Visible','off');
set(recording_toggle_button, 'Visible','off');

set(waiting_button,'UserData',0);
sub_SetStatusLive
guidata(source,handles);
end

%live radio button
function live_radio_Callback(source,eventdata,handles)
handles = guidata(gcbo);
livestop_radio = handles.livestop_radio;
memory_radio = handles.memory_radio;
record_button = handles.record_button;
record_stop_button = handles.record_stop_button;
nDeviceNo = handles.DeviceNo;
nChildNo = handles.ChildNo;
nBitDepth = handles.BitDepth;
nWidth = handles.Width;
nHeight = handles.Height;
nWidthMax = handles.WidthMax;
nHeightMax = handles.HeightMax;
nMode = handles.Mode;
PDC_FAILED = handles.failed;
PDC_COLORTYPE_MONO  = handles.colortype_mono;
PDC_COLORTYPE_COLOR = handles.colortype_color;
PDC_STATUS_PLAYBACK = handles.status_playback;
PDC_STATUS_LIVE = handles.status_live;
PDC_8BITSEL_10UPPER = handles.eightbitsel_10upper;
PDC_FUNCTION_OFF = handles.function_off;
PDC_COLORDATA_INTERLEAVE_RGB = handles.colordata_interleave_rgb;
n8BitSel = handles.eightbitsel;
nBayer = handles.Bayer;
close = handles.close_button;
close_button = handles.close_button;

sub_GetColorType
sub_SetStatusLive

set(livestop_radio,'Value',0);
set(memory_radio,'Value',0);
set(record_button,'Enable','on');
set(record_stop_button,'Enable','on');
live_value = get(source,'Value');
if ( live_value == 0 )
    set(source,'Value',1);
end

%     OnLive(nDeviceNo,nChildNo,nMode,nBitDepth,nWidthMax,nHeightMax,n8BitSel,nBayer,close,livestop_radio,memory_radio,...,
%     PDC_COLORTYPE_MONO,PDC_COLORTYPE_COLOR,PDC_FAILED,PDC_8BITSEL_10UPPER,...,
%     PDC_FUNCTION_OFF,PDC_COLORDATA_INTERLEAVE_RGB)
h_axes = handles.axes;
OnLive(nDeviceNo,nChildNo,nMode,nBitDepth,...
    nWidthMax,nHeightMax,n8BitSel,nBayer,close,...
    livestop_radio,memory_radio,h_axes,PDC_FAILED)

if ~ishandle(close)
    sub_CloseDevice
    delete(gcf)
    clear all
else
    guidata(source,handles);
end
end

%livestop radio button
function livestop_radio_Callback(source, eventdata)
handles = guidata(gcbo);
live_radio = handles.live_radio;
memory_radio = handles.memory_radio;
record_button = handles.record_button;
recording_toggle_button = handles.recording_toggle_button;
waiting_button = handles.waiting_button;
record_stop_button = handles.record_stop_button;

set(live_radio,'Value',0);
set(memory_radio,'Value',0);
set(record_button,'Enable','off');
set(recording_toggle_button,'Visible','off');
set(waiting_button,'Visible','off');
set(record_button,'Visible','on');
set(record_stop_button,'Enable','off');
set(memory_radio,'Enable','on');
livestop_value = get(source,'Value');
if ( livestop_value == 0 )
    set(source,'Value',1);
end
end

%memory radio button
function memory_radio_Callback(source, eventdata)
handles = guidata(gcbo);
livestop_radio = handles.livestop_radio;
live_radio = handles.live_radio;
record_button = handles.record_button;
record_stop_button = handles.record_stop_button;
nDeviceNo = handles.DeviceNo;
nChildNo = handles.ChildNo;
nBitDepth = handles.BitDepth;
nMode = handles.Mode;
PDC_FAILED = handles.failed;
PDC_STATUS_PLAYBACK = handles.status_playback;
PDC_COLORTYPE_MONO = handles.colortype_mono;
PDC_COLORTYPE_COLOR = handles.colortype_color;
PDC_COLORDATA_INTERLEAVE_RGB = handles.colordata_interleave_rgb;
PDC_8BITSEL_10UPPER = handles.eightbitsel_10upper;
PDC_FUNCTION_OFF = handles.function_off;
nWidthMax = handles.WidthMax;
nHeightMax = handles.HeightMax;
n8BitSel = handles.eightbitsel;
nBayer = handles.Bayer;
sub_GetColorType

set(livestop_radio,'Value',0);
set(live_radio,'Value',0);
set(record_button,'Enable','off');
set(record_stop_button,'Enable','off');
memory_value = get(source,'Value');
if ( memory_value == 0 )
    set(source,'Value',1);
end

sub_GetMemRecordRateResolution
handles.MemRecordRate = nRate;
guidata(source,handles);
sub_GetMemFrameInfo
FrameNum = get(source,'Value');
sub_GetMemImage
sub_DispImage
end

% %save button
% function save_button_Callback(source, eventdata)
%     handles = guidata(gcbo);
%     filename_edit = handles.filename_edit;
%     path_edit = handles.path_edit;
%     nDeviceNo = handles.DeviceNo;
%     nChildNo = handles.ChildNo;
%     PDC_FAILED = handles.failed;
%     format_pop = handles.format_pop;
%     fh = handles.axes;
%     PDC_COLORTYPE_MONO = handles.colortype_mono;
%     PDC_STATUS_PLAYBACK = handles.status_playback;
%     nMode = handles.Mode;
%     nBitDepth = handles.BitDepth;
%     current_frame_edit = handles.current_frame_edit;
%     PDC_COLORDATA_INTERLEAVE_BGR = handles.colordata_interleave_bgr;
%     PDC_COLORDATA_INTERLEAVE_RGB = handles.colordata_interleave_rgb;
%     current_frame = get(current_frame_edit,'String');
%     nFrameNo = str2num(current_frame);
%     FrameNum =  nFrameNo;
%     nWidthMax = handles.WidthMax;
%     nHeightMax = handles.HeightMax;
%     startframe = handles.startframe;
%     endframe = handles.endframe;
%
%     format = get(format_pop,'Value');
%     path = get(path_edit,'Enable');
%     n8BitSel                = handles.eightbitsel;
%     nBayer                  = handles.Bayer;
%     nInterleave             = PDC_COLORDATA_INTERLEAVE_BGR;
%
%     sub_SetTransferOption
%     sub_GetMemResolution
%
%     switch (path)
%
%         case 'off'
%         msgbox('Please select a folder','No folder chosen','help');
%
%         otherwise
%
%         lpszFileName = strcat(get(path_edit,'String'),'\',get(filename_edit,'String'));
%         if ( format == 1 ) %AVI
%             lpszFileName = strcat(lpszFileName,'.avi');
%             nPlayRate = handles.MemRecordRate;
%             nShowCompressDlg = 1;
%             sub_GetMemFrameInfo
%             start_value = get(startframe,'String');
%             end_value = get(endframe,'String');
%
%             iStart = str2num(start_value);
%             iEnd = str2num(end_value);
%
%             sub_AviFileSave
%
%             if nRet ~= PDC_FAILED
%                 msgbox(strcat(strcat(get(filename_edit,'String'),'.avi'),' has been saved'),'Save','help');
%             end
%
%         elseif ( format == 2 ) %JPEG
%             lpszFileName = strcat(lpszFileName,'.jpg');
%
%             if ( nMode == PDC_COLORTYPE_MONO )
%                 sub_GetMemImage
%                 colormap( gray(256) );
%                 imwrite(nBuf',lpszFileName);
%             else
%                 nInterleave             = PDC_COLORDATA_INTERLEAVE_RGB;
%                 sub_SetTransferOption
%                 sub_GetMemImage
%                 imwrite(permute( nBuf, [3 2 1] ),lpszFileName);
%             end
%
%             if nRet ~= PDC_FAILED
%                 msgbox(strcat(strcat(get(filename_edit,'String'),'.jpg'),' has been saved'),'Save','help');
%             end
%
%         elseif ( format == 3 ) %BMP
%             lpszFileName = strcat(lpszFileName,'.bmp');
%             sub_BMPFileSave
%
%             if nRet ~= PDC_FAILED
%                 msgbox(strcat(strcat(get(filename_edit,'String'),'.bmp'),' has been saved'),'Save','help');
%             end
%         end
%     end
% end

%record rate pop button
function recordrate_pop_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempHeight = CAM.nHeight;
tempWidth = CAM.nWidth;
tempShutter = CAM.nRate;
tempFps =  CAM.nRecordRateList(get(source,'Value'));
sub_SetCameraProperties
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
% shutter_pop = handles.shutter_pop;
% %    resolution_pop = handles.resolution_pop;
% nDeviceNo = handles.DeviceNo;
% nChildNo = handles.ChildNo;
% PDC_FAILED = handles.failed;
% FALSE = handles.false;
% TRUE = handles.true;
% %    set(resolution_pop,'Value',1);
% %    resolution_pop_Callback(resolution_pop);
% record_value = get(source,'Value');
% nRecordRateSize = handles.RecordRateSize;
% nRecordRateList = handles.RecordRateList;
% nShutterList = handles.ShutterList;
% nShutterSize = handles.ShutterSize;
% %    nResolutionList = handles.ResolutionList;
% %    nResolutionSize = handles.ResolutionSize;
% 
% %Set record rate
% for x=1:nRecordRateSize
%     if ( x == record_value )
%         nFps = nRecordRateList(x);
%         sub_SetRecordRate
%         sub_SetShutterSpeedFps
%     end
% end
% 
% sub_GetShutterSpeedFpsList
% for x=1:nShutterSize
%     MyShutter{x} = [ '1/' num2str(nShutterList(x)) ' sec'];
% end
% 
% set(shutter_pop,'String',MyShutter);
% 
% for x=1:nShutterSize
%     if ( nFps == nShutterList(x) )
%         set(shutter_pop,'Value',x)
%     end
% end

%    sub_GetResolution
%    nResolutionList_t = bitshift(nWidth,16);
%    nResolutionList_t = nResolutionList_t + nHeight;
%
%     for x=1:nResolutionSize
%       if ( nResolutionList(x) == nResolutionList_t )
%           set(resolution_pop,'Value',x);
%       end
%     end

% handles.ShutterList = nShutterList;
% handles.ShutterSize = nShutterSize;
% guidata(source,handles);
end

%shutter rate pop button
function shutter_pop_Callback(source, eventdata)
source
eventdata
handles = guidata(gcbo)
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
CAM.nFps = CAM.nShutterList(get(source,'Value'));
[nRet, nErrorCode] = PDC_SetShutterSpeedFps(CAM.nDeviceNo, CAM.nChildNo, CAM.nFps)
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%resolutionWidth pop button
function resolutionW_pop_Callback(source,eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempHeight = CAM.nHeight;
tempWidth = widthList(get(source,'Value'));
tempShutter = CAM.nRate;
tempFps =  CAM.nFps;
sub_SetCameraProperties
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%resolutionHeight pop button
function resolutionH_pop_Callback(source,eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
tempHeight = heightList(get(source,'Value'));
tempWidth = CAM.nWidth;
tempShutter = CAM.nRate;
tempFps =  CAM.nFps;
sub_SetCameraProperties
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

%Bitshift pop menu
function bitshift_pop_Callback(source, eventdata)
handles = guidata(gcbo);
PDC = handles.pdc;
CAM = handles.camera;
GUI = handles.gui;
CAM.n8BitSel = get(source,'Value')-1;
[nRet, nErrorCode] = PDC_SetTransferOption(CAM.nDeviceNo, CAM.nChildNo, CAM.n8BitSel, CAM.nBayer, CAM.nInterleave)
guidata(source,handles);
refreshFrame(PDC,CAM,GUI)
end

function refreshFrame(PDC,CAM,GUI)
[ nRet, nBuf, nErrorCode ] = PDC_GetLiveImageData( CAM.nDeviceNo, CAM.nChildNo, CAM.nBitDepth, CAM.nMode, CAM.nBayer, CAM.nWidth, CAM.nHeight );
frame = flipud(nBuf');
set(GUI.hIm1,'CData',flipud(frame))
drawnow
end

%Live mode
function OnLive(nDeviceNo,nChildNo,nMode,nBitDepth,...
    nWidthMax,nHeightMax,n8BitSel,nBayer,close,...
    livestop,memory,h_axes,PDC_FAILED)
sub_GetResolution
frame = zeros(nHeight,nWidth);
%    'CDataMapping','scaled',
hImage = image(frame,'Parent',h_axes,...
    'CreateFcn','axis image');

colormap(gray(256));

while 1
    if ~ishandle(close)
        break;
    end
    
    livestop_value = get(livestop,'Value');
    memory_value = get(memory,'Value');
    
    if ( livestop_value == 1 || memory_value == 1 )
        break;
    end
    
    sub_GetResolution
    sub_GetLiveImage
    %             colormap( gray(256) );
    if ( nWidth ~= nWidthMax )
        A = ones(nWidthMax - nWidth,nHeight);
        B = [ nBuf ; A ];
        C = ones(nWidthMax, nHeightMax - nHeight);
        D = [B C];
        clear nBuf
        nBuf= D;
        %                 image( nBuf');
        frame = nBuf';
        
    else
        %                 image( nBuf');
        frame = nBuf';
        
    end
    set(hImage,'CData',flipud(frame))
    drawnow
    % %            image( nBuf');
    %     image(frame)
    %     drawnow
end

% while 1
%     if ~ishandle(close)
%         break;
%     end
%
%     livestop_value = get(livestop,'Value');
%     memory_value = get(memory,'Value');
%     if ( livestop_value == 1 || memory_value == 1 )
%         break;
%     end
%     sub_GetResolution
%     sub_GetLiveImage
%
% %     A = ones(nWidthMax - nWidth,nHeight);
% %     B = [ nBuf ; A ];
% %     C = ones(nWidthMax, nHeightMax - nHeight);
% %     D = [B C];
% %     clear nBuf
% %     nBuf= D;
%            A = ones(nWidthMax - nWidth,nHeight);
%            B = [ nBuf ; A ];
%            C = ones(nWidthMax, nHeightMax - nHeight);
%            D = [B C];
% %            clear nBuf
%            nBuf= D;
% %            image( nBuf');
%     frame = nBuf';
%     image(frame)
% %     set(hImage,'CData',frame)
%     drawnow
% end
end
%figure resize
function resizeGUI(source,eventdata)
% handles = guidata(gcbo);
%     camera_display_panel = handles.camera_display_panel;
%     ax = handles.axes;
%     ax_oldunits = get(ax,'Units');
%     set(ax,'Parent',camera_display_panel,'Units','normalized', 'Position', [.07 .1 .85 .85]);
%     set(ax,'Units','pix');
%     ax_pos = get(ax,'Position');
%
%     if ( ax_pos(3)/ax_pos(4) > 1 )
%        ax_pos(3) = ax_pos(4);
%     else
%         ax_pos(4) = ax_pos(3);
%     end
%     set(ax,'Position',ax_pos);
%
%     set(ax,'Units',ax_oldunits);
%     guidata(source,handles);
end

%calibrate camera
function calibrate_button_Callback(source,eventdata)
handles = guidata(gcbo);
[nRet, nErrorCode] = PDC_SetShadingMode(handles.DeviceNo, handles.ChildNo, 2);

end