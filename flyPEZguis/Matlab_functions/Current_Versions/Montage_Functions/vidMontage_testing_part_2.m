function [frmFullB,textFrm] = vidMontage_testing_part_2(usable_data,flyPosX,flyPosY,vidObjCutrate,vidObjSupplement,montFrmCt,vidList,frmBounds,frameReferenceMesh,textBase,cutRateOps)
    vidCount= sum(cellfun(@(x) ~isempty(x),vidObjCutrate));
    all_markers = [];       all_trk_pts = [];
    all_stimuli = cell(vidCount,1);
    all_wall_pos = cell(vidCount,1);
    for iterF = cutRateOps
        frmFullA = baseFrame;
        frmFullB = baseFrame;
        for iterM = 1:vidCount
            tracking_done = 0;
            videoID = vidList{iterM};
            
            frmRef = frmBounds{iterM}(iterF);
            frameRead = frameReferenceMesh{iterM}(1,(frmRef));
            readObjRef = frameReferenceMesh{iterM}(2,(frmRef));
            
            if readObjRef == 1
                frmA = read(vidObjCutrate{iterM},frameRead);
            else
                frmA = read(vidObjSupplement{iterM},frameRead);
            end

            %%
            tI = log(double(frmA)+15);
            frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
            [~,frm_graymap] = gray2ind(frmAdj,256);
            tol = [0 0.9999];
            gammaAdj = 0.75;
            lowhigh_in = stretchlim(frmAdj,tol);
            lowhigh_in(1) = 0.01;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remap = uint8(frm_remap(:,1).*255);
            frmA = intlut(frmAdj,frm_remap);
            
            %frmA = frmA(:,:,1);            
            
            vidWidth = vidObjCutrate{iterM}.Width;
            vidHeight = vidObjCutrate{iterM}.Height;
            offset = vidHeight - vidWidth;

            top_data = usable_data(videoID,:).top_points_and_thetas{1};
            tracking_point = usable_data(videoID,:).tracking_point{1};
            try
                top_data = top_data(frmRef,1:2);
                %tracking_done = 0;
            catch
                tracking_done = 1;
            end
                        
            stim_pos = frmBounds{iterM}(1) + framesBeforeStim;
%            x_center = round(flyPosX{iterM}(stim_pos));            
            x_center = round(flyPosX{iterM});
            if strcmp(view_opt,'top')
                if flyPosY{iterM} > 192
                    if tracking_done == 0
                        top_data(2) = 192-(flyPosY{iterM} - top_data(2));
                        marker_data = round(top_data);
                    end
                    frmA(((flyPosY{iterM}+1):end),:,:) = [];
                    frmA(1:(flyPosY{iterM} - 192),:,:) = [];
                else
                    frmA = [zeros(192-flyPosY{iterM},size(frmA,2));frmA];    
                end   
                %frmA = insertMarker(frmA,[round(top_data(2))-192 round(top_data(1))],'o','color',rgb('red'),'size',50);                
            elseif strcmp(view_opt,'bottom') && strcmp(rotate_opt,'none')
                bottom_data = usable_data(videoID,:).bot_points_and_thetas{1};
                if tracking_done == 0
                    bot_data = bottom_data(frmRef,1:2);
                    bot_data(2) = offset + bot_data(2);
                end

                bot_y_pos = round(bottom_data(stim_pos,2));                
                bot_y_pos = offset + bot_y_pos;
                                
                if bot_y_pos +(192/2) > 832      %cuts off at bottom
                    frmA(1: (bot_y_pos-(192/2)),:) = [];
                    frmA = [zeros(192-size(frmA,1),size(frmA,2));frmA];    
                else
                    frmA = frmA((bot_y_pos-(192/2)) : (bot_y_pos+(190/2)) ,:);
                end
            elseif strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
                bottom_data = usable_data(videoID,:).bot_points_and_thetas{1};
                if tracking_done == 0
                    bot_data = bottom_data(frmRef,1:2);
                    bot_data(2) = offset + bot_data(2);
                    tracking_point(2) = offset + tracking_point(2);
                end

                bot_y_pos = round(bottom_data(stim_pos,2));
                bot_y_pos = offset + bot_y_pos;                
                
%                rotate_amount = 270-(bottom_data(stim_pos,3).*180/pi);
                rotate_amount = 90-(bottom_data(stim_pos,3).*180/pi);
                stimuli_pos = (usable_data.VidStat_Stim_Azi(iterM) + 2*pi) .* 180/pi + rotate_amount;
                %stim_range = ((stimuli_pos-5):(stimuli_pos+5)).*pi/180;
                stim_range = stimuli_pos.*pi/180;
                [stim_x,stim_y] = pol2cart(stim_range,(192/2));     %-96 to 96 circle
                stim_y = stim_y *-1;
                stim_x = stim_x+(192/2);        %translate into 0 - 192
                stim_y = stim_y+(192/2);        %translate into 0 - 192
               
                
                all_stimuli{iterM} = [{stim_x},{stim_y}];
                
                if bot_y_pos + 250 > 832      %cuts off at bottom
                    frmA = frmA((bot_y_pos - 250) : end,:,:);
                    zero_pad = zeros(501-size(frmA,1),size(frmA,2),size(frmA,3));
                    frmA = [frmA;zero_pad];      
                    if tracking_done == 0
                        bot_data(2) = 250-(bot_y_pos-bot_data(2));
                        tracking_point(2) = 250-(bot_y_pos-tracking_point(2));
                    end
                else
                    frmA = frmA((bot_y_pos-250) : (bot_y_pos+250) ,:,:);
                    if tracking_done == 0
                        bot_data(2) = bot_data(2)-(bot_y_pos-250);
                        tracking_point(2) = tracking_point(2)-(bot_y_pos-250);
                    end
                end                
            end

            if strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
                if x_center - 250 <= 0
                    zero_pad = zeros(size(frmA,1),250-x_center,size(frmA,3));
                    if tracking_done == 0
                        bot_data(1) = 250-x_center+bot_data(1);
                        tracking_point(1) = 250-x_center+tracking_point(1);
                    end
                    frmA = [zero_pad,frmA];
                    if size(frmA,2) < 501
                        zero_pad = zeros(size(frmA,1),501-size(frmA,2),size(frmA,3));
                        frmA = [frmA,zero_pad];
                    else
                        frmA(:,502:end,:) = [];
                    end
                else
                    frmA(:,1:(x_center - 249),:) = [];
                    if tracking_done == 0
                        bot_data(1) = bot_data(1) - (x_center - 249);
                        tracking_point(1) = tracking_point(1) - (x_center - 249);
                    end
                    zero_pad = zeros(size(frmA,1),501-size(frmA,2),size(frmA,3));
                    frmA = [frmA,zero_pad];
                end
                if p.Results.Show_Wall == true
                    wall_width_loc = get_wall_pos(photoStimName);
                    wall_width_loc = str2double(wall_width_loc);
                    % switch 180 and 0 for wall positions
                    if wall_width_loc == 0
                        wall_width_loc = 180;
                    elseif wall_width_loc == 180
                        wall_width_loc = 0;
                    end
                    switch wall_width_loc
                        case 0
                        case 90
                        case 180
                            wall_y = ((250-15):(250+15))';
                            wall_x = ones(length(wall_y),1)*150;
                        case 270
                    end                    
                    rot_wall_data = rotation([wall_x-251 wall_y-251],[0 0],-rotate_amount,'degree');
                end                
                
                frmA_rot = imrotate(frmA,rotate_amount);
                rot_size = round(size(frmA_rot)/2);
                frmA = frmA_rot((rot_size(1)-(192/2)):((rot_size(1)+(192/2))-1),(rot_size(1)-(192/2)):((rot_size(1)+(192/2))-1),:);                
                if tracking_done == 0
                    rot_bot_data = rotation(bot_data-251,[0 0],-rotate_amount,'degree');
                    rot_trk_data = rotation(tracking_point-251,[0 0],-rotate_amount,'degree');
                    
                    rot_bot_data = rot_bot_data + rot_size(1);
                    rot_bot_data(1) = rot_bot_data(1) - (rot_size(1)-(192/2));
                    rot_bot_data(2) = rot_bot_data(2) - (rot_size(1)-(192/2));
                    
                    rot_trk_data = rot_trk_data + rot_size(1);
                    rot_trk_data(1) = rot_trk_data(1) - (rot_size(1)-(192/2));
                    rot_trk_data(2) = rot_trk_data(2) - (rot_size(1)-(192/2));
                    
                    marker_data = rot_bot_data;
                    track_point = rot_trk_data;
                end
                rot_wall_data = rot_wall_data + rot_size(1);
                rot_wall_data(:,1) = rot_wall_data(:,1) - (rot_size(1)-(192/2));
                rot_wall_data(:,2) = rot_wall_data(:,2) - (rot_size(1)-(192/2));
                all_wall_pos{iterM} = [{rot_wall_data(:,1)},{rot_wall_data(:,2)}];
            else
                warning('ever do this section?');
                if x_center - (192/2) <= 0
                    frmA = frmA(:,1:(x_center+(192/2)));
                    frmA = [zeros(size(frmA,1),192-size(frmA,2)),frmA]; %#ok<*AGROW>
                elseif x_center + (192/2) > 384
                    frmA = frmA(:,(x_center-(192/2):end));
                    frmA = [frmA,zeros(size(frmA,1),192-size(frmA,2))];
                    if tracking_done == 0
                        marker_data(1) = marker_data(1) - (x_center-(192/2));
                        track_point(1) = track_point(1) - (x_center-(192/2));
                    end
                else
                    frmA = frmA(:,(x_center-(192/2)):(x_center+(192/2)));
                    if tracking_done == 0
                        marker_data(1) = marker_data(1) - (x_center-(192/2));
                        track_point(1) = track_point(1) - (x_center-(192/2));
                    end
                end
            end
            dim_test = size(frmA);
            if dim_test(2) > 192
                frmA(:,end) = [];
            end
            if tracking_done == 1
                frmA = uint8(zeros(192));
            end
            
            x_pos = mod(iterM,10);
            y_pos = (floor((iterM)/10));
            if x_pos == 0
                y_pos = y_pos - 1;
                x_pos = 10;
            end
            
%            frmA = insertMarker(frmA,[round(marker_data(1)) round(marker_data(2))],'o','size',5,'color','red');
            
            try
                frmFullA(((192*(y_pos))+1):(192*(y_pos+1)),((192*(x_pos-1))+1):((192*(x_pos)))) = frmA(:,:,1);
                all_stimuli{iterM}{1} = all_stimuli{iterM}{1} + (192*(x_pos-1));
                all_stimuli{iterM}{2} = all_stimuli{iterM}{2} + (192*(y_pos));
                
                all_wall_pos{iterM}{1} = all_wall_pos{iterM}{1} + (192*(x_pos-1));
                all_wall_pos{iterM}{2} = all_wall_pos{iterM}{2} + (192*(y_pos));
                
                
                if tracking_done == 0
                    marker_data(1) = (192*(x_pos-1)) + marker_data(1);       marker_data(2) = (192*(y_pos)) + marker_data(2);
                    track_point(1) = (192*(x_pos-1)) + track_point(1);       track_point(2) = (192*(y_pos)) + track_point(2);
                end
            catch
                warning('mistake')
            end
            if tracking_done == 0
                all_markers = [all_markers;round(marker_data)];            
                all_trk_pts = [all_trk_pts;round(track_point)];
            end
%            all_tracking_center
%            all_tracking_start_pt
            %frmFullA(yRefA:yRefB,xRefA:xRefB) = frmA;            
            frmFullB = max(frmFullA,frmFullB);
        end
        %%
        formatSa = ['%0' num2str(numel(num2str(round(montFrmCt/rateFactor)))) 's'];
        formatSb = ['%0' num2str(numel(num2str(montFrmCt))) 's'];
        labelOps = {sprintf('%04s',num2str(round(video_pulse(iterF))))
            sprintf(formatSa,num2str(round(iterF/rateFactor)))
            sprintf(formatSb,num2str(iterF))};
%        labelPos = {[0.23 0.9],      [0.565 0.9],         [0.85 0.9]};
        labelPos = {[0.175 0.9],      [0.510 0.9],         [0.90 0.9]};
        textFrm = textBase;
        kern = 0.5;
        for iterL = 1:3
            textFrm = textN2im_v2(textFrm,labelOps(iterL),fontSz,...
                labelPos{iterL},'right',kern);
        end

        frmFullC = [textFrm*0.8;frmFullB];        frmFullC(end-1:end,:) = 100;        frmFullC((1060-192):end,:,:) = [];               
        frmFullD = [repmat(frmFullC,[1 1 3]);graphBase];
        
        frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF),:) = 235;
        frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF)+1,:) = 235;

        if p.Results.Show_Tracked == true
            frmFullD = insertMarker(frmFullD,[all_markers(:,1) all_markers(:,2)+100],'o','size',5,'color','red');       %need to offset y_cord by size ot textfrm (100)
        end
%        frmFullD = insertMarker(frmFullD,[all_trk_pts(:,1) all_trk_pts(:,2)+100],'o','size',5,'color','green');       %need to offset y_cord by size ot textfrm (100)
        for iterM = 1:length(all_stimuli)
            if p.Results.Show_Stimuli == true
                frmFullD = insertMarker(frmFullD,[all_stimuli{iterM}{1}' all_stimuli{iterM}{2}'+100],'o','size',5,'color','blue');       %need to offset y_cord by size ot textfrm (100)
            end
        
            
            x_pos = mod(iterM,10);
            y_pos = (floor((iterM)/10));
            if x_pos == 0
                y_pos = y_pos - 1;
                x_pos = 10;
            end

            if p.Results.Show_Grid == true
%                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 196+192*(y_pos) 192*(x_pos) 196+192*(y_pos)],'LineWidth',1);
%                frmFullD = insertShape(frmFullD, 'line', [96+192*(x_pos-1) 100+192*(y_pos) 96+192*(x_pos-1) 100+192*(y_pos+1)],'LineWidth',1);

                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos) 192*(x_pos) 100+192*(y_pos)],'LineWidth',1,'color','red');                
                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos+1)   192*(x_pos) 100+192*(y_pos+1)],'LineWidth',1,'color','red');
              
                frmFullD = insertShape(frmFullD, 'line', [0+192*(x_pos-1)  100+192*(y_pos) 0+192*(x_pos-1)  100+192*(y_pos+1)],'LineWidth',1,'color','red');
                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos)  100+192*(y_pos) 192*(x_pos)  100+192*(y_pos+1)],'LineWidth',1,'color','red');
            end
            if p.Results.Show_Wall == true
                wall_min_x = min(all_wall_pos{iterM}{1});                   wall_max_x = max(all_wall_pos{iterM}{1});
                wall_min_y = min(all_wall_pos{iterM}{2})+100;               wall_max_y = max(all_wall_pos{iterM}{2})+100;
                
                if wall_max_y > 100+192*(y_pos+1)
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100) - (wall_max_y - (100+192*(y_pos+1)));
                elseif wall_min_y < 100+192*(y_pos)
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100) + (100+192*(y_pos) -  wall_min_y);
                else
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100);
                end    
                if wall_max_x >  192*(x_pos)
                     all_wall_pos{iterM}{1} = (all_wall_pos{iterM}{1}) - (wall_max_x - 192*(x_pos));
                elseif wall_min_x < 192*(x_pos-1)
                    warning('need to do');
                end
                
                frmFullD = insertShape(frmFullD, 'line', [all_wall_pos{iterM}{1}(1) all_wall_pos{iterM}{2}(1) all_wall_pos{iterM}{1}(end) all_wall_pos{iterM}{2}(end)],'LineWidth',1,'color','magenta');
            end   
        end
        try
            fprintf('Writting frame %5.0f out of %5.0f\n',iterF,max(cutRateOps));
            writeVideo(writeObj,frmFullD)
        catch
            warning('why')
        end
    end
end