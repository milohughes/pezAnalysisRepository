
[ nRet, nErrorCode ] = PDC_SetEndless( nDeviceNo );

if nRet == PDC_FAILED
    disp(['PDC_SetEndless Error : ' num2str(nErrorCode)]);
end