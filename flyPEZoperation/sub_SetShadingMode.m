
[ nRet, nErrorCode ] = PDC_SetShadingMode( nDeviceNo, nChildNo, nMode );

if nRet == PDC_FAILED
    disp(['PDC_SetShadingMode Error : ' num2str(nErrorCode)]);
end

