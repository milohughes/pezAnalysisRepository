clc
disp(string(datetime('now')))
original_stimulusStruct = stimulusStruct;

for i = 1:768
    for j = 1:1024
        % Inverse first/ default image
        stimulusStruct.imgReset(i,j,1)=(255-stimulusStruct.imgReset(i,j,1));
        if (stimulusStruct.imgReset(i,j,1) < 0) || (stimulusStruct.imgReset(i,j,1) > 255)
            disp(stimulusStruct.imgReset(i,j,1))
        end
        stimulusStruct.imgReset(i,j,2)=(255-stimulusStruct.imgReset(i,j,2));
        if (stimulusStruct.imgReset(i,j,2) < 0) || (stimulusStruct.imgReset(i,j,2) > 255)
            disp(stimulusStruct.imgReset(i,j,2))
        end
        stimulusStruct.imgReset(i,j,3)=(255-stimulusStruct.imgReset(i,j,3));
        if (stimulusStruct.imgReset(i,j,3) < 0) || (stimulusStruct.imgReset(i,j,3) > 255)
            disp(stimulusStruct.imgReset(i,j,3))
        end

        % Inverse last/ largest loom image
        stimulusStruct.imgFin(i,j,1)=(255-stimulusStruct.imgFin(i,j,1));
        if (stimulusStruct.imgFin(i,j,1) < 0) || (stimulusStruct.imgFin(i,j,1) > 255)
            disp(stimulusStruct.imgFin(i,j,1))
        end
        stimulusStruct.imgFin(i,j,2)=(255-stimulusStruct.imgFin(i,j,2));
        if (stimulusStruct.imgFin(i,j,2) < 0) || (stimulusStruct.imgFin(i,j,2) > 255)
            disp(stimulusStruct.imgFin(i,j,2))
        end
        stimulusStruct.imgFin(i,j,3)=(255-stimulusStruct.imgFin(i,j,3));
        if (stimulusStruct.imgFin(i,j,3) < 0) || (stimulusStruct.imgFin(i,j,3) > 255)
            disp(stimulusStruct.imgFin(i,j,3))
        end

        % Inverse every expanding frame in the loom
        for k = 1:length(stimulusStruct.imgCell)
            temp_a = (255-stimulusStruct.imgCell{k,1}(i,j,1));
            temp_c = (255-stimulusStruct.imgCell{k,1}(i,j,2));
            temp_b = (255-stimulusStruct.imgCell{k,1}(i,j,3));

            stimulusStruct.imgCell{k,1}(i,j,1) = temp_a;
            stimulusStruct.imgCell{k,1}(i,j,2) = temp_b;
            stimulusStruct.imgCell{k,1}(i,j,3) = temp_c;

        end
    end
end

disp(string(datetime('now')))

% Older code below in case it is useful at some later point in time

% clc
% 
% disp(string(datetime('now')))
% 
% for i = 1:768
%     disp_Reset_flg = 1;
%     disp_Fin_flg = 1;
%     disp_Cell_flg = 1;
%     for j = 1:1024
%         
%         if ~(stimulusStruct_working.imgReset(i,j,1)-255 == stimulusStruct_broken.imgReset(i,j,1)) && disp_Reset_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgReset(i,j,1)), " | Broken Value: ", int2str(stimulusStruct_broken.imgReset(i,j,1))))
%             disp(append("imgReset pixel 1, ",int2str(i),", ",int2str(j)))
% %             disp_Reset_flg = 0;
%         end
%         if ~(stimulusStruct_working.imgReset(i,j,2)-255 == stimulusStruct_broken.imgReset(i,j,2)) && disp_Reset_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgReset(i,j,2)), " | Broken Value: ", int2str(stimulusStruct_broken.imgReset(i,j,2))))
%             disp(append("imgReset pixel 2, ",int2str(i),", ",int2str(j)))
% %             disp_Reset_flg = 0;
%         end
%         if ~(stimulusStruct_working.imgReset(i,j,3)-255 == stimulusStruct_broken.imgReset(i,j,3)) && disp_Reset_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgReset(i,j,1)), " | Broken Value: ", int2str(stimulusStruct_broken.imgReset(i,j,1))))
%             disp(append("imgReset pixel 3, ",int2str(i),", ",int2str(j)))
% %             disp_Reset_flg = 0;
%         end
% 
%         if ~(stimulusStruct_working.imgFin(i,j,1) == stimulusStruct_broken.imgFin(i,j,1)) && disp_Fin_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgFin(i,j,1)), " | Broken Value: ", int2str(stimulusStruct_broken.imgFin(i,j,1))))
%             disp(append("imgFin pixel 1, ",int2str(i),", ",int2str(j)))
% %             disp_Fin_flg = 0;
%         end
%         if ~(stimulusStruct_working.imgFin(i,j,2) == stimulusStruct_broken.imgFin(i,j,2)) && disp_Fin_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgFin(i,j,2)), " | Broken Value: ", int2str(stimulusStruct_broken.imgFin(i,j,2))))
%             disp(append("imgFin pixel 2, ",int2str(i),", ",int2str(j)))
% %             disp_Fin_flg = 0;
%         end
%         if ~(stimulusStruct_working.imgFin(i,j,3) == stimulusStruct_broken.imgFin(i,j,3)) && disp_Fin_flg
%             disp(append("Working Value: ", int2str(stimulusStruct_working.imgFin(i,j,3)), " | Broken Value: ", int2str(stimulusStruct_broken.imgFin(i,j,3))))
%             disp(append("imgFin pixel 3, ",int2str(i),", ",int2str(j)))
% %             disp_Fin_flg = 0;
%         end
% 
% 
%         for k = 1:55
%             if ~(stimulusStruct_working.imgCell{k,1}(i,j,1) == stimulusStruct_broken.imgCell{k,1}(i,j,1)) && disp_Cell_flg
%                 disp(append("Working Value: ", int2str(stimulusStruct_working.imgCell{k,1}(i,j,1)), " | Broken Value: ", int2str(stimulusStruct_broken.imgCell{k,1}(i,j,1))))
%                 disp(append("imgCell pixel 1, ",int2str(k),", ",int2str(i),", ",int2str(j)))
% %                 disp_Cell_flg = 0;
%             end
%             if ~(stimulusStruct_working.imgCell{k,1}(i,j,2) == stimulusStruct_broken.imgCell{k,1}(i,j,2)) && disp_Cell_flg
%                 disp(append("Working Value: ", int2str(stimulusStruct_working.imgCell{k,1}(i,j,2)), " | Broken Value: ", int2str(stimulusStruct_broken.imgCell{k,1}(i,j,2))))
%                 disp(append("imgCell pixel 2, ",int2str(k),", ",int2str(i),", ",int2str(j)))
% %                 disp_Cell_flg = 0;
%             end
%             if ~(stimulusStruct_working.imgCell{k,1}(i,j,3) == stimulusStruct_broken.imgCell{k,1}(i,j,3)) && disp_Cell_flg
%                 disp(append("Working Value: ", int2str(stimulusStruct_working.imgCell{k,1}(i,j,3)), " | Broken Value: ", int2str(stimulusStruct_broken.imgCell{k,1}(i,j,3))))
%                 disp(append("imgCell, ",int2str(k),", ",int2str(i),", ",int2str(j)))
% %                 disp_Cell_flg = 0;
%             end
% 
%         end
%     end
% end
% 
% disp(string(datetime('now')))