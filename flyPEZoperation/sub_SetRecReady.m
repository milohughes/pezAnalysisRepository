
[ nRet, nErrorCode ] = PDC_SetRecReady( nDeviceNo );

if nRet == PDC_FAILED
    disp(['PDC_SetRecready Error : ' num2str(nErrorCode)]);
end

while 1
    [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );

    if nRet == PDC_FAILED
        disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
    end
    
    if ( nStatus == PDC_STATUS_RECREADY ) || ( nStatus == PDC_STATUS_REC )
        break;
    end
    drawnow
end