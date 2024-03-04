
[nRet nBitDepth nErrorCode] = PDC_GetBitDepth( nDeviceNo, nChildNo );

if nRet == PDC_FAILED
    disp(['PDC_GetBitDepth : ' num2str(nErrorCode)]);
end