
[ nRet, nBuf, nErrorCode ] = PDC_GetLiveImageData( nDeviceNo, nChildNo, nBitDepth, nMode, nBayer, nWidth, nHeight );

if nRet == PDC_FAILED
    disp(['PDC_GetLiveImageData Error : ' num2str(nErrorCode)]);
end

