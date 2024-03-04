
sub_SetStatusPlayback

[ nRet, nWidth, nHeight, nErrorCode ] = PDC_GetMemResolution( nDeviceNo, nChildNo );

if nRet == PDC_FAILED
    disp(['PDC_GetMemResolution Error : ' num2str(nErrorCode)]);
end
