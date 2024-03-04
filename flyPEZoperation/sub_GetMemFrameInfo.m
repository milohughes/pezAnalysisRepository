
[ nRet, FrameInfo, nErrorCode ] = PDC_GetMemFrameInfo( nDeviceNo, nChildNo );

if nRet == PDC_FAILED
    disp(['PDC_GetMemFrameInfo Error : ' num2str(nErrorCode)]);
end

iStart = FrameInfo.m_nStart;
iEnd = FrameInfo.m_nEnd; 
iCurrent = FrameInfo.m_nTrigger;