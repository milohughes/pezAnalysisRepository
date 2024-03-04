
while 1
    for i = round(frame_value) : end_value
        if (get(source,'UserData')==0)
            itemp = i;
            handles.itemp = itemp;
            break;
        end

        FrameNum = i;
        set(frame_slider,'Value',i);
        set(current_frame_edit,'String',num2str(i));
            
        if(i~= 0 || iCurrent == 0)
            sub_GetMemImage
            sub_DispImage
        end
        drawnow
            
        if ~ishandle(close)
            break;
        end
    end
      
    if (i == end_value)
        frame_value = start_value;
    end

    if ~ishandle(close)
        break;
    end

    if (get(source,'UserData')==0)
        set(source,'UserData',1);
        set(frame_slider,'UserData',1);
        break;
    end
    drawnow
end
%END WHILE

if (ishandle(close))
    set(source,'Enable','on');
    set(source,'Value',0);
    guidata(source,handles);
end