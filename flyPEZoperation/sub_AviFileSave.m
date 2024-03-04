
[ nRet, nErrorCode ] = PDC_AVIFileSaveOpen( nDeviceNo, nChildNo, lpszFileName, nPlayRate, nShowCompressDlg );

if nRet == PDC_FAILED
    disp(['PDC_AVIFileSaveOpen Error : ' num2str(nErrorCode)]);
    return;
end

for nFrameNo = iStart : iEnd
    if(nFrameNo ~= 0 || iCurrent == 0)
        [ nRet, nPlaySize, nErrorCode ] = PDC_AVIFileSave( nDeviceNo, nChildNo, nFrameNo );
        stopBar= progressbar((nFrameNo - iStart)/(iEnd - iStart), 0);
        if(stopBar) break; end

        if nRet == PDC_FAILED
            disp(['PDC_AVIFileSave Error : ' num2str(nErrorCode)]);
            return;
        end
    end
end

[ nRet, nErrorCode ] = PDC_AVIFileSaveClose( nDeviceNo, nChildNo );

if nRet == PDC_FAILED
    disp(['PDC_AVIFileSaveClose Error : ' num2str(nErrorCode)]);
end
