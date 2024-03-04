
[ nRet, nErrorCode ] = PDC_TriggerIn( nDeviceNo );
if nRet == PDC_FAILED
    disp(['PDC_TriggerIn Error : ' num2str(nErrorCode)]);
end

while 1
    [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );   
    if nRet == PDC_FAILED
        disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
    end

    if ( nStatus ~= PDC_STATUS_RECREADY ) && ( nStatus ~= PDC_STATUS_ENDLESS )
        break;
    end    
end

switch nMode

    case PDC_COLORTYPE_MONO
        
        while 1

            [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );

            if nRet == PDC_FAILED
                disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
            end

            if ( get(source,'UserData') == 0 ) 
                [ nRet, nErrorCode ] = PDC_SetStatus( nDeviceNo, PDC_STATUS_LIVE );
            end

            if (( nStatus ~= PDC_STATUS_RECREADY ) && ( nStatus ~= PDC_STATUS_REC ) && ( nStatus ~= PDC_STATUS_ENDLESS )  ) || (~ishandle(close)) 
                break;
            end

            livestop_value = get(livestop_radio,'Value');

            if (livestop_value == 1)
                break; 
            end

            sub_GetResolution
            sub_GetLiveImage
            colormap( gray(256) );
            
            if(nWidth ~= nWidthMax)
                A = ones(nWidthMax - nWidth,nHeight);
                B = [ nBuf ; A ];
                C = ones(nWidthMax, nHeightMax - nHeight);
                D = [B C];
                clear nBuf
                nBuf= D;
                image( nBuf'); 
            else
                image( nBuf');   
            end   
            drawnow
        end
        
    case PDC_COLORTYPE_COLOR
        
        nInterleave = PDC_COLORDATA_INTERLEAVE_RGB;
        
        while 1
          
            [ nRet, nStatus, nErrorCode ] = PDC_GetStatus( nDeviceNo );
    
            if nRet == PDC_FAILED
                disp(['PDC_GetStatus Error : ' num2str(nErrorCode)]);
            end

            if ( get(source,'UserData') == 0 ) 
                [ nRet, nErrorCode ] = PDC_SetStatus( nDeviceNo, PDC_STATUS_LIVE );
            end
          
            if ((( nStatus ~= PDC_STATUS_RECREADY ) && ( nStatus ~= PDC_STATUS_REC )) || (~ishandle(close)) )
                break;
            end

            livestop_value = get(livestop_radio,'Value');

            if (livestop_value == 1)
                break; 
            end

            sub_SetTransferOption
            sub_GetResolution
            sub_GetLiveImage
            
            if(nWidth ~= nWidthMax)
                A = ones(nWidthMax - nWidth,nHeight,3);
                nBuf = permute(nBuf,[2 3 1]);
                B = [ nBuf ; A ];
                C = ones(nWidthMax, nHeightMax - nHeight);
                D1 = [B(:,:,1)  C];
                D2 = [B(:,:,2) C];
                D3 = [B(:,:,3) C];
                clear nBuf
                nBuf(:,:,1) = D1;
                nBuf(:,:,2) = D2;
                nBuf(:,:,3) = D3;
                image(permute(nBuf,[ 2 1 3 ]));
            else
                image( permute( nBuf, [3 2 1] ) );   
            end    
            drawnow
        end
end
set(source,'Visible','off');
set(memory_radio,'Enable','on');
set(recording_toggle_button ,'Visible','off');
set(record_button,'Visible','on');
set(data_toggle_button,'Enable','on');