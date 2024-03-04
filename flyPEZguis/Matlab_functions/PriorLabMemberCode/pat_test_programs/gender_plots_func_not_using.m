 function gender_plots(~,~)
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        geno_id = cellfun(@(x) x(33:40),summary_table.Properties.RowNames,'UniformOutput',false);
        
        uni_geno = unique(geno_id);
        for iterZ = 1:length(uni_geno)
            geno_logic = ismember(geno_id,uni_geno{iterZ});
            sample_data = summary_table(geno_logic,:);
            
            [~,hist_edges,bin_index] = histcounts(sample_data.Stim_Fly_Saw_At_Trigger,-202.5:45:202.5);
            stimuli_fly_saw = hist_edges(bin_index)+22.5;
            stimuli_fly_saw(stimuli_fly_saw == -180) = 180;

            [total_table,~,~,cross_labels] = crosstab(stimuli_fly_saw,sample_data.Gender);
            
            jump_logic = cell2mat(sample_data.jumpTest);
            done_logic = cellfun(@(x) ~isempty(x), sample_data.frame_of_leg_push);
            done_jump_logic = cellfun(@(x) ~isnan(x),  sample_data(done_logic,:).frame_of_leg_push);
            jump_logic(done_logic) = done_jump_logic;
            
            [jump_table,~,~,cross_labels] = crosstab(stimuli_fly_saw(jump_logic),sample_data(jump_logic,:).Gender);
        end                
        summary_table(cellfun(@(x) isempty(x), summary_table.frame_of_leg_push),:) = [];
        summary_table(cellfun(@(x) isnan(x), summary_table.frame_of_leg_push),:) = [];
        geno_id = cellfun(@(x) x(33:40),summary_table.Properties.RowNames,'UniformOutput',false);
        wing_cycle = cellfun(@(x,y) log((x-y)/6),summary_table.wing_down_stroke,summary_table.frame_of_wing_movement);
        time_to_contact = cellfun(@(x,y,z) z-(x+y),summary_table.Start_Frame,summary_table.Stimuli_Duration,summary_table.frame_of_leg_push);
        [y_data,x_data,pez_data] = iosr.statistics.tab2box(geno_id,wing_cycle,summary_table.Gender);
        
        figure
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                         'showScatter', true,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                    

        h.groupLabels = pez_data;
        h.boxColor = {rgb('red');rgb('blue')};
        h.showlegend = true;
        set(gca,'XTickLabel',[{'DL Wildtype'},{'ESC_SS01062'}],'fontsize',15)
        
        y_tick_labels = [0.5 1 3 5 10 25 50 100  250 1000];
        set(gca,'Ytick',log(y_tick_labels),'YTickLabel',y_tick_labels,'TickLabelInterpreter','none')
        ylabel('Duration of first wing cycle log(ms)');
        
        text(1,log(250),sprintf('%4.4e',ranksum((y_data(:,1,1)),(y_data(:,1,2)))),'HorizontalAlignment','center','fontsize',15);
        text(2,log(250),sprintf('%4.4e',ranksum((y_data(:,2,1)),(y_data(:,2,2)))),'HorizontalAlignment','center','fontsize',15);
        
        
        
        [y_data,x_data,pez_data] = iosr.statistics.tab2box(geno_id,time_to_contact,summary_table.Gender);
        
        figure
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                         'showScatter', true,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                            
                     
                     
       summary_table(cellfun(@(x,y) size(x(:,3),1) < y,summary_table.bot_points_and_thetas,summary_table.frame_of_leg_push),:) = [];
       fly_pos_jump = cellfun(@(x,y) x(y,3).*180/pi,summary_table.bot_points_and_thetas,summary_table.frame_of_leg_push);
       fly_rotation = (fly_pos_jump - summary_table.Fly_Pos_At_Stim_Start);
       fly_rotation(fly_rotation < -180) = fly_rotation(fly_rotation < -180) + 360;
       fly_rotation(fly_rotation >  180) = fly_rotation(fly_rotation >  180) - 360;
       geno_id = cellfun(@(x) x(33:40),summary_table.Properties.RowNames,'UniformOutput',false);
       
        [y_data,x_data,pez_data] = iosr.statistics.tab2box(geno_id,fly_rotation,summary_table.Gender);
        
        figure
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                         'showScatter', true,'boxAlpha',.25,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                            
        h.groupLabels = pez_data;
        h.boxColor = {rgb('red');rgb('blue')};
        h.showlegend = true;
        set(gca,'XTickLabel',[{'DL Wildtype'},{'ESC_SS01062'}],'fontsize',15)
        set(gca,'Ylim',[-90 90],'Ytick',-90:30:90,'TickLabelInterpreter','none')
        title('Amount fly turned between start of stimuli and start of jump','fontsize',20)
        ylabel('rotation amount','fontsize',14);
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 function get_trigger_pos(test_table,flag,index)
        [stim_logic,~,stim_x,stim_y] = get_postion_info(test_table,index);
        total_count = sum(stim_logic);
        jumpers = sum(cell2mat(test_table(stim_logic,:).jumpTest));
        circ_plot(test_table(stim_logic,:).Fly_Pos_At_Stim_Start.*pi/180,'pat_special',[],(360/10),true,true,'linewidth',2,'color','r',.2);
        if strcmp(flag,'wall')
            line([-.4 -.4],[-.1 .1],'linewidth',2,'color',rgb('blue'))
        end
        line(stim_x,stim_y,'linewidth',2,'color',rgb('red'))
        set(gca,'Xlim',[-.4 .4],'Ylim',[-.4 .4])
        h_title = title(sprintf('Number of Flies :: %4.0f',total_count),'HorizontalAlignment','center','Interpreter','none','fontsize',14);
        curr_pos = get(h_title,'position');
        curr_pos(2) =  curr_pos(2) - .10;
        set(h_title,'position',curr_pos);
         
%        title(sprintf('Stimuli Presentend %s\nNumber of Flies :: %4.0f,  Jump Rate :: %4.4f%%',title_str,total_count,(jumpers/total_count)*100),...
%                'HorizontalAlignment','center','Interpreter','none','fontsize',14);
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 function fly_pos_stim_start(~,~)
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        summary_table = summary_table((summary_table.fly_detect_azimuth + 360) >= 225 & (summary_table.fly_detect_azimuth + 360) <= 315,:);
        
        DL_Data  = cellfun(@(x) contains(x,'00000430'),summary_table.Properties.RowNames);
        ESC_1062 = cellfun(@(x) contains(x,'00002519'),summary_table.Properties.RowNames);
        
        DL_table = summary_table(DL_Data,:);
        azi_angles = (-180-22.5):45:(180-22.5);
        figure
        for iterZ = 2:length(azi_angles)
        
            if azi_angles(iterZ-1)+22.5 == -180
                front_stimuli_DL = DL_table(abs(DL_table.Stim_Fly_Saw_At_Trigger) >= abs(azi_angles(iterZ)),:);
            else
                front_stimuli_DL = DL_table(DL_table.Stim_Fly_Saw_At_Trigger >= azi_angles(iterZ-1) & DL_table.Stim_Fly_Saw_At_Trigger <= azi_angles(iterZ),:);
            end
            [jump_data,stay_data] = split_jump_stay_data(front_stimuli_DL);
            jump_rate = (height(jump_data) ./ height(front_stimuli_DL))*100;
            [refrence_frame,jump_data] = get_trk_end_pos(jump_data,'loom',1);
            switch azi_angles(iterZ)-22.5
                case -180
                    index = 4;
                case -135
                    index = 7;
                case -90
                    index = 8;
                case -45
                    index = 9;
                case 0
                    index = 6;
                case 45
                    index = 3;
                case 90
                    index = 2;
                case 135
                    index = 1;
            end
            subplot(3,3,index);
            set(gca,'nextplot','add')
            move_diff = jump_data.Fly_Pos_At_Stim_Start-(refrence_frame+360);
            move_diff(move_diff < -180) = move_diff(move_diff < -180) + 360;
            move_diff(move_diff >  180) = move_diff(move_diff >  180) - 360;
            
            pdf_cdf_testing(move_diff(cellfun(@(x) strcmp(x,'Male'),jump_data.Gender)),-360:5:360,rgb('dark green'));
            pdf_cdf_testing(move_diff(cellfun(@(x) strcmp(x,'Female'),jump_data.Gender)),-360:5:360,rgb('light green'));
            [refrence_frame,stay_data] = get_trk_end_pos(stay_data,'loom',1);
            
            move_diff = stay_data.Fly_Pos_At_Stim_Start-(refrence_frame+360);
            move_diff(move_diff < -180) = move_diff(move_diff < -180) + 360;
            move_diff(move_diff >  180) = move_diff(move_diff >  180) - 360;
            
            pdf_cdf_testing(move_diff(cellfun(@(x) strcmp(x,'Male'),jump_data.Gender)),-360:5:360,rgb('dark red'));
            pdf_cdf_testing(move_diff(cellfun(@(x) strcmp(x,'Female'),jump_data.Gender)),-360:5:360,rgb('light red'));
            title(sprintf('Angle Fly Saw :: %4.0f\n jump rate :: %2.4f%%',azi_angles(iterZ)-22.5,jump_rate),'Interpreter','none');
            set(gca,'ytick',[],'Xlim',[-180 180],'Xtick',-180:30:180);
        end
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [refrence_frame,test_table] = get_trk_end_pos(test_table,flag,index)
        if isempty(test_table)
            total_count = 0;        
            circ_plot(test_table.Fly_Pos_At_Stim_Start.*pi/180,'pat_special',[],(360/10),true,true,'linewidth',2,'color','r',.2);
            title(sprintf('Number of Flies :: %4.0f',total_count),'HorizontalAlignment','center','Interpreter','none','fontsize',14);
            set(gca,'Xlim',[-.4 .4],'Ylim',[-.4 .4])
            return
        end
        [jump_data,stay_data] = split_jump_stay_data(test_table);
        jump_data(cellfun(@(x,y) size(x,1) <= y,jump_data.bot_points_and_thetas,jump_data.frame_of_leg_push),:) = [];
        jump_position_at_leg = cellfun(@(x,y) x(y,3) .* 180/pi,jump_data.bot_points_and_thetas,jump_data.frame_of_leg_push);
        stay_position_at_leg = cellfun(@(x,y) x(y,3) .* 180/pi,stay_data.bot_points_and_thetas,stay_data.final_frame_tracked);

        refrence_frame = [jump_position_at_leg;stay_position_at_leg];
        combo_table = [jump_data;stay_data];
        [locA,~] = ismember(test_table.Properties.RowNames,combo_table.Properties.RowNames);
        test_table = test_table(locA,:);
        test_table = test_table(combo_table.Properties.RowNames,:);
        
        
        refrence_frame(refrence_frame >  180) = refrence_frame(refrence_frame >  180) - 360;
        refrence_frame(refrence_frame < -180) = refrence_frame(refrence_frame < -180) + 360;
        [stim_logic,~,stim_x,stim_y] = get_postion_info(test_table,index);
        
        total_count = sum(stim_logic);
%        refrence_frame = refrence_frame(stim_logic);
%         circ_plot(refrence_frame.*pi/180,'pat_special',[],(360/10),true,true,'linewidth',2,'color','r',.2);
%         if strcmp(flag,'wall')
%             line([-.4 -.4],[-.1 .1],'linewidth',2,'color',rgb('blue'))
%         end
%         line(stim_x,stim_y,'linewidth',2,'color',rgb('red'))
%         set(gca,'Xlim',[-.4 .4],'Ylim',[-.4 .4])
%         h_title = title(sprintf('Number of Flies :: %4.0f',total_count),'HorizontalAlignment','center','Interpreter','none','fontsize',14);        
%         curr_pos = get(h_title,'position');
%         curr_pos(2) =  curr_pos(2) - .10;
%         set(h_title,'position',curr_pos);
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 function [stim_logic,title_str,stim_x,stim_y] = get_postion_info(test_table,index)
        switch index
            case 1  %front position
                stim_logic =  test_table.Stim_Fly_Saw_At_Trigger >= -45 & test_table.Stim_Fly_Saw_At_Trigger < 45;
                title_str = 'In front of the fly';
                stim_x = [-.05 .05];   stim_y = [-.3 -.3];
            case 2  %right position
                stim_logic = test_table.Stim_Fly_Saw_At_Trigger >= 45 & test_table.Stim_Fly_Saw_At_Trigger < 135;
                title_str = 'the Left side of the Fly';
                stim_x = [.3 .3];   stim_y = [-.05 .05];                    
            case 3  %behind position
                stim_logic = test_table.Stim_Fly_Saw_At_Trigger >= 135 | test_table.Stim_Fly_Saw_At_Trigger < -135;
                title_str = 'Behind of the Fly';
                stim_x = [-.05 .05];   stim_y = [.3 .3];
            case 4  %left position
                stim_logic = test_table.Stim_Fly_Saw_At_Trigger >= -135 & test_table.Stim_Fly_Saw_At_Trigger < -45;
                title_str = 'the Right side of the Fly';
                stim_x = [-.3 -.3];   stim_y = [-.05 .05];                    
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function find_movement_between_stim_sizes(~,~)
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        summary_table = summary_table((summary_table.fly_detect_azimuth + 360) >= 225 & (summary_table.fly_detect_azimuth + 360) <= 315,:);
        
        DL_Data  = cellfun(@(x) contains(x,'00000430'),summary_table.Properties.RowNames);
        ESC_1062 = cellfun(@(x) contains(x,'00002519'),summary_table.Properties.RowNames);
                        
        DL_table = summary_table(DL_Data,:);
        
        %angle_cuts = [10:10:30,45:15:90,180];
        angle_cuts = [10,30:30:180];
        figure; 
        for iterS = 1:4
            subplot(2,2,iterS)
            switch iterS
                case 1  %front position
                    stim_logic = DL_table.Stim_Fly_Saw_At_Trigger >= -45 & DL_table.Stim_Fly_Saw_At_Trigger < 45;
                    title_str = 'In front of the fly';
                case 2  %right position
                    stim_logic = DL_table.Stim_Fly_Saw_At_Trigger >= 45 & DL_table.Stim_Fly_Saw_At_Trigger < 135;
                    title_str = 'the Right side of the Fly';
                case 3  %behind position
                    stim_logic = DL_table.Stim_Fly_Saw_At_Trigger >= 135 | DL_table.Stim_Fly_Saw_At_Trigger < -135;
                    title_str = 'Behind of the Fly';
                case 4  %left position
                    stim_logic = DL_table.Stim_Fly_Saw_At_Trigger >= -135 & DL_table.Stim_Fly_Saw_At_Trigger < -45;
                    title_str = 'the Left side of the Fly';
            end

            set(gca,'nextplot','add')
            for iterZ = 2:length(angle_cuts)
            [total_vids,~,~,total_rotation] = caculate_movement(DL_table(stim_logic,:),angle_cuts(iterZ-1),angle_cuts(iterZ));
                hb = boxplot(total_rotation,'positions',angle_cuts(iterZ),'widths',5,'datalim',[-45 45],'extrememode','compress');
%                hb = boxplot(total_rotation,'positions',[angle_cuts(iterZ)-5 angle_cuts(iterZ)+5],'widths',5,'datalim',[-45 45],'extrememode','compress');
%                set(hb(:,1),'color',rgb('red'));                set(hb(:,2),'color',rgb('blue'));
            end
            set(gca,'Xlim',[0 190],'Xtick',angle_cuts,'XTickLabel',angle_cuts,'Ytick',-45:15:45,'ygrid','on')
            title(sprintf('Stimuli Shown from %s\nTotal Rotation Amount by size of stimuli',title_str),'Interpreter','none','HorizontalAlignment','center');
        end
        
        ESC_table = summary_table(ESC_1062,:);
        figure; 
        for iterS = 1:4
            subplot(2,2,iterS)
            switch iterS
                case 1  %front position
                    stim_logic = ESC_table.Stim_Fly_Saw_At_Trigger >= -45 & ESC_table.Stim_Fly_Saw_At_Trigger < 45;
                    title_str = 'In front of the fly';
                case 2  %right position
                    stim_logic = ESC_table.Stim_Fly_Saw_At_Trigger >= 45 & ESC_table.Stim_Fly_Saw_At_Trigger < 135;
                    title_str = 'the Right side of the Fly';
                case 3  %behind position
                    stim_logic = ESC_table.Stim_Fly_Saw_At_Trigger >= 135 | ESC_table.Stim_Fly_Saw_At_Trigger < -135;
                    title_str = 'Behind of the Fly';
                case 4  %left position
                    stim_logic = ESC_table.Stim_Fly_Saw_At_Trigger >= -135 & ESC_table.Stim_Fly_Saw_At_Trigger < -45;
                    title_str = 'the Left side of the Fly';
            end

            set(gca,'nextplot','add')
            for iterZ = 2:length(angle_cuts)
            [total_vids,~,~,total_rotation] = caculate_movement(ESC_table(stim_logic,:),angle_cuts(iterZ-1),angle_cuts(iterZ));
                hb = boxplot(total_rotation,'positions',[angle_cuts(iterZ)-5 angle_cuts(iterZ)+5],'widths',5,'datalim',[-45 45],'extrememode','compress');
                set(hb(:,1),'color',rgb('red'));                set(hb(:,2),'color',rgb('blue'));
            end
            set(gca,'Xlim',[0 190],'Xtick',angle_cuts,'XTickLabel',angle_cuts,'Ytick',-45:15:45,'ygrid','on')
            title(sprintf('Stimuli Shown from %s\nTotal Rotation Amount by size of stimuli',title_str),'Interpreter','none','HorizontalAlignment','center');
        end
        
     
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
