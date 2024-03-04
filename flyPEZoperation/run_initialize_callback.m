
% set values for pop controls
set(GUI.recordrate_pop,'Value',find(CAM.nRecordRateList == CAM.nRate));
set(GUI.shutter_pop,'Value',find(CAM.nShutterList == CAM.nFps ));
set(GUI.resolutionW_pop,'Value',find(CAM.widthList == CAM.nWidth));
set(GUI.resolutionH_pop,'Value',find(CAM.heightList == CAM.nHeight));
set(GUI.bitshift_pop,'Value',CAM.n8BitSel+1);
set(GUI.trigger_pop,'Value',find(CAM.nTriggerModeList == CAM.nTrgMode));

% initialize callbacks
set(GUI.live_radio,'Callback',{@live_radio_Callback});
set(GUI.livestop_radio,'Callback',{@livestop_radio_Callback});
set(GUI.memory_radio,'Callback',{@memory_radio_Callback});
set(GUI.record_button,'Callback',{@record_button_Callback});
set(GUI.waiting_button,'Callback',{@waiting_button_Callback});
set(GUI.endless_button,'Callback',{@endless_button_Callback});
set(GUI.record_stop_button,'Callback',{@record_stop_button_Callback});
% set(GUI.play_toggle_button,'Callback',{@play_toggle_button_Callback});
set(GUI.path_button,'Callback',{@path_button_Callback});
% set(GUI.stop_button,'Callback',{@stop_button_Callback});
set(GUI.start_frame_edit,'Callback',{@start_frame_edit_Callback});
% set(GUI.current_frame_edit,'Callback',{@current_frame_edit_Callback});
set(GUI.end_frame_edit,'Callback',{@end_frame_edit_Callback});
% set(GUI.frame_slider,'Callback',{@frame_slider_Callback});
set(GUI.camera_toggle_button,'Callback',{@camera_toggle_button_Callback});
set(GUI.ctrl_toggle_button,'Callback',{@ctrl_toggle_button_Callback});
set(GUI.meta_toggle_button,'Callback',{@meta_toggle_button_Callback});
% set(GUI.save_button,'Callback',{@save_button_Callback});
set(GUI.close_button,'Callback',{@close_button_Callback});
set(GUI.hfig,'CloseRequestFcn',{@close_button_Callback});
set(GUI.recordrate_pop,'Callback',{@recordrate_pop_Callback});
set(GUI.shutter_pop,'Callback',@shutter_pop_Callback);
set(GUI.trigger_pop,'Callback',{@trigger_pop_Callback});
set(GUI.resolutionW_pop,'Callback',{@resolutionW_pop_Callback});
set(GUI.resolutionH_pop,'Callback',{@resolutionH_pop_Callback});
set(GUI.bitshift_pop,'Callback',{@bitshift_pop_Callback});
set(GUI.calibrate_button,'Callback',{@calibrate_button_Callback});
set(GUI.hfig,'ResizeFcn',{@resizeGUI});

% initialize values

% [nRet, CAM.nChannel, nErrorCode] = PDC_GetVariableChannel(CAM.nDeviceNo, CAM.nChildNo);
% if CAM.nChannel == 0
%     CAM.nChannel = 1;
% end
% [nRet, CAM.VarRate, CAM.VarWidth, CAM.VarHeight, CAM.VarXPos, CAM.VarYPos, nErrorCode] = PDC_GetVariableChannelInfo(CAM.nDeviceNo, CAM.nChannel)
% [nRet, nErrorCode] = PDC_SetVariableChannel(CAM.nDeviceNo, CAM.nChildNo, nChannel);

% [nRet, nErrorCode] = PDC_SetRecReady(CAM.nDeviceNo)
% [nRet, nErrorCode] = PDC_SetEndless(CAM.nDeviceNo)
