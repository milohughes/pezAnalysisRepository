%reset camera
function WRW_reset_device
close all force
clear all
clc
% Ret Code
PDC_FAILED = 0;
PDC_SUCCEEDED = 1;

[nRet, nErrorCode] = PDC_Init;

if nRet == PDC_FAILED
    disp(['PDC_Init Error : ' num2str(nErrorCode)]);
end

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

nInterfaceCode = uint32(2);
nDetectNo = uint32(IPList);
nDetectNum = uint32(1);
nDetectParam = uint32(0);
[nRet, nDetectNumInfo, nErrorCode] = PDC_DetectDevice(nInterfaceCode, nDetectNo, nDetectNum, nDetectParam);
if nRet == PDC_FAILED
    disp(['PDC_DetectDevice Error : ' num2str(nErrorCode)]);
end
 
if nDetectNumInfo.m_nDeviceNum == 0
    disp('nDetectNumInfo.m_nDeviceNum Error : nDetectNumInfo.m_nDeviceNum = 0');   
end

[ nRet, nDeviceNo, nErrorCode ] = PDC_OpenDevice( nDetectNumInfo.m_DetectInfo );

if nRet == PDC_FAILED
    disp(['PDC_OpenDevice Error : ' num2str(nErrorCode)]);
end

[nRet nErrorCode] = PDC_CloseDevice(nDeviceNo);

if nRet == PDC_FAILED
    disp(['PDC_CloseDevice Error : ' num2str(nErrorCode)]);
else
    disp('Device closed');
end