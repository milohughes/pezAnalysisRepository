
sub_SetStatusPlayback

[ nRet, nRate, nErrorCode ] = PDC_GetMemRecordRate( nDeviceNo, nChildNo );

if nRet == PDC_FAILED
    disp(['PDC_GetMemRecordRate Error : ' num2str(nErrorCode)]);
end

[ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );

if nRet == PDC_FAILED
    disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
end



