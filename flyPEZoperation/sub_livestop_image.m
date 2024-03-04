

[ nRet, nBuf, nErrorCode ] = PDC_GetLiveImageData( CAM.nDeviceNo, CAM.nChildNo, CAM.nBitDepth, CAM.nMode, CAM.nBayer, CAM.nWidth, CAM.nHeight );
frame = nBuf';
set(hImage,'CData',flipud(frame))
drawnow
