
[ nRet, nErrorCode ] = PDC_SetResolution( nDeviceNo, nChildNo, nWidth, nHeight );

if nRet == PDC_FAILED
    disp(['PDC_SetResolution Error : ' num2str(nErrorCode)]);
end

