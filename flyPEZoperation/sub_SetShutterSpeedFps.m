
[ nRet, nErrorCode ] = PDC_SetShutterSpeedFps( nDeviceNo, nChildNo, nFps );

if nRet == PDC_FAILED
    disp(['PDC_SetShutterSpeedFps Error : ' num2str(nErrorCode)]);
end

