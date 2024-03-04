%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function take_off_pct_genotype(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;        
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
%        combo_str = cellfun(@(x,y,z,a) sprintf('%s :: %s\n %s Elevation :: %s',x,y,z,a),Parent_A,Parent_B,exp_info.Stimuli_Type,exp_info.Elevation,'uniformoutput',false);
        combo_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_str = unique(combo_str);
        
        figure
        index = 1;
        for iterZ = 1:length(uni_str)
       
            parent_logic = ismember(combo_str,uni_str{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];

            trig_stim_angle = cell2mat(good_data.stimulus_azimuth).*180/pi + 360;            fly_detect = good_data.fly_detect_azimuth+360; 
            trig_stim_angle =  rem(rem(trig_stim_angle,360)+360,360);                        fly_detect =  rem(rem(fly_detect,360)+360,360);
            
            if ~isempty(strfind(uni_str{iterZ},'UAS_Chrimson_Venus_X_0070VZJ_K_45195'))
                in_range_logic = true(height(good_data),1);            
            else
                stim_angle = abs(round((good_data.Stim_Offset_At_Stim_Start * 100000)) / 100000);
                angle_wanted = abs(round((trig_stim_angle - fly_detect)*100000)/100000);
            
            in_range_logic = stim_angle <= (angle_wanted + 15) & stim_angle >= (angle_wanted - 15);
            end
            
            filt_data = good_data(in_range_logic,:);
            [~,jump_logic] = get_jump_info(filt_data,1);
            
            total_counts = tabulate(abs(filt_data.Stim_Pos_At_Trigger));
            jump_counts = tabulate(abs(filt_data(jump_logic,:).Stim_Pos_At_Trigger));
                                   
            jump_pct(iterZ) = (jump_counts(:,2) ./ total_counts(:,2));
        end
        plot(1:1:length(jump_pct),jump_pct,'o','markersize',20,'color',rgb('blue'))
        set(gca,'ylim',[0 1.1],'Xtick',[],'Ytick',0:.1:1,'Ygrid','on','fontsize',12,'Xlim',[0.5 length(jump_pct)+0.5]);

        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        new_lines = Parent_A;
        y = repmat(y,length(new_lines),1);                           new_x_pos = 1:1:length(new_lines);
        hText = text(new_x_pos, y, new_lines,'parent',gca);                

        set(hText,'Rotation',45,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',10);        
    end
    function take_off_pct_protocol(hObj,~)
        new_flag = 0;
        
        selection =  get(hObj,'UserData');
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;        
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        Parent_B(cellfun(@(x) ~isempty(strfind(x,'CTRL_DL_1500090_0028FCF_DL_1500090')),Parent_B),:) = {'CTRL_DL_1500090'};
        
        if new_flag == 0
            proto_str = cellfun(@(x,y) sprintf('%s :: Azimuth :: %s',x,y),exp_info.Stimuli_Type,exp_info.Azimuth,'uniformoutput',false);
        elseif new_flag == 1
            proto_str = cellfun(@(x,y,z,a) sprintf('%s :: Azimuth :: %s :: Food Type :: %s\n%s',x,y,z,a),exp_info.Stimuli_Type,exp_info.Azimuth,exp_info.Food_Type,Parent_B,'uniformoutput',false);
        end
        uni_proto = unique(proto_str);
        
        parent_string = cellfun(@(x,y) sprintf('%s\n%s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        [parent_string,sort_idx] = sort(parent_string);
        exp_info = exp_info(sort_idx,:);
        
        figure
        index = 1;
        for iterZ = 1:length(uni_proto)
            subplot(2,2,index)            
            parent_logic = ismember(proto_str,uni_proto{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];

            trig_stim_angle = cell2mat(good_data.stimulus_azimuth).*180/pi + 360;            fly_detect = good_data.fly_detect_azimuth+360; 
            trig_stim_angle =  rem(rem(trig_stim_angle,360)+360,360);                        fly_detect =  rem(rem(fly_detect,360)+360,360);
            
            if ~isempty(strfind(uni_proto{iterZ},'None'))
                in_range_logic = true(height(good_data),1);
            else            
                stim_angle = abs(round((good_data.Stim_Offset_At_Stim_Start * 100000)) / 100000);
                angle_wanted = abs(round((trig_stim_angle - fly_detect)*100000)/100000);

                in_range_logic = stim_angle <= (angle_wanted + azi_off) & stim_angle >= (angle_wanted - azi_off);
            end
            
            filt_data = good_data(in_range_logic,:);
            [~,jump_logic] = get_jump_info(filt_data,1);
            
            exp_id = cellfun(@(x) x(29:44),filt_data.Properties.RowNames,'uniformoutput',false);
            pez_id = cellfun(@(x) x(8:14),filt_data.Properties.RowNames,'uniformoutput',false);

%             total_counts = tabulate(exp_id);
%             jump_counts = tabulate(exp_id(jump_logic));
%             
%             [~,locB] = ismember(jump_counts(:,1),total_counts(:,1));    jump_counts = jump_counts(locB,:);
%             [~,locB] = ismember(total_counts(:,1),get(exp_info,'ObsNames'));
%             
%             [~,new_sort] = sort(locB);

            if selection == 1
                [pez_counts,~,~,new_labels]  = crosstab(exp_id,pez_id);
                [jump_counts,~,~,jump_labels]  = crosstab(exp_id(jump_logic),pez_id(jump_logic));
                [~,sort_idx] = sort(new_labels(cellfun(@(x) ~isempty(x), new_labels(:,2)),2));            pez_counts = pez_counts(:,sort_idx);
                [~,sort_idx] = sort(jump_labels(cellfun(@(x) ~isempty(x), jump_labels(:,2)),2));          jump_counts = jump_counts(:,sort_idx);

                [~,sort_idx] = sort(new_labels(cellfun(@(x) ~isempty(x), new_labels(:,1)),1));            pez_counts = pez_counts(sort_idx,:);
                [~,sort_idx] = sort(jump_labels(cellfun(@(x) ~isempty(x), jump_labels(:,1)),1));          jump_counts = jump_counts(sort_idx,:);
            else
                pez_counts = tabulate(exp_id);                      jump_counts = tabulate(exp_id(jump_logic));                
                [~,sort_idx] = sort(pez_counts(:,1));               pez_counts = pez_counts(sort_idx,:);
                [~,sort_idx] = sort(jump_counts(:,1));              jump_counts = jump_counts(sort_idx,:);                
                
                new_labels = pez_counts(:,1);
                pez_counts = cell2mat(pez_counts(:,2));
                jump_counts = cell2mat(jump_counts(:,2));
            end
            
            if new_flag == 0
                [~,locB] = ismember(new_labels(:,1),get(exp_info,'ObsNames'));            
                [~,new_sort] = sort(locB);   
                new_labels = unique(parent_string,'stable');
                rotation = 0;
                align = 'center';  
                matching_data = true(1,length(new_labels));
            else
                [locA,locB] = (ismember(new_labels,get(exp_info,'ObsNames')));
                
                new_labels = exp_info(locB(locA),:).ParentA_name;
                [new_labels,new_sort] = sort(new_labels);   
                rotation = 45;
                align = 'right';    
                
                matching_data = ismember(unique(Parent_A),new_labels);
                new_pos = 1:1:length(unique(Parent_A));
            end
                        
            jump_pct = jump_counts ./ pez_counts;
            jump_pct = jump_pct(new_sort,:);    
            pez_counts = pez_counts(new_sort,:);

            if new_flag == 0
                hb = bar(jump_pct);
            else
                hb = bar(new_pos(matching_data),jump_pct);
            end
            
            
            if selection == 1
                set(hb(1),'facecolor',rgb('light red'),'edgecolor',rgb('black'));
                set(hb(2),'facecolor',rgb('light blue'),'edgecolor',rgb('black'));

                h_len = legend('Pez 3001','Pez 3002','location','North','Orientation','horizontal');
                set(h_len,'fontsize',12);   
            else
                 set(hb,'facecolor',rgb('light red'),'edgecolor',rgb('black'));
            end
            set(gca,'ylim',[0 1.1],'Xtick',[],'Ytick',0:.1:1,'Ygrid','on','fontsize',12);
            title(sprintf('%s',uni_proto{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',14);
            
            if new_flag == 0
                line([3.5 3.5],[0 1.1],'color',rgb('grey'),'linewidth',1)
            end
            
            hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
            xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
            y = repmat(y,length(new_labels),1);                          new_x_pos = 1:1:length(matching_data);
            hText = text(new_x_pos(matching_data), y, new_labels,'parent',gca);                

            set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',10.5);
            
            if selection == 1
                new_totals = reshape(pez_counts,1,10);
                for iterP = 1:5
                    text(iterP-.15,1.05,num2str(pez_counts(iterP,1)),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
                    text(iterP+.15,1.05,num2str(pez_counts(iterP,2)),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
                end
            else
                text_pos = new_x_pos(matching_data);
                
                for iterP = 1:length(pez_counts)
                    text(text_pos(iterP),1.05,num2str(pez_counts(iterP)),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
                end                
            end

            index = index + 1;
        end
    end
    function take_off_pct_by_azimuth(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;        
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        combo_str = cellfun(@(x,y,z,a) sprintf('%s :: %s\n %s Elevation :: %s',x,y,z,a),Parent_A,Parent_B,exp_info.Stimuli_Type,exp_info.Elevation,'uniformoutput',false);
        uni_str = unique(combo_str);
        uni_azi = unique(str2double(exp_info.Azimuth));
        uni_azi = [uni_azi;uni_azi*-1];
        uni_azi = unique(uni_azi);
        
        azi_width = azi_off;
        azi_split = (-180-(azi_width/2)):azi_width:(180+(azi_width/2));    
        new_azi_split = azi_split+.0001;       
        azi_split = -180:azi_width:180;    
        azi_logic = ismember(azi_split,uni_azi);
        
        angle_splits = sort([(-180:azi_width:180)-azi_off,(-180:azi_width:180)+azi_off]);
        angle_index = -180:azi_width:180;
        
        figure
        for iterZ = 1:length(uni_str)
            subplot(2,2,iterZ)
            parent_logic = ismember(combo_str,uni_str{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];
            [stim_angle,jump_logic] = get_jump_info(good_data,1);
            stim_angle = (round((stim_angle * 10000)) / 10000);
            angle_wanted = (round(((cell2mat(good_data.stimulus_azimuth).*180/pi+360) - good_data.fly_detect_azimuth)*100000)/100000);            
                       
            if cellfun(@(x) ~isempty(strfind(x,'Elevation :: 90')),uni_str(iterZ))
                in_range_logic = true(length(stim_angle),1);
                azi_logic = true(length(azi_split),1);
            else
                in_range_logic = stim_angle <= (angle_wanted + azi_off) & stim_angle >= (angle_wanted - azi_off);            
            end
            
            index = 1;
            for iterS = angle_index
                tot_counts(index) = sum(stim_angle(in_range_logic) >= (angle_index(index)-azi_off) & stim_angle(in_range_logic) <= (angle_index(index)+azi_off));
                jump_counts(index) = sum(stim_angle(jump_logic & in_range_logic) >= (angle_index(index)-azi_off) & stim_angle(jump_logic & in_range_logic) <= (angle_index(index)+azi_off));
                index = index + 1;
            end
                                   
            tot_counts = histc((stim_angle(in_range_logic)),new_azi_split);
            jump_counts = histc((stim_angle(jump_logic & in_range_logic)),new_azi_split);
            
            jump_pct = (jump_counts(azi_logic,end) ./ tot_counts(azi_logic,end))';
            keep_counts = tot_counts(azi_logic,end) >= 15;


            set(gca,'Ylim',[0 1],'nextplot','add','fontsize',12);   
            plot(azi_split(keep_counts),jump_pct(keep_counts),'ko','linewidth',1.5,'markersize',15);  %All            
            
%             new_range = azi_split(azi_logic & keep_counts);
%             p = polyfit(azi_split(azi_logic & keep_counts),jump_pct(keep_counts),4);       new_x = min(new_range):.5:max(new_range);   new_y = polyval(p,new_x);
%             plot(new_x,new_y,'-r','linewidth',1.2);

            pct_in_box = (tot_counts((azi_logic & keep_counts),end) ./ sum( tot_counts))*100;

            title(sprintf('%s',uni_str{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',14);
%            text(azi_split(azi_logic & keep_counts),repmat(1.05,sum(azi_logic & keep_counts),1),arrayfun(@(x,y) sprintf('%4.0f\n%2.4f%%',x,y), tot_counts((azi_logic & keep_counts),end),pct_in_box,'uniformoutput',false),...
%                'Interpreter','none','HorizontalAlignment','center','fontsize',15);
            
            set(gca,'Xlim',[-105 105],'Ytick',0:.1:1,'Ygrid','on','Xtick',-90:azi_width:90,'fontsize',15,'Ylim',[0 1.1]);
            
            xlabel('Azimuth relative to fly at stim start (degrees)','fontsize',16);
            ylabel('Jump Rate Percent','fontsize',12);
            for iterL = (-180+(azi_width/2)):azi_width:180
                line([iterL iterL],[0 1.1],'color',rgb('light grey'),'linewidth',.75)
            end
            line([-195 195],[1 1],'color',rgb('light grey'),'linewidth',.75)
            
%             p = polyfit(azi_split(keep_counts),jump_pct(keep_counts),1);
%             new_x = -90:1:90;       new_y = polyval(p,new_x);
%             plot(new_x,new_y)
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    function pathway_protocol(hObj,~)
        selection = get(hObj,'UserData');
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;        
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        Parent_B(cellfun(@(x) ~isempty(strfind(x,'CTRL_DL_1500090_0028FCF_DL_1500090')),Parent_B),:) = {'CTRL_DL_1500090'};
        
        proto_str = cellfun(@(x,y) sprintf('%s :: Azimuth :: %s',x,y),exp_info.Stimuli_Type,exp_info.Azimuth,'uniformoutput',false);
        uni_proto = unique(proto_str);
        
        parent_string = cellfun(@(x,y) sprintf('%s\n%s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        [parent_string,sort_idx] = sort(parent_string);
        exp_info = exp_info(sort_idx,:);
        
        figure
        index = 1;
        for iterZ = 1:length(uni_proto)
            subplot(2,2,index)            
            parent_logic = ismember(proto_str,uni_proto{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];

            trig_stim_angle = cell2mat(good_data.stimulus_azimuth).*180/pi + 360;            fly_detect = good_data.fly_detect_azimuth+360; 
            trig_stim_angle =  rem(rem(trig_stim_angle,360)+360,360);                        fly_detect =  rem(rem(fly_detect,360)+360,360);
            
            stim_angle = abs(round((good_data.Stim_Offset_At_Stim_Start * 100000)) / 100000);
            angle_wanted = abs(round((trig_stim_angle - fly_detect)*100000)/100000);
            
%            in_range_logic = stim_angle <= (angle_wanted + azi_off) & stim_angle >= (angle_wanted - azi_off);

            in_range_logic = true(height(good_data),1);
            
            filt_data = good_data(in_range_logic,:);
%            [~,jump_logic] = get_jump_info(filt_data,1);
            jump_logic = cellfun(@(x) ~isempty(x), filt_data.frame_of_leg_push);
            
            filt_data = filt_data(jump_logic,:);
            
            exp_id = cellfun(@(x) x(29:44),filt_data.Properties.RowNames,'uniformoutput',false);
            [~,locB] = ismember(exp_id,get(exp_info,'ObsNames'));
            new_labels = unique(parent_string,'stable');
            
            if selection == 1
                jump_frame = cellfun(@(x,y,z) (x-y-z)./6 ,filt_data.frame_of_take_off,filt_data.visStimFrameStart,filt_data.visStimFrameCount);
                ymin = -1 * ceil((unique(cell2mat(filt_data.visStimFrameCount))/6)/50)*50;
                set(gca,'Xtick',[],'Ylim',[ymin 200]);

                ax2 = axes('position',get(gca,'position'));
                hb = boxplot(gca,jump_frame,locB);
                ax1 = gca;

                set(hb,'linewidth',1.4);
                set(ax2,'YAxisLocation','Right','Ygrid','on','Ylim',[ymin 200],'Xtick',[])

                y_tick_lab = [10,15,20,30,60,90,180];
                if ymin == -500
                    y_tick = -40./tan(y_tick_lab .*pi/360);
                else
                    y_tick = -80./tan(y_tick_lab .*pi/360);
                end
                set(ax2,'Ytick',y_tick,'Yticklabel',y_tick_lab);
                ylabel(ax2,'Size of stimuli(degrees)','fontsize',10);

                set(ax1,'Xlim',[0 length(new_labels)+1]);
                for iterL = 50:50:200
                    line([0 length(new_labels)+1],[iterL iterL],'color',rgb('light grey'),'linewidth',.8,'parent',ax1);
                end
            else
                full_diff = cellfun(@(x,y) log((x-y)./6) ,filt_data.frame_of_take_off,filt_data.frame_of_wing_movement);
                hb = boxplot(gca,full_diff,locB,'position',unique(locB));
                set(hb,'linewidth',1.4);
                ax1 = gca;  
                set(gca,'Xtick',[],'Ylim',[0 7],'nextplot','add');
                rand_scat = (rand(length(full_diff),1)*.5-.2)+locB;
                line([min(locB)-2 max(locB)+2],[log(7) log(7)],'color',rgb('dark green'),'linewidth',1.2,'parent',gca);
                
                scatter(rand_scat,full_diff,50,rgb('orange'),'filled');
            end
            
            hxLabel = get(ax1,'XLabel');                                 set(hxLabel,'Units','data');
            xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
            y = repmat(y,length(new_labels),1);                          new_x_pos = unique(locB);
            hText = text(new_x_pos, y, new_labels,'parent',gca);                

            set(hText,'Rotation',0,'HorizontalAlignment','center','Color',rgb('black'),'Interpreter','none','fontsize',10.5);            
            title(sprintf('%s',uni_proto{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',14);
            index = index + 1;
        end
    end
    function new_pathway(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        
        new_parent_string = cellfun(@(x,y) sprintf('%s_%s',x,y),exp_info.ParentA_name,exp_info.ParentB_name,'uniformoutput',false);
        uni_parent = unique(new_parent_string);
        figure
        for iterS = 1:length(uni_parent)
            subplot(2,3,iterS)
            parent_logic = ismember(new_parent_string,uni_parent{iterS});
            good_data = vertcat(combine_data(parent_logic).Complete_usuable_data);            

            jumping_data = good_data(cellfun(@(x) ~isnan(x), good_data.frame_of_leg_push),:);
            supplement_logic = cellfun(@(x,y) ismember(x,y),jumping_data.frame_of_take_off,jumping_data.supplement_frame_reference);
            jumping_data = jumping_data(supplement_logic,:);       
            leg_extension = cellfun(@(x,y) (x-y)./6,jumping_data.frame_of_take_off,jumping_data.frame_of_leg_push);        

            wing_pt1 = cellfun(@(x,y) (x-y)./6,jumping_data.frame_of_leg_push,jumping_data.frame_of_wing_movement);        
            leg_pt1 = cellfun(@(x,y) (x-y)./6,jumping_data.wing_down_stroke,jumping_data.frame_of_leg_push);        
            leg_pt2 = cellfun(@(x,y) (x-y)./6,jumping_data.frame_of_take_off,jumping_data.wing_down_stroke);       
            full_diff =  cellfun(@(x,y) (x-y)./6,jumping_data.frame_of_take_off,jumping_data.frame_of_wing_movement);        

%            bad_data = leg_pt1 == 0 | (wing_pt1 == 0 | wing_pt1 >= 30);
            bad_data = leg_pt1 == 0;
            wing_pt1(bad_data) = [];                leg_pt1(bad_data) = [];                 full_diff(bad_data) = [];
            
            jump_count = histc(leg_extension,(1/6):(2/6):(10+1/6));
            jump_count = jump_count ./ sum(jump_count);
            bar((1/6):(2/6):(10+1/6),jump_count,'histc');
            set(gca,'Xlim',[2 8]);
        end
%         set(gca,'nextplot','add')
%         male_count = histc(leg_extension(strcmp(jumping_data.Gender,'Male')),0:(1/6):10);
%         female_count = histc(leg_extension(strcmp(jumping_data.Gender,'Female')),0:(1/6):10);
%         
%         male_bar = bar(0:(1/6):10,male_count,'histc');      set(male_bar,'facecolor',rgb('light blue'),'facealpha',0.5);
%         female_bar = bar(0:(1/6):10,female_count,'histc');  set(female_bar,'facecolor',rgb('light red'),'facealpha',0.5);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    function wsi = get_error_bars(jumpers,total)                      % adds error bars for control plot
        x = jumpers;
        n = total;
        alpha = .05;
        phat =  x./n;
        z=sqrt(2).*erfcinv(alpha);
        den=1+(z^2./n);xc=(phat+(z^2)./(2*n))./den;
        halfwidth=(z*sqrt((phat.*(1-phat)./n)+(z^2./(4*(n.^2)))))./den;
        wsi=[xc(:) xc(:)]+[-halfwidth(:) halfwidth(:)];
%        wsi = wsi .* 100;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
%% section of code for martin
    function test_data = shrink_genotypes(test_data,string_1,string_2)
        long_logic = cellfun(@(x) ~isempty(strfind(x,string_1)),test_data.ParentA_name);
        test_data.ParentA_name(long_logic) = repmat({string_2},sum(long_logic),1);

        long_logic = cellfun(@(x) ~isempty(strfind(x,string_1)),test_data.ParentB_name);
        test_data.ParentB_name(long_logic) = repmat({string_2},sum(long_logic),1);
        
    end
    function find_matching_data(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        exp_info = shrink_genotypes(exp_info,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)','DL_UAS_Kir21_3_0090');
        exp_info = shrink_genotypes(exp_info,'UAS_Chrimson_Venus_X_0070VZJ_K_45195','UAS_Chrimson_Venus_X_0070');
        exp_info = shrink_genotypes(exp_info,'20XUAS-CsChrimson-mVenus trafficked in attP18','UAS_Chrimson_Venus_X_0070');
        exp_info = shrink_genotypes(exp_info,'w+; UAS-cTNT E','UAS_TNT_2_0003');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        Parent_A_name = exp_info.ParentA_name;               Parent_B_name = exp_info.ParentB_name;
        
        chrim_logic = cellfun(@(x) length(x)==3,exp_info.Photo_Activation);
        exp_info(chrim_logic,:).Photo_Activation = cellfun(@(x) x{1},exp_info(chrim_logic,:).Photo_Activation,'uniformoutput',false);        
        
        uni_parent = unique(Parent_A_name);
        jump_pct_matrix = cell2table(cell(length(uni_parent),12));
        jump_pct_matrix.Properties.RowNames = uni_parent;
        jump_pct_matrix.Properties.VariableNames = [{'Chrim_20_1000_Total'},{'Chrim_20_1000_Jumpers'},{'Chrim_50_50_Total'},{'Chrim_50_50_Jumpers'},...
                                                    {'Kir_LV40_Azi45_Total'},{'Kir_LV40_Azi45_Jumpers'},{'TNT_LV40_Azi45_Total'},{'TNT_LV40_Azi45_Jumpers'},...;
                                                    {'Kir_LV40_Azi90_Total'},{'Kir_LV40_Azi90_Jumpers'},{'TNT_LV40_Azi90_Total'},{'TNT_LV40_Azi90_Jumpers'}];
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(Parent_A_name,uni_parent{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];
            in_range_logic = abs(good_data.Total_Movement) <= 15;
            good_data = good_data(in_range_logic,:);
                       
            [locA,locB] = ismember(cellfun(@(x) x(29:44),good_data.Properties.RowNames,'uniformoutput',false),get(exp_info,'ObsNames'));
            new_parent_B = Parent_B_name(locB(locA));
                        
            combo_proto = cell(height(good_data),1); 
            combo_proto(cellfun(@(x) ~isempty(x),good_data.photoStimProtocol)) = good_data(cellfun(@(x) ~isempty(x),good_data.photoStimProtocol),:).photoStimProtocol;
            
            loom_logic = cellfun(@(x) ~isempty(x),good_data.visStimProtocol);
            combo_proto(loom_logic) = cellfun(@(x,y,z) sprintf('%s :: %s :: Azimuth :: %2.0f',x,y,z),new_parent_B(loom_logic,:),good_data(loom_logic,:).visStimProtocol,num2cell(abs(good_data(loom_logic,:).Stim_Pos_At_Trigger)),'uniformoutput',false);
            
            remove_data = cellfun(@(x) isempty(x), combo_proto);
            good_data(remove_data,:) = [];
            combo_proto(remove_data,:) = [];
            
            [~,jump_logic] = get_jump_info(good_data,1);
            
            try
                total_table = tabulate(combo_proto);
                jump_table = tabulate(combo_proto(jump_logic));
            catch
                warning('error');
            end
            
            try
                jump_pct_matrix(iterZ,:).Chrim_20_1000_Total   = populate_matrix(total_table,'pulse_General_widthBegin1000_widthEnd1000_cycles1_intensity20');
                jump_pct_matrix(iterZ,:).Chrim_50_50_Total     = populate_matrix(total_table,'pulse_General_widthBegin50_widthEnd50_cycles1_intensity50');
                jump_pct_matrix(iterZ,:).Kir_LV40_Azi45_Total  = populate_matrix(total_table,'DL_UAS_Kir21_3_0090 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 45');
                jump_pct_matrix(iterZ,:).Kir_LV40_Azi90_Total  = populate_matrix(total_table,'DL_UAS_Kir21_3_0090 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 90');
                jump_pct_matrix(iterZ,:).TNT_LV40_Azi45_Total  = populate_matrix(total_table,'UAS_TNT_2_0003 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 45');
                jump_pct_matrix(iterZ,:).TNT_LV40_Azi90_Total  = populate_matrix(total_table,'UAS_TNT_2_0003 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 90');                
                
                jump_pct_matrix(iterZ,:).Chrim_20_1000_Jumpers   = populate_matrix(jump_table,'pulse_General_widthBegin1000_widthEnd1000_cycles1_intensity20');
                jump_pct_matrix(iterZ,:).Chrim_50_50_Jumpers     = populate_matrix(jump_table,'pulse_General_widthBegin50_widthEnd50_cycles1_intensity50');
                jump_pct_matrix(iterZ,:).Kir_LV40_Azi45_Jumpers  = populate_matrix(jump_table,'DL_UAS_Kir21_3_0090 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 45');
                jump_pct_matrix(iterZ,:).Kir_LV40_Azi90_Jumpers  = populate_matrix(jump_table,'DL_UAS_Kir21_3_0090 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 90');
                jump_pct_matrix(iterZ,:).TNT_LV40_Azi45_Jumpers  = populate_matrix(jump_table,'UAS_TNT_2_0003 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 45');
                jump_pct_matrix(iterZ,:).TNT_LV40_Azi90_Jumpers  = populate_matrix(jump_table,'UAS_TNT_2_0003 :: loom_10to180_lv40_blackonwhite.mat :: Azimuth :: 90');                
                
             catch
                warning('mistake?')
            end
        end
        
        figure
%        title(sprintf('Scatter plot of Jump rates for Genotypes that saw \n LV 40 Looming stimuli at Azimuth 0 and 50%% intensity Chrimson for 50 ms'),'fontsize',15,...
%            'HorizontalAlignment','center','Color',rgb('black'),'Interpreter','none');                    
        
        
        make_scatter_plot(1,jump_pct_matrix.Kir_LV40_Azi45_Total,jump_pct_matrix.Kir_LV40_Azi45_Jumpers,jump_pct_matrix.Chrim_20_1000_Total,jump_pct_matrix.Chrim_20_1000_Jumpers)
        title('Kir LV: 40 Azi: 45 vs Chrim 20% 1000ms')
        make_scatter_plot(2,jump_pct_matrix.Kir_LV40_Azi45_Total,jump_pct_matrix.Kir_LV40_Azi45_Jumpers,jump_pct_matrix.Chrim_50_50_Total,jump_pct_matrix.Chrim_50_50_Jumpers)
        title('Kir LV: 40 Azi: 45 vs Chrim 50% 50ms')        
        make_scatter_plot(3,jump_pct_matrix.Kir_LV40_Azi90_Total,jump_pct_matrix.Kir_LV40_Azi90_Jumpers,jump_pct_matrix.Chrim_20_1000_Total,jump_pct_matrix.Chrim_20_1000_Jumpers)
        title('Kir LV: 40 Azi: 90 vs Chrim 20% 1000ms')
        make_scatter_plot(4,jump_pct_matrix.Kir_LV40_Azi90_Total,jump_pct_matrix.Kir_LV40_Azi90_Jumpers,jump_pct_matrix.Chrim_50_50_Total,jump_pct_matrix.Chrim_50_50_Jumpers)
        title('Kir LV: 40 Azi: 90 vs Chrim 50% 50ms')
        
        make_scatter_plot(5,jump_pct_matrix.TNT_LV40_Azi45_Total,jump_pct_matrix.TNT_LV40_Azi45_Jumpers,jump_pct_matrix.Chrim_20_1000_Total,jump_pct_matrix.Chrim_20_1000_Jumpers)
        title('TNT LV: 40 Azi: 45 vs Chrim 20% 1000ms')
        make_scatter_plot(6,jump_pct_matrix.TNT_LV40_Azi45_Total,jump_pct_matrix.TNT_LV40_Azi45_Jumpers,jump_pct_matrix.Chrim_50_50_Total,jump_pct_matrix.Chrim_50_50_Jumpers)
        title('TNT LV: 40 Azi: 45 vs Chrim 50% 50ms')        
        make_scatter_plot(7,jump_pct_matrix.TNT_LV40_Azi90_Total,jump_pct_matrix.TNT_LV40_Azi90_Jumpers,jump_pct_matrix.Chrim_20_1000_Total,jump_pct_matrix.Chrim_20_1000_Jumpers)
        title('TNT LV: 40 Azi: 90 vs Chrim 20% 1000ms')
        make_scatter_plot(8,jump_pct_matrix.TNT_LV40_Azi90_Total,jump_pct_matrix.TNT_LV40_Azi90_Jumpers,jump_pct_matrix.Chrim_50_50_Total,jump_pct_matrix.Chrim_50_50_Jumpers)
        title('TNT LV: 40 Azi: 90 vs Chrim 50% 50ms')        
    end
    function value = populate_matrix(test_table,test_string)
        value = test_table(cellfun(@(x) ~isempty(strfind(x,test_string)),test_table(:,1)),2);
        if isempty(value)
            value = num2cell(0);
        end
    end
    function make_scatter_plot(index,kir_total,kir_jump,chrim_total,chrim_jump)
        subplot(4,2,index)
        kir_logic = cell2mat(kir_total) >= 50;
        kir_pct = cellfun(@(x,y) x./y, kir_jump(kir_logic),kir_total(kir_logic));
        chrim_pct = cellfun(@(x,y) x./y, chrim_jump(kir_logic),chrim_total(kir_logic));
        
        scatter(kir_pct,chrim_pct,50,rgb('blue'),'filled');
        set(gca,'Xlim',[0 1],'Ylim',[0 1],'Xtick',0:.1:1,'Ytick',0:.1:1); grid on;
        ylabel('UAS_Chrimson_Venus_X_0070','fontsize',15,'HorizontalAlignment','center','Color',rgb('black'),'Interpreter','none');
        xlabel('DL_UAS_Kir21_3_0090','fontsize',15,'HorizontalAlignment','center','Color',rgb('black'),'Interpreter','none');
        
        add_error_bars(gca,kir_total(kir_logic),kir_jump(kir_logic),chrim_total(kir_logic),chrim_jump(kir_logic));
    end
    function add_error_bars(curr_plot,kir_total,kir_jump,chrim_total,chrim_jump)
        wsi_kir = get_error_bars(cell2mat(kir_jump),cell2mat(kir_total));
        wsi_chrim = get_error_bars(cell2mat(chrim_jump),cell2mat(chrim_total));
        
        kir_pct = cellfun(@(x,y) x./y, kir_jump,kir_total);        chrim_pct = cellfun(@(x,y) x./y, chrim_jump,chrim_total);
        
        for iterZ = 1:length(chrim_pct)
            line([wsi_kir(iterZ,1) wsi_kir(iterZ,2)],[chrim_pct(iterZ) chrim_pct(iterZ)],'parent',curr_plot,'linewidth',.7,'color',rgb('black'));
        end
        for iterZ = 1:length(kir_pct)
            line([kir_pct(iterZ) kir_pct(iterZ)],[wsi_chrim(iterZ,1) wsi_chrim(iterZ,2)],'parent',curr_plot,'linewidth',.7,'color',rgb('black'));
        end        
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    function take_off_pct_special(hObj,~)
        selection = get(hObj,'UserData');
        figure
        set(gca,'nextplot','add');
        total_pct = [];         total_proto = [];       total_counts = [];
        total_geno = [];        run_info = [];          all_diff = [];
        
       
        exp_info = vertcat(combine_data(:).parsed_data);
        for iterZ = 1:length(combine_data)
            good_data = [vertcat(combine_data(iterZ).Complete_usuable_data);vertcat(combine_data(iterZ).Videos_Need_To_Work);...
                vertcat(combine_data(iterZ).Vid_Not_Tracked);vertcat(combine_data(iterZ).Bad_Tracking)];
            
            good_data(good_data.trkEnd == 0 & cellfun(@(x) isempty(x), good_data.frame_of_leg_push),:) = [];
            

            if selection == 1
                run_ids = cellfun(@(x) x(1:23),good_data.Properties.RowNames,'uniformoutput',false);
            elseif selection == 2
                run_ids = cellfun(@(x) x(8:14),good_data.Properties.RowNames,'uniformoutput',false);
            elseif selection == 3
                good_data(strcmp(good_data.Gender,'Unknown'),:) = [];
                run_ids = good_data.Gender;
            end
            
            geno_id = unique(cellfun(@(x) x(33:40),good_data.Properties.RowNames,'uniformoutput',false));
            proto_id = unique(cellfun(@(x) x(41:44),good_data.Properties.RowNames,'uniformoutput',false));
            
            [~,jump_logic,rem_records,new_start] = get_jump_info(good_data);
            run_ids(rem_records) = [];            jump_logic(rem_records) = [];
            new_start(rem_records) = [];          good_data(rem_records,:) = [];
       
            leg_frame = good_data.frame_of_take_off;
            leg_frame(cellfun(@(x) isempty(x),leg_frame)) = num2cell(good_data.autoFot(cellfun(@(x) isempty(x),leg_frame)));
            true_jump = cell2mat(leg_frame) - new_start;
            
            ontime_logic = (true_jump >= 0) | isnan(true_jump);
            jump_logic(true_jump >= 6000) = false;      %any jumper after lights off is treated as non jump
                
            good_data = good_data(ontime_logic,:);          jump_logic = jump_logic(ontime_logic,:);
                        
            run_ids = run_ids(ontime_logic);
            
            total_table = tabulate(run_ids);
            jump_table = tabulate(run_ids(jump_logic));
            
            missing_run = total_table(~ismember(total_table(:,1),jump_table(:,1)),1);            missing_run = [missing_run,repmat({0},length(missing_run),2)];            
            jump_table = [jump_table;missing_run];           [~,locB] = ismember(total_table(:,1),jump_table(:,1));        jump_table = jump_table(locB,:);
            
            jump_pct = cellfun(@(x,y) (x ./ y)*100,jump_table(:,2),total_table(:,2));
%            plot(repmat(iterZ,length(jump_pct),1),jump_pct,'o')
            
            run_info = [run_info;jump_table(:,1)];
            total_pct = [total_pct;jump_pct];
            total_geno = [total_geno;repmat(geno_id,length(jump_pct),1)];
            total_proto = [total_proto;repmat(proto_id,length(jump_pct),1)];
            total_counts = [total_counts;[jump_table(:,2),total_table(:,2)]];
        end
        run_info = [run_info,total_geno,total_proto,num2cell(total_pct),total_counts];
        [~,sort_idx] = sort(cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),run_info(:,2),run_info(:,3),run_info(:,1),'uniformoutput',false));
        run_info = run_info(sort_idx,:);

        if selection == 1
            pez_list = cellfun(@(x) x(8:14),run_info(:,1),'uniformoutput',false);
        else
            pez_list = run_info(:,1);
        end
        
        uni_geno = unique(run_info(:,2),'stable');
        uni_proto = unique(run_info(:,3),'stable');
        
        [x_plot,y_plot] = split_fig(length(uni_geno));     %how many subplots to make
        for iterZ = 1:length(uni_geno)
           
            subplot(x_plot,y_plot,iterZ)
            geno_logic = ismember(run_info(:,2),uni_geno{iterZ});
%            [y_data,x_data,groups] = iosr.statistics.tab2box(cell2mat(total_proto(geno_logic)),total_pct(geno_logic),pez_list(geno_logic));
            [y_data,x_data,~] = iosr.statistics.tab2box(cell2mat(run_info(geno_logic,3)),cell2mat(run_info(geno_logic,4)));
            
            new_labels = convert_labels(x_data,'Intensity',exp_info);
            [new_labels,sort_idx] = sort(new_labels);
            x_data = x_data(sort_idx);
            y_data = y_data(:,sort_idx,:);
            
            filt_run_info = run_info(geno_logic,:);
            
            jump_counts = arrayfun(@(x) cell2mat(filt_run_info(ismember(filt_run_info(:,3),uni_proto(x)),(5:6))),1:1:length(uni_proto),'uniformoutput',false);
            jump_pct = cellfun(@(x) sum(x(:,1)) ./ sum(x(:,2)).*100,jump_counts);
            jump_pct = jump_pct(sort_idx);
            
            jump_diff = arrayfun(@(x) y_data(:,x) - jump_pct(x),1:1:length(jump_pct),'uniformoutput',false);
            try
                all_diff = [all_diff,cell2mat(jump_diff)];
            catch
                warning('why')
            end
            
            if selection == 1
                h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));               
            elseif selection == 2
                hb = make_bar_plot(y_data',new_labels,0,'center','',110,.1,12,15);
                set(hb(1),'facecolor',rgb('light blue'));
                set(hb(2),'facecolor',rgb('light red'));
                set(hb(3),'facecolor',rgb('light green'));
                
                h_len = legend('Pez3001','Pez3002','Pez3004');
                set(h_len,'fontsize',15,'location','north','orientation','horizontal');                
            elseif selection == 3
                hb = make_bar_plot(y_data',new_labels,0,'center','',110,.1,12,15);
                set(hb(1),'facecolor',rgb('light red'));
                set(hb(2),'facecolor',rgb('light blue'));
                
                h_len = legend('Females Only','Males Only');
                set(h_len,'fontsize',15,'location','north','orientation','horizontal');                
                
            end
                           
            set(gca,'Ylim',[0 110],'Ytick',0:10:100,'Ygrid','on','nextplot','add','fontsize',15);
            
            box on;
            
            new_labels = unique(convert_labels(uni_geno{iterZ},'Genotype_1',exp_info));
            new_labels = regexprep(new_labels,' :: ','\n');
            title(sprintf('%s',new_labels{1}),'Interpreter','none','HorizontalAlignment','center','fontsize',14);          
            
%             filt_run = run_info(geno_logic,:);
%             for iterX = 1:length(x_data)
%                 jumpers = sum(cell2mat(filt_run(ismember(filt_run(:,3),x_data{iterX}),5)));
%                 totals  = sum(cell2mat(filt_run(ismember(filt_run(:,3),x_data{iterX}),6)));
%                 jump_rate = (jumpers / totals)*100;
% %                plot(iterX,jump_rate,'*','color',rgb('green'),'markersize',10);
%                 wsi = get_error_bars((jump_rate*50)/100,50);
%                 wsi = wsi .* 100;
%                 
%                 line([iterX-(h.groupWidth/2) iterX+(h.groupWidth/2)],[wsi(1) wsi(1)],'color',rgb('dark green'),'linewidth',2);
%                 line([iterX-(h.groupWidth/2) iterX+(h.groupWidth/2)],[wsi(2) wsi(2)],'color',rgb('dark green'),'linewidth',2);
%             end
        end
        figure;

        if selection == 2
        h = iosr.statistics.boxPlot([3001,3002,3004],all_diff','symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                       
        else
            h = iosr.statistics.boxPlot([1,2],all_diff','symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                       
        end

        line([.5 3.5],[0 0],'color',rgb('dark green'),'linewidth',1.5,'parent',gca);
        set(gca,'fontsize',15,'ygrid','on','Ylim',[-50 50],'Ytick',-50:10:50);
        title('Differnce between pulled average and individual pez performace','Interpreter','none','HorizontalAlignment','center','fontsize',14); 
   end
    function video_per_day(hObj,~)
        selection = get(hObj,'UserData');
        exp_info = vertcat(combine_data(:).parsed_data);
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');
        all_data = [];

        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            [good_data,in_range_logic] = find_good_data(uni_parent{iterZ},parent_logic);
            [~,~,~,start_frame] = get_jump_info(good_data);
            
            leg_frame = good_data.frame_of_leg_push;
            leg_frame(cellfun(@(x) isempty(x),good_data.frame_of_leg_push)) = num2cell(start_frame(cellfun(@(x) isempty(x),good_data.frame_of_leg_push)));
            ontime_logic = (cellfun(@(x) isnan(x), leg_frame) | cell2mat(leg_frame) >= start_frame);
            all_data = [all_data;good_data(ontime_logic & in_range_logic,:)];
        end
        if selection < 4
            vpr_table = tabulate(cellfun(@(x) x(1:23),all_data.Properties.RowNames,'uniformoutput',false));
            pez_list  = cellfun(@(x) str2double(x(11:14)),vpr_table(:,1));        
            day_run = weekday(cellfun(@(x) datenum([x(20:21),'.',x(22:23),'.',x(16:19)],'mm.dd.yyyy'),vpr_table(:,1)));            
        else
            vpr_table = tabulate(cellfun(@(x) x(1:40),all_data.Properties.RowNames,'uniformoutput',false));
            geno_list = cellfun(@(x) str2double(x(33:end)),vpr_table(:,1));
        end
        
        if selection == 1
            uni_res = unique(pez_list);
            plot_data = pez_list;
        elseif selection == 2
            uni_res = unique(day_run);
            plot_data = day_run;
        elseif selection == 4
            uni_res = unique(geno_list);
            plot_data = geno_list;
        end        
        
        if selection ~= 3
            new_results = zeros(length(uni_res),2);
            for iterP = 1:length(uni_res)
                new_logic = ismember(plot_data,uni_res(iterP));
                new_results(iterP,1) = sum(new_logic);                  %total runs
                new_results(iterP,2) = sum(cell2mat(vpr_table(new_logic,2))); %total videos
            end
            new_results = [new_results;sum(new_results)];
        end

        
        figure
        if selection == 3
            [y_data,x_data,~] = iosr.statistics.tab2box(pez_list,cell2mat(vpr_table(:,2)),day_run);
            group = [{'Monday'};{'Wednesday'};{'Friday'}];
            h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','.','notch',false,'showLegend',true,...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',250,'linewidth',2.5,...
                   'groupLabels',group,'xSeparator',true,'boxcolor',{rgb('light red'),rgb('light blue'),rgb('light green')});
            set(h.handles.legend,'fontsize',40,'FontWeight','bold')
        else
            new_entry = max(plot_data)+2;
            plot_data = [plot_data;repmat(new_entry,length(plot_data),1)];
            scat_data = cell2mat(vpr_table(:,2));
            scat_data = [scat_data;scat_data];
            
            [y_data,x_data,~] = iosr.statistics.tab2box(plot_data,scat_data);
            h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','.','notch',true,...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',75,'linewidth',2.5);
        end

              
        set(gca,'Ylim',[0 35],'fontsize',25,'Ytick',0:5:35,'Ygrid','on','xtick',[])                      
        if selection == 3               
            title(sprintf('Videos Per Run By Pez and By Day'),'Interpreter','none','HorizontalAlignment','center','fontsize',40);
            new_labels = num2cell(x_data);
        else
            for iterZ = 1:length(x_data)
                text(x_data(iterZ),33.5,sprintf('%3.0f',new_results(iterZ,1)),'Interpreter','none','HorizontalAlignment','center','fontsize',20);
                pulled_avg = new_results(iterZ,2) ./ new_results(iterZ,1);
                line([(x_data(iterZ)-(h.groupWidth/2)) (x_data(iterZ)+(h.groupWidth/2))],[pulled_avg pulled_avg],'color',rgb('green'),'linewidth',1.5,'parent',gca);
            end
            if selection == 1
                title(sprintf('Videos Per Run By Pez Used'),'Interpreter','none','HorizontalAlignment','center','fontsize',40);
                new_labels = num2cell(x_data);
                new_labels(end) = {'All Pezes'};
            elseif selection == 2
                title(sprintf('Videos Per Run By Day Of The Week'),'Interpreter','none','HorizontalAlignment','center','fontsize',40);
                new_labels = [{'Monday'};{'Wednesday'};{'Friday'}];
                new_labels = [new_labels;{'All Days Run'}];
            elseif selection == 4
                title(sprintf('Videos Per Run By Day Genotype'),'Interpreter','none','HorizontalAlignment','center','fontsize',40);
                %new_labels = convert_labels(num2str(uni_res),'Genotype_many',exp_info);
                new_labels = convert_labels(num2str(uni_res),'DN_convert',exp_info);
                new_labels = [new_labels,{'All Genotypes'}];
            end            
        end
        rotation = 0;                                                align = 'center'; 
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(new_labels),1);                          new_x_pos = x_data;
        y = y + 0;
        hText = text(new_x_pos, y, new_labels,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',20);        

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function pathway_histogram(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        
        exp_info(cellfun(@(x) strcmp(x(5:12),'00001713'),exp_id),:) = [];
        exp_id(cellfun(@(x) strcmp(x(5:12),'00001713'),exp_id)) = [];        

        Parent_A = exp_info.ParentA_name;        Parent_B = exp_info.ParentB_name;
        
        parent_str = cellfun(@(x) sprintf('%s',x),Parent_A,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');   
        
        [locA,locB] = ismember(uni_parent,Parent_A);
        
        geno_used = cellfun(@(x) x(5:12),exp_id(locB(locA)),'uniformoutput',false);
        new_labels = convert_labels(geno_used,'DN_convert',exp_info); 
        x_data = 0:0.10:7;
        new_x_data = [1 3 5 7 10 20 35 50 100 250 500 1000];
        figure
        
%        height_offset = .15;
        height_offset = .3;
        uni_labels = unique(new_labels);
        for iterZ = 1:length(uni_labels)
%            subplot(9,1,iterZ);
            label_logic = ismember(new_labels,uni_labels{iterZ});
            matching_logic = ismember(cellfun(@(x) x(5:12),exp_id,'uniformoutput',false),geno_used(label_logic));
            good_data = [vertcat(combine_data(matching_logic).Complete_usuable_data);vertcat(combine_data(matching_logic).Videos_Need_To_Work);...
                vertcat(combine_data(matching_logic).Vid_Not_Tracked);vertcat(combine_data(matching_logic).Bad_Tracking)];
            good_data(cellfun(@(x) isempty(x), good_data.frame_of_leg_push),:) = [];
            good_data(cellfun(@(x) isnan(x), good_data.frame_of_leg_push),:) = [];
            
            full_diff = cellfun(@(x,y) log((x-y)/6),good_data.frame_of_take_off,good_data.frame_of_wing_movement);
            full_diff(full_diff > log(100)) = [];            
            [f,x] = hist(full_diff,x_data);
            f = (f ./ sum(f));

            hb = bar(x,f,'hist');
            set(gca,'nextplot','add');
            
            old_x_data = get(hb,'Xdata');
            old_y_data = get(hb,'Ydata');
            old_y_data = old_y_data + ((iterZ-1)*height_offset);

            delete(hb);
            patch(old_x_data,old_y_data,rgb('light blue'));            
            
            pct_short = (sum(full_diff <= log(7)) / length(full_diff))*100;
            total_count = length(full_diff);
        end
        y_max = height_offset*iterZ;        
        set(gca,'Xlim',[log(3) log(100)]);
        set(gca,'Ytick',[0,height_offset],'Ylim',[0 y_max]);
        line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',gca);                    
        %set(gca,'Xlim',[log(3) log(100)],'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12);
        set(gca,'Xlim',[0 log(250)],'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12);
       
        y_height = height_offset/2:height_offset:(height_offset*iterZ);

        hText = text(ones(length(uni_labels),1)*log(2.75), y_height', uni_labels,'parent',gca);

        set(hText,'Rotation',0,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',15);
        
    end
    function stacked_pathway_plot(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        
        exp_info(cellfun(@(x) strcmp(x(5:12),'00001713'),exp_id),:) = [];
        exp_id(cellfun(@(x) strcmp(x(5:12),'00001713'),exp_id)) = [];        
        
%        color_list = [{'light blue'},{'dark yellow'},{'green'}];
        
%        new_labels = convert_labels(geno_used,'DN_convert',exp_info); 

        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        
        parent_str = cellfun(@(x) sprintf('%s',x),Parent_A,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');   
        
        [locA,locB] = ismember(uni_parent,Parent_A);
        
        geno_used = cellfun(@(x) x(5:12),exp_id(locB(locA)),'uniformoutput',false);
        new_labels = convert_labels(geno_used,'DN_convert',exp_info); 
        
        [new_labels,sort_idx] = sort(new_labels);
        uni_parent = uni_parent(sort_idx);
        figure;
        x_data = 0:0.10:7;
        all_data = [];
        parent_data = [];
        
        new_x_data = [1 3 5 7 10 20 35 50 100 250 500 1000];
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            good_data = vertcat(combine_data(parent_logic).Complete_usuable_data);
            good_data(cellfun(@(x) isempty(x), good_data.frame_of_leg_push),:) = [];
            good_data(cellfun(@(x) isnan(x), good_data.frame_of_leg_push),:) = [];
            
            full_diff = cellfun(@(x,y) log((x-y)/6),good_data.frame_of_take_off,good_data.frame_of_wing_movement);
            full_diff(full_diff > log(100)) = [];         
                        
            [f(iterZ,:),x(iterZ,:)] = hist(full_diff,x_data);
%            f(iterZ,:) = f(iterZ,:) ./ max(f(iterZ,:));
            f(iterZ,:) = f(iterZ,:) ./ sum(f(iterZ,:));
            
            all_data = [all_data;full_diff];
            parent_data = [parent_data;repmat(new_labels(iterZ),length(full_diff),1)];
            
%             subplot(4,4,iterZ)
%             bar(x,f,'barwidth',1);
%             set(gca,'Xlim',[0 5]);
%             title(sprintf('%s',new_labels{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',15);
        end
        uni_label = unique(new_labels);
        %new_color = [{'light grey'};{'black'}];
        new_color = [{'light purple'};{'light blue'}];
        height_offset = .15;
        for iterZ = 1:length(uni_label)
            label_logic = ismember(new_labels,uni_label{iterZ});
            matching_bar = f(label_logic,:);
            x_data = x(label_logic,:);
            
%            subplot(9,1,iterZ);
            set(gca,'nextplot','add');
            
            matching_count = size(matching_bar,1);
            
            for iterM = 1:2
                if  matching_count == 1
                    hb = bar(x_data(1,:),matching_bar(1,:),'hist');
                else
                    hb = bar(x_data(iterM,:),matching_bar(iterM,:),'hist');
                end
%               set(gca,'nextplot','add');
            
               old_x_data = get(hb,'Xdata');
               old_y_data = get(hb,'Ydata');
               old_y_data = old_y_data + ((iterZ-1)*height_offset);

               delete(hb);
               patch(old_x_data,old_y_data,rgb(new_color{iterM}));
            end
                        
%            y_max = .125;            
%            set(gca,'Xlim',[0 5],'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12,'Ylim',[0 y_max],'Ytick',[0,y_max]);
%            title(sprintf('%s',uni_label{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',15);
%            line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',gca);
        end
        
         set(gca,'Xlim',[0 5],'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12,'Ylim',[0 height_offset*length(uni_label)],'Ytick',[0,height_offset]);
         line([log(7) log(7)],[0 height_offset*length(uni_label)],'color',rgb('red'),'linewidth',2.0,'parent',gca);
         
        y_max = height_offset*iterZ;        
        set(gca,'Xlim',[log(3) log(100)]);
        set(gca,'Ytick',[0,height_offset],'Ylim',[0 y_max]);
        line([log(7) log(7)],[0 y_max],'color',rgb('red'),'linewidth',2.0,'parent',gca);                    
        set(gca,'Xlim',[log(3) log(100)],'XtickLabel',new_x_data,'Xtick',log(new_x_data),'fontsize',12);
       
        y_height = height_offset/2:height_offset:(height_offset*iterZ);

        hText = text(ones(length(uni_label),1)*log(2.75), y_height', uni_label,'parent',gca);

        set(hText,'Rotation',0,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',15);         
     
%         figure
%         uni_parent = unique(parent_data);
%         rank_res = cell(length(uni_parent),3);
%         for iterZ = 1:length(uni_parent)
%             ctrl_logic = ismember(parent_data,'   DL Wildtype');
%             exp_logic = ismember(parent_data,uni_parent{iterZ});
%             rank_res(iterZ,1) = uni_parent(iterZ);
%             [p,~,stats] = ranksum(all_data(ctrl_logic),all_data(exp_logic));
%             
%             rank_res(iterZ,2) = num2cell(stats.zval);
%             rank_res(iterZ,3) = num2cell(p);
%         end        
    end
    function protocol_profile(~,~)
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = cellfun(@(x) x{1},exp_info.Photo_Activation,'uniformoutput',false);
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        
        parent_str = cellfun(@(x) sprintf('%s',x),Parent_A,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');   
        
        for iterZ = 1:length(uni_parent)
            figure
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            
            [good_data,in_range_logic] = find_good_data(uni_parent{iterZ},parent_logic);
            filt_data = good_data(in_range_logic,:);
            
            proto_string = filt_data.photoStimProtocol;
            uni_proto = unique(proto_string);
            [~,sort_idx] = sort(cellfun(@(x) x(end-3:end),uni_proto,'uniformoutput',false));
            uni_proto = uni_proto(sort_idx);
            
%            [x_plot,y_plot] = split_fig(length(uni_proto));     %how many subplots to make
            for iterU = 1:length(uni_proto)
%                subplot(x_plot,y_plot,iterU)
                set(gca,'nextplot','add')
                proto_logic = ismember(proto_string,uni_proto{iterU});
            
                jump_frame = filt_data(proto_logic,:).frame_of_take_off;
                jump_frame(cellfun(@(x) isempty(x),jump_frame)) = num2cell(filt_data(proto_logic,:).autoFot(cellfun(@(x) isempty(x),jump_frame)));
                new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,filt_data(proto_logic,:).photoactivation_info,'uniformoutput',false);

                jump_time = cellfun(@(x,y) (x-y) ./ 6, jump_frame,new_start_frame);

                x_cuts = [0:50:200,300:100:500,750,1000];
                hist_counts = histc(jump_time,x_cuts);
                hist_counts = cumsum(hist_counts);
                hist_counts = hist_counts ./ length(jump_time);
                plot(x_cuts,[0;hist_counts(1:(end-1))],'-o');
                set(gca,'Ylim',[0 1],'Xlim',[0 1000],'Ytick',0:.2:1,'Ygrid','on');
%                title(sprintf('%s',uni_proto{iterU}));
%                legend(uni_proto);
            end  
            legend(uni_proto);
        end
    end
    function time_after_lights_on(hObj,~)
        %short pathway == 52.5 frames to account for frame rate
        selection = get(hObj,'userData');
        
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;   
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');              
        
%        [x_plot,y_plot] = split_fig(length(uni_parent));     %how many subplots to make
        geno_used = cellfun(@(x) x(5:12),exp_id,'uniformoutput',false);
%        uni_geno = convert_labels(geno_used,'Genotype_many',exp_info);
        uni_geno = convert_labels(geno_used,'DN_convert',exp_info);
        uni_geno = unique(uni_geno,'stable');
        
%        figure;
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            [good_data,in_range_logic] = find_good_data(uni_parent{iterZ},parent_logic);           
            figure
            set(gcf,'position',[848   971   712   527]);
%            curr_plot = subplot(x_plot,y_plot,iterZ);
%            curr_position = get(curr_plot,'position');
            filt_data = good_data(in_range_logic,:);
            
            wing_frame = filt_data.frame_of_wing_movement;
%            jump_frame = filt_data.frame_of_take_off;
            jump_frame = filt_data.wing_down_stroke;
            
            not_done_logic = cellfun(@(x) isempty(x), jump_frame);
            jump_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));
            
            wing_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));
            
            new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,filt_data.photoactivation_info);
            
            jump_timing = cellfun(@(x,y) (x-y)./6,jump_frame,num2cell(new_start_frame));
            to_early = cellfun(@(x,y) (x < y ),wing_frame,num2cell(new_start_frame));
            
            jumping_data = filt_data(arrayfun(@(x) ~isnan(x), jump_timing),:);
            to_early(arrayfun(@(x) ~isnan(x), jump_timing)) = [];            
            jump_timing = jump_timing(arrayfun(@(x) ~isnan(x), jump_timing),:);
            
            jumping_data(to_early,:) = [];  jump_timing(to_early,:) = [];
            jumping_data(jump_timing < 0,:) = [];  jump_timing(jump_timing < 0) = [];            
            
            intensity_used = cellfun(@(x) str2double(x(strfind(x,'intensity')+9:end)),jumping_data.photoStimProtocol);
            [intensity_used,sort_idx] = sort(intensity_used);
            pez_list = cellfun(@(x) x(8:14),jumping_data.Properties.RowNames,'uniformoutput',false);
            gender_list = jumping_data.Gender;
            
            if selection == 1
                [y_data,x_data,~] = iosr.statistics.tab2box(intensity_used,jump_timing(sort_idx));
                h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                       'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',75);
            elseif selection == 2
                [y_data,x_data,groups] = iosr.statistics.tab2box(intensity_used,jump_timing(sort_idx),pez_list(sort_idx));
                h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                       'showScatter', false,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',75);
                h.xSeparator = true;
                h.groupLabels = groups;
                h.boxColor = {rgb('red');rgb('blue');rgb('green')};
                h.showLegend = true;
            elseif selection == 3
                keep_data = ~strcmp(gender_list,'Unknown');
                keep_data = keep_data(sort_idx);
                
                [y_data,x_data,groups] = iosr.statistics.tab2box(intensity_used(keep_data),jump_timing(sort_idx(keep_data)),gender_list(sort_idx(keep_data)));
                h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                       'showScatter', false,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',75);
                h.xSeparator = true;
                h.groupLabels = groups;
                try
                    h.boxColor = {rgb('red');rgb('blue')};
                    h.showLegend = true;
                catch
                    h.boxColor = {rgb('red');rgb('blue');rgb('green')};
                end
                
                
            end
            h.linewidth = 1.5;
            
            drawnow;
            title(sprintf('%s',uni_geno{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',15);
            set(gca,'ylim',[0 1250],'Ytick',0:200:1000,'Ygrid','on','fontsize',15)
            if selection == 1
                line([5 55],[1000 1000],'color',rgb('green'),'linewidth',1.5,'parent',gca);
                set(gca,'Xlim',[5 55])
            elseif selection == 2
                set(gca,'ylim',[0 450],'Ytick',0:50:450,'Ygrid','on','fontsize',15)
                set(h.handles.legend,'location','southoutside','orientation','horizontal','fontsize',25)
            elseif selection == 3
                set(gca,'ylim',[0 450],'Ytick',0:50:450,'Ygrid','on','fontsize',15)
            end
            h.handles.legend.Location = 'southoutside';
            h.handles.legend.Orientation = 'vertical';
            h.handles.legend.FontSize = 20;
        end
    end
    function intensity_vs_duration(~,~)
        exp_id = cellstr(vertcat(combine_data(:).exp_id));
        exp_info = vertcat(combine_data(:).parsed_data);        
        proto_string = exp_info.Stimuli_Type;   
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');
        [x_plot,y_plot] = split_fig(length(uni_parent));     %how many subplots to make
        geno_used = cellfun(@(x) x(5:12),exp_id,'uniformoutput',false);
        uni_geno = convert_labels(geno_used,'Genotype_many',exp_info);
        uni_geno = unique(uni_geno,'stable');
        
        x_index = 50:100:1300;
        y_index = 0:5:55;
        figure;
        for iterZ = 1:length(uni_geno)
            curr_plot = subplot(x_plot,y_plot,iterZ);
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            [good_data,in_range_logic] = find_good_data(uni_parent{iterZ},parent_logic);      
            filt_data = good_data(in_range_logic,:);
            
            
            wing_frame = filt_data.frame_of_wing_movement;
%            jump_frame = filt_data.frame_of_take_off;
            jump_frame = filt_data.wing_down_stroke;
            
            not_done_logic = cellfun(@(x) isempty(x), jump_frame);
            jump_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));
            
            wing_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));
            
            new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,filt_data.photoactivation_info);
            
            jump_timing = cellfun(@(x,y) (x-y)./6,jump_frame,num2cell(new_start_frame));
            to_early = cellfun(@(x,y) (x < y ),wing_frame,num2cell(new_start_frame));
            
            jumping_data = filt_data(arrayfun(@(x) ~isnan(x), jump_timing),:);
            to_early(arrayfun(@(x) ~isnan(x), jump_timing)) = [];            
            jump_timing = jump_timing(arrayfun(@(x) ~isnan(x), jump_timing),:);
            
%            new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,jumping_data.photoactivation_info);
            
%            leg_timing = (cell2mat(jumping_data.frame_of_leg_push) - new_start_frame)./6;
            leg_timing = jump_timing;
            
            intensity_used = cellfun(@(x) str2double(x(strfind(x,'intensity')+9:end)),jumping_data.photoStimProtocol);
            intensity_used(leg_timing<0) = [];      leg_timing(leg_timing<0) = [];
            
            hist_counts =  hist3([leg_timing,intensity_used],{x_index y_index});
            pct_jumpers = (hist_counts ./ repmat(sum(hist_counts),length(x_index),1))*100;
            pct_jumpers(arrayfun(@(x) isnan(x),pct_jumpers)) = 0;
            
%            surf(y_index-2.5,x_index,hist_counts);
            surf(y_index-2.5,x_index,pct_jumpers);
            view([90 -90]);
            caxis([0 100])
            colorbar(); 
            set(gca,'Ylim',[0 1300],'Xlim',[-2.5 52.5])
            title(sprintf('%s',uni_parent{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',14);          
        end
    end
    function path_way_use_by_intensity(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        filt_data = [];        
        
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');
        figure;
        
        [x_plot,y_plot] = split_fig(length(uni_parent));     %how many subplots to make
        for iterZ = 1:length(uni_parent)
            subplot(x_plot,y_plot,iterZ);
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            [good_data,in_range_logic] = find_good_data(uni_parent{iterZ},parent_logic);
            filt_data = good_data(in_range_logic,:);
            filt_data(cellfun(@(x) isempty(x), filt_data.frame_of_leg_push),:) = [];
            filt_data(cellfun(@(x) isnan(x), filt_data.frame_of_leg_push),:) = [];

            new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,filt_data.photoactivation_info);
            early_jump = cellfun(@(x,y) (x-y) < 0,(filt_data.frame_of_wing_movement),num2cell(new_start_frame));
            filt_data(early_jump,:) = [];       new_start_frame(early_jump) = [];            
            
            
            intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),filt_data.photoStimProtocol);
                
            boxplot(cellfun(@(x,y) log((x-y)./6),filt_data.frame_of_take_off,filt_data.frame_of_wing_movement),intensity_used,'notch','on');
            line([0 55],[log(7) log(7)],'color',rgb('green'));
            title(sprintf('%s\nCount :: %4.0f',uni_parent{iterZ},height(filt_data)),'Interpreter','none','HorizontalAlignment','center','fontsize',14);          
            set(gca,'Ylim',[0 7]);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function compare_auto_v_manual(~,~)
        good_data = vertcat(combine_data(:).Complete_usuable_data);
        leg_logic = cellfun(@(x) ~isnan(x),good_data.frame_of_leg_push);
        auto_logic = good_data.autoJumpTest == 1;
%        [result_tab,~,~,labels] = crosstab(leg_logic,auto_logic);
        
        filt_data = good_data(leg_logic & auto_logic ,:);
        
        frame_difference = cellfun(@(x,y) (x-y) ,filt_data.frame_of_take_off,filt_data.autoFrameOfTakeoff);
        over_100 = sum(abs(frame_difference) > 100);
        over_50 = sum(abs(frame_difference) >= 50) - over_100;
        frame_difference(abs(frame_difference) >= 50) = [];
        
        figure; f = histc(frame_difference,-60:10:60);

        bar(-55:10:65,f,'barwidth',1,'facecolor',rgb('light blue'));
        set(gca,'Xtick',-60:10:60,'fontsize',15,'Xlim',[-60 60])
        xlabel('difference in annotations','fontsize',15);
        title('Positive Difference means Manual Annotations are Later','fontsize',20,'Interpreter','none','HorizontalAlignment','center');
    end
    function video_breakdown(~,~)
        filt_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);...
                    vertcat(combine_data(:).Vid_Not_Tracked);vertcat(combine_data(:).Bad_Tracking)];                                
                
        [gender_table,~,~,gen_labels] = crosstab(cellfun(@(x) x(8:23),filt_data.Properties.RowNames,'uniformoutput',false),filt_data.Gender);                
        gender_table = cell2table(num2cell(gender_table(:,1:2)));
        gender_table.Properties.RowNames = gen_labels(:,1);
        gender_table.Properties.VariableNames = gen_labels(1:2,2);
        
        [~,sort_idx] = sort(gender_table.Properties.RowNames);
        gender_table = gender_table(sort_idx,:);
        
        male_pct = gender_table.Male ./ (gender_table.Male + gender_table.Female);
        [y_data,x_data,~] = iosr.statistics.tab2box(cellfun(@(x) x(1:7),gender_table.Properties.RowNames,'uniformoutput',false),male_pct);
        
        figure
        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));               

                
        multi_fail = vertcat(combine_data(:).Multi_Blank);
        pez_fail = vertcat(combine_data(:).Pez_Issues);
                        
        curate_fail_logic = cellfun(@(x) ~strcmp(x,'Good'),filt_data.Fly_Detect_Accuracy);
        curate_fail = filt_data(curate_fail_logic,:);           filt_data(curate_fail_logic,:) = [];
        
        tracking_fail_logic = cellfun(@(x) ~strcmp(x,'Analysis complete'),filt_data.Analysis_Status);
        track_fail = filt_data(tracking_fail_logic,:);           filt_data(tracking_fail_logic,:) = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        multi_table = tabulate(cellfun(@(x) x(8:14),multi_fail.Properties.RowNames,'uniformoutput',false));
        [~,sort_idx] = sort(multi_table(:,1));      multi_table = multi_table(sort_idx,:);
        
        pez_table = tabulate(cellfun(@(x) x(8:14),pez_fail.Properties.RowNames,'uniformoutput',false));
        [~,sort_idx] = sort(pez_table(:,1));      pez_table = pez_table(sort_idx,:);

        curate_table = tabulate(cellfun(@(x) x(8:14),curate_fail.Properties.RowNames,'uniformoutput',false));
        [~,sort_idx] = sort(curate_table(:,1));      curate_table = curate_table(sort_idx,:);

        track_table = tabulate(cellfun(@(x) x(8:14),track_fail.Properties.RowNames,'uniformoutput',false));
        [~,sort_idx] = sort(track_table(:,1));     track_table = track_table(sort_idx,:);

        good_table = tabulate(cellfun(@(x) x(8:14),filt_data.Properties.RowNames,'uniformoutput',false));
        [~,sort_idx] = sort(good_table(:,1));     good_table = good_table(sort_idx,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        count_list = cell2mat(cellfun(@(x,y,z,a,b) [x,y,z,a,b],pez_table(:,2),multi_table(:,2),curate_table(:,2),track_table(:,2),good_table(:,2),'uniformoutput',false));
        totals = sum(count_list,2);
        
        pct_break_down = cell2mat((arrayfun(@(x) count_list(x,:) ./ totals(x),1:1:3,'uniformoutput',false))');
        figure
        hb = bar(pct_break_down');
        
        set(hb,'edgecolor',rgb('black'),'linewidth',1.25)
        set(hb(1),'facecolor',rgb('red'))
        set(hb(2),'facecolor',rgb('blue'))
        set(hb(3),'facecolor',rgb('orange'))        
        
        set(gca,'Ylim',[0 1],'Ytick',0:.2:1,'Ygrid','on','fontsize',18,'Xtick',[]);
        h_len = legend('Pez3001','Pez3002','Pez3004');
        set(h_len,'Location','Best','Fontsize',25);
        
        new_labels = [{sprintf('Pez\nIssues')},{sprintf('Multi/Blank\nVideoes')},{sprintf('Location\nErrors')},{sprintf('Tracking\nErrors')},{sprintf('Useable\nVideos')}];
        
        rotation = 0;                                                align = 'center'; 
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(new_labels),1);                          new_x_pos = 1:1:length(new_labels);
        y = y - .05;
        hText = text(new_x_pos, y, new_labels,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',20);        
        
        title('Distribution of Downloaded Videos Seperated By Pez Used','Interpreter','none','HorizontalAlignment','center','fontsize',25);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
        pulled_pct = [pct_break_down(:,[1,2]),sum(pct_break_down(:,3:end),2)];
        figure
        hb = bar(pulled_pct');
        
        set(hb,'edgecolor',rgb('black'),'linewidth',1.25)
        set(hb(1),'facecolor',rgb('red'))
        set(hb(2),'facecolor',rgb('blue'))
        set(hb(3),'facecolor',rgb('orange'))        
        
        set(gca,'Ylim',[0 1],'Ytick',0:.2:1,'Ygrid','on','fontsize',18,'Xtick',[]);
        h_len = legend('Pez3001','Pez3002','Pez3004');
        set(h_len,'Location','Best','Fontsize',25);
        
        new_labels = [{sprintf('Pez\nIssues')},{sprintf('Multi/Blank\nVideoes')},{sprintf('Useable\nVideos')}];
        
        rotation = 0;                                                align = 'center'; 
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(new_labels),1);                          new_x_pos = 1:1:length(new_labels);
        y = y - .05;
        hText = text(new_x_pos, y, new_labels,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',20);        
        
        title('Distribution of Downloaded Videos Seperated By Pez Used','Interpreter','none','HorizontalAlignment','center','fontsize',25);
    end
    function stimuli_delay(~,~)
        good_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);...
                     vertcat(combine_data(:).Vid_Not_Tracked);vertcat(combine_data(:).Bad_Tracking)];                                        
        
        start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,good_data.photoactivation_info);
        pez_list = cellfun(@(x) str2double(x(11:14)),good_data.Properties.RowNames);
        
        pez_list(start_frame>450) = [];
        start_frame(start_frame>450) = [];
        start_frame = start_frame ./ 6;

        figure
        [y_data,x_data,~] = iosr.statistics.tab2box(pez_list,start_frame);

        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
            'showScatter', false,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

        set(gca,'Ylim',[55 75],'Ytick',55:5:75,'Ygrid','on','fontsize',18)
        ylabel('Delay between Frame 1 and Stimuli Start (ms)','fontsize',15)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function gender_break_down(~,~)
        good_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);...
                     vertcat(combine_data(:).Vid_Not_Tracked);vertcat(combine_data(:).Bad_Tracking)];                                        
        good_data(cellfun(@(x) strcmp(x,'Unknown'),good_data.Gender),:) =[];
%        [new_table,~,~,run_labels] = crosstab(cellfun(@(x) x(8:23),good_data.Properties.RowNames,'uniformoutput',false),good_data.Gender);
        [new_table,~,~,run_labels] = crosstab(cellfun(@(x) x(1:23),good_data.Properties.RowNames,'uniformoutput',false),good_data.Gender);
        new_table = cell2table(num2cell(new_table));
        new_table.Properties.RowNames = run_labels(:,1);
        new_table.Properties.VariableNames = run_labels(cellfun(@(x) (~isempty(x)),run_labels(:,2)),2);
        
        keep_data = (new_table.Female + new_table.Male) >= 15;
        new_table = new_table(keep_data,:);
        
        male_pct = new_table.Male ./ (new_table.Male + new_table.Female);
        pez_list = cellfun(@(x) str2double(x(11:14)),new_table.Properties.RowNames);
%        pez_list = cellfun(@(x) str2double(x(4:7)),new_table.Properties.RowNames);
        
        [y_data,x_data,~] = iosr.statistics.tab2box(pez_list,male_pct);

        figure
        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
            'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
        
        overall_male_pct = sum(new_table.Male) / sum((new_table.Male + new_table.Female));
        line([3000 3005],[overall_male_pct overall_male_pct],'color',rgb('green'),'linewidth',1.5,'parent',gca);
        set(gca,'fontsize',15,'Ylim',[0 1],'Ytick',0:.2:1);
        title('percent of male flies by run, seperated by pez')
    end
    function take_off_pct_by_intensity_genotype(hObj,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        proto_used = cellfun(@(x) x{1}, exp_info.Photo_Activation,'uniformoutput',false);
        intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),proto_used);
        
        selection = get(hObj,'UserData');
        all_jump = [];  all_totals = [];
        
        for iterZ = 10:10:50
            testing_intensity = iterZ;
            test_logic = intensity_used == testing_intensity;

            filt_data = [vertcat(combine_data(test_logic).Complete_usuable_data);vertcat(combine_data(test_logic).Videos_Need_To_Work);...
                        vertcat(combine_data(test_logic).Vid_Not_Tracked);vertcat(combine_data(test_logic).Bad_Tracking)];                                

            wing_frame = filt_data.frame_of_wing_movement;
            jump_frame = filt_data.frame_of_leg_push;

            not_done_logic = cellfun(@(x) isempty(x), jump_frame);
            jump_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));

            wing_frame(not_done_logic) = num2cell(filt_data.autoFot(not_done_logic));

            new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,filt_data.photoactivation_info);
            to_early = cellfun(@(x,y) (x < y ),wing_frame,num2cell(new_start_frame));

            filt_data(to_early,:) = [];      %remove pre stim flies
            jump_frame(to_early,:) = [];    new_start_frame(to_early,:) = [];
            jump_timing = cellfun(@(x,y) (x-y)./6,jump_frame,num2cell(new_start_frame));

%            cut_val = (2500/ testing_intensity);
%            cut_val = 250;
            cut_val = 1000;

%            new_labels = [{sprintf('10%%\n250ms')},{sprintf('20%%\n125ms')},{sprintf('30%%\n83ms')},{sprintf('40%%\n63ms')},{sprintf('50%%\n50ms')}];
%            new_labels = [{sprintf('10%%\n250ms')},{sprintf('20%%\n250ms')},{sprintf('30%%\n250ms')},{sprintf('40%%\n250ms')},{sprintf('50%%\n250ms')}];
            new_labels = [{sprintf('10%%\n1000ms')},{sprintf('20%%\n1000ms')},{sprintf('30%%\n1000ms')},{sprintf('40%%\n1000ms')},{sprintf('50%%\n1000ms')}];

            change_jump = jump_timing > cut_val;
            jump_timing(change_jump) = NaN(sum(change_jump),1);

            if selection == 1
                exp_ids = cellfun(@(x) x(33:40),filt_data.Properties.RowNames,'uniformoutput',false);
            elseif selection == 2
                exp_ids = cellfun(@(x) [x(33:40),'_',x(8:14)],filt_data.Properties.RowNames,'uniformoutput',false);
            elseif selection == 3
                exp_ids = cellfun(@(x,y) [x(33:40),'_',y],filt_data.Properties.RowNames,filt_data.Gender,'uniformoutput',false);
                not_done_logic = cellfun(@(x) ~isempty(strfind(x,'Unknown')),exp_ids);
                exp_ids(not_done_logic) = [];
                jump_timing(not_done_logic) = [];
            end
            total_counts = tabulate(exp_ids);
            jump_counts = tabulate(exp_ids(arrayfun(@(x) ~isnan(x),jump_timing)));
            
            [~,sort_idx] =sort(total_counts(:,1));
            total_counts = total_counts(sort_idx,:);

            locA = ismember(total_counts(:,1),jump_counts(:,1));
            if sum(~locA) > 0
                missing_data = total_counts(~locA,:);
                missing_data(:,2) = repmat({0},sum(~locA),1);
                jump_counts = [jump_counts;missing_data];
            end

            [~,locB] = ismember(total_counts(:,1),jump_counts(:,1));
            jump_counts = jump_counts(locB,:);
            jump_pct = cellfun(@(x,y) (x/y),jump_counts(:,2),total_counts(:,2));
            
            get_jumpers = @(z) sum(cell2mat(cellfun(@(x,y) (y(~isempty(strfind(x,z)))),jump_counts(:,1),jump_counts(:,2),'uniformoutput',false)));
            get_totals = @(z) sum(cell2mat(cellfun(@(x,y) (y(~isempty(strfind(x,z)))),total_counts(:,1),total_counts(:,2),'uniformoutput',false)));
            
            if selection > 1
                uni_exp = unique(cellfun(@(x) x(1:8),jump_counts(:,1),'uniformoutput',false));            
                for iterP = 1:length(uni_exp)
                    pulled_pct(iterP) = get_jumpers(uni_exp{iterP}) ./ get_totals(uni_exp{iterP});
                end
            end

            all_jump = [all_jump,jump_pct];
            all_totals = [all_totals,pulled_pct'];            
        end
        jump_table = cell2table(num2cell(all_jump));
        jump_table.Properties.RowNames = jump_counts(:,1);
        jump_table.Properties.VariableNames = arrayfun(@(x) sprintf('Intensity_%2.0f',x),10:10:50,'uniformoutput',false);
        
        [~,sort_idx] = sort(jump_table.Properties.RowNames);
        jump_table = jump_table(sort_idx,:);
        
        if selection == 1
            new_dn_strings = convert_labels(jump_table.Properties.RowNames,'DN_convert',exp_info);
            for iterZ = 1:height(jump_table)
                figure;
                set(gcf,'position',[ 837         325        1003         607]);

                plot_data = cell2mat(table2cell(jump_table(iterZ,:)));
                hb = bar(plot_data);
                set(hb,'facecolor',rgb('light blue'),'linewidth',1.25','edgecolor',rgb('black'));
                
                set_alignment(new_labels,iterZ,'gender')

                title(sprintf('%s',new_dn_strings{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',25);            
            end
        else
            exp_id = cellfun(@(x) x(1:8),jump_table.Properties.RowNames,'uniformoutput',false);
            uni_exp_id = unique(exp_id);
            new_dn_strings = convert_labels(uni_exp_id,'DN_convert',exp_info);
            pez_diff = [];
            for iterZ = 1:length(uni_exp_id)
                matching_logic = ismember(exp_id,uni_exp_id{iterZ});
                figure;
                set(gcf,'position',[ 837         325        1003         607]);

                plot_data = cell2mat(table2cell(jump_table(matching_logic,:)));
                plot_data = [plot_data;all_totals(iterZ,:)];
                hb = bar(plot_data');    
                if selection == 2
                    set_alignment(new_labels,iterZ,'gender')
                elseif selection == 3
                    set_alignment(new_labels,iterZ,'pez');
                end


                set(hb(1),'facecolor',rgb('red'),'barwidth',.75)
                set(hb(2),'facecolor',rgb('blue'),'barwidth',.75)
                if selection == 2
                    set(hb(3),'facecolor',rgb('orange'),'barwidth',.75)        
                    set(hb(4),'facecolor',rgb('green'),'barwidth',.75)
                    h_len = legend('Pez3001','Pez3002','Pez3004','All Pezes');                    
                    x_data = [3001,3002,3004];
                elseif selection == 3
                    set(hb(3),'facecolor',rgb('green'),'barwidth',.75)
                    h_len = legend('Females Only','Males only','Both Genders');
                    x_data = [1,2];
                end
                set(hb,'edgecolor',rgb('black'),'linewidth',.8);
                set(h_len,'location','north','Orientation','horizontal','fontsize',15);
                
                
                title(sprintf('%s',new_dn_strings{iterZ}),'Interpreter','none','HorizontalAlignment','center','fontsize',25);                                            
                pez_diff = [pez_diff,cell2mat(arrayfun(@(x) plot_data(x,:)-all_totals(iterZ,:),(1:1:(length(plot_data(:,1))-1))','uniformoutput',false))];
            end
            figure;
            h = iosr.statistics.boxPlot(x_data,pez_diff','symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));               
            
            if selection == 2
                line([3000 3005],[0 0],'color',rgb('dark green'),'linewidth',1.5,'parent',gca);
                set(gca,'fontsize',15,'ygrid','on','Ylim',[-.15 .15],'Ytick',-.15:.05:.15);
                title('Differnce between pulled average and individual Pez Performace','Interpreter','none','HorizontalAlignment','center','fontsize',20);             
                
            elseif selection == 3
                line([0 3],[0 0],'color',rgb('dark green'),'linewidth',1.5,'parent',gca);
                set(gca,'fontsize',15,'ygrid','on','Ylim',[-.5 .5],'Ytick',-.5:.1:.5);
                title('Differnce between pulled average and Gender Performance','Interpreter','none','HorizontalAlignment','center','fontsize',20);                             
            end
            set(gca,'fontsize',15,'Xticklabel',[{'Females Only'},{'Males Only'}])
        end
    end
    function set_alignment(new_labels,iterZ,flag)
        set(gca,'Xtick',[],'fontsize',15);

        rotation = 0;                                                align = 'center'; 
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(new_labels),1);                          new_x_pos = 1:1:length(new_labels);
        if iterZ == 3
            set(gca,'ylim',[0 1.2],'Ytick',0:.2:1);
            y = y - .05;
        else
            if strcmp(flag,'gender')
                set(gca,'ylim',[0 .5],'Ytick',0:.1:.5);
                y = y - .025;
            elseif strcmp(flag,'pez')
                set(gca,'ylim',[0 .6],'Ytick',0:.1:.6);
                y = y - .025;
                if iterZ == 4
                    set(gca,'ylim',[0 1.2],'Ytick',0:.2:1);
                    y = y - .05;
                end                    
            end

        end
        hText = text(new_x_pos, y, new_labels,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',17);          
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function leg_extenstion_by_intensity(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        
        good_data = vertcat(combine_data(:).Complete_usuable_data);
        start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,good_data.photoactivation_info);

        wing_frame = good_data.frame_of_wing_movement;
        wing_frame(cellfun(@(x) isempty(x),good_data.frame_of_wing_movement)) = num2cell(good_data(cellfun(@(x) isempty(x),good_data.frame_of_leg_push),:).autoFot);

        ontime_logic = (cellfun(@(x) isnan(x), wing_frame) | cell2mat(wing_frame) >= start_frame);
        good_data = good_data(ontime_logic,:);         
        
        intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),good_data.photoStimProtocol);
        wing_start = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_wing_movement,num2cell(start_frame));
        outlier_logic = wing_start > 400 | intensity_used == 10;
        
        good_data(outlier_logic,:) = [];
        
        leg_down = cellfun(@(x,y) ((x-y)/6),good_data.wing_down_stroke,good_data.frame_of_leg_push);
        down_jump = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_take_off,good_data.wing_down_stroke);
        leg_jump = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_take_off,good_data.frame_of_leg_push);
        genotype = cellfun(@(x) x(33:40),good_data.Properties.RowNames,'uniformoutput',false);
        
        genotype = [genotype;genotype;genotype];
        pathway_int = [leg_down;down_jump;leg_jump];
        pathway_cat = [repmat({'leg down'},length(leg_down),1);repmat({'down jump'},length(down_jump),1);repmat({'leg jump'},length(leg_jump),1)];
        remove_data = pathway_int == 0;
        
        [y_data,x_data,groups] = iosr.statistics.tab2box(genotype(~remove_data),pathway_int(~remove_data),pathway_cat(~remove_data));
        uni_geno = unique(genotype);
        y_data = y_data(:,:,[2,1,3]);
        groups = cellfun(@(x) x,groups{1},'uniformoutput',false);
        groups = [groups(2);groups(1);groups(3)];
        

        figure
        h = iosr.statistics.boxPlot(1:1:length(uni_geno),y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
            'showScatter', false,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

        h.boxColor = {rgb('light red'),rgb('light blue'),rgb('light green')};
        h.xSeparator = true;
        h.groupLabels = groups;
        h.showLegend = true;   
        h.handles.legend.FontSize = 20;
        h.handles.legend.Location = 'best';
        
        new_labels = convert_labels(x_data,'DN_convert',exp_info);
        set(gca,'Xticklabel',new_labels,'fontsize',15,'Ygrid','on','Ytick',0:2:10);
        title(sprintf('Pathway Components seperated by Genotype\nCombined prototcols for 20%% intensity to 50%% intensity'),'Interpreter','none','fontsize',17);
    end
    function gender_take_off_pct(~,~)
%         good_data = vertcat(combine_data(:).Complete_usuable_data);
%         stimuli_used = good_data.visStimProtocol;
%         chrim_logic = cellfun(@(x) isempty(x),stimuli_used);
%         stimuli_used(chrim_logic) = good_data.photoStimProtocol(chrim_logic);
%         stimuli_used = regexprep(stimuli_used,'.mat','');
%         stimuli_used = regexprep(stimuli_used,'pulse_General_','');
%         
%         [new_table,~,~,total_labels] = crosstab(stimuli_used,good_data.Gender);
%         
%         jump_logic = cellfun(@(x) ~isnan(x),good_data.frame_of_take_off);
%         
%         [jump_table,~,~,jump_labels] = crosstab(stimuli_used(jump_logic),good_data.Gender(jump_logic));
%         
%         [~,sort_idx] = sort(total_labels(:,1));
%         total_labels = total_labels(sort_idx,1);
    end
    function menu_labels(~,~)
        m_compare = uimenu(hFigC,'Label','Compare Functions');
            uimenu(m_compare,'label','Auto Vs Manual compare','callback',@compare_auto_v_manual);
            uimenu(m_compare,'label','Video Break Down','callback',@video_breakdown);
            uimenu(m_compare,'label','Stimuli Start Delay','callback',@stimuli_delay);
            uimenu(m_compare,'label','Stimuli Start Delay','callback',@gender_break_down);
        m_jump_special = uimenu(hFigC,'Label','Special Jump Rate Plots');
            uimenu(m_jump_special,'Label','Take Off Percentages :: By Run','callback',@take_off_pct_special,'UserData',1);
            uimenu(m_jump_special,'Label','Take Off Percentages :: By Pez','callback',@take_off_pct_special,'UserData',2);
            uimenu(m_jump_special,'Label','Take Off Percentages :: By Gender','callback',@take_off_pct_special,'UserData',3);
            uimenu(m_jump,'label',' ');
%            uimenu(m_jump,'label','Tuning Curve By Azimuth','callback',@tuning_curve_jump_rate);
            uimenu(m_jump,'label','Chrimson 50% by 50ms','callback',@take_off_pct_by_intensity);
            uimenu(m_jump,'label','Chrimson 50% by 50ms','callback',@take_off_pct_by_intensity_genotype,'UserData',1);
            uimenu(m_jump,'label','Chrimson 50% by 50ms By Pez','callback',@take_off_pct_by_intensity_genotype,'UserData',2);
            uimenu(m_jump,'label','Chrimson 50% by 50ms By Gender','callback',@take_off_pct_by_intensity_genotype,'UserData',3);
        m_timing = uimenu(hFigC,'Label','Jump Timing Plots');      
            uimenu(m_timing,'label','Time After Lights On : Boxplot','callback',@time_after_lights_on,'UserData',1);
            uimenu(m_timing,'label','Time After Lights On : Boxplot By Pez','callback',@time_after_lights_on,'UserData',2);
            uimenu(m_timing,'label','Time After Lights On : Boxplot By Gender','callback',@time_after_lights_on,'UserData',3);
            uimenu(m_timing,'label','Intensity Vs Duration','callback',@intensity_vs_duration);
        m_special = uimenu(hFigC,'Label','New Special Plots');
            uimenu(m_special,'label','Video Per Run :: Pez','callback',@video_per_day,'UserData',1)
            uimenu(m_special,'label','Video Per Run :: Day','callback',@video_per_day,'UserData',2)
            uimenu(m_special,'label','Video Per Run :: Pez And Day','callback',@video_per_day,'UserData',3)
            uimenu(m_special,'label','Video Per Run :: Genotype','callback',@video_per_day,'UserData',4)

            uimenu(m_special,'label','Protocol Profile','callback',@protocol_profile);
        m_pathway = uimenu(hFigC,'Label','Pathway Usage');      
             uimenu(m_pathway,'label','By Genotype And Protocol : boxplot','callback',@path_way_use_by_intensity)           
             uimenu(m_pathway,'label','Stacked Pathway Hist :: Martin','callback',@stacked_pathway_plot);
             uimenu(m_pathway,'label','Pathay Histogram :: Martin','callback',@pathway_histogram);
             uimenu(m_pathway,'label','');
             uimenu(m_pathway,'label','Full Leg Extenstion by Intensity','callback',@leg_extenstion_by_intensity);
        m_gender = uimenu(hFigC,'Label','Gender Testing Functions');
            uimenu(m_gender,'label','Take off Pct By Gender','callback',@gender_take_off_pct);            
        m_counts = uimenu(hFigC,'Label','Special option');      
            uimenu(m_counts,'label','Total Videos By Pez / Light Cycle','callback',@total_videos_by_pez_cycle);
            uimenu(m_counts,'label','Downloaded Video Distribution','callback',@video_distribution);            
    end
    function take_off_parents(~,~)
        figure
        geno_used = height(total_counts);
        [x_plot,y_plot] = split_fig(geno_used);     %how many subplots to make
        for iterZ = 1:geno_used
            subplot(x_plot,y_plot,iterZ);
            new_labels = convert_labels(total_counts.Properties.VariableNames,'Intensity',exp_info);
            [new_labels,IA,IC] = unique(new_labels,'stable');

            new_table = zeros(height(total_counts),length(IA));
            new_jump = zeros(height(total_counts),length(IA));
            uni_C = unique(IC);
            for iterC = 1:length(uni_C)                
                new_table(:,iterC) = sum(cell2mat(table2cell(total_counts(:,IC == uni_C(iterC)))),2);
                new_jump(:,iterC) = sum(cell2mat(table2cell(jump_counts(:,IC == uni_C(iterC)))),2);
            end

            jump_count = new_jump(iterZ,:);
            total_count = new_table(iterZ,:);
            jump_pct = jump_count ./ total_count;                

            [new_labels,sort_idx] = sort(new_labels);

            if selection == 2.1
                uni_geno = convert_labels(total_counts.Properties.RowNames(iterZ),'Genotype_1',exp_info);
                uni_geno = unique(uni_geno,'stable');
            else
                uni_geno = total_counts.Properties.RowNames(iterZ);
            end
            jump_pct = jump_pct(sort_idx).*100;
            make_bar_plot(jump_pct,new_labels,45,'right',uni_geno{1},new_height,new_space,12,20)
            add_error_bars(gca,jump_count(sort_idx),total_count(sort_idx));
            total_N = new_table(iterZ,:);
            total_N = total_N(sort_idx);
            text(1:1:length(new_table(1,:)),repmat(new_height-new_space*1,length(new_table(1,:)),1),arrayfun(@(x) sprintf('%3.0f',x),total_N,'uniformoutput',false),...
                'Interpreter','none','HorizontalAlignment','center','fontsize',12);                
            set(gca,'fontsize',15);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function compare_take_off_pcts_cycle(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        
        morning_logic = cellfun(@(x) strcmp(x,'Darwin Incubator :: #BB'),exp_info.Name);
        afternoon_logic = cellfun(@(x) strcmp(x,'Darwin Incubator :: #DD'),exp_info.Name);
        
        uni_parent = unique(Parent_A);
        [x_plot,y_plot] = split_fig(length(uni_parent));
        figure
        azi_cut = (0-45/2):45:(90+45/2);

        for iterZ = 1:length(uni_parent);
            subplot(x_plot,y_plot,iterZ);
            Parent_logic = ismember(Parent_A,uni_parent{iterZ});
            morning_data = [vertcat(combine_data(Parent_logic & morning_logic).Complete_usuable_data);vertcat(combine_data(Parent_logic & morning_logic).Videos_Need_To_Work)];
            afternoon_data = [vertcat(combine_data(Parent_logic & afternoon_logic).Complete_usuable_data);vertcat(combine_data(Parent_logic & afternoon_logic).Videos_Need_To_Work)];
            
            morning_data(abs(morning_data.Stim_Fly_Saw_At_Trigger) > 112.5,:) = [];
            afternoon_data(abs(afternoon_data.Stim_Fly_Saw_At_Trigger) > 112.5,:) = [];
            
            [morning_stim_angle,morning_jump_logic,rem_records] = get_jump_info(morning_data);
            morning_data(rem_records,:) = []; morning_jump_logic(rem_records) = [];   morning_stim_angle(rem_records) = [];
            
            [afternoon_stim_angle,afternoon_jump_logic,rem_records] = get_jump_info(afternoon_data);
            afternoon_data(rem_records,:) = []; afternoon_jump_logic(rem_records) = [];   afternoon_stim_angle(rem_records) = [];
                        
            morning_total = histc(abs(morning_data.Stim_Fly_Saw_At_Trigger),azi_cut);                               morning_total(end) = [];
            morning_jump = histc(abs(morning_data(morning_jump_logic,:).Stim_Fly_Saw_At_Trigger),azi_cut);          morning_jump(end) = [];

            afternoon_total = histc(abs(afternoon_data.Stim_Fly_Saw_At_Trigger),azi_cut);                           afternoon_total(end) = [];
            afternoon_jump = histc(abs(afternoon_data(afternoon_jump_logic,:).Stim_Fly_Saw_At_Trigger),azi_cut);    afternoon_jump(end) = [];

            morning_jump_rate = morning_jump ./  morning_total;
            afternoon_jump_rate = afternoon_jump ./  afternoon_total;
            total_jump_rate = (morning_jump + afternoon_jump) ./ (morning_total + afternoon_total);
            
            set(gca,'nextplot','add');
            scatter(0:45:90,morning_jump_rate,50,rgb('red'),'filled')
            scatter(0:45:90,afternoon_jump_rate,50,rgb('blue'),'filled')
            
            set(gca,'Ylim',[0 1],'Ytick',0:.1:1,'Ygrid','on');
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pathway_dist(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        filt_data = [];
        
        loom_string = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'uniformoutput',false);
        chrim_logic = cellfun(@(x) ~isempty(strfind(x,'None')),loom_string);
        photo_string = cellfun(@(x) x{1}, exp_info(chrim_logic,:).Photo_Activation,'uniformoutput',false);
        
        proto_string = loom_string;
        proto_string(chrim_logic) = photo_string;
                
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        [uni_parent,ia,~] = unique(parent_str);        
        all_data = [];
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            if ~isempty(strfind(uni_parent{iterZ},'Chrimson'))
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'all_data');            
            else
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'in_range');
            end
            filt_data = good_data;
            filt_data(cellfun(@(x) isempty(x),filt_data.frame_of_leg_push),:) = [];
            filt_data(cellfun(@(x) isnan(x),filt_data.frame_of_leg_push),:) = [];
            full_diff = cellfun(@(x,y) log((x-y)/6),filt_data.frame_of_take_off,filt_data.frame_of_wing_movement);
            all_data = [all_data;[num2cell(full_diff),repmat(Parent_A(ia(iterZ)),length(full_diff),1)]];
        end
        figure; 
        boxplot(cell2mat(all_data(:,1)),all_data(:,2));
        set(gca,'Ylim',[0 7])
        line([0 7],[log(7) log(7)]);
        
        table_counts = tabulate(all_data(:,2));
        text(1:1:6,repmat(6.5,6,1),cellfun(@(x) sprintf('%4.0f',x),table_counts(:,2),'uniformoutput',false));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function get_movement_info(~,~)
        all_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work)];
        pez_list = cellfun(@(x) x(8:14),all_data.Properties.RowNames,'uniformoutput',false);
        proto_list = cellfun(@(x) str2double(x(41:44)),all_data.Properties.RowNames);        
        
        pez_1_logic = cellfun(@(x) strcmp(x,'pez3001'),pez_list);        pez_2_logic = cellfun(@(x) strcmp(x,'pez3002'),pez_list);
        morning_logic = ismember(proto_list,[581,582,583]);              afternoon_logic = ismember(proto_list,[584,585,586]);
        
        figure;
        subplot(2,2,1)
        [f,x] = hist(all_data(pez_1_logic & morning_logic,:).Total_Movement,-90:10:90);
        f = f ./ max(f);        bar(x,f,'hist');
        subplot(2,2,2)
        [f,x] = hist(all_data(pez_1_logic & afternoon_logic,:).Total_Movement,-90:10:90);
        f = f ./ max(f);        bar(x,f,'hist');
        subplot(2,2,3)
        [f,x] = hist(all_data(pez_2_logic & morning_logic,:).Total_Movement,-90:10:90);
        f = f ./ max(f);        bar(x,f,'hist');
        subplot(2,2,4)
        [f,x] = hist(all_data(pez_2_logic & afternoon_logic,:).Total_Movement,-90:10:90);
        f = f ./ max(f);        bar(x,f,'hist');
        
        
    end
    function control_jump_pct(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
               
        uni_parent = unique(Parent_A);
        for iterZ = 1:length(uni_parent)
            figure
            parent_logic = ismember(Parent_A,uni_parent{iterZ});
            good_data = find_good_data(uni_parent{iterZ},parent_logic,'in_range');
            [~,jump_logic,rem_records,~] = get_jump_info(good_data);
            good_data(rem_records,:) = [];                  jump_logic(rem_records) = [];
            
            jump_color = zeros(length(jump_logic),3);
            jump_color(jump_logic,:) = repmat(rgb('red'),sum(jump_logic),1);
            jump_color(~jump_logic,:) = repmat(rgb('blue'),sum(~jump_logic),1);
            
            stim_fly_saw = good_data.Stim_Fly_Saw_At_Trigger;            
            org_fly_pos = good_data.fly_detect_azimuth + 360;
            org_fly_pos  = rem(rem(org_fly_pos ,360)+360,360);
            
            total_movement = good_data.Fly_Pos_At_Stim_Start - org_fly_pos;
            total_movement(total_movement > 180) = total_movement(total_movement > 180) - 360;
            total_movement(total_movement < -180) = total_movement(total_movement < -180) + 360;
            
            subplot(2,2,1);                                                    zero_azi = abs(good_data.Stim_Pos_At_Trigger) == 0;
            scatter(org_fly_pos(zero_azi),stim_fly_saw(zero_azi),50,jump_color(zero_azi,:),'filled');
            title('Zero degree Azimuth Protocol');
            line([0 360],[-15 -15],'color',rgb('black'),'linewidth',1);        line([0 360],[15 15],'color',rgb('black'),'linewidth',1);
            set(gca,'Xtick',0:30:360,'Xgrid','on');

            subplot(2,2,2);                                                    side_azi = abs(good_data.Stim_Pos_At_Trigger) == 45;
            scatter(org_fly_pos(side_azi),stim_fly_saw(side_azi),50,jump_color(side_azi,:),'filled');
            title('45 degree Azimuth Protocol');
            line([0 360],[60 60],'color',rgb('black'),'linewidth',1);          line([0 360],[30 30],'color',rgb('black'),'linewidth',1);
            line([0 360],[-60 -60],'color',rgb('black'),'linewidth',1);        line([0 360],[-30 -30],'color',rgb('black'),'linewidth',1);
            set(gca,'Xtick',0:30:360,'Xgrid','on');
            
            
            subplot(2,2,3);                                                    side_azi = abs(good_data.Stim_Pos_At_Trigger) == 90;
            scatter(org_fly_pos(side_azi),stim_fly_saw(side_azi),50,jump_color(side_azi,:),'filled');
            title('90 degree Azimuth Protocol');
            line([0 360],[75 75],'color',rgb('black'),'linewidth',1);          line([0 360],[105 105],'color',rgb('black'),'linewidth',1);
            line([0 360],[-75 -75],'color',rgb('black'),'linewidth',1);        line([0 360],[-105 -105],'color',rgb('black'),'linewidth',1);
            set(gca,'Xtick',0:30:360,'Xgrid','on');            
        end
    end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function giant_fiber_timing_plot(~,~)
        [good_data,geno_string,geno_table] = get_timing_info;
        filt_geno_logic = (ismember(geno_string,geno_table(cell2mat(geno_table(:,2)) > 20,1)));
        
        good_data = good_data(filt_geno_logic,:);
        geno_string = geno_string(filt_geno_logic);
        
        filt_data_gf = good_data(cellfun(@(x) ~isempty(strfind(x,'  Giant Fiber(27721)')),geno_string),:);
        delay_to_wing_lift_gf = cellfun(@(x,y) (x-y)/6,filt_data_gf.frame_of_wing_movement,filt_data_gf.start_frame);
        delay_to_wing_down_gf = cellfun(@(x,y) (x-y)/6,filt_data_gf.wing_down_stroke,filt_data_gf.start_frame);        
        
        delay_to_wing_lift_gf = log10(delay_to_wing_lift_gf)/log10(2);            delay_to_wing_down_gf = log10(delay_to_wing_down_gf)/log10(2);
        
        x_index = 0:1:10;           lights_off = log10(50)/log10(2);
        x_tick_label = [1,2,4,8,16,32,64,128,256,512,1024];
        x_tick = log10(x_tick_label)/log10(2);
        [upper_p, lower_p] = get_limit_estimates(delay_to_wing_lift_gf,delay_to_wing_down_gf);
        upper_estimate_lim = polyval(upper_p,x_index);                          lower_estimate_lim = polyval(lower_p,x_index);
        
        
        uni_geno = unique(geno_string);
        figure
        [x_plot,y_plot] = split_fig(length(uni_geno));
        for iterZ = 1:length(uni_geno)
            subplot(x_plot,y_plot,iterZ);
            filt_data = good_data(cellfun(@(x) ~isempty(strfind(x,uni_geno{iterZ})),geno_string),:);
            delay_to_wing_lift = cellfun(@(x,y) (x-y)/6,filt_data.frame_of_wing_movement,filt_data.start_frame);
            delay_to_wing_down = cellfun(@(x,y) (x-y)/6,filt_data.wing_down_stroke,filt_data.start_frame);
        
            delay_to_wing_lift = log10(delay_to_wing_lift)/log10(2);
            delay_to_wing_down = log10(delay_to_wing_down)/log10(2);
            
            if length(delay_to_wing_lift) < 20
                continue
            end
            
            scatter(delay_to_wing_lift,delay_to_wing_down);
            set(gca,'nextplot','add');
            plot(x_index,upper_estimate_lim,'-r','linewidth',1.2);
            plot(x_index,lower_estimate_lim,'-r','linewidth',1.2);            
            title(sprintf('%s',uni_geno{iterZ}));
            
            line([lights_off lights_off],[2 10],'color',rgb('black'),'linewidth',.8);
            line([2 10],[lights_off lights_off],'color',rgb('black'),'linewidth',.8);
            set(gca,'Xtick',x_tick,'Ytick',x_tick,'xticklabel',x_tick_label,'yticklabel',x_tick_label,'Xlim',[2 10],'Ylim',[2 10]);
            xlabel('Delay to Start of Wing Lift (ms)')
            ylabel('Delay to Start of Wing Down Stroke (ms)')
        end
    end
    function [upper_p, lower_p] = get_limit_estimates(delay_to_wing_lift,delay_to_wing_down)        
        lin_mdl = fitlm(delay_to_wing_lift,delay_to_wing_down);        
        residuals = (delay_to_wing_down -  polyval([lin_mdl.Coefficients.Estimate(2),lin_mdl.Coefficients.Estimate(1)],delay_to_wing_lift));                
        linear_component = delay_to_wing_lift.*lin_mdl.Coefficients.Estimate(2) + lin_mdl.Coefficients.Estimate(1);
        upper_lim = linear_component + (mean(residuals) +  std(residuals)*1.96);
        lower_lim = linear_component + (mean(residuals) -  std(residuals)*1.96);
        
        upper_p = polyfit(delay_to_wing_lift,upper_lim,1);        lower_p = polyfit(delay_to_wing_lift,lower_lim,1);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function take_off_pct_plots(~,~)
        new_height = 1.20;
        new_space = .10;
        compare_height  = 1.05;
%        post_testing = false;
        post_testing = true;
        show_counts = true;
                
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        filt_data = [];
        
        loom_string = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'uniformoutput',false);
        chrim_logic = cellfun(@(x) ~isempty(strfind(x,'None')),loom_string);
        photo_string = cellfun(@(x) x{1}, exp_info(chrim_logic,:).Photo_Activation,'uniformoutput',false);
        
        proto_string = loom_string;
        proto_string(chrim_logic) = photo_string;
                
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');        
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            if ~isempty(strfind(uni_parent{iterZ},'Chrimson'))
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'all_data');            
            else
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'in_range');
            end
            filt_data = [filt_data;good_data];
        end
        
        [~,jump_logic,rem_records,new_start] = get_jump_info(filt_data);
        filt_data(rem_records,:) = [];        jump_logic(rem_records) = [];
        new_start(rem_records) = [];
        
        leg_frame = filt_data.frame_of_leg_push;
        leg_frame(cellfun(@(x) isempty(x),leg_frame)) = num2cell(filt_data.autoFot(cellfun(@(x) isempty(x),leg_frame)));
        ontime_logic = (cellfun(@(x) isnan(x), leg_frame) | cell2mat(leg_frame) >= new_start);
                
        filt_data = filt_data(ontime_logic,:);
        jump_logic = jump_logic(ontime_logic,:);
        
        geno_string = cellfun(@(x) x(33:40),filt_data.Properties.RowNames,'uniformoutput',false);
        [locA,locB] = ismember(cellfun(@(x) x(41:44),filt_data.Properties.RowNames,'uniformoutput',false),cellfun(@(x) x(13:16),get(exp_info,'ObsNames'),'uniformoutput',false));
        proto_string = proto_string(locB(locA));

%        [~,locB] = ismember(geno_string,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'uniformoutput',false));        

        uni_geno = unique(geno_string,'stable');
%        temp_labels = convert_labels(uni_geno,'DN_convert',exp_info,'exp_str_8');
        temp_labels = uni_geno;
        [locA,locB] = ismember(geno_string,uni_geno);
        geno_string = temp_labels(locB(locA));

        [total_counts,~,~,total_labels] = crosstab(geno_string,proto_string);
        [jump_counts,~,~,jump_labels] = crosstab(geno_string(jump_logic),proto_string(jump_logic));
        
        total_counts = cell2table(num2cell(total_counts));
        total_counts.Properties.RowNames = total_labels(cellfun(@(x) ~isempty(x),total_labels(:,1)),1);
        total_counts.Properties.VariableNames = total_labels(cellfun(@(x) ~isempty(x),total_labels(:,2)),2);
        
        jump_counts = cell2table(num2cell(jump_counts));
        jump_counts.Properties.RowNames = jump_labels(cellfun(@(x) ~isempty(x),jump_labels(:,1)),1);
        jump_counts.Properties.VariableNames = jump_labels(cellfun(@(x) ~isempty(x),jump_labels(:,2)),2);
     
        locA = ismember(total_counts.Properties.VariableNames,jump_counts.Properties.VariableNames);
        if sum(~locA) > 0
            missing_data = cell2table(num2cell(zeros(height(jump_counts),sum(~locA))));
            missing_data.Properties.VariableNames =  total_counts.Properties.VariableNames(~locA);
            missing_data.Properties.RowNames =  jump_counts.Properties.RowNames;
            jump_counts = [jump_counts,missing_data];
        end
        
        [~,locB] = ismember(total_counts.Properties.VariableNames,jump_counts.Properties.VariableNames);
        jump_counts = jump_counts(:,locB);        
        
        locA = ismember(total_counts.Properties.RowNames,jump_counts.Properties.RowNames);
        if sum(~locA) > 0
            missing_data = cell2table(num2cell(zeros(sum(~locA),width(jump_counts))));
            missing_data.Properties.VariableNames =  jump_counts.Properties.VariableNames;
            missing_data.Properties.RowNames =  total_counts.Properties.RowNames(~locA);
            jump_counts = [jump_counts;missing_data];
        end
        
        [~,locB] = ismember(total_counts.Properties.RowNames,jump_counts.Properties.RowNames);
        jump_counts = jump_counts(locB,:);        
        
        jump_pct = cellfun(@(x,y) x./y,table2cell(jump_counts),table2cell(total_counts));
        
        figure
        proto_used = width(total_counts);
        [x_plot,y_plot] = split_fig(proto_used);     %how many subplots to make

        new_proto = convert_labels_2(total_counts.Properties.VariableNames);

        [new_proto,sort_idx] = sort(new_proto);
        total_counts = total_counts(:,sort_idx);
        jump_counts = jump_counts(:,sort_idx);            

        for iterZ = 1:proto_used
            uni_proto = new_proto(iterZ);
            jump_pct = cellfun(@(x,y) x./y,table2cell(jump_counts(:,iterZ)),table2cell(total_counts(:,iterZ)));
            new_labels = total_counts.Properties.RowNames(~isnan(jump_pct));                

            subplot(x_plot,y_plot,iterZ)
%            new_labels_1 = convert_labels(new_labels,'Genotype_many',exp_info,'exp_str_8');

            jump_pct(isnan(jump_pct)) = [];
%            [sort_order] = sort_by_ctrl(new_labels,jump_pct);            
            sort_order = make_sort_order(new_labels);

            new_labels = new_labels(sort_order);
            jump_pct = jump_pct(sort_order);
            sort_counts = total_counts(sort_order,:);

            hb = make_bar_plot(jump_pct,new_labels,45,'right',uni_proto{1},new_height,new_space,14,25);
            set(gca,'fontsize',15);
            patch_ctrl_lines(hb,new_labels,rgb('grey'));
            
            if show_counts == true
                total_N = cell2mat(table2cell(sort_counts(:,iterZ)));
                text(1:1:height(sort_counts),repmat(new_height-new_space,height(sort_counts),1),arrayfun(@(x) sprintf('%3.0f',x),total_N,'uniformoutput',false),...
                    'Interpreter','none','HorizontalAlignment','center','fontsize',15);
            end
            
            if post_testing == true
                add_error_bars(gca,cell2mat(table2cell(jump_counts(sort_order,iterZ))),cell2mat(table2cell(total_counts(sort_order,iterZ))));

                result_matrix = find_p_values(table2cell(jump_counts(sort_order,iterZ)),table2cell(total_counts(sort_order,iterZ)));
                dl_compare = result_matrix(1,:);

                num_samp = length(dl_compare) - 1;
                for iterD  = 1:length(dl_compare)
                    if dl_compare(iterD) < (0.001/num_samp)
                        text(iterD,compare_height,'***','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                    elseif dl_compare(iterD) < (0.01/num_samp)
                        text(iterD,compare_height,'**','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                    elseif dl_compare(iterD) < (0.05/num_samp)
                        text(iterD,compare_height,'*','Interpreter','none','HorizontalAlignment','center','fontsize',15);
                    end
                end
            end
        end
        ylabel('Take off Percent','fontsize',15)
    end  
    function [filt_data,geno_string,geno_table] = get_timing_info(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;
        filt_data = [];
        
        loom_string = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),exp_info.Stimuli_Type,exp_info.Elevation,exp_info.Azimuth,'uniformoutput',false);
        chrim_logic = cellfun(@(x) ~isempty(strfind(x,'None')),loom_string);
        photo_string = cellfun(@(x) x{1}, exp_info(chrim_logic,:).Photo_Activation,'uniformoutput',false);
        
        proto_string = loom_string;
        proto_string(chrim_logic) = photo_string;
                
        Parent_A = exp_info.ParentA_name;                 Parent_B = exp_info.ParentB_name;
        parent_str = cellfun(@(x,y) sprintf('%s :: %s',x,y),Parent_A,Parent_B,'uniformoutput',false);
        uni_parent = unique(parent_str,'stable');        
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_str,uni_parent{iterZ});
            if ~isempty(strfind(uni_parent{iterZ},'Chrimson'))
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'all_data');            
            else
                good_data = find_good_data(uni_parent{iterZ},parent_logic,'in_range');
            end
            filt_data = [filt_data;good_data];
        end
        
        [~,jump_logic,rem_records,new_start] = get_jump_info(filt_data);
        filt_data(rem_records,:) = [];        jump_logic(rem_records) = [];
        new_start(rem_records) = [];
        
        leg_frame = filt_data.frame_of_leg_push;
        leg_frame(cellfun(@(x) isempty(x),leg_frame)) = num2cell(filt_data.autoFot(cellfun(@(x) isempty(x),leg_frame)));
        ontime_logic = (cellfun(@(x) isnan(x), leg_frame) | cell2mat(leg_frame) >= new_start);
                
        filt_data = filt_data(ontime_logic,:);
        jump_logic = jump_logic(ontime_logic,:);
        
        geno_string = cellfun(@(x) x(33:40),filt_data.Properties.RowNames,'uniformoutput',false);

        uni_geno = unique(geno_string,'stable');
        temp_labels = convert_labels(uni_geno,'DN_convert',exp_info,'exp_str_8');
        [locA,locB] = ismember(geno_string,uni_geno);
        geno_string = temp_labels(locB(locA));
        leg_frame = filt_data.frame_of_leg_push;

        geno_string(cellfun(@(x) isempty(x), leg_frame)) = [];        filt_data(cellfun(@(x) isempty(x), leg_frame),:) = [];
        leg_frame(cellfun(@(x) isempty(x), leg_frame)) = [];
        
        geno_string(cellfun(@(x) isnan(x), leg_frame)) = [];        filt_data(cellfun(@(x) isnan(x), leg_frame),:) = [];
        
        geno_table = tabulate(geno_string);        
    end
    function take_off_timing_plot(~,~) 
        compress_form = true;
%        compress_form = false;
        
        [filt_data,geno_string,geno_table] = get_timing_info;       
        test_timing = cellfun(@(x,y) (x-y)/6, filt_data.frame_of_wing_movement,filt_data.start_frame);        
%        test_timing = cellfun(@(x,y) (x-y)/6, filt_data.frame_of_take_off,filt_data.start_frame);
%        test_timing = cellfun(@(x,y) (x-y)/6, filt_data.frame_of_leg_push,filt_data.start_frame);
        if compress_form == true
            mod_timing = (log10(test_timing/50)/log10(2))+1;
        else
            mod_timing = test_timing;
        end
        pez_string = cellfun(@(x) x(8:14),filt_data.Properties.RowNames,'uniformoutput',false);
        gender_string = filt_data.Gender;
                
        [y_data,x_data,~] = iosr.statistics.tab2box(geno_string,mod_timing);
        [locA,locB] = ismember(x_data,geno_table(:,1));
        geno_table = geno_table(locB(locA),:);
        low_data = cell2mat(geno_table(:,2)) < 20;        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % only use for full chrimson data
        sort_order = make_sort_order(x_data);
         
         y_data = y_data(:,sort_order);          x_data = x_data(sort_order);
         low_data = low_data(sort_order);        
         y_data = y_data(:,~low_data);          x_data = x_data(~low_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        figure
        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('dark green'),'scatterMarker','.','scatterSize',250,'linewidth',0.05,'linecolor',rgb('black'),...
                   'showViolin', true,'violinColor',rgb('light blue'),'violinAlpha',0.5);            

        new_x_pos = 1:1:length(x_data);    
        if compress_form == true
            h_patch = patch([(min(new_x_pos) - .5) (min(new_x_pos) - .5) (max(new_x_pos) + .5) (max(new_x_pos) + .5)],[-3 1 1 -3],rgb('light red'));        
            y_tick_label = 50*2.^((-3:1:5)-1);            
            set(gca,'Ylim',[-3 5],'Ytick',-3:1:5,'yticklabel',y_tick_label,'fontsize',14);

            ylabel('Time after lights on (base(2) ms)','fontsize',14);                        
        else
            h_patch = patch([(min(new_x_pos) - .5) (min(new_x_pos) - .5) (max(new_x_pos) + .5) (max(new_x_pos) + .5)],[0 50 50 0],rgb('light red'));        
            y_tick_label = 0:100:800;
            set(gca,'Ylim',[0 800],'Ytick',0:100:800,'yticklabel',y_tick_label,'fontsize',14);
            ylabel('Time after lights on (ms)','fontsize',14);            
        end
        title('Time between lights on and take of take off','fontsize',20);

        set(h_patch,'FaceAlpha',.1,'Edgecolor',rgb('light red'),'EdgeAlpha',.1);
        set(gca,'Xtick',[]);
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(x_data),1);                              
        hText = text(new_x_pos, y, x_data,'parent',gca);                

        set(hText,'Rotation',45,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',14);
        set(gca,'Xlim',[(min(new_x_pos) - .5) (max(new_x_pos) + .5)]);        
    end
    function pathway_timing(hObj,~)
        selection = get(hObj,'Userdata');
        [filt_data,geno_string,geno_table] = get_timing_info;

        wing_leg = cellfun(@(x,y) (x-y)/6, filt_data.frame_of_leg_push,filt_data.frame_of_wing_movement);
        leg_down = cellfun(@(x,y) (x-y)/6, filt_data.wing_down_stroke,filt_data.frame_of_leg_push);
        down_jump = cellfun(@(x,y) (x-y)/6, filt_data.frame_of_take_off,filt_data.wing_down_stroke);
        
        unsure_data = wing_leg == 0 | leg_down == 0 | down_jump == 0;
        wing_leg(unsure_data) = [];         leg_down(unsure_data) = [];
        down_jump(unsure_data) = [];        geno_string(unsure_data) = [];
        
        leg_cycle = leg_down + down_jump;
        wing_cycle = leg_down + wing_leg;
        full_diff = wing_leg + leg_down + down_jump;

        if selection == 1

            mod_timing = (log10(wing_cycle/2.5)/log10(2));
            ylimits = [-4 8];
            y_tick = [(log10([.25,.5,1]./2.5)/log10(2)),-1:1:8];            y_tick_label = 2.5*2.^(y_tick);
            y_lab_str = 'Wings up to Wings Down ms (2.5 * base 2)';
            title_str = sprintf('Duration Between Start of Wing Lift and first Wing Downstroke\nin base 2 millisecond scale');
        elseif selection == 2
            ylimits = [0 10];   y_tick = 0:1:10;             y_tick_label = y_tick;
            mod_timing = leg_cycle;  
            y_lab_str = 'Leg Push to Take off ms';
            title_str = sprintf('Duration Between Start of Leg Push and Take off');
        elseif selection == 3
            mod_timing = (log10(full_diff/2.5)/log10(2));
            ylimits = [0 8];
            y_tick = [(log10([.25,.5,1]./2.5)/log10(2)),-1:1:8];            y_tick_label = 2.5*2.^(y_tick);            
            y_lab_str = 'Wings up to Take off ms (2.5 * base 2)';
            title_str = sprintf('Duration Between Wing Lift and Take off\nin base 2 millisecond scale');
        elseif selection == 4
            y_tick = [(log10([.25,.5,1]./2.5)/log10(2)),-1:1:8];            y_tick_label = 2.5*2.^(y_tick);                        
            ylimits = [-4 8];            
            mod_timing =  (log10(wing_leg/2.5)/log10(2));
            y_lab_str = 'Wings up to Take off ms (2.5 * base 2)';
            title_str = sprintf('Duration Between Wing Lift and Start of Leg push\nin base 2 millisecond scale');
        elseif selection == 5
            mod_timing = leg_down;
            ylimits = [0 6];   y_tick = 0:.5:6;             y_tick_label = y_tick;
            y_lab_str = 'Milliseconds';            
            title_str = sprintf('Duration Between Leg Push to Wing Down stroke');
        elseif selection == 6
            mod_timing =  down_jump;
            ylimits = [0 10];    y_tick = 0:1:10;             y_tick_label = y_tick;
            y_lab_str = 'Milliseconds';
            title_str = sprintf('Duration Between Wing Downstroke to Take off Frame');            
        end        
        
        [y_data,x_data,~] = iosr.statistics.tab2box(geno_string,mod_timing);
        [locA,locB] = ismember(x_data,geno_table(:,1));
        geno_table = geno_table(locB(locA),:);
        low_data = cell2mat(geno_table(:,2)) < 20;        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % only use for full chrimson data
         sort_order = make_sort_order(x_data);
         y_data = y_data(:,sort_order);          x_data = x_data(sort_order);
         low_data = low_data(sort_order);
        
         y_data = y_data(:,~low_data);          x_data = x_data(~low_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        figure
        scat_color = ([{rgb('black')};{rgb('black')};{rgb('red')};{rgb('red')};repmat({rgb('green')},20,1)]);
        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('purple'),'scatterMarker','.','scatterSize',250,'linewidth',0.05,'linecolor',rgb('black'),...
                   'showViolin', true,'violinColor',rgb('light blue'),'violinAlpha',0.25);            

        new_x_pos = 1:1:length(x_data);       
        if selection == 3        
            h_patch = patch([(min(new_x_pos) - .5) (min(new_x_pos) - .5) (max(new_x_pos) + .5) (max(new_x_pos) + .5)],[0 1.5 1.5 0],rgb('light red'));
            set(h_patch,'FaceAlpha',.1,'Edgecolor',rgb('light red'),'EdgeAlpha',.1);
        end
                
        set(gca,'Xtick',[],'Ylim',ylimits,'Ytick',y_tick,'yticklabel',y_tick_label,'fontsize',14);
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(x_data),1);                              
        hText = text(new_x_pos, y, x_data,'parent',gca);                

        set(hText,'Rotation',45,'HorizontalAlignment','right','Color',rgb('black'),'Interpreter','none','fontsize',14);
        set(gca,'Xlim',[(min(new_x_pos) - .5) (max(new_x_pos) + .5)]);          
        
        line_count = size(y_data,2);
        result_matrix = zeros(line_count);
        for iterZ = 1:line_count
            for iterQ = iterZ:line_count
                result_matrix(iterZ,iterQ) = ranksum(y_data(:,iterZ),y_data(:,iterQ));
            end
        end        
        color_scatter(h,x_data);
        
        gf_data = y_data(:,cellfun(@(x) ~isempty(strfind(x,'  Giant Fiber')),x_data));
        gf_data(isnan(gf_data)) = [];
        
        lower_limit = mean(gf_data)-1.96*std(gf_data);
        upper_limit = mean(gf_data)+1.96*std(gf_data);
        line([(min(new_x_pos) - .5) (max(new_x_pos) + .5)],[lower_limit lower_limit],'color',rgb('gray'),'linewidth',1.2);
        line([(min(new_x_pos) - .5) (max(new_x_pos) + .5)],[upper_limit upper_limit],'color',rgb('gray'),'linewidth',1.2);
        
        title(title_str,'fontsize',20);
        ylabel(y_lab_str,'fontsize',14);            
        
    end
    function color_scatter(h,x_data)
        try
            h.handles.scatters(cellfun(@(x) ~isempty(strfind(x,'   DL Wildtype')),x_data)).MarkerEdgeColor = rgb('black');
        catch
        end
        try
            h.handles.scatters(cellfun(@(x) ~isempty(strfind(x,'   SS01062')),x_data)).MarkerEdgeColor = rgb('black');
        catch
        end        
        try
            h.handles.scatters(cellfun(@(x) ~isempty(strfind(x,'  Giant Fiber(0727)')),x_data)).MarkerEdgeColor = rgb('red');
        catch
        end
        try
            h.handles.scatters(cellfun(@(x) ~isempty(strfind(x,'  Giant Fiber(27721)')),x_data)).MarkerEdgeColor = rgb('red');
        catch
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function patch_ctrl_lines(plot_handle,new_labels,patch_color)
        patch_bars(plot_handle,'DL Wildtype',new_labels,patch_color);
        patch_bars(plot_handle,'CTRL_DL_1500090',new_labels,patch_color);
        
        patch_bars(plot_handle,'L1, L2',new_labels,patch_color);                
        patch_bars(plot_handle,'SS00797',new_labels,patch_color);
        
        patch_bars(plot_handle,'SS01062',new_labels,patch_color);
        
        patch_bars(plot_handle,'Giant Fiber',new_labels,patch_color);
        patch_bars(plot_handle,'SS27721',new_labels,patch_color);
        patch_bars(plot_handle,'17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)',new_labels,patch_color);
    end
    function hb = make_bar_plot(jump_pct,new_labels,rotation,align,title_str,new_height,new_space,font_label,font_title)
        hb = bar(jump_pct);
        set(hb,'facecolor',rgb('light blue'));
        set(gca,'Ylim',[0 new_height],'Xtick',[]);

%        rotation = 45;                                               align = 'right';                
        hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
        y = repmat(y,length(new_labels),1);                          new_x_pos = 1:1:length(jump_pct);
%        y = y - .025;
        hText = text(new_x_pos, y, new_labels,'parent',gca);                

        set(hText,'Rotation',rotation,'HorizontalAlignment',align,'Color',rgb('black'),'Interpreter','none','fontsize',font_label);                
        title(sprintf('%s',title_str),'Interpreter','none','HorizontalAlignment','center','fontsize',font_title);          
        set(gca,'Ytick',0:new_space:(new_height-new_space*2),'Ygrid','on');        
    end
    function patch_bars(hb,test_label,new_labels,bar_color)
        bar_x_data = get(hb,'Xdata');   bar_y_data = get(hb,'Ydata');
                
        dl_pos = cellfun(@(x) ~isempty(strfind(x,test_label)),new_labels);
        dl_pos = find(dl_pos>0);
        for iterZ = 1:length(dl_pos)
            if dl_pos(iterZ) > 0
                patch([(bar_x_data(dl_pos(iterZ))-.4) (bar_x_data(dl_pos(iterZ))-.4) (bar_x_data(dl_pos(iterZ))+.4) (bar_x_data(dl_pos(iterZ))+.4)],...
                      [0 bar_y_data(dl_pos(iterZ)) bar_y_data(dl_pos(iterZ)) 0],bar_color,'parent',gca);
            end
        end        
    end
    function result_matrix = find_p_values(jumpers,total_counts)
        result_matrix = zeros(length(jumpers));
        
        if iscell(jumpers)
            jumpers = cell2mat(jumpers);
        end
        if iscell(total_counts)
            total_counts = cell2mat(total_counts);
        end        
        
        for iterZ = 1:length(jumpers)
            for iterL = 1:length(jumpers)
                pulled_p = (jumpers(iterZ) + jumpers(iterL)) / (total_counts(iterZ) + total_counts(iterL));
                bot_val = sqrt(pulled_p * (1-pulled_p) * ((1/total_counts(iterZ))+(1/total_counts(iterL))));
                top_val = abs(jumpers(iterZ)/total_counts(iterZ) - jumpers(iterL) / total_counts(iterL));
                z_score = top_val ./ bot_val;
                result_matrix(iterZ,iterL) =  2*(1-normcdf(z_score));
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function pez_temp_jump(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
                
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        Parent_B = exp_info.ParentB_name;    
        
        Parent_A = convert_labels(Parent_A,'DN_convert',exp_info,'geno_string');
        
        [uni_parent,uni_loc] = unique(Parent_A);
        uni_parB = Parent_B(uni_loc);
        
%        figure
        for iterZ = 1:length(uni_parent)
%            subplot(4,5,iterZ);
figure
            parent_logic = ismember(Parent_A,uni_parent{iterZ});
            good_data = find_good_data(uni_parB{iterZ},parent_logic,'all_data');
            pez_temp = good_data.temp_degC;
            [~,jump_logic,rem_records,new_start_frame] = get_jump_info(good_data);
            good_data(rem_records,:) = [];        jump_logic(rem_records) = [];            new_start_frame(rem_records) = [];

            good_data(cellfun(@(x) isempty(x), good_data.frame_of_leg_push),:) = [];
            good_data(cellfun(@(x) isnan(x), good_data.frame_of_leg_push),:) = [];
            
            temp_cluster = zeros(length(good_data.temp_degC),1);
            for iterT = 22:.5:25
                temp_cluster((good_data.temp_degC < iterT+.25) & (good_data.temp_degC >= iterT-.25)) = iterT;
            end
            wing_cycle = cellfun(@(x,y) log10((x-y)./6 /log10(2)),good_data.wing_down_stroke,good_data.frame_of_wing_movement);
                        
            [y_data,x_data,~] = iosr.statistics.tab2box(temp_cluster,wing_cycle);
            
            jump_counts = size(y_data,1) - sum(arrayfun(@(x) isnan(x),y_data),1);
            keep_data = jump_counts > 1;
            if isempty(x_data(keep_data))
                continue
            end
            h = iosr.statistics.boxPlot(x_data(keep_data),y_data(:,keep_data),'symbolColor','k','medianColor','k','symbolMarker','+',...
                   'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('purple'),'scatterMarker','.','scatterSize',250,'linewidth',0.05,'linecolor',rgb('black'),...
                   'showViolin', false,'violinColor',rgb('light blue'),'violinAlpha',0.25);            
            
            h.groupWidth = .75;
           
            set(gca,'nextplot','add');
            scatter(x_data(~keep_data),y_data(1,~keep_data));
            
            set(gca,'Xlim',[21.5 24.5],'Xtick',22:.5:24,'Xticklabel',22:.5:24);
            for iterL = 21.75:.5:25
                line([iterL iterL],[0 4],'color',rgb('light grey'),'linewidth',.7);
            end
            title(sprintf('%s',uni_parent{iterZ}));
        end        
    end
    function new_labels = convert_labels_2(old_labels)                           %converts proto string into readable text
        new_labels = cell(length(old_labels),1);
        chrim_logic = cellfun(@(x) ~isempty(strfind(x,'intensity')),old_labels);
        photo_str = old_labels(chrim_logic);
        if ~isempty(photo_str)
            intensity_index = cellfun(@(x) strfind(x,'intensity'),photo_str);
            duration_start = cellfun(@(x) strfind(x,'Begin'),photo_str);
            duration_end = cellfun(@(x) strfind(x,'_widthEnd'),photo_str);
            intensity_used = cellfun(@(x,y) str2double(x(y+9:end)),photo_str,num2cell(intensity_index));
            duration_used = cellfun(@(x,y,z) str2double(x(y+5:z-1)),photo_str,num2cell(duration_start),num2cell(duration_end));
            new_labels(chrim_logic) = cellfun(@(x,y) sprintf('%3.0f%% Intensity,\n%5.0fms',x,y),num2cell(intensity_used),num2cell(duration_used),'uniformoutput',false);        
        end
        if sum(~chrim_logic) > 0
            new_labels(~chrim_logic) = old_labels(~chrim_logic);
        end
    end
    function [sort_order,new_labels] = make_sort_order(new_labels)
        dl_logic = cellfun(@(x) (~isempty(strfind(x,'DL Wildtype'))),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);
        
        dl_logic = cellfun(@(x) (~isempty(strfind(x,'SS01062'))),new_labels);                
        new_labels(dl_logic) = cellfun(@(x) sprintf('   %s',x),new_labels(dl_logic),'uniformoutput',false);
        
        gf_logic = cellfun(@(x) (~isempty(strfind(x,'Giant Fiber'))),new_labels);                
        new_labels(gf_logic) = cellfun(@(x) sprintf('  %s',x),new_labels(gf_logic),'uniformoutput',false);                

        single_logic = cellfun(@(x) isempty(strfind(x,',')),new_labels);
        new_labels(single_logic) = cellfun(@(x) sprintf(' %s',x),new_labels(single_logic),'uniformoutput',false);                                
        
        [~,sort_order] = sort(new_labels);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function wsi = get_error_bars(jumpers,total)                        %finds error bars
        x = jumpers;
        n = total;
        alpha = .05;
        phat =  x./n;
        z=sqrt(2).*erfcinv(alpha);
        den=1+(z^2./n);xc=(phat+(z^2)./(2*n))./den;
        halfwidth=(z*sqrt((phat.*(1-phat)./n)+(z^2./(4*(n.^2)))))./den;
        wsi=[xc(:) xc(:)]+[-halfwidth(:) halfwidth(:)];
%        wsi = wsi .* 100;
    end
    function add_error_bars(curr_plot,jumpers, total)                   %draws error bars on the graph
        wsi = get_error_bars(jumpers,total);
                
        for iterZ = 1:length(jumpers)
            line([iterZ iterZ],[wsi(iterZ,1) wsi(iterZ,2)],'parent',curr_plot,'linewidth',.7,'color',rgb('black'));
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function lights_on_to_wing_lift(~,~)
        sep_date = 'date_list';
%        sep_date = 'collection_list';
        [good_data,geno_string,geno_table] = get_timing_info;
        filt_geno_logic = (ismember(geno_string,geno_table(cell2mat(geno_table(:,2)) > 20,1)));
        
        good_data = good_data(filt_geno_logic,:);
        geno_string = geno_string(filt_geno_logic);
        geno_string(cellfun(@(x) ~isempty(strfind(x,'   DL Wildtype')),geno_string)) = [];
        
%        filt_data_gf = good_data(cellfun(@(x) ~isempty(strfind(x,'  Giant Fiber(27721)')),geno_string),:);            
        filt_data_gf = good_data(cellfun(@(x) ~isempty(strfind(x,'Giant Fiber')),geno_string),:);
        
        [~,jump_logic,rem_records,new_start_frame] = get_jump_info(filt_data_gf);
        filt_data_gf(rem_records,:) = [];          jump_logic(rem_records) = [];       new_start_frame(rem_records) = [];
                
        pez_list = cellfun(@(x) x(8:14),filt_data_gf.Properties.RowNames,'uniformoutput',false);
        wing_lift_time = (cell2mat(filt_data_gf.frame_of_wing_movement) - new_start_frame)./6;
        wing_down_time = (cell2mat(filt_data_gf.wing_down_stroke) - new_start_frame)./6;
        leg_push_time = (cell2mat(filt_data_gf.frame_of_leg_push) - new_start_frame)./6;
        take_off_time = (cell2mat(filt_data_gf.frame_of_take_off) - new_start_frame)./6;
                
        gender_list = filt_data_gf.Gender;
        date_list = cellfun(@(x) x(16:21),filt_data_gf.Properties.RowNames,'uniformoutput',false);
        
        date_counts = tabulate(date_list);

        figure;
        if strcmp(sep_date,'pez_list')
            keep_records = cellfun(@(x) isempty(strfind(x,'pez3003')),pez_list) & new_start_frame > 100 &  wing_lift_time < 60;
            [y_data,x_data,test_group] = iosr.statistics.tab2box(pez_list(keep_records),wing_lift_time(keep_records),gender_list(keep_records));            
            plot_scatter_data(y_data,x_data,test_group);                  title('time dely to start of wing lift');
        elseif strcmp(sep_date,'date_list')
            date_logic = ismember(date_list,date_counts(cell2mat(date_counts(:,2)) >= 50,1));
            keep_records = date_logic & new_start_frame > 100 &  wing_lift_time < 60;
            [y_data_w,x_data_w,test_group_w] = iosr.statistics.tab2box(date_list(keep_records),wing_lift_time(keep_records),gender_list(keep_records));
            
            [y_data_l,x_data_l,test_group_l] = iosr.statistics.tab2box(date_list(keep_records),leg_push_time(keep_records),gender_list(keep_records));
            [y_data_d,x_data_d,test_group_d] = iosr.statistics.tab2box(date_list(keep_records),wing_down_time(keep_records),gender_list(keep_records));
            [y_data_t,x_data_t,test_group_t] = iosr.statistics.tab2box(date_list(keep_records),take_off_time(keep_records),gender_list(keep_records));
        end
        
        subplot(2,2,1); plot_scatter_data(y_data_w,x_data_w,test_group_w);      title('time dely to start of wing lift');
        subplot(2,2,2); plot_scatter_data(y_data_l,x_data_l,test_group_l);      title('time dely to start of leg push');
        subplot(2,2,3); plot_scatter_data(y_data_d,x_data_d,test_group_d);      title('time dely to start of wing down stroke');
        subplot(2,2,4); plot_scatter_data(y_data_t,x_data_t,test_group_t);      title('time dely to start of toe off');

    end
    function plot_scatter_data(y_data,x_data,test_group)
        new_y_tick = 0:5:60;        new_y_tick_labels = 0:5:60;
        
        h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                       'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',125,...
                       'linewidth',0.05,'linecolor',rgb('black'),'showViolin', true,'violinColor',rgb('light orange'),'violinAlpha',0.15,'showLegend',true);            
        h.groupLabels = test_group;
        
        h.scatterColor(1) = {rgb('dark red')};      h.violinColor(2) = {rgb('light red')};
        h.scatterColor(2) = {rgb('dark blue')};     h.violinColor(2) = {rgb('light blue')};
        set(gca,'Ytick',new_y_tick,'Ygrid','on','Yticklabels',new_y_tick_labels)
        
        h.handles.legend.FontSize = 35;
        h.handles.legend.Orientation = 'horizontal';
        h.handles.legend.Location = 'best';
        set(gca,'Ylim',[0 60]);        
    end

    function fly_profile(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        proto_string = exp_info.Stimuli_Type;
        Parent_A = exp_info.ParentA_name;
        
%        parent_logic = cellfun(@(x) strcmp(x,'1500487'),exp_info.ParentA_ID);
%        parent_logic = cellfun(@(x) strcmp(x,'1500090'),exp_info.ParentA_ID);
        parent_logic = cellfun(@(x) strcmp(x,'3027963'),exp_info.ParentA_ID);
%        parent_logic = cellfun(@(x) strcmp(x,'3027964'),exp_info.ParentA_ID);
%        parent_logic = cellfun(@(x) strcmp(x,'3027779'),exp_info.ParentA_ID);
        good_data = find_good_data('UAS_Chrimson_Venus_X_0070VZJ_K_45195',parent_logic,'all_data');
        good_data(cellfun(@(x) isempty(x), good_data.frame_of_leg_push),:) = [];
        
        [~,jump_logic,rem_records,new_start_frame] = get_jump_info(good_data);
        good_data(rem_records,:) = [];          jump_logic(rem_records) = [];       new_start_frame(rem_records) = [];
        
        remove_data = cellfun(@(x) isempty(x),good_data.bot_points_and_thetas);
        good_data(remove_data,:) = [];          jump_logic(remove_data) = [];       new_start_frame(remove_data) = [];
        
        last_frame = zeros(length(new_start_frame),1);
        last_frame(jump_logic) = cell2mat(good_data(jump_logic,:).frame_of_leg_push);
        last_frame(~jump_logic) = good_data(~jump_logic,:).trkEnd;
        tracking_count = cellfun(@(x) length(x), good_data.bot_points_and_thetas);
        last_frame(last_frame>tracking_count) = tracking_count(last_frame>tracking_count);
        
        new_cut_frame_idx = cellfun(@(x,y,z) double(x(x <= y & x >= z)),good_data.cutrate10th_frame_reference,num2cell(last_frame),num2cell(new_start_frame),'uniformoutput',false);
        
        tracking_data = cellfun(@(x,y) x(y,:),good_data.bot_points_and_thetas,new_cut_frame_idx,'uniformoutput',false);
        gender_list = good_data.Gender;
        
        zeroed_data = cellfun(@(x) [x(:,1) - x(1,1),x(:,2) - x(1,2),x(:,3)],tracking_data,'uniformoutput',false);
        rotated_data = cellfun(@(x) [rotation([x(:,1),x(:,2)],[0,0],(2*pi - x(1,3)),'radians'),x(:,3) - x(1,3)],zeroed_data,'uniformoutput',false);

        avg_speed = zeros(length(rotated_data),1);
        for iterZ = 1:length(rotated_data);
            test_data = rotated_data{iterZ}; 
            x_cord = test_data(:,1);            y_cord = test_data(:,2);    r_cord = test_data(:,2);
            r_cord = rem(rem(r_cord,(2*pi))+(2*pi),(2*pi));
            z_cord = new_cut_frame_idx{iterZ}';
            
            figure; set(gca,'nextplot','add');
            scatter3(x_cord,y_cord,new_cut_frame_idx{iterZ});            
            u = cos(r_cord)*25;
            v = -sin(r_cord)*25;
            w = zeros(length(r_cord),1);            
            
            for iterX = 1:length(x_cord)
                quiver3(x_cord(iterX),y_cord(iterX),z_cord(iterX),u(iterX),v(iterX),w(iterX),'LineWidth',1.2,'AutoScaleFactor',1,'color',rgb('orange'));
            end

%            set(hQuiv(index),'XData',roi(1)+avgPrismL/2,'YData',(vidHeight-(roi(2)+avgPrismL/2)),...
%                'MaxHeadSize',5,'LineWidth',line_length,'AutoScaleFactor',1,'color',color,'UData',u,'VData',v,'visible','on')            

            
%            euclideanDistance = [0;sqrt((x_cord(2:end) - x_cord(1:(end-1))).^2 + (y_cord(2:end) - y_cord(1:(end-1))).^2)];            
%            avg_speed(iterZ) = max(abs(diff(euclideanDistance)));            
        end
        
%        rotate_cords = rotation([x_cord,y_cord],[0,0],(2*pi - sample_data(1,3)),'radians');        
        figure; 
        [y_data,x_data,test_group] = iosr.statistics.tab2box(num2cell(jump_logic),avg_speed',gender_list);
        h = iosr.statistics.boxPlot([0 1],y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                       'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',125,...
                       'linewidth',0.05,'linecolor',rgb('black'),'showViolin', true,'violinColor',rgb('light orange'),'violinAlpha',0.15,'showLegend',true);            
        h.groupLabels = test_group;
        
        h.scatterColor(1) = {rgb('dark red')};      h.violinColor(2) = {rgb('light red')};
        h.scatterColor(2) = {rgb('dark blue')};     h.violinColor(2) = {rgb('light blue')};
        
        
        
        figure
        pos_x_pos_y = subplot(3,3,3);    set(pos_x_pos_y,'nextplot','add');
        pos_x_mid_y = subplot(3,3,6);    set(pos_x_mid_y,'nextplot','add');
        pos_x_neg_y = subplot(3,3,9);    set(pos_x_neg_y,'nextplot','add');
        
        neg_x_pos_y = subplot(3,3,1);    set(neg_x_pos_y,'nextplot','add');
        neg_x_mid_y = subplot(3,3,4);    set(neg_x_mid_y,'nextplot','add');
        neg_x_neg_y = subplot(3,3,7);    set(neg_x_neg_y,'nextplot','add');
        
        mid_x_pos_y = subplot(3,3,2);    set(mid_x_pos_y,'nextplot','add');
        mid_x_mid_y = subplot(3,3,5);    set(mid_x_mid_y,'nextplot','add');        
        mid_x_neg_y = subplot(3,3,8);    set(mid_x_neg_y,'nextplot','add');
                
        plot_counts = zeros(3,3);        jump_counts = zeros(3,3);
        for iterZ = 1:length(tracking_data)
            sample_data = tracking_data{iterZ};
            try
            x_cord = sample_data(:,1);      x_cord = x_cord - x_cord(1);        %centers to (0,0)
            y_cord = sample_data(:,2);      y_cord = y_cord - y_cord(1);
            catch
                warning('error?')
            end

            if jump_logic(iterZ)
                last_cord = good_data.frame_of_leg_push{iterZ} - new_start_frame(iterZ);
                if last_cord > good_data.trkEnd(iterZ);
                    last_cord = good_data.trkEnd(iterZ) - new_start_frame(iterZ);
                end
                if last_cord >  (50+00)*6;
                    continue
                end
            else
                last_cord = (50+00)*6;
%                last_cord = good_data.trkEnd(iterZ) - new_start_frame(iterZ);
            end
            if last_cord > length(rotate_cords);
                last_cord = length(rotate_cords);
            end
            try
                rotate_cords = rotate_cords(1:last_cord,:);
            if abs(rotate_cords(last_cord,1)) <= 10 && abs(rotate_cords(last_cord,2)) <= 10 
                plot(mid_x_mid_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(2,2) = plot_counts(2,2) + 1;
                jump_counts(2,2) = jump_counts(2,2) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) < -10 && rotate_cords(last_cord,2) > 10 
                plot(neg_x_pos_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(1,1) = plot_counts(1,1) + 1;
                jump_counts(1,1) = jump_counts(1,1) + jump_logic(iterZ);
            elseif abs(rotate_cords(last_cord,1)) <= 10 && rotate_cords(last_cord,2) > 10 
                plot(mid_x_pos_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(1,2) = plot_counts(1,2) + 1;
                jump_counts(1,2) = jump_counts(1,2) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) > 10 && rotate_cords(last_cord,2) > 10 
                plot(pos_x_pos_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(1,3) = plot_counts(1,3) + 1;
                jump_counts(1,3) = jump_counts(1,3) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) < -10 && abs(rotate_cords(last_cord,2)) <= 10 
                plot(neg_x_mid_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(2,1) = plot_counts(2,1) + 1;
                jump_counts(2,1) = jump_counts(2,1) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) > 10 && abs(rotate_cords(last_cord,2)) <= 10 
                plot(pos_x_mid_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(2,3) = plot_counts(2,3) + 1;
                jump_counts(2,3) = jump_counts(2,3) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) < -10 && rotate_cords(last_cord,2) < -10 
                plot(neg_x_neg_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(3,1) = plot_counts(3,1) + 1;
                jump_counts(3,1) = jump_counts(3,1) + jump_logic(iterZ);
            elseif abs(rotate_cords(last_cord,1)) <= 10 && rotate_cords(last_cord,2) < -10 
                plot(mid_x_neg_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(3,2) = plot_counts(3,2) + 1;
                jump_counts(3,2) = jump_counts(3,2) + jump_logic(iterZ);
            elseif rotate_cords(last_cord,1) > 10 && rotate_cords(last_cord,2) < -10 
                plot(pos_x_neg_y, rotate_cords(:,1), rotate_cords(:,2));
                plot_counts(3,3) = plot_counts(3,3) + 1;
                jump_counts(3,3) = jump_counts(3,3) + jump_logic(iterZ);
            end
            catch
                warning('to long');
            end
        end
        set(pos_x_pos_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');
        set(pos_x_mid_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');
        set(pos_x_neg_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');
        
        set(neg_x_pos_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');
        set(neg_x_mid_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on'); 
        set(neg_x_neg_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on'); 

        set(mid_x_pos_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');
        set(mid_x_mid_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on'); 
        set(mid_x_neg_y,'xlim',[-200 200],'Ylim',[-200 200],'Xtick',-200:50:200,'Ytick',-200:50:200,'XGrid','on','YGrid','on');         
        
        title(sprintf('Backwards and Left\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(1,1),(jump_counts(1,1) / plot_counts(1,1))*100),'parent',neg_x_pos_y);
        title(sprintf('Rotate 90 Left\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(1,2),(jump_counts(1,2) / plot_counts(1,2))*100),'parent',mid_x_pos_y);
        title(sprintf('Forward Left\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(1,3),(jump_counts(1,3) / plot_counts(1,3))*100),'parent',pos_x_pos_y);
        
        title(sprintf('Straight Forward \nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(2,3),(jump_counts(2,3) / plot_counts(2,3))*100),'parent',pos_x_mid_y);
        title(sprintf('Straight Backwards\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(2,1),(jump_counts(2,1) / plot_counts(2,1))*100),'parent',neg_x_mid_y);
        title(sprintf('No Movement\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(2,2),(jump_counts(2,2) / plot_counts(2,2))*100),'parent',mid_x_mid_y);
        
        title(sprintf('Backwards and Right\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(3,1),(jump_counts(3,1) / plot_counts(3,1))*100),'parent',neg_x_neg_y);
        title(sprintf('Rotate 90 Right\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(3,2),(jump_counts(3,2) / plot_counts(3,2))*100),'parent',mid_x_neg_y);
        title(sprintf('Forward Right\nCount: %4.0f, Jump Pct : %2.4f%%',plot_counts(3,3),(jump_counts(3,3) / plot_counts(3,3))*100),'parent',pos_x_neg_y);
        
    end
    function [x_plot,y_plot] = split_fig(proto_used)     %how many subplots to make
        if proto_used == 1;                x_plot = 1; y_plot = 1;
        elseif proto_used == 2;            x_plot = 1; y_plot = 2;
        elseif proto_used <= 4;            x_plot = 2; y_plot = 2;
        elseif proto_used <= 6;            x_plot = 2; y_plot = 3;
        elseif proto_used <= 8;            x_plot = 4; y_plot = 2;
        elseif proto_used <= 9;            x_plot = 4; y_plot = 3;
        elseif proto_used <= 12;           x_plot = 3; y_plot = 4;
        elseif proto_used <= 16;           x_plot = 4; y_plot = 4;
        elseif proto_used <= 20;           x_plot = 5; y_plot = 4;
        elseif proto_used <= 25;           x_plot = 5; y_plot = 5;
        elseif proto_used <= 30;           x_plot = 5; y_plot = 6;
        elseif proto_used <= 36;           x_plot = 6; y_plot = 6;            
        end        
    end 
    
        function new_test_function(~,~)
        [filt_data,full_genotype,~] = get_timing_info;
%        geno_logic = cellfun(@(x) ~isempty(strfind(x,'    DL Wildtype')),full_genotype);
%        geno_logic = cellfun(@(x) ~isempty(strfind(x,'   Giant Fiber(27721)')),full_genotype);
%        geno_logic = cellfun(@(x) ~isempty(strfind(x,'DN058(49024)')),full_genotype);
        geno_logic = cellfun(@(x) ~isempty(strfind(x,'1062')),full_genotype);
        filt_data = filt_data(geno_logic,:);
        
        [~,jump_logic,rem_records,new_start] = get_jump_info(filt_data);
        remove_data = cellfun(@(x) isempty(x),filt_data.bot_points_and_thetas);        
        filt_data((rem_records | remove_data),:) = [];        
        jump_logic((rem_records | remove_data)) = [];        
        new_start((rem_records | remove_data)) = [];
        
        bottom_roi_pos = cell2mat(cellfun(@(x) x(2,:),filt_data.Adjusted_ROI,'uniformoutput',false));
        tracked_frames = cellfun(@(x,y) length(x),filt_data.bot_points_and_thetas);
                
        figure
        tracking_data = cellfun(@(x,y) x(y,:),filt_data.bot_points_and_thetas,num2cell(new_start),'uniformoutput',false);        
        org_pos = make_plot_quivers(tracking_data,bottom_roi_pos,rgb('orange'));

        light_cut_pos = [0,25,50,75,100,150,200,300,400];
        for iterZ = 1:length(light_cut_pos)
            light_delay = light_cut_pos(iterZ)*6;
            subplot(3,3,iterZ)
        
            last_frame = zeros(length(tracking_data),1);
            last_frame(jump_logic) = cell2mat(filt_data(jump_logic,:).frame_of_leg_push);
            last_frame(~jump_logic) = new_start(~jump_logic) + light_delay;

            last_frame(last_frame > (new_start + light_delay)) = new_start((last_frame > new_start + light_delay)) + light_delay;
            last_frame(last_frame > tracked_frames) = tracked_frames(last_frame > tracked_frames);

            tracking_data = cellfun(@(x,y) x(y,:),filt_data.bot_points_and_thetas,num2cell(last_frame),'uniformoutput',false);        
            final_pos = make_plot_quivers(tracking_data,bottom_roi_pos,rgb('blue'));        
            
            still_on_prism = last_frame >= (new_start + light_delay);

            plot_movement_diff(final_pos(still_on_prism,:),org_pos(still_on_prism,:))
            title(sprintf('Distrubition of movement :: %4.0f Flies\n%3.0f milliseconds after lights on',sum(still_on_prism),light_cut_pos(iterZ)));
        end
    end
    function org_pos = make_plot_quivers(tracking_data,bottom_roi_pos,quiv_color)
        org_pos = cell2mat(tracking_data);
        offset = 832-384;
        
        org_pos(:,1) = (org_pos(:,1) - bottom_roi_pos(:,1));            %aligns x pos to bottom right of prism
        org_pos(:,2) = bottom_roi_pos(:,2) - ((org_pos(:,2)+offset));
        org_pos(:,3) = rem(rem(org_pos(:,3),(2*pi))+(2*pi),(2*pi));
               
%         u = cos(org_pos(:,3))*15;                v = sin(org_pos(:,3))*15;        
%         degree_pos = org_pos(:,3) * 180/pi;
%         
%         set(gca,'nextplot','add');
%    
         h_quiv = quiver(org_pos(:,1),org_pos(:,2),u,v,'MaxHeadSize',5,'LineWidth',2,'color',quiv_color);
%         
%         axis equal
%         line([135 135],[0 270],'color',rgb('black'),'linewidth',.8);
%         line([0 270],[135 135],'color',rgb('black'),'linewidth',.8);
%         set(gca,'Xlim',[0 270],'ylim',[0 270],'Ytick',0:50:270,'Xtick',0:50:270);
%         grid on
    end
    function plot_movement_diff(final_pos,org_pos)
        total_movement = final_pos - org_pos;
        u = cos(total_movement(:,3))*15;                v = sin(total_movement(:,3))*15;        
        h_quiv = quiver(total_movement(:,1),total_movement(:,2),u,v,'MaxHeadSize',5,'LineWidth',1.1,'color',rgb('green'));
        
        line([0 0],[-200 200],'color',rgb('black'),'linewidth',.8);
        line([-200 200],[0 0],'color',rgb('black'),'linewidth',.8);
        axis equal
        set(gca,'Xlim',[-200 200],'ylim',[-200 200],'Ytick',-200:50:200,'Xtick',-200:50:200);
        grid on        
    end
    