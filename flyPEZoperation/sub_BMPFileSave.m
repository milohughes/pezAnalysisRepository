
[ nRet, nErrorCode ] = PDC_BMPFileSave( nDeviceNo, nChildNo, lpszFileName, nFrameNo );

if nRet == PDC_FAILED
    disp(['PDC_BMPFileSave Error : ' num2str(nErrorCode)]);
end

