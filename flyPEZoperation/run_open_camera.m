% Initializing and opening camera

Detect_auto1_edit_num = 192;
Detect_auto2_edit_num = 168;
Detect_auto3_edit_num = 0;
Detect_auto4_edit_num = 10;

%Detect auto hex IP calculation
Detect_auto1_hex = dec2hex(Detect_auto1_edit_num);
Detect_auto2_hex = dec2hex(Detect_auto2_edit_num);
Detect_auto3_hex = strcat('0',dec2hex(Detect_auto3_edit_num));
Detect_auto4_hex = strcat('0',dec2hex(Detect_auto4_edit_num));
Detect_auto_hex = strcat(Detect_auto1_hex,Detect_auto2_hex,Detect_auto3_hex,Detect_auto4_hex);
IPList = hex2dec(Detect_auto_hex);

CAM.nInterfaceCode = uint32(2);
CAM.nDetectNo = uint32(IPList);
CAM.nDetectNum = uint32(1);
CAM.nDetectParam = uint32(0);

%Initialize detect and open device
[nRet nErrorCode] = PDC_Init;
if nRet == PDC.FAILED && nErrorCode ~= 7
    disp(['PDC_Init Error : ' num2str(nErrorCode)]);
end

[ nRet, CAM.nDetectNumInfo, nErrorCode] = PDC_DetectDevice( CAM.nInterfaceCode, CAM.nDetectNo, CAM.nDetectNum, CAM.nDetectParam );
if nRet == PDC.FAILED
    disp(['PDC_DetectDevice Error : ' num2str(nErrorCode)]);
end
if CAM.nDetectNumInfo.m_nDeviceNum == 0
    disp(['nDetectNumInfo.m_nDeviceNum Error : nDetectNumInfo.m_nDeviceNum = 0']);
end

[ nRet, CAM.nDeviceNo, nErrorCode ] = PDC_OpenDevice( CAM.nDetectNumInfo.m_DetectInfo );
if nRet == PDC.FAILED
    WRW_reset_device
    [ nRet, CAM.nDeviceNo, nErrorCode ] = PDC_OpenDevice( CAM.nDetectNumInfo.m_DetectInfo );
    if nRet == PDC.FAILED
        disp(['PDC_OpenDevice Error : ' num2str(nErrorCode)]);
        msgbox('Camera was not opened','No camera opened','Warn');
        return;
    end
end

% confirm zero children
[ nRet, CAM.nStatus, nErrorCode ] = PDC_GetStatus( CAM.nDeviceNo );
[ nRet, nMaxChildCount, nErrorCode ] = PDC_GetMaxChildDeviceCount( CAM.nDeviceNo );
[ nRet, nChildSize, nChildList, nErrorCode ] = PDC_GetExistChildDeviceList( CAM.nDeviceNo );
CAM.nChildNo = nChildList(1);

% get device properties
[ nRet, CAM.nDeviceName, nErrorCode ] = PDC_GetDeviceName( CAM.nDeviceNo, 0 );
[ nRet, CAM.nFrames, CAM.nBlock, nErrorCode ] = PDC_GetMaxFrames( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nRate, nErrorCode] = PDC_GetRecordRate( CAM.nDeviceNo, CAM.nChildNo );
if CAM.nStatus ~= PDC.STATUS_LIVE
   [ nRet, nErrorCode ] = PDC_SetStatus( CAM.nDeviceNo, PDC.STATUS_LIVE ); 
end      
[ nRet, CAM.nMode, nErrorCode] = PDC_GetColorType( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nWidthMax, CAM.nHeightMax, nErrorCode ] = PDC_GetMaxResolution( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nWidth, CAM.nHeight, nErrorCode ] = PDC_GetResolution( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nFps, nErrorCode ] = PDC_GetShutterSpeedFps( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nTrgMode, CAM.nAFrames, CAM.nRFrames, CAM.nRCount, nErrorCode ] = PDC_GetTriggerMode( CAM.nDeviceNo );
[ nRet, CAM.n8BitSel, CAM.nBayer, CAM.nInterleave, nErrorCode ] = PDC_GetTransferOption( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nWidthStep, CAM.nHeightStep, CAM.nXPosStep, CAM.nYPosStep, CAM.nWidthMin, CAM.nHeightMin, CAM.nFreePos, nErrorCode] = PDC_GetVariableRestriction(CAM.nDeviceNo);

CAM.nBitDepth = 8;
CAM.nChannel = 1;

% populate lists
[ nRet, CAM.nRecordRateSize, CAM.nRecordRateList, nErrorCode ] = PDC_GetRecordRateList( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nResolutionSize, CAM.nResolutionList, nErrorCode ] = PDC_GetResolutionList( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nShutterSize, CAM.nShutterList, nErrorCode ] = PDC_GetShutterSpeedFpsList( CAM.nDeviceNo, CAM.nChildNo );
[ nRet, CAM.nTriggerModeSize, CAM.nTriggerModeList, nErrorCode] = PDC_GetTriggerModeList(CAM.nDeviceNo);

[nRet, nErrorCode] = PDC_SetRecordingType(CAM.nDeviceNo, 2);

[nRet, nErrorCode] = PDC_SetDownloadMode(CAM.nDeviceNo, PDC.DOWNLOAD_MODE_PLAYBACK_OFF);
[nRet, nErrorCode] = PDC_SetAutoPlay(CAM.nDeviceNo, PDC.AUTOPLAY_OFF);

if nRet == PDC.FAILED
    disp(['Error : ' num2str(nErrorCode)]);
else
    disp('Camera is ready')
end
