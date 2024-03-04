
if (nWidth == nWidthMax)
   nHeight = nWidth;
else
    sub_GetResolution
end

[ nRet, nBuf, nErrorCode ] = PDC_GetMemImageData( nDeviceNo, nChildNo, FrameNum, nBitDepth, nMode, nBayer, nWidth, nHeight );

if nRet == PDC_FAILED
    disp(['PDC_GetMemImageData Error : ' num2str(nErrorCode)]);
end