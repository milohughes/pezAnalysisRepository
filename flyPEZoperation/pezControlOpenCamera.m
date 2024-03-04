function nDeviceNo = pezControlOpenCamera(cameraIP,PDC)
%pezControlOpenCamera Opens photron camera associated with input IP

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
[~,nErrorCode] = PDC_Init;
if nErrorCode ~= 1 && nErrorCode ~= 7, disp(['Init Error ' int2str(nErrorCode)]), end
[nRet,nDetectNumInfo,nErrorCode] = PDC_DetectDevice( nInterfaceCode, nDetectNo, nDetectNum, nDetectParam );
if nRet ~= 1, disp(['DetectDevice Error ' int2str(nErrorCode)]), end
if nDetectNumInfo.m_nDeviceNum == 0
    disp('nDetectNumInfo.m_nDeviceNum Error : nDetectNumInfo.m_nDeviceNum = 0');
    return
end
[nRet,nDeviceNo,~] = PDC_OpenDevice(nDetectNumInfo.m_DetectInfo);
if nRet ~= 1
    [~,~] = PDC_CloseDevice(nDeviceNo);
    [nRet,nDeviceNo,nErrorCode] = PDC_OpenDevice( nDetectNumInfo.m_DetectInfo );
    if nRet ~= 1
        nDeviceNo = [];
        disp(['PDC_OpenDevice Error : ' num2str(nErrorCode)]);
        return
    end
end

% set camera states
[nRet,nStatus,nErrorCode] = PDC_GetStatus(nDeviceNo);
errorCodeTest(nRet,nErrorCode)
if nStatus ~= PDC.STATUS_LIVE
    [nRet,nErrorCode] = PDC_SetStatus(nDeviceNo,PDC.STATUS_LIVE);
    if nRet == PDC.FAILED, disp(['SetStatus Error ' int2str(nErrorCode)]), end
end
[nRet,nErrorCode] = PDC_SetRecordingType(nDeviceNo,PDC.RECORDING_TYPE_READY_AND_TRIG);
errorCodeTest(nRet,nErrorCode)
[nRet,nErrorCode] = PDC_SetDownloadMode(nDeviceNo,PDC.DOWNLOAD_MODE_PLAYBACK_OFF);
errorCodeTest(nRet,nErrorCode)
[nRet,nErrorCode] = PDC_SetAutoPlay(nDeviceNo,PDC.AUTOPLAY_OFF);
errorCodeTest(nRet,nErrorCode)

[nRet,~,nOut,nErrorCode] = PDC_GetExternalCount(nDeviceNo);
errorCodeTest(nRet,nErrorCode)
if nOut < 4, error('Insufficient number of camera ports'), end
[nRet,nMode,nErrorCode] = PDC_GetExternalOutMode(nDeviceNo,1);
errorCodeTest(nRet,nErrorCode)
if nMode ~= PDC.EXT_OUT_RECORD_POSI
    [nRet, nErrorCode] = PDC_SetExternalOutMode(nDeviceNo,1,PDC.EXT_OUT_RECORD_POSI);
%     [nRet, nErrorCode] = PDC_SetExternalOutMode(nDeviceNo,1,PDC.EXT_OUT_READY_POSI);
%     [nRet, nErrorCode] = PDC_SetExternalOutMode(nDeviceNo,1,PDC.EXT_OUT_REC_POS_AND_SYNC_POS);
    errorCodeTest(nRet,nErrorCode)
end
[nRet,nMode,nErrorCode] = PDC_GetExternalOutMode(nDeviceNo,2);
errorCodeTest(nRet,nErrorCode)
if nMode ~= PDC.EXT_OUT_SYNC_POSI
    [nRet, nErrorCode] = PDC_SetExternalOutMode(nDeviceNo,2,PDC.EXT_OUT_SYNC_POSI);
    errorCodeTest(nRet,nErrorCode)
end
[nRet,nMode,nErrorCode] = PDC_GetExternalOutMode(nDeviceNo,3);
errorCodeTest(nRet,nErrorCode)
if nMode ~= PDC.EXT_OUT_SYNC_NEGA
    [nRet, nErrorCode] = PDC_SetExternalOutMode(nDeviceNo,3,PDC.EXT_OUT_SYNC_NEGA);
    errorCodeTest(nRet,nErrorCode)
end

end

function errorCodeTest(nRet,nErrorCode)
if nRet ~= 1
    disp(['Camera error: ' num2str(nErrorCode)]);
end
end

