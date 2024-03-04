
[ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );

if nRet == PDC_FAILED
    disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
end
        
if nStatus ~= PDC_STATUS_PLAYBACK
    
   [ nRet, nErrorCode ] = PDC_SetStatus( nDeviceNo, PDC_STATUS_PLAYBACK ); 
   
   if nRet == PDC_FAILED
        disp(['PDC_SetStatus Error : ' num2str(nErrorCode)]);
   end
end      

while 1
    [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );
    
    if nRet == PDC_FAILED
        disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
    end
    
    if nStatus == PDC_STATUS_PLAYBACK
        break;
    end    
end



